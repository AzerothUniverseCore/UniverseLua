local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

local REVIVE_HANDLER_NAME = "Revive"

local ReviveHandlers = AIO.AddHandlers(REVIVE_HANDLER_NAME, {})

----------------------------------------------------------------------------
-- Localisation (frFR / enUS)
----------------------------------------------------------------------------
local LOCALES = {
    frFR = {
        TITLE          = "Vous avez succombé",
        DESC           = "Ressusciter sur place.",
        CHARGES_LEFT   = "Résurrections restantes : %d/%d\nRéinitialisation dans %s",
        NO_CHARGE_LEFT = "Plus de résurrection disponible\nProchaine dans %s",
        NO_CHARGE_MSG  = "Plus de résurrection disponible pour le moment.",
        AVAILABLE      = "Disponible",
        BTN_REVIVE     = "Ressusciter",
    },
    enUS = {
        TITLE          = "You are dead",
        DESC           = "Resurrect immediately on the spot.",
        CHARGES_LEFT   = "Resurrections remaining: %d/%d\nResets in %s",
        NO_CHARGE_LEFT = "No resurrection available\nNext in %s",
        NO_CHARGE_MSG  = "No resurrection available right now.",
        AVAILABLE      = "available",
        BTN_REVIVE     = "Resurrect",
    },
}

local L = LOCALES[GetLocale()] or LOCALES.enUS

----------------------------------------------------------------------------
-- Etat local (mis a jour par le serveur)
----------------------------------------------------------------------------
local currentCharges   = 0
local maxCharges        = 10
local nextResetSeconds = 0
local lastUpdateClock  = 0

----------------------------------------------------------------------------
-- Construction de l'interface
----------------------------------------------------------------------------
local frame = CreateFrame("Frame", "ReviveFrame", UIParent)
frame:SetSize(280, 150)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 80)
frame:SetFrameStrata("DIALOG")
frame:SetToplevel(true)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetClampedToScreen(true)
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
AIO.SavePosition(frame)

frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 11, top = 11, bottom = 11 },
})

local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", frame, "TOP", 0, -18)
title:SetText(L.TITLE)

local desc = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
desc:SetPoint("TOP", title, "BOTTOM", 0, -10)
desc:SetWidth(240)
desc:SetText(L.DESC)

local status = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
status:SetPoint("TOP", desc, "BOTTOM", 0, -12)
status:SetWidth(240)

local reviveButton = CreateFrame("Button", "ReviveButton", frame, "UIPanelButtonTemplate")
reviveButton:SetSize(160, 30)
reviveButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 20)
reviveButton:SetText(L.BTN_REVIVE)

frame:Hide()

----------------------------------------------------------------------------
-- Mise a jour de l'affichage (charges restantes + minuteur de reset)
----------------------------------------------------------------------------
local function FormatTime(seconds)
    if seconds <= 0 then
        return L.AVAILABLE
    end
    local m = math.floor(seconds / 60)
    local s = seconds % 60
    return string.format("%02d:%02d", m, s)
end

local function RefreshStatusText()
    local elapsed = GetTime() - lastUpdateClock
    local remaining = math.max(0, nextResetSeconds - elapsed)

    if currentCharges > 0 then
        status:SetText(string.format(L.CHARGES_LEFT, currentCharges, maxCharges, FormatTime(remaining)))
        reviveButton:Enable()
    else
        status:SetText(string.format(L.NO_CHARGE_LEFT, FormatTime(remaining)))
        reviveButton:Disable()
    end
end

frame:SetScript("OnUpdate", function(self, elapsed)
    self.tick = (self.tick or 0) + elapsed
    if self.tick < 1 then return end
    self.tick = 0
    if self:IsShown() then
        RefreshStatusText()
    end
end)

----------------------------------------------------------------------------
-- Handlers serveur -> client
----------------------------------------------------------------------------
function ReviveHandlers.UpdateStatus(player, count, secondsLeft, max)
    currentCharges = count or 0
    nextResetSeconds = secondsLeft or 0
    maxCharges = max or maxCharges
    lastUpdateClock = GetTime()
    RefreshStatusText()
end

function ReviveHandlers.ReviveResult(player, success, reason)
    if success then
        frame:Hide()
    elseif reason == "NO_CHARGES" then
        status:SetText(L.NO_CHARGE_MSG)
    end
end

----------------------------------------------------------------------------
-- Bouton
----------------------------------------------------------------------------
reviveButton:SetScript("OnClick", function()
    AIO.Handle(REVIVE_HANDLER_NAME, "RequestRevive")
end)

----------------------------------------------------------------------------
-- Detection de la mort (evenements client standards)
----------------------------------------------------------------------------
local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_DEAD")
watcher:RegisterEvent("PLAYER_ALIVE")
watcher:RegisterEvent("PLAYER_UNGHOST")
watcher:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_DEAD" then
        AIO.Handle(REVIVE_HANDLER_NAME, "RequestStatus")
        frame:Show()
    else
        frame:Hide()
    end
end)
