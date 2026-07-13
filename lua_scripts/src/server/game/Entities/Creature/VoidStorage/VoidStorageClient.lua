-- VoidStorageClient.lua
-- Système Void Storage pour TrinityCore 3.3.5 avec AIO (Interface Cataclysm 4.3.4)

local AIO = AIO or require("AIO")
if AIO.AddAddon() then return end

local VoidStorageHandlers = AIO.AddHandlers("VoidStorage", {})

local OPEN_TALENT_WINDOW_SOUND = "Sound\\INTERFACE\\UI_Transmogrify_Apply.OGG"
local CLOSE_TALENT_WINDOW_SOUND = "Sound\\INTERFACE\\UI_VoidStorage_Undo.OGG"

-- Configuration
local VOID_STORAGE_SLOTS = 80
local DEPOSIT_SLOTS = 9
local WITHDRAW_SLOTS = 9
local VOID_STORAGE_STORE_ITEM = 25 * 10000 -- 25 gold par item
local BUTTON_TYPE_DEPOSIT = 1
local BUTTON_TYPE_WITHDRAW = 2
local BUTTON_TYPE_STORAGE = 3

-- Variables globales
local VoidStorageFrame = nil
local VoidStorageData = {}
local DepositSlots = {}
local WithdrawSlots = {}
local isTransferInProgress = false -- Protection anti-spam
local LockedItems = {} -- Protection anti-duplication : items déjà dans Deposit
local isTransferInProgress = false -- Protection anti-spam

-- Chemin de la texture
local VOID_TEXTURE = "Interface\\VoidStorage\\voidstorage"

-- Coordonnées UV exactes
local UV = {
    banner = {0.00195313, 0.66015625, 0.00195313, 0.16210938},
    slot = {0.66406250, 0.74414063, 0.00195313, 0.08203125},
    arrowDeposit = {0.74804688, 0.80078125, 0.00195313, 0.09179688},
    arrowWithdraw = {0.80468750, 0.85742188, 0.00195313, 0.09179688},
    bankBG = {0.00195313, 0.47265625, 0.16601563, 0.50781250}
}

-- ============================================
-- FONCTIONS HELPER
-- ============================================

-- Vérifier si un item est déjà verrouillé (dans Deposit)
local function IsItemLocked(bag, slot)
    local key = bag .. "_" .. slot
    return LockedItems[key] ~= nil
end

-- Verrouiller un item (empêche de le remettre dans Deposit)
local function LockItem(bag, slot)
    local key = bag .. "_" .. slot
    LockedItems[key] = true
end

-- Déverrouiller un item
local function UnlockItem(bag, slot)
    local key = bag .. "_" .. slot
    LockedItems[key] = nil
end

-- Déverrouiller tous les items
local function UnlockAllItems()
    LockedItems = {}
end

-- Calculer le coût total
local function CalculateTotalCost()
    local count = 0
    for i = 1, DEPOSIT_SLOTS do
        if DepositSlots[i] and DepositSlots[i].entry then
            count = count + 1
        end
    end
    return count * VOID_STORAGE_STORE_ITEM
end

-- Mettre à jour l'affichage du coût
local function UpdateCostDisplay()
    if not VoidStorageFrame then return end
    
    local cost = CalculateTotalCost()
    local goldAmount = math.floor(cost / 10000)
    
    VoidStorageFrame.costText:SetText(goldAmount .. "|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:2:0|t")
    
    -- Activer/désactiver le bouton selon qu'il y a des items à transférer
    local hasDeposit = false
    local hasWithdraw = false
    
    for i = 1, DEPOSIT_SLOTS do
        if DepositSlots[i] and DepositSlots[i].entry then
            hasDeposit = true
            break
        end
    end
    
    for i = 1, WITHDRAW_SLOTS do
        if WithdrawSlots[i] and WithdrawSlots[i].voidSlot then
            hasWithdraw = true
            break
        end
    end
    
    if hasDeposit or hasWithdraw then
        VoidStorageFrame.transferButton:Enable()
    else
        VoidStorageFrame.transferButton:Disable()
    end
end

-- Mettre à jour les slots de dépôt
function UpdateDepositSlots()
    if not VoidStorageFrame then return end
    
    for i = 1, DEPOSIT_SLOTS do
        local slot = VoidStorageFrame.depositSlots[i]
        local data = DepositSlots[i]
        
        if data and data.texture then
            slot.icon:SetTexture(data.texture)
            slot.icon:Show()
        else
            slot.icon:Hide()
        end
    end
    
    UpdateCostDisplay()
end

-- Mettre à jour les slots de retrait
function UpdateWithdrawSlots()
    if not VoidStorageFrame then return end
    
    for i = 1, WITHDRAW_SLOTS do
        local slot = VoidStorageFrame.withdrawSlots[i]
        local data = WithdrawSlots[i]
        
        if data and data.entry then
            local texture = GetItemIcon(data.entry)
            if texture then
                slot.icon:SetTexture(texture)
                slot.icon:Show()
            end
        else
            slot.icon:Hide()
        end
    end
    
    UpdateCostDisplay()
end

-- Mettre à jour les slots de stockage
local function UpdateStorageSlots()
    if not VoidStorageFrame then return end
    
    for i = 1, VOID_STORAGE_SLOTS do
        local slot = VoidStorageFrame.storageSlots[i]
        local data = VoidStorageData[i]
        
        if data and data.entry then
            local texture = GetItemIcon(data.entry)
            if texture then
                slot.icon:SetTexture(texture)
                slot.icon:Show()
            end
        else
            slot.icon:Hide()
        end
    end
end

-- ============================================
-- CRÉATION DE L'INTERFACE
-- ============================================

local function CreateVoidStorageFrame()
    if VoidStorageFrame then return VoidStorageFrame end
    
    -- Frame principal (DOIT ÊTRE CRÉÉ EN PREMIER)
    local frame = CreateFrame("Frame", "VoidStorageMainFrame", UIParent)
    frame:SetSize(718, 436)
    frame:SetPoint("CENTER", 0, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(10)
    frame:Hide()
    
    -- Fermeture via la touche Echap
    tinsert(UISpecialFrames, "VoidStorageMainFrame")
    
    -- Nettoyage des slots à chaque fermeture (bouton ET touche Echap)
    frame:SetScript("OnHide", function()
        DepositSlots = {}
        WithdrawSlots = {}
        UnlockAllItems()
        PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
    end)
    
    -- ===== CADRE GRIS EXTÉRIEUR =====
    
    -- Créer un frame pour le cadre gris (FrameLevel inférieur aux bordures décoratives)
    local borderFrame = CreateFrame("Frame", nil, frame)
    borderFrame:SetAllPoints()
    borderFrame:SetFrameLevel(frame:GetFrameLevel())
	
	-- Créer le cadre inset (bordure intérieure décorative)
local insetFrame = CreateFrame("Frame", nil, frame)
insetFrame:SetAllPoints()
insetFrame:SetFrameLevel(frame:GetFrameLevel())

-- Bordure supérieure (brun/or)
insetFrame.topInset = insetFrame:CreateTexture(nil, "BORDER")
insetFrame.topInset:SetHeight(3)
insetFrame.topInset:SetPoint("TOPLEFT", 4, -20)
insetFrame.topInset:SetPoint("TOPRIGHT", -4, -20)
insetFrame.topInset:SetTexture(0.5, 0.4, 0.3, 0.8)

-- Bordure gauche (brun/or)
insetFrame.leftInset = insetFrame:CreateTexture(nil, "BORDER")
insetFrame.leftInset:SetWidth(3)
insetFrame.leftInset:SetPoint("TOPLEFT", 4, -20)
insetFrame.leftInset:SetPoint("BOTTOMLEFT", 4, 3)
insetFrame.leftInset:SetTexture(0.5, 0.4, 0.3, 0.8)

-- Bordure droite (brun/or)
insetFrame.rightInset = insetFrame:CreateTexture(nil, "BORDER")
insetFrame.rightInset:SetWidth(3)
insetFrame.rightInset:SetPoint("TOPRIGHT", -4, -20)
insetFrame.rightInset:SetPoint("BOTTOMRIGHT", -4, 3)
insetFrame.rightInset:SetTexture(0.5, 0.4, 0.3, 0.8)

-- Bordure inférieure (brun/or)
insetFrame.bottomInset = insetFrame:CreateTexture(nil, "BORDER")
insetFrame.bottomInset:SetHeight(3)
insetFrame.bottomInset:SetPoint("BOTTOMLEFT", 4, 3)
insetFrame.bottomInset:SetPoint("BOTTOMRIGHT", -4, 3)
insetFrame.bottomInset:SetTexture(0.5, 0.4, 0.3, 0.8)
    
    -- Bordure grise supérieure
    borderFrame.topBorder = borderFrame:CreateTexture(nil, "BACKGROUND")
    borderFrame.topBorder:SetHeight(1)
    borderFrame.topBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -22)
    borderFrame.topBorder:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -22)
    borderFrame.topBorder:SetTexture(0.3, 0.3, 0.3, 1)
    
    -- Bordure grise gauche
    borderFrame.leftBorder = borderFrame:CreateTexture(nil, "BACKGROUND")
    borderFrame.leftBorder:SetWidth(1)
    borderFrame.leftBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -22)
    borderFrame.leftBorder:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 4, 4)
    borderFrame.leftBorder:SetTexture(0.3, 0.3, 0.3, 1)
    
    -- Bordure grise droite
    borderFrame.rightBorder = borderFrame:CreateTexture(nil, "BACKGROUND")
    borderFrame.rightBorder:SetWidth(1)
    borderFrame.rightBorder:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -22)
    borderFrame.rightBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 4)
    borderFrame.rightBorder:SetTexture(0.3, 0.3, 0.3, 1)
    
    -- Bordure grise inférieure
    borderFrame.bottomBorder = borderFrame:CreateTexture(nil, "BACKGROUND")
    borderFrame.bottomBorder:SetHeight(1)
    borderFrame.bottomBorder:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 4, 4)
    borderFrame.bottomBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 4)
    borderFrame.bottomBorder:SetTexture(0.3, 0.3, 0.3, 1)
    
    -- ===== FOND (BACKGROUND) =====
    
    -- Fond en marbre
    frame.marbleBg = frame:CreateTexture(nil, "BACKGROUND")
    frame.marbleBg:SetPoint("TOPLEFT", 2, -21)
    frame.marbleBg:SetPoint("BOTTOMRIGHT", -2, 2)
    frame.marbleBg:SetTexture("Interface\\FrameGeneral\\UI-Background-Marble", true, true)
    frame.marbleBg:SetHorizTile(true)
    frame.marbleBg:SetVertTile(true)
    
    -- Teinte violette
    frame.tint = frame:CreateTexture(nil, "BORDER")
    frame.tint:SetPoint("TOPLEFT", 2, -21)
    frame.tint:SetPoint("BOTTOMRIGHT", -2, 2)
    frame.tint:SetTexture(0.302, 0.102, 0.204, 0.5)
    
    -- Lignes éthérées
    frame.lines = frame:CreateTexture(nil, "ARTWORK")
    frame.lines:SetPoint("TOPLEFT", 2, -21)
    frame.lines:SetPoint("BOTTOMRIGHT", -2, 2)
    frame.lines:SetTexture("Interface\\Transmogrify\\EtherealLines", true, true)
    frame.lines:SetHorizTile(true)
    frame.lines:SetVertTile(true)
    frame.lines:SetAlpha(0.3)
    
    -- ===== CRÉER LES FRAMES ENFANTS POUR LES BORDURES =====
    -- Ceci garantit que l'ordre d'affichage est toujours correct
    
    -- Frame pour les bords (derrière)
    local edgesFrame = CreateFrame("Frame", nil, frame)
    edgesFrame:SetAllPoints()
    edgesFrame:SetFrameLevel(frame:GetFrameLevel() + 1)
    
    edgesFrame.leftEdge = edgesFrame:CreateTexture(nil, "OVERLAY")
    edgesFrame.leftEdge:SetSize(23, 64)
    edgesFrame.leftEdge:SetTexture("Interface\\Transmogrify\\VerticalTiles", false, true)
    edgesFrame.leftEdge:SetTexCoord(0.40625000, 0.76562500, 0.00000000, 1.00000000)
    
    edgesFrame.rightEdge = edgesFrame:CreateTexture(nil, "OVERLAY")
    edgesFrame.rightEdge:SetSize(23, 64)
    edgesFrame.rightEdge:SetTexture("Interface\\Transmogrify\\VerticalTiles", false, true)
    edgesFrame.rightEdge:SetTexCoord(0.01562500, 0.37500000, 0.00000000, 1.00000000)
    
    edgesFrame.bottomEdge = edgesFrame:CreateTexture(nil, "OVERLAY")
    edgesFrame.bottomEdge:SetSize(64, 23)
    edgesFrame.bottomEdge:SetTexture("Interface\\Transmogrify\\HorizontalTiles", true, false)
    edgesFrame.bottomEdge:SetTexCoord(0.00000000, 1.00000000, 0.01562500, 0.37500000)
    
    edgesFrame.topEdge = edgesFrame:CreateTexture(nil, "OVERLAY")
    edgesFrame.topEdge:SetSize(64, 23)
    edgesFrame.topEdge:SetPoint("TOPLEFT", 2, -3)
    edgesFrame.topEdge:SetPoint("TOPRIGHT", -2, -3)
    edgesFrame.topEdge:SetTexture("Interface\\Transmogrify\\HorizontalTiles", true, false)
    edgesFrame.topEdge:SetTexCoord(0.00000000, 1.00000000, 0.40625000, 0.76562500)
    
    -- Frame pour les coins (devant les bords)
    local cornersFrame = CreateFrame("Frame", nil, frame)
    cornersFrame:SetAllPoints()
    cornersFrame:SetFrameLevel(frame:GetFrameLevel() + 2)
    
    cornersFrame.cornerTL = cornersFrame:CreateTexture(nil, "OVERLAY")
    cornersFrame.cornerTL:SetSize(64, 64)
    cornersFrame.cornerTL:SetPoint("TOPLEFT", -2, -18)
    cornersFrame.cornerTL:SetTexture("Interface\\Transmogrify\\Textures")
    cornersFrame.cornerTL:SetTexCoord(0.00781250, 0.50781250, 0.00195313, 0.12695313)
    
    cornersFrame.cornerTR = cornersFrame:CreateTexture(nil, "OVERLAY")
    cornersFrame.cornerTR:SetSize(64, 64)
    cornersFrame.cornerTR:SetPoint("TOPRIGHT", 0, -18)
    cornersFrame.cornerTR:SetTexture("Interface\\Transmogrify\\Textures")
    cornersFrame.cornerTR:SetTexCoord(0.00781250, 0.50781250, 0.38476563, 0.50781250)
    
    cornersFrame.cornerBL = cornersFrame:CreateTexture(nil, "OVERLAY")
    cornersFrame.cornerBL:SetSize(64, 64)
    cornersFrame.cornerBL:SetPoint("BOTTOMLEFT", -2, -1)
    cornersFrame.cornerBL:SetTexture("Interface\\Transmogrify\\Textures")
    cornersFrame.cornerBL:SetTexCoord(0.00781250, 0.50781250, 0.25781250, 0.38085938)
    
    cornersFrame.cornerBR = cornersFrame:CreateTexture(nil, "OVERLAY")
    cornersFrame.cornerBR:SetSize(64, 64)
    cornersFrame.cornerBR:SetPoint("BOTTOMRIGHT", 0, -1)
    cornersFrame.cornerBR:SetTexture("Interface\\Transmogrify\\Textures")
    cornersFrame.cornerBR:SetTexCoord(0.00781250, 0.50781250, 0.13085938, 0.25390625)
    
    -- Positionner les bords par rapport aux coins
    edgesFrame.leftEdge:SetPoint("TOPLEFT", cornersFrame.cornerTL, "BOTTOMLEFT", 3, 16)
    edgesFrame.leftEdge:SetPoint("BOTTOMLEFT", cornersFrame.cornerBL, "TOPLEFT", 3, -16)
    
    edgesFrame.rightEdge:SetPoint("TOPRIGHT", cornersFrame.cornerTR, "BOTTOMRIGHT", -3, 16)
    edgesFrame.rightEdge:SetPoint("BOTTOMRIGHT", cornersFrame.cornerBR, "TOPRIGHT", -3, -16)
    
    edgesFrame.bottomEdge:SetPoint("BOTTOMLEFT", cornersFrame.cornerBL, "BOTTOMRIGHT", -30, 4)
    edgesFrame.bottomEdge:SetPoint("BOTTOMRIGHT", cornersFrame.cornerBR, "BOTTOMLEFT", 30, 4)
    
    -- Sauvegarder les références pour accès ultérieur si nécessaire
    frame.leftEdge = edgesFrame.leftEdge
    frame.rightEdge = edgesFrame.rightEdge
    frame.bottomEdge = edgesFrame.bottomEdge
    frame.topEdge = edgesFrame.topEdge
    frame.cornerTL = cornersFrame.cornerTL
    frame.cornerTR = cornersFrame.cornerTR
    frame.cornerBL = cornersFrame.cornerBL
    frame.cornerBR = cornersFrame.cornerBR
    
    -- Frame pour la bannière (toujours au-dessus)
    local bannerFrame = CreateFrame("Frame", nil, frame)
    bannerFrame:SetAllPoints()
    bannerFrame:SetFrameLevel(frame:GetFrameLevel() + 3)
    
    bannerFrame.banner = bannerFrame:CreateTexture(nil, "OVERLAY")
    bannerFrame.banner:SetSize(337, 82)
    bannerFrame.banner:SetPoint("BOTTOM", frame, "TOP", 0, -19)
    bannerFrame.banner:SetTexture(VOID_TEXTURE)
    bannerFrame.banner:SetTexCoord(unpack(UV.banner))
    
    frame.banner = bannerFrame.banner
    
    -- Titre
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 16, 3)
    frame.title:SetText("")
    
    -- Bouton de fermeture
	frame.closeButton = CreateFrame("Button", nil, frame)
	frame.closeButton:SetSize(32, 32)
	frame.closeButton:SetPoint("TOPRIGHT", -3, -23)
	frame.closeButton:SetFrameLevel(frame:GetFrameLevel() + 10)  -- AJOUT DE CETTE LIGNE
	frame.closeButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
	frame.closeButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
	frame.closeButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
	frame.closeButton:SetScript("OnClick", function()
		frame:Hide()
	end)
    
    -- ===== DEPOSIT FRAME =====
frame.depositFrame = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
frame.depositFrame:SetSize(145, 138)
frame.depositFrame:SetPoint("TOPLEFT", 34, -48)

frame.depositBg = frame.depositFrame:CreateTexture(nil, "BACKGROUND", nil, -6)
frame.depositBg:SetPoint("TOPLEFT", 3, -3)
frame.depositBg:SetPoint("BOTTOMRIGHT", -3, 2)
frame.depositBg:SetTexture(VOID_TEXTURE)
frame.depositBg:SetTexCoord(unpack(UV.bankBG))

frame.depositTitle = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
frame.depositTitle:SetPoint("BOTTOM", frame.depositFrame, "TOP", 0, 3)
frame.depositTitle:SetText("Dépôt")

frame.depositArrow = frame:CreateTexture(nil, "ARTWORK")
frame.depositArrow:SetSize(27, 46)
frame.depositArrow:SetPoint("LEFT", frame.depositFrame, "RIGHT", -4, 0)
frame.depositArrow:SetTexture(VOID_TEXTURE)
frame.depositArrow:SetTexCoord(unpack(UV.arrowDeposit))
    
    -- Slots Deposit
    frame.depositSlots = {}
    for i = 1, DEPOSIT_SLOTS do
        local slot = CreateFrame("Button", "VoidDepositSlot"..i, frame.depositFrame)
        slot:SetSize(37, 37)
        
        if i == 1 then
            slot:SetPoint("TOPLEFT", 10, -8)
        elseif (i % 3) == 1 then
            slot:SetPoint("TOP", frame.depositSlots[i-3], "BOTTOM", 0, -5)
        else
            slot:SetPoint("LEFT", frame.depositSlots[i-1], "RIGHT", 7, 0)
        end
        
        slot.bg = slot:CreateTexture(nil, "BACKGROUND")
        slot.bg:SetSize(41, 41)
        slot.bg:SetPoint("CENTER")
        slot.bg:SetTexture(VOID_TEXTURE)
        slot.bg:SetTexCoord(unpack(UV.slot))
        
        slot.icon = slot:CreateTexture(nil, "BORDER")
        slot.icon:SetAllPoints()
        
        slot.slotIndex = i
        slot.buttonType = BUTTON_TYPE_DEPOSIT
        
        slot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        slot:RegisterForDrag("LeftButton")
        
        -- Clic droit pour retirer du slot deposit
        slot:SetScript("OnClick", function(self, button)
            if button == "RightButton" and DepositSlots[self.slotIndex] then
                -- Déverrouiller l'item avant de le retirer
                local data = DepositSlots[self.slotIndex]
                if data.bag and data.slot then
                    UnlockItem(data.bag, data.slot)
                end
                DepositSlots[self.slotIndex] = nil
                UpdateDepositSlots()
            elseif button == "LeftButton" then
                -- Clic gauche : déposer l'item du curseur
                local cursorType, itemID, itemLink = GetCursorInfo()
                if cursorType == "item" then
                    -- Chercher l'item dans les sacs pour obtenir sa position
                    local itemBag, itemSlot = nil, nil
                    for bag = 0, 4 do
                        local numSlots = GetContainerNumSlots(bag)
                        if numSlots then
                            for slot = 1, numSlots do
                                local link = GetContainerItemLink(bag, slot)
                                if link then
                                    local id = tonumber(link:match("item:(%d+)"))
                                    if id == itemID then
                                        itemBag = bag
                                        itemSlot = slot
                                        break
                                    end
                                end
                            end
                        end
                        if itemBag then break end
                    end
                    
                    -- Vérifier si l'item est déjà verrouillé
                    if itemBag and itemSlot then
                        if IsItemLocked(itemBag, itemSlot) then
                            --print("|cffff0000Cet item est déjà dans la file de dépôt!|r")
                            ClearCursor()
                            return
                        end
                        
                        -- Stocker les infos et verrouiller
                        local texture = GetItemIcon(itemID)
                        if texture then
                            DepositSlots[self.slotIndex] = {
                                entry = itemID,
                                link = itemLink,
                                texture = texture,
                                bag = itemBag,
                                slot = itemSlot
                            }
                            LockItem(itemBag, itemSlot)
                            UpdateDepositSlots()
                        end
                    end
                    ClearCursor()
                end
            end
        end)
        
        -- Recevoir un item glissé depuis l'inventaire
        slot:SetScript("OnReceiveDrag", function(self)
            local cursorType, itemID, itemLink = GetCursorInfo()
            if cursorType == "item" then
                -- Chercher l'item dans les sacs pour obtenir sa position
                local itemBag, itemSlot = nil, nil
                for bag = 0, 4 do
                    local numSlots = GetContainerNumSlots(bag)
                    if numSlots then
                        for slot = 1, numSlots do
                            local link = GetContainerItemLink(bag, slot)
                            if link then
                                local id = tonumber(link:match("item:(%d+)"))
                                if id == itemID then
                                    itemBag = bag
                                    itemSlot = slot
                                    break
                                end
                            end
                        end
                    end
                    if itemBag then break end
                end
                
                -- Vérifier si l'item est déjà verrouillé
                if itemBag and itemSlot then
                    if IsItemLocked(itemBag, itemSlot) then
                        --print("|cffff0000Cet item est déjà dans la file de dépôt!|r")
                        ClearCursor()
                        return
                    end
                    
                    -- Stocker les infos et verrouiller
                    local texture = GetItemIcon(itemID)
                    if texture then
                        DepositSlots[self.slotIndex] = {
                            entry = itemID,
                            link = itemLink,
                            texture = texture,
                            bag = itemBag,
                            slot = itemSlot
                        }
                        LockItem(itemBag, itemSlot)
                        UpdateDepositSlots()
                    end
                end
                ClearCursor()
            end
        end)
        
        -- Glisser l'item du slot deposit vers l'inventaire (annulation)
        slot:SetScript("OnDragStart", function(self)
            if DepositSlots[self.slotIndex] then
                -- Déverrouiller l'item avant de le retirer
                local data = DepositSlots[self.slotIndex]
                if data.bag and data.slot then
                    UnlockItem(data.bag, data.slot)
                end
                DepositSlots[self.slotIndex] = nil
                UpdateDepositSlots()
            end
        end)
        
        slot:SetScript("OnEnter", function(self)
            if DepositSlots[self.slotIndex] then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(DepositSlots[self.slotIndex].link)
                GameTooltip:Show()
            end
        end)
        
        slot:SetScript("OnLeave", function() GameTooltip:Hide() end)
        
        frame.depositSlots[i] = slot
    end
    
    -- ===== WITHDRAW FRAME =====
frame.withdrawFrame = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
frame.withdrawFrame:SetSize(145, 138)
frame.withdrawFrame:SetPoint("TOP", frame.depositFrame, "BOTTOM", 0, -22)

frame.withdrawBg = frame.withdrawFrame:CreateTexture(nil, "BACKGROUND", nil, -6)
frame.withdrawBg:SetPoint("TOPLEFT", 3, -3)
frame.withdrawBg:SetPoint("BOTTOMRIGHT", -3, 2)
frame.withdrawBg:SetTexture(VOID_TEXTURE)
frame.withdrawBg:SetTexCoord(unpack(UV.bankBG))

frame.withdrawTitle = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
frame.withdrawTitle:SetPoint("BOTTOM", frame.withdrawFrame, "TOP", 0, 3)
frame.withdrawTitle:SetText("Retrait")

frame.withdrawArrow = frame:CreateTexture(nil, "ARTWORK")
frame.withdrawArrow:SetSize(27, 46)
frame.withdrawArrow:SetPoint("LEFT", frame.withdrawFrame, "RIGHT", -1, 0)
frame.withdrawArrow:SetTexture(VOID_TEXTURE)
frame.withdrawArrow:SetTexCoord(unpack(UV.arrowWithdraw))
    
    -- Slots Withdraw
    frame.withdrawSlots = {}
    for i = 1, WITHDRAW_SLOTS do
        local slot = CreateFrame("Button", "VoidWithdrawSlot"..i, frame.withdrawFrame)
        slot:SetSize(37, 37)
        
        if i == 1 then
            slot:SetPoint("TOPLEFT", 10, -8)
        elseif (i % 3) == 1 then
            slot:SetPoint("TOP", frame.withdrawSlots[i-3], "BOTTOM", 0, -5)
        else
            slot:SetPoint("LEFT", frame.withdrawSlots[i-1], "RIGHT", 7, 0)
        end
        
        slot.bg = slot:CreateTexture(nil, "BACKGROUND")
        slot.bg:SetSize(41, 41)
        slot.bg:SetPoint("CENTER")
        slot.bg:SetTexture(VOID_TEXTURE)
        slot.bg:SetTexCoord(unpack(UV.slot))
        
        slot.icon = slot:CreateTexture(nil, "BORDER")
        slot.icon:SetAllPoints()
        
        slot.slotIndex = i
        slot.buttonType = BUTTON_TYPE_WITHDRAW
        
        slot:RegisterForClicks("RightButtonUp")
        
        -- Clic droit pour retirer
        slot:SetScript("OnClick", function(self, button)
            if button == "RightButton" and WithdrawSlots[self.slotIndex] then
                WithdrawSlots[self.slotIndex] = nil
                UpdateWithdrawSlots()
            end
        end)
        
        slot:SetScript("OnEnter", function(self)
            if WithdrawSlots[self.slotIndex] then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(WithdrawSlots[self.slotIndex].link)
                GameTooltip:Show()
            end
        end)
        
        slot:SetScript("OnLeave", function() GameTooltip:Hide() end)
        
        frame.withdrawSlots[i] = slot
    end
    
    -- ===== STORAGE FRAME =====
frame.storageFrame = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
frame.storageFrame:SetSize(481, 347)
frame.storageFrame:SetPoint("TOPLEFT", frame.depositFrame, "TOPRIGHT", 22, -4)

frame.storageBg = frame.storageFrame:CreateTexture(nil, "BACKGROUND", nil, -6)
frame.storageBg:SetPoint("TOPLEFT", 3, -3)
frame.storageBg:SetPoint("BOTTOMRIGHT", -3, 2)
frame.storageBg:SetTexture(VOID_TEXTURE)
frame.storageBg:SetTexCoord(unpack(UV.bankBG))

-- Lignes de séparation
for j = 1, 4 do
    local line = frame.storageFrame:CreateTexture(nil, "ARTWORK")
    line:SetSize(2, 343)
    line:SetPoint("TOPLEFT", 97 * j, -2)
    line:SetTexture(0.1451, 0.0941, 0.1373, 0.8)
end

frame.storageTitle = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
frame.storageTitle:SetPoint("BOTTOMLEFT", frame.storageFrame, "TOPLEFT", 16, 3)
frame.storageTitle:SetText("Chambre du Vide")
    
    -- Slots Storage
    frame.storageSlots = {}
    for i = 1, VOID_STORAGE_SLOTS do
        local slot = CreateFrame("Button", "VoidStorageSlot"..i, frame.storageFrame)
        slot:SetSize(37, 37)
        
        if i == 1 then
            slot:SetPoint("TOPLEFT", 10, -8)
        elseif (i % 8) == 1 then
            local offset = ((i % 16) == 1) and 14 or 7
            slot:SetPoint("LEFT", frame.storageSlots[i-8], "RIGHT", offset, 0)
        else
            slot:SetPoint("TOP", frame.storageSlots[i-1], "BOTTOM", 0, -5)
        end
        
        slot.bg = slot:CreateTexture(nil, "BACKGROUND")
        slot.bg:SetSize(41, 41)
        slot.bg:SetPoint("CENTER")
        slot.bg:SetTexture(VOID_TEXTURE)
        slot.bg:SetTexCoord(unpack(UV.slot))
        
        slot.icon = slot:CreateTexture(nil, "BORDER")
        slot.icon:SetAllPoints()
        
        slot.slotIndex = i
        slot.buttonType = BUTTON_TYPE_STORAGE
        
        slot:RegisterForClicks("LeftButtonUp")
        
        -- Clic gauche pour ajouter au withdraw
        slot:SetScript("OnClick", function(self, button)
            if button == "LeftButton" and VoidStorageData[self.slotIndex] then
                -- Trouver un slot withdraw vide
                for j = 1, WITHDRAW_SLOTS do
                    if not WithdrawSlots[j] then
                        WithdrawSlots[j] = {
                            voidSlot = self.slotIndex,
                            entry = VoidStorageData[self.slotIndex].entry,
                            link = VoidStorageData[self.slotIndex].link
                        }
                        UpdateWithdrawSlots()
                        break
                    end
                end
            end
        end)
        
        slot:SetScript("OnEnter", function(self)
            if VoidStorageData[self.slotIndex] then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(VoidStorageData[self.slotIndex].link)
                GameTooltip:Show()
            end
        end)
        
        slot:SetScript("OnLeave", function() GameTooltip:Hide() end)
        
        frame.storageSlots[i] = slot
    end
    
    -- ===== COST FRAME =====
frame.costFrame = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
frame.costFrame:SetSize(145, 44)
frame.costFrame:SetPoint("LEFT", frame.withdrawFrame)
frame.costFrame:SetPoint("BOTTOM", frame.storageFrame)

frame.costBg = frame.costFrame:CreateTexture(nil, "BACKGROUND", nil, -6)
frame.costBg:SetPoint("TOPLEFT", 3, -3)
frame.costBg:SetPoint("BOTTOMRIGHT", -3, 2)
frame.costBg:SetTexture(VOID_TEXTURE)
frame.costBg:SetTexCoord(unpack(UV.bankBG))

frame.costLabel = frame.costFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
frame.costLabel:SetPoint("TOPLEFT", 8, -6)
frame.costLabel:SetText("Coût :")

frame.costText = frame.costFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
frame.costText:SetPoint("TOPRIGHT", -8, -6)
frame.costText:SetText("0|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:2:0|t")
    
    -- Bouton Transfer
    frame.transferButton = CreateFrame("Button", nil, frame.costFrame, "UIPanelButtonTemplate")
    frame.transferButton:SetSize(143, 22)
    frame.transferButton:SetPoint("BOTTOM", 0, 2)
    frame.transferButton:SetText("Transférer")
    frame.transferButton:Disable()
    
    frame.transferButton:SetScript("OnClick", function()
        -- Protection anti-spam
        if isTransferInProgress then
            --print("|cffff0000Transfert en cours, veuillez patienter...|r")
            return
        end
        
        -- Collecter les items à déposer en cherchant leur position actuelle
        local depositItems = {}
        for i = 1, DEPOSIT_SLOTS do
            if DepositSlots[i] and DepositSlots[i].entry then
                -- Chercher l'item dans les sacs MAINTENANT (pas avant)
                local found = false
                for bag = 0, 4 do
                    local numSlots = GetContainerNumSlots(bag)
                    if numSlots then
                        for slot = 1, numSlots do
                            local link = GetContainerItemLink(bag, slot)
                            if link then
                                local itemID = tonumber(link:match("item:(%d+)"))
                                if itemID == DepositSlots[i].entry then
                                    table.insert(depositItems, {
                                        bag = bag,
                                        slot = slot - 1
                                    })
                                    found = true
                                    break
                                end
                            end
                        end
                    end
                    if found then break end
                end
                
                if not found then
                    --print("|cffff0000Erreur: Item " .. (DepositSlots[i].link or "inconnu") .. " non trouvé dans l'inventaire!|r")
                end
            end
        end
        
        -- Collecter les slots à retirer
        local withdrawSlots = {}
        for i = 1, WITHDRAW_SLOTS do
            if WithdrawSlots[i] and WithdrawSlots[i].voidSlot then
                table.insert(withdrawSlots, WithdrawSlots[i].voidSlot)
            end
        end
        
        -- Vérifier qu'il y a quelque chose à transférer
        if #depositItems == 0 and #withdrawSlots == 0 then
            --print("|cffff0000Aucun item à transférer!|r")
            return
        end
        
        -- VERROUILLER le transfert
        isTransferInProgress = true
        frame.transferButton:Disable()
        frame.transferButton:SetText("Transfert...")
        
        -- Envoyer au serveur
        if #depositItems > 0 then
            --print("|cff00ff00Envoi de " .. #depositItems .. " item(s) au serveur...|r")
            AIO.Handle("VoidStorage", "DepositItems", depositItems)
        end
        
        if #withdrawSlots > 0 then
            AIO.Handle("VoidStorage", "WithdrawItems", withdrawSlots)
        end
        
        -- Débloquer après 2 secondes de sécurité (au cas où le serveur ne répond pas)
        C_Timer.After(2, function()
            if isTransferInProgress then
                isTransferInProgress = false
                frame.transferButton:SetText("Transférer")
                UpdateCostDisplay() -- Réactiver le bouton si nécessaire
            end
        end)
    end)
    
    VoidStorageFrame = frame
    return frame
end

-- ============================================
-- HANDLERS AIO
-- ============================================

function VoidStorageHandlers.OpenVoidStorage(player)
    local frame = CreateVoidStorageFrame()
    DepositSlots = {}
    WithdrawSlots = {}
    UnlockAllItems() -- Réinitialiser les verrous
    isTransferInProgress = false
    frame:Show()
    PlaySoundFile(OPEN_TALENT_WINDOW_SOUND)
    AIO.Handle("VoidStorage", "RequestData")
end

function VoidStorageHandlers.ReceiveData(player, data)
    VoidStorageData = data or {}
    UpdateStorageSlots()
end

function VoidStorageHandlers.UpdateAfterDeposit(player, success, message, newData)
    -- Débloquer le transfert
    isTransferInProgress = false
    if VoidStorageFrame and VoidStorageFrame.transferButton then
        VoidStorageFrame.transferButton:SetText("Transférer")
    end
    
    if success then
        --print("|cff00ff00" .. message .. "|r")
        
        VoidStorageData = newData or {}
        DepositSlots = {}
        UpdateStorageSlots()
        UpdateDepositSlots()
    else
        --print("|cffff0000" .. message .. "|r")
        -- Réactiver le bouton même en cas d'erreur
        UpdateCostDisplay()
    end
end

function VoidStorageHandlers.UpdateAfterWithdraw(player, success, message, newData)
    -- Débloquer le transfert
    isTransferInProgress = false
    if VoidStorageFrame and VoidStorageFrame.transferButton then
        VoidStorageFrame.transferButton:SetText("Transférer")
    end
    
    if success then
        --print("|cff00ff00" .. message .. "|r")
        VoidStorageData = newData or {}
        WithdrawSlots = {}
        UpdateStorageSlots()
        UpdateWithdrawSlots()
    else
        --print("|cffff0000" .. message .. "|r")
        -- Réactiver le bouton même en cas d'erreur
        UpdateCostDisplay()
    end
end