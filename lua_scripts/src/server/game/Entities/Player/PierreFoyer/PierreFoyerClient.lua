local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

local LOCALES = {
    frFR = {
        buttonTooltipTitle = "Pierre de Foyer",
        buttonTooltipLine  = "Cliquez pour voyager vers un lieu.",
        windowTitle        = "Pierre de Foyer",
        recallLabel        = "Retour",
        recallTooltipTitle = "Retour",
        recallTooltipLine  = "Vous ramene a votre position precedente.",
        closeTooltip       = "Fermer",
    },
    enUS = {
        buttonTooltipTitle = "Hearthstone",
        buttonTooltipLine  = "Click to travel to a location.",
        windowTitle        = "Hearthstone",
        recallLabel        = "Recall",
        recallTooltipTitle = "Recall",
        recallTooltipLine  = "Returns you to your previous location.",
        closeTooltip       = "Close",
    },
}
local L = LOCALES[GetLocale()] or LOCALES.enUS
local IS_FR = (GetLocale() == "frFR")

local DESTINATIONS = {
    { "Orgrimmar",                          nameEn = "Orgrimmar",                          faction = "Horde" },
    { "Sanctuaire des Deux-Lunes",          nameEn = "Shrine of Two Moons",                faction = "Horde" },
    { "Hurlevent",                          nameEn = "Stormwind",                          faction = "Alliance" },
    { "Sanctuaire des Sept-Etoiles",        nameEn = "Shrine of Seven Stars",              faction = "Alliance" },
    { "Dalaran",                            nameEn = "Dalaran" },
    { "Dalaran (Legion)",        			nameEn = "Dalaran (Legion)" },
    { "Les Ports Oublies",       			nameEn = "The Forgotten Ports" },
    { "Netheril",         					nameEn = "Netheril" },
    { "Chemin du Reve d'emeraude",      	nameEn = "Path of the Emerald Dream" },
}

local function DestName(dest)
    return IS_FR and dest[1] or dest.nameEn
end

local playerFaction = UnitFactionGroup("player")

local function DestVisible(dest)
    return not dest.faction or dest.faction == playerFaction
end

local frame = CreateFrame("Frame", "PierreFoyerFrame", UIParent)
frame:SetFrameStrata("DIALOG")
frame:SetWidth(230)
frame:SetHeight(120)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 60)
frame:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 11, top = 12, bottom = 11 },
})
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:SetClampedToScreen(true)
frame:Hide()

UISpecialFrames = UISpecialFrames or {}
table.insert(UISpecialFrames, "PierreFoyerFrame")

local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", frame, "TOP", 0, -16)
title:SetText(L.windowTitle)

local titleIcon = frame:CreateTexture(nil, "ARTWORK")
titleIcon:SetWidth(20)
titleIcon:SetHeight(20)
titleIcon:SetPoint("RIGHT", title, "LEFT", -4, 0)
titleIcon:SetTexture("Interface\\Icons\\INV_Misc_Rune_01")

local closeButton = CreateFrame("Button", "PierreFoyerFrameCloseButton", frame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
closeButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText(L.closeTooltip, 1, 1, 1)
    GameTooltip:Show()
end)
closeButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

local BUTTON_WIDTH  = 190
local BUTTON_HEIGHT = 20
local BUTTON_GAP    = 4
local TOP_PADDING   = 42

local destButtons = {}
local shownCount = 0
for i, dest in ipairs(DESTINATIONS) do
    if DestVisible(dest) then
        local btn = CreateFrame("Button", "PierreFoyerDestButton"..i, frame, "UIPanelButtonTemplate")
        btn:SetWidth(BUTTON_WIDTH)
        btn:SetHeight(BUTTON_HEIGHT)
        btn:SetPoint("TOP", frame, "TOP", 0, -(TOP_PADDING + shownCount * (BUTTON_HEIGHT + BUTTON_GAP)))
        btn:SetText(DestName(dest))
        btn:SetScript("OnClick", function()
            AIO.Handle("PierreFoyer", "Teleport", i)
        end)
        destButtons[i] = btn
        shownCount = shownCount + 1
    end
end

local lastY = TOP_PADDING + (shownCount - 1) * (BUTTON_HEIGHT + BUTTON_GAP) + BUTTON_HEIGHT

local divider = frame:CreateTexture(nil, "ARTWORK")
divider:SetWidth(BUTTON_WIDTH)
divider:SetHeight(8)
divider:SetPoint("TOP", frame, "TOP", 0, -(lastY + 10))
divider:SetTexture("Interface\\Common\\UI-TooltipDivider-Transparent")

local recallButton = CreateFrame("Button", "PierreFoyerRecallButton", frame, "UIPanelButtonTemplate")
recallButton:SetWidth(BUTTON_WIDTH)
recallButton:SetHeight(BUTTON_HEIGHT + 2)
recallButton:SetPoint("TOP", divider, "BOTTOM", 0, -8)
recallButton:SetText(L.recallLabel)
recallButton:SetScript("OnClick", function()
    AIO.Handle("PierreFoyer", "Recall")
end)
recallButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L.recallTooltipTitle, 1, 1, 1)
    GameTooltip:AddLine(L.recallTooltipLine, 1, 0.82, 0, true)
    GameTooltip:Show()
end)
recallButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

local totalHeight = lastY + 10 + 8 + 8 + BUTTON_HEIGHT + 2 + 16
frame:SetHeight(totalHeight)

do

    local CF_ANCHOR         = "TOPLEFT"
    local CF_RELATIVE_POINT = "TOPLEFT"
    local CF_OFFSET_X       = 65
    local CF_OFFSET_Y       = -29

    local button = CreateFrame("Button", "PierreFoyerCharacterFrameButton", CharacterFrame)
    button:SetHeight(28)
    button:SetWidth(28)
    button:SetFrameStrata("HIGH")
    button:SetPoint(CF_ANCHOR, CharacterFrame, CF_RELATIVE_POINT, CF_OFFSET_X, CF_OFFSET_Y)

    button:SetNormalTexture("Interface\\Icons\\INV_Misc_Rune_01")
    button:SetPushedTexture("Interface\\Icons\\INV_Misc_Rune_01")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    local pushedTex = button:GetPushedTexture()
    pushedTex:SetTexCoord(0.05, 0.95, 0.05, 0.95)

    button:Hide()
    PaperDollFrame:HookScript("OnShow", function() button:Show() end)
    PaperDollFrame:HookScript("OnHide", function() button:Hide() end)
    if PaperDollFrame:IsShown() then button:Show() end

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L.buttonTooltipTitle, 1, 1, 1)
        GameTooltip:AddLine(L.buttonTooltipLine, 1, 0.82, 0, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    button:SetScript("OnMouseDown", function(self, mouseButton)
        if IsShiftKeyDown() then
            self:StartMoving()
        end
    end)
    button:SetScript("OnMouseUp", function(self)
        self:StopMovingOrSizing()
    end)

    button:SetScript("OnClick", function(self, mouseButton)
        if IsShiftKeyDown() then return end
        if frame:IsShown() then
            frame:Hide()
        else
            frame:Show()
        end
    end)
end

AIO.AddHandlers("PierreFoyer", {
    Result = function(player, message, r, g, b)
        UIErrorsFrame:AddMessage(message, r or 1, g or 0.82, b or 0, 1, 3.5)
    end,
})

AIO.Handle("PierreFoyer", "SetLocale", GetLocale())
