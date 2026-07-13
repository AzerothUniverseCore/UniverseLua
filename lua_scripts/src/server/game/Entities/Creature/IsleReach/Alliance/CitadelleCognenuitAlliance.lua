-- Téléportation automatique après avoir rendu la quête 55992
local QUEST_ID = 55992
local NPC_QUEST_STARTER = 156280
local MAP_ID = 863
local X, Y, Z, O = 898.273, -1771.58, 181.178, 3.6799

local function OnQuestAccept(event, player, creature, quest, opt)
    if quest:GetId() == QUEST_ID then
        player:Teleport(MAP_ID, X, Y, Z, O)
    end
end

RegisterCreatureEvent(NPC_QUEST_STARTER, 31, OnQuestAccept)