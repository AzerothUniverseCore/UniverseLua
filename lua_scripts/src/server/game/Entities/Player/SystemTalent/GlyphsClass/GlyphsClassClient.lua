local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local GlyphsClassHandlers = AIO.AddHandlers("GlyphsClass", {})

-- Crée l'icône qui ouvrira la fenêtre des glyphes
local iconOpenGlyphWindow = CreateFrame("Button", "iconOpenGlyphWindow", UIParent, "SecureActionButtonTemplate")
iconOpenGlyphWindow:SetSize(40, 40)
iconOpenGlyphWindow:SetPoint("BOTTOMRIGHT", -110, 85)
iconOpenGlyphWindow:SetNormalTexture("Interface/icons/ability_dragonriding_glyph01")
iconOpenGlyphWindow:SetAttribute("type", "macro")
iconOpenGlyphWindow:SetAttribute("macrotext", "/click buttonOpenGlyphWindow")

-- Crée le bouton invisible qui sera cliqué par l'icône des glyphes
local buttonOpenGlyphWindow = CreateFrame("Button", "buttonOpenGlyphWindow", UIParent, "UIPanelButtonTemplate")
buttonOpenGlyphWindow:SetText("Glyphes")
buttonOpenGlyphWindow:SetSize(1, 1)
buttonOpenGlyphWindow:SetPoint("BOTTOMRIGHT", -130, 85)

-- Fonction pour ouvrir la fenêtre des glyphes
local function OpenGlyphWindow()
    Talented:ToggleGlyphFrame()
end

buttonOpenGlyphWindow:SetScript("OnClick", OpenGlyphWindow)