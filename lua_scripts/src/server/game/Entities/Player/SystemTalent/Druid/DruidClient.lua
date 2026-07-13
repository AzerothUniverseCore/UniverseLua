local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local DruidHandlers = AIO.AddHandlers("TalentDruidspell", {})

function DruidHandlers.ShowTalentDruid(player)
    frameTalentDruid:Show()
    -- Redemande au serveur l’état visuel au cas où
    AIO.Handle("TalentDruidspell", "RequestLearnedTalents")
	-- Redemande le nombre de talents restants
    AIO.Handle("TalentDruidspell", "GetTalentItemCount")
end

local MAX_TALENTS = 60 -- Définition du nombre maximal de talents que le joueur peut apprendre

local OPEN_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_final_trait_unlocked.ogg"
local CLOSE_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_trait_refund_end.ogg"
local SPELL_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_80_azeritearmor_rotationends_02.ogg"

-- Attribute window
local frameTalentDruid = CreateFrame("Frame", "frameTalentDruid", UIParent)
frameTalentDruid:SetSize(1200, 650)
frameTalentDruid:SetMovable(true)
frameTalentDruid:EnableMouse(true)
frameTalentDruid:RegisterForDrag("LeftButton")
frameTalentDruid:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, -50) -- Adjust the X and Y coordinates
frameTalentDruid:SetBackdrop(
{
    -- bgFile = "interface/TalentFrame/talentsclassbackgroundDruid", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    bgFile = "interface/TalentFrame/Template/Class/Druid/talentsclassbackgrounddruid", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    edgeFile = "interface/tooltips/ui-tooltip-border-corrupteddruid", --Interface/DialogFrame/UI-DialogBox-Border
    edgeSize = 20,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})

-- Ajoutez la texture de l'icône du Druid
local druidIcon = frameTalentDruid:CreateTexture("DruidIcon", "OVERLAY")
druidIcon:SetTexture("Interface\\TalentFrame\\Template\\Class\\Druid\\IconeDruid.blp")
druidIcon:SetSize(60, 60)
druidIcon:SetPoint("TOPLEFT", frameTalentDruid, "TOPLEFT", -10, 10)

-- Template Talent Frame

-- Ajoute une textureone pour l'image BLP
local textureone = frameTalentDruid:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
textureone:SetTexture("Interface\\TalentFrame\\Template\\Class\\Druid\\TalentFrameTemplate.blp")
textureone:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
textureone:SetPoint("TOPLEFT", frameTalentDruid, "TOPLEFT", -170, 140) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentDruid:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Ajoute une texturetwo pour l'image BLP
local texturetwo = frameTalentDruid:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
texturetwo:SetTexture("Interface\\TalentFrame\\Template\\Class\\Druid\\TalentFrameTemplateOriginal.blp")
texturetwo:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
texturetwo:SetPoint("TOPRIGHT", frameTalentDruid, "TOPRIGHT", 170, 140) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentDruid:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Drag & Drop
frameTalentDruid:SetScript("OnDragStart", frameTalentDruid.StartMoving)
frameTalentDruid:SetScript("OnHide", frameTalentDruid.StopMovingOrSizing)
frameTalentDruid:SetScript("OnDragStop", frameTalentDruid.StopMovingOrSizing)
frameTalentDruid:Hide()

-- Nouveau template d'arête
frameTalentDruid:SetBackdropBorderColor(135, 135, 237) -- Couleur pourpre

-- Nouveau template d'arête
-- frameTalentDruid:SetBackdropBorderColor(199, 156, 110) -- Couleur marron / talentsclassbackgroundDruid

-- Close button
local buttonTalentDruidClose = CreateFrame("Button", "buttonTalentDruidClose", frameTalentDruid, "UIPanelCloseButton")
buttonTalentDruidClose:SetPoint("TOPRIGHT", -12, -12)
buttonTalentDruidClose:EnableMouse(true)
buttonTalentDruidClose:SetSize(32, 32)

local function CloseTalentWindow()
    frameTalentDruid:Hide()
    PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
end

-- Associez la fonction de fermeture au bouton de fermeture
buttonTalentDruidClose:SetScript("OnClick", CloseTalentWindow)

-- Title bar
local frameTalentDruidTitleBar = CreateFrame("Frame", "frameTalentDruidTitleBar", frameTalentDruid, nil)
frameTalentDruidTitleBar:SetSize(135, 25)
frameTalentDruidTitleBar:SetBackdrop(
{
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corrupteddruid",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentDruidTitleBar:SetPoint("TOP", 0, 20)

local fontTalentDruidTitleText = frameTalentDruidTitleBar:CreateFontString("fontTalentDruidTitleText")
fontTalentDruidTitleText:SetFont("Fonts\\FRIZQT__.TTF", 13)
fontTalentDruidTitleText:SetSize(190, 5)
fontTalentDruidTitleText:SetPoint("CENTER", 0, 0)
fontTalentDruidTitleText:SetText("|cffFFC125Talents|r")

-- Détecte la langue du client
local locale = GetLocale() -- Retourne "enUS", "frFR", etc.

-- Table des traductions
local localizedTexts = {
    enUS = "|cffFFC125Druid|r",
    frFR = "|cffFFC125Druide|r",
}

-- Récupère le texte correspondant à la langue actuelle ou par défaut en anglais
local textToDisplay = localizedTexts[locale] or localizedTexts["enUS"]

local fontTalentDruidFrameText = frameTalentDruidTitleBar:CreateFontString("fontTalentDruidFrameText")
fontTalentDruidFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentDruidFrameText:SetSize(200, 5)
fontTalentDruidFrameText:SetPoint("TOPLEFT", frameTalentDruidTitleBar, "BOTTOMLEFT", -30, -35) -- Adjust the Y offset as needed
fontTalentDruidFrameText:SetText(textToDisplay)

-- Remplacez votre ligne existante pour la création du texte par celle-ci
local fontTalentDruidFrameText = frameTalentDruidTitleBar:CreateFontString("fontTalentDruidFrameText")
fontTalentDruidFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentDruidFrameText:SetSize(200, 5)
fontTalentDruidFrameText:SetPoint("TOPLEFT", frameTalentDruidTitleBar, "BOTTOMLEFT", -30, -60) -- Adjust the Y offset as needed
fontTalentDruidFrameText:SetText("0 / " .. MAX_TALENTS) -- Initialisez le texte avec 0 talents appris

-------------------------------------------------------------
-- Affichage "Talents restants" (item 338404 dans le sac)
-------------------------------------------------------------

local frameTalentPointsRemaining = CreateFrame("Frame", "frameTalentPointsRemaining", frameTalentDruid, nil)
frameTalentPointsRemaining:SetSize(220, 30)
frameTalentPointsRemaining:SetBackdrop({
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corrupteddruid",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentPointsRemaining:SetPoint("BOTTOMRIGHT", frameTalentDruid, "BOTTOMRIGHT", -960, 10)

local fontTalentPointsRemainingText = frameTalentPointsRemaining:CreateFontString("fontTalentPointsRemainingText")
fontTalentPointsRemainingText:SetFont("Fonts\\FRIZQT__.TTF", 14)
fontTalentPointsRemainingText:SetSize(210, 20)
fontTalentPointsRemainingText:SetPoint("CENTER", 0, 0)
fontTalentPointsRemainingText:SetText("|cFFFF7D0ATalents restants : 0|r")
-------------------------------------------------------------

-- Définir les textes en fonction de la langue locale
local noTalentPointsText

if GetLocale() == "frFR" then
    noTalentPointsText = "|cff00ffffVous n'avez plus de points de talent !|r"
elseif GetLocale() == "enUS" then
    noTalentPointsText = "|cff00ffffYou have no more talent points!|r"
else
    -- Valeur par défaut en anglais si la langue n'est ni frFR ni enUS
    noTalentPointsText = "|cff00ffffYou have no more talent points!|r"
end

-- Table globale pour stocker les boutons par handler
local spellButtons = {}

-- Met à jour l'état visuel des talents appris depuis le serveur
DruidHandlers.UpdateLearnedTalents = function(player, learnedSpells)
    for handler, learned in pairs(learnedSpells) do
        local button = spellButtons[handler]
        if button then
            local learnIndicator = button.learnIndicator or nil
            local buttonText = button.buttonText or nil

            if learned then
                -- Marque comme appris
                button:SetAlpha(1)
                if learnIndicator then learnIndicator:Show() end
                if buttonText then buttonText:SetText("|cffffda2b1|r") end
            else
                -- Marque comme non appris
                button:SetAlpha(1)
                if learnIndicator then learnIndicator:Hide() end
                if buttonText then buttonText:SetText("|cff1aff1a0|r") end
            end
        end
    end
end

-- Fonction générique pour créer un bouton de sort
local function CreateSpellButton(name, texturePath, tooltipText, talentHandler, positionX, positionY)
    local buttonClicked = false
    local talentLearned = false

    local button = CreateFrame("Button", name, frameTalentDruid, nil)
    button:SetSize(40, 40)
    button:EnableMouse(true)
    button:SetNormalTexture(texturePath)
    button:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
    button:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
    button:SetPoint("TOPLEFT", positionX, positionY)
	
	-- Stocker le bouton pour pouvoir le mettre à jour plus tard
    spellButtons[talentHandler] = button
	
	-- ✅ AJOUT DU CADRE VISUEL SUPERPOSÉ SUR LE BOUTON
    local buttonFrame = button:CreateTexture(nil, "OVERLAY")
    buttonFrame:SetTexture("Interface/TALENTFRAME/Template/Button_Talent.blp")
    buttonFrame:SetSize(36, 36)
    buttonFrame:SetPoint("CENTER", button, "CENTER", 0, 0)
    buttonFrame:SetDrawLayer("OVERLAY", 1) -- Au-dessus de l'icône mais sous les autres éléments

-- Texture pour l'indicateur d'apprentissage
local learnIndicator = button:CreateTexture(nil, "OVERLAY")
learnIndicator:SetTexture("Interface/Buttons/UI-CheckBox-Check")
learnIndicator:SetSize(30, 30)
learnIndicator:SetPoint("BOTTOMRIGHT", -2, 2)
learnIndicator:Hide()
button.learnIndicator = learnIndicator -- ✅ rendre accessible à l’extérieur

-- Texte pour afficher l'état du bouton (0 ou 1)
local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
buttonText:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
button.buttonText = buttonText -- ✅ rendre accessible à l’extérieur

    -- Fonction pour mettre à jour l'état du bouton et de l'indicateur d'apprentissage
    local function UpdateButtonState()
        if talentLearned then
            button:SetAlpha(1) -- Réduire l'opacité pour indiquer que le bouton est désactivé
            learnIndicator:Show() -- Afficher l'indicateur d'apprentissage
            buttonText:SetText("|cffffda2b1|r") -- Mettre à jour le texte pour afficher "1"
        else
            button:SetAlpha(1) -- Rétablir l'opacité pour indiquer que le bouton est activé
            learnIndicator:Hide() -- Cacher l'indicateur d'apprentissage
            buttonText:SetText("|cff1aff1a0|r") -- Mettre à jour le texte pour afficher "0"
        end
    end

    -- Fonction à exécuter lorsque le bouton est cliqué
    button:SetScript("OnMouseUp", function()
        if not buttonClicked and not talentLearned then
            -- Ajouter une vérification pour s'assurer que le joueur a des points de talent
            local talentItemID = 338404
            local hasTalentPoints = GetItemCount(talentItemID, false, true) > 0

            if hasTalentPoints then
                AIO.Handle("TalentDruidspell", talentHandler, 1)
                PlaySoundFile(SPELL_TALENT_WINDOW_SOUND)
                buttonClicked = true -- Marquer le bouton comme cliqué
                talentLearned = true -- Marquer le talent comme appris
                UpdateButtonState() -- Mettre à jour l'état du bouton
            else
                print(noTalentPointsText)  -- Affichage du message localisé
            end
        end
    end)

    -- Affichage du tooltip
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "TOPLEFT")
        GameTooltip:ClearLines()
        GameTooltip:SetText(tooltipText)
        GameTooltip:Show()
    end)

    -- Cacher le tooltip lorsque la souris quitte le bouton
    button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Appel initial pour définir l'état du bouton au chargement
    UpdateButtonState()
end

-- Utilisation de la fonction générique avec des positions spécifiques

-------------------------------------------------------------

-------------------------------------------------------------

-- Template 1

-- Equilibre

-- Table des sorts
local spells = {
{
    id = "spellStarlightWrath",
    name = "buttonSpellStarlightWrath",
    icon = "Interface/icons/spell_nature_abolishmagic",
    position = {100, -80},
    handler = "spellstarlightwrath",
    tooltips = {
        frFR = "|cffffffffColère stellaire|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit le temps d'incantation de vos sorts Colère et Feu Stellaire de 0.5 sec.|r",
        enUS = "|cffffffffStarlight Wrath|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Reduces the cast time of your Wrath and Starfire by 0.5 sec.|r"
    }
},
{
    id = "spellGenesis",
    name = "buttonSpellGenesis",
    icon = "Interface/icons/spell_arcane_arcane03",
    position = {205, -75},
    handler = "spellgenesis",
    tooltips = {
        frFR = "|cffffffffGenèse|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente les dégâts et les soins produits par les effets de dégâts et de soins de vos sorts périodiques de 5%.|r",
        enUS = "|cffffffffGenesis|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases the damage and healing done by the periodic damage and healing effects of your spells by 5%.|r"
    }
},
{
    id = "spellMoonglow",
    name = "buttonSpellMoonglow",
    icon = "Interface/icons/spell_nature_sentinal",
    position = {315, -75},
    handler = "spellarcanestability",
    tooltips = {
        frFR = "|cffffffffLueur de la lune|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit de 9% le coût en mana de vos sorts Eclat lunaire, Feu stellaire, Météores, Colère, Toucher guérisseur, Nourrir, Rétablissement et Récupération.|r",
        enUS = "|cffffffffMoonglow|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Reduces the mana cost of your Moonfire, Starfire, Typhoon, Wrath, Healing Touch, Nourish, Rejuvenation, and Regrowth spells by 9%.|r"
    }
},
{
    id = "spellNaturesMajesty",
    name = "buttonSpellNaturesMajesty",
    icon = "Interface/icons/inv_staff_01",
    position = {418, -80},
    handler = "spellnaturesmajesty",
    tooltips = {
        frFR = "|cffffffffMajesté de la nature|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente de 4% les chances d'infliger un coup critique avec vos sorts Colère, Feu stellaire, Météores, Nourrir et Toucher guérisseur.|r",
        enUS = "|cffffffffNature's Majesty|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases your chance to score a critical strike with your Wrath, Starfire, Typhoon, Nourish, and Healing Touch spells by 4%.|r"
    }
},
{
    id = "spellImprovedMoonfire",
    name = "buttonSpellImprovedMoonfire",
    icon = "Interface/icons/spell_nature_starfall",
    position = {150, -130},
    handler = "spellimprovedmoonfire",
    tooltips = {
        frFR = "|cffffffffEclat lunaire amélioré|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente les points de dégâts et les chances de porter un coup critique avec votre sort Eclat lunaire de 10%.|r",
        enUS = "|cffffffffImproved Moonfire|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases the damage and critical strike chance of your Moonfire spell by 10%.|r"
    }
},
{
    id = "spellBrambles",
    name = "buttonSpellBrambles",
    icon = "Interface/icons/spell_nature_thorns",
    position = {260, -130},
    handler = "spellbrambles",
    tooltips = {
        frFR = "|cffffffffRonces|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Les dégâts infligés par vos Epines et Sarments sont augmentés de 75% et les attaques de vos Tréants sont augmentées de 15%.\nDe plus, les dégâts infligés par vos Tréants et les attaques avec Ecorce activé ont 15% de chances d'hébéter la cible pendant 3 sec.|r",
        enUS = "|cffffffffBrambles|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases the damage done by your Thorns and Entangling Roots by 75%, and increases your Treants' attacks by 15%. Additionally, the damage done by your Treants and attacks while Barkskin is active have a 15% chance to incapacitate the target for 3 sec.|r"
    }
},
{
    id = "spellNaturesGrace",
    name = "buttonSpellNaturesGrace",
    icon = "Interface/icons/spell_nature_naturesblessing",
    position = {370, -130},
    handler = "spellnaturesgrace",
    tooltips = {
        frFR = "|cffffffffGrâce de la nature|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Tous les coups critiques non périodiques des sorts ont 100% de chances de vous octroyer une Bénédiction de la nature.\nCette dernière augmente de 20% votre vitesse d'incantation des sorts pendant 3 seconds.|r",
        enUS = "|cffffffffNature's Grace|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100All non-periodic critical strikes from your spells have a 100% chance to grant you Nature's Blessing, increasing your spellcasting speed by 20% for 3 seconds.|r"
    }
},
{
    id = "spellNaturesSplendor",
    name = "buttonSpellNaturesSplendor",
    icon = "Interface/icons/spell_nature_natureguardian",
    position = {475, -133},
    handler = "spellnaturessplendor",
    tooltips = {
        frFR = "|cffffffffSplendeur de la nature|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente la durée de vos sorts Eclat lunaire et Récupération de 3 sec., Rétablissement de 6 sec.\nainsi qu'Essaim d'insectes et Fleur de vie de 2 sec.|r",
        enUS = "|cffffffffNature's Splendor|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases the duration of your Moonfire and Rejuvenation by 3 sec, Lifebloom and Healing Touch by 6 sec, and Insect Swarm and Wild Growth by 2 sec.|r"
    }
},
{
    id = "spellNaturesReach",
    name = "buttonSpellNaturesReach",
    icon = "Interface/icons/spell_nature_naturetouchgrow",
    position = {96, -185},
    handler = "spellnaturesreach",
    tooltips = {
        frFR = "|cffffffffAllonge de la Nature|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente la portée de vos sorts d'Équilibre et de la technique Lucioles (farouche) de 20%, et réduit la menace générée par vos sorts d'Equilibre de 30%.|r",
        enUS = "|cffffffffNature's Reach|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases the range of your Balance spells and your Feral Touch ability by 20%, and reduces the threat generated by your Balance spells by 30%.|r"
    }
},
{
    id = "spellVengeance",
    name = "buttonSpellVengeance",
    icon = "Interface/icons/spell_nature_purge",
    position = {205, -185},
    handler = "spellvengeance",
    tooltips = {
        frFR = "|cffffffffVengeance|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente de 100% le bonus de dégâts supplémentaires infligés par les coups critiques avec vos sorts Feu stellaire, Météores, Eclat lunaire et Colère.|r",
        enUS = "|cffffffffVengeance|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases the bonus damage dealt by critical strikes with your Starfire, Typhoon, Moonfire, and Wrath spells by 100%.|r"
    }
},
{
    id = "spellCelestialFocus",
    name = "buttonSpellCelestialFocus",
    icon = "Interface/icons/spell_arcane_starfire",
    position = {315, -185},
    handler = "spellcelestialfocus",
    tooltips = {
        frFR = "|cffffffffFocalisation céleste|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit de 70% l'interruption causée par les attaques infligeant des dégâts pendant que vous incantez Feu stellaire, Hibernation et Ouragan, en plus d'augmenter votre total de hâte des sorts de 3%.|r",
        enUS = "|cffffffffCelestial Focus|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Reduces the interruption caused by damage-dealing attacks by 70% while casting Starfire, Hibernate, and Hurricane, in addition to increasing your spell haste by 3%.|r"
    }
},
{
    id = "spellLunarGuidance",
    name = "buttonSpellLunarGuidance",
    icon = "Interface/icons/ability_druid_lunarguidance",
    position = {422, -185},
    handler = "spelllunarguidance",
    tooltips = {
        frFR = "|cffffffffSoutien lunaire|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente la puissance de vos sorts de 12% de votre total d'Intelligence.|r",
        enUS = "|cffffffffLunar Guidance|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases the power of your spells by 12% of your total Intelligence.|r"
    }
},
{
    id = "spellInsectSwarm",
    name = "buttonSpellInsectSwarm",
    icon = "Interface/icons/spell_nature_insectswarm",
    position = {527, -190},
    handler = "spellinsectswarm",
    tooltips = {
        frFR = "|cffffffffEssaim d'insectes|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100La cible ennemie est assaillie par des insectes. Ses chances de toucher sont réduites de 3% et elle subit 144 points de dégâts de Nature en 12 seconds.|r",
        enUS = "|cffffffffInsect Swarm|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100The enemy target is assaulted by insects. Their chance to hit is reduced by 3%, and they take 144 Nature damage over 12 seconds.|r"
    }
},
{
    id = "spellImprovedInsectSwarm",
    name = "buttonSpellImprovedInsectSwarm",
    icon = "Interface/icons/spell_nature_insectswarm",
    position = {43, -240},
    handler = "spellimprovedinsectswarm",
    tooltips = {
        frFR = "|cffffffffEssaim d'insectes amélioré|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente les dégâts infligés par votre sort Colère aux cibles affectées par votre sort Essaim d'insectes de 3%,\net augmente les chances de coup critique de votre sort Feu stellaire de 3% sur les cibles affectées par votre sort Eclat lunaire.|r",
        enUS = "|cffffffffImproved Insect Swarm|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases the damage dealt by your Wrath spell to targets affected by your Insect Swarm by 3%, and increases the critical strike chance of your Starfire spell by 3% on targets affected by your Moonfire.|r"
    }
},
{
    id = "spellDreamstate",
    name = "buttonSpellDreamstate",
    icon = "Interface/icons/ability_druid_dreamstate",
    position = {150, -240},
    handler = "spelldreamstate",
    tooltips = {
        frFR = "|cffffffffEtat de rêve|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Régénère une quantité de mana égale à 10% de votre Intelligence toutes les 5 sec., même pendant l'incantation.|r",
        enUS = "|cffffffffDreamstate|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Regenerates an amount of mana equal to 10% of your Intelligence every 5 sec, even while casting.|r"
    }
},
{
    id = "spellMoonfury",
    name = "buttonSpellMoonfury",
    icon = "Interface/icons/spell_nature_moonglow",
    position = {368, -240},
    handler = "spellmoonfury",
    tooltips = {
        frFR = "|cffffffffFureur lunaire|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente de 10% les dégâts infligés par vos sorts Feu stellaire,\nEclat lunaire et Colère.|r",
        enUS = "|cffffffffMoonfury|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases the damage dealt by your Starfire, Moonfire, and Wrath spells by 10%.|r"
    }
},
{
    id = "spellBalanceofPower",
    name = "buttonSpellBalanceofPower",
    icon = "Interface/icons/ability_druid_balanceofpower",
    position = {478, -240},
    handler = "spellbalanceofpower",
    tooltips = {
        frFR = "|cffffffffEquilibre de la puissance|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente vos chances de toucher avec tous les sorts de 4% et réduit les dégâts que vous infligent tous les sorts de 6%.|r",
        enUS = "|cffffffffBalance of Power|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases your chance to hit with all spells by 4% and reduces the damage taken from all spells by 6%.|r"
    }
},
{
    id = "spellMoonkinForm",
    name = "buttonSpellMoonkinForm",
    icon = "Interface/icons/spell_nature_forceofnature",
    position = {98, -293},
    handler = "spellmoonkinform",
    tooltips = {
        frFR = "|cffffffffForme de sélénien|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Le druide adopte sa forme de sélénien. Tant qu'il est sous cette forme, la valeur d'armure apportée par les objets est augmentée de 370%,\nles dégâts qu'il subit alors qu'il est étourdi sont réduits de 15% et tous les membres du groupe\net du raid se trouvant à moins de 100 mètres voient leurs chances d'obtenir un coup critique avec les sorts augmenter de 5%.\nLes critiques réussis avec les sorts monocibles sous cette forme ont une chance de régénérer instantanément 2% de votre total de mana.\nLe sélénien ne peut pas lancer de sorts de soins ou de résurrection tant qu'il est transformé.\n\nLa transformation libère le lanceur de sorts des métamorphoses et des effets qui affectent le déplacement.|r",
        enUS = "|cffffffffMoonkin Form|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100The druid takes on the Moonkin form. While in this form, the armor value provided by items is increased by 370%, damage taken while stunned is reduced by 15%, and all party and raid members within 100 yards have their chance to score a critical hit with spells increased by 5%. Critical hits with single-target spells in this form have a chance to instantly regenerate 2% of your total mana. The Moonkin form prevents casting healing or resurrection spells. The transformation also frees the caster from polymorph effects and movement-impairing effects.|r"
    }
},
{
    id = "spellImprovedMoonkinForm",
    name = "buttonSpellImprovedMoonkinForm",
    icon = "Interface/icons/ability_druid_improvedmoonkinform",
    position = {205, -293},
    handler = "spellimprovedmoonkinform",
    tooltips = {
        frFR = "|cffffffffForme de sélénien améliorée|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Votre Aura de sélénien permet aussi aux cibles affectées de voir leur hâte augmenter de 3%,\net vous bénéficiez d'un montant de dégâts des sorts supplémentaire égal à 30% de votre Esprit.|r",
        enUS = "|cffffffffImproved Moonkin Form|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Your Moonkin Aura also increases the haste of affected targets by 3%, and you gain additional spell damage equal to 30% of your Spirit.|r"
    }
},
{
    id = "spellImprovedFaerieFire",
    name = "buttonSpellImprovedFaerieFire",
    icon = "Interface/icons/spell_nature_faeriefire",
    position = {315, -293},
    handler = "spellimprovedfaeriefire",
    tooltips = {
        frFR = "|cffffffffLucioles améliorées|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Votre sort Lucioles augmente aussi les chances que la cible soit touchée par les attaques avec les sorts de 3%\nainsi que vos chances de coup critique avec les sorts infligeant des dégâts sur les cibles affectées par Lucioles de 3%.|r",
        enUS = "|cffffffffImproved Faerie Fire|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Your Faerie Fire spell also increases the chance for the target to be hit by spell attacks by 3%, as well as increasing your chance of critical strike with damage-dealing spells on targets affected by Faerie Fire by 3%.|r"
    }
},
{
    id = "spellOwlkinFrenzy",
    name = "buttonSpellOwlkinFrenzy",
    icon = "Interface/icons/ability_druid_owlkinfrenzy",
    position = {422, -293},
    handler = "spellowlkinfrenzy",
    tooltips = {
        frFR = "|cffffffffFrénésie du chouettide|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Les attaques que vous subissez lorsque vous êtes en forme de sélénien ont 15% de chances de vous faire entrer dans un état de frénésie,\nqui augmente vos dégâts de 10%, vous rend insensible aux interruptions pendant l'incantation de sorts d'Equilibre et vous donne 2% de votre mana de base toutes les 2 sec.\nDure 10 secondes.|r",
        enUS = "|cffffffffOwlkin Frenzy|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Attacks you receive while in Moonkin Form have a 15% chance to trigger Frenzy,\nwhich increases your damage by 10%, makes you immune to interruptions while casting Balance spells, and restores 2% of your base mana every 2 seconds.\nLasts for 10 seconds.|r"
    }
},
{
    id = "spellWrathofCenarius",
    name = "buttonSpellWrathofCenarius",
    icon = "Interface/icons/ability_druid_twilightswrath",
    position = {260, -240},
    handler = "spellwrathofcenarius",
    tooltips = {
        frFR = "|cffffffffColère de Cénarius|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Votre sort Feu stellaire bénéficie de 20% supplémentaires et votre Colère de 10% supplémentaires des effets du bonus aux dégâts.|r",
        enUS = "|cffffffffWrath of Cenarius|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Your Starfire spell gains 20% additional damage, and your Wrath spell gains 10% additional damage from damage bonuses.|r"
    }
},
{
    id = "spellEclipse",
    name = "buttonSpellEclipse",
    icon = "Interface/icons/ability_druid_eclipse",
    position = {43, -350},
    handler = "spelleclipse",
    tooltips = {
        frFR = "|cffffffffEclipse|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Quand vous réussissez un coup critique avec Feu stellaire, vous avez 100% de chances d'augmenter de 40% les dégâts infligés par Colère.\nQuand vous réussissez un coup critique avec Colère, vous avez 60% de chances d'augmenter vos chances de coup critique avec Feu stellaire de 40%.\nChaque effet dure 15 secondes et a un temps de recharge distinct de 30 sec.\nLes deux effets ne peuvent se produire simultanément.|r",
        enUS = "|cffffffffEclipse|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100When you score a critical hit with Starfire, you have a 100% chance to increase the damage dealt by Wrath by 40%.\nWhen you score a critical hit with Wrath, you have a 60% chance to increase your chance to score critical hits with Starfire by 40%.\nEach effect lasts 15 seconds and has a separate cooldown of 30 seconds.\nThe two effects cannot occur simultaneously.|r"
    }
},
{
    id = "spellTyphoon",
    name = "buttonSpellTyphoon",
    icon = "Interface/icons/ability_druid_typhoon",
    position = {150, -350},
    handler = "spelltyphoon",
    tooltips = {
        frFR = "|cffffffffTyphon|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Vous invoquez un violent Typhon qui inflige 400 points de dégâts de Nature quand il entre en contact avec des cibles hostiles.\nIl les fait tomber à la renverse et les hébète pendant 6 secondes.|r",
        enUS = "|cffffffffTyphoon|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Summons a violent Typhoon that deals 400 Nature damage to enemies it comes into contact with.\nIt knocks them back and incapacitates them for 6 seconds.|r"
    }
},
{
    id = "spellForceofNature",
    name = "buttonSpellForceofNature",
    icon = "Interface/icons/ability_druid_forceofnature",
    position = {260, -350},
    handler = "spellforceofnature",
    tooltips = {
        frFR = "|cffffffffForce de la nature|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Invoque 3 tréants qui attaquent les cibles ennemies pendant 30 secondes.|r",
        enUS = "|cffffffffForce of Nature|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Summons 3 Treants that attack enemy targets for 30 seconds.|r"
    }
},
{
    id = "spellGaleWinds",
    name = "buttonSpellGaleWinds",
    icon = "Interface/icons/ability_druid_galewinds",
    position = {368, -350},
    handler = "spellgalewinds",
    tooltips = {
        frFR = "|cffffffffGrands vents|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente de 30% les dégâts infligés par vos sorts Ouragan et Typhon, et augmente la portée de votre sort Cyclone de 4 mètres.|r",
        enUS = "|cffffffffGale Winds|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases the damage of your Hurricane and Typhoon spells by 30%, and increases the range of your Cyclone spell by 4 meters.|r"
    }
},
{
    id = "spellEarthandMoon",
    name = "buttonSpellEarthandMoon",
    icon = "Interface/icons/ability_druid_earthandsky",
    position = {478, -350},
    handler = "spellearthandmoon",
    tooltips = {
        frFR = "|cffffffffTerre et lune|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Vos sorts Colère et Feu stellaire ont 100% de chances d'appliquer l'effet Terre et lune sur la cible.\nCelui-ci augmente les dégâts des sorts infligés à la cible de 13% pendant 12 secondes.\nAugmente également vos dégâts des sorts de 6%.|r",
        enUS = "|cffffffffEarth and Moon|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Your Wrath and Starfire spells have a 100% chance to apply the Earth and Moon effect to the target.\nThis effect increases the damage of spells dealt to the target by 13% for 12 seconds.\nAlso increases your spell damage by 6%.|r"
    }
},
{
    id = "spellStarfall",
    name = "buttonSpellStarfall",
    icon = "Interface/icons/ability_druid_starfall",
    position = {98, -405},
    handler = "spellstarfall",
    tooltips = {
        frFR = "|cffffffffMétéores|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Un déluge de météores tombe du ciel sur toutes les cibles se trouvant à moins de a mètres du lanceur de sorts et chacun inflige 145 à 167 points de dégâts des Arcanes.\nInflige également 26 points de dégâts des Arcanes à tous les autres ennemis se trouvant à moins de 5 mètres de la cible ennemie.\n20 météores au maximum. Dure 10 secondes. Si vous changez de forme ou utilisez une monture, l'effet est annulé.\nTout effet qui vous fait perdre le contrôle de votre personnage l'annule également.|r",
        enUS = "|cffffffffStarfall|r\n|cffffffffTalent|r |cff65ca00Balance|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100A shower of meteors falls from the sky, striking all enemies within a certain distance of the caster, dealing 145 to 167 Arcane damage each.\nAlso deals 26 Arcane damage to all enemies within 5 yards of the target enemy.\nA maximum of 20 meteors. Lasts 10 seconds. Changing form or using a mount cancels the effect.\nAny effect that causes you to lose control of your character will also cancel it.|r"
    }
},


-- CreateSpellButton("buttonSpellStarlightWrath", "Interface/icons/spell_nature_abolishmagic", "|cffffffffColère stellaire|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit le temps d'incantation de vos sorts Colère et Feu Stellaire de 0.5 sec.|r", "spellstarlightwrath", 100, -80)
-- CreateSpellButton("buttonSpellGenesis", "Interface/icons/spell_arcane_arcane03", "|cffffffffGenèse|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente les dégâts et les soins produits par les effets de dégâts et de soins de vos sorts périodiques de 5%.|r", "spellgenesis", 205, -75)
-- CreateSpellButton("buttonSpellMoonglow", "Interface/icons/spell_nature_sentinal", "|cffffffffLueur de la lune|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit de 9% le coût en mana de vos sorts Eclat lunaire, Feu stellaire, Météores, Colère, Toucher guérisseur, Nourrir, Rétablissement et Récupération.|r", "spellarcanestability", 315, -75)
-- CreateSpellButton("buttonSpellNaturesMajesty", "Interface/icons/inv_staff_01", "|cffffffffMajesté de la nature|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente de 4% les chances d'infliger un coup critique avec vos sorts Colère, Feu stellaire, Météores, Nourrir et Toucher guérisseur.|r", "spellnaturesmajesty", 418, -80)
-- CreateSpellButton("buttonSpellImprovedMoonfire", "Interface/icons/spell_nature_starfall", "|cffffffffEclat lunaire amélioré|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente les points de dégâts et les chances de porter un coup critique avec votre sort Eclat lunaire de 10%.|r", "spellimprovedmoonfire", 150, -130)
-- CreateSpellButton("buttonSpellBrambles", "Interface/icons/spell_nature_thorns", "|cffffffffRonces|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Les dégâts infligés par vos Epines et Sarments sont augmentés de 75% et les attaques de vos Tréants sont augmentées de 15%.\nDe plus, les dégâts infligés par vos Tréants et les attaques avec Ecorce activé ont 15% de chances d'hébéter la cible pendant 3 sec.|r", "spellbrambles", 260, -130)
-- CreateSpellButton("buttonSpellNaturesGrace", "Interface/icons/spell_nature_naturesblessing", "|cffffffffGrâce de la nature|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Tous les coups critiques non périodiques des sorts ont 100% de chances de vous octroyer une Bénédiction de la nature.\nCette dernière augmente de 20% votre vitesse d'incantation des sorts pendant 3 seconds.|r", "spellnaturesgrace", 370, -130)
-- CreateSpellButton("buttonSpellNaturesSplendor", "Interface/icons/spell_nature_natureguardian", "|cffffffffSplendeur de la nature|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente la durée de vos sorts Eclat lunaire et Récupération de 3 sec., Rétablissement de 6 sec.\nainsi qu'Essaim d'insectes et Fleur de vie de 2 sec.|r", "spellnaturessplendor", 475, -133)
-- CreateSpellButton("buttonSpellNaturesReach", "Interface/icons/spell_nature_naturetouchgrow", "|cffffffffAllonge de la Nature|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente la portée de vos sorts d'Équilibre et de la technique Lucioles (farouche) de 20%, et réduit la menace générée par vos sorts d'Equilibre de 30%.|r", "spellnaturesreach", 96, -185)
-- CreateSpellButton("buttonSpellVengeance", "Interface/icons/spell_nature_purge", "|cffffffffVengeance|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente de 100% le bonus de dégâts supplémentaires infligés par les coups critiques avec vos sorts Feu stellaire, Météores, Eclat lunaire et Colère.|r", "spellvengeance", 205, -185)
-- CreateSpellButton("buttonSpellCelestialFocus", "Interface/icons/spell_arcane_starfire", "|cffffffffFocalisation céleste|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit de 70% l'interruption causée par les attaques infligeant des dégâts pendant que vous incantez Feu stellaire, Hibernation et Ouragan, en plus d'augmenter votre total de hâte des sorts de 3%.|r", "spellcelestialfocus", 315, -185)
-- CreateSpellButton("buttonSpellLunarGuidance", "Interface/icons/ability_druid_lunarguidance", "|cffffffffSoutien lunaire|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente la puissance de vos sorts de 12% de votre total d'Intelligence.|r", "spelllunarguidance", 422, -185)
-- CreateSpellButton("buttonSpellInsectSwarm", "Interface/icons/spell_nature_insectswarm", "|cffffffffEssaim d'insectes|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100La cible ennemie est assaillie par des insectes. Ses chances de toucher sont réduites de 3% et elle subit 144 points de dégâts de Nature en 12 seconds.|r", "spellinsectswarm", 527, -190)
-- CreateSpellButton("buttonSpellImprovedInsectSwarm", "Interface/icons/spell_nature_insectswarm", "|cffffffffEssaim d'insectes amélioré|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente les dégâts infligés par votre sort Colère aux cibles affectées par votre sort Essaim d'insectes de 3%,\net augmente les chances de coup critique de votre sort Feu stellaire de 3% sur les cibles affectées par votre sort Eclat lunaire.|r", "spellimprovedinsectswarm", 43, -240)
-- CreateSpellButton("buttonSpellDreamstate", "Interface/icons/ability_druid_dreamstate", "|cffffffffEtat de rêve|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Régénère une quantité de mana égale à 10% de votre Intelligence toutes les 5 sec., même pendant l'incantation.|r", "spelldreamstate", 150, -240)
-- CreateSpellButton("buttonSpellMoonfury", "Interface/icons/spell_nature_moonglow", "|cffffffffFureur lunaire|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente de 10% les dégâts infligés par vos sorts Feu stellaire,\nEclat lunaire et Colère.|r", "spellmoonfury", 368, -240)
-- CreateSpellButton("buttonSpellBalanceofPower", "Interface/icons/ability_druid_balanceofpower", "|cffffffffEquilibre de la puissance|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente vos chances de toucher avec tous les sorts de 4% et réduit les dégâts que vous infligent tous les sorts de 6%.|r", "spellbalanceofpower", 478, -240)
-- CreateSpellButton("buttonSpellMoonkinForm", "Interface/icons/spell_nature_forceofnature", "|cffffffffForme de sélénien|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Le druide adopte sa forme de sélénien. Tant qu'il est sous cette forme, la valeur d'armure apportée par les objets est augmentée de 370%,\nles dégâts qu'il subit alors qu'il est étourdi sont réduits de 15% et tous les membres du groupe\net du raid se trouvant à moins de 100 mètres voient leurs chances d'obtenir un coup critique avec les sorts augmenter de 5%.\nLes critiques réussis avec les sorts monocibles sous cette forme ont une chance de régénérer instantanément 2% de votre total de mana.\nLe sélénien ne peut pas lancer de sorts de soins ou de résurrection tant qu'il est transformé.\n\nLa transformation libère le lanceur de sorts des métamorphoses et des effets qui affectent le déplacement.|r", "spellmoonkinform", 98, -293)
-- CreateSpellButton("buttonSpellImprovedMoonkinForm", "Interface/icons/ability_druid_improvedmoonkinform", "|cffffffffForme de sélénien améliorée|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Votre Aura de sélénien permet aussi aux cibles affectées de voir leur hâte augmenter de 3%,\net vous bénéficiez d'un montant de dégâts des sorts supplémentaire égal à 30% de votre Esprit.|r", "spellimprovedmoonkinform", 205, -293)
-- CreateSpellButton("buttonSpellImprovedFaerieFire", "Interface/icons/spell_nature_faeriefire", "|cffffffffLucioles améliorées|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Votre sort Lucioles augmente aussi les chances que la cible soit touchée par les attaques avec les sorts de 3%\nainsi que vos chances de coup critique avec les sorts infligeant des dégâts sur les cibles affectées par Lucioles de 3%.|r", "spellimprovedfaeriefire", 315, -293)
-- CreateSpellButton("buttonSpellOwlkinFrenzy", "Interface/icons/ability_druid_owlkinfrenzy", "|cffffffffFrénésie du chouettide|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Les attaques que vous subissez lorsque vous êtes en forme de sélénien ont 15% de chances de vous faire entrer dans un état de frénésie,\nqui augmente vos dégâts de 10%, vous rend insensible aux interruptions pendant l'incantation de sorts d'Equilibre et vous donne 2% de votre mana de base toutes les 2 sec.\nDure 10 seconds.|r", "spellowlkinfrenzy", 422, -293)
-- CreateSpellButton("buttonSpellWrathofCenarius", "Interface/icons/ability_druid_twilightswrath", "|cffffffffColère de Cénarius|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Votre sort Feu stellaire bénéficie de 20% supplémentaires et votre Colère de 10% supplémentaires des effets du bonus aux dégâts.|r", "spellwrathofcenarius", 260, -240)
-- CreateSpellButton("buttonSpellEclipse", "Interface/icons/ability_druid_eclipse", "|cffffffffEclipse|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Quand vous réussissez un coup critique avec Feu stellaire, vous avez 100% de chances d'augmenter de 40% les dégâts infligés par Colère.\nQuand vous réussissez un coup critique avec Colère, vous avez 60% de chances d'augmenter vos chances de coup critique avec Feu stellaire de 40%.\nChaque effet dure 15 seconds. et a un temps de recharge distinct de 30 sec.\nLes deux effets ne peuvent se produire simultanément.|r", "spelleclipse", 43, -350)
-- CreateSpellButton("buttonSpellTyphoon", "Interface/icons/ability_druid_typhoon", "|cffffffffTyphon|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Vous invoquez un violent Typhon qui inflige 400 points de dégâts de Nature quand il entre en contact avec des cibles hostiles.\nIl les fait tomber à la renverse et les hébète pendant 6 seconds.|r", "spelltyphoon", 150, -350)
-- CreateSpellButton("buttonSpellForceofNature", "Interface/icons/ability_druid_forceofnature", "|cffffffffForce de la nature|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Invoque 3 tréants qui attaquent les cibles ennemies pendant 30 seconds.|r", "spellforceofnature", 260, -350)
-- CreateSpellButton("buttonSpellGaleWinds", "Interface/icons/ability_druid_galewinds", "|cffffffffGrands vents|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente de 30% les dégâts infligés par vos sorts Ouragan et Typhon, et augmente la portée de votre sort Cyclone de 4 mètres.|r", "spellgalewinds", 368, -350)
-- CreateSpellButton("buttonSpellEarthandMoon", "Interface/icons/ability_druid_earthandsky", "|cffffffffTerre et lune|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Vos sorts Colère et Feu stellaire ont 100% de chances d'appliquer l'effet Terre et lune sur la cible.\nCelui-ci augmente les dégâts des sorts infligés à la cible de 13% pendant 12 seconds.\nAugmente également vos dégâts des sorts de 6%.|r", "spellearthandmoon", 478, -350)
-- CreateSpellButton("buttonSpellStarfall", "Interface/icons/ability_druid_starfall", "|cffffffffMétéores|r\n|cffffffffTalent|r |cff65ca00Equilibre|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Un déluge de météores tombe du ciel sur toutes les cibles se trouvant à moins de a mètres du lanceur de sorts et chacun inflige 145 à 167 points de dégâts des Arcanes.\nInflige également 26 points de dégâts des Arcanes à tous les autres ennemis se trouvant à moins de 5 mètres de la cible ennemie.\n20 météores au maximum. Dure 10 seconds. Si vous changez de forme ou utilisez une monture, l'effet est annulé.\nTout effet qui vous fait perdre le contrôle de votre personnage l'annule également.|r", "spellstarfall", 98, -405)

-- Combat Farouche

{
    id = "spellFerocity",
    name = "buttonSpellFerocity",
    icon = "Interface/icons/ability_hunter_pet_hyena",
    position = {205, -405},
    handler = "spellferocity",
    tooltips = {
        frFR = "|cffffffffFérocité|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit le coût en rage ou en énergie de vos techniques Mutiler, Balayage, Griffe, Griffure et Mutilation de 5.|r",
        enUS = "|cffffffffFerocity|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Reduces the rage or energy cost of your Mangle, Swipe, Claw, Rake, and Mutilate by 5.|r"
    }
},
{
    id = "spellFeralAggression",
    name = "buttonSpellFeralAggression",
    icon = "Interface/icons/ability_druid_demoralizingroar",
    position = {315, -405},
    handler = "spellferalaggression",
    tooltips = {
        frFR = "|cffffffffAgressivité farouche|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente les effets de réduction de la puissance d'attaque de votre Rugissement démoralisant de 40% et les dégâts infligés par votre Morsure féroce de 15%.|r",
        enUS = "|cffffffffFeral Aggression|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases the attack power reduction of your Demoralizing Roar by 40% and the damage dealt by your Ferocious Bite by 15%.|r"
    }
},
{
    id = "spellFeralInstinct",
    name = "buttonSpellFeralInstinct",
    icon = "Interface/icons/ability_ambush",
    position = {422, -405},
    handler = "spellferalinstinct",
    tooltips = {
        frFR = "|cffffffffInstinct farouche|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente de 30% les dégâts infligés par votre technique Balayage et réduit les chances de vous détecter de vos ennemis lorsque vous rôdez.|r",
        enUS = "|cffffffffFeral Instinct|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases the damage of your Swipe ability by 30% and reduces the chances of being detected by enemies while stealthed.|r"
    }
},
{
    id = "spellSavageFury",
    name = "buttonSpellSavageFury",
    icon = "Interface/icons/ability_druid_ravage",
    position = {43, -458},
    handler = "spellsavagefury",
    tooltips = {
        frFR = "|cffffffffFurie sauvage|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente les dégâts infligés par vos techniques Griffe, Griffure, Mutilation (félin), Mutilation (ours) et Mutiler de 20%.|r",
        enUS = "|cffffffffSavage Fury|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases the damage of your Claw, Rake, Mangle (Feline), Mangle (Bear), and Mangle by 20%.|r"
    }
},
{
    id = "spellThickHide",
    name = "buttonSpellThickHide",
    icon = "Interface/icons/inv_misc_pelt_bear_03",
    position = {150, -458},
    handler = "spellthickhide",
    tooltips = {
        frFR = "|cffffffffPeau épaisse|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente de 10% la valeur d'armure apportée par les objets en tissu et en cuir.|r",
        enUS = "|cffffffffThick Hide|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases the armor value from cloth and leather items by 10%.|r"
    }
},
{
    id = "spellFeralSwiftness",
    name = "buttonSpellFeralSwiftness",
    icon = "Interface/icons/spell_nature_spiritwolf",
    position = {260, -458},
    handler = "spellferalswiftness",
    tooltips = {
        frFR = "|cffffffffCélérité farouche|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente votre vitesse de déplacement de 30% avec votre forme de félin\net augmente vos chances d'esquiver lorsque vous êtes en forme de félin, d'ours et d'ours redoutable de 4%.|r",
        enUS = "|cffffffffFeral Swiftness|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases your movement speed by 30% while in Cat Form\nand increases your dodge chance by 4% when in Cat, Bear, and Dire Bear Forms.|r"
    }
},
{
    id = "spellSurvivalInstincts",
    name = "buttonSpellSurvivalInstincts",
    icon = "Interface/icons/ability_druid_tigersroar",
    position = {368, -458},
    handler = "spellsurvivalinstincts",
    tooltips = {
        frFR = "|cffffffffInstincts de survie|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Activée, cette technique vous confère temporairement 30% de votre maximum de points de vie\nen plus pendant 20 seconds lorsque vous êtes en forme d'ours, de félin ou d'ours redoutable.\nLorsque l'effet expire, les points de vie sont perdus.|r",
        enUS = "|cffffffffSurvival Instincts|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100When activated, this ability temporarily increases your maximum health by 30%\nfor 20 seconds while in Bear, Cat, or Dire Bear form.\nHealth is lost when the effect expires.|r"
    }
},
{
    id = "spellSharpenedClaws",
    name = "buttonSpellSharpenedClaws",
    icon = "Interface/icons/inv_misc_monsterclaw_04",
    position = {478, -458},
    handler = "spellsharpenedclaws",
    tooltips = {
        frFR = "|cffffffffGriffes aiguisées|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente de 6% vos chances d'infliger un coup critique lorsque vous êtes transformé en ours, en ours redoutable ou en félin.|r",
        enUS = "|cffffffffSharpened Claws|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases your chance to critically hit by 6% while in Bear, Dire Bear, or Cat form.|r"
    }
},
{
    id = "spellShreddingAttacks",
    name = "buttonSpellShreddingAttacks",
    icon = "Interface/icons/spell_shadow_vampiricaura",
    position = {98, -510},
    handler = "spellshreddingattacks",
    tooltips = {
        frFR = "|cffffffffAttaques lacérantes|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit de 18 le coût en énergie de votre technique Lambeau et de 2 le coût en rage de votre technique Lacérer.|r",
        enUS = "|cffffffffShredding Attacks|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Reduces the energy cost of your Shred ability by 18 and the rage cost of your Lacerate ability by 2.|r"
    }
},
{
    id = "spellPredatoryStrikes",
    name = "buttonSpellPredatoryStrikes",
    icon = "Interface/icons/ability_hunter_pet_cat",
    position = {205, -510},
    handler = "spellpredatorystrikes",
    tooltips = {
        frFR = "|cffffffffFrappes de prédateur|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente votre puissance d'attaque en mêlée en forme de félin, d'ours et d'ours redoutable de 150% de votre niveau et de 20% la puissance d'attaque de votre arme équipée.\nDe plus, vos coups de grâce ont 20% de chances par point de combo de faire de votre prochain sort de Nature au temps d'incantation de base inférieur à 10 sec.\nun sort instantané.|r",
        enUS = "|cffffffffPredatory Strikes|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases your melee attack power in Cat, Bear, and Dire Bear form by 150% of your level and 20% of the attack power from your equipped weapon.\nAdditionally, your finishing moves have a 20% chance per combo point to make your next Nature spell with a base cast time under 10 seconds.\ninstant cast.|r"
    }
},
{
    id = "spellPrimalFury",
    name = "buttonSpellPrimalFury",
    icon = "Interface/icons/ability_racial_cannibalize",
    position = {315, -510},
    handler = "spellprimalfury",
    tooltips = {
        frFR = "|cffffffffFureur primitive|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Vous confère 100% de chances de générer 5 points de rage supplémentaires chaque fois que vous réussissez un coup critique en forme d'ours et d'ours redoutable\net vos coups critiques obtenus avec les techniques de la forme de félin qui ajoutent des points de combo ont 100% de chances d'ajouter un point de combo supplémentaire.|r",
        enUS = "|cffffffffPrimal Fury|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Gives you a 100% chance to generate 5 additional rage points every time you score a critical strike in Bear or Dire Bear form\nand your critical strikes with combo-generating abilities in Cat form have a 100% chance to generate an additional combo point.|r"
    }
},
{
    id = "spellPrimalPrecision",
    name = "buttonSpellPrimalPrecision",
    icon = "Interface/icons/ability_druid_primalprecision",
    position = {422, -510},
    handler = "spellprimalprecision",
    tooltips = {
        frFR = "|cffffffffPrécision primale|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente votre expertise de 10,\net vous êtes remboursé de 80% du coût en énergie d'un coup de grâce si celui-ci échoue.|r",
        enUS = "|cffffffffPrimal Precision|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases your expertise by 10,\nand refunds 80% of the energy cost of a finishing move if it fails.|r"
    }
},


-- CreateSpellButton("buttonSpellFerocity", "Interface/icons/ability_hunter_pet_hyena", "|cffffffffFérocité|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit le coût en rage ou en énergie de vos techniques Mutiler, Balayage, Griffe, Griffure et Mutilation de 5.|r", "spellferocity", 205, -405)
-- CreateSpellButton("buttonSpellFeralAggression", "Interface/icons/ability_druid_demoralizingroar", "|cffffffffAgressivité farouche|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente les effets de réduction de la puissance d'attaque de votre Rugissement démoralisant de 40% et les dégâts infligés par votre Morsure féroce de 15%.|r", "spellferalaggression", 315, -405)
-- CreateSpellButton("buttonSpellFeralInstinct", "Interface/icons/ability_ambush", "|cffffffffInstinct farouche|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente de 30% les dégâts infligés par votre technique Balayage et réduit les chances de vous détecter de vos ennemis lorsque vous rôdez.|r", "spellferalinstinct", 422, -405)
-- CreateSpellButton("buttonSpellSavageFury", "Interface/icons/ability_druid_ravage", "|cffffffffFurie sauvage|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente les dégâts infligés par vos techniques Griffe, Griffure, Mutilation (félin), Mutilation (ours) et Mutiler de 20%.|r", "spellsavagefury", 43, -458)
-- CreateSpellButton("buttonSpellThickHide", "Interface/icons/inv_misc_pelt_bear_03", "|cffffffffPeau épaisse|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente de 10% la valeur d'armure apportée par les objets en tissu et en cuir.|r", "spellthickhide", 150, -458)
-- CreateSpellButton("buttonSpellFeralSwiftness", "Interface/icons/spell_nature_spiritwolf", "|cffffffffCélérité farouche|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente votre vitesse de déplacement de 30% avec votre forme de félin\net augmente vos chances d'esquiver lorsque vous êtes en forme de félin, d'ours et d'ours redoutable de 4%.|r", "spellferalswiftness", 260, -458)
-- CreateSpellButton("buttonSpellSurvivalInstincts", "Interface/icons/ability_druid_tigersroar", "|cffffffffInstincts de survie|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Activée, cette technique vous confère temporairement 30% de votre maximum de points de vie\nen plus pendant 20 seconds lorsque vous êtes en forme d'ours, de félin ou d'ours redoutable.\nLorsque l'effet expire, les points de vie sont perdus.|r", "spellsurvivalinstincts", 368, -458)
-- CreateSpellButton("buttonSpellSharpenedClaws", "Interface/icons/inv_misc_monsterclaw_04", "|cffffffffGriffes aiguisées|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente de 6% vos chances d'infliger un coup critique lorsque vous êtes transformé en ours, en ours redoutable ou en félin.|r", "spellsharpenedclaws", 478, -458)
-- CreateSpellButton("buttonSpellShreddingAttacks", "Interface/icons/spell_shadow_vampiricaura", "|cffffffffAttaques lacérantes|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit de 18 le coût en énergie de votre technique Lambeau et de 2 le coût en rage de votre technique Lacérer.|r", "spellshreddingattacks", 98, -510)
-- CreateSpellButton("buttonSpellPredatoryStrikes", "Interface/icons/ability_hunter_pet_cat", "|cffffffffFrappes de prédateur|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente votre puissance d'attaque en mêlée en forme de félin, d'ours et d'ours redoutable de 150% de votre niveau et de 20% la puissance d'attaque de votre arme équipée.\nDe plus, vos coups de grâce ont 20% de chances par point de combo de faire de votre prochain sort de Nature au temps d'incantation de base inférieur à 10 sec.\nun sort instantané.|r", "spellpredatorystrikes", 205, -510)
-- CreateSpellButton("buttonSpellPrimalFury", "Interface/icons/ability_racial_cannibalize", "|cffffffffFureur primitive|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Vous confère 100% de chances de générer 5 points de rage supplémentaires chaque fois que vous réussissez un coup critique en forme d'ours et d'ours redoutable\net vos coups critiques obtenus avec les techniques de la forme de félin qui ajoutent des points de combo ont 100% de chances d'ajouter un point de combo supplémentaire.|r", "spellprimalfury", 315, -510)
-- CreateSpellButton("buttonSpellPrimalPrecision", "Interface/icons/ability_druid_primalprecision", "|cffffffffPrécision primale|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente votre expertise de 10,\net vous êtes remboursé de 80% du coût en énergie d'un coup de grâce si celui-ci échoue.|r", "spellprimalprecision", 422, -510)

-- Template 2

{
    id = "spellImpactBrutal",
    name = "buttonSpellImpactbrutal",
    icon = "Interface/icons/ability_druid_bash",
    position = {663, -75},
    handler = "spellimpactbrutal",
    tooltips = {
        frFR = "|cffffffffImpact brutal|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente la durée d'étourdissement de vos techniques Sonner\net Traquenard de 1 sec. et réduit le temps de recharge de Sonner de 30 sec.|r",
        enUS = "|cffffffffBrutal Impact|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases the stun duration of your Bash and Pounce by 1 sec, and reduces the cooldown of Bash by 30 sec.|r"
    }
},
{
    id = "spellFeralCharge",
    name = "buttonSpellFeralCharge",
    icon = "Interface/icons/ability_hunter_pet_bear",
    position = {770, -75},
    handler = "spellferalcharge",
    tooltips = {
        frFR = "|cffffffffCharge farouche|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Apprend Charge farouche (ours) et Charge farouche (félin).\n\nCharge farouche (ours) - Vous chargez un ennemi, l'immobilisez et interrompez le sort qu'il incantait pendant 4 secondes.\nCette technique ne peut être utilisée qu'en forme d'ours et d'ours redoutable.\nTemps de recharge de 15 secondes.\n\nCharge farouche (félin) - Vous bondissez derrière un ennemi et l'hébétez pendant 3 secondes.\nTemps de recharge de 30 secondes.|r",
        enUS = "|cffffffffFeral Charge|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Teaches Feral Charge (Bear) and Feral Charge (Cat).\n\nFeral Charge (Bear) - You charge an enemy, stunning and interrupting their casting for 4 seconds.\nThis ability can only be used in Bear and Dire Bear forms.\nCooldown of 15 sec.\n\nFeral Charge (Cat) - You pounce behind an enemy, stunning them for 3 seconds.\nCooldown of 30 sec.|r"
    }
},
{
    id = "spellNurturingInstinct",
    name = "buttonSpellNurturingInstinct",
    icon = "Interface/icons/ability_druid_healinginstincts",
    position = {880, -75},
    handler = "spellnurturinginstinct",
    tooltips = {
        frFR = "|cffffffffInstinct nourricier|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente vos sorts de soins d'un montant égal à 70% au maximum de votre Agilité,\net augmente les soins qui vous sont prodigués de 20% quand vous êtes en forme de félin.|r",
        enUS = "|cffffffffNurturing Instinct|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases your healing abilities by an amount equal to 70% of your Agility,\nand increases the healing you receive by 20% while in Cat form.|r"
    }
},
{
    id = "spellNaturalReaction",
    name = "buttonSpellNaturalReaction",
    icon = "Interface/icons/ability_bullrush",
    position = {990, -75},
    handler = "spellnaturalreaction",
    tooltips = {
        frFR = "|cffffffffRéaction naturelle|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente votre score d'esquive en forme d'ours ou d'ours redoutable de 6%,\net vous régénérez 3 points de rage chaque fois que vous esquivez en forme d'ours ou d'ours redoutable.|r",
        enUS = "|cffffffffNatural Reaction|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases your dodge rating in Bear and Dire Bear forms by 6%,\nand you regenerate 3 rage points each time you dodge in Bear or Dire Bear form.|r"
    }
},
{
    id = "spellHeartOfTheWild",
    name = "buttonSpellHeartoftheWild",
    icon = "Interface/icons/spell_holy_blessingofagility",
    position = {1100, -75},
    handler = "spellheartofthewild",
    tooltips = {
        frFR = "|cffffffffCœur de fauve|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente votre Intelligence de 20%.\nDe plus, votre Endurance est augmentée de 10% lorsque vous êtes en forme d'ours ou d'ours redoutable\net votre puissance d'attaque est augmentée de 10% lorsque vous êtes en forme de félin.|r",
        enUS = "|cffffffffHeart of the Wild|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases your Intellect by 20%,\nand your Stamina is increased by 10% while in Bear or Dire Bear form,\nand your Attack Power is increased by 10% while in Cat form.|r"
    }
},
{
    id = "spellSurvivaloftheFittest",
    name = "buttonSpellSurvivaloftheFittest",
    icon = "Interface/icons/ability_druid_enrage",
    position = {718, -130},
    handler = "spellsurvivalofthefittest",
    tooltips = {
        frFR = "|cffffffffSurvie du plus apte|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente toutes les caractéristiques de 6%, réduit la probabilité que vous soyez touché par un coup critique infligé par une attaque en mêlée de 6%\net augmente de 33% la valeur d'armure apportée par les objets en tissu et en cuir quand vous êtes en forme d'ours et d'ours redoutable.|r",
        enUS = "|cffffffffSurvival of the Fittest|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases all attributes by 6%, reduces the chance you will be critically hit by a melee attack by 6%,\nand increases the armor value of cloth and leather items by 33% when in Bear or Dire Bear form.|r"
    }
},
{
    id = "spellLeaderofthePack",
    name = "buttonSpellLeaderofthePack",
    icon = "Interface/icons/spell_nature_unyeildingstamina",
    position = {825, -130},
    handler = "spellleaderofthepack",
    tooltips = {
        frFR = "|cffffffffChef de la meute|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Pendant qu'il est en forme de félin, d'ours ou d'ours redoutable, le Chef de la meute augmente de 5% les chances\nde tous les membres du groupe se trouvant à moins de 100 mètres d'obtenir un coup critique avec les attaques à distance et en mêlée.|r",
        enUS = "|cffffffffLeader of the Pack|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100While in Cat, Bear, or Dire Bear form, Leader of the Pack increases the chance for all party members within 100 yards to score a critical hit with melee and ranged attacks by 5%.|r"
    }
},
{
    id = "spellImprovedLeaderofthePack",
    name = "buttonSpellImprovedLeaderofthePack",
    icon = "Interface/icons/spell_nature_unyeildingstamina",
    position = {935, -130},
    handler = "spellimprovedleaderofthepack",
    tooltips = {
        frFR = "|cffffffffChef de la meute amélioré|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Votre technique Chef de la meute permet aussi aux cibles affectées d'être soignées pour un montant égal à\n4% de leur total de points de vie lorsqu'elles réussissent un coup critique avec une attaque en mêlée ou à distance.\nL'effet de soins ne peut se produire plus d'une fois toutes les 6 sec.\nDe plus, vous recevez 8% de votre maximum de mana quand vous bénéficiez de ce soin.|r",
        enUS = "|cffffffffImproved Leader of the Pack|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Your Leader of the Pack ability also causes affected targets to be healed for an amount equal to 4% of their total health when they score a critical hit with a melee or ranged attack.\nThe healing effect cannot occur more than once every 6 seconds.\nAdditionally, you receive 8% of your maximum mana when you benefit from this healing.|r"
    }
},
{
    id = "spellPrimalTenacity",
    name = "buttonSpellPrimalTenacity",
    icon = "Interface/icons/ability_druid_primaltenacity",
    position = {1045, -130},
    handler = "spelprimaltenacity",
    tooltips = {
        frFR = "|cffffffffTénacité primordiale|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit de 30% la durée des effets de Peur\net de 30% tous les dégâts subis quand vous êtes en forme de félin alors que vous êtes étourdi.|r",
        enUS = "|cffffffffPrimal Tenacity|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Reduces the duration of Fear effects by 30%\nand reduces all damage taken by 30% when you are stunned while in Cat form.|r"
    }
},
{
    id = "spellProtectorofthePack",
    name = "buttonSpellProtectorofthePack",
    icon = "Interface/icons/ability_druid_challangingroar",
    position = {663, -184},
    handler = "spellprotectorofthepack",
    tooltips = {
        frFR = "|cffffffffProtecteur de la meute|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente votre puissance d'attaque de 6%\net réduit les dégâts que vous subissez de 12% tant que vous êtes en forme d'ours ou d'ours redoutable.|r",
        enUS = "|cffffffffProtector of the Pack|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases your attack power by 6%\nand reduces the damage you take by 12% while in Bear or Dire Bear form.|r"
    }
},
{
    id = "spellMangle",
    name = "buttonSpellMangle",
    icon = "Interface/icons/ability_druid_mangle2",
    position = {770, -184},
    handler = "spellmangle",
    tooltips = {
        frFR = "|cffffffffMutilation|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Mutile la cible, lui inflige des dégâts\net fait augmenter les dégâts infligés par les effets de saignement pendant 60 secondes.\nCette technique peut être utilisée en forme de félin ou d'ours redoutable.|r",
        enUS = "|cffffffffMangle|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Mangles the target, dealing damage and increasing the damage dealt by its bleed effects for 60 seconds.\nThis ability can be used in Cat or Dire Bear form.|r"
    }
},
{
    id = "spellImprovedMangle",
    name = "buttonSpellImprovedMangle",
    icon = "Interface/icons/ability_druid_mangle2",
    position = {880, -184},
    handler = "spellimprovedmangle",
    tooltips = {
        frFR = "|cffffffffMutilation améliorée|r\n|cffffffffTalent|r |cffa07db5Mutilation améliorée|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit le temps de recharge de votre technique Mutilation (ours) de 1.5 sec.,\net réduit le coût en énergie de votre technique Mutilation (félin) de 6.|r",
        enUS = "|cffffffffImproved Mangle|r\n|cffffffffTalent|r |cffa07db5Improved Mangle|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Reduces the cooldown of your Mangle (Bear) ability by 1.5 seconds,\nand reduces the energy cost of your Mangle (Cat) ability by 6.|r"
    }
},
{
    id = "spellRendandTear",
    name = "buttonSpellRendandTear",
    icon = "Interface/icons/ability_druid_primalagression",
    position = {990, -184},
    handler = "spellrendandtear",
    tooltips = {
        frFR = "|cffffffffPourfendre et déchirer|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente les dégâts infligés par les attaques Mutiler et Lambeau sur les cibles qui saignent de 20%,\net augmente les chances de coup critique de votre technique Morsure féroce sur les cibles qui saignent de 25%.|r",
        enUS = "|cffffffffRend and Tear|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases the damage dealt by Mangle and Rake on bleeding targets by 20%,\nand increases the critical strike chance of your Ferocious Bite ability on bleeding targets by 25%.|r"
    }
},
{
    id = "spellPrimalGore",
    name = "buttonSpellPrimalGore",
    icon = "Interface/icons/ability_druid_rake",
    position = {1100, -184},
    handler = "spellprimalgore",
    tooltips = {
        frFR = "|cffffffffLacération primitive|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Les dégâts périodiques de vos techniques Lacérer et Déchirure peuvent être critiques.|r",
        enUS = "|cffffffffPrimal Gore|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100The periodic damage of your Lacerate and Rip abilities can critically strike.|r"
    }
},
{
    id = "spellBerserk",
    name = "buttonSpellBerserk",
    icon = "Interface/icons/ability_druid_berserk",
    position = {718, -240},
    handler = "spellberserk",
    tooltips = {
        frFR = "|cffffffffBerserk|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Activée, cette technique permet à votre technique Mutilation (ours) d'atteindre un maximum de 3 cibles\nen plus de fonctionner sans temps de recharge, et réduit le coût en énergie de toutes vos techniques en forme de félin de 50%.\nDure 15 secondes. Vous ne pouvez pas utiliser Fureur du tigre quand Berserk est actif.\n\nAnnule l'effet de Peur et vous rend insensible à Peur pendant toute sa durée.|r",
        enUS = "|cffffffffBerserk|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100When activated, this ability allows your Mangle (Bear) ability to hit up to 3 targets,\nwhile also functioning without a cooldown, and reduces the energy cost of all your Cat form abilities by 50%. Lasts for 15 seconds. You cannot use Tiger's Fury while Berserk is active.\n\nRemoves the Fear effect and makes you immune to Fear for its duration.|r"
    }
},
{
    id = "spellPredatoryInstincts",
    name = "buttonSpellPredatoryInstincts",
    icon = "Interface/icons/ability_druid_predatoryinstincts",
    position = {825, -240},
    handler = "spellpredatoryinstincts",
    tooltips = {
        frFR = "|cffffffffInstincts de prédateur|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Lorsque vous êtes en forme de félin, augmente les dégâts de vos coups critiques en mêlée de 10% et réduit les dégâts que vous infligent les attaques à zone d'effet de 30%.|r",
        enUS = "|cffffffffPredatory Instincts|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100While in Cat form, increases the damage of your critical melee strikes by 10% and reduces the damage taken from area-of-effect attacks by 30%.|r"
    }
},
{
    id = "spellInfectedWounds",
    name = "buttonSpellInfectedWounds",
    icon = "Interface/icons/ability_druid_infectedwound",
    position = {935, -240},
    handler = "spellinfectedwounds",
    tooltips = {
        frFR = "|cffffffffBlessures infectées|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Vos attaques Lambeau, Mutiler et Mutilation infligent une blessure infectée à la cible.\nLa Blessure infectée réduit la vitesse de déplacement de la cible de 50% et sa vitesse d'attaque de 20%.\nDure 12 secondes.|r",
        enUS = "|cffffffffInfected Wounds|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Your Rake, Mangle, and Mangle (Cat) abilities apply Infected Wounds to the target.\nInfected Wounds reduces the target's movement speed by 50% and attack speed by 20%. Lasts for 12 seconds.|r"
    }
},
{
    id = "spellKingoftheJungle",
    name = "buttonSpellKingoftheJungle",
    icon = "Interface/icons/ability_druid_kingofthejungle",
    position = {1045, -240},
    handler = "spellkingofthejungle",
    tooltips = {
        frFR = "|cffffffffRoi de la jungle|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Lorsque vous utilisez votre technique Enragé en forme d'ours ou d'ours redoutable, vos dégâts sont augmentés de 15%,\net votre technique Fureur du tigre vous rend aussi immédiatement 60 points d'énergie.\nDe plus, le coût en mana des formes d'ours, de félin et d'ours redoutable est réduit de 60%.|r",
        enUS = "|cffffffffKing of the Jungle|r\n|cffffffffTalent|r |cffa07db5Feral Combat|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100When you use your Enrage ability in Bear or Dire Bear form, your damage is increased by 15%,\nand your Tiger's Fury ability instantly restores 60 energy.\nAdditionally, the mana cost of Bear, Cat, and Dire Bear forms is reduced by 60%.|r"
    }
},


-- CreateSpellButton("buttonSpellImpactbrutal", "Interface/icons/ability_druid_bash", "|cffffffffImpact brutal|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente la durée d'étourdissement de vos techniques Sonner\net Traquenard de 1 sec. et réduit le temps de recharge de Sonner de 30 sec.|r", "spellimpactbrutal", 663, -75)
-- CreateSpellButton("buttonSpellFeralCharge", "Interface/icons/ability_hunter_pet_bear", "|cffffffffCharge farouche|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Apprend Charge farouche (ours) et Charge farouche (félin).\n\nCharge farouche (ours) - Vous chargez un ennemi, l'immobilisez et interrompez le sort qu'il incantait pendant 4 secondes.\nCette technique ne peut être utilisée qu'en forme d'ours et d'ours redoutable.\nTemps de recharge de 15 secondes.\n\nCharge farouche (félin) - Vous bondissez derrière un ennemi et l'hébétez pendant 3 secondes.\nTemps de recharge de 30 secondes.|r", "spellferalcharge", 770, -75)
-- CreateSpellButton("buttonSpellNurturingInstinct", "Interface/icons/ability_druid_healinginstincts", "|cffffffffInstinct nourricier|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente vos sorts de soins d'un montant égal à 70% au maximum de votre Agilité,\net augmente les soins qui vous sont prodigués de 20% quand vous êtes en forme de félin.|r", "spellnurturinginstinct", 880, -75)
-- CreateSpellButton("buttonSpellNaturalReaction", "Interface/icons/ability_bullrush", "|cffffffffRéaction naturelle|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente votre score d'esquive en forme d'ours ou d'ours redoutable de 6%,\net vous régénérez 3 points de rage chaque fois que vous esquivez en forme d'ours ou d'ours redoutable.|r", "spellnaturalreaction", 990, -75)
-- CreateSpellButton("buttonSpellHeartoftheWild", "Interface/icons/spell_holy_blessingofagility", "|cffffffffCœur de fauve|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente votre Intelligence de 20%.\nDe plus, votre Endurance est augmentée de 10% lorsque vous êtes en forme d'ours ou d'ours redoutable\net votre puissance d'attaque est augmentée de 10% lorsque vous êtes en forme de félin.|r", "spellheartofthewild", 1100, -75)
-- CreateSpellButton("buttonSpellSurvivaloftheFittest", "Interface/icons/ability_druid_enrage", "|cffffffffSurvie du plus apte|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente toutes les caractéristiques de 6%, réduit la probabilité que vous soyez touché par un coup critique infligé par une attaque en mêlée de 6%\net augmente de 33% la valeur d'armure apportée par les objets en tissu et en cuir quand vous êtes en forme d'ours et d'ours redoutable.|r", "spellsurvivalofthefittest", 718, -130)
-- CreateSpellButton("buttonSpellLeaderofthePack", "Interface/icons/spell_nature_unyeildingstamina", "|cffffffffChef de la meute|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Pendant qu'il est en forme de félin, d'ours ou d'ours redoutable, le Chef de la meute augmente de 5% les chances\nde tous les membres du groupe se trouvant à moins de 100 mètres d'obtenir un coup critique avec les attaques à distance et en mêlée.|r", "spellleaderofthepack", 825, -130)
-- CreateSpellButton("buttonSpellImprovedLeaderofthePack", "Interface/icons/spell_nature_unyeildingstamina", "|cffffffffChef de la meute amélioré|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Votre technique Chef de la meute permet aussi aux cibles affectées d'être soignées pour un montant égal à\n4% de leur total de points de vie lorsqu'elles réussissent un coup critique avec une attaque en mêlée ou à distance.\nL'effet de soins ne peut se produire plus d'une fois toutes les 6 sec.\nDe plus, vous recevez 8% de votre maximum de mana quand vous bénéficiez de ce soin.|r", "spellimprovedleaderofthepack", 935, -130)
-- CreateSpellButton("buttonSpellPrimalTenacity", "Interface/icons/ability_druid_primaltenacity", "|cffffffffTénacité primordiale|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit de 30% la durée des effets de Peur\net de 30% tous les dégâts subis quand vous êtes en forme de félin alors que vous êtes étourdi.|r", "spelprimaltenacity", 1045, -130)
-- CreateSpellButton("buttonSpellProtectorofthePack", "Interface/icons/ability_druid_challangingroar", "|cffffffffProtecteur de la meute|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente votre puissance d'attaque de 6%\net réduit les dégâts que vous subissez de 12% tant que vous êtes en forme d'ours ou d'ours redoutable.|r", "spellprotectorofthepack", 663, -184)
-- CreateSpellButton("buttonSpellMangle", "Interface/icons/ability_druid_mangle2", "|cffffffffMutilation|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Mutile la cible, lui inflige des dégâts\net fait augmenter les dégâts infligés par les effets de saignement pendant 60 seconds.\nCette technique peut être utilisée en forme de félin ou d'ours redoutable.|r", "spellmangle", 770, -184)
-- CreateSpellButton("buttonSpellImprovedMangle", "Interface/icons/ability_druid_mangle2", "|cffffffffMutilation améliorée|r\n|cffffffffTalent|r |cffa07db5Mutilation améliorée|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit le temps de recharge de votre technique Mutilation (ours) de 1.5 sec.,\net réduit le coût en énergie de votre technique Mutilation (félin) de 6.|r", "spellimprovedmangle", 880, -184)
-- CreateSpellButton("buttonSpellRendandTear", "Interface/icons/ability_druid_primalagression", "|cffffffffPourfendre et déchirer|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente les dégâts infligés par les attaques Mutiler et Lambeau sur les cibles qui saignent de 20%,\net augmente les chances de coup critique de votre technique Morsure féroce sur les cibles qui saignent de 25%.|r", "spellrendandtear", 990, -184)
-- CreateSpellButton("buttonSpellPrimalGore", "Interface/icons/ability_druid_rake", "|cffffffffLacération primitive|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Les dégâts périodiques de vos techniques Lacérer et Déchirure peuvent être critiques.", "spellprimalgore", 1100, -184)
-- CreateSpellButton("buttonSpellBerserk", "Interface/icons/ability_druid_berserk", "|cffffffffBerserk|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Activée, cette technique permet à votre technique Mutilation (ours) d'atteindre un maximum de 3 cibles\nen plus de fonctionner sans temps de recharge, et réduit le coût en énergie de toutes vos techniques en forme de félin de 50%.\nDure 15 seconds. Vous ne pouvez pas utiliser Fureur du tigre quand Berserk est actif.\n\nAnnule l'effet de Peur et vous rend insensible à Peur pendant toute sa durée.|r", "spellberserk", 718, -240)
-- CreateSpellButton("buttonSpellPredatoryInstincts", "Interface/icons/ability_druid_predatoryinstincts", "|cffffffffInstincts de prédateur|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Lorsque vous êtes en forme de félin, augmente les dégâts de vos coups critiques en mêlée de 10% et réduit les dégâts que vous infligent les attaques à zone d'effet de 30%.|r", "spellpredatoryinstincts", 825, -240)
-- CreateSpellButton("buttonSpellInfectedWounds", "Interface/icons/ability_druid_infectedwound", "|cffffffffBlessures infectées|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Vos attaques Lambeau, Mutiler et Mutilation infligent une blessure infectée à la cible.\nLa Blessure infectée réduit la vitesse de déplacement de la cible de 50% et sa vitesse d'attaque de 20%.\nDure 12 seconds.|r", "spellinfectedwounds", 935, -240)
-- CreateSpellButton("buttonSpellKingoftheJungle", "Interface/icons/ability_druid_kingofthejungle", "|cffffffffRoi de la jungle|r\n|cffffffffTalent|r |cffa07db5Combat Farouche|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Lorsque vous utilisez votre technique Enragé en forme d'ours ou d'ours redoutable, vos dégâts sont augmentés de 15%,\net votre technique Fureur du tigre vous rend aussi immédiatement 60 points d'énergie.\nDe plus, le coût en mana des formes d'ours, de félin et d'ours redoutable est réduit de 60%.", "spellkingofthejungle", 1045, -240)


-- Restauration

{
    id = "spellImprovedMarkoftheWild",
    name = "buttonSpellImprovedMarkoftheWild",
    icon = "Interface/icons/spell_nature_regeneration",
    position = {663, -293},
    handler = "spellimprovedmarkofthewild",
    tooltips = {
        frFR = "|cffffffffMarque du fauve améliorée|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente les effets de vos sorts Marque du fauve et Don du fauve de 40%,\net augmente l'ensemble de vos totaux de caractéristiques de 2%.|r",
        enUS = "|cffffffffImproved Mark of the Wild|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases the effects of your Mark of the Wild and Gift of the Wild by 40%,\nand increases all of your attribute totals by 2%.|r"
    }
},
{
    id = "spellNaturesFocus",
    name = "buttonSpellNaturesFocus",
    icon = "Interface/icons/spell_nature_healingwavegreater",
    position = {770, -293},
    handler = "spellnaturesfocus",
    tooltips = {
        frFR = "|cffffffffFocalisation de la nature|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit de 70% l'interruption causée par les attaques infligeant des dégâts pendant que vous incantez\nToucher guérisseur, Colère, Sarments, Cyclone, Nourrir, Rétablissement et Tranquillité.|r",
        enUS = "|cffffffffNature's Focus|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Reduces the interruption caused by damage-dealing attacks while casting Healing Touch, Wrath, Entangling Roots, Cyclone, Nourish, Rejuvenation, and Tranquility by 70%.|r"
    }
},
{
    id = "spellFuror",
    name = "buttonSpellFuror",
    icon = "Interface/icons/spell_holy_blessingofstamina",
    position = {990, -293},
    handler = "spellfuror",
    tooltips = {
        frFR = "|cffffffffFureur|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Vous confère 100% de chances de gagner 10 points de rage lorsque vous vous transformez en ours et ours redoutable.\nVous conservez jusqu'à 100 de vos points d'énergie lorsque vous vous transformez en félin.\nAugmente de 10% votre total d'Intelligence lorsque vous êtes en forme de sélénien.|r",
        enUS = "|cffffffffFuror|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Gives you a 100% chance to gain 10 rage points when shifting into Bear and Dire Bear form.\nYou retain up to 100 energy when shifting into Cat form.\nIncreases your total Intelligence by 10% while in Moonkin form.|r"
    }
},
{
    id = "spellNaturalist",
    name = "buttonSpellNaturalist",
    icon = "Interface/icons/spell_nature_healingtouch",
    position = {880, -293},
    handler = "spellnaturalist",
    tooltips = {
        frFR = "|cffffffffNaturaliste|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit le temps d'incantation de votre sort Toucher guérisseur de 0.5 sec.\net augmente les dégâts que vous infligez avec les attaques physiques sous toutes les formes de 10%.|r",
        enUS = "|cffffffffNaturalist|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Reduces the casting time of your Healing Touch by 0.5 seconds,\nand increases your physical attack damage in all forms by 10%.|r"
    }
},
{
    id = "spellSubtlety",
    name = "buttonSpellSubtlety",
    icon = "Interface/icons/ability_eyeoftheowl",
    position = {1100, -293},
    handler = "spellsubtlety",
    tooltips = {
        frFR = "|cffffffffDiscrétion|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit de 30% la menace générée par vos sorts de restauration\net réduit de 30% la probabilité que vos sorts bénéfiques, Eclat lunaire et Essaim d'insectes soient dissipés.|r",
        enUS = "|cffffffffSubtlety|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Reduces the threat generated by your healing spells by 30%\nand reduces the chance for your beneficial spells, Moonfire, and Insect Swarm to be dispelled by 30%.|r"
    }
},
{
    id = "spellNaturalShapeshifter",
    name = "buttonSpellNaturalShapeshifter",
    icon = "Interface/icons/spell_nature_wispsplode",
    position = {718, -348},
    handler = "spellnaturalshapeshifter",
    tooltips = {
        frFR = "|cffffffffChangeforme naturel|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit le coût en mana de tous les changements de forme de 30%.|r",
        enUS = "|cffffffffNatural Shapeshifter|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Reduces the mana cost of all shapeshifts by 30%.|r"
    }
},
{
    id = "spellIntensity",
    name = "buttonSpellIntensity",
    icon = "Interface/icons/spell_frost_windwalkon",
    position = {825, -348},
    handler = "spellintensity",
    tooltips = {
        frFR = "|cffffffffIntensité|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Vous confère 50% de votre vitesse de récupération du mana normale pendant l'incantation.\nVotre technique Enrager génère instantanément 10 points de rage.|r",
        enUS = "|cffffffffIntensity|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Gives you 50% of your normal mana regeneration rate while casting.\nYour Enrage ability instantly generates 10 rage.|r"
    }
},
{
    id = "spellOmenofClarity",
    name = "buttonSpellOmenofClarity",
    icon = "Interface/icons/spell_nature_crystalball",
    position = {935, -348},
    handler = "spellomenofclarity",
    tooltips = {
        frFR = "|cffffffffAugure de clarté|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Tous les dégâts, sorts de soins et attaques automatiques du druide ont une chance de faire entrer le lanceur de sorts dans un état d'Idées claires.\nCet état réduit le coût en mana, en rage ou en énergie de votre prochain sort de dégât ou de soins ou de votre prochaine technique offensive de 100%.|r",
        enUS = "|cffffffffOmen of Clarity|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100All damage, healing spells, and auto-attacks from the druid have a chance to enter the Clearcasting state.\nThis state reduces the mana, rage, or energy cost of your next damage or healing spell or next offensive ability by 100%.|r"
    }
},
{
    id = "spellMasterShapeshifter",
    name = "buttonSpellMasterShapeshifter",
    icon = "Interface/icons/ability_druid_mastershapeshifter",
    position = {1045, -348},
    handler = "spellmastershapeshifter",
    tooltips = {
        frFR = "|cffffffffMaître changeforme|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Le druide bénéficie d'un effet tant qu'il conserve la forme concernée.\n\nForme d'ours - Augmente les dégâts physiques de 4%.\n\nForme de félin - Augmente les chances de coup critique de 4%.\n\nForme de sélénien - Augmente les dégâts des sorts de 4%.\n\nForme d'arbre de vie - Augmente les soins de 4%.|r",
        enUS = "|cffffffffMaster Shapeshifter|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100The druid gains an effect as long as they stay in the form:\n\nBear Form - Increases physical damage by 4%.\n\nCat Form - Increases critical strike chance by 4%.\n\nMoonkin Form - Increases spell damage by 4%.\n\nTree of Life Form - Increases healing done by 4%.|r"
    }
},
{
    id = "spellTranquilSpirit",
    name = "buttonSpellTranquilSpirit",
    icon = "Interface/icons/spell_holy_elunesgrace",
    position = {663, -402},
    handler = "spelltranquilspirit",
    tooltips = {
        frFR = "|cffffffffTranquillité de l'esprit|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit le coût en mana de vos sorts\nToucher guérisseur, Nourrir et Tranquillité de 10%.|r",
        enUS = "|cffffffffTranquil Spirit|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Reduces the mana cost of your Healing Touch, Nourish, and Tranquility spells by 10%.|r"
    }
},
{
    id = "spellImprovedRejuvenation",
    name = "buttonSpellImprovedRejuvenation",
    icon = "Interface/icons/spell_nature_rejuvenation",
    position = {770, -402},
    handler = "spellimprovedrejuvenation",
    tooltips = {
        frFR = "|cffffffffRécupération améliorée|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente les effets de votre sort Récupération de 15%.|r",
        enUS = "|cffffffffImproved Rejuvenation|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases the effectiveness of your Rejuvenation spell by 15%.|r"
    }
},
{
    id = "spellNaturesSwiftness",
    name = "buttonSpellNaturesSwiftness",
    icon = "Interface/icons/spell_nature_ravenform",
    position = {880, -402},
    handler = "spellnaturesswiftness",
    tooltips = {
        frFR = "|cffffffffRapidité de la nature|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Lorsque cette technique est activée, votre prochain sort de Nature dont le temps d'incantation de base est inférieur à 10 sec. devient un sort instantané.|r",
        enUS = "|cffffffffNature's Swiftness|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100When activated, your next Nature spell with a base cast time of less than 10 seconds becomes instant.|r"
    }
},
{
    id = "spellGiftofNature",
    name = "buttonSpellGiftofNature",
    icon = "Interface/icons/spell_nature_protectionformnature",
    position = {990, -402},
    handler = "spellgiftofnature",
    tooltips = {
        frFR = "|cffffffffDon de la Nature|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente les effets de tous les sorts de soins de 10%.|r",
        enUS = "|cffffffffGift of Nature|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases the effects of all healing spells by 10%.|r"
    }
},
{
    id = "spellImprovedTranquility",
    name = "buttonSpellImprovedTranquility",
    icon = "Interface/icons/spell_nature_tranquility",
    position = {1100, -402},
    handler = "spellimprovedtranquility",
    tooltips = {
        frFR = "|cffffffffTranquillité améliorée|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Diminue le niveau de menace généré par Tranquillité de 100%,\net réduit le temps de recharge de 60%.|r",
        enUS = "|cffffffffImproved Tranquility|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Reduces the threat generated by Tranquility by 100% and reduces its cooldown by 60%.|r"
    }
},
{
    id = "spellEmpoweredTouch",
    name = "buttonSpellEmpoweredTouch",
    icon = "Interface/icons/ability_druid_empoweredtouch",
    position = {718, -456},
    handler = "spellempoweredtouch",
    tooltips = {
        frFR = "|cffffffffToucher surpuissant|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Votre sort Toucher guérisseur bénéficie de 40% supplémentaires\net votre sort Nourrir de 20% des effets du bonus relatif aux soins.|r",
        enUS = "|cffffffffEmpowered Touch|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Your Healing Touch spell benefits from an additional 40% and your Nourish spell benefits from 20% more healing bonus effects.|r"
    }
},
{
    id = "spellNaturesBounty",
    name = "buttonSpellNaturesBounty",
    icon = "Interface/icons/spell_nature_resistnature",
    position = {825, -456},
    handler = "spellnaturesbounty",
    tooltips = {
        frFR = "|cffffffffBonté de la nature|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente les chances d'obtenir un effet critique avec vos sorts Rétablissement et Nourrir de 25%.|r",
        enUS = "|cffffffffNature's Bounty|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases your critical chance with your Rejuvenation and Nourish spells by 25%.|r"
    }
},
{
    id = "spellLivingSpirit",
    name = "buttonSpellLivingSpirit",
    icon = "Interface/icons/spell_nature_giftofthewaterspirit",
    position = {935, -456},
    handler = "spelllivingspirit",
    tooltips = {
        frFR = "|cffffffffEsprit vif|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente votre total d'Esprit de 15%.|r",
        enUS = "|cffffffffLiving Spirit|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases your Spirit stat by 15%.|r"
    }
},
{
    id = "spellSwiftmend",
    name = "buttonSpellSwiftmend",
    icon = "Interface/icons/inv_relics_idolofrejuvenation",
    position = {1045, -456},
    handler = "spellswiftmend",
    tooltips = {
        frFR = "|cffffffffPrompte guérison|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Consume un effet de Récupération ou de Rétablissement sur une cible alliée\npour lui rendre instantanément le montant de points de vie équivalent à 12 sec. de Récupération ou 18 sec. de Rétablissement.|r",
        enUS = "|cffffffffSwiftmend|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Consumes a Rejuvenation or Regrowth effect on an ally target to instantly heal them for the amount of healing over 12 seconds of Rejuvenation or 18 seconds of Regrowth.|r"
    }
},
{
    id = "spellNaturalPerfection",
    name = "buttonSpellNaturalPerfection",
    icon = "Interface/icons/ability_druid_naturalperfection",
    position = {663, -510},
    handler = "spellnaturalperfection",
    tooltips = {
        frFR = "|cffffffffPerfection naturelle|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Vos chances d'obtenir un coup critique avec tous les sorts sont augmentées de 3%\net les coups critiques contre vous vous font bénéficier de l'effet de Perfection naturelle qui réduit tous les dégâts que vous subissez de 4%.\nCumulable jusqu'à 3 fois\nDure 8 seconds.|r",
        enUS = "|cffffffffNatural Perfection|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases your critical chance with all spells by 3% and critical strikes against you grant the Natural Perfection effect which reduces all damage taken by 4%. Stackable up to 3 times. Lasts 8 seconds.|r"
    }
},
{
    id = "spellEmpoweredRejuvenation",
    name = "buttonSpellEmpoweredRejuvenation",
    icon = "Interface/icons/ability_druid_empoweredrejuvination",
    position = {770, -510},
    handler = "spellempoweredrejuvenation",
    tooltips = {
        frFR = "|cffffffffRécupération surpuissante|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Les effets du bonus relatif aux soins de vos sorts de soins sur la durée sont augmentés de 20%.|r",
        enUS = "|cffffffffEmpowered Rejuvenation|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases the healing bonus effects of your Heal over Time spells by 20%.|r"
    }
},
{
    id = "spellLivingSeed",
    name = "buttonLivingSeed",
    icon = "Interface/icons/ability_druid_giftoftheearthmother",
    position = {880, -510},
    handler = "spelllivingseed",
    tooltips = {
        frFR = "|cffffffffGraine de vie|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Quand vous réussissez des soins critiques avec vos sorts Prompte guérison, Rétablissement, Nourrir ou Toucher guérisseur,\nvous avez 100% de chances de planter une Graine de vie sur la cible pour un montant égal à 30% des points de vie rendus.\nLa Graine de vie fleurira lors de la prochaine attaque sur la cible.\nDure 15 seconds.|r",
        enUS = "|cffffffffLiving Seed|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100When you critically heal with your Swiftmend, Rejuvenation, Nourish, or Healing Touch,\nyou have a 100% chance to plant a Living Seed on the target equal to 30% of the healing done.\nThe Living Seed blooms when the target is next attacked.\nLasts 15 seconds.|r"
    }
},
{
    id = "spellRevitalize",
    name = "buttonSpellRevitalize",
    icon = "Interface/icons/ability_druid_replenish",
    position = {990, -510},
    handler = "spellrevitalize",
    tooltips = {
        frFR = "|cffffffffRevitaliser|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Vos sorts Récupération et Croissance sauvage ont 15% de chances de rendre 8 points d'énergie,\n4 points de rage, 1% du mana ou 16 points de puissance runique par itération.|r",
        enUS = "|cffffffffRevitalize|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Your Rejuvenation and Wild Growth spells have a 15% chance to restore 8 energy, 4 rage, 1% mana, or 16 runic power per tick.|r"
    }
},
{
    id = "spellTreeofLife",
    name = "buttonSpellTreeofLife",
    icon = "Interface/icons/ability_druid_treeoflife",
    position = {1100, -510},
    handler = "spelltreeoflife",
    tooltips = {
        frFR = "|cffffffffArbre de vie|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit le coût en mana de vos sorts de soins sur la durée de 20% et permet d'adopter la forme de l'Arbre de vie.\nTant que vous êtes sous cette forme,\nles soins reçus sont augmentés de 6% pour tous les membres du groupe et du raid se trouvant à moins de 100 mètres,\net vous ne pouvez lancer que des sorts de Restauration en plus d'Innervation, Ecorce, Emprise de la nature et Epines.\nLa transformation libère le lanceur de sorts des effets qui le ralentissent et des métamorphoses.|r",
        enUS = "|cffffffffTree of Life|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Reduces the mana cost of your healing-over-time spells by 20% and allows you to assume the Tree of Life form.\nWhile in this form,\nhealing received is increased by 6% for all party and raid members within 100 yards,\nand you can only cast Restoration spells along with Innervate, Barkskin, Nature's Grasp, and Thorns.\nThe transformation also frees you from movement impairing effects and shapeshifts.|r"
    }
},
{
    id = "spellImprovedTreeofLife",
    name = "buttonSpellImprovedTreeofLife",
    icon = "Interface/icons/ability_druid_improvedtreeform",
    position = {716, -564},
    handler = "spellimprovedtreeoflife",
    tooltips = {
        frFR = "|cffffffffArbre de vie amélioré|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente de 200% la valeur d'armure apportée par les objets lorsque vous êtes en forme d'Arbre de vie,\net augmente votre puissance des sorts de 15% de votre Esprit lorsque vous êtes en forme d'Arbre de vie.|r",
        enUS = "|cffffffffImproved Tree of Life|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases your armor value from items by 200% while in Tree of Life form,\nand increases your spell power by 15% of your Spirit while in Tree of Life form.|r"
    }
},
{
    id = "spellImprovedBarkskin",
    name = "buttonSpellImprovedBarkskin",
    icon = "Interface/icons/spell_nature_stoneclawtotem",
    position = {824, -564},
    handler = "spellimprovedbarkskin",
    tooltips = {
        frFR = "|cffffffffEcorce améliorée|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente de 160% la valeur d’armure apportée par les objets en tissu et en cuir lorsque vous êtes en forme de voyage ou que vous n'avez pas changé de forme,\naugmente la réduction de dégâts conférée par votre sort Ecorce de 10% et réduit la probabilité que votre Ecorce soit dissipée de 70%.|r",
        enUS = "|cffffffffImproved Barkskin|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases the armor value from cloth and leather items by 160% while in Travel Form or while shapeless,\nincreases the damage reduction from your Barkskin by 10%, and reduces the chance for your Barkskin to be dispelled by 70%.|r"
    }
},
{
    id = "spellGiftoftheEarthmother",
    name = "buttonSpellGiftoftheEarthmother",
    icon = "Interface/icons/ability_druid_manatree",
    position = {934, -564},
    handler = "spellgiftoftheearthmother",
    tooltips = {
        frFR = "|cffffffffDon de la Terre-mère|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente votre total de hâte des sorts de 10%\net réduit le temps de recharge de base de votre sort Fleur de vie de 10%.|r",
        enUS = "|cffffffffGift of the Earthmother|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Increases your spell haste by 10%\nand reduces the cooldown of your Lifebloom by 10%.|r"
    }
},
{
    id = "spellWildGrowth",
    name = "buttonSpellWildGrowth",
    icon = "Interface/icons/ability_druid_flourish",
    position = {1045, -564},
    handler = "spellwildgrowth",
    tooltips = {
        frFR = "|cffffffffCroissance sauvage|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Rend à 5 membres au maximum du groupe ou du raid alliés se trouvant à moins de 15 mètres de la cible 686 points de vie en 7 seconds.\nLes soins sont prodigués rapidement au début, et ralentissent au fur et à mesure que Croissance sauvage atteint la fin de sa durée.|r",
        enUS = "|cffffffffWild Growth|r\n|cffffffffTalent|r |cff9cef03Restoration|r\n|cffffffffRequires|r |cffff7d0aDruid|r\n|cffffd100Heals up to 5 party or raid members within 15 yards of the target for 686 health over 7 seconds.\nHealing is done rapidly at the start, and slows down as Wild Growth reaches the end of its duration.|r"
		}
	}
}


-- CreateSpellButton("buttonSpellImprovedMarkoftheWild", "Interface/icons/spell_nature_regeneration", "|cffffffffMarque du fauve améliorée|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente les effets de vos sorts Marque du fauve et Don du fauve de 40%,\net augmente l'ensemble de vos totaux de caractéristiques de 2%.|r", "spellimprovedmarkofthewild", 663, -293)
-- CreateSpellButton("buttonSpellNaturesFocus", "Interface/icons/spell_nature_healingwavegreater", "|cffffffffFocalisation de la nature|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit de 70% l'interruption causée par les attaques infligeant des dégâts pendant que vous incantez\nToucher guérisseur, Colère, Sarments, Cyclone, Nourrir, Rétablissement et Tranquillité.|r", "spellnaturesfocus", 770, -293)
-- CreateSpellButton("buttonSpellFuror", "Interface/icons/spell_holy_blessingofstamina", "|cffffffffFureur|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Vous confère 100% de chances de gagner 10 points de rage lorsque vous vous transformez en ours et ours redoutable.\nVous conservez jusqu'à 100 de vos points d'énergie lorsque vous vous transformez en félin.\nAugmente de 10% votre total d'Intelligence lorsque vous êtes en forme de sélénien.|r", "spellfuror", 990, -293)
-- CreateSpellButton("buttonSpellNaturalist", "Interface/icons/spell_nature_healingtouch", "|cffffffffNaturaliste|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit le temps d'incantation de votre sort Toucher guérisseur de 0.5 sec.\net augmente les dégâts que vous infligez avec les attaques physiques sous toutes les formes de 10%.|r", "spellnaturalist", 880, -293)
-- CreateSpellButton("buttonSpellSubtlety", "Interface/icons/ability_eyeoftheowl", "|cffffffffDiscrétion|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit de 30% la menace générée par vos sorts de restauration\net réduit de 30% la probabilité que vos sorts bénéfiques, Eclat lunaire et Essaim d'insectes soient dissipés.|r", "spellsubtlety", 1100, -293)
-- CreateSpellButton("buttonSpellNaturalShapeshifter", "Interface/icons/spell_nature_wispsplode", "|cffffffffChangeforme naturel|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit le coût en mana de tous les changements de forme de 30%.|r", "spellnaturalshapeshifter", 718, -348)
-- CreateSpellButton("buttonSpellIntensity", "Interface/icons/spell_frost_windwalkon", "|cffffffffIntensité|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Vous confère 50% de votre vitesse de récupération du mana normale pendant l'incantation.\nVotre technique Enrager génère instantanément 10 points de rage.|r", "spellintensity", 825, -348)
-- CreateSpellButton("buttonSpellOmenofClarity", "Interface/icons/spell_nature_crystalball", "|cffffffffAugure de clarté|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Tous les dégâts, sorts de soins et attaques automatiques du druide ont une chance de faire entrer le lanceur de sorts dans un état d'Idées claires.\nCet état réduit le coût en mana, en rage ou en énergie de votre prochain sort de dégât ou de soins ou de votre prochaine technique offensive de 100%.|r", "spellomenofclarity", 935, -348)
-- CreateSpellButton("buttonSpellMasterShapeshifter", "Interface/icons/ability_druid_mastershapeshifter", "|cffffffffMaître changeforme|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Le druide bénéficie d'un effet tant qu'il conserve la forme concernée.\n\nForme d'ours - Augmente les dégâts physiques de 4%.\n\nForme de félin - Augmente les chances de coup critique de 4%.\n\nForme de sélénien - Augmente les dégâts des sorts de 4%.\n\nForme d'arbre de vie - Augmente les soins de 4%.|r", "spellmastershapeshifter", 1045, -348)
-- CreateSpellButton("buttonSpellTranquilSpirit", "Interface/icons/spell_holy_elunesgrace", "|cffffffffTranquillité de l'esprit|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit le coût en mana de vos sorts\nToucher guérisseur, Nourrir et Tranquillité de 10%.|r", "spelltranquilspirit", 663, -402)
-- CreateSpellButton("buttonSpellImprovedRejuvenation", "Interface/icons/spell_nature_rejuvenation", "|cffffffffRécupération améliorée|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente les effets de votre sort Récupération de 15%.|r", "spellimprovedrejuvenation", 770, -402)
-- CreateSpellButton("buttonSpellNaturesSwiftness", "Interface/icons/spell_nature_ravenform", "|cffffffffRapidité de la nature|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Lorsque cette technique est activée, votre prochain sort de Nature dont le temps d'incantation de base est inférieur à 10 sec. devient un sort instantané.|r", "spellnaturesswiftness", 880, -402)
-- CreateSpellButton("buttonSpellGiftofNature", "Interface/icons/spell_nature_protectionformnature", "|cffffffffDon de la Nature|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente les effets de tous les sorts de soins de 10%.|r", "spellgiftofnature", 990, -402)
-- CreateSpellButton("buttonSpellImprovedTranquility", "Interface/icons/spell_nature_tranquility", "|cffffffffTranquillité améliorée|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Diminue le niveau de menace généré par Tranquillité de 100%,\net réduit le temps de recharge de 60%.|r", "spellimprovedtranquility", 1100, -402)
-- CreateSpellButton("buttonSpellEmpoweredTouch", "Interface/icons/ability_druid_empoweredtouch", "|cffffffffToucher surpuissant|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Votre sort Toucher guérisseur bénéficie de 40% supplémentaires\net votre sort Nourrir de 20% des effets du bonus relatif aux soins.|r", "spellempoweredtouch", 718, -456)
-- CreateSpellButton("buttonSpellNaturesBounty", "Interface/icons/spell_nature_resistnature", "|cffffffffBonté de la nature|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente les chances d'obtenir un effet critique avec vos sorts Rétablissement et Nourrir de 25%.|r", "spellnaturesbounty", 825, -456)
-- CreateSpellButton("buttonSpellLivingSpirit", "Interface/icons/spell_nature_giftofthewaterspirit", "|cffffffffEsprit vif|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente votre total d'Esprit de 15%.|r", "spelllivingspirit", 935, -456)
-- CreateSpellButton("buttonSpellSwiftmend", "Interface/icons/inv_relics_idolofrejuvenation", "|cffffffffPrompte guérison|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Consume un effet de Récupération ou de Rétablissement sur une cible alliée\npour lui rendre instantanément le montant de points de vie équivalent à 12 sec. de Récupération ou 18 sec. de Rétablissement.|r", "spellswiftmend", 1045, -456)
-- CreateSpellButton("buttonSpellNaturalPerfection", "Interface/icons/ability_druid_naturalperfection", "|cffffffffPerfection naturelle|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Vos chances d'obtenir un coup critique avec tous les sorts sont augmentées de 3%\net les coups critiques contre vous vous font bénéficier de l'effet de Perfection naturelle qui réduit tous les dégâts que vous subissez de 4%.\nCumulable jusqu'à 3 fois\nDure 8 seconds.|r", "spellnaturalperfection", 663, -510)
-- CreateSpellButton("buttonSpellEmpoweredRejuvenation", "Interface/icons/ability_druid_empoweredrejuvination", "|cffffffffRécupération surpuissante|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Les effets du bonus relatif aux soins de vos sorts de soins sur la durée sont augmentés de 20%.|r", "spellempoweredrejuvenation", 770, -510)
-- CreateSpellButton("buttonLivingSeed", "Interface/icons/ability_druid_giftoftheearthmother", "|cffffffffGraine de vie|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Quand vous réussissez des soins critiques avec vos sorts Prompte guérison, Rétablissement, Nourrir ou Toucher guérisseur,\nvous avez 100% de chances de planter une Graine de vie sur la cible pour un montant égal à 30% des points de vie rendus.\nLa Graine de vie fleurira lors de la prochaine attaque sur la cible.\nDure 15 seconds.|r", "spelllivingseed", 880, -510)
-- CreateSpellButton("buttonSpellRevitalize", "Interface/icons/ability_druid_replenish", "|cffffffffRevitaliser|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Vos sorts Récupération et Croissance sauvage ont 15% de chances de rendre 8 points d'énergie,\n4 points de rage, 1% du mana ou 16 points de puissance runique par itération.|r", "spellrevitalize", 990, -510)
-- CreateSpellButton("buttonSpellTreeofLife", "Interface/icons/ability_druid_treeoflife", "|cffffffffArbre de vie|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Réduit le coût en mana de vos sorts de soins sur la durée de 20% et permet d'adopter la forme de l'Arbre de vie.\nTant que vous êtes sous cette forme,\nles soins reçus sont augmentés de 6% pour tous les membres du groupe et du raid se trouvant à moins de 100 mètres,\net vous ne pouvez lancer que des sorts de Restauration en plus d'Innervation, Ecorce, Emprise de la nature et Epines.\nLa transformation libère le lanceur de sorts des effets qui le ralentissent et des métamorphoses.|r", "spelltreeoflife", 1100, -510)
-- CreateSpellButton("buttonSpellImprovedTreeofLife", "Interface/icons/ability_druid_improvedtreeform", "|cffffffffArbre de vie amélioré|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente de 200% la valeur d'armure apportée par les objets lorsque vous êtes en forme d'Arbre de vie,\net augmente votre puissance des sorts de 15% de votre Esprit lorsque vous êtes en forme d'Arbre de vie.|r", "spellimprovedtreeoflife", 716, -564)
-- CreateSpellButton("buttonSpellImprovedBarkskin", "Interface/icons/spell_nature_stoneclawtotem", "|cffffffffEcorce améliorée|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente de 160% la valeur d’armure apportée par les objets en tissu et en cuir lorsque vous êtes en forme de voyage ou que vous n'avez pas changé de forme,\naugmente la réduction de dégâts conférée par votre sort Ecorce de 10% et réduit la probabilité que votre Ecorce soit dissipée de 70%.|r", "spellimprovedbarkskin", 824, -564)
-- CreateSpellButton("buttonSpellGiftoftheEarthmother", "Interface/icons/ability_druid_manatree", "|cffffffffDon de la Terre-mère|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Augmente votre total de hâte des sorts de 10%\net réduit le temps de recharge de base de votre sort Fleur de vie de 10%.|r", "spellgiftoftheearthmother", 934, -564)
-- CreateSpellButton("buttonSpellWildGrowth", "Interface/icons/ability_druid_flourish", "|cffffffffCroissance sauvage|r\n|cffffffffTalent|r |cff9cef03Restauration|r\n|cffffffffRequiert|r |cffff7d0aDruide|r\n|cffffd100Rend à 5 membres au maximum du groupe ou du raid alliés se trouvant à moins de 15 mètres de la cible 686 points de vie en 7 seconds.\nLes soins sont prodigués rapidement au début, et ralentissent au fur et à mesure que Croissance sauvage atteint la fin de sa durée.|r", "spellwildgrowth", 1045, -564)

-- Fonction pour obtenir le texte localisé
local function GetLocalizedText(tooltipTable)
    local locale = GetLocale() -- "frFR", "enUS", etc.
    return tooltipTable[locale] or "Text not available"
end

-- Création automatique des boutons
for _, spell in ipairs(spells) do
    CreateSpellButton(
        spell.name,                   -- Nom du bouton
        spell.icon,                   -- Chemin de l'icône
        GetLocalizedText(spell.tooltips), -- Texte localisé
        spell.handler,                -- Nom du handler
        unpack(spell.position)        -- Position X, Y
    )
end
-------------------------------------------------------------

-------------------------------------------------------------

-- Définir les textes en fonction de la langue locale
local saveButtonText, screenshotMessage

if GetLocale() == "frFR" then
    saveButtonText = "Sauvegarder"
    screenshotMessage = "Capture d'écran enregistrée dans le dossier Screenshots."
elseif GetLocale() == "enUS" then
    saveButtonText = "Save"
    screenshotMessage = "Screenshot saved in the Screenshots folder."
else
    -- Valeurs par défaut en anglais si la langue n'est ni frFR ni enUS
    saveButtonText = "Save"
    screenshotMessage = "Screenshot saved in the Screenshots folder."
end

-- Créez le bouton Save à l'intérieur de la fenêtre frameTalentDruid
local saveButton = CreateFrame("Button", "saveButton", frameTalentDruid, "UIPanelButtonTemplate")
saveButton:SetSize(85, 25)
saveButton:SetPoint("BOTTOMRIGHT", buttonTalentDruidClose, "BOTTOMLEFT", -185, 5) -- Place le bouton Save à gauche du bouton Close
saveButton:SetText(saveButtonText)

-- Fonction qui prend un screenshot quand le bouton est cliqué
saveButton:SetScript("OnClick", function()
    Screenshot()  -- Prendre un screenshot et l'enregistrer dans le dossier Screenshots du jeu
    print(screenshotMessage)  -- Affiche un message de confirmation en fonction de la locale
end)

-- Affiche l'UI des talents
--frameTalentDruid:Show()

-- Définir les textes en fonction de la langue locale
local buttonResetText, buttonReloadText

if GetLocale() == "frFR" then
    buttonResetText = "Réinitialiser"
    buttonReloadText = "Actualiser"
elseif GetLocale() == "enUS" then
    buttonResetText = "Reset"
    buttonReloadText = "Reload"
else
    -- Valeurs par défaut en anglais si la langue n'est ni frFR ni enUS
    buttonResetText = "Reset"
    buttonReloadText = "Reload"
end

-- Ajoutez une variable pour suivre l'état du bouton Réinitialiser
local resetButtonClicked = false

-- Créez le bouton Reset à l'intérieur de la fenêtre frameTalentDruid
local buttonReset = CreateFrame("Button", "buttonReset", frameTalentDruid, "UIPanelButtonTemplate")
buttonReset:SetSize(85, 25)
buttonReset:SetPoint("BOTTOMRIGHT", buttonTalentDruidClose, "BOTTOMLEFT", -95, 5) -- Place le bouton Reset à gauche du bouton Reload
buttonReset:SetText(buttonResetText)

local function ResetTalents()
    -- Ajoutez ici la logique pour réinitialiser les talents du joueur
    AIO.Handle("TalentDruidspell", "ResetTalents")
    resetButtonClicked = true -- Marquez le bouton Réinitialiser comme cliqué
end

buttonReset:SetScript("OnClick", ResetTalents)

-- Créez le bouton Reload à l'intérieur de la fenêtre frameTalentDruid
local buttonReload = CreateFrame("Button", "buttonReload", frameTalentDruid, "UIPanelButtonTemplate")
buttonReload:SetSize(85, 25)
buttonReload:SetPoint("BOTTOMRIGHT", buttonTalentDruidClose, "BOTTOMLEFT", -5, 5) -- Place le bouton Reload à gauche du bouton Close
buttonReload:SetText(buttonReloadText)

local function ReloadClient()
    -- Ajoutez une vérification pour s'assurer que le bouton Réinitialiser a été cliqué
    if resetButtonClicked then
        ReloadUI()
    else
        -- Affiche un message informatif si "Réinitialiser" n'a pas été cliqué
        if GetLocale() == "frFR" then
            print("|cff00ffffVous ne pouvez <Actualiser> que lorsque vous <Réinitialiser> vos talents.")
        else
            print("|cff00ffffYou can only <Reload> after <Resetting> your talents.")
        end
    end
end

buttonReload:SetScript("OnClick", ReloadClient)

-- Ajoutez une variable globale pour suivre l'état de la fenêtre des talents
local talentsWindowOpen = false

local function OuvrirFermerInterfaceTalents()
    if talentsWindowOpen then
        frameTalentDruid:Hide()
        buttonReload:Hide()
        PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
    else
        frameTalentDruid:Show()
        buttonReload:Show()
        PlaySoundFile(OPEN_TALENT_WINDOW_SOUND)
    end

    -- Inversez l'état de la fenêtre des talents
    talentsWindowOpen = not talentsWindowOpen
end

-- Définir le texte localisé en fonction de la langue
local pointsBeforeResetText

if GetLocale() == "frFR" then
    pointsBeforeResetText = "|cff00ffffVous avez utilisés %d points avant la réinitialisation des talents|r"
elseif GetLocale() == "enUS" then
    pointsBeforeResetText = "|cff00ffffYou have used %d points before talent reset|r"
else
    -- Valeur par défaut en anglais si la langue n'est ni frFR ni enUS
    pointsBeforeResetText = "|cff00ffffYou have used %d points before talent reset|r"
end

-- Fonction pour obtenir le texte localisé pour les info-bulles
local function GetLocalizedTooltipText()
    local locale = GetLocale()
    local localizedText = {
        frFR = "|cffffffffTalents|r |cffff7d0a(Druide)|r\n\nL'éventail des talents disponibles\npour améliorer et spécialiser\nvotre personnage.",
        enUS = "|cffffffffTalents|r |cffff7d0a(Druid)|r\n\nThe range of available talents\nfor enhancing and specializing\nyour character."
    }

    return localizedText[locale] or localizedText["enUS"]  -- Retourne le texte en fonction de la locale
end

-- Fonction pour obtenir le texte localisé pour les points avant réinitialisation
local function GetLocalizedPointsBeforeResetText()
    local locale = GetLocale()
    local localizedText = {
        frFR = "|cff00ffffVous avez utilisés %d points avant la réinitialisation des talents|r",
        enUS = "|cff00ffffYou have used %d points before talent reset|r"
    }

    return localizedText[locale] or localizedText["enUS"]  -- Retourne le texte en fonction de la locale
end

-- Vérifier si le joueur est un Druid avant de créer le bouton
local playerClass = select(2, UnitClass("player")) -- Obtenir la classe du joueur
if playerClass == "DRUID" then
    local buttonOuvrirTalents = CreateFrame("Button", "buttonOuvrirTalents", UIParent)
    buttonOuvrirTalents:SetSize(32, 33)
    buttonOuvrirTalents:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -173, 8) -- Placer en bas à droite avec un décalage de 10 pixels

    -- Ajouter une texture BLP au bouton
    buttonOuvrirTalents:SetNormalTexture("Interface\\TalentFrame\\Template\\MicroButton\\ButtonSystemTalent.blp")

    -- Ajouter une texture de surbrillance
    local highlightTexture = buttonOuvrirTalents:CreateTexture(nil, "HIGHLIGHT")
    highlightTexture:SetAllPoints(buttonOuvrirTalents)
    highlightTexture:SetTexture("Interface\\TalentFrame\\Template\\MicroButton\\ButtonSystemTalentLight.blp")
    buttonOuvrirTalents:SetHighlightTexture(highlightTexture)

    -- Supprimer le texte du bouton
    buttonOuvrirTalents:SetText("")

    -- Ajouter une info-bulle avec texte localisé
    buttonOuvrirTalents:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT") -- Définir l'ancre de l'info-bulle
        GameTooltip:SetText(GetLocalizedTooltipText()) -- Texte de l'info-bulle localisé
        GameTooltip:Show()
    end)

    -- Masquer l'info-bulle lorsque la souris quitte le bouton
    buttonOuvrirTalents:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Action au clic du bouton
    buttonOuvrirTalents:SetScript("OnClick", OuvrirFermerInterfaceTalents)
    TalentMicroButton:Hide()
end

-- Mise à jour du nombre de talents
DruidHandlers.UpdateTalentCount = function(player, talentsAppris)
    if fontTalentDruidFrameText then
        fontTalentDruidFrameText:SetText(talentsAppris .. " / " .. MAX_TALENTS)
    end
end

-- Mise à jour des points de talent utilisés avec texte localisé
DruidHandlers.UpdateTalentPointsUsed = function(player, pointsUsed, pointsBeforeReset)
    -- Utilisation du texte localisé pour les points avant réinitialisation
    print(string.format(GetLocalizedPointsBeforeResetText(), pointsBeforeReset))
end

-- Affichage des talents restants (items 338404 dans le sac)
DruidHandlers.UpdateTalentItemCount = function(player, count)
    if fontTalentPointsRemainingText then
        fontTalentPointsRemainingText:SetText("|cFFFF7D0ATalents restants : " .. count .. "|r")
    end
end

-------------------------------------------------------------
-- CORRECTION : mise à jour automatique quand le sac change
-- BAG_UPDATE se déclenche à chaque ajout/retrait d'item dans l'inventaire
-- On utilise GetItemCount() côté client directement, sans aller/retour serveur
-------------------------------------------------------------
local TALENT_ITEM_ID = 338404

local function UpdateTalentCountFromBag()
    local count = GetItemCount(TALENT_ITEM_ID, false, true)
    if fontTalentPointsRemainingText then
        fontTalentPointsRemainingText:SetText("|cFFFF7D0ATalents restants : " .. (count or 0) .. "|r")
    end
end

local bagWatcher = CreateFrame("Frame")
bagWatcher:RegisterEvent("BAG_UPDATE")
-- Petit délai via OnUpdate pour laisser le temps à l'inventaire de se finaliser
local bagUpdatePending = false
bagWatcher:SetScript("OnEvent", function(self, event)
    bagUpdatePending = true
end)
bagWatcher:SetScript("OnUpdate", function(self, elapsed)
    if bagUpdatePending then
        bagUpdatePending = false
        UpdateTalentCountFromBag()
    end
end)

-------------------------------------------------------------
-- Touche Échap : ferme l'interface des talents
-------------------------------------------------------------
if playerClass == "DRUID" then
    -- Surcharge OnHide pour synchroniser talentsWindowOpen quand Échap est pressé
    local _originalOnHide = frameTalentDruid:GetScript("OnHide")
    frameTalentDruid:SetScript("OnHide", function(self)
        talentsWindowOpen = false
        if _originalOnHide then _originalOnHide(self) end
    end)
    -- WoW appelle automatiquement Hide() sur les frames listées ici quand Échap est pressé
    tinsert(UISpecialFrames, "frameTalentDruid")
end