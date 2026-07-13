-- DestinyPandaServer.lua
local AIO = AIO or require("AIO")

local function OpenDestinyFaction(player)
    AIO.Handle(player, "DestinyFactionHandler", "OpenDestinyInterface")
end

local WEAPON_UPGRADE_GAMEOBJECT_ID = 5400427  -- ID du GameObject

local function TeleportPlayer(event, player, command)
    -- Vérifier l'équipe du joueur (Alliance = 0, Horde = 1)
    local team = player:GetTeam()  -- 0 pour Alliance, 1 pour Horde
    
    -- Fermer la frame avant de téléporter le joueur
    AIO.Handle(player, "DestinyFactionHandler", "CloseDestinyInterface")

    if command == "teleport_panda alliance" then
        -- Si le joueur est de la Horde, il ne peut pas se téléporter vers l'Alliance
        if team == 1 then
            player:SendBroadcastMessage("|cff00ff98Vous ne pouvez pas rejoindre l'Alliance en tant que membre de la Horde.|r")
            player:SendNotification('|cff00ff98Vous ne pouvez pas rejoindre l\'Alliance en tant que membre de la Horde.|r')
            return false
        end
        -- Téléportation vers l'Alliance
        player:Teleport(0, -8905, 560, 94, 0.62)  -- Coordonnées de l'Alliance
        return false
    elseif command == "teleport_panda horde" then
        -- Si le joueur est de l'Alliance, il ne peut pas se téléporter vers la Horde
        if team == 0 then
            player:SendBroadcastMessage("|cff00ff98Vous ne pouvez pas rejoindre la Horde en tant que membre de l'Alliance.|r")
            player:SendNotification('|cff00ff98Vous ne pouvez pas rejoindre la Horde en tant que membre de l\'Alliance.|r')
            return false
        end
        -- Téléportation vers la Horde
        player:Teleport(1, 1517.55, -4412.03, 21.7103, 0.243466)  -- Coordonnées de la Horde
        return false
    end
end

RegisterPlayerEvent(42, TeleportPlayer)

local function OnGossipHello(event, player, gameObject)
    local questID = 29800
    local requiredLevel = 17

    -- Vérifie si l'objet player est valide
    if not player or not player:IsInWorld() then
        return
    end

    -- Vérifie si le joueur a atteint le niveau requis
    if player:GetLevel() < requiredLevel then
        player:SendBroadcastMessage("|cff00ff98Vous devez être au moins niveau 17 pour aller vers votre destin.|r")
		player:SendNotification('|cff00ff98Vous devez être au moins niveau 17 pour aller vers votre destin.|r')
        return
    end

    -- Vérifie si la quête 29800 a été complétée en vérifiant la récompense
    if not player:HasReceivedQuestReward(questID) then
        player:SendBroadcastMessage("|cff00ff98Vous devez d'abord terminer la quête : (De nouveaux alliés) pour aller vers votre destin.|r")
		player:SendNotification('|cff00ff98Vous devez d\'abord terminer la quête : (De nouveaux alliés) pour aller vers votre destin.|r')
        return
    end

    -- Ouvre la frame UI DestinyPandaFrame lorsque le joueur clique sur le GameObject
    AIO.Handle(player, "DestinyFactionHandler", "OpenDestinyInterface")
end

-- Enregistrez l'événement Gossip pour le GameObject spécifié
RegisterGameObjectGossipEvent(WEAPON_UPGRADE_GAMEOBJECT_ID, 1, OnGossipHello)