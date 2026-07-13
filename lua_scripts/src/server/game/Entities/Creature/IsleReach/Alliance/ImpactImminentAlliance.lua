-- Téléportation automatique après avoir rendu la quête 58208 "Impact imminent"
local QUEST_ID = 58208
local NPC_QUEST_ENDER = 156280
local MAP_ID = 859
local X, Y, Z, O = -456.128, -2607.34, 1.14247, 0.0887033

local function OnQuestReward(event, player, creature, quest, opt)
    if quest:GetId() == QUEST_ID then
        player:Teleport(MAP_ID, X, Y, Z, O)
    end
end

RegisterCreatureEvent(NPC_QUEST_ENDER, 34, OnQuestReward) -- CREATURE_EVENT_ON_QUEST_REWARD