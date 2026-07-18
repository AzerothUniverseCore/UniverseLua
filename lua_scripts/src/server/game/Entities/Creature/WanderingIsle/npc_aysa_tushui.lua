local QUEST_WAY_OF_THE_TUSHUI = 29414
local NPC_AYSA                = 54567
local NPC_AYSA_LAKE_ESCORT    = 56661
local NPC_MASTER_LI_FEI       = 54856
local NPC_TROUBLEMAKER        = 59637
local SPELL_MEDITATION_BAR    = 116421
local AREA_CAVE_OF_MEDITATION = 5848

local STANDSTATE_STAND        = 0
local STANDSTATE_SIT          = 1

local MEDITATION_DURATION     = 90
local WAVE_INTERVAL_MS        = 15000
local MOBS_PER_WAVE           = 3

local LIFEI_TALK_THRESHOLDS   = { 25, 30, 42, 54, 66, 78, 85 }

local TROUBLEMAKER_SPAWNS = {
    { x = 1154.55, y = 3438.75, z = 104.973, o = 3.0 },
    { x = 1154.55, y = 3438.75, z = 104.973, o = 3.3 },
    { x = 1154.55, y = 3438.75, z = 104.973, o = 3.6 },
}

local AysaState = {}

local function GetState(creature)
    local guid = creature:GetGUID()
    if not AysaState[guid] then
        AysaState[guid] = {
            aysaGUID         = guid,
            meditationActive = false,
            meditationTimer  = 0,
            lifeiGUID        = nil,
            playerGUIDs      = {},
            eventWave        = nil,
            eventTick        = nil,
            eventEnd         = nil,
            eventStart       = nil,
            eventIntro       = nil,
            inScript         = false,
        }
    end
    return AysaState[guid]
end

local function ClearState(creature)
    AysaState[creature:GetGUID()] = nil
end

-- -------------------------------------------------------
-- GESTION DES JOUEURS PAR GUID
-- -------------------------------------------------------
local function UpdatePlayerGUIDs(creature, state)
    state.playerGUIDs = {}
    local players = creature:GetPlayersInRange(25)
    if not players then return end
    for _, player in ipairs(players) do
        if player then
            local ok, isGM = pcall(function() return player:IsGameMaster() end)
            if ok and not isGM then
                local ok2, status = pcall(function()
                    return player:GetQuestStatus(QUEST_WAY_OF_THE_TUSHUI)
                end)
                if ok2 and status == 3 then
                    local ok3, guid = pcall(function() return player:GetGUID() end)
                    if ok3 and guid then
                        table.insert(state.playerGUIDs, guid)
                    end
                end
            end
        end
    end
end

local function ForEachPlayer(map, state, callback)
    for _, guid in ipairs(state.playerGUIDs) do
        local player = map:GetWorldObject(guid)
        if player then
            callback(player)
        end
    end
end

-- -------------------------------------------------------
-- LI FEI
-- -------------------------------------------------------
local function GetOrSpawnLifei(creature, state)
    if state.lifeiGUID then
        local map = creature:GetMap()
        local lifei = map and map:GetWorldObject(state.lifeiGUID)
        if lifei and lifei:IsAlive() then
            return lifei
        end
        state.lifeiGUID = nil
    end
    local lifei = creature:SpawnCreature(
        NPC_MASTER_LI_FEI,
        1130.162231, 3435.905518, 105.496597, 0.0,
        3, 0
    )
    if lifei then
        lifei:MoveRandom(5.0)
        state.lifeiGUID = lifei:GetGUID()
    end
    return lifei
end

local function DespawnLifei(map, state)
    if state.lifeiGUID then
        local lifei = map and map:GetWorldObject(state.lifeiGUID)
        if lifei then lifei:DespawnOrUnsummon(0) end
        state.lifeiGUID = nil
    end
end

-- -------------------------------------------------------
-- EVENTS
-- -------------------------------------------------------
local function CancelAllEvents(state)
    if state.eventWave  then RemoveEventById(state.eventWave)  ; state.eventWave  = nil end
    if state.eventTick  then RemoveEventById(state.eventTick)  ; state.eventTick  = nil end
    if state.eventEnd   then RemoveEventById(state.eventEnd)   ; state.eventEnd   = nil end
    if state.eventStart then RemoveEventById(state.eventStart) ; state.eventStart = nil end
    if state.eventIntro then RemoveEventById(state.eventIntro) ; state.eventIntro = nil end
end

local function CleanupPlayers(map, state)
    if not map then return end
    ForEachPlayer(map, state, function(player)
        player:RemoveAura(SPELL_MEDITATION_BAR)
    end)
end

-- -------------------------------------------------------
-- VAGUE DE TROUBLEMAKERS
-- -------------------------------------------------------
local function SpawnMobWave(creature)
    for i = 1, MOBS_PER_WAVE do
        local sp = TROUBLEMAKER_SPAWNS[i] or TROUBLEMAKER_SPAWNS[1]
        local mob = creature:SpawnCreature(
            NPC_TROUBLEMAKER,
            sp.x, sp.y, sp.z, sp.o,
            1, 12000
        )
        if mob then
            mob:SetReactState(1)
            mob:AttackStart(creature)
            mob:AddThreat(creature, 300.0)
        end
    end
end

-- -------------------------------------------------------
-- MEDITATION PRINCIPALE
-- -------------------------------------------------------
local function StartMeditation(creature)
    local state = GetState(creature)
    if state.inScript then return end

    creature:SetStandState(STANDSTATE_SIT)
    creature:SetReactState(0)
    state.meditationActive = true
    state.inScript         = true
    state.meditationTimer  = 0

    UpdatePlayerGUIDs(creature, state)

    creature:SendUnitSay("Je vais mediter maintenant. Protegez-moi des perturbateurs !", 0)

    local firstTick = true
    state.eventTick = creature:RegisterEvent(function(eId, delay, repeats, c)
        if not state.meditationActive then return end
        if firstTick then
            firstTick = false
            --print("|cff00ff88[Aysa]|r Tick meditation demarre (RegisterEvent OK).")
        end

        local m = c:GetMap()
        if not m then return end

        state.meditationTimer = state.meditationTimer + 1
        local pct = math.min(
            math.floor((state.meditationTimer / MEDITATION_DURATION) * 100),
            100
        )

        -- Dialogues Li Fei aux seuils
        for i, threshold in ipairs(LIFEI_TALK_THRESHOLDS) do
            if state.meditationTimer == threshold then
                local lifei = GetOrSpawnLifei(c, state)
                if lifei then
                    lifei:SendUnitSay("...", i - 1)
                    if i == 7 then
                        lifei:DespawnOrUnsummon(500)
                        state.lifeiGUID = nil
                    end
                end
                break
            end
        end

        -- Mise a jour barre de progression
        UpdatePlayerGUIDs(c, state)
        ForEachPlayer(m, state, function(player)
            if not player:HasAura(SPELL_MEDITATION_BAR) then
                player:CastSpell(player, SPELL_MEDITATION_BAR, true)
            end
            player:SetPower(11, pct)
            player:SetMaxPower(11, 100)
        end)

    end, 1000, 0)

    -- -------------------------------------------------------
    -- Vagues de mobs (meme fix : RegisterEvent au lieu de CreateLuaEvent)
    -- -------------------------------------------------------
    local firstWave = true
    state.eventWave = creature:RegisterEvent(function(eId, delay, repeats, c)
        if not state.meditationActive then return end
        if firstWave then
            firstWave = false
            --print("|cff00ff88[Aysa]|r Premiere vague de perturbateurs (RegisterEvent OK).")
        end

        UpdatePlayerGUIDs(c, state)
        SpawnMobWave(c)

    end, WAVE_INTERVAL_MS, 0)

    -- -------------------------------------------------------
    -- Fin de meditation (meme fix : RegisterEvent au lieu de CreateLuaEvent)
    -- -------------------------------------------------------
    state.eventEnd = creature:RegisterEvent(function(eId, delay, repeats, c)
        state.eventEnd         = nil
        state.meditationActive = false
        state.inScript         = false

        if state.eventTick then RemoveEventById(state.eventTick) ; state.eventTick = nil end
        if state.eventWave then RemoveEventById(state.eventWave) ; state.eventWave = nil end

        local m = c:GetMap()
        if not m then return end

        DespawnLifei(m, state)

        c:SetStandState(STANDSTATE_STAND)
        c:SetReactState(1)
        c:SendUnitSay("La meditation est accomplie. Vous avez bien defendu la Voie de Tushui.", 0)

        -- Snapshot final des GUIDs
        UpdatePlayerGUIDs(c, state)
        local finalGUIDs = {}
        for _, g in ipairs(state.playerGUIDs) do
            table.insert(finalGUIDs, g)
        end

        -- Barre 100% + credit quete
        for _, guid in ipairs(finalGUIDs) do
            local player = m:GetWorldObject(guid)
            if player then
                player:SetPower(11, 100)
                player:SetMaxPower(11, 100)
                player:KilledMonsterCredit(NPC_MASTER_LI_FEI, 0)
            end
        end

        -- Retrait aura differe de 2s via RegisterEvent (c est fourni safe)
        c:RegisterEvent(function(eId2, delay2, repeats2, c2)
            local m2 = c2:GetMap()
            if not m2 then return end
            for _, guid in ipairs(finalGUIDs) do
                local player = m2:GetWorldObject(guid)
                if player then
                    player:RemoveAura(SPELL_MEDITATION_BAR)
                end
            end
        end, 2000, 1)

        state.meditationTimer = 0

        -- Nouvelle session dans 30s
        state.eventStart = c:RegisterEvent(function(eId3, delay3, repeats3, c3)
            state.eventStart = nil
            StartMeditation(c3)
        end, 30000, 1)

    end, MEDITATION_DURATION * 1000, 1)
end

-- -------------------------------------------------------
-- INTERRUPTION (HP < 5%)
-- -------------------------------------------------------
local function InterruptMeditation(creature, state)
    if not state.inScript then return end

    state.meditationActive = false
    state.inScript         = false
    state.meditationTimer  = 0

    CancelAllEvents(state)

    local map = creature:GetMap()
    DespawnLifei(map, state)
    CleanupPlayers(map, state)

    creature:SetStandState(STANDSTATE_STAND)
    creature:SetHealth(creature:GetMaxHealth())
    creature:SetReactState(1)

    local mobs = creature:GetCreaturesInRange(60, NPC_TROUBLEMAKER)
    if mobs then
        for _, mob in ipairs(mobs) do
            creature:DealDamage(mob, mob:GetHealth(), false)
        end
    end

    creature:SendUnitSay("Ma meditation a ete interrompue ! Nous devons recommencer.", 0)

    state.eventStart = creature:RegisterEvent(function(eId, delay, repeats, c)
        state.eventStart = nil
        StartMeditation(c)
    end, 20000, 1)
end

-- ============================================================
-- NPC 56661 - npc_aysa_lake_escort
-- ============================================================
local JUMP_POINT_1 = 1
local JUMP_POINT_2 = 2
local JUMP_POINT_3 = 3

local function Escort_OnSpawn(event, creature)
    creature:SetReactState(0)
    creature:RegisterEvent(function(eventId, delay, repeats, c)
        c:SendUnitSay("...", 0)
        c:MoveJump(1196.72, 3492.85, 90.9836, 10, 20, JUMP_POINT_1)
    end, 2500, 1)
end

local function Escort_OnMoveInform(event, creature, moveType, pointId)
    if moveType ~= 0 and moveType ~= 6 then return end

    if pointId == JUMP_POINT_1 then
        creature:MoveJump(1192.29, 3478.69, 108.788, 10, 20, JUMP_POINT_2)
    elseif pointId == JUMP_POINT_2 then
        creature:MoveJump(1197.99, 3460.63, 103.04, 10, 20, JUMP_POINT_3)
    elseif pointId == JUMP_POINT_3 then
        creature:RegisterEvent(function(eventId, delay, repeats, c)
            c:DespawnOrUnsummon(0)
        end, 500, 1)
    end
end

RegisterCreatureEvent(NPC_AYSA_LAKE_ESCORT, 14, Escort_OnSpawn)
RegisterCreatureEvent(NPC_AYSA_LAKE_ESCORT, 28, Escort_OnMoveInform)

-- ============================================================
-- NPC 54567 - npc_aysa
-- ============================================================

local function Aysa_OnDamageTaken(event, creature, attacker, damage)
    local state = GetState(creature)
    if not state.inScript then return end

    local hp    = creature:GetHealth()
    local maxhp = creature:GetMaxHealth()

    if (hp - damage) <= (maxhp * 0.05) then
        InterruptMeditation(creature, state)
    end
end

local function Aysa_OnSpawn(event, creature)
    local state = GetState(creature)
    creature:SetReactState(1)
    creature:SetFaction(2263)

    if creature:GetAreaId() == AREA_CAVE_OF_MEDITATION then
        state.eventStart = creature:RegisterEvent(function(eId, delay, repeats, c)
            state.eventStart = nil
            StartMeditation(c)
        end, 3000, 1)
    end
end

local function Aysa_OnRemove(event, creature)
    local state = GetState(creature)
    CancelAllEvents(state)
    local map = creature:GetMap()
    DespawnLifei(map, state)
    CleanupPlayers(map, state)
    ClearState(creature)
end

local function Aysa_OnQuestAccept(event, player, creature, quest)
    if quest:GetId() ~= QUEST_WAY_OF_THE_TUSHUI then return end

    local state = GetState(creature)
    if state.inScript then
        InterruptMeditation(creature, state)
    end
    CancelAllEvents(state)

    -- Sequence de deplacement vers la cave (RegisterEvent = safe, c est fourni)
    creature:RegisterEvent(function(eId, delay, repeats, c)
        c:MoveJump(1196.72, 3492.85, 90.9836, 10, 20, 0)
    end, 1000, 1)

    creature:RegisterEvent(function(eId, delay, repeats, c)
        c:MoveJump(1192.29, 3478.69, 108.788, 10, 20, 0)
    end, 3000, 1)

    creature:RegisterEvent(function(eId, delay, repeats, c)
        c:MoveJump(1197.99, 3460.63, 103.04, 10, 20, 0)
    end, 5500, 1)

    creature:RegisterEvent(function(eId, delay, repeats, c)
        c:MoveTo(4, 1192.92, 3455.66, 103.082)
    end, 7500, 1)

    creature:RegisterEvent(function(eId, delay, repeats, c)
        c:MoveTo(5, 1179.78, 3445.48, 102.417)
    end, 8500, 1)

    creature:RegisterEvent(function(eId, delay, repeats, c)
        c:MoveTo(6, 1137.02, 3432.98, 105.536)
    end, 10875, 1)

    -- Arrivee dans la cave -> meditation (RegisterEvent = safe)
    creature:RegisterEvent(function(eId, delay, repeats, c)
        StartMeditation(c)
    end, 17500, 1)
end

-- -------------------------------------------------------
-- Hooks
-- -------------------------------------------------------
RegisterCreatureEvent(NPC_AYSA, 14, Aysa_OnSpawn)           -- ON_SPAWN
RegisterCreatureEvent(NPC_AYSA, 37, Aysa_OnRemove)          -- ON_REMOVE
RegisterCreatureEvent(NPC_AYSA, 6,  Aysa_OnDamageTaken)     -- ON_DAMAGE_TAKEN
RegisterCreatureEvent(NPC_AYSA, 31, Aysa_OnQuestAccept)     -- ON_QUEST_ACCEPT
