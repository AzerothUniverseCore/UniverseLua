-- DestinyPandaClient.lua
local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local DestinyFactionHandlers = AIO.AddHandlers("DestinyFactionHandler", {})

local frame = CreateFrame("Frame", "DestinyPandaFrame", UIParent)
frame:SetSize(1000, 1000)
frame:SetPoint("CENTER")
frame:SetFrameLevel(100)
frame:SetMovable(false)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:Hide()

frame.bg = frame:CreateTexture(nil, "BACKGROUND")
frame.bg:SetAllPoints(true)
frame.bg:SetTexture("Interface/DestinyPandaUI/DestinyPandaUI.blp")

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", frame, "TOP", 0, -285)
title:SetText("Choisissez votre destin")
title:SetFont("Fonts\\morpheus.ttf", 32)
title:SetTextColor(42/255, 28/255, 16/255, 1)

local allianceLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
allianceLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 295, -325)
allianceLabel:SetText("L'Alliance")
allianceLabel:SetFont("Fonts\\morpheus.ttf", 20)
allianceLabel:SetTextColor(50/255, 40/255, 30/255, 1)

local hordeLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
hordeLabel:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -315, -325)
hordeLabel:SetText("La Horde")
hordeLabel:SetFont("Fonts\\morpheus.ttf", 20)
hordeLabel:SetTextColor(50/255, 40/255, 30/255, 1)

local allianceText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
allianceText:SetPoint("TOPLEFT", frame, "TOPLEFT", 260, -375)
allianceText:SetText("Les nobles peuples de\nl'Alliance sont liés par leurs\ntraditions d'honneur, de\ngrandeur d'âme, de foi, de\njustice et de sacrifice.\n\nChacune des nations qui la\nconstituent oeuvre pour un\nmonde de paix et de justice,\nque ce soit par son savoir\ntechnique, sa maîtrise des\nArcanes ou sa sagesse\nspirituelle.\n\nRalliez-vous à la bannière de\nl'Alliance pour défendre ses\nidéaux partout en Azeroth et\nau-delà.\n\nPour l'Alliance !")
allianceText:SetFont("Fonts\\MARCELLUS.TTF", 24)
allianceText:SetWidth(200)
allianceText:SetJustifyH("LEFT")
allianceText:SetTextColor(60/255, 45/255, 35/255, 1)

local hordeText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
hordeText:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -260, -375)
hordeText:SetText("Les fières nations de la Horde\nsont regroupées en une\nalliance de circonstance\ncontre un monde hostile qui\nmenace de les anéantir.\n\nDéterminée, féroce et parfois\nmonstrueuse, la Horde a pour\nvaleurs la force et l'honneur\nmais doit lutter pour garder\nson aggressivité sous contrôle.\n\nRejoignez la Horde pour\nconstruire un monde où l'on\npuisse vivre libre.\n\nPour la Horde !")
hordeText:SetFont("Fonts\\MARCELLUS.TTF", 24)
hordeText:SetWidth(200)
hordeText:SetJustifyH("RIGHT")
hordeText:SetTextColor(60/255, 45/255, 35/255, 1)

local function CreateButton(name, textureNormal, texturePushed, x, y, callback, text)
    local btn = CreateFrame("Button", name, frame)
    btn:SetSize(200, 100)
    btn:SetPoint("CENTER", frame, "CENTER", x, y)
    
    btn:SetNormalTexture(textureNormal)
    btn:SetPushedTexture(texturePushed)
    btn:SetHighlightTexture("Interface/DestinyPandaUI/BouttonHighlightDestiny.blp")
    btn:SetHighlightTexture("Interface/DestinyPandaUI/BouttonHighlightBlueDestiny.blp")
    
    local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btnText:SetPoint("CENTER", btn, "CENTER")
    btnText:SetText(text)
    btnText:SetFont("Fonts\\MARCELLUS.TTF", 14)
    
    btn:SetScript("OnClick", callback)
    return btn
end

local allianceButton = CreateButton("AllianceButton", 
    "Interface/DestinyPandaUI/BouttonNormalAllianceDestiny.blp", 
    "Interface/DestinyPandaUI/BouttonPushedAllianceDestiny.blp", 
    -150, -168, 
    function() SendChatMessage(".teleport_panda alliance", "GUILD") end,
    "Rejoignez\nl'Alliance")

local hordeButton = CreateButton("HordeButton", 
    "Interface/DestinyPandaUI/BouttonNormalHordeDestiny.blp", 
    "Interface/DestinyPandaUI/BouttonPushedHordeDestiny.blp", 
    150, -168, 
    function() SendChatMessage(".teleport_panda horde", "GUILD") end,
    "Rejoignez\nla Horde")

function DestinyFactionHandlers.OpenDestinyInterface()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

function DestinyFactionHandlers.CloseDestinyInterface()
    if frame:IsShown() then
        frame:Hide()
    end
end
