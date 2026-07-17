-- ============================================================
--  Shu - Un nouvel ami (Quest 29679)
--  Script Lua Eluna / TrinityCore 3.3.5a
-- ============================================================

local SHU_ENTRY        = 65493
local SPELL_WATER_JET  = 117063
local QUEST_ID         = 29679
local KILL_CREDIT      = 60488

local PLATFORM_RADIUS  = 6.0
local POLL_MS          = 400
local POLL_REPEATS     = 5     -- ~2 secondes de detection apres le cast
local WAIT_BEFORE_CAST_MS = 4000   -- delai teleport -> cast (identique au smart_scripts d'origine : 4000/4000)
local CYCLE_INTERVAL_MS   = 10000  -- delai entre deux cycles (identique au smart_scripts d'origine : 10000/10000)

local PLATFORM_POSITIONS = {
    { x = 1102.05, y = 2882.11, z = 94.32, o = 0.11 },
    { x = 1120.01, y = 2883.20, z = 96.44, o = 4.17 },
    { x = 1128.09, y = 2859.44, z = 97.64, o = 2.51 },
    { x = 1111.52, y = 2849.84, z = 94.84, o = 1.94 },
}

local AIUPDATE_EVENT_ID = 7

pcall(function() math.randomseed(os.time()) end)

local shuState = {} -- [guid] = { started = bool }

local function dist2D(x1, y1, x2, y2)
    return math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
end

local function playerHasQuestActive(player)
    local ok, status = pcall(function() return player:GetQuestStatus(QUEST_ID) end)
    return ok and status == 3
end

local function CreditNearbyPlayers(creature, platform)
    local credited = {}

    creature:RegisterEvent(function(eventId, delay, repeats, creatureArg)
        if not creatureArg then return end

        local okWorld, inWorld = pcall(function() return creatureArg:IsInWorld() end)
        if not okWorld or not inWorld then return end

        local okMap, map = pcall(function() return creatureArg:GetMap() end)
        if not okMap or not map then return end

        local okPlayers, players = pcall(function() return map:GetPlayers() end)
        if not okPlayers or not players then return end

        for _, player in ipairs(players) do
            if player and playerHasQuestActive(player) then
                local pguid = player:GetGUIDLow()
                if not credited[pguid] then
                    local d = dist2D(player:GetX(), player:GetY(), platform.x, platform.y)
                    if d <= PLATFORM_RADIUS then
                        credited[pguid] = true
                        pcall(function() player:KilledMonsterCredit(KILL_CREDIT) end)
                    end
                end
            end
        end
    end, POLL_MS, POLL_REPEATS)
end

local function RunShuCycle(creature)
    if not creature then return end
    local okWorld, inWorld = pcall(function() return creature:IsInWorld() end)
    if not okWorld or not inWorld then return end

    local platform = PLATFORM_POSITIONS[math.random(#PLATFORM_POSITIONS)]

    local okJump, errJump = pcall(function()
        creature:MoveJump(platform.x, platform.y, platform.z, 10, 10)
    end)
    if not okJump then
        print("|cffffcc00[Shu]|r MoveJump indisponible (" .. tostring(errJump) .. "), repli sur NearTeleport.")
        local okTp, errTp = pcall(function()
            creature:NearTeleport(platform.x, platform.y, platform.z, platform.o)
        end)
        if not okTp then
            print("|cffff0000[Shu]|r NearTeleport a aussi echoue : " .. tostring(errTp))
        end
    end

    creature:RegisterEvent(function(eventId, delay, repeats, creatureArg)
        if not creatureArg then return end
        local okWorld2, inWorld2 = pcall(function() return creatureArg:IsInWorld() end)
        if not okWorld2 or not inWorld2 then return end

        CreditNearbyPlayers(creatureArg, platform)

        local okCast, errCast = pcall(function()
            creatureArg:CastSpell(creatureArg, SPELL_WATER_JET, true)
        end)
        if not okCast then
            print("|cffff0000[Shu]|r CastSpell a echoue : " .. tostring(errCast))
        end
    end, WAIT_BEFORE_CAST_MS, 1)

    creature:RegisterEvent(function(eventId, delay, repeats, creatureArg)
        if not creatureArg then return end
        RunShuCycle(creatureArg)
    end, CYCLE_INTERVAL_MS, 1)
end

local function OnShuAIUpdate(event, creature, diff)
    local guid = creature:GetGUIDLow()
    if not shuState[guid] then
        shuState[guid] = { started = true }
        -- print("|cff00ff88[Shu]|r Cycle demarre pour Shu (guid=" .. tostring(guid) .. ").")
        RunShuCycle(creature)
    end
end

local ok, err = pcall(function()
    RegisterCreatureEvent(SHU_ENTRY, AIUPDATE_EVENT_ID, OnShuAIUpdate)
end)
if not ok then
    print("|cffff0000[Shu]|r RegisterCreatureEvent a echoue : " .. tostring(err))
end

local cooldown_players = {}

local function OnQuestAccept(event, player, questId)
    if questId ~= QUEST_ID then return end
    cooldown_players[player:GetGUIDLow()] = nil
end

local function OnQuestAbandon(event, player, questId)
    if questId ~= QUEST_ID then return end
    cooldown_players[player:GetGUIDLow()] = nil
end

RegisterPlayerEvent(19, OnQuestAccept)
RegisterPlayerEvent(20, OnQuestAbandon)