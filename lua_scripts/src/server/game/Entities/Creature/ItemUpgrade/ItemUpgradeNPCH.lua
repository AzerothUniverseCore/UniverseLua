-- ItemUpgradeNPC.lua - Script pour ouvrir l'UI via un PNJ
local AIO = AIO or require("AIO")

local NPC_ENTRY = 57801

-- Event OnGossipHello : quand le joueur parle au PNJ
local function OnGossipHello(event, player, creature)
    --player:GossipClearMenu()
    --player:GossipMenuAddItem(0, "Améliorer mes objets", 0, 1)
	AIO.Handle(player, "ItemUpgrade", "ToggleFrame")
    --player:GossipSendMenu(1, creature)
end

-- Event OnGossipSelect : quand le joueur sélectionne une option
local function OnGossipSelect(event, player, creature, sender, action)
    if action == 1 then
        player:GossipComplete()
        -- Ouvrir l'interface ItemUpgrade
        AIO.Handle(player, "ItemUpgrade", "ToggleFrame")
    end
end

-- Enregistrer les events pour le PNJ
RegisterCreatureGossipEvent(NPC_ENTRY, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ENTRY, 2, OnGossipSelect)

--print("|cFF00FF00ItemUpgradeNPC chargé ! PNJ ID: " .. NPC_ENTRY .. "|r")