-- DestinyPandaServer.lua
local AIO = AIO or require("AIO")

-- ------------------------------------------------------------
--  Locale du joueur (bilingue frFR / enUS, repli sur frFR)
-- ------------------------------------------------------------
local function GetPlayerLocale(player)
    local ok, result = pcall(function()
        local accountId = player:GetAccountId()
        local q = AuthDBQuery("SELECT locale FROM account WHERE id = "..accountId..";")
        if q then
            local loc = q:GetUInt8(0)
            if loc == 0 then return "enUS" end
        end
        return "frFR"
    end)
    if ok and result then return result end
    return "frFR"
end

local DestinyNotif = {
    frFR = {
        CANT_JOIN_ALLIANCE = "|cff00ff98Vous ne pouvez pas rejoindre l'Alliance en tant que membre de la Horde.|r",
        CANT_JOIN_HORDE     = "|cff00ff98Vous ne pouvez pas rejoindre la Horde en tant que membre de l'Alliance.|r",
        LEVEL_REQUIRED      = "|cff00ff98Vous devez être au moins niveau 17 pour aller vers votre destin.|r",
        QUEST_REQUIRED      = "|cff00ff98Vous devez d'abord terminer la quête : (De nouveaux alliés) pour aller vers votre destin.|r",
    },
    enUS = {
        CANT_JOIN_ALLIANCE = "|cff00ff98You cannot join the Alliance as a member of the Horde.|r",
        CANT_JOIN_HORDE     = "|cff00ff98You cannot join the Horde as a member of the Alliance.|r",
        LEVEL_REQUIRED      = "|cff00ff98You must be at least level 17 to head toward your destiny.|r",
        QUEST_REQUIRED      = "|cff00ff98You must first complete the quest: (New Allies) to head toward your destiny.|r",
    },
}
local function L(player)
    return DestinyNotif[GetPlayerLocale(player)] or DestinyNotif.frFR
end

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
            player:SendBroadcastMessage(L(player).CANT_JOIN_ALLIANCE)
            player:SendNotification(L(player).CANT_JOIN_ALLIANCE)
            return false
        end
        -- Téléportation vers l'Alliance
        player:Teleport(0, -8905, 560, 94, 0.62)  -- Coordonnées de l'Alliance
        return false
    elseif command == "teleport_panda horde" then
        -- Si le joueur est de l'Alliance, il ne peut pas se téléporter vers la Horde
        if team == 0 then
            player:SendBroadcastMessage(L(player).CANT_JOIN_HORDE)
            player:SendNotification(L(player).CANT_JOIN_HORDE)
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
        player:SendBroadcastMessage(L(player).LEVEL_REQUIRED)
		player:SendNotification(L(player).LEVEL_REQUIRED)
        return
    end

    -- Vérifie si la quête 29800 a été complétée en vérifiant la récompense
    if not player:HasReceivedQuestReward(questID) then
        player:SendBroadcastMessage(L(player).QUEST_REQUIRED)
		player:SendNotification(L(player).QUEST_REQUIRED)
        return
    end

    -- Ouvre la frame UI DestinyPandaFrame lorsque le joueur clique sur le GameObject
    AIO.Handle(player, "DestinyFactionHandler", "OpenDestinyInterface")
end

-- Enregistrez l'événement Gossip pour le GameObject spécifié
RegisterGameObjectGossipEvent(WEAPON_UPGRADE_GAMEOBJECT_ID, 1, OnGossipHello)