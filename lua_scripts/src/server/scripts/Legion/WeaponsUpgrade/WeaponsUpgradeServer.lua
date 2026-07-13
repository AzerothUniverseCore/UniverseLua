-- WeaponsUpgradeServer.lua
local AIO = AIO or require("AIO")

local WEAPON_UPGRADE = 249516

-- Cache pour stocker les mappings d'amélioration
local upgradeCache = {}
local cacheLoaded = false

-- Fonction pour charger les données depuis la DB
local function LoadUpgradeMappings()
    if cacheLoaded then
        return
    end
    
    local query = WorldDBQuery("SELECT current_item_id, upgraded_item_id FROM weapons_upgrade")
    
    if query then
        local count = 0
        repeat
            local currentItemId = query:GetUInt32(0)
            local upgradedItemId = query:GetUInt32(1)
            upgradeCache[currentItemId] = upgradedItemId
            count = count + 1
        until not query:NextRow()
        
        cacheLoaded = true
    end
end

-- Charger les mappings au démarrage du serveur
LoadUpgradeMappings()

local WeaponsUpgradeHandlers = AIO.AddHandlers("WeaponsUpgradeHandler", {})

function WeaponsUpgradeHandlers.UpgradeItem(player, itemEntry)
    local currencyID = 339505 -- ID de la monnaie personnalisée
    local currencyCost = 14000 -- Coût en monnaie personnalisée
    
    -- Vérifier le niveau du joueur
    if player:GetLevel() < 80 then
        player:SendBroadcastMessage("Vous devez être au moins de niveau 80 pour améliorer cette arme.")
        return
    end
    
    -- Vérifier que le joueur possède l'arme
    local item = player:GetItemByEntry(itemEntry)
    if not item then
        player:SendBroadcastMessage("Arme prodigieuse non trouvée dans votre inventaire.")
        return
    end
    
    -- Vérifier la monnaie
    local currentCurrency = player:GetItemCount(currencyID)
    if currentCurrency < currencyCost then
        player:SendBroadcastMessage("Vous n'avez pas assez de |cffffffff[Cristaux d'Infusion]|r pour améliorer cette arme prodigieuse.")
        return
    end
    
    -- Récupérer l'ID de l'arme améliorée depuis le cache
    local newItemID = upgradeCache[itemEntry]
    
    if not newItemID then
        player:SendBroadcastMessage("Cet objet ne peut pas être amélioré ou n'est pas une arme prodigieuse valide.")
        return
    end
    
    -- Effectuer l'amélioration
    player:RemoveItem(itemEntry, 1)
    player:AddItem(newItemID, 1)
    player:RemoveItem(currencyID, currencyCost)
    
    player:SendBroadcastMessage(string.format(
        "Votre arme prodigieuse a été améliorée avec succès ! Vous avez dépensé |cffffffff%d Cristaux d'Infusion|r.",
        currencyCost
    ))
end

-- Fonction pour recharger le cache (utile pour les mises à jour à chaud)
function WeaponsUpgradeHandlers.ReloadCache()
    upgradeCache = {}
    cacheLoaded = false
    LoadUpgradeMappings()
end

-- Fonction pour envoyer le mapping au client (pour l'aperçu)
local function SendMappingToClient(player)
    AIO.Handle(player, "WeaponsUpgradeHandler", "SetUpgradeMapping", upgradeCache)
end

-- Event 1 : Gossip Hello → animation + ouverture interface
local function OnGossipHello(event, player, gameObject)
    -- Joue l'animation d'activation du GO (durée 10s)
    gameObject:UseDoorOrButton(10000)
    -- Envoyer le mapping puis ouvrir l'interface
    SendMappingToClient(player)
    AIO.Handle(player, "WeaponsUpgradeHandler", "OpenInterface")
    player:GossipComplete()
end

RegisterGameObjectGossipEvent(WEAPON_UPGRADE, 1, OnGossipHello)

-- Commande GM pour recharger le cache
local function OnCommand(event, player, command)
    if command == "reload weapons" then
        if player:GetGMRank() >= 3 then
            WeaponsUpgradeHandlers.ReloadCache()
            player:SendBroadcastMessage("[WeaponsUpgrade] Cache rechargé depuis la base de données.")
            return false
        end
    end
end

RegisterPlayerEvent(42, OnCommand) -- PLAYER_EVENT_ON_COMMAND
