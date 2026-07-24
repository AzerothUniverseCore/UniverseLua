local AIO = AIO or require("AIO")

local WEAPON_UPGRADE = 249516

local upgradeCache = {}
local cacheLoaded = false

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

LoadUpgradeMappings()

local WeaponsUpgradeHandlers = AIO.AddHandlers("WeaponsUpgradeHandler", {})

local function GetPlayerLocale(player)
    local ok, result = pcall(function()
        local accountId = player:GetAccountId()
        local q = AuthDBQuery("SELECT locale FROM account WHERE id = " .. accountId .. ";")
        if q then
            local localeId = q:GetUInt8(0)
            if localeId == 0 then return "enUS" end
        end
        return "frFR"
    end)
    if ok and result then return result end
    return "frFR"
end

local WeaponsUpgradeNotif = {
    frFR = {
        LEVEL_TOO_LOW = "Vous devez être au moins de niveau 80 pour améliorer cette arme.",
        ITEM_NOT_FOUND = "Arme prodigieuse non trouvée dans votre inventaire.",
        NOT_ENOUGH_CURRENCY = "Vous n'avez pas assez de |cffffffff[Cristaux d'Infusion]|r pour améliorer cette arme prodigieuse.",
        CANT_UPGRADE = "Cet objet ne peut pas être amélioré ou n'est pas une arme prodigieuse valide.",
        UPGRADE_SUCCESS = "Votre arme prodigieuse a été améliorée avec succès ! Vous avez dépensé |cffffffff%d Cristaux d'Infusion|r.",
        CACHE_RELOADED = "[WeaponsUpgrade] Cache rechargé depuis la base de données.",
    },
    enUS = {
        LEVEL_TOO_LOW = "You must be at least level 80 to upgrade this weapon.",
        ITEM_NOT_FOUND = "Prodigious weapon not found in your inventory.",
        NOT_ENOUGH_CURRENCY = "You don't have enough |cffffffff[Infusion Crystals]|r to upgrade this prodigious weapon.",
        CANT_UPGRADE = "This item cannot be upgraded or is not a valid prodigious weapon.",
        UPGRADE_SUCCESS = "Your prodigious weapon has been upgraded successfully! You spent |cffffffff%d Infusion Crystals|r.",
        CACHE_RELOADED = "[WeaponsUpgrade] Cache reloaded from the database.",
    },
}
local function L(player)
    return WeaponsUpgradeNotif[GetPlayerLocale(player)] or WeaponsUpgradeNotif.frFR
end

function WeaponsUpgradeHandlers.UpgradeItem(player, itemEntry)
    local currencyID = 339505 -- ID de la monnaie personnalisée
    local currencyCost = 14000 -- Coût en monnaie personnalisée
    
    if player:GetLevel() < 80 then
        player:SendBroadcastMessage(L(player).LEVEL_TOO_LOW)
        return
    end
    
    local item = player:GetItemByEntry(itemEntry)
    if not item then
        player:SendBroadcastMessage(L(player).ITEM_NOT_FOUND)
        return
    end
    
    local currentCurrency = player:GetItemCount(currencyID)
    if currentCurrency < currencyCost then
        player:SendBroadcastMessage(L(player).NOT_ENOUGH_CURRENCY)
        return
    end
    
    local newItemID = upgradeCache[itemEntry]
    
    if not newItemID then
        player:SendBroadcastMessage(L(player).CANT_UPGRADE)
        return
    end
    
    player:RemoveItem(itemEntry, 1)
    player:AddItem(newItemID, 1)
    player:RemoveItem(currencyID, currencyCost)
    
    player:SendBroadcastMessage(string.format(L(player).UPGRADE_SUCCESS, currencyCost))
end

function WeaponsUpgradeHandlers.ReloadCache()
    upgradeCache = {}
    cacheLoaded = false
    LoadUpgradeMappings()
end

local function SendMappingToClient(player)
    AIO.Handle(player, "WeaponsUpgradeHandler", "SetUpgradeMapping", upgradeCache)
end

local function OnGossipHello(event, player, gameObject)
    gameObject:UseDoorOrButton(10000)
    SendMappingToClient(player)
    AIO.Handle(player, "WeaponsUpgradeHandler", "OpenInterface")
    player:GossipComplete()
end

RegisterGameObjectGossipEvent(WEAPON_UPGRADE, 1, OnGossipHello)

local function OnCommand(event, player, command)
    if command == "reload weapons" then
        if player:GetGMRank() >= 3 then
            WeaponsUpgradeHandlers.ReloadCache()
            player:SendBroadcastMessage(L(player).CACHE_RELOADED)
            return false
        end
    end
end

RegisterPlayerEvent(42, OnCommand)
