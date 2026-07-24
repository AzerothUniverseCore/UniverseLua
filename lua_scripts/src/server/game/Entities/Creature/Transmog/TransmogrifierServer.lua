-- TransmogrifierServer.lua
-- Système de Transmogrification optimisé pour TrinityCore 3.3.5 avec AIO

local AIO = AIO or require("AIO")
local TransmogHandlers = AIO.AddHandlers("Transmog", {})

-- Détermine la langue du compte du joueur (0 = enUS, sinon frFR)
local function GetPlayerLocale(player)
    local ok, result = pcall(function()
        local accountId = player:GetAccountId()
        local q = AuthDBQuery("SELECT locale FROM account WHERE id = " .. accountId .. ";")
        if q then
            local localeId = q:GetUInt8(0)
            if localeId == 0 then
                return "enUS"
            end
        end
        return "frFR"
    end)
    if ok and result then
        return result
    end
    return "frFR"
end

local TransmogNotif = {
    frFR = {
        INVALID_SLOT = "Slot invalide!",
        NO_ITEM_EQUIPPED = "Aucun item équipé dans ce slot!",
        NOT_COMPATIBLE = "Cet item n'est pas compatible avec ce slot!",
        ITEM_NOT_IN_BAGS = "Vous ne possédez pas cet item dans vos sacs!",
        NOT_ENOUGH_MONEY = "Vous n'avez pas assez d'argent! Coût: 50 pièces d'or",
        NO_APPEARANCE = "Impossible d'obtenir l'apparence de cet item!",
        APPLY_SUCCESS = "Transmogrification appliquée avec succès!",
        SLOT_RESET = "Slot réinitialisé!",
        ALL_RESET = "Toutes les transmogrifications réinitialisées!",
    },
    enUS = {
        INVALID_SLOT = "Invalid slot!",
        NO_ITEM_EQUIPPED = "No item equipped in this slot!",
        NOT_COMPATIBLE = "This item is not compatible with this slot!",
        ITEM_NOT_IN_BAGS = "You don't have this item in your bags!",
        NOT_ENOUGH_MONEY = "You don't have enough money! Cost: 50 gold",
        NO_APPEARANCE = "Unable to retrieve this item's appearance!",
        APPLY_SUCCESS = "Transmogrification applied successfully!",
        SLOT_RESET = "Slot reset!",
        ALL_RESET = "All transmogrifications reset!",
    },
}

local function L(player)
    return TransmogNotif[GetPlayerLocale(player)] or TransmogNotif.frFR
end

local TRANSMOG_COST = 500000 -- 4 pièces d'or (1 or = 10000 copper)
local TRANSMOG_TABLE = "transmog_char"
local ITEMS_PER_PAGE = 8
local NPC_ENTRY = 54442

-- Correspondance des slots d'équipement avec types d'inventaire
local EQUIPMENT_SLOTS = {
    [1] = {name = "HEAD", invTypes = {1}},
    [3] = {name = "SHOULDER", invTypes = {3}},
    [15] = {name = "BACK", invTypes = {16}},
    [5] = {name = "CHEST", invTypes = {5, 20}}, -- Torse et Robe
    [9] = {name = "WRIST", invTypes = {9}},
    [10] = {name = "HANDS", invTypes = {10}},
    [6] = {name = "WAIST", invTypes = {6}},
    [7] = {name = "LEGS", invTypes = {7}},
    [8] = {name = "FEET", invTypes = {8}},
    [16] = {name = "MAINHAND", invTypes = {13, 17, 21}}, -- 1H, 2H, MH
    [17] = {name = "OFFHAND", invTypes = {14, 22, 23, 13}}, -- Shield, Holdable, OH, 1H
    [18] = {name = "RANGED", invTypes = {15, 25, 26}} -- Ranged, Thrown, Wand
}

-- Créer la table de transmogrification (CORRECTION DE LA SYNTAXE SQL)
local function CreateTransmogTable()
    -- Utiliser la concaténation au lieu de string.format avec [[]]
    local createQuery = "CREATE TABLE IF NOT EXISTS " .. TRANSMOG_TABLE .. " (" ..
        "guid INT UNSIGNED NOT NULL, " ..
        "slot TINYINT UNSIGNED NOT NULL, " ..
        "item_entry INT UNSIGNED NOT NULL, " ..
        "PRIMARY KEY (guid, slot)" ..
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8"
    
    CharDBExecute(createQuery)
    --print(">> Transmog: Table " .. TRANSMOG_TABLE .. " créée/vérifiée")
end

-- Initialiser la table au démarrage
CreateTransmogTable()

-- Vérifier si un item est compatible avec un slot
local function IsItemCompatible(itemEntry, slotId)
    local slotConfig = EQUIPMENT_SLOTS[slotId]
    if not slotConfig then 
        return false 
    end
    
    local query = WorldDBQuery(string.format(
        "SELECT class, subclass, InventoryType, Quality FROM item_template WHERE entry = %u",
        itemEntry
    ))
    
    if not query then 
        return false 
    end
    
    local itemClass = query:GetUInt8(0)
    local itemSubClass = query:GetUInt8(1)
    local invType = query:GetUInt8(2)
    local quality = query:GetUInt8(3)
    
    -- RELAXER LES RESTRICTIONS: Autoriser tous les items équipables
    -- Pas de restriction de qualité minimum
    
    -- L'item doit être une arme (2), armure (4), ou accessoire (non-équipable peut être ignoré)
    if itemClass ~= 2 and itemClass ~= 4 then 
        -- Vérifier si c'est au moins équipable (invType > 0)
        if invType == 0 then
            return false
        end
    end
    
    -- Vérifier que le type d'inventaire correspond au slot
    for _, validInvType in ipairs(slotConfig.invTypes) do
        if invType == validInvType then
            --print(string.format("    -> Item %d: Class=%d, InvType=%d, Quality=%d -> MATCH!", 
                --itemEntry, itemClass, invType, quality))
            return true
        end
    end
    
    -- DEBUG: Afficher pourquoi l'item n'est pas compatible
    --print(string.format("    -> Item %d: Class=%d, InvType=%d (expected: %s) -> NO MATCH", 
        --itemEntry, itemClass, invType, table.concat(slotConfig.invTypes, ",")))
    
    return false
end

-- Obtenir tous les items compatibles dans les sacs d'un joueur
local function GetAvailableItemsFromBags(player, slotId)
    local items = {}
    local itemSet = {} -- Pour éviter les doublons
    local count = 0
    
    --print(">> Transmog: Scanning bags for slot " .. slotId)
    
    -- CORRECTION: Selon la doc Eluna, pour les sacs:
    -- bag = 255, slots 23-38 = backpack (sac principal)
    -- bag = 255, slots 19-22 = equipped bag slots
    -- bag = 19-22, slots 0-35 = items dans les sacs équipés
    
    -- 1. Scanner le sac principal (INVENTORY_SLOT_BAG_0 = bag 255, slots 23-38)
    for slot = 23, 38 do
        local item = player:GetItemByPos(255, slot)
        if item then
            local itemEntry = item:GetEntry()
            local itemName = item:GetName()
            
            --print(string.format("  Backpack Slot %d: Item %d (%s)", slot, itemEntry, itemName))
            
            if not itemSet[itemEntry] then
                if IsItemCompatible(itemEntry, slotId) then
                    table.insert(items, itemEntry)
                    itemSet[itemEntry] = true
                    count = count + 1
                    --print("    -> COMPATIBLE!")
                else
                    --print("    -> Not compatible")
                end
            end
        end
    end
    
    -- 2. Scanner les sacs équipés (bag 19-22, chaque sac peut avoir 0-35 slots)
    for bagSlot = 19, 22 do
        local bag = player:GetItemByPos(255, bagSlot)
        
        if bag then
            local bagSize = bag:GetBagSize()
            --print(string.format(">> Bag slot %d has %d slots", bagSlot, bagSize))
            
            for slot = 0, bagSize - 1 do
                local item = player:GetItemByPos(bagSlot, slot)
                if item then
                    local itemEntry = item:GetEntry()
                    local itemName = item:GetName()
                    
                    --print(string.format("  Bag %d Slot %d: Item %d (%s)", bagSlot, slot, itemEntry, itemName))
                    
                    if not itemSet[itemEntry] then
                        if IsItemCompatible(itemEntry, slotId) then
                            table.insert(items, itemEntry)
                            itemSet[itemEntry] = true
                            count = count + 1
                            --print("    -> COMPATIBLE!")
                        else
                            --print("    -> Not compatible")
                        end
                    end
                end
            end
        else
            --print(string.format(">> Bag slot %d: Empty", bagSlot))
        end
    end
    
    --print(string.format(">> Transmog: Found %d compatible items for slot %d", count, slotId))
    return items
end

-- Paginer une liste d'items
local function PaginateItems(items, page)
    local totalItems = #items
    local totalPages = math.max(1, math.ceil(totalItems / ITEMS_PER_PAGE))
    
    -- S'assurer que la page est valide
    if page < 1 then page = 1 end
    if page > totalPages then page = totalPages end
    
    local startIndex = ((page - 1) * ITEMS_PER_PAGE) + 1
    local endIndex = math.min(startIndex + ITEMS_PER_PAGE - 1, totalItems)
    
    local pageItems = {}
    for i = startIndex, endIndex do
        table.insert(pageItems, items[i])
    end
    
    -- Compléter avec des 0 si moins de 8 items
    while #pageItems < ITEMS_PER_PAGE do
        table.insert(pageItems, 0)
    end
    
    return pageItems, totalPages
end

-- Sauvegarder une transmogrification
local function SaveTransmog(guid, slotId, itemEntry)
    local query = string.format(
        "REPLACE INTO %s (guid, slot, item_entry) VALUES (%u, %u, %u)",
        TRANSMOG_TABLE, guid, slotId, itemEntry
    )
    CharDBExecute(query)
end

-- Charger une transmogrification
local function LoadTransmog(guid, slotId)
    local query = CharDBQuery(string.format(
        "SELECT item_entry FROM %s WHERE guid = %u AND slot = %u",
        TRANSMOG_TABLE, guid, slotId
    ))
    
    if query then
        return query:GetUInt32(0)
    end
    
    return 0
end

-- Construire la table des apparences actuellement appliquées pour un
-- joueur (utilisée par le client pour afficher la BONNE icône après
-- application, puisque l'item réellement équipé ne change pas).
local function BuildAppliedAppearances(guid)
    local appearances = {}
    for slotId, _ in pairs(EQUIPMENT_SLOTS) do
        appearances[slotId] = LoadTransmog(guid, slotId)
    end
    return appearances
end

-- Supprimer une transmogrification d'un slot
local function DeleteTransmog(guid, slotId)
    local query = string.format(
        "DELETE FROM %s WHERE guid = %u AND slot = %u",
        TRANSMOG_TABLE, guid, slotId
    )
    CharDBExecute(query)
end

-- Supprimer toutes les transmogrifications
local function DeleteAllTransmog(guid)
    local query = string.format(
        "DELETE FROM %s WHERE guid = %u",
        TRANSMOG_TABLE, guid
    )
    CharDBExecute(query)
end

-- Obtenir le Display ID d'un item
local function GetItemDisplayId(itemEntry)
    local query = WorldDBQuery(string.format(
        "SELECT displayid FROM item_template WHERE entry = %u",
        itemEntry
    ))
    
    if query then
        return query:GetUInt32(0)
    end
    
    return 0
end

-- Appliquer visuellement une transmogrification
local function ApplyTransmogVisual(player, slotId, itemEntry)
    -- Convertir slotId en slot équipement (0-based)
    local equipSlot = slotId - 1
    
    -- Calculer l'offset pour PLAYER_VISIBLE_ITEM
    -- PLAYER_VISIBLE_ITEM_1_ENTRYID = 283 pour le slot HEAD (0)
    local baseOffset = 283
    local slotOffset = baseOffset + (equipSlot * 2)
    
    -- CORRECTION IMPORTANTE: Utiliser l'ItemEntry et non le DisplayID !
    -- Le client WoW charge automatiquement le bon DisplayID depuis l'ItemEntry
    player:SetUInt32Value(slotOffset, itemEntry)
    player:SetUInt32Value(slotOffset + 1, 0) -- Enchant visuel à 0
    
    --print(string.format(">> Applied transmog: Slot %d (equipSlot %d), ItemEntry %d, Offset %d", 
        --slotId, equipSlot, itemEntry, slotOffset))
end

-- Restaurer l'apparence originale d'un item
local function RestoreOriginalVisual(player, slotId)
    local item = player:GetItemByPos(255, slotId - 1)
    if item then
        local itemEntry = item:GetEntry()
        ApplyTransmogVisual(player, slotId, itemEntry)
        --print(string.format(">> Restored original: Slot %d, ItemEntry %d", slotId, itemEntry))
    else
        -- Slot vide, mettre à 0
        local equipSlot = slotId - 1
        local baseOffset = 283
        local slotOffset = baseOffset + (equipSlot * 2)
        player:SetUInt32Value(slotOffset, 0)
        player:SetUInt32Value(slotOffset + 1, 0)
        --print(string.format(">> Cleared slot: %d", slotId))
    end
end

-- Handler: Ouvrir l'interface
function TransmogHandlers.OpenUI(player)
    --print(">> Opening Transmog UI for " .. player:GetName())
    AIO.Handle(player, "Transmog", "CreateUI")
    TransmogHandlers.GetSlotAvailability(player)
    AIO.Handle(player, "Transmog", "UpdateAppliedAppearances", BuildAppliedAppearances(player:GetGUIDLow()))
end

-- Handler: Obtenir les items disponibles pour un slot
function TransmogHandlers.GetItems(player, slotId, page)
    if not EQUIPMENT_SLOTS[slotId] then
        --print(">> Invalid slot: " .. tostring(slotId))
        return
    end
    
    page = page or 1
    
    --print(string.format(">> Getting items for slot %d, page %d", slotId, page))
    
    -- Récupérer tous les items compatibles dans les sacs
    local allItems = GetAvailableItemsFromBags(player, slotId)
    
    -- Paginer les résultats
    local pageItems, totalPages = PaginateItems(allItems, page)
    
    --print(string.format(">> Sending %d items, page %d/%d", #pageItems, page, totalPages))
    
    -- Envoyer au client
    AIO.Handle(player, "Transmog", "UpdateItemGrid", pageItems, page, totalPages)
end

-- Handler : indique, pour chaque emplacement, si le joueur possede au moins
-- un objet compatible dans ses sacs (utilise par le client pour n'afficher
-- l'icone "indisponible" que si aucun objet de transmog n'est possede, et non
-- simplement parce que rien n'est equipe dans ce slot).
function TransmogHandlers.GetSlotAvailability(player)
    local availability = {}
    for slotId, _ in pairs(EQUIPMENT_SLOTS) do
        local items = GetAvailableItemsFromBags(player, slotId)
        availability[slotId] = (#items > 0)
    end
    AIO.Handle(player, "Transmog", "UpdateSlotAvailability", availability)
end

-- Handler: Appliquer une transmogrification
function TransmogHandlers.ApplyTransmog(player, slotId, itemEntry)
    if not EQUIPMENT_SLOTS[slotId] then
        AIO.Handle(player, "Transmog", "ShowError", L(player).INVALID_SLOT)
        return
    end
    
    -- Vérifier que le joueur a un item équipé dans ce slot
    local equippedItem = player:GetItemByPos(255, slotId - 1)
    if not equippedItem then
        AIO.Handle(player, "Transmog", "ShowError", L(player).NO_ITEM_EQUIPPED)
        return
    end
    
    -- Vérifier que l'item est compatible
    if not IsItemCompatible(itemEntry, slotId) then
        AIO.Handle(player, "Transmog", "ShowError", L(player).NOT_COMPATIBLE)
        return
    end
    
    -- Vérifier que le joueur possède l'item dans ses sacs
    local hasItem = false
    
    -- Vérifier sac principal (bag 255, slots 23-38)
    for slot = 23, 38 do
        local item = player:GetItemByPos(255, slot)
        if item and item:GetEntry() == itemEntry then
            hasItem = true
            break
        end
    end
    
    -- Vérifier les sacs équipés si pas trouvé
    if not hasItem then
        for bagSlot = 19, 22 do
            local bag = player:GetItemByPos(255, bagSlot)
            if bag then
                local bagSize = bag:GetBagSize()
                for slot = 0, bagSize - 1 do
                    local item = player:GetItemByPos(bagSlot, slot)
                    if item and item:GetEntry() == itemEntry then
                        hasItem = true
                        break
                    end
                end
            end
            if hasItem then break end
        end
    end
    
    if not hasItem then
        AIO.Handle(player, "Transmog", "ShowError", L(player).ITEM_NOT_IN_BAGS)
        return
    end

	-- NOUVEAU : Vérifier si le joueur a assez d'argent
    local playerMoney = player:GetCoinage()
    if playerMoney < TRANSMOG_COST then
        AIO.Handle(player, "Transmog", "ShowError", L(player).NOT_ENOUGH_MONEY)
        return
    end
    
    -- Obtenir le Display ID (juste pour le log debug)
    local displayId = GetItemDisplayId(itemEntry)
    if displayId == 0 then
        AIO.Handle(player, "Transmog", "ShowError", L(player).NO_APPEARANCE)
        return
    end

	-- NOUVEAU : Retirer l'argent
    player:ModifyMoney(-TRANSMOG_COST)
    
    --print(string.format(">> DEBUG: Item %d -> DisplayID %d", itemEntry, displayId))
    
    -- Sauvegarder et appliquer (utilise l'itemEntry, pas le displayId)
    SaveTransmog(player:GetGUIDLow(), slotId, itemEntry)
    ApplyTransmogVisual(player, slotId, itemEntry)
    
    AIO.Handle(player, "Transmog", "ShowSuccess", L(player).APPLY_SUCCESS)
    AIO.Handle(player, "Transmog", "UpdateAppliedAppearances", BuildAppliedAppearances(player:GetGUIDLow()))
    
    --print(string.format(">> %s transmogged slot %d to item %d (display %d)", 
        --player:GetName(), slotId, itemEntry, displayId))
end

-- Handler: Réinitialiser un slot
function TransmogHandlers.ResetSlot(player, slotId)
    if not EQUIPMENT_SLOTS[slotId] then
        return
    end
    
    DeleteTransmog(player:GetGUIDLow(), slotId)
    RestoreOriginalVisual(player, slotId)
    
    AIO.Handle(player, "Transmog", "ShowSuccess", L(player).SLOT_RESET)
    AIO.Handle(player, "Transmog", "UpdateAppliedAppearances", BuildAppliedAppearances(player:GetGUIDLow()))
end

-- Handler: Réinitialiser tous les slots
function TransmogHandlers.ResetAll(player)
    DeleteAllTransmog(player:GetGUIDLow())
    
    -- Restaurer l'apparence originale de tous les slots
    for slotId, _ in pairs(EQUIPMENT_SLOTS) do
        RestoreOriginalVisual(player, slotId)
    end
    
    AIO.Handle(player, "Transmog", "ShowSuccess", L(player).ALL_RESET)
    AIO.Handle(player, "Transmog", "UpdateAppliedAppearances", BuildAppliedAppearances(player:GetGUIDLow()))
end

-- Charger et appliquer les transmogrifications au login
local function OnLogin(event, player)
    local guid = player:GetGUID()  -- ← GetGUID() et non GetGUIDLow()
    
    player:RegisterEvent(function()
        local plr = GetPlayerByGUID(guid)  -- ← fonctionne avec le GUID complet
        if not plr then return end
        
        for slotId, _ in pairs(EQUIPMENT_SLOTS) do
            local transmogEntry = LoadTransmog(plr:GetGUIDLow(), slotId)  -- ← GUIDLow pour le SQL
            if transmogEntry > 0 then
                ApplyTransmogVisual(plr, slotId, transmogEntry)
            end
        end
        --print(">> Transmog loaded for " .. plr:GetName())
    end, 1500, 1)
end

-- Réappliquer la transmog après équipement d'un item
local function OnEquip(event, player, item, bag, slot)
    -- Déterminer le slot d'équipement
    if bag ~= 255 then return end
    
    local slotId = slot + 1 -- Eluna utilise 0-based, nos slots sont 1-based
    
    if EQUIPMENT_SLOTS[slotId] then
        local guid = player:GetGUID()  -- ← GetGUID() et non GetGUIDLow()
        
        -- Petit délai pour s'assurer que l'item est bien équipé
        player:RegisterEvent(function()
            local plr = GetPlayerByGUID(guid)  -- ← fonctionne avec le GUID complet
            if not plr then return end
            
            local transmogEntry = LoadTransmog(plr:GetGUIDLow(), slotId)  -- ← GUIDLow pour le SQL
            if transmogEntry > 0 then
                ApplyTransmogVisual(plr, slotId, transmogEntry)
            end
        end, 300, 1)
    end
end

-- Gossip du PNJ
local function OnGossipHello(event, player, creature)
    AIO.Handle(player, "Transmog", "CreateUI")
	TransmogHandlers.OpenUI(player)
end

-- Events
RegisterCreatureGossipEvent(NPC_ENTRY, 1, OnGossipHello)

-- Commande .transmog pour ouvrir l'interface
--local function TransmogCommand(event, player, command)
--    local cmd = command:lower()
--    if cmd == "transmog" or cmd == "tmog" then
--        TransmogHandlers.OpenUI(player)
--        return false
--    end
--end

-- Enregistrer les événements
RegisterPlayerEvent(3, OnLogin)          -- PLAYER_EVENT_ON_LOGIN
RegisterPlayerEvent(29, OnEquip)         -- PLAYER_EVENT_ON_EQUIP
--RegisterPlayerEvent(42, TransmogCommand) -- PLAYER_EVENT_ON_COMMAND

--print("========================================")
--print(">> Transmogrification System LOADED!")
--print(">> Table: " .. TRANSMOG_TABLE)
--print(">> Commands: .transmog, .tmog, /transmog, /tmog")
--print("========================================")
