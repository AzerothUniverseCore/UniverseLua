-- Téléportation automatique après avoir rendu la quête 59984
local QUEST_ID = 59984
local NPC_QUEST_STARTER = 166573
local MAP_ID = 863
local X, Y, Z, O = 4002.46, 8399.58, 322.217, 0.886692

local function OnQuestAccept(event, player, creature, quest, opt)
    if quest:GetId() == QUEST_ID then
        player:Teleport(MAP_ID, X, Y, Z, O)
    end
end

RegisterCreatureEvent(NPC_QUEST_STARTER, 31, OnQuestAccept)