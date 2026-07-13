local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local DruidHandlers = AIO.AddHandlers("FormDruidspell", {})

function DruidHandlers.ShowFormDruid(player)
    frameFormDruid:Show()
end

local OPEN_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_orderhall_talent_select.ogg"
local CLOSE_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_9_0_covenant_ability_ability_button_appears.ogg"
local SPELL_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_82_heartofazeroth_activateessenceslot_03.ogg"

-- Attribute window
local frameFormDruid = CreateFrame("Frame", "frameFormDruid", UIParent)
frameFormDruid:SetSize(1000, 600)
frameFormDruid:SetMovable(true)
frameFormDruid:EnableMouse(true)
frameFormDruid:RegisterForDrag("LeftButton")
frameFormDruid:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 100, -100) -- Adjust the X and Y coordinates
frameFormDruid:SetFrameLevel(100)  -- Définit un niveau de frame élevé
frameFormDruid:SetBackdrop(
{
    bgFile = "interface/TalentFrame/talentsclassbackgrounddruid2", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    edgeFile = "interface/tooltips/ui-tooltip-border-corrupteddruid2", --Interface/DialogFrame/UI-DialogBox-Border
    edgeSize = 20,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})

-- Ajoutez la texture de l'icône du Druid
local formIcon = frameFormDruid:CreateTexture("FormIcon", "OVERLAY")
formIcon:SetTexture("Interface\\TalentFrame\\Template\\Class\\Druid\\IconeDruid.blp")
formIcon:SetSize(60, 60)
formIcon:SetPoint("TOPLEFT", frameFormDruid, "TOPLEFT", -10, 10)

-- Drag & Drop
frameFormDruid:SetScript("OnDragStart", frameFormDruid.StartMoving)
frameFormDruid:SetScript("OnHide", frameFormDruid.StopMovingOrSizing)
frameFormDruid:SetScript("OnDragStop", frameFormDruid.StopMovingOrSizing)
frameFormDruid:Hide()

-- Nouveau template d'arête
frameFormDruid:SetBackdropBorderColor(169, 210, 113) -- Couleur rouge pale

-- Close button
local buttonFormDruidClose = CreateFrame("Button", "buttonFormDruidClose", frameFormDruid, "UIPanelCloseButton")
buttonFormDruidClose:SetPoint("TOPRIGHT", -5, -5)
buttonFormDruidClose:EnableMouse(true)
buttonFormDruidClose:SetSize(27, 27)

local function CloseTalentWindow()
    frameFormDruid:Hide()
    PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
end

-- Associez la fonction de fermeture au bouton de fermeture
buttonFormDruidClose:SetScript("OnClick", CloseTalentWindow)

-- Title bar
local frameFormDruidTitleBar = CreateFrame("Frame", "frameFormDruidTitleBar", frameFormDruid, nil)
frameFormDruidTitleBar:SetSize(135, 25)
frameFormDruidTitleBar:SetBackdrop(
{
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corrupteddruid2",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameFormDruidTitleBar:SetPoint("TOP", 0, 20)

local fontFormDruidTitleText = frameFormDruidTitleBar:CreateFontString("fontFormDruidTitleText")
fontFormDruidTitleText:SetFont("Fonts\\FRIZQT__.TTF", 13)
fontFormDruidTitleText:SetSize(190, 5)
fontFormDruidTitleText:SetPoint("CENTER", 0, 0)
fontFormDruidTitleText:SetText("|cffFFC125Forme|r")

-- Forme Ours

local fontFormDruidBearText = frameFormDruidTitleBar:CreateFontString("fontFormDruidBearText")
fontFormDruidBearText:SetFont("Fonts\\FRIZQT__.TTF", 13)
fontFormDruidBearText:SetSize(200, 5)
fontFormDruidBearText:SetPoint("TOPLEFT", frameFormDruidTitleBar, "BOTTOMLEFT", -280, -15) -- Adjust the Y offset as needed
fontFormDruidBearText:SetText("|cffFFC125Formes Ours|r")

-- FormBear1

local buttonFormBear1 = CreateFrame("Button", "buttonFormBear1", frameFormDruid, nil)
buttonFormBear1:SetSize(40, 40)
buttonFormBear1:SetPoint("TOPLEFT", 50, -45)
buttonFormBear1:EnableMouse(true)
buttonFormBear1:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear1:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear1:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear1:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear1", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear1:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 1"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear1:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear2

local buttonFormBear2 = CreateFrame("Button", "buttonFormBear2", frameFormDruid, nil)
buttonFormBear2:SetSize(40, 40)
buttonFormBear2:SetPoint("TOPLEFT", 160, -45)
buttonFormBear2:EnableMouse(true)
buttonFormBear2:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear2:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear2:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear2:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear2", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear2:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 2"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear2:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear3

local buttonFormBear3 = CreateFrame("Button", "buttonFormBear3", frameFormDruid, nil)
buttonFormBear3:SetSize(40, 40)
buttonFormBear3:SetPoint("TOPLEFT", 270, -45)
buttonFormBear3:EnableMouse(true)
buttonFormBear3:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear3:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear3:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear3:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear3", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear3:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 3"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear3:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear4

local buttonFormBear4 = CreateFrame("Button", "buttonFormBear4", frameFormDruid, nil)
buttonFormBear4:SetSize(40, 40)
buttonFormBear4:SetPoint("TOPLEFT", 380, -45)
buttonFormBear4:EnableMouse(true)
buttonFormBear4:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear4:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear4:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear4:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear4", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear4:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 4"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear4:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-------------------

-- FormBear5

local buttonFormBear5 = CreateFrame("Button", "buttonFormBear5", frameFormDruid, nil)
buttonFormBear5:SetSize(40, 40)
buttonFormBear5:SetPoint("TOPLEFT", 50, -110)
buttonFormBear5:EnableMouse(true)
buttonFormBear5:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear5:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear5:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear5:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear5", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear5:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 5"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear5:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear6

local buttonFormBear6 = CreateFrame("Button", "buttonFormBear6", frameFormDruid, nil)
buttonFormBear6:SetSize(40, 40)
buttonFormBear6:SetPoint("TOPLEFT", 160, -110)
buttonFormBear6:EnableMouse(true)
buttonFormBear6:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear6:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear6:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear6:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear6", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear6:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 6"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear6:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear7

local buttonFormBear7 = CreateFrame("Button", "buttonFormBear7", frameFormDruid, nil)
buttonFormBear7:SetSize(40, 40)
buttonFormBear7:SetPoint("TOPLEFT", 270, -110)
buttonFormBear7:EnableMouse(true)
buttonFormBear7:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear7:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear7:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear7:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear7", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear7:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 7"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear7:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear14

local buttonFormBear14 = CreateFrame("Button", "buttonFormBear14", frameFormDruid, nil)
buttonFormBear14:SetSize(40, 40)
buttonFormBear14:SetPoint("TOPLEFT", 380, -110)
buttonFormBear14:EnableMouse(true)
buttonFormBear14:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear14:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear14:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear14:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear14", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear14:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 8"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear14:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-------------------

-- FormBear8

local buttonFormBear8 = CreateFrame("Button", "buttonFormBear8", frameFormDruid, nil)
buttonFormBear8:SetSize(40, 40)
buttonFormBear8:SetPoint("TOPLEFT", 50, -180)
buttonFormBear8:EnableMouse(true)
buttonFormBear8:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear8:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear8:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear8:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear8", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear8:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 9"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear8:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear9

local buttonFormBear9 = CreateFrame("Button", "buttonFormBear9", frameFormDruid, nil)
buttonFormBear9:SetSize(40, 40)
buttonFormBear9:SetPoint("TOPLEFT", 160, -180)
buttonFormBear9:EnableMouse(true)
buttonFormBear9:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear9:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear9:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear9:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear9", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear9:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 10"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear9:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear10

local buttonFormBear10 = CreateFrame("Button", "buttonFormBear10", frameFormDruid, nil)
buttonFormBear10:SetSize(40, 40)
buttonFormBear10:SetPoint("TOPLEFT", 270, -180)
buttonFormBear10:EnableMouse(true)
buttonFormBear10:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear10:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear10:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear10:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear10", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear10:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 11"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear10:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear15

local buttonFormBear15 = CreateFrame("Button", "buttonFormBear15", frameFormDruid, nil)
buttonFormBear15:SetSize(40, 40)
buttonFormBear15:SetPoint("TOPLEFT", 380, -180)
buttonFormBear15:EnableMouse(true)
buttonFormBear15:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear15:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear15:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear15:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear15", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear15:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 12"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear15:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-------------------

-- FormBear11

local buttonFormBear11 = CreateFrame("Button", "buttonFormBear11", frameFormDruid, nil)
buttonFormBear11:SetSize(40, 40)
buttonFormBear11:SetPoint("TOPLEFT", 50, -250)
buttonFormBear11:EnableMouse(true)
buttonFormBear11:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear11:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear11:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear11:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear11", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear11:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 13"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear11:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear12

local buttonFormBear12 = CreateFrame("Button", "buttonFormBear12", frameFormDruid, nil)
buttonFormBear12:SetSize(40, 40)
buttonFormBear12:SetPoint("TOPLEFT", 160, -250)
buttonFormBear12:EnableMouse(true)
buttonFormBear12:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear12:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear12:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear12:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear12", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear12:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 14"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear12:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear13

local buttonFormBear13 = CreateFrame("Button", "buttonFormBear13", frameFormDruid, nil)
buttonFormBear13:SetSize(40, 40)
buttonFormBear13:SetPoint("TOPLEFT", 270, -250)
buttonFormBear13:EnableMouse(true)
buttonFormBear13:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear13:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear13:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear13:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear13", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear13:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 15"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear13:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear16

local buttonFormBear16 = CreateFrame("Button", "buttonFormBear16", frameFormDruid, nil)
buttonFormBear16:SetSize(40, 40)
buttonFormBear16:SetPoint("TOPLEFT", 380, -250)
buttonFormBear16:EnableMouse(true)
buttonFormBear16:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear16:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear16:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear16:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear16", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear16:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 16"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear16:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-------------------

-- FormBear17

local buttonFormBear17 = CreateFrame("Button", "buttonFormBear17", frameFormDruid, nil)
buttonFormBear17:SetSize(40, 40)
buttonFormBear17:SetPoint("TOPLEFT", 50, -320)
buttonFormBear17:EnableMouse(true)
buttonFormBear17:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear17:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear17:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear17:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear17", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear17:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 17"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear17:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear18

local buttonFormBear18 = CreateFrame("Button", "buttonFormBear18", frameFormDruid, nil)
buttonFormBear18:SetSize(40, 40)
buttonFormBear18:SetPoint("TOPLEFT", 160, -320)
buttonFormBear18:EnableMouse(true)
buttonFormBear18:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear18:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear18:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear18:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear18", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear18:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 18"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear18:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear19

local buttonFormBear19 = CreateFrame("Button", "buttonFormBear19", frameFormDruid, nil)
buttonFormBear19:SetSize(40, 40)
buttonFormBear19:SetPoint("TOPLEFT", 270, -320)
buttonFormBear19:EnableMouse(true)
buttonFormBear19:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear19:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear19:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear19:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear19", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear19:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 19"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear19:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear20

local buttonFormBear20 = CreateFrame("Button", "buttonFormBear20", frameFormDruid, nil)
buttonFormBear20:SetSize(40, 40)
buttonFormBear20:SetPoint("TOPLEFT", 380, -320)
buttonFormBear20:EnableMouse(true)
buttonFormBear20:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear20:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear20:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear20:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear20", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear20:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 20"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear20:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-------------------

-- FormBear21

local buttonFormBear21 = CreateFrame("Button", "buttonFormBear21", frameFormDruid, nil)
buttonFormBear21:SetSize(40, 40)
buttonFormBear21:SetPoint("TOPLEFT", 50, -390)
buttonFormBear21:EnableMouse(true)
buttonFormBear21:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear21:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear21:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear21:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear21", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear21:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 21"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear21:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear22

local buttonFormBear22 = CreateFrame("Button", "buttonFormBear22", frameFormDruid, nil)
buttonFormBear22:SetSize(40, 40)
buttonFormBear22:SetPoint("TOPLEFT", 160, -390)
buttonFormBear22:EnableMouse(true)
buttonFormBear22:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear22:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear22:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear22:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear22", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear22:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 22"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear22:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear23

local buttonFormBear23 = CreateFrame("Button", "buttonFormBear23", frameFormDruid, nil)
buttonFormBear23:SetSize(40, 40)
buttonFormBear23:SetPoint("TOPLEFT", 270, -390)
buttonFormBear23:EnableMouse(true)
buttonFormBear23:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear23:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear23:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear23:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear23", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear23:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 23"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear23:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear24

local buttonFormBear24 = CreateFrame("Button", "buttonFormBear24", frameFormDruid, nil)
buttonFormBear24:SetSize(40, 40)
buttonFormBear24:SetPoint("TOPLEFT", 380, -390)
buttonFormBear24:EnableMouse(true)
buttonFormBear24:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear24:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear24:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear24:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear24", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear24:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 24"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear24:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-------------------

-- FormBear25

local buttonFormBear25 = CreateFrame("Button", "buttonFormBear25", frameFormDruid, nil)
buttonFormBear25:SetSize(40, 40)
buttonFormBear25:SetPoint("TOPLEFT", 50, -460)
buttonFormBear25:EnableMouse(true)
buttonFormBear25:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear25:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear25:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear25:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear25", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear25:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 25"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear25:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear26

local buttonFormBear26 = CreateFrame("Button", "buttonFormBear26", frameFormDruid, nil)
buttonFormBear26:SetSize(40, 40)
buttonFormBear26:SetPoint("TOPLEFT", 160, -460)
buttonFormBear26:EnableMouse(true)
buttonFormBear26:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear26:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear26:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear26:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear26", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear26:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 26"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear26:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear27

local buttonFormBear27 = CreateFrame("Button", "buttonFormBear27", frameFormDruid, nil)
buttonFormBear27:SetSize(40, 40)
buttonFormBear27:SetPoint("TOPLEFT", 270, -460)
buttonFormBear27:EnableMouse(true)
buttonFormBear27:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear27:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear27:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear27:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear27", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear27:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 27"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear27:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear28

local buttonFormBear28 = CreateFrame("Button", "buttonFormBear28", frameFormDruid, nil)
buttonFormBear28:SetSize(40, 40)
buttonFormBear28:SetPoint("TOPLEFT", 380, -460)
buttonFormBear28:EnableMouse(true)
buttonFormBear28:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear28:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear28:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear28:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear28", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear28:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 28"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear28:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-------------------

-- FormBear29

local buttonFormBear29 = CreateFrame("Button", "buttonFormBear29", frameFormDruid, nil)
buttonFormBear29:SetSize(40, 40)
buttonFormBear29:SetPoint("TOPLEFT", 50, -530)
buttonFormBear29:EnableMouse(true)
buttonFormBear29:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear29:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear29:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear29:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear29", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear29:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 29"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear29:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear30

local buttonFormBear30 = CreateFrame("Button", "buttonFormBear30", frameFormDruid, nil)
buttonFormBear30:SetSize(40, 40)
buttonFormBear30:SetPoint("TOPLEFT", 160, -530)
buttonFormBear30:EnableMouse(true)
buttonFormBear30:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear30:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear30:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear30:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear30", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear30:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 30"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear30:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear31

local buttonFormBear31 = CreateFrame("Button", "buttonFormBear31", frameFormDruid, nil)
buttonFormBear31:SetSize(40, 40)
buttonFormBear31:SetPoint("TOPLEFT", 270, -530)
buttonFormBear31:EnableMouse(true)
buttonFormBear31:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear31:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear31:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear31:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear31", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear31:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 31"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear31:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormBear32

local buttonFormBear32 = CreateFrame("Button", "buttonFormBear32", frameFormDruid, nil)
buttonFormBear32:SetSize(40, 40)
buttonFormBear32:SetPoint("TOPLEFT", 380, -530)
buttonFormBear32:EnableMouse(true)
buttonFormBear32:SetNormalTexture("Interface/icons/ability_racial_bearform")
buttonFormBear32:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear32:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormBear32:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formbear32", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormBear32:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme Ours 32"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme d'ours redoutable.") ; GameTooltip:Show() end)
buttonFormBear32:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-----------------------------------------------------------------------------------------------------

-- Forme de Félin

local fontFormDruidCatText = frameFormDruidTitleBar:CreateFontString("fontFormDruidCatText")
fontFormDruidCatText:SetFont("Fonts\\FRIZQT__.TTF", 13)
fontFormDruidCatText:SetSize(200, 5)
fontFormDruidCatText:SetPoint("TOPLEFT", frameFormDruidTitleBar, "BOTTOMLEFT", 220, -15) -- Adjust the Y offset as needed
fontFormDruidCatText:SetText("|cffFFC125Formes Félin/Voyage|r")

-- FormCat1

local buttonFormCat1 = CreateFrame("Button", "buttonFormCat1", frameFormDruid, nil)
buttonFormCat1:SetSize(40, 40)
buttonFormCat1:SetPoint("TOPLEFT", 540, -45)
buttonFormCat1:EnableMouse(true)
buttonFormCat1:SetNormalTexture("Interface/icons/ability_druid_catform")
buttonFormCat1:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat1:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat1:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat1", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat1:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Félin 1"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de félin.") ; GameTooltip:Show() end)
buttonFormCat1:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormCat2

local buttonFormCat2 = CreateFrame("Button", "buttonFormCat2", frameFormDruid, nil)
buttonFormCat2:SetSize(40, 40)
buttonFormCat2:SetPoint("TOPLEFT", 650, -45)
buttonFormCat2:EnableMouse(true)
buttonFormCat2:SetNormalTexture("Interface/icons/ability_druid_catform")
buttonFormCat2:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat2:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat2:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat2", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat2:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Félin 2"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de félin.") ; GameTooltip:Show() end)
buttonFormCat2:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormCat3

local buttonFormCat3 = CreateFrame("Button", "buttonFormCat3", frameFormDruid, nil)
buttonFormCat3:SetSize(40, 40)
buttonFormCat3:SetPoint("TOPLEFT", 760, -45)
buttonFormCat3:EnableMouse(true)
buttonFormCat3:SetNormalTexture("Interface/icons/ability_druid_catform")
buttonFormCat3:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat3:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat3:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat3", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat3:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Félin 3"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de félin.") ; GameTooltip:Show() end)
buttonFormCat3:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormCat4

local buttonFormCat4 = CreateFrame("Button", "buttonFormCat4", frameFormDruid, nil)
buttonFormCat4:SetSize(40, 40)
buttonFormCat4:SetPoint("TOPLEFT", 870, -45)
buttonFormCat4:EnableMouse(true)
buttonFormCat4:SetNormalTexture("Interface/icons/ability_druid_catform")
buttonFormCat4:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat4:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat4:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat4", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat4:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Félin 4"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de félin.") ; GameTooltip:Show() end)
buttonFormCat4:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-------------------

-- FormCat5

local buttonFormCat5 = CreateFrame("Button", "buttonFormCat5", frameFormDruid, nil)
buttonFormCat5:SetSize(40, 40)
buttonFormCat5:SetPoint("TOPLEFT", 540, -110)
buttonFormCat5:EnableMouse(true)
buttonFormCat5:SetNormalTexture("Interface/icons/ability_druid_catform")
buttonFormCat5:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat5:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat5:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat5", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat5:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Félin 5"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de félin.") ; GameTooltip:Show() end)
buttonFormCat5:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormCat6

local buttonFormCat6 = CreateFrame("Button", "buttonFormCat6", frameFormDruid, nil)
buttonFormCat6:SetSize(40, 40)
buttonFormCat6:SetPoint("TOPLEFT", 650, -110)
buttonFormCat6:EnableMouse(true)
buttonFormCat6:SetNormalTexture("Interface/icons/ability_druid_catform")
buttonFormCat6:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat6:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat6:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat6", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat6:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Félin 6"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de félin.") ; GameTooltip:Show() end)
buttonFormCat6:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormCat7

local buttonFormCat7 = CreateFrame("Button", "buttonFormCat7", frameFormDruid, nil)
buttonFormCat7:SetSize(40, 40)
buttonFormCat7:SetPoint("TOPLEFT", 760, -110)
buttonFormCat7:EnableMouse(true)
buttonFormCat7:SetNormalTexture("Interface/icons/ability_druid_catform")
buttonFormCat7:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat7:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat7:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat7", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat7:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Félin 7"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de félin.") ; GameTooltip:Show() end)
buttonFormCat7:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormCat8

local buttonFormCat8 = CreateFrame("Button", "buttonFormCat8", frameFormDruid, nil)
buttonFormCat8:SetSize(40, 40)
buttonFormCat8:SetPoint("TOPLEFT", 870, -110)
buttonFormCat8:EnableMouse(true)
buttonFormCat8:SetNormalTexture("Interface/icons/ability_druid_catform")
buttonFormCat8:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat8:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat8:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat8", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat8:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Félin 8"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de félin.") ; GameTooltip:Show() end)
buttonFormCat8:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-------------------

-- FormCat9

local buttonFormCat9 = CreateFrame("Button", "buttonFormCat9", frameFormDruid, nil)
buttonFormCat9:SetSize(40, 40)
buttonFormCat9:SetPoint("TOPLEFT", 540, -180)
buttonFormCat9:EnableMouse(true)
buttonFormCat9:SetNormalTexture("Interface/icons/ability_druid_catform")
buttonFormCat9:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat9:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat9:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat9", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat9:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Félin 9"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de félin.") ; GameTooltip:Show() end)
buttonFormCat9:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormCat10

local buttonFormCat10 = CreateFrame("Button", "buttonFormCat10", frameFormDruid, nil)
buttonFormCat10:SetSize(40, 40)
buttonFormCat10:SetPoint("TOPLEFT", 650, -180)
buttonFormCat10:EnableMouse(true)
buttonFormCat10:SetNormalTexture("Interface/icons/ability_druid_catform")
buttonFormCat10:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat10:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat10:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat10", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat10:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Félin 10"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de félin.") ; GameTooltip:Show() end)
buttonFormCat10:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormCat11

local buttonFormCat11 = CreateFrame("Button", "buttonFormCat11", frameFormDruid, nil)
buttonFormCat11:SetSize(40, 40)
buttonFormCat11:SetPoint("TOPLEFT", 760, -180)
buttonFormCat11:EnableMouse(true)
buttonFormCat11:SetNormalTexture("Interface/icons/ability_druid_catform")
buttonFormCat11:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat11:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat11:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat11", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat11:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Félin 11"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de félin.") ; GameTooltip:Show() end)
buttonFormCat11:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormCat12

local buttonFormCat12 = CreateFrame("Button", "buttonFormCat12", frameFormDruid, nil)
buttonFormCat12:SetSize(40, 40)
buttonFormCat12:SetPoint("TOPLEFT", 870, -180)
buttonFormCat12:EnableMouse(true)
buttonFormCat12:SetNormalTexture("Interface/icons/ability_druid_catform")
buttonFormCat12:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat12:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat12:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat12", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat12:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Félin 12"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de félin.") ; GameTooltip:Show() end)
buttonFormCat12:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-------------------

-- FormCat13

local buttonFormCat13 = CreateFrame("Button", "buttonFormCat13", frameFormDruid, nil)
buttonFormCat13:SetSize(40, 40)
buttonFormCat13:SetPoint("TOPLEFT", 540, -250)
buttonFormCat13:EnableMouse(true)
buttonFormCat13:SetNormalTexture("Interface/icons/ability_druid_catform")
buttonFormCat13:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat13:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat13:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat13", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat13:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Félin 13"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de félin.") ; GameTooltip:Show() end)
buttonFormCat13:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormCat14

local buttonFormCat14 = CreateFrame("Button", "buttonFormCat14", frameFormDruid, nil)
buttonFormCat14:SetSize(40, 40)
buttonFormCat14:SetPoint("TOPLEFT", 650, -250)
buttonFormCat14:EnableMouse(true)
buttonFormCat14:SetNormalTexture("Interface/icons/ability_druid_catform")
buttonFormCat14:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat14:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat14:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat14", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat14:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Félin 14"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de félin.") ; GameTooltip:Show() end)
buttonFormCat14:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormCat15

local buttonFormCat15 = CreateFrame("Button", "buttonFormCat15", frameFormDruid, nil)
buttonFormCat15:SetSize(40, 40)
buttonFormCat15:SetPoint("TOPLEFT", 760, -250)
buttonFormCat15:EnableMouse(true)
buttonFormCat15:SetNormalTexture("Interface/icons/ability_druid_catform")
buttonFormCat15:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat15:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat15:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat15", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat15:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Félin 15"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de félin.") ; GameTooltip:Show() end)
buttonFormCat15:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormCat16

local buttonFormCat16 = CreateFrame("Button", "buttonFormCat16", frameFormDruid, nil)
buttonFormCat16:SetSize(40, 40)
buttonFormCat16:SetPoint("TOPLEFT", 870, -250)
buttonFormCat16:EnableMouse(true)
buttonFormCat16:SetNormalTexture("Interface/icons/Ability_Druid_TravelForm")
buttonFormCat16:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat16:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat16:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat16", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat16:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Voyage 16"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de voyage.") ; GameTooltip:Show() end)
buttonFormCat16:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-------------------

-- FormCat17

local buttonFormCat17 = CreateFrame("Button", "buttonFormCat17", frameFormDruid, nil)
buttonFormCat17:SetSize(40, 40)
buttonFormCat17:SetPoint("TOPLEFT", 540, -320)
buttonFormCat17:EnableMouse(true)
buttonFormCat17:SetNormalTexture("Interface/icons/Ability_Druid_TravelForm")
buttonFormCat17:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat17:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat17:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat17", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat17:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Voyage 17"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de voyage.") ; GameTooltip:Show() end)
buttonFormCat17:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormCat18

local buttonFormCat18 = CreateFrame("Button", "buttonFormCat18", frameFormDruid, nil)
buttonFormCat18:SetSize(40, 40)
buttonFormCat18:SetPoint("TOPLEFT", 650, -320)
buttonFormCat18:EnableMouse(true)
buttonFormCat18:SetNormalTexture("Interface/icons/Ability_Druid_TravelForm")
buttonFormCat18:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat18:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat18:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat18", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat18:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Voyage 18"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de voyage.") ; GameTooltip:Show() end)
buttonFormCat18:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormCat19

local buttonFormCat19 = CreateFrame("Button", "buttonFormCat19", frameFormDruid, nil)
buttonFormCat19:SetSize(40, 40)
buttonFormCat19:SetPoint("TOPLEFT", 760, -320)
buttonFormCat19:EnableMouse(true)
buttonFormCat19:SetNormalTexture("Interface/icons/Ability_Druid_TravelForm")
buttonFormCat19:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat19:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat19:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat19", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat19:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Voyage 19"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de voyage.") ; GameTooltip:Show() end)
buttonFormCat19:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormCat20

local buttonFormCat20 = CreateFrame("Button", "buttonFormCat20", frameFormDruid, nil)
buttonFormCat20:SetSize(40, 40)
buttonFormCat20:SetPoint("TOPLEFT", 870, -320)
buttonFormCat20:EnableMouse(true)
buttonFormCat20:SetNormalTexture("Interface/icons/Ability_Druid_TravelForm")
buttonFormCat20:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat20:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat20:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat20", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat20:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Voyage 20"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de voyage.") ; GameTooltip:Show() end)
buttonFormCat20:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-------------------

-- FormCat21

local buttonFormCat21 = CreateFrame("Button", "buttonFormCat21", frameFormDruid, nil)
buttonFormCat21:SetSize(40, 40)
buttonFormCat21:SetPoint("TOPLEFT", 540, -390)
buttonFormCat21:EnableMouse(true)
buttonFormCat21:SetNormalTexture("Interface/icons/Ability_Druid_TravelForm")
buttonFormCat21:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat21:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat21:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat21", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat21:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Voyage 21"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de voyage.") ; GameTooltip:Show() end)
buttonFormCat21:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormCat22

local buttonFormCat22 = CreateFrame("Button", "buttonFormCat22", frameFormDruid, nil)
buttonFormCat22:SetSize(40, 40)
buttonFormCat22:SetPoint("TOPLEFT", 650, -390)
buttonFormCat22:EnableMouse(true)
buttonFormCat22:SetNormalTexture("Interface/icons/Ability_Druid_TravelForm")
buttonFormCat22:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat22:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat22:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat22", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat22:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Voyage 22"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de voyage.") ; GameTooltip:Show() end)
buttonFormCat22:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormCat23

local buttonFormCat23 = CreateFrame("Button", "buttonFormCat23", frameFormDruid, nil)
buttonFormCat23:SetSize(40, 40)
buttonFormCat23:SetPoint("TOPLEFT", 760, -390)
buttonFormCat23:EnableMouse(true)
buttonFormCat23:SetNormalTexture("Interface/icons/Ability_Druid_TravelForm")
buttonFormCat23:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat23:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat23:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat23", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat23:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Voyage 23"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de voyage.") ; GameTooltip:Show() end)
buttonFormCat23:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormCat24

local buttonFormCat24 = CreateFrame("Button", "buttonFormCat24", frameFormDruid, nil)
buttonFormCat24:SetSize(40, 40)
buttonFormCat24:SetPoint("TOPLEFT", 870, -390)
buttonFormCat24:EnableMouse(true)
buttonFormCat24:SetNormalTexture("Interface/icons/Ability_Druid_TravelForm")
buttonFormCat24:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat24:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat24:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat24", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat24:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Voyage 24"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de voyage.") ; GameTooltip:Show() end)
buttonFormCat24:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-------------------

-- FormCat25

local buttonFormCat25 = CreateFrame("Button", "buttonFormCat25", frameFormDruid, nil)
buttonFormCat25:SetSize(40, 40)
buttonFormCat25:SetPoint("TOPLEFT", 540, -460)
buttonFormCat25:EnableMouse(true)
buttonFormCat25:SetNormalTexture("Interface/icons/Ability_Druid_TravelForm")
buttonFormCat25:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat25:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat25:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat25", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat25:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Voyage 25"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de voyage.") ; GameTooltip:Show() end)
buttonFormCat25:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormCat26

local buttonFormCat26 = CreateFrame("Button", "buttonFormCat26", frameFormDruid, nil)
buttonFormCat26:SetSize(40, 40)
buttonFormCat26:SetPoint("TOPLEFT", 650, -460)
buttonFormCat26:EnableMouse(true)
buttonFormCat26:SetNormalTexture("Interface/icons/Ability_Druid_TravelForm")
buttonFormCat26:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat26:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat26:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat26", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat26:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Voyage 26"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de voyage.") ; GameTooltip:Show() end)
buttonFormCat26:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormCat27

local buttonFormCat27 = CreateFrame("Button", "buttonFormCat27", frameFormDruid, nil)
buttonFormCat27:SetSize(40, 40)
buttonFormCat27:SetPoint("TOPLEFT", 760, -460)
buttonFormCat27:EnableMouse(true)
buttonFormCat27:SetNormalTexture("Interface/icons/Ability_Druid_TravelForm")
buttonFormCat27:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat27:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat27:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat27", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat27:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Voyage 27"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de voyage.") ; GameTooltip:Show() end)
buttonFormCat27:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-- FormCat28

local buttonFormCat28 = CreateFrame("Button", "buttonFormCat28", frameFormDruid, nil)
buttonFormCat28:SetSize(40, 40)
buttonFormCat28:SetPoint("TOPLEFT", 870, -460)
buttonFormCat28:EnableMouse(true)
buttonFormCat28:SetNormalTexture("Interface/icons/Ability_Druid_TravelForm")
buttonFormCat28:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat28:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat28:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat28", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat28:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Voyage 28"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de voyage.") ; GameTooltip:Show() end)
buttonFormCat28:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-------------------

-- FormCat29

local buttonFormCat29 = CreateFrame("Button", "buttonFormCat29", frameFormDruid, nil)
buttonFormCat29:SetSize(40, 40)
buttonFormCat29:SetPoint("TOPLEFT", 703, -530)
buttonFormCat29:EnableMouse(true)
buttonFormCat29:SetNormalTexture("Interface/icons/Ability_Druid_TravelForm")
buttonFormCat29:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat29:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
buttonFormCat29:SetScript("OnMouseUp", function() AIO.Handle("FormDruidspell", "formcat29", 1) PlaySoundFile(SPELL_TALENT_WINDOW_SOUND) end)
buttonFormCat29:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "TOPLEFT"); GameTooltip:ClearLines(); GameTooltip:SetText("|cffffffffForme de Voyage 29"); GameTooltip:AddLine("|cffffffffInstantanée                                       "); GameTooltip:AddLine("|cffffffffRequiert|r |cffff7d0aDruide|r                              "); GameTooltip:AddLine("|cffffd100Transformé en forme de voyage.") ; GameTooltip:Show() end)
buttonFormCat29:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

-------------------

local function OuvrirInterfaceForms()
    frameFormDruid:Show()
	PlaySoundFile(OPEN_TALENT_WINDOW_SOUND)
end

-- Ajoutez une variable globale pour suivre l'état de la fenêtre des talents
local formsWindowOpen = false

local function OuvrirFermerInterfaceForms()
    if formsWindowOpen then
        frameFormDruid:Hide()
        buttonReload:Hide()
        PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
    else
        frameFormDruid:Show()
        buttonReload:Show()
        PlaySoundFile(OPEN_TALENT_WINDOW_SOUND)
    end

    -- Inversez l'état de la fenêtre des talents
    formsWindowOpen = not formsWindowOpen
end

-- Vérifier si le joueur est un Druid avant de créer le bouton
local playerClass = select(2, UnitClass("player")) -- Obtenir la classe du joueur
if playerClass == "DRUID" then
    local buttonOuvrirForms = CreateFrame("Button", "buttonOuvrirForms", UIParent)
    buttonOuvrirForms:SetSize(32, 33)
    buttonOuvrirForms:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -208, 35) -- Placer en bas à droite avec un décalage de 10 pixels

    -- Ajouter une texture BLP au bouton
    buttonOuvrirForms:SetNormalTexture("Interface\\TalentFrame\\Template\\MicroButton\\ButtonSystemForm.blp")

    -- Ajouter une texture de surbrillance
    local highlightTexture = buttonOuvrirForms:CreateTexture(nil, "HIGHLIGHT")
    highlightTexture:SetAllPoints(buttonOuvrirForms)
    highlightTexture:SetTexture("Interface\\TalentFrame\\Template\\MicroButton\\ButtonSystemFormLight.blp")
    buttonOuvrirForms:SetHighlightTexture(highlightTexture)

    -- Supprimer le texte du bouton
    buttonOuvrirForms:SetText("")

    -- Ajouter une info-bulle
    buttonOuvrirForms:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT") -- Définir l'ancre de l'info-bulle
        GameTooltip:SetText("|cffffffffForme|r |cffff7d0a(Druide)|r\n\nChanger l'apparence de votre druide\ntout en maintenant les compétences\nde la forme choisie.")
        GameTooltip:Show()
    end)

    -- Masquer l'info-bulle lorsque la souris quitte le bouton
    buttonOuvrirForms:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    buttonOuvrirForms:SetScript("OnClick", OuvrirFermerInterfaceForms)
    TalentMicroButton:Hide()
end