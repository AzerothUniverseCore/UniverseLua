-- AIO spell charges -- TrinityCore 3.3.5 / Eluna compatible version.
-- Install this file and spell_charges_client.lua in your Eluna scripts path.

local AIO = AIO or require("AIO")

if AIO.IsMainState and not AIO.IsMainState() then
    return
end

local PREFIX = "SpellCharges"

-- Eluna PlayerEvents enum (official values from elunaluaengine.github.io)
local PLAYER_EVENT_ON_LOGIN          = 3
local PLAYER_EVENT_ON_LOGOUT         = 4
local PLAYER_EVENT_ON_SPELL_CAST     = 5   -- (event, player, spell, skipCheck)
local PLAYER_EVENT_ON_KILL_PLAYER    = 6
local PLAYER_EVENT_ON_TALENTS_RESET  = 17
local PLAYER_EVENT_ON_COMMAND        = 42
local PLAYER_EVENT_ON_LEARN_SPELL    = 44

local RESET_AFTER_LOGOUT_MS = 15 * 60 * 1000

local spells      = {}
local groups      = {}
local playerState = {}
local spellCount  = 0
local recentCasts = {}
local CAST_DEBOUNCE_MS = 300

local MSG_BEGIN   = PREFIX .. "_Begin"
local MSG_ROW     = PREFIX .. "_Row"
local MSG_END     = PREFIX .. "_End"
local MSG_REQUEST = PREFIX .. "_Request"

local function log(message)
    print("[SpellCharges] " .. message)
end

-- ---------------------------------------------------------------------------
-- AIO client registration
-- ---------------------------------------------------------------------------
local function registerClientAddon()
    if not AIO.AddAddon and not AIO.AddAddonCode then
        --log("AIO addon registration missing; spell_charges_client.lua cannot be sent.")
        return
    end

    local source = debug.getinfo(1, "S").source
    if source:sub(1, 1) == "@" then
        source = source:sub(2)
    end

    local candidates = {
        source:gsub("spell_charges%.lua$", "spell_charges_client.lua"),
        "lua_scripts/src/server/scripts/Spells/SpellCharges/spell_charges_client.lua",
        "lua_scripts/scripts/spell_charges_client.lua",
        "scripts/spell_charges_client.lua",
    }

    for _, clientPath in ipairs(candidates) do
        local file = io.open(clientPath, "rb")
        if file then
            local code = file:read("*all")
            file:close()

            if AIO.AddAddonCode then
                AIO.AddAddonCode("spell_charges_client.lua", code)
                --log("Registered AIO client addon code from: " .. clientPath)
                return
            end

            local ok, err = pcall(AIO.AddAddon, clientPath, "spell_charges_client.lua")
            if ok then
                --log("Registered AIO client addon path: " .. clientPath)
                return
            end

            --log("AIO.AddAddon failed for " .. clientPath .. ": " .. tostring(err))
        end
    end

    --log("Could not find spell_charges_client.lua. Put it beside spell_charges.lua or in lua_scripts/scripts/.")
end

-- ---------------------------------------------------------------------------
-- DB helpers
-- ---------------------------------------------------------------------------
local function ensureTable()
    WorldDBExecute([[
        CREATE TABLE IF NOT EXISTS spell_charges_spells (
            spell_id INT UNSIGNED NOT NULL,
            group_id INT UNSIGNED NOT NULL DEFAULT 0,
            max_charges TINYINT UNSIGNED NOT NULL,
            base_cooldown INT UNSIGNED NOT NULL,
            PRIMARY KEY (spell_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end

local function getNow()
    return GetCurrTime()
end

local function normalizeGroupId(spellId, groupId)
    if groupId == nil or groupId == 0 then
        return spellId
    end
    return groupId
end

local function loadConfig()
    spells     = {}
    groups     = {}
    spellCount = 0

    ensureTable()

    local query = WorldDBQuery([[
        SELECT spell_id, group_id, max_charges, base_cooldown
        FROM spell_charges_spells
        ORDER BY spell_id ASC
    ]])

    if not query then
        --log("No configured spells found in spell_charges_spells.")
        return
    end

    repeat
        local spellId      = query:GetUInt32(0)
        local groupId      = normalizeGroupId(spellId, query:GetUInt32(1))
        local maxCharges   = query:GetUInt8(2)
        local baseCooldown = query:GetUInt32(3)

        if maxCharges >= 2 and baseCooldown > 0 then
            spells[spellId] = {
                spellId      = spellId,
                groupId      = groupId,
                maxCharges   = maxCharges,
                baseCooldown = baseCooldown,
            }

            if not groups[groupId] then
                groups[groupId] = {
                    groupId      = groupId,
                    maxCharges   = maxCharges,
                    baseCooldown = baseCooldown,
                    spellIds     = {},
                }
            end

            local group = groups[groupId]
            group.maxCharges   = math.max(group.maxCharges,   maxCharges)
            group.baseCooldown = math.max(group.baseCooldown, baseCooldown)
            table.insert(group.spellIds, spellId)
            spellCount = spellCount + 1
        end
    until not query:NextRow()
end

-- ---------------------------------------------------------------------------
-- Player state helpers
-- ---------------------------------------------------------------------------
local function getGuidState(guidLow)
    if not playerState[guidLow] then
        playerState[guidLow] = {
            groups   = {},
            logoutAt = 0,
        }
    end
    return playerState[guidLow]
end

local function ensureGroupState(guidLow, groupId)
    local guidState = getGuidState(guidLow)
    local group     = groups[groupId]
    if not group then
        return nil
    end

    if not guidState.groups[groupId] then
        guidState.groups[groupId] = {
            charges           = group.maxCharges,
            effectiveCooldown = group.baseCooldown,
            readyAt           = 0,
            timerId           = nil,
        }
    end

    return guidState.groups[groupId]
end

local function removeTimer(state, player)
    if state and state.timerId then
        if player then
            player:RemoveEventById(state.timerId)
        else
            RemoveEventById(state.timerId)
        end
        state.timerId = nil
    end
end

local function resetSpellCooldowns(player, group)
    for _, spellId in ipairs(group.spellIds) do
        if player:HasSpell(spellId) then
            player:ResetSpellCooldown(spellId, true)
        end
    end
end

-- ---------------------------------------------------------------------------
-- Network helpers
-- ---------------------------------------------------------------------------
local function buildEntryPayload(spellId, groupState, group)
    local now       = getNow()
    local remaining = 0

    if groupState.readyAt and groupState.readyAt > now then
        remaining = groupState.readyAt - now
    end

    return table.concat({
        "R",
        tostring(spellId),
        tostring(group.maxCharges),
        tostring(math.max(0, math.min(group.maxCharges, groupState.charges))),
        tostring(groupState.effectiveCooldown or group.baseCooldown),
        tostring(remaining),
    }, "|")
end

local function sendStatus(player)
    if not player then
        return
    end

    local guidLow = player:GetGUIDLow()

    AIO.Msg():Add(MSG_BEGIN):Send(player)

    for spellId, info in pairs(spells) do
        if player:HasSpell(spellId) then
            local group      = groups[info.groupId]
            local groupState = ensureGroupState(guidLow, info.groupId)
            AIO.Msg():Add(MSG_ROW, buildEntryPayload(spellId, groupState, group)):Send(player)
        end
    end

    AIO.Msg():Add(MSG_END):Send(player)
end

-- ---------------------------------------------------------------------------
-- Recharge scheduling
-- ---------------------------------------------------------------------------
local function scheduleRecharge(player, groupId, delay)
    if not player then
        return
    end

    local guidLow = player:GetGUIDLow()
    local group   = groups[groupId]
    local state   = ensureGroupState(guidLow, groupId)
    if not group or not state then
        return
    end

    if state.charges >= group.maxCharges or state.timerId then
        return
    end

    delay         = math.max(1, delay or group.baseCooldown)
    state.readyAt = getNow() + delay

    state.timerId = player:RegisterEvent(function(_, _, _, eventPlayer)
        state.timerId = nil
        state.charges = math.min(group.maxCharges, state.charges + 1)
        state.readyAt = 0

        resetSpellCooldowns(eventPlayer, group)
        sendStatus(eventPlayer)

        if state.charges < group.maxCharges then
            scheduleRecharge(eventPlayer, groupId, state.effectiveCooldown or group.baseCooldown)
        end
    end, delay, 1)
end

local function advanceOfflineRecharge(player)
    local guidLow   = player:GetGUIDLow()
    local guidState = playerState[guidLow]
    if not guidState or not guidState.logoutAt or guidState.logoutAt == 0 then
        return
    end

    local elapsed = getNow() - guidState.logoutAt
    if elapsed >= RESET_AFTER_LOGOUT_MS then
        playerState[guidLow] = nil
        return
    end

    for groupId, state in pairs(guidState.groups) do
        local group = groups[groupId]
        if group then
            local cooldown = state.effectiveCooldown or group.baseCooldown
            if cooldown > 0 and state.charges < group.maxCharges then
                local gained  = math.floor(elapsed / cooldown)
                state.charges = math.min(group.maxCharges, state.charges + gained)
                removeTimer(state, player)

                if state.charges < group.maxCharges then
                    local remainder = cooldown - (elapsed % cooldown)
                    scheduleRecharge(player, groupId, remainder)
                end
            end
        end
    end

    guidState.logoutAt = 0
end

-- ---------------------------------------------------------------------------
-- Cast debounce
-- ---------------------------------------------------------------------------
local function shouldProcessCast(guidLow, spellId)
    local key = guidLow .. ":" .. spellId
    local now = getNow()

    if recentCasts[key] and (now - recentCasts[key]) < CAST_DEBOUNCE_MS then
        return false
    end

    recentCasts[key] = now
    return true
end

-- ---------------------------------------------------------------------------
-- PLAYER_EVENT_ON_SPELL_CAST = 5
-- Signature: function(event, player, spell, skipCheck)
-- Called before the spell is executed. Return false to cancel it.
-- ---------------------------------------------------------------------------
local function onSpellCast(event, player, spell, skipCheck)
    if not player or not spell then
        return
    end

    local spellId = spell:GetEntry()
    local info    = spells[spellId]
    if not info then
        return
    end

    local group   = groups[info.groupId]
    local guidLow = player:GetGUIDLow()
    local state   = ensureGroupState(guidLow, info.groupId)
    if not group or not state then
        return
    end

    -- No charges left: cancel the cast.
    if state.charges < 1 then
        player:SendNotification("No charges remaining for this spell.")
        return false
    end

    if not shouldProcessCast(guidLow, spellId) then
        return
    end

    state.charges = state.charges - 1

    local cooldown = player:GetSpellCooldownDelay(spellId)
    if not cooldown or cooldown <= 0 then
        cooldown = group.baseCooldown
    end

    state.effectiveCooldown = cooldown

    -- Still have charges: reset cooldown so the spell is usable immediately.
    if state.charges > 0 then
        resetSpellCooldowns(player, group)
    end

    scheduleRecharge(player, info.groupId, cooldown)
    sendStatus(player)
end

-- ---------------------------------------------------------------------------
-- Other player event handlers
-- ---------------------------------------------------------------------------
local function onLogin(event, player)
    advanceOfflineRecharge(player)
    sendStatus(player)
end

local function onLogout(event, player)
    local guidLow   = player:GetGUIDLow()
    local guidState = getGuidState(guidLow)
    guidState.logoutAt = getNow()

    for _, state in pairs(guidState.groups) do
        removeTimer(state, player)
    end
end

local function resetPlayer(player)
    local guidLow   = player:GetGUIDLow()
    local guidState = playerState[guidLow]
    if guidState then
        for _, state in pairs(guidState.groups) do
            removeTimer(state, player)
        end
    end

    playerState[guidLow] = nil
    sendStatus(player)
end

local function onTalentsReset(event, player)
    resetPlayer(player)
end

local function onLearnSpell(event, player)
    sendStatus(player)
end

local function onCommand(event, player, command)
    local cmd = string.lower(command or "")
    if cmd ~= "spellcharges" and cmd ~= "spellcharges reset" then
        return true
    end

    if not player or player:GetGMRank() < 3 then
        return true
    end

    resetPlayer(player)
    player:SendNotification("Spell charges reset.")
    return false
end

local function onRequest(player)
    sendStatus(player)
end

-- ---------------------------------------------------------------------------
-- Bootstrap
-- ---------------------------------------------------------------------------
registerClientAddon()
loadConfig()

RegisterPlayerEvent(PLAYER_EVENT_ON_SPELL_CAST,    onSpellCast)
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGIN,          onLogin)
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGOUT,         onLogout)
RegisterPlayerEvent(PLAYER_EVENT_ON_TALENTS_RESET,  onTalentsReset)
RegisterPlayerEvent(PLAYER_EVENT_ON_LEARN_SPELL,    onLearnSpell)
RegisterPlayerEvent(PLAYER_EVENT_ON_COMMAND,        onCommand)
AIO.RegisterEvent(MSG_REQUEST, onRequest)

--log("Loaded " .. tostring(spellCount) .. " configured spell(s).")
