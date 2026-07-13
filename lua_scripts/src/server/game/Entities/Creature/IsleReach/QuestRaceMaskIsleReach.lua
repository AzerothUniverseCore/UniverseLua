-- Gestion des quêtes Confins de l'exil selon la faction du joueur
-- Alliance NPC : 156280 | Horde NPC : 166573

local NPC_ALLIANCE   = 156280
local NPC_ALLIANCE_2 = 157046
local NPC_ALLIANCE_3 = 157043
local NPC_ALLIANCE_4 = 157042
local NPC_ALLIANCE_5 = 167886

local NPC_HORDE   = 166573
local NPC_HORDE_2 = 166585
local NPC_HORDE_3 = 245248
local NPC_HORDE_4 = 166590
local NPC_HORDE_5 = 166794
local NPC_HORDE_6 = 166799

-- Quêtes Alliance
local QUEST_ECHAUFFEMENT_A  = 56775
local QUEST_INEBRANLABLE_A  = 58209
local QUEST_IMPACT_A        = 58208

-- Quêtes Horde
local QUEST_ECHAUFFEMENT_H  = 59926
local QUEST_INEBRANLABLE_H  = 59927
local QUEST_IMPACT_H        = 59928

-- Races Alliance
local RACES_ALLIANCE = {
    [1]  = true, -- Human
    [3]  = true, -- Dwarf
    [4]  = true, -- Night Elf
    [7]  = true, -- Gnome
    [11] = true, -- Draenei
    [12] = true, -- Worgen
    [14] = true, -- Pandaren Alliance
    [16] = true, -- Night Elf Illidari
    [18] = true, -- Void Elf
    [21] = true, -- Lightforged Draenei
    [23] = true, -- Dark Iron Dwarf Alliance
    [25] = true, -- High Elf
    [27] = true, -- Vulpera Alliance
    [29] = true, -- Dracthyr Alliance
    [31] = true, -- Kul Tiran
}

-- Races Horde
local RACES_HORDE = {
    [2]  = true, -- Orc
    [5]  = true, -- Undead
    [6]  = true, -- Tauren
    [8]  = true, -- Troll
    [9]  = true, -- Goblin
    [10] = true, -- Blood Elf
    [13] = true, -- Pandaren Horde
    [15] = true, -- Blood Elf Illidari
    [17] = true, -- Eredar
    [19] = true, -- Vulpera Horde
    [20] = true, -- Nightborne
    [22] = true, -- Zandalari Troll
    [24] = true, -- Dark Iron Dwarf Horde
    [26] = true, -- Highmountain Tauren
    [28] = true, -- Dracthyr Horde
    [30] = true, -- Mag'har Orc
}

local function isAlliance(player)
    return RACES_ALLIANCE[player:GetRace()] == true
end

local function isHorde(player)
    return RACES_HORDE[player:GetRace()] == true
end

-- =====================================================
-- NPC ALLIANCE (156280) : bloque les races Horde
-- =====================================================
local function OnGossipHello_Alliance(event, player, object)
    if isHorde(player) then
        player:GossipMenuAddItem(0, "Ces quêtes sont réservées à l'Alliance.", 0, 1)
        player:GossipSendMenu(0xFFFFFFFF, object)
        return true -- bloque le menu de quête normal
    end
    return false
end

local function OnQuestAccept_Alliance(event, player, creature, quest)
    if isHorde(player) then
        player:SendBroadcastMessage("Ces quêtes sont réservées à l'Alliance.")
        return true -- bloque l'acceptation
    end
end

for _, npcId in ipairs({ NPC_ALLIANCE, NPC_ALLIANCE_2, NPC_ALLIANCE_3, NPC_ALLIANCE_4, NPC_ALLIANCE_5 }) do
    RegisterCreatureGossipEvent(npcId, 1, OnGossipHello_Alliance) -- events.gossip.on_hello
    RegisterCreatureEvent(npcId, 31, OnQuestAccept_Alliance)       -- CREATURE_EVENT_ON_QUEST_ACCEPT
end

-- =====================================================
-- NPC HORDE (166573) : bloque les races Alliance
-- =====================================================
local function OnGossipHello_Horde(event, player, object)
    if isAlliance(player) then
        player:GossipMenuAddItem(0, "Ces quêtes sont réservées à la Horde.", 0, 1)
        player:GossipSendMenu(0xFFFFFFFF, object)
        return true -- bloque le menu de quête normal
    end
    return false
end

local function OnQuestAccept_Horde(event, player, creature, quest)
    if isAlliance(player) then
        player:SendBroadcastMessage("Ces quêtes sont réservées à la Horde.")
        return true -- bloque l'acceptation
    end
end

for _, npcId in ipairs({ NPC_HORDE, NPC_HORDE_2, NPC_HORDE_3, NPC_HORDE_4, NPC_HORDE_5, NPC_HORDE_6 }) do
    RegisterCreatureGossipEvent(npcId, 1, OnGossipHello_Horde) -- events.gossip.on_hello
    RegisterCreatureEvent(npcId, 31, OnQuestAccept_Horde)       -- CREATURE_EVENT_ON_QUEST_ACCEPT
end