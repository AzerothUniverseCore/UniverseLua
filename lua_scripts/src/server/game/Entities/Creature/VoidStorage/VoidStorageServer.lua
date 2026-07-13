-- VoidStorageServer.lua
-- Système Void Storage pour TrinityCore 3.3.5 avec AIO
-- VERSION PROPRE ET COMPLETE

local AIO = AIO or require("AIO")

-- Configuration
local VOID_STORAGE_MAX_SLOT = 80
local VOID_STORAGE_MAX_DEPOSIT = 9
local VOID_STORAGE_MAX_WITHDRAW = 9
local VOID_STORAGE_STORE_ITEM = 25 * 10000 -- 25 gold par item
local NPC_ENTRY = 54443

-- Cache mémoire
local VoidStorageCache = {}

-- Table de base de données
local DB_TABLE = "character_void_storage"

-- ============================================
-- FONCTIONS DE BASE DE DONNÉES
-- ============================================

local function InitDatabase()
    local query = CharDBQuery(string.format("SHOW TABLES LIKE '%s'", DB_TABLE))
    
    if not query then
        CharDBExecute(string.format([[
            CREATE TABLE IF NOT EXISTS %s (
                guid INT UNSIGNED NOT NULL,
                slot TINYINT UNSIGNED NOT NULL,
                item_entry INT UNSIGNED NOT NULL,
                item_guid INT UNSIGNED NOT NULL DEFAULT 0,
                PRIMARY KEY (guid, slot),
                INDEX idx_guid (guid)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
        ]], DB_TABLE))
    end
    
    --print("[VoidStorage] Base de données initialisée")
end

local function LoadPlayerData(playerGUID)
    if VoidStorageCache[playerGUID] then
        return VoidStorageCache[playerGUID]
    end
    
    local data = {}
    local query = CharDBQuery(string.format(
        "SELECT slot, item_entry FROM %s WHERE guid = %d ORDER BY slot",
        DB_TABLE, playerGUID
    ))
    
    if query then
        repeat
            local slot = query:GetUInt8(0)
            local itemEntry = query:GetUInt32(1)
            data[slot] = { entry = itemEntry }
        until not query:NextRow()
    end
    
    VoidStorageCache[playerGUID] = data
    return data
end

local function SavePlayerData(playerGUID)
    local data = VoidStorageCache[playerGUID]
    if not data then return end
    
    CharDBExecute(string.format("DELETE FROM %s WHERE guid = %d", DB_TABLE, playerGUID))
    
    for slot, itemData in pairs(data) do
        if itemData and itemData.entry then
            CharDBExecute(string.format(
                "REPLACE INTO %s (guid, slot, item_entry, item_guid) VALUES (%d, %d, %d, 0)",
                DB_TABLE, playerGUID, slot, itemData.entry
            ))
        end
    end
end

-- ============================================
-- FONCTIONS HELPER
-- ============================================

local function FindEmptySlot(playerGUID)
    local data = VoidStorageCache[playerGUID] or {}
    for i = 1, VOID_STORAGE_MAX_SLOT do
        if not data[i] or not data[i].entry then
            return i
        end
    end
    return nil
end

local function GetNumOfVoidStorageFreeSlots(playerGUID)
    local data = VoidStorageCache[playerGUID] or {}
    local count = 0
    for i = 1, VOID_STORAGE_MAX_SLOT do
        if not data[i] or not data[i].entry then
            count = count + 1
        end
    end
    return count
end

local function PrepareDataForClient(player)
    local playerGUID = player:GetGUIDLow()
    local data = LoadPlayerData(playerGUID)
    local clientData = {}
    
    for slot, itemData in pairs(data) do
        if itemData and itemData.entry then
            local itemLink = string.format("|cffffffff|Hitem:%d:0:0:0:0:0:0:0|h[Item %d]|h|r", itemData.entry, itemData.entry)
            
            clientData[slot] = {
                entry = itemData.entry,
                link = itemLink,
                count = 1
            }
        end
    end
    
    return clientData
end

local function CanStoreItemInVoidStorage(item)
    if not item then
        return false, "Item invalide"
    end
    
    local success, template = pcall(function() return item:GetTemplate() end)
    if success and template then
        local itemClass = nil
        success, itemClass = pcall(function() return template:GetClass() end)
        
        if success and itemClass then
            if itemClass == 12 then
                return false, "Les items de quête ne peuvent pas être stockés"
            end
            if itemClass == 1 then
                return false, "Les sacs ne peuvent pas être stockés"
            end
        end
        
        local maxStack = nil
        success, maxStack = pcall(function() return template:GetMaxStackCount() end)
        
        if success and maxStack and maxStack > 1 then
            return false, "Les items empilables ne peuvent pas être stockés"
        end
    end
    
    return true, ""
end

local function GetFreeBagSlots(player)
    local freeSlots = 0
    
    for bag = 0, 4 do
        local bagSlots = player:GetBagSlots(bag)
        if bagSlots and bagSlots > 0 then
            for slot = 0, bagSlots - 1 do
                local item = player:GetItemByPos(bag, slot)
                if not item then
                    freeSlots = freeSlots + 1
                end
            end
        end
    end
    
    return freeSlots
end

-- ============================================
-- HANDLERS AIO
-- ============================================

local VoidStorageHandlers = AIO.AddHandlers("VoidStorage", {})

function VoidStorageHandlers.RequestData(player)
    local clientData = PrepareDataForClient(player)
    AIO.Handle(player, "VoidStorage", "ReceiveData", clientData)
end

function VoidStorageHandlers.DepositItems(player, itemsToDeposit)
    if not itemsToDeposit or type(itemsToDeposit) ~= "table" or #itemsToDeposit == 0 then
        AIO.Handle(player, "VoidStorage", "UpdateAfterDeposit", false, "Aucun item à déposer", nil)
        return
    end
    
    if #itemsToDeposit > VOID_STORAGE_MAX_DEPOSIT then
        AIO.Handle(player, "VoidStorage", "UpdateAfterDeposit", false, "Maximum " .. VOID_STORAGE_MAX_DEPOSIT .. " items à la fois", nil)
        return
    end
    
    local playerGUID = player:GetGUIDLow()
    local data = LoadPlayerData(playerGUID)
    
    local freeSlots = GetNumOfVoidStorageFreeSlots(playerGUID)
    if #itemsToDeposit > freeSlots then
        AIO.Handle(player, "VoidStorage", "UpdateAfterDeposit", false, "Void Storage plein! Slots libres: " .. freeSlots, nil)
        return
    end
    
    local totalCost = #itemsToDeposit * VOID_STORAGE_STORE_ITEM
    if player:GetCoinage() < totalCost then
        local goldNeeded = math.floor(totalCost / 10000)
        AIO.Handle(player, "VoidStorage", "UpdateAfterDeposit", false, "Pas assez d'or! Requis: " .. goldNeeded .. " or", nil)
        return
    end
    
    local validItems = {}
    
    for i, itemInfo in ipairs(itemsToDeposit) do
        local bag = itemInfo.bag or 0
        local slot = itemInfo.slot or 0
        
        local item = nil
        
        if bag == 0 then
            item = player:GetItemByPos(255, slot)
        else
            local bagSlot = 18 + bag
            item = player:GetItemByPos(bagSlot, slot)
        end
        
        if item then
            local canStore, errorMsg = CanStoreItemInVoidStorage(item)
            if canStore then
                table.insert(validItems, {
                    item = item,
                    bag = bag,
                    slot = slot
                })
            end
        end
    end
    
    if #validItems == 0 then
        AIO.Handle(player, "VoidStorage", "UpdateAfterDeposit", false, "Aucun item valide à déposer", nil)
        return
    end
    
    local depositedCount = 0
    for _, itemData in ipairs(validItems) do
    local emptySlot = FindEmptySlot(playerGUID)
    if emptySlot then
        local itemEntry = itemData.item:GetEntry()
        data[emptySlot] = { entry = itemEntry }

        local removed = false
        pcall(function()
            player:RemoveItem(itemEntry, 1)
            removed = true
        end)
        
        if removed then
            depositedCount = depositedCount + 1
        else
            data[emptySlot] = nil
        end
    end
end

    
    if depositedCount > 0 then
        local cost = depositedCount * VOID_STORAGE_STORE_ITEM
        player:ModifyMoney(-cost)
        
        VoidStorageCache[playerGUID] = data
        SavePlayerData(playerGUID)
        
        local clientData = PrepareDataForClient(player)
        local goldCost = math.floor(cost / 10000)
        local msg = depositedCount .. " item(s) déposé(s)! Coût: " .. goldCost .. " or"
        AIO.Handle(player, "VoidStorage", "UpdateAfterDeposit", true, msg, clientData)
    else
        AIO.Handle(player, "VoidStorage", "UpdateAfterDeposit", false, "Erreur lors du dépôt", nil)
    end
end

function VoidStorageHandlers.WithdrawItems(player, slotsToWithdraw)
    --print("[VoidStorage] === DEBUT WithdrawItems ===")
    
    if not slotsToWithdraw or type(slotsToWithdraw) ~= "table" or #slotsToWithdraw == 0 then
        --print("[VoidStorage] Erreur: Aucun slot reçu")
        AIO.Handle(player, "VoidStorage", "UpdateAfterWithdraw", false, "Aucun item à retirer", nil)
        return
    end
    
    --print(string.format("[VoidStorage] Nombre de slots à retirer: %d", #slotsToWithdraw))
    
    if #slotsToWithdraw > VOID_STORAGE_MAX_WITHDRAW then
        AIO.Handle(player, "VoidStorage", "UpdateAfterWithdraw", false, "Maximum " .. VOID_STORAGE_MAX_WITHDRAW .. " items à la fois", nil)
        return
    end
    
    local playerGUID = player:GetGUIDLow()
    local data = LoadPlayerData(playerGUID)
    
    -- On ne vérifie pas l'espace (AddItem gère automatiquement l'ajout)
    
    local withdrawnCount = 0
    for _, slotIndex in ipairs(slotsToWithdraw) do
        if data[slotIndex] and data[slotIndex].entry then
            local itemEntry = data[slotIndex].entry
            --print(string.format("[VoidStorage] Tentative de retrait du slot %d (entry=%d)", slotIndex, itemEntry))
            
            -- Utiliser AddItem qui retourne l'item créé
            local item = player:AddItem(itemEntry, 1)
            
            if item then
                --print(string.format("[VoidStorage] Item ajouté à l'inventaire avec succès"))
                data[slotIndex] = nil
                withdrawnCount = withdrawnCount + 1
            else
                --print(string.format("[VoidStorage] ERREUR: Impossible d'ajouter l'item (inventaire plein?)"))
            end
        else
            --print(string.format("[VoidStorage] ERREUR: Slot %d vide ou invalide", slotIndex))
        end
    end
    
    --print(string.format("[VoidStorage] Total retiré: %d items", withdrawnCount))
    
    if withdrawnCount > 0 then
        VoidStorageCache[playerGUID] = data
        SavePlayerData(playerGUID)
        
        local clientData = PrepareDataForClient(player)
        local msg = withdrawnCount .. " item(s) retiré(s)!"
        AIO.Handle(player, "VoidStorage", "UpdateAfterWithdraw", true, msg, clientData)
        --print("[VoidStorage] === FIN WithdrawItems (SUCCES) ===")
    else
        local errorMsg = "Inventaire plein ou items invalides"
        AIO.Handle(player, "VoidStorage", "UpdateAfterWithdraw", false, errorMsg, nil)
        --print("[VoidStorage] === FIN WithdrawItems (ECHEC) ===")
    end
end

-- ============================================
-- EVENTS
-- ============================================

local function OnGossipHello(event, player, creature)
    AIO.Handle(player, "VoidStorage", "OpenVoidStorage")
    VoidStorageHandlers.RequestData(player)
end

local function OnLogout(event, player)
    local playerGUID = player:GetGUIDLow()
    SavePlayerData(playerGUID)
    VoidStorageCache[playerGUID] = nil
end

RegisterCreatureGossipEvent(NPC_ENTRY, 1, OnGossipHello)
RegisterPlayerEvent(4, OnLogout)

InitDatabase()

--print("================================================")
--print("VoidStorage: Système chargé et fonctionnel")
--print("VoidStorage: NPC ID = " .. NPC_ENTRY)
--print("VoidStorage: Slots = " .. VOID_STORAGE_MAX_SLOT)
--print("VoidStorage: Coût = " .. (VOID_STORAGE_STORE_ITEM / 10000) .. " or/item")
--print("VoidStorage: Retrait = GRATUIT")
--print("================================================")