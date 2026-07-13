-- TaxiPathSystemServer.lua
local AIO = AIO or require("AIO")
local TxiPathHandlers = AIO.AddHandlers("TxiPathSystemServer", {})

-- Fonction de téléportation du joueur avec vérification de la faction
function TxiPathHandlers.TeleportPlayer(player, mapId, x, y, z, orientation)
    local faction = player:GetTeam()  -- 0 = Alliance, 1 = Horde

    -- Effectue la téléportation
    player:Teleport(mapId, x, y, z, orientation)
end

-- Fonction pour gérer l'interaction avec le GameObject
function TxiPathHandlers.OnGameObjectGossipHello(event, player, gameObject)
    if gameObject:GetEntry() == 1660056 then  -- Vérifie si l'ID du GameObject est 1660056
        -- Ouvre l'interface via le client
        AIO.Handle(player, "TxiPathSystemClient", "ShowMainFrame")  -- Appelle la fonction qui montre l'UI
    end
end

-- Enregistre l'événement d'interaction sur le GameObject (ON_HELLO)
RegisterGameObjectGossipEvent(1660056, 1, TxiPathHandlers.OnGameObjectGossipHello)  -- 1 correspond à l'événement ON_HELLO