local AIO = AIO or require("AIO")
if AIO.AddAddon() then return end

local WarModeHandlers = AIO.AddHandlers("WarMode", {})

local UI_LOCALE = (GetLocale and GetLocale() == "enUS") and "enUS" or "frFR"

local Locales = {
    frFR = {
        TITLE = "Mode Guerre",
        STATUS_LABEL_DISABLED = "Statut: |cffff0000Désactivé|r",
        STATUS_LABEL_ENABLED = "Statut: |cff00ff00Activé|r",
        DESC_TITLE = "Bonus du Mode Guerre",
        BONUS_XP = "|cff00ff00+10%|r Expérience",
        BONUS_GOLD = "|cff00ff00+10%|r Or des loots",
        WARNING = "|cffff9900Attention:|r Activer le mode guerre vous rendra PvP en permanence dans le monde ouvert.",
        BTN_DISABLE = "Désactiver",
        BTN_ENABLE = "Activer",
        CHAT_PREFIX = "[Mode Guerre]",
        ENABLED_CHAT_MSG = "|cFF00FF00Mode Guerre activé:|r Bonus d'XP et d'or de 10%.",
    },
    enUS = {
        TITLE = "War Mode",
        STATUS_LABEL_DISABLED = "Status: |cffff0000Disabled|r",
        STATUS_LABEL_ENABLED = "Status: |cff00ff00Enabled|r",
        DESC_TITLE = "War Mode Bonuses",
        BONUS_XP = "|cff00ff00+10%|r Experience",
        BONUS_GOLD = "|cff00ff00+10%|r Loot Gold",
        WARNING = "|cffff9900Warning:|r Activating War Mode will flag you as permanently PvP-enabled in the open world.",
        BTN_DISABLE = "Disable",
        BTN_ENABLE = "Enable",
        CHAT_PREFIX = "[War Mode]",
        ENABLED_CHAT_MSG = "|cFF00FF00War Mode enabled:|r 10% XP and gold bonus.",
    },
}

local L = Locales[UI_LOCALE] or Locales.frFR

local WarModeFrame = nil
local isInitialized = false
local isWarModeActive = false

-- Sons
local SOUND_ACTIVATE = "Sound\\Interface\\igMainMenuOptionCheckBoxOn.wav"
local SOUND_DEACTIVATE = "Sound\\Interface\\igMainMenuOptionCheckBoxOff.wav"

-- Icône selon la faction (icônes d'origine, présentes depuis les tout premiers clients, donc garanties dans le 3.3.5)
local function GetFactionIcon()
    local faction = UnitFactionGroup("player")
    if faction == "Horde" then
        return "Interface\\Icons\\pvpcurrency-honor-horde"
    else
        return "Interface\\Icons\\pvpcurrency-honor-alliance"
    end
end

-- Couleur d'accent selon la faction (bleu Alliance / rouge Horde)
local function GetFactionColor()
    local faction = UnitFactionGroup("player")
    if faction == "Horde" then
        return 1, 0.25, 0.2
    else
        return 0.2, 0.55, 1
    end
end

-- Fonction pour créer l'interface War Mode
local function CreateWarModeFrame()
    if WarModeFrame then
        return WarModeFrame
    end

    -- Frame principal avec backdrop natif (méthode standard Blizzard, la plus fiable)
    local frame = CreateFrame("Frame", "WarModeFrame", UIParent)
    frame:SetSize(360, 420)
    frame:SetPoint("CENTER", 0, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    frame:Hide()

    -- Bandeau titre (même technique que Mod Me Panel : UI-DialogBox-Header)
    local header = frame:CreateTexture(nil, "ARTWORK")
    header:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
    header:SetSize(280, 64)
    header:SetPoint("TOP", frame, "TOP", 0, 12)

    -- Titre
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.title:SetPoint("CENTER", header, "CENTER", 0, 12)
    frame.title:SetText(L.TITLE)

    -- Bouton de fermeture
    local xButton = CreateFrame("Button", nil, frame)
    xButton:SetSize(28, 28)
    xButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    xButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    xButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    xButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
    xButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    -- Conteneur principal
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", 20, -66)
    content:SetPoint("BOTTOMRIGHT", -20, 65)

    -- Cadre autour de l'icône (backdrop bordure tooltip, technique 100% native)
    local iconHolder = CreateFrame("Frame", nil, content)
    iconHolder:SetSize(72, 72)
    iconHolder:SetPoint("TOP", content, "TOP", 0, -6)
    iconHolder:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
    })
    frame.iconHolder = iconHolder

    -- Icône War Mode (selon la faction du joueur)
    frame.icon = iconHolder:CreateTexture(nil, "ARTWORK")
    frame.icon:SetTexture(GetFactionIcon())
    frame.icon:SetSize(60, 60)
    frame.icon:SetPoint("CENTER", iconHolder, "CENTER", 0, 0)
    frame.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Petit badge PvP affiché en bas à droite de l'icône quand le mode est actif
    frame.pvpBadge = content:CreateTexture(nil, "OVERLAY")
    frame.pvpBadge:SetTexture("Interface\\CharacterFrame\\UI-Party-PVP-Icon")
    frame.pvpBadge:SetSize(22, 22)
    frame.pvpBadge:SetPoint("BOTTOMRIGHT", iconHolder, "BOTTOMRIGHT", 6, -4)
    frame.pvpBadge:Hide()

    -- Statut
    frame.statusLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.statusLabel:SetPoint("TOP", iconHolder, "BOTTOM", 0, -14)
    frame.statusLabel:SetShadowOffset(1, -1)
    frame.statusLabel:SetText(L.STATUS_LABEL_DISABLED)

    -- Ligne de séparation (simple bande de couleur unie, pas de texture décorative étirée)
    local midDivider = content:CreateTexture(nil, "ARTWORK")
    midDivider:SetTexture("Interface\\Buttons\\WHITE8X8")
    midDivider:SetVertexColor(0.5, 0.42, 0.3, 0.6)
    midDivider:SetHeight(1)
    midDivider:SetPoint("TOP", frame.statusLabel, "BOTTOM", 0, -10)
    midDivider:SetWidth(280)

    -- Description
    frame.descTitle = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.descTitle:SetPoint("TOP", midDivider, "BOTTOM", 0, -10)
    frame.descTitle:SetText(L.DESC_TITLE)

    -- Ligne bonus XP (icône + texte)
    local xpRow = CreateFrame("Frame", nil, content)
    xpRow:SetSize(180, 20)
    xpRow:SetPoint("TOP", frame.descTitle, "BOTTOM", 0, -12)

    local xpIcon = xpRow:CreateTexture(nil, "ARTWORK")
    xpIcon:SetTexture("Interface\\Icons\\xp_icon")
    xpIcon:SetSize(20, 20)
    xpIcon:SetPoint("LEFT", xpRow, "LEFT", 0, 0)
    xpIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    frame.bonusXP = xpRow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.bonusXP:SetPoint("LEFT", xpIcon, "RIGHT", 6, 0)
    frame.bonusXP:SetText(L.BONUS_XP)

    -- Ligne bonus Or (icône + texte)
    local goldRow = CreateFrame("Frame", nil, content)
    goldRow:SetSize(180, 20)
    goldRow:SetPoint("TOP", xpRow, "BOTTOM", 0, -8)

    local goldIcon = goldRow:CreateTexture(nil, "ARTWORK")
    goldIcon:SetTexture("Interface\\Icons\\INV_Misc_Coin_02")
    goldIcon:SetSize(20, 20)
    goldIcon:SetPoint("LEFT", goldRow, "LEFT", 0, 0)
    goldIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    frame.bonusGold = goldRow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.bonusGold:SetPoint("LEFT", goldIcon, "RIGHT", 6, 0)
    frame.bonusGold:SetText(L.BONUS_GOLD)

    -- Encadré d'avertissement PvP (backdrop tooltip standard, combo confirmé dans le FrameXML Blizzard)
    local warnFrame = CreateFrame("Frame", nil, content)
    warnFrame:SetSize(300, 44)
    warnFrame:SetPoint("TOP", goldRow, "BOTTOM", 0, -16)
    warnFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    warnFrame:SetBackdropColor(0.35, 0.08, 0.05, 0.6)

    frame.warning = warnFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.warning:SetPoint("CENTER", warnFrame, "CENTER", 0, 0)
    frame.warning:SetWidth(280)
    frame.warning:SetWordWrap(true)
    frame.warning:SetJustifyH("CENTER")
    frame.warning:SetText(L.WARNING)

    -- Bouton Activer/Désactiver
    frame.toggleButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.toggleButton:SetSize(120, 36)
    frame.toggleButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 20)
    frame.toggleButton:SetNormalFontObject("GameFontNormalLarge")
    frame.toggleButton:SetHighlightFontObject("GameFontHighlightLarge")

    frame.toggleButton:SetScript("OnClick", function()
        local activate = not isWarModeActive
        AIO.Handle("WarMode", "ToggleWarMode", activate)

        if activate then
            PlaySoundFile(SOUND_ACTIVATE)
        else
            PlaySoundFile(SOUND_DEACTIVATE)
        end
    end)

    WarModeFrame = frame

    tinsert(UISpecialFrames, "WarModeFrame")

    return frame
end

-- Fonction pour mettre à jour l'affichage
local function UpdateDisplay()
    if not WarModeFrame then return end

    if isWarModeActive then
        WarModeFrame.statusLabel:SetText(L.STATUS_LABEL_ENABLED)
        WarModeFrame.toggleButton:SetText(L.BTN_DISABLE)
        WarModeFrame.icon:SetDesaturated(false)
        WarModeFrame.pvpBadge:Show()
        WarModeFrame.iconHolder:SetBackdropBorderColor(GetFactionColor())
    else
        WarModeFrame.statusLabel:SetText(L.STATUS_LABEL_DISABLED)
        WarModeFrame.toggleButton:SetText(L.BTN_ENABLE)
        WarModeFrame.icon:SetDesaturated(true)
        WarModeFrame.pvpBadge:Hide()
        WarModeFrame.iconHolder:SetBackdropBorderColor(1, 1, 1, 1)
    end
end

-- Handler pour initialiser
function WarModeHandlers.Initialize(player, active)
    if not isInitialized then
        isInitialized = true
        -- print("|cFF00FF00War Mode|r chargé. Tapez |cFFFFFF00/warmode|r ou |cFFFFFF00/wm|r pour ouvrir.")
    end

    isWarModeActive = active

    if active then
        print(L.ENABLED_CHAT_MSG)
    end
end

-- Handler pour afficher le panel
function WarModeHandlers.ShowPanel()
    local frame = CreateWarModeFrame()
    UpdateDisplay()

    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        AIO.Handle("WarMode", "RequestStatus")
    end
end

-- Handler pour mettre à jour le statut
function WarModeHandlers.UpdateStatus(player, active)
    isWarModeActive = active
    UpdateDisplay()
end

-- Handler pour afficher un message
function WarModeHandlers.ShowMessage(player, message, isError)
    if isError then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000" .. L.CHAT_PREFIX .. "|r " .. message)
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. L.CHAT_PREFIX .. "|r " .. message)
    end
end

-- Commandes slash
SLASH_WARMODE1 = "/warmode"
SLASH_WARMODE2 = "/wm"
SlashCmdList["WARMODE"] = function(msg)
    AIO.Handle("WarMode", "ShowPanel")
end
