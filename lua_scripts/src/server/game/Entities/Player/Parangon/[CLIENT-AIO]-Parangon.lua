--[[
    Système Parangon - AIO
]]--

local AIO = AIO or require("AIO");
if AIO.AddAddon() then
  return
end

local parangon = {}
local parangon_addon = AIO.AddHandlers("AIO_Parangon", {})

parangon.mainWindow = CreateFrame("Frame", "ParangonMainWindow", UIParent)
  parangon.mainWindow:SetSize(300, 500)
  parangon.mainWindow:SetMovable(false)
  parangon.mainWindow:EnableMouse(true)
  parangon.mainWindow:RegisterForDrag("Right_Button")
  parangon.mainWindow:SetPoint("CENTER", 0, 50)
  parangon.mainWindow:Hide()

-- Fermeture de l'UI avec la touche Échap
tinsert(UISpecialFrames, "ParangonMainWindow")
  
parangon.mainWindowChild = CreateFrame("Frame", parangon.mainWindowChild, parangon.mainWindow)
  parangon.mainWindowChild:SetSize(300, 500)
  parangon.mainWindowChild:SetPoint("CENTER", 0, 0)
  -- parangon.mainWindowChild:SetClipsChildren(true)
  
-- local mainWindowChild = CreateFrame("Frame", mainWindowChild, parangon.mainWindow)
  -- mainWindowChild:SetSize(300, 500)
  
-- parangon.mainWindow:SetFrameChild(mainWindowChild);
  
-- parangon.scrollFrame = CreateFrame("Frame", parangon.scrollFrame, parangon.mainWindow, "UIPanelScrollFrameTemplate")
  -- parangon.scrollFrame:SetSize(300, 500)
  -- parangon.scrollFrame:SetPoint("CENTER", 0, 50)
  -- parangon.scrollFrame:SetFrameLevel(parangon.mainWindow:GetFrameLevel() + 1)
  
-- parangon.ScrollFrame = CreateFrame("ScrollFrame", nil, parangon.mainWindow, "UIPanelScrollFrameTemplate");

-- parangon.ScrollFrame:SetPoint("TOPLET", parangon.mainTitleTexture, "TOPLEFT", 4, -8);
-- parangon.ScrollFrame:SetPoint("BOTTOMRIGHT", parangon.mainTitleTexture, "BOTTOMRIGHT", -3, 4);

-- parangon.ScrollFrame.ScrollBar

parangon.mainWindowTexture = parangon.mainWindow:CreateTexture()
  parangon.mainWindowTexture:SetAllPoints(parangon.mainWindow)
  parangon.mainWindowTexture:SetTexture("interface/parangon/parangon_frame")
  parangon.mainWindowTexture:SetTexCoord(0.58154296875, 0.96435546875, 0.04052734375, 0.81201171875)

parangon.mainTitle = CreateFrame("Frame", parangon.mainTitle, parangon.mainWindow)
  parangon.mainTitle:SetSize(150, 45)
  parangon.mainTitle:SetPoint("TOP", 0, 20)
  parangon.mainTitle:SetFrameLevel(parangon.mainWindow:GetFrameLevel() + 1)

parangon.mainTitleTexture = parangon.mainWindow:CreateTexture()
  parangon.mainTitleTexture:SetAllPoints(parangon.mainTitle)
  parangon.mainTitleTexture:SetTexture("interface/parangon/parangon_frame")
  parangon.mainTitleTexture:SetParent(parangon.mainTitle)
  parangon.mainTitleTexture:SetTexCoord(0.23486328125, 0.48779296875, 0.33251953125, 0.40966796875)

parangon.mainTitleText = parangon.mainTitle:CreateFontString(parangon.mainTitleText)
  parangon.mainTitleText:SetFont("Fonts\\FRIZQT__.TTF", 13)
  parangon.mainTitleText:SetSize(190, 5)
  parangon.mainTitleText:SetPoint("CENTER", 0, 3)
  parangon.mainTitleText:SetText("|CFF000000Parangon|r")

parangon.mainWindowArt = CreateFrame("Button", parangon.mainWindowArt, parangon.mainWindow)
  parangon.mainWindowArt:SetSize(140, 100)
  parangon.mainWindowArt:SetPoint("TOP", -70, -80)
  parangon.mainWindowArt:SetFrameLevel(1)
  parangon.mainWindowArt:SetAlpha(0.4)
  parangon.mainWindowArt:SetFrameLevel(2)

parangon.mainWindowArtTexture = parangon.mainWindowArt:CreateTexture()
  parangon.mainWindowArtTexture:SetAllPoints(parangon.mainWindowArt)
  parangon.mainWindowArtTexture:SetTexture("interface/parangon/parangon_frame")
  parangon.mainWindowArtTexture:SetTexCoord(0.00048828125, 0.35009765625, 0.00048828125, 0.21435546875)

parangon.levelWindow = CreateFrame("Frame", parangon.levelWindow, parangon.mainWindow)
  parangon.levelWindow:SetSize(95, 90)
  parangon.levelWindow:SetPoint("TOP", 0, -30)
  parangon.levelWindow:SetFrameLevel(2)

parangon.levelWindowTexture = parangon.levelWindow:CreateTexture()
  parangon.levelWindowTexture:SetAllPoints(parangon.levelWindow)
  parangon.levelWindowTexture:SetTexture("interface/parangon/parangon_frame")
  parangon.levelWindowTexture:SetTexCoord(0.05419921875, 0.17431640625, 0.31201171875, 0.42724609375)

parangon.levelText = parangon.levelWindow:CreateFontString(parangon.levelText)
  parangon.levelText:SetFont("Fonts\\FRIZQT__.TTF", 18)
  parangon.levelText:SetSize(190, 3)
  parangon.levelText:SetPoint("CENTER", -2, 1)
  parangon.levelText:SetShadowColor(0.156, 0.2, 0.2)
  parangon.levelText:SetShadowOffset(0.5, 0)

parangon.closeButton = CreateFrame("Button", parangon.closeButton, parangon.mainWindow, "UIPanelCloseButton")
  parangon.closeButton:SetPoint("TOPRIGHT", 1.5, 3)
  parangon.closeButton:EnableMouse(true)
  parangon.closeButton:SetSize(26, 26)
  parangon.closeButton:SetFrameLevel(2)

parangon.expIcon = CreateFrame("Frame", parangon.expIcon, parangon.mainWindow)
  parangon.expIcon:SetSize(39, 39)
  parangon.expIcon:SetBackdrop({
    bgFile = "Interface/Icons/garr_currencyicon-xp",
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
  })
  parangon.expIcon:SetPoint("TOP", 0, -115)
  parangon.expIcon:SetFrameLevel(6)


parangon.expText = parangon.mainWindow:CreateFontString(parangon.expText)
  parangon.expText:SetFont("Fonts\\FRIZQT__.TTF", 13)
  parangon.expText:SetSize(190, 3)
  parangon.expText:SetPoint("TOP", 0, -155)
  parangon.expText:SetShadowColor(0.156, 0.2, 0.2)
  parangon.expText:SetShadowOffset(0.5, 0)


parangon.buttonsCoords = {
  global = {
    pos_y = 50
  }
}

parangon.leftButtons = {}
parangon.leftButtonsTexture = {}

parangon.leftButtonsArt = {}

parangon.centerButtons = {}
parangon.centerText = {}

parangon.rightButtons = {}
parangon.rightButtonsTexture = {}
parangon.rightText = {}

parangon.spellsList = {
  [7464] = {name = 'Force', icon = '_D3mantraofconviction'},
  [7471] = {name = 'Agilité', icon = '_D3mantraofevasion'},
  [7477] = {name = 'Endurance', icon = '_D3mantraofretribution'},
  [7468] = {name = 'Intelligence', icon = '_D3mantraofhealing'},
  [7597] = {name = 'Coup Critique', icon = 'inv_inscription_modified_craftingreagent01'},
  [37728] = {name = 'Hâte', icon = 'inv_inscription_modified_craftingreagent03'},
  [55565] = {name = 'Puissance des sorts', icon = 'spell_holy_greaterheal'},
  [9136] = {name = 'Puissance d\'attaque', icon = 'spell_holy_excorcism'},
  [1502002] = {name = 'Esquive', icon = 'spell_nature_invisibilty'},
  [7511] = {name = 'Defense', icon = 'ability_warrior_defensivestance'},
  [13665] = {name = 'Parade', icon = 'ability_parry'},
  [27949] = {name = 'Régén vie/mana', icon = 'spell_nature_regenerate'},
  [18672] = {name = 'Résistance', icon = 'spell_holy_devotion'},
  [9760] = {name = 'Armure', icon = 'inv_chest_plate01'},
  [46412] = {name = 'Résilience', icon = 'spell_arcane_arcaneresilience'},
  [15464] = {name = 'Score de toucher', icon = 'inv_offhand_stratholme_a_02'},
}

for id, subtable in pairs(parangon.spellsList) do
  parangon.leftButtons[id] = CreateFrame("Frame", parangon.leftButtons[id], parangon.mainWindowChild)
    parangon.leftButtons[id]:SetSize(50, 50)
    parangon.leftButtons[id]:SetPoint("LEFT", 20, parangon.buttonsCoords.global.pos_y)
    parangon.leftButtons[id]:SetFrameLevel(3)

  parangon.leftButtonsTexture[id] = parangon.leftButtons[id]:CreateTexture()
    parangon.leftButtonsTexture[id]:SetAllPoints(parangon.leftButtons[id])
    parangon.leftButtonsTexture[id]:SetTexture("Interface/parangon/ButtonBorder")

  parangon.leftButtonsArt[id] = CreateFrame("Frame", parangon.leftButtonsArt[id], parangon.leftButtons[id], nil)
  parangon.leftButtonsArt[id]:SetSize(35, 35)
  parangon.leftButtonsArt[id]:SetBackdrop(
    {
      bgFile = "Interface/Icons/"..subtable.icon,
      insets = {left = 0, right = 0, top = 0, bottom = 0}
    }
  )
  parangon.leftButtonsArt[id]:SetPoint("CENTER", 0, 0)
  parangon.leftButtonsArt[id]:SetFrameLevel(2)

  parangon.centerButtons[id] = CreateFrame("Button", parangon.centerButtons[id], parangon.mainWindowChild, nil)
    parangon.centerButtons[id]:SetSize(170, 55)
    parangon.centerButtons[id]:SetPoint("CENTER", 0, parangon.buttonsCoords.global.pos_y)
    parangon.centerButtons[id]:SetNormalTexture("Interface/Parangon/LargeButtonBorder")
    parangon.centerButtons[id]:SetHighlightTexture("Interface/Parangon/LargeButtonBorder_Hover")
    parangon.centerButtons[id]:SetPushedTexture("Interface/Parangon/LargeButtonBorder_Push")
    parangon.centerButtons[id]:EnableMouseWheel(1)
    parangon.centerButtons[id]:SetFrameLevel(3)

  parangon.centerButtons[id]:SetScript("OnMouseUp", function(self, button, down)
    if (button == "LeftButton") then
      AIO.Handle("AIO_Parangon", "setStatsInformation", id, 1, true)
    elseif (button == "RightButton") then
      AIO.Handle("AIO_Parangon", "setStatsInformation", id, 1, false)
    elseif (button == "MiddleButton") then
      AIO.Handle("AIO_Parangon", "setStatsInformation", id, 10, true)
    end
  end)

  parangon.centerButtons[id]:SetScript("OnMouseWheel", function(self, value)
    if (value > 0) then
      AIO.Handle("AIO_Parangon", "setStatsInformation", id, 1, true)
    else
      AIO.Handle("AIO_Parangon", "setStatsInformation", id, 1, false)
    end
  end)

  parangon.centerText[id] = parangon.centerButtons[id]:CreateFontString(parangon.centerText[id])
    parangon.centerText[id]:SetFont("Interface/Fonts/MARCELLUS.TTF", 14)
    parangon.centerText[id]:SetSize(190, 3)
    parangon.centerText[id]:SetPoint("CENTER", -1, 1)
    parangon.centerText[id]:SetText("|CFFFFFFFF"..subtable.name.."|r")
    parangon.centerText[id]:SetShadowColor(0, 0, 0)
    parangon.centerText[id]:SetShadowOffset(0.5, 0.5)

  parangon.rightButtons[id] = CreateFrame("Frame", parangon.rightButtons[id], parangon.mainWindowChild)
    parangon.rightButtons[id]:SetSize(50, 50)
    parangon.rightButtons[id]:SetPoint("Right", -20, parangon.buttonsCoords.global.pos_y)
    parangon.rightButtons[id]:SetFrameLevel(1000)
    parangon.rightButtons[id]:SetFrameLevel(3)

  parangon.rightText[id] = parangon.rightButtons[id]:CreateFontString(parangon.rightText[id])
    parangon.rightText[id]:SetFont("Fonts/FRIZQT__.TTF", 14)
    parangon.rightText[id]:SetSize(190, 3)
    parangon.rightText[id]:SetPoint("CENTER", 0.5, 0)
    parangon.rightText[id]:SetShadowColor(0, 0, 0)
    parangon.rightText[id]:SetShadowOffset(0.5, 0)

  parangon.rightButtonsTexture[id] = parangon.rightButtons[id]:CreateTexture()
    parangon.rightButtonsTexture[id]:SetAllPoints(parangon.rightButtons[id])
    parangon.rightButtonsTexture[id]:SetTexture("Interface/parangon/ButtonBorder")

  parangon.buttonsCoords.global.pos_y = parangon.buttonsCoords.global.pos_y - 0  
  
  
parangon.NextButton1 = CreateFrame("Button", parangon.NextButton1, parangon.mainWindow, nil)
  parangon.NextButton1:SetSize(25, 25)
  parangon.NextButton1:SetPoint("BOTTOM", -75, 68.75)
  parangon.NextButton1:SetNormalTexture("Interface/GLUES/PageNumbers/UI-PageNumber-1")
  parangon.NextButton1:SetFrameLevel(3)
  
	parangon.NextButton1:SetScript("OnShow", function(self)
		parangon.leftButtons[7464]:SetPoint("LEFT", 20, parangon.buttonsCoords.global.pos_y)
		parangon.leftButtonsArt[7464]:SetPoint("CENTER", 0, 0)
		parangon.centerButtons[7464]:SetPoint("CENTER", 0, parangon.buttonsCoords.global.pos_y)
		parangon.centerText[7464]:SetPoint("CENTER", -1, 1)
		parangon.rightButtons[7464]:SetPoint("Right", -20, parangon.buttonsCoords.global.pos_y)
		parangon.rightText[7464]:SetPoint("CENTER", 0.5, 0)
		
		parangon.leftButtons[7471]:SetPoint("LEFT", 20, parangon.buttonsCoords.global.pos_y - 60)
		parangon.leftButtonsArt[7471]:SetPoint("CENTER", 0, 0)
		parangon.centerButtons[7471]:SetPoint("CENTER", 0, parangon.buttonsCoords.global.pos_y - 60)
		parangon.centerText[7471]:SetPoint("CENTER", -1, 1)
		parangon.rightButtons[7471]:SetPoint("Right", -20, parangon.buttonsCoords.global.pos_y - 60)
		parangon.rightText[7471]:SetPoint("CENTER", 0.5, 0)
		
		parangon.leftButtons[7477]:SetPoint("LEFT", 20, parangon.buttonsCoords.global.pos_y - 120)
		parangon.leftButtonsArt[7477]:SetPoint("CENTER", 0, 0)
		parangon.centerButtons[7477]:SetPoint("CENTER", 0, parangon.buttonsCoords.global.pos_y - 120)
		parangon.centerText[7477]:SetPoint("CENTER", -1, 1)
		parangon.rightButtons[7477]:SetPoint("Right", -20, parangon.buttonsCoords.global.pos_y - 120)
		parangon.rightText[7477]:SetPoint("CENTER", 0.5, 0)
		
		parangon.leftButtons[7468]:SetPoint("LEFT", 20, parangon.buttonsCoords.global.pos_y - 180)
		parangon.leftButtonsArt[7468]:SetPoint("CENTER", 0, 0)
		parangon.centerButtons[7468]:SetPoint("CENTER", 0, parangon.buttonsCoords.global.pos_y - 180)
		parangon.centerText[7468]:SetPoint("CENTER", -1, 1)
		parangon.rightButtons[7468]:SetPoint("Right", -20, parangon.buttonsCoords.global.pos_y - 180)
		parangon.rightText[7468]:SetPoint("CENTER", 0.5, 0)
		
		
		parangon.leftButtons[7597]:SetPoint("LEFT", 20, parangon.buttonsCoords.global.pos_y)
		parangon.leftButtonsArt[7597]:SetPoint("CENTER", 0, 0)
		parangon.centerButtons[7597]:SetPoint("CENTER", 0, parangon.buttonsCoords.global.pos_y)
		parangon.centerText[7597]:SetPoint("CENTER", -1, 1)
		parangon.rightButtons[7597]:SetPoint("Right", -20, parangon.buttonsCoords.global.pos_y)
		parangon.rightText[7597]:SetPoint("CENTER", 0.5, 0)
		
		parangon.leftButtons[37728]:SetPoint("LEFT", 20, parangon.buttonsCoords.global.pos_y - 60)
		parangon.leftButtonsArt[37728]:SetPoint("CENTER", 0, 0)
		parangon.centerButtons[37728]:SetPoint("CENTER", 0, parangon.buttonsCoords.global.pos_y - 60)
		parangon.centerText[37728]:SetPoint("CENTER", -1, 1)
		parangon.rightButtons[37728]:SetPoint("Right", -20, parangon.buttonsCoords.global.pos_y - 60)
		parangon.rightText[37728]:SetPoint("CENTER", 0.5, 0)
		
		parangon.leftButtons[55565]:SetPoint("LEFT", 20, parangon.buttonsCoords.global.pos_y - 120)
		parangon.leftButtonsArt[55565]:SetPoint("CENTER", 0, 0)
		parangon.centerButtons[55565]:SetPoint("CENTER", 0, parangon.buttonsCoords.global.pos_y - 120)
		parangon.centerText[55565]:SetPoint("CENTER", -1, 1)
		parangon.rightButtons[55565]:SetPoint("Right", -20, parangon.buttonsCoords.global.pos_y - 120)
		parangon.rightText[55565]:SetPoint("CENTER", 0.5, 0)
		
		parangon.leftButtons[9136]:SetPoint("LEFT", 20, parangon.buttonsCoords.global.pos_y - 180)
		parangon.leftButtonsArt[9136]:SetPoint("CENTER", 0, 0)
		parangon.centerButtons[9136]:SetPoint("CENTER", 0, parangon.buttonsCoords.global.pos_y - 180)
		parangon.centerText[9136]:SetPoint("CENTER", -1, 1)
		parangon.rightButtons[9136]:SetPoint("Right", -20, parangon.buttonsCoords.global.pos_y - 180)
		parangon.rightText[9136]:SetPoint("CENTER", 0.5, 0)
		
		
		parangon.leftButtons[1502002]:SetPoint("LEFT", 20, parangon.buttonsCoords.global.pos_y)
		parangon.leftButtonsArt[1502002]:SetPoint("CENTER", 0, 0)
		parangon.centerButtons[1502002]:SetPoint("CENTER", 0, parangon.buttonsCoords.global.pos_y)
		parangon.centerText[1502002]:SetPoint("CENTER", -1, 1)
		parangon.rightButtons[1502002]:SetPoint("Right", -20, parangon.buttonsCoords.global.pos_y)
		parangon.rightText[1502002]:SetPoint("CENTER", 0.5, 0)
		
		parangon.leftButtons[7511]:SetPoint("LEFT", 20, parangon.buttonsCoords.global.pos_y - 60)
		parangon.leftButtonsArt[7511]:SetPoint("CENTER", 0, 0)
		parangon.centerButtons[7511]:SetPoint("CENTER", 0, parangon.buttonsCoords.global.pos_y - 60)
		parangon.centerText[7511]:SetPoint("CENTER", -1, 1)
		parangon.rightButtons[7511]:SetPoint("Right", -20, parangon.buttonsCoords.global.pos_y - 60)
		parangon.rightText[7511]:SetPoint("CENTER", 0.5, 0)
		
		parangon.leftButtons[13665]:SetPoint("LEFT", 20, parangon.buttonsCoords.global.pos_y - 120)
		parangon.leftButtonsArt[13665]:SetPoint("CENTER", 0, 0)
		parangon.centerButtons[13665]:SetPoint("CENTER", 0, parangon.buttonsCoords.global.pos_y - 120)
		parangon.centerText[13665]:SetPoint("CENTER", -1, 1)
		parangon.rightButtons[13665]:SetPoint("Right", -20, parangon.buttonsCoords.global.pos_y - 120)
		parangon.rightText[13665]:SetPoint("CENTER", 0.5, 0)
		
		parangon.leftButtons[27949]:SetPoint("LEFT", 20, parangon.buttonsCoords.global.pos_y - 180)
		parangon.leftButtonsArt[27949]:SetPoint("CENTER", 0, 0)
		parangon.centerButtons[27949]:SetPoint("CENTER", 0, parangon.buttonsCoords.global.pos_y - 180)
		parangon.centerText[27949]:SetPoint("CENTER", -1, 1)
		parangon.rightButtons[27949]:SetPoint("Right", -20, parangon.buttonsCoords.global.pos_y - 180)
		parangon.rightText[27949]:SetPoint("CENTER", 0.5, 0)
		
		
		parangon.leftButtons[18672]:SetPoint("LEFT", 20, parangon.buttonsCoords.global.pos_y)
		parangon.leftButtonsArt[18672]:SetPoint("CENTER", 0, 0)
		parangon.centerButtons[18672]:SetPoint("CENTER", 0, parangon.buttonsCoords.global.pos_y)
		parangon.centerText[18672]:SetPoint("CENTER", -1, 1)
		parangon.rightButtons[18672]:SetPoint("Right", -20, parangon.buttonsCoords.global.pos_y)
		parangon.rightText[18672]:SetPoint("CENTER", 0.5, 0)
		
		parangon.leftButtons[9760]:SetPoint("LEFT", 20, parangon.buttonsCoords.global.pos_y - 60)
		parangon.leftButtonsArt[9760]:SetPoint("CENTER", 0, 0)
		parangon.centerButtons[9760]:SetPoint("CENTER", 0, parangon.buttonsCoords.global.pos_y - 60)
		parangon.centerText[9760]:SetPoint("CENTER", -1, 1)
		parangon.rightButtons[9760]:SetPoint("Right", -20, parangon.buttonsCoords.global.pos_y - 60)
		parangon.rightText[9760]:SetPoint("CENTER", 0.5, 0)
		
		parangon.leftButtons[46412]:SetPoint("LEFT", 20, parangon.buttonsCoords.global.pos_y - 120)
		parangon.leftButtonsArt[46412]:SetPoint("CENTER", 0, 0)
		parangon.centerButtons[46412]:SetPoint("CENTER", 0, parangon.buttonsCoords.global.pos_y - 120)
		parangon.centerText[46412]:SetPoint("CENTER", -1, 1)
		parangon.rightButtons[46412]:SetPoint("Right", -20, parangon.buttonsCoords.global.pos_y - 120)
		parangon.rightText[46412]:SetPoint("CENTER", 0.5, 0)
		
		parangon.leftButtons[15464]:SetPoint("LEFT", 20, parangon.buttonsCoords.global.pos_y - 180)
		parangon.leftButtonsArt[15464]:SetPoint("CENTER", 0, 0)
		parangon.centerButtons[15464]:SetPoint("CENTER", 0, parangon.buttonsCoords.global.pos_y - 180)
		parangon.centerText[15464]:SetPoint("CENTER", -1, 1)
		parangon.rightButtons[15464]:SetPoint("Right", -20, parangon.buttonsCoords.global.pos_y - 180)
		parangon.rightText[15464]:SetPoint("CENTER", 0.5, 0)
		
		parangon.leftButtons[7464]:Show()
		parangon.leftButtonsTexture[7464]:Show()
		parangon.leftButtonsArt[7464]:Show()
		parangon.centerButtons[7464]:Show()
		parangon.centerText[7464]:Show()
		parangon.rightButtons[7464]:Show()
		parangon.rightText[7464]:Show()
		parangon.rightButtonsTexture[7464]:Show()
		
		parangon.leftButtons[7471]:Show()
		parangon.leftButtonsTexture[7471]:Show()
		parangon.leftButtonsArt[7471]:Show()
		parangon.centerButtons[7471]:Show()
		parangon.centerText[7471]:Show()
		parangon.rightButtons[7471]:Show()
		parangon.rightText[7471]:Show()
		parangon.rightButtonsTexture[7471]:Show()
		
		parangon.leftButtons[7477]:Show()
		parangon.leftButtonsTexture[7477]:Show()
		parangon.leftButtonsArt[7477]:Show()
		parangon.centerButtons[7477]:Show()
		parangon.centerText[7477]:Show()
		parangon.rightButtons[7477]:Show()
		parangon.rightText[7477]:Show()
		parangon.rightButtonsTexture[7477]:Show()
		
		parangon.leftButtons[7468]:Show()
		parangon.leftButtonsTexture[7468]:Show()
		parangon.leftButtonsArt[7468]:Show()
		parangon.centerButtons[7468]:Show()
		parangon.centerText[7468]:Show()
		parangon.rightButtons[7468]:Show()
		parangon.rightText[7468]:Show()
		parangon.rightButtonsTexture[7468]:Show()
		
		parangon.leftButtons[7597]:Hide()
		parangon.leftButtonsTexture[7597]:Hide()
		parangon.leftButtonsArt[7597]:Hide()
		parangon.centerButtons[7597]:Hide()
		parangon.centerText[7597]:Hide()
		parangon.rightButtons[7597]:Hide()
		parangon.rightText[7597]:Hide()
		parangon.rightButtonsTexture[7597]:Hide()
		
		parangon.leftButtons[37728]:Hide()
		parangon.leftButtonsTexture[37728]:Hide()
		parangon.leftButtonsArt[37728]:Hide()
		parangon.centerButtons[37728]:Hide()
		parangon.centerText[37728]:Hide()
		parangon.rightButtons[37728]:Hide()
		parangon.rightText[37728]:Hide()
		parangon.rightButtonsTexture[37728]:Hide()
		
		parangon.leftButtons[55565]:Hide()
		parangon.leftButtonsTexture[55565]:Hide()
		parangon.leftButtonsArt[55565]:Hide()
		parangon.centerButtons[55565]:Hide()
		parangon.centerText[55565]:Hide()
		parangon.rightButtons[55565]:Hide()
		parangon.rightText[55565]:Hide()
		parangon.rightButtonsTexture[55565]:Hide()
		
		parangon.leftButtons[9136]:Hide()
		parangon.leftButtonsTexture[9136]:Hide()
		parangon.leftButtonsArt[9136]:Hide()
		parangon.centerButtons[9136]:Hide()
		parangon.centerText[9136]:Hide()
		parangon.rightButtons[9136]:Hide()
		parangon.rightText[9136]:Hide()
		parangon.rightButtonsTexture[9136]:Hide()
		
		parangon.leftButtons[1502002]:Hide()
		parangon.leftButtonsTexture[1502002]:Hide()
		parangon.leftButtonsArt[1502002]:Hide()
		parangon.centerButtons[1502002]:Hide()
		parangon.centerText[1502002]:Hide()
		parangon.rightButtons[1502002]:Hide()
		parangon.rightText[1502002]:Hide()
		parangon.rightButtonsTexture[1502002]:Hide()
		
		parangon.leftButtons[7511]:Hide()
		parangon.leftButtonsTexture[7511]:Hide()
		parangon.leftButtonsArt[7511]:Hide()
		parangon.centerButtons[7511]:Hide()
		parangon.centerText[7511]:Hide()
		parangon.rightButtons[7511]:Hide()
		parangon.rightText[7511]:Hide()
		parangon.rightButtonsTexture[7511]:Hide()
		
		parangon.leftButtons[13665]:Hide()
		parangon.leftButtonsTexture[13665]:Hide()
		parangon.leftButtonsArt[13665]:Hide()
		parangon.centerButtons[13665]:Hide()
		parangon.centerText[13665]:Hide()
		parangon.rightButtons[13665]:Hide()
		parangon.rightText[13665]:Hide()
		parangon.rightButtonsTexture[13665]:Hide()
		
		parangon.leftButtons[27949]:Hide()
		parangon.leftButtonsTexture[27949]:Hide()
		parangon.leftButtonsArt[27949]:Hide()
		parangon.centerButtons[27949]:Hide()
		parangon.centerText[27949]:Hide()
		parangon.rightButtons[27949]:Hide()
		parangon.rightText[27949]:Hide()
		parangon.rightButtonsTexture[27949]:Hide()
		
		parangon.leftButtons[18672]:Hide()
		parangon.leftButtonsTexture[18672]:Hide()
		parangon.leftButtonsArt[18672]:Hide()
		parangon.centerButtons[18672]:Hide()
		parangon.centerText[18672]:Hide()
		parangon.rightButtons[18672]:Hide()
		parangon.rightText[18672]:Hide()
		parangon.rightButtonsTexture[18672]:Hide()
		
		parangon.leftButtons[9760]:Hide()
		parangon.leftButtonsTexture[9760]:Hide()
		parangon.leftButtonsArt[9760]:Hide()
		parangon.centerButtons[9760]:Hide()
		parangon.centerText[9760]:Hide()
		parangon.rightButtons[9760]:Hide()
		parangon.rightText[9760]:Hide()
		parangon.rightButtonsTexture[9760]:Hide()
		
		parangon.leftButtons[46412]:Hide()
		parangon.leftButtonsTexture[46412]:Hide()
		parangon.leftButtonsArt[46412]:Hide()
		parangon.centerButtons[46412]:Hide()
		parangon.centerText[46412]:Hide()
		parangon.rightButtons[46412]:Hide()
		parangon.rightText[46412]:Hide()
		parangon.rightButtonsTexture[46412]:Hide()
		
		parangon.leftButtons[15464]:Hide()
		parangon.leftButtonsTexture[15464]:Hide()
		parangon.leftButtonsArt[15464]:Hide()
		parangon.centerButtons[15464]:Hide()
		parangon.centerText[15464]:Hide()
		parangon.rightButtons[15464]:Hide()
		parangon.rightText[15464]:Hide()
		parangon.rightButtonsTexture[15464]:Hide()
	end)
	
	parangon.NextButton1:SetScript("OnMouseUp", function(self, button, down)
		if (button == "LeftButton") then
		parangon.leftButtons[7464]:Show()
		parangon.leftButtonsTexture[7464]:Show()
		parangon.leftButtonsArt[7464]:Show()
		parangon.centerButtons[7464]:Show()
		parangon.centerText[7464]:Show()
		parangon.rightButtons[7464]:Show()
		parangon.rightText[7464]:Show()
		parangon.rightButtonsTexture[7464]:Show()
		
		parangon.leftButtons[7471]:Show()
		parangon.leftButtonsTexture[7471]:Show()
		parangon.leftButtonsArt[7471]:Show()
		parangon.centerButtons[7471]:Show()
		parangon.centerText[7471]:Show()
		parangon.rightButtons[7471]:Show()
		parangon.rightText[7471]:Show()
		parangon.rightButtonsTexture[7471]:Show()
		
		parangon.leftButtons[7477]:Show()
		parangon.leftButtonsTexture[7477]:Show()
		parangon.leftButtonsArt[7477]:Show()
		parangon.centerButtons[7477]:Show()
		parangon.centerText[7477]:Show()
		parangon.rightButtons[7477]:Show()
		parangon.rightText[7477]:Show()
		parangon.rightButtonsTexture[7477]:Show()
		
		parangon.leftButtons[7468]:Show()
		parangon.leftButtonsTexture[7468]:Show()
		parangon.leftButtonsArt[7468]:Show()
		parangon.centerButtons[7468]:Show()
		parangon.centerText[7468]:Show()
		parangon.rightButtons[7468]:Show()
		parangon.rightText[7468]:Show()
		parangon.rightButtonsTexture[7468]:Show()
		
		parangon.leftButtons[7597]:Hide()
		parangon.leftButtonsTexture[7597]:Hide()
		parangon.leftButtonsArt[7597]:Hide()
		parangon.centerButtons[7597]:Hide()
		parangon.centerText[7597]:Hide()
		parangon.rightButtons[7597]:Hide()
		parangon.rightText[7597]:Hide()
		parangon.rightButtonsTexture[7597]:Hide()
		
		parangon.leftButtons[37728]:Hide()
		parangon.leftButtonsTexture[37728]:Hide()
		parangon.leftButtonsArt[37728]:Hide()
		parangon.centerButtons[37728]:Hide()
		parangon.centerText[37728]:Hide()
		parangon.rightButtons[37728]:Hide()
		parangon.rightText[37728]:Hide()
		parangon.rightButtonsTexture[37728]:Hide()
		
		parangon.leftButtons[55565]:Hide()
		parangon.leftButtonsTexture[55565]:Hide()
		parangon.leftButtonsArt[55565]:Hide()
		parangon.centerButtons[55565]:Hide()
		parangon.centerText[55565]:Hide()
		parangon.rightButtons[55565]:Hide()
		parangon.rightText[55565]:Hide()
		parangon.rightButtonsTexture[55565]:Hide()
		
		parangon.leftButtons[9136]:Hide()
		parangon.leftButtonsTexture[9136]:Hide()
		parangon.leftButtonsArt[9136]:Hide()
		parangon.centerButtons[9136]:Hide()
		parangon.centerText[9136]:Hide()
		parangon.rightButtons[9136]:Hide()
		parangon.rightText[9136]:Hide()
		parangon.rightButtonsTexture[9136]:Hide()
		
		parangon.leftButtons[1502002]:Hide()
		parangon.leftButtonsTexture[1502002]:Hide()
		parangon.leftButtonsArt[1502002]:Hide()
		parangon.centerButtons[1502002]:Hide()
		parangon.centerText[1502002]:Hide()
		parangon.rightButtons[1502002]:Hide()
		parangon.rightText[1502002]:Hide()
		parangon.rightButtonsTexture[1502002]:Hide()
		
		parangon.leftButtons[7511]:Hide()
		parangon.leftButtonsTexture[7511]:Hide()
		parangon.leftButtonsArt[7511]:Hide()
		parangon.centerButtons[7511]:Hide()
		parangon.centerText[7511]:Hide()
		parangon.rightButtons[7511]:Hide()
		parangon.rightText[7511]:Hide()
		parangon.rightButtonsTexture[7511]:Hide()
		
		parangon.leftButtons[13665]:Hide()
		parangon.leftButtonsTexture[13665]:Hide()
		parangon.leftButtonsArt[13665]:Hide()
		parangon.centerButtons[13665]:Hide()
		parangon.centerText[13665]:Hide()
		parangon.rightButtons[13665]:Hide()
		parangon.rightText[13665]:Hide()
		parangon.rightButtonsTexture[13665]:Hide()
		
		parangon.leftButtons[27949]:Hide()
		parangon.leftButtonsTexture[27949]:Hide()
		parangon.leftButtonsArt[27949]:Hide()
		parangon.centerButtons[27949]:Hide()
		parangon.centerText[27949]:Hide()
		parangon.rightButtons[27949]:Hide()
		parangon.rightText[27949]:Hide()
		parangon.rightButtonsTexture[27949]:Hide()
		
		parangon.leftButtons[18672]:Hide()
		parangon.leftButtonsTexture[18672]:Hide()
		parangon.leftButtonsArt[18672]:Hide()
		parangon.centerButtons[18672]:Hide()
		parangon.centerText[18672]:Hide()
		parangon.rightButtons[18672]:Hide()
		parangon.rightText[18672]:Hide()
		parangon.rightButtonsTexture[18672]:Hide()
		
		parangon.leftButtons[9760]:Hide()
		parangon.leftButtonsTexture[9760]:Hide()
		parangon.leftButtonsArt[9760]:Hide()
		parangon.centerButtons[9760]:Hide()
		parangon.centerText[9760]:Hide()
		parangon.rightButtons[9760]:Hide()
		parangon.rightText[9760]:Hide()
		parangon.rightButtonsTexture[9760]:Hide()
		
		parangon.leftButtons[46412]:Hide()
		parangon.leftButtonsTexture[46412]:Hide()
		parangon.leftButtonsArt[46412]:Hide()
		parangon.centerButtons[46412]:Hide()
		parangon.centerText[46412]:Hide()
		parangon.rightButtons[46412]:Hide()
		parangon.rightText[46412]:Hide()
		parangon.rightButtonsTexture[46412]:Hide()
		
		parangon.leftButtons[15464]:Hide()
		parangon.leftButtonsTexture[15464]:Hide()
		parangon.leftButtonsArt[15464]:Hide()
		parangon.centerButtons[15464]:Hide()
		parangon.centerText[15464]:Hide()
		parangon.rightButtons[15464]:Hide()
		parangon.rightText[15464]:Hide()
		parangon.rightButtonsTexture[15464]:Hide()
		end
	end)
	parangon.NextButton1:SetScript("OnEnter", function(self) parangon.NextButton1:SetAlpha(1.0) end)
	parangon.NextButton1:SetScript("OnLeave", function(self) parangon.NextButton1:SetAlpha(0.5) end)
	
	
	
	
parangon.NextButton2 = CreateFrame("Button", parangon.NextButton2, parangon.mainWindow, nil)
  parangon.NextButton2:SetSize(25, 25)
  parangon.NextButton2:SetPoint("BOTTOM", -25, 68.75)
  parangon.NextButton2:SetNormalTexture("Interface/GLUES/PageNumbers/UI-PageNumber-2")
  parangon.NextButton2:SetFrameLevel(3)
	
	parangon.NextButton2:SetScript("OnMouseUp", function(self, button, down)
		if (button == "LeftButton") then
		parangon.leftButtons[7464]:Hide()
		parangon.leftButtonsTexture[7464]:Hide()
		parangon.leftButtonsArt[7464]:Hide()
		parangon.centerButtons[7464]:Hide()
		parangon.centerText[7464]:Hide()
		parangon.rightButtons[7464]:Hide()
		parangon.rightText[7464]:Hide()
		parangon.rightButtonsTexture[7464]:Hide()
		
		parangon.leftButtons[7471]:Hide()
		parangon.leftButtonsTexture[7471]:Hide()
		parangon.leftButtonsArt[7471]:Hide()
		parangon.centerButtons[7471]:Hide()
		parangon.centerText[7471]:Hide()
		parangon.rightButtons[7471]:Hide()
		parangon.rightText[7471]:Hide()
		parangon.rightButtonsTexture[7471]:Hide()
		
		parangon.leftButtons[7477]:Hide()
		parangon.leftButtonsTexture[7477]:Hide()
		parangon.leftButtonsArt[7477]:Hide()
		parangon.centerButtons[7477]:Hide()
		parangon.centerText[7477]:Hide()
		parangon.rightButtons[7477]:Hide()
		parangon.rightText[7477]:Hide()
		parangon.rightButtonsTexture[7477]:Hide()
		
		parangon.leftButtons[7468]:Hide()
		parangon.leftButtonsTexture[7468]:Hide()
		parangon.leftButtonsArt[7468]:Hide()
		parangon.centerButtons[7468]:Hide()
		parangon.centerText[7468]:Hide()
		parangon.rightButtons[7468]:Hide()
		parangon.rightText[7468]:Hide()
		parangon.rightButtonsTexture[7468]:Hide()
		
		parangon.leftButtons[7597]:Show()
		parangon.leftButtonsTexture[7597]:Show()
		parangon.leftButtonsArt[7597]:Show()
		parangon.centerButtons[7597]:Show()
		parangon.centerText[7597]:Show()
		parangon.rightButtons[7597]:Show()
		parangon.rightText[7597]:Show()
		parangon.rightButtonsTexture[7597]:Show()
		
		parangon.leftButtons[37728]:Show()
		parangon.leftButtonsTexture[37728]:Show()
		parangon.leftButtonsArt[37728]:Show()
		parangon.centerButtons[37728]:Show()
		parangon.centerText[37728]:Show()
		parangon.rightButtons[37728]:Show()
		parangon.rightText[37728]:Show()
		parangon.rightButtonsTexture[37728]:Show()
		
		parangon.leftButtons[55565]:Show()
		parangon.leftButtonsTexture[55565]:Show()
		parangon.leftButtonsArt[55565]:Show()
		parangon.centerButtons[55565]:Show()
		parangon.centerText[55565]:Show()
		parangon.rightButtons[55565]:Show()
		parangon.rightText[55565]:Show()
		parangon.rightButtonsTexture[55565]:Show()
		
		parangon.leftButtons[9136]:Show()
		parangon.leftButtonsTexture[9136]:Show()
		parangon.leftButtonsArt[9136]:Show()
		parangon.centerButtons[9136]:Show()
		parangon.centerText[9136]:Show()
		parangon.rightButtons[9136]:Show()
		parangon.rightText[9136]:Show()
		parangon.rightButtonsTexture[9136]:Show()
		
		parangon.leftButtons[1502002]:Hide()
		parangon.leftButtonsTexture[1502002]:Hide()
		parangon.leftButtonsArt[1502002]:Hide()
		parangon.centerButtons[1502002]:Hide()
		parangon.centerText[1502002]:Hide()
		parangon.rightButtons[1502002]:Hide()
		parangon.rightText[1502002]:Hide()
		parangon.rightButtonsTexture[1502002]:Hide()
		
		parangon.leftButtons[7511]:Hide()
		parangon.leftButtonsTexture[7511]:Hide()
		parangon.leftButtonsArt[7511]:Hide()
		parangon.centerButtons[7511]:Hide()
		parangon.centerText[7511]:Hide()
		parangon.rightButtons[7511]:Hide()
		parangon.rightText[7511]:Hide()
		parangon.rightButtonsTexture[7511]:Hide()
		
		parangon.leftButtons[13665]:Hide()
		parangon.leftButtonsTexture[13665]:Hide()
		parangon.leftButtonsArt[13665]:Hide()
		parangon.centerButtons[13665]:Hide()
		parangon.centerText[13665]:Hide()
		parangon.rightButtons[13665]:Hide()
		parangon.rightText[13665]:Hide()
		parangon.rightButtonsTexture[13665]:Hide()
		
		parangon.leftButtons[27949]:Hide()
		parangon.leftButtonsTexture[27949]:Hide()
		parangon.leftButtonsArt[27949]:Hide()
		parangon.centerButtons[27949]:Hide()
		parangon.centerText[27949]:Hide()
		parangon.rightButtons[27949]:Hide()
		parangon.rightText[27949]:Hide()
		parangon.rightButtonsTexture[27949]:Hide()
		
		parangon.leftButtons[18672]:Hide()
		parangon.leftButtonsTexture[18672]:Hide()
		parangon.leftButtonsArt[18672]:Hide()
		parangon.centerButtons[18672]:Hide()
		parangon.centerText[18672]:Hide()
		parangon.rightButtons[18672]:Hide()
		parangon.rightText[18672]:Hide()
		parangon.rightButtonsTexture[18672]:Hide()
		
		parangon.leftButtons[9760]:Hide()
		parangon.leftButtonsTexture[9760]:Hide()
		parangon.leftButtonsArt[9760]:Hide()
		parangon.centerButtons[9760]:Hide()
		parangon.centerText[9760]:Hide()
		parangon.rightButtons[9760]:Hide()
		parangon.rightText[9760]:Hide()
		parangon.rightButtonsTexture[9760]:Hide()
		
		parangon.leftButtons[46412]:Hide()
		parangon.leftButtonsTexture[46412]:Hide()
		parangon.leftButtonsArt[46412]:Hide()
		parangon.centerButtons[46412]:Hide()
		parangon.centerText[46412]:Hide()
		parangon.rightButtons[46412]:Hide()
		parangon.rightText[46412]:Hide()
		parangon.rightButtonsTexture[46412]:Hide()
		
		parangon.leftButtons[15464]:Hide()
		parangon.leftButtonsTexture[15464]:Hide()
		parangon.leftButtonsArt[15464]:Hide()
		parangon.centerButtons[15464]:Hide()
		parangon.centerText[15464]:Hide()
		parangon.rightButtons[15464]:Hide()
		parangon.rightText[15464]:Hide()
		parangon.rightButtonsTexture[15464]:Hide()
		end
	end)
	parangon.NextButton2:SetScript("OnEnter", function(self) parangon.NextButton2:SetAlpha(1.0) end)
	parangon.NextButton2:SetScript("OnLeave", function(self) parangon.NextButton2:SetAlpha(0.5) end)
	
	
	
	
parangon.NextButton3 = CreateFrame("Button", parangon.NextButton3, parangon.mainWindow, nil)
  parangon.NextButton3:SetSize(25, 25)
  parangon.NextButton3:SetPoint("BOTTOM", 25, 68.75)
  parangon.NextButton3:SetNormalTexture("Interface/GLUES/PageNumbers/UI-PageNumber-3")
  parangon.NextButton3:SetFrameLevel(3)
	
	parangon.NextButton3:SetScript("OnMouseUp", function(self, button, down)
		if (button == "LeftButton") then
		parangon.leftButtons[7464]:Hide()
		parangon.leftButtonsTexture[7464]:Hide()
		parangon.leftButtonsArt[7464]:Hide()
		parangon.centerButtons[7464]:Hide()
		parangon.centerText[7464]:Hide()
		parangon.rightButtons[7464]:Hide()
		parangon.rightText[7464]:Hide()
		parangon.rightButtonsTexture[7464]:Hide()
		
		parangon.leftButtons[7471]:Hide()
		parangon.leftButtonsTexture[7471]:Hide()
		parangon.leftButtonsArt[7471]:Hide()
		parangon.centerButtons[7471]:Hide()
		parangon.centerText[7471]:Hide()
		parangon.rightButtons[7471]:Hide()
		parangon.rightText[7471]:Hide()
		parangon.rightButtonsTexture[7471]:Hide()
		
		parangon.leftButtons[7477]:Hide()
		parangon.leftButtonsTexture[7477]:Hide()
		parangon.leftButtonsArt[7477]:Hide()
		parangon.centerButtons[7477]:Hide()
		parangon.centerText[7477]:Hide()
		parangon.rightButtons[7477]:Hide()
		parangon.rightText[7477]:Hide()
		parangon.rightButtonsTexture[7477]:Hide()
		
		parangon.leftButtons[7468]:Hide()
		parangon.leftButtonsTexture[7468]:Hide()
		parangon.leftButtonsArt[7468]:Hide()
		parangon.centerButtons[7468]:Hide()
		parangon.centerText[7468]:Hide()
		parangon.rightButtons[7468]:Hide()
		parangon.rightText[7468]:Hide()
		parangon.rightButtonsTexture[7468]:Hide()
		
		parangon.leftButtons[7597]:Hide()
		parangon.leftButtonsTexture[7597]:Hide()
		parangon.leftButtonsArt[7597]:Hide()
		parangon.centerButtons[7597]:Hide()
		parangon.centerText[7597]:Hide()
		parangon.rightButtons[7597]:Hide()
		parangon.rightText[7597]:Hide()
		parangon.rightButtonsTexture[7597]:Hide()
		
		parangon.leftButtons[37728]:Hide()
		parangon.leftButtonsTexture[37728]:Hide()
		parangon.leftButtonsArt[37728]:Hide()
		parangon.centerButtons[37728]:Hide()
		parangon.centerText[37728]:Hide()
		parangon.rightButtons[37728]:Hide()
		parangon.rightText[37728]:Hide()
		parangon.rightButtonsTexture[37728]:Hide()
		
		parangon.leftButtons[55565]:Hide()
		parangon.leftButtonsTexture[55565]:Hide()
		parangon.leftButtonsArt[55565]:Hide()
		parangon.centerButtons[55565]:Hide()
		parangon.centerText[55565]:Hide()
		parangon.rightButtons[55565]:Hide()
		parangon.rightText[55565]:Hide()
		parangon.rightButtonsTexture[55565]:Hide()
		
		parangon.leftButtons[9136]:Hide()
		parangon.leftButtonsTexture[9136]:Hide()
		parangon.leftButtonsArt[9136]:Hide()
		parangon.centerButtons[9136]:Hide()
		parangon.centerText[9136]:Hide()
		parangon.rightButtons[9136]:Hide()
		parangon.rightText[9136]:Hide()
		parangon.rightButtonsTexture[9136]:Hide()
		
		parangon.leftButtons[1502002]:Show()
		parangon.leftButtonsTexture[1502002]:Show()
		parangon.leftButtonsArt[1502002]:Show()
		parangon.centerButtons[1502002]:Show()
		parangon.centerText[1502002]:Show()
		parangon.rightButtons[1502002]:Show()
		parangon.rightText[1502002]:Show()
		parangon.rightButtonsTexture[1502002]:Show()
		
		parangon.leftButtons[7511]:Show()
		parangon.leftButtonsTexture[7511]:Show()
		parangon.leftButtonsArt[7511]:Show()
		parangon.centerButtons[7511]:Show()
		parangon.centerText[7511]:Show()
		parangon.rightButtons[7511]:Show()
		parangon.rightText[7511]:Show()
		parangon.rightButtonsTexture[7511]:Show()
		
		parangon.leftButtons[13665]:Show()
		parangon.leftButtonsTexture[13665]:Show()
		parangon.leftButtonsArt[13665]:Show()
		parangon.centerButtons[13665]:Show()
		parangon.centerText[13665]:Show()
		parangon.rightButtons[13665]:Show()
		parangon.rightText[13665]:Show()
		parangon.rightButtonsTexture[13665]:Show()
		
		parangon.leftButtons[27949]:Show()
		parangon.leftButtonsTexture[27949]:Show()
		parangon.leftButtonsArt[27949]:Show()
		parangon.centerButtons[27949]:Show()
		parangon.centerText[27949]:Show()
		parangon.rightButtons[27949]:Show()
		parangon.rightText[27949]:Show()
		parangon.rightButtonsTexture[27949]:Show()
		
		parangon.leftButtons[18672]:Hide()
		parangon.leftButtonsTexture[18672]:Hide()
		parangon.leftButtonsArt[18672]:Hide()
		parangon.centerButtons[18672]:Hide()
		parangon.centerText[18672]:Hide()
		parangon.rightButtons[18672]:Hide()
		parangon.rightText[18672]:Hide()
		parangon.rightButtonsTexture[18672]:Hide()
		
		parangon.leftButtons[9760]:Hide()
		parangon.leftButtonsTexture[9760]:Hide()
		parangon.leftButtonsArt[9760]:Hide()
		parangon.centerButtons[9760]:Hide()
		parangon.centerText[9760]:Hide()
		parangon.rightButtons[9760]:Hide()
		parangon.rightText[9760]:Hide()
		parangon.rightButtonsTexture[9760]:Hide()
		
		parangon.leftButtons[46412]:Hide()
		parangon.leftButtonsTexture[46412]:Hide()
		parangon.leftButtonsArt[46412]:Hide()
		parangon.centerButtons[46412]:Hide()
		parangon.centerText[46412]:Hide()
		parangon.rightButtons[46412]:Hide()
		parangon.rightText[46412]:Hide()
		parangon.rightButtonsTexture[46412]:Hide()
		
		parangon.leftButtons[15464]:Hide()
		parangon.leftButtonsTexture[15464]:Hide()
		parangon.leftButtonsArt[15464]:Hide()
		parangon.centerButtons[15464]:Hide()
		parangon.centerText[15464]:Hide()
		parangon.rightButtons[15464]:Hide()
		parangon.rightText[15464]:Hide()
		parangon.rightButtonsTexture[15464]:Hide()
		end
	end)
	parangon.NextButton3:SetScript("OnEnter", function(self) parangon.NextButton3:SetAlpha(1.0) end)
	parangon.NextButton3:SetScript("OnLeave", function(self) parangon.NextButton3:SetAlpha(0.5) end)
	
	
	
	
parangon.NextButton4 = CreateFrame("Button", parangon.NextButton4, parangon.mainWindow, nil)
  parangon.NextButton4:SetSize(25, 25)
  parangon.NextButton4:SetPoint("BOTTOM", 75, 68.75)
  parangon.NextButton4:SetNormalTexture("Interface/GLUES/PageNumbers/UI-PageNumber-4")
  parangon.NextButton4:SetFrameLevel(3)
	
	parangon.NextButton4:SetScript("OnMouseUp", function(self, button, down)
		if (button == "LeftButton") then
		parangon.leftButtons[7464]:Hide()
		parangon.leftButtonsTexture[7464]:Hide()
		parangon.leftButtonsArt[7464]:Hide()
		parangon.centerButtons[7464]:Hide()
		parangon.centerText[7464]:Hide()
		parangon.rightButtons[7464]:Hide()
		parangon.rightText[7464]:Hide()
		parangon.rightButtonsTexture[7464]:Hide()
		
		parangon.leftButtons[7471]:Hide()
		parangon.leftButtonsTexture[7471]:Hide()
		parangon.leftButtonsArt[7471]:Hide()
		parangon.centerButtons[7471]:Hide()
		parangon.centerText[7471]:Hide()
		parangon.rightButtons[7471]:Hide()
		parangon.rightText[7471]:Hide()
		parangon.rightButtonsTexture[7471]:Hide()
		
		parangon.leftButtons[7477]:Hide()
		parangon.leftButtonsTexture[7477]:Hide()
		parangon.leftButtonsArt[7477]:Hide()
		parangon.centerButtons[7477]:Hide()
		parangon.centerText[7477]:Hide()
		parangon.rightButtons[7477]:Hide()
		parangon.rightText[7477]:Hide()
		parangon.rightButtonsTexture[7477]:Hide()
		
		parangon.leftButtons[7468]:Hide()
		parangon.leftButtonsTexture[7468]:Hide()
		parangon.leftButtonsArt[7468]:Hide()
		parangon.centerButtons[7468]:Hide()
		parangon.centerText[7468]:Hide()
		parangon.rightButtons[7468]:Hide()
		parangon.rightText[7468]:Hide()
		parangon.rightButtonsTexture[7468]:Hide()
		
		parangon.leftButtons[7597]:Hide()
		parangon.leftButtonsTexture[7597]:Hide()
		parangon.leftButtonsArt[7597]:Hide()
		parangon.centerButtons[7597]:Hide()
		parangon.centerText[7597]:Hide()
		parangon.rightButtons[7597]:Hide()
		parangon.rightText[7597]:Hide()
		parangon.rightButtonsTexture[7597]:Hide()
		
		parangon.leftButtons[37728]:Hide()
		parangon.leftButtonsTexture[37728]:Hide()
		parangon.leftButtonsArt[37728]:Hide()
		parangon.centerButtons[37728]:Hide()
		parangon.centerText[37728]:Hide()
		parangon.rightButtons[37728]:Hide()
		parangon.rightText[37728]:Hide()
		parangon.rightButtonsTexture[37728]:Hide()
		
		parangon.leftButtons[55565]:Hide()
		parangon.leftButtonsTexture[55565]:Hide()
		parangon.leftButtonsArt[55565]:Hide()
		parangon.centerButtons[55565]:Hide()
		parangon.centerText[55565]:Hide()
		parangon.rightButtons[55565]:Hide()
		parangon.rightText[55565]:Hide()
		parangon.rightButtonsTexture[55565]:Hide()
		
		parangon.leftButtons[9136]:Hide()
		parangon.leftButtonsTexture[9136]:Hide()
		parangon.leftButtonsArt[9136]:Hide()
		parangon.centerButtons[9136]:Hide()
		parangon.centerText[9136]:Hide()
		parangon.rightButtons[9136]:Hide()
		parangon.rightText[9136]:Hide()
		parangon.rightButtonsTexture[9136]:Hide()
		
		parangon.leftButtons[1502002]:Hide()
		parangon.leftButtonsTexture[1502002]:Hide()
		parangon.leftButtonsArt[1502002]:Hide()
		parangon.centerButtons[1502002]:Hide()
		parangon.centerText[1502002]:Hide()
		parangon.rightButtons[1502002]:Hide()
		parangon.rightText[1502002]:Hide()
		parangon.rightButtonsTexture[1502002]:Hide()
		
		parangon.leftButtons[7511]:Hide()
		parangon.leftButtonsTexture[7511]:Hide()
		parangon.leftButtonsArt[7511]:Hide()
		parangon.centerButtons[7511]:Hide()
		parangon.centerText[7511]:Hide()
		parangon.rightButtons[7511]:Hide()
		parangon.rightText[7511]:Hide()
		parangon.rightButtonsTexture[7511]:Hide()
		
		parangon.leftButtons[13665]:Hide()
		parangon.leftButtonsTexture[13665]:Hide()
		parangon.leftButtonsArt[13665]:Hide()
		parangon.centerButtons[13665]:Hide()
		parangon.centerText[13665]:Hide()
		parangon.rightButtons[13665]:Hide()
		parangon.rightText[13665]:Hide()
		parangon.rightButtonsTexture[13665]:Hide()
		
		parangon.leftButtons[27949]:Hide()
		parangon.leftButtonsTexture[27949]:Hide()
		parangon.leftButtonsArt[27949]:Hide()
		parangon.centerButtons[27949]:Hide()
		parangon.centerText[27949]:Hide()
		parangon.rightButtons[27949]:Hide()
		parangon.rightText[27949]:Hide()
		parangon.rightButtonsTexture[27949]:Hide()
		
		parangon.leftButtons[18672]:Show()
		parangon.leftButtonsTexture[18672]:Show()
		parangon.leftButtonsArt[18672]:Show()
		parangon.centerButtons[18672]:Show()
		parangon.centerText[18672]:Show()
		parangon.rightButtons[18672]:Show()
		parangon.rightText[18672]:Show()
		parangon.rightButtonsTexture[18672]:Show()
		
		parangon.leftButtons[9760]:Show()
		parangon.leftButtonsTexture[9760]:Show()
		parangon.leftButtonsArt[9760]:Show()
		parangon.centerButtons[9760]:Show()
		parangon.centerText[9760]:Show()
		parangon.rightButtons[9760]:Show()
		parangon.rightText[9760]:Show()
		parangon.rightButtonsTexture[9760]:Show()
		
		parangon.leftButtons[46412]:Show()
		parangon.leftButtonsTexture[46412]:Show()
		parangon.leftButtonsArt[46412]:Show()
		parangon.centerButtons[46412]:Show()
		parangon.centerText[46412]:Show()
		parangon.rightButtons[46412]:Show()
		parangon.rightText[46412]:Show()
		parangon.rightButtonsTexture[46412]:Show()
		
		parangon.leftButtons[15464]:Show()
		parangon.leftButtonsTexture[15464]:Show()
		parangon.leftButtonsArt[15464]:Show()
		parangon.centerButtons[15464]:Show()
		parangon.centerText[15464]:Show()
		parangon.rightButtons[15464]:Show()
		parangon.rightText[15464]:Show()
		parangon.rightButtonsTexture[15464]:Show()
		end
	end)
	parangon.NextButton4:SetScript("OnEnter", function(self) parangon.NextButton4:SetAlpha(1.0) end)
	parangon.NextButton4:SetScript("OnLeave", function(self) parangon.NextButton4:SetAlpha(0.5) end)
end

parangon.pointsLeft = parangon.mainWindow:CreateFontString(parangon.pointsLeft)
  parangon.pointsLeft:SetFont("Fonts/FRIZQT__.TTF", 12)
  parangon.pointsLeft:SetSize(999, 3)
  parangon.pointsLeft:SetPoint("BOTTOM", 0, 56.25)
  parangon.pointsLeft:SetShadowColor(0, 0, 0)
  parangon.pointsLeft:SetShadowOffset(1, 1)

parangon.saveButton = CreateFrame("Button", parangon.saveButton, parangon.mainWindow)
  parangon.saveButton:SetSize(150, 35)
  parangon.saveButton:SetNormalTexture("Interface/buttons/ui-dialogbox-button-gold-up")
  parangon.saveButton:SetHighlightTexture("Interface/buttons/ui-dialogbox-button-highlight")
  parangon.saveButton:SetPushedTexture("Interface/buttons/ui-dialogbox-button-gold-down")
  parangon.saveButton:SetPoint("BOTTOM", 0, 11.25)
  parangon.saveButton:SetFrameLevel(2)

parangon.saveButton:SetScript("OnMouseUp", function(self, button, down)
  if (button == "LeftButton") then
    parangon.mainWindow:Hide()
    AIO.Handle("AIO_Parangon", "setStats")
  end
end)

parangon.saveButtonText = parangon.saveButton:CreateFontString(parangon.saveButtonText)
  parangon.saveButtonText:SetFont("Fonts/FRIZQT__.TTF", 12)
  parangon.saveButtonText:SetSize(180, 3)
  parangon.saveButtonText:SetPoint("CENTER", 0, 6)
  parangon.saveButtonText:SetText("|CFFFFFFFFAccepter|r")
  parangon.saveButtonText:SetShadowColor(0, 0, 0)
  parangon.saveButtonText:SetShadowOffset(0.5, 0.5)

parangon.characterFrameContainer = CreateFrame("Frame", parangon.characterFrameContainer, CharacterFrame);
  parangon.characterFrameContainer:SetSize(55, 55)
  parangon.characterFrameContainer:RegisterForDrag("LeftButton")
  parangon.characterFrameContainer:SetPoint("TOP", 125, 52)
  parangon.characterFrameContainer:SetBackdrop({
    bgFile = "Interface/bankframe/bank-background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    edgeSize = 20,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
  })
  parangon.characterFrameContainer:SetFrameLevel(5)
  parangon.characterFrameContainer:SetMovable(false)
  parangon.characterFrameContainer:EnableMouse(true)
  parangon.characterFrameContainer:SetClampedToScreen(true)
  parangon.characterFrameContainer:SetScript("OnDragStart", parangon.characterFrameContainer.StartMoving)
  parangon.characterFrameContainer:SetScript("OnHide", parangon.characterFrameContainer.StopMovingOrSizing)
  parangon.characterFrameContainer:SetScript("OnDragStop", parangon.characterFrameContainer.StopMovingOrSizing)

parangon.characterFrameBorder = CreateFrame("Button", parangon.characterFrameBorder, parangon.characterFrameContainer)
  parangon.characterFrameBorder:SetSize(50, 50)
  parangon.characterFrameBorder:SetNormalTexture("Interface/parangon/ButtonBorder")
  parangon.characterFrameBorder:SetHighlightTexture("Interface/parangon/ButtonBorder_Hover")
  parangon.characterFrameBorder:SetPushedTexture("Interface/parangon/ButtonBorder_Push")
  parangon.characterFrameBorder:SetPoint("CENTER", 0, 0)
  parangon.characterFrameBorder:EnableMouseWheel(1)
  parangon.characterFrameBorder:SetFrameLevel(1000)
  parangon.characterFrameBorder:SetFrameLevel(7)

  parangon.characterFrameBorder:SetScript("OnEnter", function(self, button, down)
    GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR", 1, 5)
    GameTooltip:AddLine("Statistiques Parangon", 1, 1, 1)
    GameTooltip:AddLine(""..parangon.pointsLeft:GetText().."\n")
	GameTooltip:AddLine("Affiche/masque la fenêtre d'attribution des points de Parangon.\n")
	GameTooltip:AddLine("Clic droit ou gauche/molette ajuste les points de Parangon\n")

    for spellid, subtable in pairs(parangon.spellsList) do
      GameTooltip:AddLine("|CFFFFFFFF+ "..parangon.rightText[spellid]:GetText().."|CFFFFFFFF "..subtable.name.."|r");
    end
    GameTooltip:AddLine("\n|CFFFFFFFF"..parangon.expText:GetText().."|r");

    GameTooltip:Show()
  end)

  parangon.characterFrameBorder:SetScript("OnLeave", function (self, button, down)
    GameTooltip:Hide()
  end)

  parangon.characterFrameBorder:SetScript("OnMouseUp", function (self, button, down)
    if(parangon.mainWindow:IsShown())then
      parangon.mainWindow:Hide()
    else
      parangon.mainWindow:Show()
    end
  end)

parangon.characterFrameBackground = CreateFrame("Frame", parangon.characterFrameBackground, parangon.characterFrameBorder)
  parangon.characterFrameBackground:SetSize(39, 39)
  parangon.characterFrameBackground:SetBackdrop({
    bgFile = "Interface/Icons/_LLDAKnowledge",
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
  })
  parangon.characterFrameBackground:SetPoint("CENTER", 0, 0)
  parangon.characterFrameBackground:SetFrameLevel(6)

function parangon_addon.setInfo(player, stats, level, points, exps)
  for statid, value in pairs(stats) do
    parangon.rightText[statid]:SetText("|CFF00CE00" .. value)
  end

  parangon.levelText:SetText("|CFFFFFFFF" .. level)
  parangon.pointsLeft:SetText("Vous avez |CFFD70000" .. points .. "|r point(s) à dépenser.")

  parangon.expText:SetText("|CFFFFFFFF(".. exps.exp .. " / " .. exps.exp_max .. ")")
end
