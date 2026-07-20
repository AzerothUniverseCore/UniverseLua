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

local BG_TEXTURE = "Interface\\WeaponUpgrade\\shopcardgenericgreen"
local BG_COORD    = { 0, 570 / 1024, 0, 465 / 512 }

local ITEM_BORDER_TEXTURE = "Interface\\Collections\\Collections"
local ITEM_BORDER_COORD   = { 0.246094, 0.355469, 0.013672, 0.123047 }

local ATLAS_TEXTURE = "Interface\\Journeys\\JourneysFrame2xUpgrade"
local PLATE_NORMAL  = { 0.026367, 0.334961, 0.102539, 0.204590 }

local ARROW_NEXT = { 0.002441, 0.022461, 0.002441, 0.037109 }

local EMPTY_SLOT_TEXTURE = "Interface\\PaperDoll\\UI-PaperDoll-Slot-MainHand"

local function ResetSlotIcon(icon)
    icon:SetTexture(EMPTY_SLOT_TEXTURE)
    icon:SetTexCoord(0, 1, 0, 1)
    icon:SetVertexColor(1, 1, 1)
    icon:Show()
end

local FRAME_W, FRAME_H = 340, 292

local frameWeaponsUpgrade
local currentItemID

local upgradeMapping = {}

function WeaponsUpgradeHandlers.SetUpgradeMapping(player, mappingData)
    upgradeMapping = mappingData
    --print("[WeaponsUpgrade] Mappings reçus du serveur: " .. #mappingData .. " entrées")
end

local function CreateWeaponsUpgrade()
    frameWeaponsUpgrade = CreateFrame("Frame", "WeaponsUpgradeFrame", UIParent)
    frameWeaponsUpgrade:SetSize(FRAME_W, FRAME_H)
    frameWeaponsUpgrade:SetPoint("CENTER")
    frameWeaponsUpgrade:SetFrameStrata("FULLSCREEN_DIALOG")
    frameWeaponsUpgrade:EnableMouse(true)
    frameWeaponsUpgrade:SetMovable(true)
    frameWeaponsUpgrade:RegisterForDrag("LeftButton")
    frameWeaponsUpgrade:SetScript("OnDragStart", frameWeaponsUpgrade.StartMoving)
    frameWeaponsUpgrade:SetScript("OnDragStop", frameWeaponsUpgrade.StopMovingOrSizing)

    local bg = frameWeaponsUpgrade:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(frameWeaponsUpgrade)
    bg:SetTexture(BG_TEXTURE)
    bg:SetTexCoord(unpack(BG_COORD))
    frameWeaponsUpgrade.bg = bg

    local title = frameWeaponsUpgrade:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\MORPHEUS.TTF", 20, "OUTLINE")
    title:SetPoint("TOP", 0, -18)
    title:SetTextColor(1, 1, 1)
    title:SetText("Arme Prodigieuse")

    local subtitle = frameWeaponsUpgrade:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -6)
    subtitle:SetText("|cffff8204(Amélioration)|r")

    frameWeaponsUpgrade:SetScript("OnHide", function()
        PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
    end)

    local closeButton = CreateFrame("Button", nil, frameWeaponsUpgrade, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frameWeaponsUpgrade, "TOPRIGHT", -3, -3)
    closeButton:SetScript("OnClick", function()
        frameWeaponsUpgrade:Hide()
    end)

    local SLOT_SIZE = 44

    local itemSlot1 = CreateFrame("Button", "ItemSlotFrame1", frameWeaponsUpgrade)
    itemSlot1:SetSize(SLOT_SIZE, SLOT_SIZE)
    itemSlot1:SetPoint("CENTER", frameWeaponsUpgrade, "CENTER", -62, 6)

    local itemIcon1 = itemSlot1:CreateTexture(nil, "ARTWORK")
    itemIcon1:SetPoint("CENTER")
    itemIcon1:SetSize(SLOT_SIZE - 6, SLOT_SIZE - 6)
    itemSlot1.itemIcon = itemIcon1
    ResetSlotIcon(itemIcon1)

    local ring1 = itemSlot1:CreateTexture(nil, "OVERLAY")
    ring1:SetAllPoints(itemSlot1)
    ring1:SetTexture(ITEM_BORDER_TEXTURE)
    ring1:SetTexCoord(unpack(ITEM_BORDER_COORD))
    itemSlot1.ring = ring1

    local arrow = frameWeaponsUpgrade:CreateTexture(nil, "ARTWORK")
    arrow:SetSize(16, 28)
    arrow:SetPoint("CENTER", frameWeaponsUpgrade, "CENTER", 0, 6)
    arrow:SetTexture(ATLAS_TEXTURE)
    arrow:SetTexCoord(unpack(ARROW_NEXT))

    local itemSlot2 = CreateFrame("Button", "ItemSlotFrame2", frameWeaponsUpgrade)
    itemSlot2:SetSize(SLOT_SIZE, SLOT_SIZE)
    itemSlot2:SetPoint("CENTER", frameWeaponsUpgrade, "CENTER", 62, 6)

    local itemIcon2 = itemSlot2:CreateTexture(nil, "ARTWORK")
    itemIcon2:SetPoint("CENTER")
    itemIcon2:SetSize(SLOT_SIZE - 6, SLOT_SIZE - 6)
    itemSlot2.itemIcon = itemIcon2
    ResetSlotIcon(itemIcon2)

    local ring2 = itemSlot2:CreateTexture(nil, "OVERLAY")
    ring2:SetAllPoints(itemSlot2)
    ring2:SetTexture(ITEM_BORDER_TEXTURE)
    ring2:SetTexCoord(unpack(ITEM_BORDER_COORD))
    itemSlot2.ring = ring2

    local function UpdateNextUpgradeDisplay(itemID)
        local newItemID = upgradeMapping[itemID]
        if newItemID then
            itemSlot2.itemIcon:SetTexture(GetItemIcon(newItemID))
            itemSlot2.itemIcon:SetTexCoord(0, 1, 0, 1)
            itemSlot2.itemIcon:Show()
        else
            ResetSlotIcon(itemSlot2.itemIcon)
        end
    end

    itemSlot1:SetScript("OnReceiveDrag", function()
        local cursorType, itemID = GetCursorInfo()
        if cursorType == "item" then
            itemSlot1.itemIcon:SetTexture(GetItemIcon(itemID))
            itemSlot1.itemIcon:Show()
            currentItemID = itemID
            ClearCursor()

            UpdateNextUpgradeDisplay(itemID)
        end
    end)

    itemSlot1:SetScript("OnClick", function(self, button)
        local cursorType, itemID = GetCursorInfo()

        if button == "LeftButton" then
            if cursorType == "item" then
                itemSlot1.itemIcon:SetTexture(GetItemIcon(itemID))
                itemSlot1.itemIcon:Show()
                currentItemID = itemID
                ClearCursor()

                UpdateNextUpgradeDisplay(itemID)
            elseif currentItemID then
                ResetSlotIcon(itemSlot1.itemIcon)
                currentItemID = nil
                ResetSlotIcon(itemSlot2.itemIcon)
                GameTooltip:Hide()
            end
        elseif button == "RightButton" then
            ResetSlotIcon(itemSlot1.itemIcon)
            currentItemID = nil
            ResetSlotIcon(itemSlot2.itemIcon)
            GameTooltip:Hide()
        end
    end)

    itemSlot1:SetScript("OnEnter", function(self)
        self.ring:SetVertexColor(1, 1, 0.55)
        if currentItemID then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink("item:" .. currentItemID)
            GameTooltip:Show()
        end
    end)

    itemSlot1:SetScript("OnLeave", function(self)
        self.ring:SetVertexColor(1, 1, 1)
        GameTooltip:Hide()
    end)

    local goldIcon = frameWeaponsUpgrade:CreateTexture(nil, "OVERLAY")
    goldIcon:SetSize(16, 16)
    goldIcon:SetPoint("BOTTOM", frameWeaponsUpgrade, "BOTTOM", -100, 80)
    goldIcon:SetTexture("Interface\\Icons\\inv_enchanting_wod_crystal")

    itemSlot2:SetScript("OnEnter", function(self)
        self.ring:SetVertexColor(1, 1, 0.55)
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
        self.ring:SetVertexColor(1, 1, 1)
        GameTooltip:Hide()
    end)

    local upgradeButton = CreateFrame("Button", nil, frameWeaponsUpgrade)
    upgradeButton:SetSize(140, 30)
    upgradeButton:SetPoint("BOTTOM", 0, 18)

    local upgradeBg = upgradeButton:CreateTexture(nil, "BACKGROUND")
    upgradeBg:SetAllPoints(upgradeButton)
    upgradeBg:SetTexture(ATLAS_TEXTURE)
    upgradeBg:SetTexCoord(unpack(PLATE_NORMAL))
    upgradeButton.bg = upgradeBg

    local upgradeLabel = upgradeButton:CreateFontString(nil, "OVERLAY")
    upgradeLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    upgradeLabel:SetPoint("CENTER")
    upgradeLabel:SetText("Améliorer")
    upgradeLabel:SetTextColor(1, 1, 1)

    upgradeButton:SetScript("OnEnter", function(self) self.bg:SetVertexColor(1, 0.85, 0.55) end)
    upgradeButton:SetScript("OnLeave", function(self) self.bg:SetVertexColor(1, 1, 1) end)

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
            ResetSlotIcon(itemSlot1.itemIcon)
            ResetSlotIcon(itemSlot2.itemIcon)
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
