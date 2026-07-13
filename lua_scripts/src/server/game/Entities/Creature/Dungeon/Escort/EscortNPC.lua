local NPC_ID = 338404

local function GossipHello(event, player, unit)
    player:GossipClearMenu()
    if not following then
        player:GossipMenuAddItem(0, "Bonjour ! Besoin d'un coup de main ?", 0, 1, false, "Dites-moi si vous désirez que je sois votre protecteur.", 0)
    end
    player:GossipSendMenu(1, unit)
end

local function GossipSelect(event, player, creature, sender, intid)
    if (intid == 1) then
        player:SendBroadcastMessage("Votre protecteur est prêt à entrer en action au combat !")
        creature:MoveFollow(player)
        
        creature:SetFaction(2110)

        local playerLevel = player:GetLevel()
        creature:SetLevel(playerLevel)
    end
end

RegisterCreatureGossipEvent(NPC_ID, 1, GossipHello)
RegisterCreatureGossipEvent(NPC_ID, 2, GossipSelect)