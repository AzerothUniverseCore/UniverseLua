local function OnSpiritRelease(event, player)
    -- Vérification si le joueur est sur la carte battleground (Map 761)
    local mapId = player:GetMapId()
    if mapId == 761 then
        -- Coordonnées du cimetière pour l'Alliance
        local allianceX = 909.46
        local allianceY = 1337.36
        local allianceZ = 27.6449

        -- Coordonnées du cimetière pour la Horde
        local hordeX = 1401.38
        local hordeY = 977.125
        local hordeZ = 7.44215

        -- Vérifier l'équipe du joueur dans le battleground (0 pour Alliance, 1 pour Horde)
        if player:GetTeam() == 0 then  -- Alliance
            player:Teleport(mapId, allianceX, allianceY, allianceZ, 0)  -- Orientation à 0
        elseif player:GetTeam() == 1 then  -- Horde
            player:Teleport(mapId, hordeX, hordeY, hordeZ, 0)  -- Orientation à 0
        end
    end
end

-- Enregistrer l'événement ON_RELEASE_SPIRIT pour déclencher la fonction à la libération de l'esprit
RegisterPlayerEvent(35, OnSpiritRelease)  -- 35 correspond à l'événement ON_RELEASE_SPIRIT
