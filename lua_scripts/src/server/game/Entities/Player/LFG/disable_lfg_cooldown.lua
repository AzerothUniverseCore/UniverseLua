local function RemoveLFGCooldownAura(player)
    -- Enlève les auras liées aux cooldowns des donjons
    player:RemoveAura(71328)
    player:RemoveAura(71041)
end

local function OnPlayerLogin(event, player)
    -- Enlève les auras lorsque le joueur se déconnecte
    RemoveLFGCooldownAura(player)
end

local function OnPlayerLogout(event, player)
    -- Enlève les auras lorsque le joueur se déconnecte
    RemoveLFGCooldownAura(player)
end

local function OnPlayerZoneChange(event, player, newZone, newArea)
    -- Enlève les auras lorsque le joueur change de zone
    -- Vérifiez si le joueur est dans un donjon et si le changement de zone indique une sortie de donjon
    local instanceId = player:GetInstanceId()
    if instanceId and instanceId ~= 0 then
        RemoveLFGCooldownAura(player)
    end
end

local function OnPlayerMapChange(event, player, oldMap, newMap)
    -- Enlève les auras lorsque le joueur change de carte (peut inclure les sorties de donjon)
    -- Vérifiez si le joueur est dans un donjon
    local instanceId = player:GetInstanceId()
    if instanceId and instanceId ~= 0 then
        RemoveLFGCooldownAura(player)
    end
end

local function OnPlayerBindToInstance(event, player, difficulty, mapId, permanent)
    -- Enlève les auras lorsque le joueur se lie à une instance (entrée dans un donjon)
    -- Assurez-vous de ne pas enlever les auras si le donjon n'est pas accessible
    local instanceId = player:GetInstanceId()
    if instanceId and instanceId ~= 0 then
        RemoveLFGCooldownAura(player)
    end
end

-- Enregistre les événements pour le script
RegisterPlayerEvent(3, OnPlayerLogin)  -- PLAYER_EVENT_ON_LOGIN
RegisterPlayerEvent(4, OnPlayerLogout)  -- PLAYER_EVENT_ON_LOGOUT
RegisterPlayerEvent(27, OnPlayerZoneChange) -- PLAYER_EVENT_ON_UPDATE_ZONE
RegisterPlayerEvent(28, OnPlayerMapChange) -- PLAYER_EVENT_ON_MAP_CHANGE
RegisterPlayerEvent(26, OnPlayerBindToInstance) -- PLAYER_EVENT_ON_BIND_TO_INSTANCE
