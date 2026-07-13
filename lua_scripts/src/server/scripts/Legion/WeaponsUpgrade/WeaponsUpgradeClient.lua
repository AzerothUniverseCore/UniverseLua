-- WeaponsUpgradeClient.lua
local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

local WeaponsUpgradeHandlers = AIO.AddHandlers("WeaponsUpgradeHandler", {})

local OPEN_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_9_0_covenant_ability_ability_button_placed.ogg"
local CLOSE_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_9_0_covenant_ability_ability_button_appears.ogg"
local UPGRADE_SUCCESS_SOUND = "Sound\\TalentsSystem\\ui_70_artifact_forge_apperancechange_03.ogg"
local UPGRADE_FAILURE_SOUND = "Sound\\TalentsSystem\\ui_70_artifact_forge_apperancelocked_01.ogg"
local PLACEHOLDER_SOUND = "Sound\\TalentsSystem\\ui_70_artifact_forge_appearance_locked.ogg"

local frameWeaponsUpgrade
local currentItemID

-- Cache local pour l'aperçu (sera synchronisé avec le serveur)
local upgradeMapping = {}

-- Fonction pour recevoir les mappings depuis le serveur
function WeaponsUpgradeHandlers.SetUpgradeMapping(player, mappingData)
    upgradeMapping = mappingData
    --print("[WeaponsUpgrade] Mappings reçus du serveur: " .. #mappingData .. " entrées")
end

local function CreateWeaponsUpgrade()
    frameWeaponsUpgrade = CreateFrame("Frame", "WeaponsUpgradeFrame", UIParent)
    frameWeaponsUpgrade:SetSize(300, 300)
    frameWeaponsUpgrade:SetPoint("CENTER")
    frameWeaponsUpgrade:SetBackdrop({
        bgFile = "Interface\\Collections\\WeaponsItemUpgrade",
        edgeSize = 20,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    frameWeaponsUpgrade:SetBackdropColor(1, 1, 1, 1)
    frameWeaponsUpgrade:EnableMouse(true)
    frameWeaponsUpgrade:SetMovable(true)
    frameWeaponsUpgrade:RegisterForDrag("LeftButton")
    frameWeaponsUpgrade:SetScript("OnDragStart", frameWeaponsUpgrade.StartMoving)
    frameWeaponsUpgrade:SetScript("OnDragStop", frameWeaponsUpgrade.StopMovingOrSizing)

    local title = frameWeaponsUpgrade:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", 0, -40)
    title:SetText("Amélioration")

    local subtitle = frameWeaponsUpgrade:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -5)
    subtitle:SetText("|cff006cd9(Arme Prodigieuse)|r")

    frameWeaponsUpgrade:SetScript("OnHide", function()
        PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
    end)

    local closeButton = CreateFrame("Button", nil, frameWeaponsUpgrade, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frameWeaponsUpgrade, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function()
        frameWeaponsUpgrade:Hide()
    end)

    -- Premier emplacement d'item (actuel)
    local itemSlot1 = CreateFrame("Button", "ItemSlotFrame1", frameWeaponsUpgrade, "ItemButtonTemplate")
    itemSlot1:SetSize(32, 32)
    itemSlot1:SetPoint("CENTER", -50, -10)
    itemSlot1:SetNormalTexture("Interface\\Collections\\ESlot2")

    local itemIcon1 = itemSlot1:CreateTexture(nil, "OVERLAY")
    itemIcon1:SetSize(32, 32)
    itemIcon1:SetPoint("CENTER")
    itemSlot1.itemIcon = itemIcon1

    -- Deuxième emplacement d'item (suivant)
    local itemSlot2 = CreateFrame("Button", "ItemSlotFrame2", frameWeaponsUpgrade, "ItemButtonTemplate")
    itemSlot2:SetSize(32, 32)
    itemSlot2:SetPoint("CENTER", 50, -10)
    itemSlot2:SetNormalTexture("Interface\\Collections\\ESlot")

    local itemIcon2 = itemSlot2:CreateTexture(nil, "OVERLAY")
    itemIcon2:SetSize(32, 32)
    itemIcon2:SetPoint("CENTER")
    itemSlot2.itemIcon = itemIcon2

    -- Fonction pour mettre à jour l'affichage de l'amélioration suivante
    local function UpdateNextUpgradeDisplay(itemID)
        local newItemID = upgradeMapping[itemID]
        if newItemID then
            itemSlot2.itemIcon:SetTexture(GetItemIcon(newItemID))
            itemSlot2.itemIcon:Show()
        else
            itemSlot2.itemIcon:SetTexture(nil)
            itemSlot2.itemIcon:Hide()
        end
    end

    -- Fonction pour gérer le glisser-déposer du premier emplacement
    itemSlot1:SetScript("OnReceiveDrag", function()
        local cursorType, itemID = GetCursorInfo()
        if cursorType == "item" then
            itemSlot1.itemIcon:SetTexture(GetItemIcon(itemID))
            itemSlot1.itemIcon:Show()
            currentItemID = itemID
            ClearCursor()

            -- Mise à jour de l'affichage de l'amélioration suivante
            UpdateNextUpgradeDisplay(itemID)
        end
    end)

    -- Gestion du clic sur le premier emplacement
    itemSlot1:SetScript("OnClick", function(self, button)
        local cursorType, itemID = GetCursorInfo()
        
        if button == "LeftButton" then
            if cursorType == "item" then
                itemSlot1.itemIcon:SetTexture(GetItemIcon(itemID))
                itemSlot1.itemIcon:Show()
                currentItemID = itemID
                ClearCursor()

                -- Mise à jour de l'affichage de l'amélioration suivante
                UpdateNextUpgradeDisplay(itemID)
            elseif currentItemID then
                itemSlot1.itemIcon:SetTexture(nil)
                itemSlot1.itemIcon:Hide()
                currentItemID = nil
                itemSlot2.itemIcon:SetTexture(nil)
                itemSlot2.itemIcon:Hide()
                GameTooltip:Hide()
            end
        elseif button == "RightButton" then
            itemSlot1.itemIcon:SetTexture(nil)
            itemSlot1.itemIcon:Hide()
            currentItemID = nil
            itemSlot2.itemIcon:SetTexture(nil)
            itemSlot2.itemIcon:Hide()
            GameTooltip:Hide()
        end
    end)

    -- Scripts OnEnter et OnLeave pour les deux emplacements
    itemSlot1:SetScript("OnEnter", function(self)
        if currentItemID then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink("item:" .. currentItemID)
            GameTooltip:Show()
        end
    end)

    itemSlot1:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    local goldIcon = frameWeaponsUpgrade:CreateTexture(nil, "OVERLAY")
    goldIcon:SetSize(16, 16)
    goldIcon:SetPoint("BOTTOM", -95, 65)
    goldIcon:SetTexture("Interface\\Icons\\inv_enchanting_wod_crystal")
    
    local goldCostText = frameWeaponsUpgrade:CreateFontString(nil, "OVERLAY", "GameFontHighlight")

    itemSlot2:SetScript("OnEnter", function(self)
        if currentItemID then
            local newItemID = upgradeMapping[currentItemID]
            if newItemID then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink("item:" .. newItemID)
                GameTooltip:Show()
            end
        end
    end)
    
    local goldCostText = frameWeaponsUpgrade:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    goldCostText:SetPoint("LEFT", goldIcon, "RIGHT", 5, 0)
    goldCostText:SetText("Prix : 14000 Cristaux d'Infusion")

    itemSlot2:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Ajout du bouton d'amélioration
    local upgradeButton = CreateFrame("Button", nil, frameWeaponsUpgrade, "UIPanelButtonTemplate")
    upgradeButton:SetSize(100, 30)
    upgradeButton:SetPoint("BOTTOM", 0, 20)
    upgradeButton:SetText("Améliorer")
    upgradeButton:SetScript("OnClick", function()
        if InCombatLockdown() then
            print("Vous ne pouvez pas améliorer votre arme pendant un combat.")
            return
        end

        if currentItemID then
            local newItemID = upgradeMapping[currentItemID]
            if not newItemID then
                PlaySoundFile(UPGRADE_FAILURE_SOUND)
                print("Cet objet ne peut pas être amélioré.")
                return
            end
            
            PlaySoundFile(UPGRADE_SUCCESS_SOUND)
            AIO.Handle("WeaponsUpgradeHandler", "UpgradeItem", currentItemID)
            itemSlot1.itemIcon:SetTexture(nil)
            itemSlot1.itemIcon:Hide()
            itemSlot2.itemIcon:SetTexture(nil)
            itemSlot2.itemIcon:Hide()
            itemSlot1:SetNormalTexture("Interface\\Collections\\ESlot2")
            currentItemID = nil
        else
            PlaySoundFile(PLACEHOLDER_SOUND)
            print("Veuillez placer une arme prodigieuse dans l'emplacement avant d'utiliser l'amélioration.")
        end
    end)

    frameWeaponsUpgrade:Hide()
    tinsert(UISpecialFrames, "WeaponsUpgradeFrame")
end

function WeaponsUpgradeHandlers.OpenInterface()
    if not frameWeaponsUpgrade then
        CreateWeaponsUpgrade()
    end
    frameWeaponsUpgrade:Show()
    PlaySoundFile(OPEN_TALENT_WINDOW_SOUND)
end
