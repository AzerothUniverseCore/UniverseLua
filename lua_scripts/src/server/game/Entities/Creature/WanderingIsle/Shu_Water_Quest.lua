-- ============================================================
--  Shu - Un nouvel ami (Quest 29679)
--  Script Lua Eluna / TrinityCore 3.3.5a  (multistate)
-- ============================================================

local SHU_ENTRY        = 65493
local SPELL_WATER_JET  = 117063
local QUEST_ID         = 29679
local KILL_CREDIT      = 60488

local PLATFORM_RADIUS  = 6.0
local POLL_MS          = 400
local POLL_REPEATS     = 5  -- 2 secondes de détection

local PLATFORM_POSITIONS = {
    { x = 1102.05, y = 2882.11, z = 94.32 },
    { x = 1120.01, y = 2883.20, z = 96.44 },
    { x = 1128.09, y = 2859.44, z = 97.64 },
    { x = 1111.52, y = 2849.84, z = 94.84 },
    { x = 1117.52, y = 2848.44, z = 92.22 },
    { x = 1105.79, y = 2885.37, z = 92.22 },
    { x = 1131.86, y = 2852.78, z = 92.22 },
    { x = 1125.67, y = 2851.84, z = 92.22 },
    { x = 1118.77, y = 2890.42, z = 92.22 },
    { x = 1113.78, y = 2886.40, z = 92.22 },
}

local currentMap   = nil
local cooldown_players = {}

local function dist2D(x1, y1, x2, y2)
    return math.sqrt((x1-x2)^2 + (y1-y2)^2)
end

local function playerHasQuestActive(player)
    return player:GetQuestStatus(QUEST_ID) == 3
end

-- Trouve la plateforme la plus proche de la position donnée
local function getNearestPlatform(x, y)
    local nearest = nil
    local minDist = math.huge
    for _, pos in ipairs(PLATFORM_POSITIONS) do
        local d = dist2D(x, y, pos.x, pos.y)
        if d < minDist then
            minDist = d
            nearest = pos
        end
    end
    return nearest, minDist
end

-- FIX : RegisterSpellEvent n'existe pas sur ce build Eluna (methode absente,
-- probablement parce que les spell hooks ne sont pas compiles dans ce fork
-- TrinityCore/Eluna), d'ou "attempt to call global 'RegisterSpellEvent' (a nil
-- value)". On detecte donc le cast de Shu autrement, avec des methodes
-- confirmees disponibles sur ce build : RegisterCreatureEvent (deja utilise
-- ailleurs dans le projet) + Unit:GetCurrentSpell, sondes via AIUPDATE.
local CREATURE_EVENT_ON_AIUPDATE = 7
local CURRENT_GENERIC_SPELL      = 1
local CURRENT_CHANNELED_SPELL    = 2

local wasCastingWaterJet = {}

local function GetCastedSpellEntry(creature)
    -- La plupart des sorts cibles (non instantanes-melee) passent par le slot
    -- "generique" ; on verifie aussi le slot "channele" au cas ou.
    local castedSpell = creature:GetCurrentSpell(CURRENT_GENERIC_SPELL)
    if not castedSpell then
        castedSpell = creature:GetCurrentSpell(CURRENT_CHANNELED_SPELL)
    end
    if not castedSpell then return nil end
    return castedSpell:GetEntry()
end

local function OnWaterJetCast(caster)
    if not caster then return end

    currentMap = caster:GetMap()
    if not currentMap then return end

    -- Plateforme la plus proche de Shu au moment du cast
    local shuX, shuY = caster:GetX(), caster:GetY()
    local targetPlatform, _ = getNearestPlatform(shuX, shuY)
    if not targetPlatform then return end

    local credited_this_cast = {}

    CreateLuaEvent(function(eventId, delay, rep)
        local players = currentMap:GetPlayers()
        if not players then return end

        for _, player in ipairs(players) do
            if player and playerHasQuestActive(player) then
                local pguid = player:GetGUIDLow()

                if not credited_this_cast[pguid] then
                    -- Vérifier uniquement sur LA plateforme ciblée par Shu
                    local d = dist2D(player:GetX(), player:GetY(), targetPlatform.x, targetPlatform.y)
                    if d <= PLATFORM_RADIUS then
                        credited_this_cast[pguid] = true
                        player:KilledMonsterCredit(KILL_CREDIT)
                    end
                end
            end
        end
    end, POLL_MS, POLL_REPEATS)
end

local function OnQuestAccept(event, player, questId)
    if questId ~= QUEST_ID then return end
    cooldown_players[player:GetGUIDLow()] = nil
end

local function OnQuestAbandon(event, player, questId)
    if questId ~= QUEST_ID then return end
    cooldown_players[player:GetGUIDLow()] = nil
end

-- Sonde l'etat de cast de Shu a chaque AIUPDATE (remplace RegisterSpellEvent).
local function OnShuAIUpdate(event, creature, diff)
    if creature:GetEntry() ~= SHU_ENTRY then return end

    local guid = creature:GetGUIDLow()
    local castEntry = GetCastedSpellEntry(creature)

    if castEntry == SPELL_WATER_JET then
        if not wasCastingWaterJet[guid] then
            -- Detection du front montant : on ne declenche qu'une fois par cast,
            -- au moment ou Shu commence a lancer Water Jet.
            wasCastingWaterJet[guid] = true
            OnWaterJetCast(creature)
        end
    else
        wasCastingWaterJet[guid] = nil
    end
end

RegisterCreatureEvent(SHU_ENTRY, CREATURE_EVENT_ON_AIUPDATE, OnShuAIUpdate)
RegisterPlayerEvent(19, OnQuestAccept)
RegisterPlayerEvent(20, OnQuestAbandon)