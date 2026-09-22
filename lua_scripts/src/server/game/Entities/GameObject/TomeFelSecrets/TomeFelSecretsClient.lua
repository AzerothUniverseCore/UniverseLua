local AIO = AIO or require("AIO")
if AIO.AddAddon() then return end

-- =====================================================================
-- LOCALISATION
-- =====================================================================

local LOCALES =
{
    frFR = {
        TITLE          = "Tome des secrets gangrenés",
        SHARD_LABEL    = "Éclat du gardien des pierres",
        CRYSTAL_LABEL  = "Cristaux d'infusion",
        STATUS_OBTAINED  = "|cff00ff00Déjà obtenu|r",
        STATUS_AVAILABLE = "|cffffd200Coût :|r",
        ERROR_COST     = "Monnaie insuffisante pour cet équipement légendaire.",
        ERROR_ALREADY  = "Vous possédez déjà cet équipement légendaire.",
        SUCCESS        = "Équipement légendaire obtenu !",
        SLASH_HINT     = "",
    },
    enUS = {
        TITLE          = "Tome of Fel Secrets",
        SHARD_LABEL    = "Guardian's Stone Shard",
        CRYSTAL_LABEL  = "Infusion Crystals",
        STATUS_OBTAINED  = "|cff00ff00Already obtained|r",
        STATUS_AVAILABLE = "|cffffd200Cost:|r",
        ERROR_COST     = "Not enough currency for this legendary item.",
        ERROR_ALREADY  = "You already own this legendary item.",
        SUCCESS        = "Legendary item obtained!",
        SLASH_HINT     = "",
    },
}

local L = LOCALES[GetLocale()] or LOCALES.enUS

-- =====================================================================
-- ASSETS
-- =====================================================================

local ADDON_PATH = "Interface\\TomeFelSecrets\\"

local PANEL_TEXTURE   = ADDON_PATH .. "TomeFelSecrets.blp"
local RING_TEX_BROWN  = ADDON_PATH .. "TomeFelSecrets_Circle_Brown.blp"
local RING_TEX_YELLOW = ADDON_PATH .. "TomeFelSecrets_Circle_Yellow.blp"
local RING_TEX_PURPLE = ADDON_PATH .. "TomeFelSecrets_Circle_Purple.blp"

local SOUND_OPEN    = "Sound\\TalentsSystem\\ui_9_0_covenant_ability_ability_button_placed.ogg"
local SOUND_CLOSE   = "Sound\\TalentsSystem\\ui_9_0_covenant_ability_ability_button_appears.ogg"
local SOUND_SUCCESS = "Sound\\TalentsSystem\\ui_70_artifact_forge_apperancechange_03.ogg"
local SOUND_FAIL    = "Sound\\TalentsSystem\\ui_70_artifact_forge_apperancelocked_01.ogg"

local PANEL_SIZE  = 512
local SLOT_SIZE    = 76
local ICON_SIZE    = 44

local SLOT_Y_OFFSET = 47
local SLOT_X_OFFSET = 2

local SLOTS =
{
    -- Wings
    { id = 200015, px = 95,  py = 132, ring = RING_TEX_PURPLE }, -- Jina-Kang, Gentillesse de Chi-Ji
    { id = 200016, px = 253, py = 132, ring = RING_TEX_PURPLE }, -- Xing-Ho, Souffle de Yu'lon
    { id = 200017, px = 418, py = 132, ring = RING_TEX_PURPLE }, -- Qian-Le, Courage de Niuzao
    { id = 200018, px = 253, py = 261, ring = RING_TEX_PURPLE }, -- Gong-Lu, Force de Xuen

    -- Rings
    { id = 8850542, px = 174, py = 261, ring = RING_TEX_YELLOW }, -- Khadgar
    { id = 8850543, px = 337, py = 261, ring = RING_TEX_BROWN  }, -- Garrosh Hurlenfer
    { id = 8850544, px = 95,  py = 386, ring = RING_TEX_YELLOW }, -- Rexxar
    { id = 8850545, px = 253, py = 386, ring = RING_TEX_BROWN  }, -- Tirion Fordring
    { id = 8850552, px = 418, py = 386, ring = RING_TEX_YELLOW }, -- Malfurion Hurlorage
}

-- =====================================================================
-- HELPERS ICONES
-- =====================================================================

local QUESTIONMARK_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

local function GetIconForItem(itemId)
    local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(itemId)
    return texture or QUESTIONMARK_ICON
end

local BOTTOM_EXTRA = 72

local FRAME_W = PANEL_SIZE
local FRAME_H = PANEL_SIZE + BOTTOM_EXTRA

local TomeFelSecretsFrame = CreateFrame("Frame", "TomeFelSecretsFrame", UIParent)
TomeFelSecretsFrame:SetSize(FRAME_W, FRAME_H)
TomeFelSecretsFrame:SetPoint("CENTER", 0, 10)
TomeFelSecretsFrame:SetFrameStrata("FULLSCREEN_DIALOG")
TomeFelSecretsFrame:EnableMouse(true)
TomeFelSecretsFrame:SetMovable(true)
TomeFelSecretsFrame:RegisterForDrag("LeftButton")
TomeFelSecretsFrame:SetScript("OnDragStart", TomeFelSecretsFrame.StartMoving)
TomeFelSecretsFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    if AIO.SavePosition then AIO.SavePosition(self) end
end)
TomeFelSecretsFrame:SetScript("OnHide", function() PlaySoundFile(SOUND_CLOSE) end)
TomeFelSecretsFrame:Hide()

if AIO.SavePosition then AIO.SavePosition(TomeFelSecretsFrame) end
tinsert(UISpecialFrames, "TomeFelSecretsFrame")

local panel = TomeFelSecretsFrame:CreateTexture(nil, "ARTWORK")
panel:SetSize(PANEL_SIZE, PANEL_SIZE)
panel:SetPoint("TOPLEFT", 0, 0)
panel:SetTexture(PANEL_TEXTURE)

local title = TomeFelSecretsFrame:CreateFontString(nil, "OVERLAY")
title:SetFont("Fonts\\MORPHEUS.TTF", 18, "OUTLINE")
title:SetPoint("TOP", 0, -25)
title:SetTextColor(1, 1, 1)
title:SetText(L.TITLE)

local closeBtn = CreateFrame("Button", nil, TomeFelSecretsFrame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -46, -112)
closeBtn:SetScript("OnClick", function() TomeFelSecretsFrame:Hide() end)

local CURRENCY_Y = 87

local CURRENCY_SHARD_X   = -110
local CURRENCY_CRYSTAL_X = 60

local currencyShardIcon = TomeFelSecretsFrame:CreateTexture(nil, "OVERLAY")
currencyShardIcon:SetSize(20, 20)
currencyShardIcon:SetPoint("BOTTOM", TomeFelSecretsFrame, "BOTTOM", CURRENCY_SHARD_X, CURRENCY_Y)

local currencyShardText = TomeFelSecretsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
currencyShardText:SetPoint("LEFT", currencyShardIcon, "RIGHT", 6, 0)

local currencyCrystalIcon = TomeFelSecretsFrame:CreateTexture(nil, "OVERLAY")
currencyCrystalIcon:SetSize(20, 20)
currencyCrystalIcon:SetPoint("BOTTOM", TomeFelSecretsFrame, "BOTTOM", CURRENCY_CRYSTAL_X, CURRENCY_Y)

local currencyCrystalText = TomeFelSecretsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
currencyCrystalText:SetPoint("LEFT", currencyCrystalIcon, "RIGHT", 6, 0)

local function CreateCurrencyHover(icon, getEntry)
    local hover = CreateFrame("Frame", nil, TomeFelSecretsFrame)
    hover:SetPoint("LEFT", icon, "LEFT", 0, 0)
    hover:SetSize(90, 24)
    hover:EnableMouse(true)
    hover:SetScript("OnEnter", function(self)
        local entry = getEntry()
        if not entry then return end
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetHyperlink("item:" .. entry)
        GameTooltip:Show()
    end)
    hover:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return hover
end

CreateCurrencyHover(currencyShardIcon, function() return TomeFelSecretsFrame.currency.shardEntry end)
CreateCurrencyHover(currencyCrystalIcon, function() return TomeFelSecretsFrame.currency.crystalEntry end)

local hint = TomeFelSecretsFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
hint:SetPoint("BOTTOM", 0, 12)
hint:SetText(L.SLASH_HINT)

-- =====================================================================
-- SLOTS CIRCLE
-- =====================================================================

TomeFelSecretsFrame.buttons = {}
TomeFelSecretsFrame.data = {}
TomeFelSecretsFrame.currency = {}

local function UpdateTooltip(button)
    local itemId = button.itemId
    local data = TomeFelSecretsFrame.data[itemId]
    if not data then return end

    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    GameTooltip:SetHyperlink("item:" .. itemId)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(data.desc, 1, 1, 1, true)
    GameTooltip:AddLine(" ")

    if data.obtained then
        GameTooltip:AddLine(L.STATUS_OBTAINED)
    else
        local currency = TomeFelSecretsFrame.currency
        local haveShard = (currency.shardCount or 0) >= (currency.shardCost or 0)
        local haveCrystal = (currency.crystalCount or 0) >= (currency.crystalCost or 0)
        GameTooltip:AddLine(L.STATUS_AVAILABLE)
        GameTooltip:AddDoubleLine(L.SHARD_LABEL,
            string.format("%d / %d", currency.shardCount or 0, currency.shardCost or 0),
            1, 1, 1, haveShard and 0 or 1, haveShard and 1 or 0, 0)
        GameTooltip:AddDoubleLine(L.CRYSTAL_LABEL,
            string.format("%d / %d", currency.crystalCount or 0, currency.crystalCost or 0),
            1, 1, 1, haveCrystal and 0 or 1, haveCrystal and 1 or 0, 0)
    end

    GameTooltip:Show()
end

local function CreateItemSlot(slot)
    local itemId = slot.id
    local button = CreateFrame("Button", "TomeFelSecretsButton" .. itemId, TomeFelSecretsFrame)
    button:SetSize(SLOT_SIZE, SLOT_SIZE)

    local xOfs = slot.px - SLOT_SIZE / 2 + SLOT_X_OFFSET
    local yOfs = -(slot.py - SLOT_SIZE / 2) - SLOT_Y_OFFSET
    button:SetPoint("TOPLEFT", xOfs, yOfs)
    button.itemId = itemId

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("CENTER")
    icon:SetSize(ICON_SIZE, ICON_SIZE)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    icon:SetTexture(GetIconForItem(itemId))
    button.icon = icon

    local ring = button:CreateTexture(nil, "OVERLAY")
    ring:SetAllPoints(button)
    ring:SetTexture(slot.ring)
    button.ring = ring

    local check = button:CreateTexture(nil, "OVERLAY", nil, 1)
    check:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
    check:SetSize(20, 20)
    check:SetPoint("BOTTOMRIGHT", 4, -2)
    check:Hide()
    button.check = check

    button.pulsePhase = math.random() * 6.28

    button:SetScript("OnEnter", UpdateTooltip)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:SetScript("OnClick", function(self)
        local data = TomeFelSecretsFrame.data[self.itemId]
        if data and not data.obtained then
            AIO.Handle("TomeFelSecrets", "RequestObtain", self.itemId)
        end
    end)

    return button
end

for _, slot in ipairs(SLOTS) do
    TomeFelSecretsFrame.buttons[slot.id] = CreateItemSlot(slot)
end

local pulseElapsed = 0
TomeFelSecretsFrame:SetScript("OnUpdate", function(self, elapsed)
    pulseElapsed = pulseElapsed + elapsed
    for _, button in pairs(self.buttons) do
        local data = self.data[button.itemId]
        if not data or not data.obtained then
            button.ring:SetAlpha(0.78 + 0.22 * math.sin(pulseElapsed * 2 + button.pulsePhase))
        end
    end
end)

-- =====================================================================
-- UPDATE DISPLAY
-- =====================================================================

local function RefreshCurrencyText()
    local c = TomeFelSecretsFrame.currency
    local shardColor = (c.shardCount or 0) >= (c.shardCost or 0) and "|cff00ff00" or "|cffff2020"
    local crystalColor = (c.crystalCount or 0) >= (c.crystalCost or 0) and "|cff00ff00" or "|cffff2020"

    if c.shardEntry then currencyShardIcon:SetTexture(GetIconForItem(c.shardEntry)) end
    if c.crystalEntry then currencyCrystalIcon:SetTexture(GetIconForItem(c.crystalEntry)) end

    currencyShardText:SetText(string.format("%s%d / %d|r", shardColor, c.shardCount or 0, c.shardCost or 0))
    currencyCrystalText:SetText(string.format("%s%d / %d|r", crystalColor, c.crystalCount or 0, c.crystalCost or 0))
end

local function PopulateFrame(items, currency)
    TomeFelSecretsFrame.currency = currency or {}

    for _, item in ipairs(items) do
        TomeFelSecretsFrame.data[item.id] = item

        local button = TomeFelSecretsFrame.buttons[item.id]
        if button then
            button.icon:SetTexture(GetIconForItem(item.id))
            if item.obtained then
                button.icon:SetDesaturated(true)
                button.ring:SetVertexColor(0.5, 0.5, 0.5)
                button.ring:SetAlpha(1)
                button.check:Show()
            else
                button.icon:SetDesaturated(false)
                button.ring:SetVertexColor(1, 1, 1)
                button.check:Hide()
            end
        end
    end

    RefreshCurrencyText()
end

local function RefreshAllIcons()
    for itemId, button in pairs(TomeFelSecretsFrame.buttons) do
        button.icon:SetTexture(GetIconForItem(itemId))
    end
    if TomeFelSecretsFrame.currency.shardEntry then
        currencyShardIcon:SetTexture(GetIconForItem(TomeFelSecretsFrame.currency.shardEntry))
    end
    if TomeFelSecretsFrame.currency.crystalEntry then
        currencyCrystalIcon:SetTexture(GetIconForItem(TomeFelSecretsFrame.currency.crystalEntry))
    end
end

local iconWatcher = CreateFrame("Frame")
iconWatcher:RegisterEvent("GET_ITEM_INFO_RECEIVED")
iconWatcher:SetScript("OnEvent", function(self, event, itemId, success)
    if success and TomeFelSecretsFrame:IsShown() then
        RefreshAllIcons()
    end
end)

-- =====================================================================
-- HANDLERS AIO
-- =====================================================================

local TomeFelSecretsHandlers = AIO.AddHandlers("TomeFelSecrets", {})

function TomeFelSecretsHandlers.OpenFrame(player, items, currency)
    PopulateFrame(items, currency)
    TomeFelSecretsFrame:Show()
    PlaySoundFile(SOUND_OPEN)
end

function TomeFelSecretsHandlers.Refresh(player, items, currency)
    PopulateFrame(items, currency)
end

function TomeFelSecretsHandlers.ObtainResult(player, itemId, success, reason)
    if success then
        PlaySoundFile(SOUND_SUCCESS)
        UIErrorsFrame:AddMessage(L.SUCCESS, 0, 1, 0)
    else
        PlaySoundFile(SOUND_FAIL)
        if reason == "cost" then
            UIErrorsFrame:AddMessage(L.ERROR_COST, 1, 0.1, 0.1)
        elseif reason == "already" then
            UIErrorsFrame:AddMessage(L.ERROR_ALREADY, 1, 0.1, 0.1)
        end
    end
end

-- =====================================================================
-- SLASH COMMAND
-- =====================================================================

SLASH_TOMEFELSECRETS1 = "/tomefel"
SlashCmdList["TOMEFELSECRETS"] = function()
    if TomeFelSecretsFrame:IsShown() then
        TomeFelSecretsFrame:Hide()
    else
        AIO.Handle("TomeFelSecrets", "RequestOpen")
    end
end
