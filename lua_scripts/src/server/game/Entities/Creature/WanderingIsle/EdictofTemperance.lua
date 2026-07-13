-- Script Lua pour TrinityCore 3.3.5 avec Eluna
-- Complète la quête 29408 "La leçon du parchemin brûlant" au clic sur le GameObject 210986

local GAMEOBJECT_ID = 210986  -- ID du GameObject (Edict of Temperance)
local QUEST_ID = 29408        -- ID de la quête "La leçon du parchemin brûlant"

-- Fonction appelée lors du clic sur le GameObject
local function OnGossipHello(event, player, gameobject)
    -- Vérifier si le joueur a la quête active
    if player:HasQuest(QUEST_ID) then
        -- Vérifier le statut de la quête
        local questStatus = player:GetQuestStatus(QUEST_ID)
        
        -- Si la quête n'est pas complétée (statut != 1)
        if questStatus ~= 1 then
            -- Compléter l'objectif de la quête ou la valider directement
            player:CompleteQuest(QUEST_ID)
            
            -- Message de confirmation au joueur (optionnel)
            player:SendBroadcastMessage("La quête 'La leçon du parchemin brûlant' a été validée !")
        else
            player:SendBroadcastMessage("Vous avez déjà complété cette quête.")
        end
    else
        player:SendBroadcastMessage("Vous devez d'abord accepter la quête.")
    end
    
    -- Fermer la fenêtre de gossip
    player:GossipComplete()
end

-- Enregistrer l'événement pour le GameObject
RegisterGameObjectGossipEvent(GAMEOBJECT_ID, 1, OnGossipHello)