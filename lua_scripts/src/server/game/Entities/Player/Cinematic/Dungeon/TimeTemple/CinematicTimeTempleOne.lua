-- Script de cinématique déclenchée une seule fois en entrant dans une carte spécifique et une zone spécifique

-- ID de la cinématique à jouer
local cinematicID = 168

-- ID de la carte où la cinématique sera jouée
local mapID = 823

-- ID de la zone où la cinématique sera jouée
local zoneID = 5179

-- Fonction déclenchée lorsque le joueur change de zone
local function OnPlayerChangeZone(event, player, newZone, newArea)
    -- Vérifie si le joueur est dans la bonne carte et dans la bonne zone
    if player:GetMapId() == mapID and newZone == zoneID then
        -- Vérifie si le joueur a déjà vu la cinématique
        if not player:GetData("HasSeenCinematicOne") then
            -- Joue la cinématique
            player:SendCinematicStart(cinematicID)
            -- Marque la cinématique comme vue pour ce joueur
            player:SetData("HasSeenCinematicOne", true)
        end
    end
end

-- Enregistrez l'événement pour le changement de zone
RegisterPlayerEvent(27, OnPlayerChangeZone)
