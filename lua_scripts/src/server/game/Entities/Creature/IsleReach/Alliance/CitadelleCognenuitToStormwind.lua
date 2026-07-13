-- Téléportation automatique après avoir rendu la quête 59984
local QUEST_ID = 55992
local NPC_QUEST_ENDER = 156280
local MAP_ID = 807
local X, Y, Z, O = 11608.8, 11896, 13.1453, 0.190893

local function OnQuestReward(event, player, creature, quest, opt)
    if quest:GetId() == QUEST_ID then
        player:Teleport(MAP_ID, X, Y, Z, O)
    end
end

RegisterCreatureEvent(NPC_QUEST_ENDER, 34, OnQuestReward)