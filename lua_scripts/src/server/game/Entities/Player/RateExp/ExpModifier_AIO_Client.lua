-- ExpModifier_AIO_Client.lua
local AIO = AIO or require("AIO");

if AIO.AddAddon() then
    return
end

local h_expmodifier = AIO.AddHandlers("h_expmodifier", {});

-- ============================================================
--  LOCALE frFR / enUS
-- ============================================================
local UI_LOCALE = (GetLocale and GetLocale() == "enUS") and "enUS" or "frFR"

local Locales = {
    frFR = {
        TITLE = "Multiplicateur d'expérience",
        DESC = "Vous permet de modifier votre multiplicateur d'expérience.\n\nCela vous permettra d'acquérir plus d'expérience ou moins, c'est selon votre choix.",
        CURRENT_RATE_LABEL = "|CFFa8a8ffVotre multiplicateur actuel : ",
        BTN_X1 = "Multiplicateur x1",
        BTN_X2 = "Multiplicateur x2",
        BTN_X3 = "Multiplicateur x3",
        BTN_X4 = "|cffFFD700Multiplicateur x4|r",
        BTN_X5 = "|cffFFD700Multiplicateur x5|r",
        CLOSE = "Fermer",
        TOOLTIP_TITLE = "|cffFFC125Multiplicateur d'expérience|r",
        TOOLTIP_DESC = "Cliquez ici pour modifier votre multiplicateur d'expérience.",
    },
    enUS = {
        TITLE = "Experience Multiplier",
        DESC = "Lets you change your experience multiplier.\n\nThis will let you gain more or less experience, depending on your choice.",
        CURRENT_RATE_LABEL = "|CFFa8a8ffYour current multiplier: ",
        BTN_X1 = "Multiplier x1",
        BTN_X2 = "Multiplier x2",
        BTN_X3 = "Multiplier x3",
        BTN_X4 = "|cffFFD700Multiplier x4|r",
        BTN_X5 = "|cffFFD700Multiplier x5|r",
        CLOSE = "Close",
        TOOLTIP_TITLE = "|cffFFC125Experience Multiplier|r",
        TOOLTIP_DESC = "Click here to change your experience multiplier.",
    },
}

local L = Locales[UI_LOCALE] or Locales.frFR


local OPEN_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_70_artifact_forge_relic_place.ogg"
local CLOSE_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_trait_refund_start.ogg"

local f_expmodifier = CreateFrame("Frame", "f_expmodifier", UIParent, "UIPanelDialogTemplate");

f_expmodifier:SetSize(250, 460);
f_expmodifier:RegisterForDrag("LeftButton");
f_expmodifier:SetPoint("CENTER");
f_expmodifier:SetToplevel(true);
f_expmodifier:SetClampedToScreen(true);
-- Enable dragging of frame
f_expmodifier:SetMovable(true);
f_expmodifier:EnableMouse(true);
f_expmodifier:SetScript("OnDragStart", f_expmodifier.StartMoving);
f_expmodifier:SetScript("OnHide", function(self)
    self:StopMovingOrSizing()
    PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
end);
f_expmodifier:SetScript("OnDragStop", f_expmodifier.StopMovingOrSizing);
f_expmodifier:Hide();
tinsert(UISpecialFrames, "f_expmodifier")

local f_expmodifier_TitleBar = f_expmodifier:CreateFontString("f_expmodifier_TitleBar", "OVERLAY")
f_expmodifier_TitleBar:SetFont("Fonts\\FRIZQT__.TTF", 13)
f_expmodifier_TitleBar:SetSize(190, 5)
f_expmodifier_TitleBar:SetPoint("TOP", f_expmodifier, "TOP", -5, -13)
f_expmodifier_TitleBar:SetText(L.TITLE)

local f_expmodifier_InnerText = f_expmodifier:CreateFontString("f_expmodifier_InnerText")
f_expmodifier_InnerText:SetFont("Fonts\\FRIZQT__.TTF", 12.3)
f_expmodifier_InnerText:SetSize(190, 0)
f_expmodifier_InnerText:SetPoint("CENTER", 0, 135)
f_expmodifier_InnerText:SetText(L.DESC)

local f_expmodifier_InnerText2 = f_expmodifier:CreateFontString("f_expmodifier_InnerText2")
f_expmodifier_InnerText2:SetFont("Fonts\\FRIZQT__.TTF", 12.3)
f_expmodifier_InnerText2:SetSize(190, 0)
f_expmodifier_InnerText2:SetPoint("CENTER", 0, 50)
f_expmodifier_InnerText2:SetText(L.CURRENT_RATE_LABEL)

local f_expmodifier_InnerMyRate = f_expmodifier:CreateFontString("f_expmodifier_InnerMyRate", function() AIO.Handle("h_expmodifier", "getRateModifier", 1) end)
f_expmodifier_InnerMyRate:SetFont("Fonts\\FRIZQT__.TTF", 20)
f_expmodifier_InnerMyRate:SetSize(190, 0)
f_expmodifier_InnerMyRate:SetPoint("CENTER", 0, 20)

local f_expmodifier_Button1 = CreateFrame("Button", "f_expmodifier_Button1", f_expmodifier)
f_expmodifier_Button1:SetSize(170, 30)
f_expmodifier_Button1:SetPoint("CENTER", 0, -40)
f_expmodifier_Button1:EnableMouse(true)
f_expmodifier_Button1:SetNormalTexture("Interface/BUTTONS/UI-DialogBox-Button-Up")
f_expmodifier_Button1:SetHighlightTexture("Interface/BUTTONS/UI-DialogBox-Button-Highlight")
f_expmodifier_Button1:SetPushedTexture("Interface/BUTTONS/UI-DialogBox-Button-Down")
f_expmodifier_Button1:SetScript("OnMouseUp", function() AIO.Handle("h_expmodifier", "setRateModifier", 1) end)

local f_expmodifier_Text1 = f_expmodifier_Button1:CreateFontString("f_expmodifier_Text1")
f_expmodifier_Text1:SetFont("Fonts\\FRIZQT__.TTF", 12)
f_expmodifier_Text1:SetSize(190, 10)
f_expmodifier_Text1:SetPoint("CENTER", 0, 5)
f_expmodifier_Text1:SetText(L.BTN_X1)

local f_expmodifier_Button2 = CreateFrame("Button", "f_expmodifier_Button2", f_expmodifier)
f_expmodifier_Button2:SetSize(150, 30)
f_expmodifier_Button2:SetPoint("CENTER", 0, -70)
f_expmodifier_Button2:EnableMouse(true)
f_expmodifier_Button2:SetNormalTexture("Interface/BUTTONS/UI-DialogBox-Button-Up")
f_expmodifier_Button2:SetHighlightTexture("Interface/BUTTONS/UI-DialogBox-Button-Highlight")
f_expmodifier_Button2:SetPushedTexture("Interface/BUTTONS/UI-DialogBox-Button-Down")
f_expmodifier_Button2:SetScript("OnMouseUp", function() AIO.Handle("h_expmodifier", "setRateModifier", 2) end)

local f_expmodifier_Text2 = f_expmodifier_Button2:CreateFontString("f_expmodifier_Text2")
f_expmodifier_Text2:SetFont("Fonts\\FRIZQT__.TTF", 12)
f_expmodifier_Text2:SetSize(190, 10)
f_expmodifier_Text2:SetPoint("CENTER", 0, 5)
f_expmodifier_Text2:SetText(L.BTN_X2)

local f_expmodifier_Button3 = CreateFrame("Button", "f_expmodifier_Button3", f_expmodifier)
f_expmodifier_Button3:SetSize(150, 30)
f_expmodifier_Button3:SetPoint("CENTER", 0, -100)
f_expmodifier_Button3:EnableMouse(true)
f_expmodifier_Button3:SetNormalTexture("Interface/BUTTONS/UI-DialogBox-Button-Up")
f_expmodifier_Button3:SetHighlightTexture("Interface/BUTTONS/UI-DialogBox-Button-Highlight")
f_expmodifier_Button3:SetPushedTexture("Interface/BUTTONS/UI-DialogBox-Button-Down")
f_expmodifier_Button3:SetScript("OnMouseUp", function() AIO.Handle("h_expmodifier", "setRateModifier", 3) end)

local f_expmodifier_Text3 = f_expmodifier_Button3:CreateFontString("f_expmodifier_Text3")
f_expmodifier_Text3:SetFont("Fonts\\FRIZQT__.TTF", 12)
f_expmodifier_Text3:SetSize(190, 10)
f_expmodifier_Text3:SetPoint("CENTER", 0, 5)
f_expmodifier_Text3:SetText(L.BTN_X3)

-- Bouton x4 (Premium)
local f_expmodifier_Button4 = CreateFrame("Button", "f_expmodifier_Button4", f_expmodifier)
f_expmodifier_Button4:SetSize(150, 30)
f_expmodifier_Button4:SetPoint("CENTER", 0, -130)
f_expmodifier_Button4:EnableMouse(true)
f_expmodifier_Button4:SetNormalTexture("Interface/BUTTONS/UI-DialogBox-Button-Up")
f_expmodifier_Button4:SetHighlightTexture("Interface/BUTTONS/UI-DialogBox-Button-Highlight")
f_expmodifier_Button4:SetPushedTexture("Interface/BUTTONS/UI-DialogBox-Button-Down")
f_expmodifier_Button4:SetScript("OnMouseUp", function() AIO.Handle("h_expmodifier", "setRateModifier", 4) end)
f_expmodifier_Button4:Hide() -- Caché par défaut

local f_expmodifier_Text4 = f_expmodifier_Button4:CreateFontString("f_expmodifier_Text4")
f_expmodifier_Text4:SetFont("Fonts\\FRIZQT__.TTF", 12)
f_expmodifier_Text4:SetSize(190, 10)
f_expmodifier_Text4:SetPoint("CENTER", 0, 5)
f_expmodifier_Text4:SetText(L.BTN_X4)

-- Bouton x5 (Premium)
local f_expmodifier_Button5 = CreateFrame("Button", "f_expmodifier_Button5", f_expmodifier)
f_expmodifier_Button5:SetSize(150, 30)
f_expmodifier_Button5:SetPoint("CENTER", 0, -160)
f_expmodifier_Button5:EnableMouse(true)
f_expmodifier_Button5:SetNormalTexture("Interface/BUTTONS/UI-DialogBox-Button-Up")
f_expmodifier_Button5:SetHighlightTexture("Interface/BUTTONS/UI-DialogBox-Button-Highlight")
f_expmodifier_Button5:SetPushedTexture("Interface/BUTTONS/UI-DialogBox-Button-Down")
f_expmodifier_Button5:SetScript("OnMouseUp", function() AIO.Handle("h_expmodifier", "setRateModifier", 5) end)
f_expmodifier_Button5:Hide() -- Caché par défaut

local f_expmodifier_Text5 = f_expmodifier_Button5:CreateFontString("f_expmodifier_Text5")
f_expmodifier_Text5:SetFont("Fonts\\FRIZQT__.TTF", 12)
f_expmodifier_Text5:SetSize(190, 10)
f_expmodifier_Text5:SetPoint("CENTER", 0, 5)
f_expmodifier_Text5:SetText(L.BTN_X5)

-- Bouton Fermer
local f_expmodifier_ButtonClose = CreateFrame("Button", "f_expmodifier_ButtonClose", f_expmodifier, "UIPanelCloseButton")
f_expmodifier_ButtonClose:SetSize(150, 30)
f_expmodifier_ButtonClose:SetPoint("CENTER", 0, -210)
f_expmodifier_ButtonClose:EnableMouse(true)
f_expmodifier_ButtonClose:SetNormalTexture("Interface/BUTTONS/UI-DialogBox-Button-Up")
f_expmodifier_ButtonClose:SetHighlightTexture("Interface/BUTTONS/UI-DialogBox-Button-Highlight")
f_expmodifier_ButtonClose:SetPushedTexture("Interface/BUTTONS/UI-DialogBox-Button-Down")
f_expmodifier_ButtonClose:SetScript("OnMouseUp", function() 
    f_expmodifier:Hide()
end)

local f_expmodifier_TextClose = f_expmodifier_ButtonClose:CreateFontString("f_expmodifier_TextClose")
f_expmodifier_TextClose:SetFont("Fonts\\FRIZQT__.TTF", 12)
f_expmodifier_TextClose:SetSize(190, 10)
f_expmodifier_TextClose:SetPoint("CENTER", 0, 5)
f_expmodifier_TextClose:SetText(L.CLOSE)

AIO.SavePosition(f_expmodifier);

-- ============================================================
--  BOUTON SUR LE PLAYERFRAME
--  Positionné sous le portrait du joueur (bas-gauche du cadre)
--  Le PlayerFrame fait ~119x90px. Le portrait est à TOPLEFT+7,-7.
--  On ancre le bouton sous le portrait, décalé vers le bas.
-- ============================================================
local expPlayerBtn = CreateFrame("Button", "ExpModifierPlayerFrameButton", PlayerFrame)
expPlayerBtn:SetSize(42, 42)
-- Sous le portrait, à gauche (correspond à la zone entourée en rouge)
expPlayerBtn:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", -8, 18)
expPlayerBtn:SetFrameStrata("MEDIUM")
expPlayerBtn:SetFrameLevel(10)

expPlayerBtn:SetNormalTexture("interface\\RateExpUI\\exp_button")
expPlayerBtn:SetHighlightTexture("interface\\RateExpUI\\exp_button")
expPlayerBtn:GetHighlightTexture():SetAlpha(0.4)
expPlayerBtn:SetPushedTexture("interface\\RateExpUI\\exp_button")
expPlayerBtn:GetPushedTexture():SetVertexColor(0.7, 0.7, 0.7)

expPlayerBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L.TOOLTIP_TITLE, 1, 1, 1)
    GameTooltip:AddLine(L.TOOLTIP_DESC, 0.8, 0.8, 0.8, true)
    GameTooltip:Show()
end)
expPlayerBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
expPlayerBtn:SetScript("OnClick", function()
    if f_expmodifier:IsShown() then
        f_expmodifier:Hide()
    else
        AIO.Handle("h_expmodifier", "getRateModifier", 1)
        f_expmodifier:Show()
		PlaySoundFile(OPEN_TALENT_WINDOW_SOUND)
    end
end)

function h_expmodifier.ShowFrame(player)
    f_expmodifier:Show()
end

function h_expmodifier.setMyRate(player, currentRate)
    f_expmodifier_InnerMyRate:SetText("|CFFa8a8ff "..currentRate.."")
end

-- Fonction pour afficher ou masquer les boutons premium
function h_expmodifier.setPremiumButtons(player, isPremium)
    if isPremium == 1 then
        f_expmodifier_Button4:Show()
        f_expmodifier_Button5:Show()
    else
        f_expmodifier_Button4:Hide()
        f_expmodifier_Button5:Hide()
    end
end
