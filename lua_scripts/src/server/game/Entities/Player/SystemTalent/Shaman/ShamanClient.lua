local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local ShamanHandlers = AIO.AddHandlers("TalentShamanspell", {})

function ShamanHandlers.ShowTalentShaman(player)
    frameTalentShaman:Show()
    -- Redemande au serveur l’état visuel au cas où
    AIO.Handle("TalentShamanspell", "RequestLearnedTalents")
	-- Redemande le nombre de talents restants
    AIO.Handle("TalentShamanspell", "GetTalentItemCount")
end

local MAX_TALENTS = 60 -- Définition du nombre maximal de talents que le joueur peut apprendre

local OPEN_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_final_trait_unlocked.ogg"
local CLOSE_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_trait_refund_end.ogg"
local SPELL_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_80_azeritearmor_rotationends_02.ogg"

-- Attribute window
local frameTalentShaman = CreateFrame("Frame", "frameTalentShaman", UIParent)
frameTalentShaman:SetSize(1200, 650)
frameTalentShaman:SetMovable(true)
frameTalentShaman:EnableMouse(true)
frameTalentShaman:RegisterForDrag("LeftButton")
frameTalentShaman:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, -50) -- Adjust the X and Y coordinates
frameTalentShaman:SetBackdrop(
{
    -- bgFile = "interface/TalentFrame/talentsclassbackgroundShaman", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    bgFile = "interface/TalentFrame/Template/Class/Shaman/talentsclassbackgroundShaman", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedshaman", --Interface/DialogFrame/UI-DialogBox-Border
    edgeSize = 20,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})

-- Ajoutez la texture de l'icône du Démoniste
local shamanIcon = frameTalentShaman:CreateTexture("ShamanIcon", "OVERLAY")
shamanIcon:SetTexture("Interface\\TalentFrame\\Template\\Class\\Shaman\\IconeShaman.blp")
shamanIcon:SetSize(60, 60)
shamanIcon:SetPoint("TOPLEFT", frameTalentShaman, "TOPLEFT", -10, 10)

-- Template Talent Frame

-- Ajoute une textureone pour l'image BLP
local textureone = frameTalentShaman:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
textureone:SetTexture("Interface\\TalentFrame\\Template\\Class\\Shaman\\TalentFrameTemplate.blp")
textureone:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
textureone:SetPoint("TOPLEFT", frameTalentShaman, "TOPLEFT", -170, 140) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentShaman:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Ajoute une texturetwo pour l'image BLP
local texturetwo = frameTalentShaman:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
texturetwo:SetTexture("Interface\\TalentFrame\\Template\\Class\\Shaman\\TalentFrameTemplateOriginal.blp")
texturetwo:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
texturetwo:SetPoint("TOPRIGHT", frameTalentShaman, "TOPRIGHT", 170, 140) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentShaman:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Drag & Drop
frameTalentShaman:SetScript("OnDragStart", frameTalentShaman.StartMoving)
frameTalentShaman:SetScript("OnHide", frameTalentShaman.StopMovingOrSizing)
frameTalentShaman:SetScript("OnDragStop", frameTalentShaman.StopMovingOrSizing)
frameTalentShaman:Hide()

-- Nouveau template d'arête
frameTalentShaman:SetBackdropBorderColor(0, 112, 222) -- Couleur bleu

-- Close button
local buttonTalentShamanClose = CreateFrame("Button", "buttonTalentShamanClose", frameTalentShaman, "UIPanelCloseButton")
buttonTalentShamanClose:SetPoint("TOPRIGHT", -12, -12)
buttonTalentShamanClose:EnableMouse(true)
buttonTalentShamanClose:SetSize(32, 32)

local function CloseTalentWindow()
    frameTalentShaman:Hide()
    PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
end

-- Associez la fonction de fermeture au bouton de fermeture
buttonTalentShamanClose:SetScript("OnClick", CloseTalentWindow)

-- Title bar
local frameTalentShamanTitleBar = CreateFrame("Frame", "frameTalentShamanTitleBar", frameTalentShaman, nil)
frameTalentShamanTitleBar:SetSize(135, 25)
frameTalentShamanTitleBar:SetBackdrop(
{
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedshaman",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentShamanTitleBar:SetPoint("TOP", 0, 20)

local fontTalentShamanTitleText = frameTalentShamanTitleBar:CreateFontString("fontTalentShamanTitleText")
fontTalentShamanTitleText:SetFont("Fonts\\FRIZQT__.TTF", 13)
fontTalentShamanTitleText:SetSize(190, 5)
fontTalentShamanTitleText:SetPoint("CENTER", 0, 0)
fontTalentShamanTitleText:SetText("|cffFFC125Talents|r")

-- Détecte la langue du client
local locale = GetLocale() -- Retourne "enUS", "frFR", etc.

-- Table des traductions
local localizedTexts = {
    enUS = "|cffFFC125Shaman|r",
    frFR = "|cffFFC125Chaman|r",
}

-- Récupère le texte correspondant à la langue actuelle ou par défaut en anglais
local textToDisplay = localizedTexts[locale] or localizedTexts["enUS"]

local fontTalentShamanFrameText = frameTalentShamanTitleBar:CreateFontString("fontTalentShamanFrameText")
fontTalentShamanFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentShamanFrameText:SetSize(200, 5)
fontTalentShamanFrameText:SetPoint("TOPLEFT", frameTalentShamanTitleBar, "BOTTOMLEFT", -30, -35) -- Adjust the Y offset as needed
fontTalentShamanFrameText:SetText(textToDisplay)

-- Remplacez votre ligne existante pour la création du texte par celle-ci
local fontTalentShamanFrameText = frameTalentShamanTitleBar:CreateFontString("fontTalentShamanFrameText")
fontTalentShamanFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentShamanFrameText:SetSize(200, 5)
fontTalentShamanFrameText:SetPoint("TOPLEFT", frameTalentShamanTitleBar, "BOTTOMLEFT", -30, -60) -- Adjust the Y offset as needed
fontTalentShamanFrameText:SetText("0 / " .. MAX_TALENTS) -- Initialisez le texte avec 0 talents appris

-------------------------------------------------------------
-- Affichage "Talents restants" (item 338404 dans le sac)
-------------------------------------------------------------

local frameTalentPointsRemaining = CreateFrame("Frame", "frameTalentPointsRemaining", frameTalentShaman, nil)
frameTalentPointsRemaining:SetSize(220, 30)
frameTalentPointsRemaining:SetBackdrop({
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedshaman",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentPointsRemaining:SetPoint("BOTTOMRIGHT", frameTalentShaman, "BOTTOMRIGHT", -960, 10)

local fontTalentPointsRemainingText = frameTalentPointsRemaining:CreateFontString("fontTalentPointsRemainingText")
fontTalentPointsRemainingText:SetFont("Fonts\\FRIZQT__.TTF", 14)
fontTalentPointsRemainingText:SetSize(210, 20)
fontTalentPointsRemainingText:SetPoint("CENTER", 0, 0)
fontTalentPointsRemainingText:SetText("|cFF0070DETalents restants : 0|r")
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
ShamanHandlers.UpdateLearnedTalents = function(player, learnedSpells)
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

    local button = CreateFrame("Button", name, frameTalentShaman, nil)
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
                AIO.Handle("TalentShamanspell", talentHandler, 1)
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

-- Elémentaire

-- Table des sorts
local spells = {
{
    id = "spellConvection",
    name = "buttonSpellConvection",
    icon = "Interface/icons/spell_nature_wispsplode",
    position = {100, -80},
    handler = "spellconvection",
    tooltips = {
        frFR = "|cffffffffConvection|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit le coût en mana de vos Horions ainsi que de vos sorts Éclair, Chaîne d'éclairs, Explosion de lave et Cisaille de vent de 10%.|r",
        enUS = "|cffffffffConvection|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Reduces the mana cost of your Lightning Bolts, Chain Lightning, Lava Burst, and Wind Shear by 10%.|r"
    }
},

{
    id = "spellConcussion",
    name = "buttonSpellConcussion",
    icon = "Interface/icons/spell_fire_fireball",
    position = {205, -75},
    handler = "spellconcussion",
    tooltips = {
        frFR = "|cffffffffCommotion|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente les dégâts infligés par vos sorts Éclair, Chaîne d'éclairs, Orage et Explosion de lave ainsi que vos Horions de 5%.|r",
        enUS = "|cffffffffConcussion|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases the damage of your Lightning Bolt, Chain Lightning, Stormstrike, Lava Burst, and Lightning Strikes by 5%.|r"
    }
},

{
    id = "spellCallofFlame",
    name = "buttonSpellCallofFlame",
    icon = "Interface/icons/spell_fire_immolation",
    position = {315, -75},
    handler = "spellcallofflame",
    tooltips = {
        frFR = "|cffffffffAppel des flammes|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 15% les dégâts infligés par vos Totems de feu et votre Nova de feu, et de 6% les dégâts infligés par votre sort Explosion de lave.|r",
        enUS = "|cffffffffCall of Flame|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases the damage of your Fire Totems and Fire Nova by 15%, and Lava Burst damage by 6%.|r"
    }
},

{
    id = "spellElementalWarding",
    name = "buttonSpellElementalWarding",
    icon = "Interface/icons/spell_nature_spiritarmor",
    position = {418, -80},
    handler = "spellelementalwarding",
    tooltips = {
        frFR = "|cffffffffProtection contre les éléments|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit tous les dégâts subis de 6%.|r",
        enUS = "|cffffffffElemental Warding|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Reduces all damage taken by 6%.|r"
    }
},

{
    id = "spellElementalDevastation",
    name = "buttonSpellElementalDevastation",
    icon = "Interface/icons/spell_fire_elementaldevastation",
    position = {45, -130},
    handler = "spellelementaldevastation",
    tooltips = {
        frFR = "|cffffffffDévastation élémentaire|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Vos coups critiques non périodiques obtenus avec des sorts offensifs augmentent de 9% vos chances d'obtenir un coup critique avec les attaques de mêlée pendant 10 secondes.|r",
        enUS = "|cffffffffElemental Devastation|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Your non-periodic critical strikes from offensive spells increase your melee critical strike chance by 9% for 10 seconds.|r"
    }
},
{
    id = "spellReverberation",
    name = "buttonSpellReverberation",
    icon = "Interface/icons/spell_frost_frostward",
    position = {150, -130},
    handler = "spellreverberation",
    tooltips = {
        frFR = "|cffffffffRéverbération|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit le temps de recharge de vos Horions et de Cisaille de vent de 1 seconde.|r",
        enUS = "|cffffffffReverberation|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Reduces the cooldown of your Lightning Bolt and Wind Shear by 1 second.|r"
    }
},

{
    id = "spellElementalFocus",
    name = "buttonSpellElementalFocus",
    icon = "Interface/icons/spell_shadow_manaburn",
    position = {260, -130},
    handler = "spellelementalfocus",
    tooltips = {
        frFR = "|cffffffffFocalisation élémentaire|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Après avoir réussi un coup critique non périodique avec un sort de dégâts de Feu, de Givre ou de Nature, vous entrez dans un état d'Idées claires.\nIdées claires réduit le coût en mana de vos 2 prochains sorts de dégâts ou de soins de 40%.|r",
        enUS = "|cffffffffElemental Focus|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100After landing a non-periodic critical hit with a Fire, Frost, or Nature damage spell, you enter the Clearcasting state.\nClearcasting reduces the mana cost of your next 2 damage or healing spells by 40%.|r"
    }
},

{
    id = "spellElementalFury",
    name = "buttonSpellElementalFury",
    icon = "Interface/icons/spell_fire_volcano",
    position = {370, -130},
    handler = "spellelementalfury",
    tooltips = {
        frFR = "|cffffffffFureur élémentaire|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 100% le bonus aux dégâts des coups critiques obtenus avec vos Totems incendiaires et de magma ainsi qu'avec les sorts de Feu, de Givre et de Nature.|r",
        enUS = "|cffffffffElemental Fury|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases the critical strike damage bonus of your Fire, Frost, and Nature spells and Lava and Fire Totems by 100%.|r"
    }
},

{
    id = "spellImprovedFireNova",
    name = "buttonSpellImprovedFireNova",
    icon = "Interface/icons/spell_fire_sealoffire",
    position = {475, -133},
    handler = "spellimprovedfirenova",
    tooltips = {
        frFR = "|cffffffffNova de feu améliorée|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente les dégâts infligés par votre Nova de feu de 20% et réduit le temps de recharge de 4 sec.|r",
        enUS = "|cffffffffImproved Fire Nova|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases the damage of your Fire Nova by 20% and reduces its cooldown by 4 seconds.|r"
    }
},

{
    id = "spellEyeoftheStorm",
    name = "buttonSpellEyeoftheStorm",
    icon = "Interface/icons/spell_shadow_soulleech_2",
    position = {96, -185},
    handler = "spelleyeofthestorm",
    tooltips = {
        frFR = "|cffffffffOeil du cyclone|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit de 70% l'interruption causée par les attaques infligeant des dégâts pendant que vous incantez les sorts Éclair, Chaîne d'éclairs, Explosion de lave ou Maléfice.|r",
        enUS = "|cffffffffEye of the Storm|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Reduces interruption caused by damage-dealing attacks by 70% while casting Lightning Bolt, Chain Lightning, Lava Burst, or Hex.|r"
    }
},
{
    id = "spellElementalReach",
    name = "buttonSpellElementalReach",
    icon = "Interface/icons/spell_nature_stormreach",
    position = {205, -185},
    handler = "spellelementalreach",
    tooltips = {
        frFR = "|cffffffffAllonge élémentaire|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente la portée de vos sorts Éclair, Chaîne d'éclairs, Nova de feu et Explosion de lave de 6 mètres,\naugmente le rayon de votre sort Orage de 20% et augmente la portée de votre Horion de flammes de 15 mètres.|r",
        enUS = "|cffffffffElemental Reach|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases the range of your Lightning Bolt, Chain Lightning, Fire Nova, and Lava Burst by 6 yards,\nincreases the radius of your Storm spell by 20%, and increases the range of your Flame Shock by 15 yards.|r"
    }
},

{
    id = "spellCallofThunder",
    name = "buttonSpellCallofThunder",
    icon = "Interface/icons/spell_nature_callstorm",
    position = {315, -185},
    handler = "spellcallofthunder",
    tooltips = {
        frFR = "|cffffffffAppel de la foudre|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente vos chances de réaliser un coup critique avec vos sorts Éclair, Chaîne d'éclairs et Orage de 5% supplémentaires.|r",
        enUS = "|cffffffffCall of Thunder|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases your critical strike chance with Lightning Bolt, Chain Lightning, and Storm by an additional 5%.|r"
    }
},

{
    id = "spellUnrelentingStorm",
    name = "buttonSpellUnrelentingStorm",
    icon = "Interface/icons/spell_nature_unrelentingstorm",
    position = {422, -185},
    handler = "spellunrelentingstorm",
    tooltips = {
        frFR = "|cffffffffTempête continuelle|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Régénère une quantité de mana égale à 12% de votre Intelligence toutes les 5 sec., même pendant l'incantation.|r",
        enUS = "|cffffffffUnrelenting Storm|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Regenerates an amount of mana equal to 12% of your Intelligence every 5 seconds, even while casting.|r"
    }
},

{
    id = "spellElementalPrecision",
    name = "buttonSpellElementalPrecision",
    icon = "Interface/icons/spell_nature_elementalprecision_1",
    position = {527, -190},
    handler = "spellelementalprecision",
    tooltips = {
        frFR = "|cffffffffPrécision élémentaire|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 3% vos chances de toucher avec les sorts de Feu, de Givre et de Nature, et réduit de 30% la menace générée par les sorts de Feu, Givre et Nature.|r",
        enUS = "|cffffffffElemental Precision|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases your chance to hit with Fire, Frost, and Nature spells by 3%, and reduces the threat generated by Fire, Frost, and Nature spells by 30%.|r"
    }
},

{
    id = "spellLightningMastery",
    name = "buttonSpellLightningMastery",
    icon = "Interface/icons/spell_lightning_lightningbolt01",
    position = {43, -240},
    handler = "spelllightningmastery",
    tooltips = {
        frFR = "|cffffffffMaîtrise de la foudre|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit le temps d'incantation de vos sorts Éclair, Chaîne d'éclairs et Explosion de lave de 0.5 sec.|r",
        enUS = "|cffffffffLightning Mastery|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Reduces the cast time of your Lightning Bolt, Chain Lightning, and Lava Burst spells by 0.5 seconds.|r"
    }
},
{
    id = "spellElementalMastery",
    name = "buttonSpellElementalMastery",
    icon = "Interface/icons/spell_nature_wispheal",
    position = {150, -240},
    handler = "spellelementalmastery",
    tooltips = {
        frFR = "|cffffffffMaîtrise élémentaire|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Lorsqu'elle est activée, votre prochain sort Éclair, Chaîne d'éclairs ou Explosion de lave bénéficie d'une incantation instantanée.\nDe plus, vous bénéficiez d'un bonus à la hâte des sorts de 15% pendant 15 secondes.\nMaîtrise élémentaire partage le temps de recharge de Rapidité de la nature.|r",
        enUS = "|cffffffffElemental Mastery|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100When activated, your next Lightning Bolt, Chain Lightning, or Lava Burst has an instant cast.\nAdditionally, you gain a 15% haste buff to spells for 15 seconds.\nElemental Mastery shares a cooldown with Nature's Swiftness.|r"
    }
},

{
    id = "spellStormEarthandFire",
    name = "buttonSpellStormEarthandFire",
    icon = "Interface/icons/spell_shaman_stormearthfire",
    position = {368, -240},
    handler = "spellstormearthandfire",
    tooltips = {
        frFR = "|cffffffffTempête, terre et feu|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit le temps de recharge de votre sort Chaîne d'éclairs de 2,5 sec.,\nvotre Totem de lien terrestre a 100% de chances d'enraciner les cibles pendant 5 secondes\nà son lancement et les dégâts périodiques infligés par votre Horion de flammes sont augmentés de 60%.|r",
        enUS = "|cffffffffStorm, Earth and Fire|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Reduces the cooldown of your Chain Lightning by 2.5 seconds,\nyour Earthbind Totem has a 100% chance to root targets for 5 seconds\nwhen placed, and the periodic damage from your Flame Shock is increased by 60%.|r"
    }
},

{
    id = "spellBoomingEchoes",
    name = "buttonSpellBoomingEchoes",
    icon = "Interface/icons/spell_fire_blueflamering",
    position = {478, -240},
    handler = "spellboomingechoes",
    tooltips = {
        frFR = "|cffffffffÉchos tonitruants|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit le temps de recharge de vos sorts Horion de flammes et Horion de givre de 2 secondes.\nsupplémentaires, en plus d'augmenter les dégâts directs qu'ils infligent de 20% supplémentaires.|r",
        enUS = "|cffffffffBooming Echoes|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Reduces the cooldown of your Flame Shock and Frost Shock by 2 additional seconds,\nand increases the direct damage they deal by an additional 20%.|r"
    }
},

{
    id = "spellElementalOath",
    name = "buttonSpellElementalOath",
    icon = "Interface/icons/spell_shaman_elementaloath",
    position = {98, -293},
    handler = "spellelementaloath",
    tooltips = {
        frFR = "|cffffffffSerment des éléments|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Quand vous êtes sous l'effet d'Idées claires alors que Focalisation élémentaire est active, vous infligez 10% de dégâts supplémentaires avec les sorts.\nDe plus, les membres du groupe ou raid se trouvant à moins de 100 mètres bénéficient d'un bonus de 5% à leurs chances de coup critique avec les sorts.|r",
        enUS = "|cffffffffElemental Oath|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100When under the effect of Clearcasting while Elemental Focus is active, you deal 10% more damage with your spells.\nAdditionally, party or raid members within 100 yards receive a 5% bonus to their spell critical strike chance.|r"
    }
},

{
    id = "spellLightningOverload",
    name = "buttonSpellLightningOverload",
    icon = "Interface/icons/spell_nature_lightningoverload",
    position = {205, -293},
    handler = "spelllightningoverload",
    tooltips = {
        frFR = "|cffffffffSurcharge de foudre|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Donne à vos sorts Éclair et Chaîne d'éclairs 33% de chances de lancer un second sort semblable sur la même cible sans coût supplémentaire.\nCe sort inflige la moitié des dégâts et ne génère pas de menace.|r",
        enUS = "|cffffffffLightning Overload|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Gives your Lightning Bolt and Chain Lightning spells a 33% chance to cast a second similar spell on the same target at no additional cost.\nThis spell deals half the damage and does not generate threat.|r"
    }
},
{
    id = "spellAstralShift",
    name = "buttonSpellAstralShift",
    icon = "Interface/icons/spell_shaman_astralshift",
    position = {315, -293},
    handler = "spellastralshift",
    tooltips = {
        frFR = "|cffffffffTransfert astral|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Quand vous êtes étourdi, apeuré ou réduit au silence, vous entrez dans le Plan astral afin de réduire tous les dégâts subis de 30% pendant la durée de l'effet d'étourdissement, de peur ou de silence.|r",
        enUS = "|cffffffffAstral Shift|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100When stunned, feared, or silenced, you enter the Astral Plane, reducing all damage taken by 30% for the duration of the stun, fear, or silence effect.|r"
    }
},

{
    id = "spellTotemofWrath",
    name = "buttonSpellTotemofWrath",
    icon = "Interface/icons/spell_fire_totemofwrath",
    position = {422, -293},
    handler = "spelltotemofwrath",
    tooltips = {
        frFR = "|cffffffffTotem de courroux|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Invoque un Totem de courroux qui dispose de 5 points de vie aux pieds du lanceur de sorts.\nIl augmente de 100 la puissance des sorts de tous les membres du groupe et du raid, et augmente de 3%\nles chances de coup critique de toutes les attaques contre les ennemis se trouvant à moins de 40 mètres.\nDure 5 mn.|r",
        enUS = "|cffffffffTotem of Wrath|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Summons a Totem of Wrath with 5 health at the caster's feet.\nIt increases the spell power of all party and raid members by 100, and increases the critical strike chance of all attacks against enemies within 40 yards by 3%. Lasts 5 minutes.|r"
    }
},

{
    id = "spellLavaFlows",
    name = "buttonSpellLavaFlows",
    icon = "Interface/icons/spell_shaman_lavaflow",
    position = {527, -295},
    handler = "spelllavaflows",
    tooltips = {
        frFR = "|cffffffffFlots de lave|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente le bonus aux dégâts des coups critiques de votre sort Explosion de lave de 24% supplémentaires,\net lorsque votre Horion de flammes est dissipé,\nvotre vitesse d'incantation des sorts est augmentée de 30% pendant 6 secondes.|r",
        enUS = "|cffffffffLava Flows|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases the critical strike damage bonus of your Lava Burst by an additional 24%,\nand when your Flame Shock is dispelled, your casting speed is increased by 30% for 6 seconds.|r"
    }
},

{
    id = "spellShamanism",
    name = "buttonSpellShamanism",
    icon = "Interface/icons/spell_unused2",
    position = {43, -350},
    handler = "spellshamanism",
    tooltips = {
        frFR = "|cffffffffChamanisme|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Vos sorts Éclair et Chaîne d'éclairs bénéficient de 20% supplémentaires et votre Explosion de lave de 25% supplémentaires des effets de vos bonus aux dégâts.|r",
        enUS = "|cffffffffShamanism|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Your Lightning and Chain Lightning spells gain an additional 20% bonus, and your Lava Burst gains an additional 25% bonus to your damage bonuses.|r"
    }
},

{
    id = "spellThunderstorm",
    name = "buttonSpellThunderstorm",
    icon = "Interface/icons/spell_shaman_thunderstorm",
    position = {150, -350},
    handler = "spellthunderstorm",
    tooltips = {
        frFR = "|cffffffffOrage|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Vous appelez la foudre, qui vous charge d'énergie et inflige des dégâts aux ennemis se trouvant à moins de 10 mètres.\nVous rend 8% de mana et inflige 551 à 629 points de dégâts de Nature à tous les ennemis proches, les faisant tomber à la renverse 20 mètres plus loin.\nCe sort est utilisable quand vous êtes étourdi.|r",
        enUS = "|cffffffffThunderstorm|r\n|cffffffffTalent|r |cffca95ffElemental|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100You call down a thunderstorm, charging yourself with energy and dealing damage to enemies within 10 yards.\nRestores 8% of your mana and deals 551 to 629 Nature damage to all nearby enemies, knocking them back 20 yards.\nThis spell can be used while stunned.|r"
    }
},
{
    id = "spellEnhancingTotems",
    name = "buttonSpellEnhancingTotems",
    icon = "Interface/icons/spell_nature_earthbindtotem",
    position = {260, -350},
    handler = "spellenhancingtotems",
    tooltips = {
        frFR = "|cffffffffTotems renforcés|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 15% l'effet de vos Totems de Force de la Terre et Langue de feu.|r",
        enUS = "|cffffffffEnhancing Totems|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases the effect of your Earthbind Totem and Fire Tongue Totem by 15%.|r"
    }
},

{
    id = "spellEarthsGrasp",
    name = "buttonSpellEarthsGrasp",
    icon = "Interface/icons/spell_nature_stoneclawtotem",
    position = {368, -350},
    handler = "spellearthsgrasp",
    tooltips = {
        frFR = "|cffffffffEmprise de la terre|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente les points de vie de votre Totem de griffes de pierre de 50% et le rayon de votre Totem de lien terrestre de 20%, en plus de réduire le temps de recharge des deux totems de 30%.|r",
        enUS = "|cffffffffEarth's Grasp|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases the health of your Stoneclaw Totem by 50% and the radius of your Earthbind Totem by 20%, and reduces the cooldown of both totems by 30%.|r"
    }
},

{
    id = "spellAncestralKnowledge",
    name = "buttonSpellAncestralKnowledge",
    icon = "Interface/icons/spell_shadow_grimward",
    position = {478, -350},
    handler = "spellancestralknowledge",
    tooltips = {
        frFR = "|cffffffffConnaissance ancestrale|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente votre Intelligence de 10%.|r",
        enUS = "|cffffffffAncestral Knowledge|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases your Intelligence by 10%.|r"
    }
},


-- CreateSpellButton("buttonSpellConvection", "Interface/icons/spell_nature_wispsplode", "|cffffffffConvection|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit le coût en mana de vos Horions ainsi que de vos sorts Eclair, Chaîne d'éclairs, Explosion de lave et Cisaille de vent de 10%.|r", "spellconvection", 100, -80)
-- CreateSpellButton("buttonSpellConcussion", "Interface/icons/spell_fire_fireball", "|cffffffffCommotion|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente les dégâts infligés par vos sorts Eclair, Chaîne d'éclairs, Orage et Explosion de lave ainsi que vos Horions de 5%.|r", "spellconcussion", 205, -75)
-- CreateSpellButton("buttonSpellCallofFlame", "Interface/icons/spell_fire_immolation", "|cffffffffAppel des flammes|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 15% les dégâts infligés par vos Totems de feu et votre Nova de feu, et de 6% les dégâts infligés par votre sort Explosion de lave.|r", "spellcallofflame", 315, -75)
-- CreateSpellButton("buttonSpellElementalWarding", "Interface/icons/spell_nature_spiritarmor", "|cffffffffProtection contre les éléments|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit tous les dégâts subis de 6%.|r", "spellelementalwarding", 418, -80)
-- CreateSpellButton("buttonSpellElementalDevastation", "Interface/icons/spell_fire_elementaldevastation", "|cffffffffDévastation élémentaire|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Vos coups critiques non périodiques obtenus avec des sorts offensifs augmentent de 9% vos chances d'obtenir un coup critique avec les attaques de mêlée pendant 10 secondes.|r", "spellelementaldevastation", 45, -130)
-- CreateSpellButton("buttonSpellReverberation", "Interface/icons/spell_frost_frostward", "|cffffffffRéverbération|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit le temps de recharge de vos Horions et de Cisaille de vent de 1 seconde.|r", "spellreverberation", 150, -130)
-- CreateSpellButton("buttonSpellElementalFocus", "Interface/icons/spell_shadow_manaburn", "|cffffffffFocalisation élémentaire|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Après avoir réussi un coup critique non périodique avec un sort de dégâts de Feu, de Givre ou de Nature, vous entrez dans un état d'Idées claires.\nIdées claires réduit le coût en mana de vos 2 prochains sorts de dégâts ou de soins de 40%.|r", "spellelementalfocus", 260, -130)
-- CreateSpellButton("buttonSpellElementalFury", "Interface/icons/spell_fire_volcano", "|cffffffffFureur élémentaire|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 100% le bonus aux dégâts des coups critiques obtenus avec vos Totems incendiaires et de magma ainsi qu'avec les sorts de Feu, de Givre et de Nature.|r", "spellelementalfury", 370, -130)
-- CreateSpellButton("buttonSpellImprovedFireNova", "Interface/icons/spell_fire_sealoffire", "|cffffffffNova de feu améliorée|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente les dégâts infligés par votre Nova de feu de 20% et réduit le temps de recharge de 4 sec.|r", "spellimprovedfirenova", 475, -133)
-- CreateSpellButton("buttonSpellEyeoftheStorm", "Interface/icons/spell_shadow_soulleech_2", "|cffffffffOeil du cyclone|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit de 70% l'interruption causée par les attaques infligeant des dégâts pendant que vous incantez les sorts Eclair, Chaîne d'éclairs, Explosion de lave ou Maléfice.|r", "spelleyeofthestorm", 96, -185)
-- CreateSpellButton("buttonSpellElementalReach", "Interface/icons/spell_nature_stormreach", "|cffffffffAllonge élémentaire|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente la portée de vos sorts Eclair, Chaîne d'éclairs, Nova de feu et Explosion de lave de 6 mètres,\naugmente le rayon de votre sort Orage de 20% et augmente la portée de votre Horion de flammes de 15 mètres.|r", "spellelementalreach", 205, -185)
-- CreateSpellButton("buttonSpellCallofThunder", "Interface/icons/spell_nature_callstorm", "|cffffffffAppel de la foudre|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente vos chances de réaliser un coup critique avec vos sorts Eclair, Chaîne d'éclairs et Orage de 5% supplémentaires.|r", "spellcallofthunder", 315, -185)
-- CreateSpellButton("buttonSpellUnrelentingStorm", "Interface/icons/spell_nature_unrelentingstorm", "|cffffffffTempête continuelle|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Régénère une quantité de mana égale à 12% de votre Intelligence toutes les 5 sec., même pendant l'incantation.|r", "spellunrelentingstorm", 422, -185)
-- CreateSpellButton("buttonSpellElementalPrecision", "Interface/icons/spell_nature_elementalprecision_1", "|cffffffffPrécision élémentaire|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 3% vos chances de toucher avec les sorts de Feu, de Givre et de Nature, et réduit de 30% la menace générée par les sorts de Feu, Givre et Nature.|r", "spellelementalprecision", 527, -190)
-- CreateSpellButton("buttonSpellLightningMastery", "Interface/icons/spell_lightning_lightningbolt01", "|cffffffffMaîtrise de la foudre|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit le temps d'incantation de vos sorts Eclair, Chaîne d'éclairs et Explosion de lave de 0.5 sec.", "spelllightningmastery", 43, -240)
-- CreateSpellButton("buttonSpellElementalMastery", "Interface/icons/spell_nature_wispheal", "|cffffffffMaîtrise élémentaire|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Lorsqu'elle est activée, votre prochain sort Eclair, Chaîne d'éclairs ou Explosion de lave bénéficie d'une incantation instantanée.\nDe plus, vous bénéficiez d'un bonus à la hâte des sorts de 15% pendant 15 secondes.\nMaîtrise élémentaire partage le temps de recharge de Rapidité de la nature.|r", "spellelementalmastery", 150, -240)
-- CreateSpellButton("buttonSpellStormEarthandFire", "Interface/icons/spell_shaman_stormearthfire", "|cffffffffTempête, terre et feu|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit le temps de recharge de votre sort Chaîne d'éclairs de 2,5 sec.,\nvotre Totem de lien terrestre a 100% de chances d'enraciner les cibles pendant 5 seconds\nà son lancement et les dégâts périodiques infligés par votre Horion de flammes sont augmentés de 60%.|r", "spellstormearthandfire", 368, -240)
-- CreateSpellButton("buttonSpellBoomingEchoes", "Interface/icons/spell_fire_blueflamering", "|cffffffffEchos tonitruants|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit le temps de recharge de vos sorts Horion de flammes et Horion de givre de 2 secondes.\nsupplémentaires, en plus d'augmenter les dégâts directs qu'ils infligent de 20% supplémentaires.|r", "spellboomingechoes", 478, -240)
-- CreateSpellButton("buttonSpellElementalOath", "Interface/icons/spell_shaman_elementaloath", "|cffffffffSerment des éléments|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Quand vous êtes sous l'effet d'Idées claires alors que Focalisation élémentaire est active, vous infligez 10% de dégâts supplémentaires avec les sorts.\nDe plus, les membres du groupe ou raid se trouvant à moins de 100 mètres bénéficient d'un bonus de 5% à leurs chances de coup critique avec les sorts.|r", "spellelementaloath", 98, -293)
-- CreateSpellButton("buttonSpellLightningOverload", "Interface/icons/spell_nature_lightningoverload", "|cffffffffSurcharge de foudre|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Donne à vos sorts Eclair et Chaîne d'éclairs 33% de chances de lancer un second sort semblable sur la même cible sans coût supplémentaire.\nCe sort inflige la moitié des dégâts et ne génère pas de menace.|r", "spelllightningoverload", 205, -293)
-- CreateSpellButton("buttonSpellAstralShift", "Interface/icons/spell_shaman_astralshift", "|cffffffffTransfert astral|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Quand vous êtes étourdi, apeuré ou réduit au silence, vous entrez dans le Plan astral afin de réduire tous les dégâts subis de 30% pendant la durée de l'effet d'étourdissement, de peur ou de silence.|r", "spellastralshift", 315, -293)
-- CreateSpellButton("buttonSpellTotemofWrath", "Interface/icons/spell_fire_totemofwrath", "|cffffffffTotem de courroux|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100nvoque un Totem de courroux qui dispose de 5 points de vie aux pieds du lanceur de sorts.\nIl augmente de 100 la puissance des sorts de tous les membres du groupe et du raid, et augmente de 3%\nles chances de coup critique de toutes les attaques contre les ennemis se trouvant à moins de 40 mètres.\nDure 5 mn.|r", "spelltotemofwrath", 422, -293)
-- CreateSpellButton("buttonSpellLavaFlows", "Interface/icons/spell_shaman_lavaflow", "|cffffffffFlots de lave|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente le bonus aux dégâts des coups critiques de votre sort Explosion de lave de 24% supplémentaires,\net lorsque votre Horion de flammes est dissipé,\nvotre vitesse d'incantation des sorts est augmentée de 30% pendant 6 secondes.|r", "spelllavaflows", 527, -295)
-- CreateSpellButton("buttonSpellShamanism", "Interface/icons/spell_unused2", "|cffffffffChamanisme|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Vos sorts Éclair et Chaîne d'éclairs bénéficient de 20% supplémentaires et votre Explosion de lave de 25% supplémentaires des effets de vos bonus aux dégâts.|r", "spellshamanism", 43, -350)
-- CreateSpellButton("buttonSpellThunderstorm", "Interface/icons/spell_shaman_thunderstorm", "|cffffffffOrage|r\n|cffffffffTalent|r |cffca95ffElémentaire|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Vous appelez la foudre, qui vous charge d'énergie et inflige des dégâts aux ennemis se trouvant à moins de 10 mètres.\nVous rend 8% de mana et inflige 551 à 629 points de dégâts de Nature à tous les ennemis proches, les faisant tomber à la renverse 20 mètres plus loin.\nCe sort est utilisable quand vous êtes étourdi.|r", "spellthunderstorm", 150, -350)
-- CreateSpellButton("buttonSpellEnhancingTotems", "Interface/icons/spell_nature_earthbindtotem", "|cffffffffTotems renforcés|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 15% l'effet de vos Totems de Force de la Terre et Langue de feu.|r", "spellenhancingtotems", 260, -350)
-- CreateSpellButton("buttonSpellEarthsGrasp", "Interface/icons/spell_nature_stoneclawtotem", "|cffffffffEmprise de la terre|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente les points de vie de votre Totem de griffes de pierre de 50% et le rayon de votre Totem de lien terrestre de 20%, en plus de réduire le temps de recharge des deux totems de 30%.|r", "spellearthsgrasp", 368, -350)
-- CreateSpellButton("buttonSpellAncestralKnowledge", "Interface/icons/spell_shadow_grimward", "|cffffffffConnaissance ancestrale|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente votre Intelligence de 10%.|r", "spellancestralknowledge", 478, -350)

-- Amélioration

{
    id = "spellGuardianTotems",
    name = "buttonSpellGuardianTotems",
    icon = "Interface/icons/spell_nature_stoneskintotem",
    position = {98, -405},
    handler = "spellguardiantotems",
    tooltips = {
        frFR = "|cffffffffTotems gardiens|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 20% le montant de points d'armure augmentés par votre Totem Peau de pierre et réduit le temps de recharge de votre Totem de glèbe de 2 sec.|r",
        enUS = "|cffffffffGuardian Totems|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases the amount of armor provided by your Stoneclaw Totem by 20% and reduces the cooldown of your Earthbind Totem by 2 seconds.|r"
    }
},

{
    id = "spellThunderingStrikes",
    name = "buttonSpellThunderingStrikes",
    icon = "Interface/icons/ability_thunderbolt",
    position = {205, -405},
    handler = "spellthunderingstrikes",
    tooltips = {
        frFR = "|cffffffffFrappe foudroyante|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 5% vos chances d'infliger un coup critique avec tous les sorts et attaques.|r",
        enUS = "|cffffffffThundering Strikes|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases your chances to deal a critical strike with all spells and attacks by 5%.|r"
    }
},

{
    id = "spellImprovedGhostWolf",
    name = "buttonSpellImprovedGhostWolf",
    icon = "Interface/icons/spell_nature_spiritwolf",
    position = {315, -405},
    handler = "spellimprovedghostwolf",
    tooltips = {
        frFR = "|cffffffffLoup fantôme amélioré|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit le temps d'incantation de votre sort Loup fantôme de 2 secondes.|r",
        enUS = "|cffffffffImproved Ghost Wolf|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Reduces the cast time of your Ghost Wolf spell by 2 seconds.|r"
    }
},

{
    id = "spellImprovedShields",
    name = "buttonSpellImprovedShields",
    icon = "Interface/icons/spell_nature_lightningshield",
    position = {422, -405},
    handler = "spellimprovedshields",
    tooltips = {
        frFR = "|cffffffffBoucliers améliorés|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 15% les dégâts infligés par les orbes de votre Bouclier de foudre,\nde 15% la quantité de mana obtenue grâce aux orbes de votre Bouclier d'eau et de 15% la quantité de soins obtenus avec vos orbes de Bouclier de terre.|r",
        enUS = "|cffffffffImproved Shields|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases the damage of your Lightning Shield orbs by 15%, the mana gained from your Water Shield orbs by 15%, and the healing received from your Earth Shield orbs by 15%.|r"
    }
},

{
    id = "spellElementalWeapons",
    name = "buttonSpellElementalWeapons",
    icon = "Interface/icons/spell_fire_flametounge",
    position = {43, -458},
    handler = "spellelementalweapons",
    tooltips = {
        frFR = "|cffffffffArmes élémentaires|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 40% les dégâts infligés par l'effet de votre Arme Furie-des-vents, de 30% les dégâts des sorts de votre Arme Langue de feu et de 30% le bonus aux soins de votre Arme Viveterre.|r",
        enUS = "|cffffffffElemental Weapons|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases the damage of your Windfury Weapon effect by 40%, the spell damage of your Fire Tongue Weapon by 30%, and the healing bonus of your Earthliving Weapon by 30%.|r"
    }
},
{
    id = "spellShamanisticFocus",
    name = "buttonSpellShamanisticFocus",
    icon = "Interface/icons/spell_nature_elementalabsorption",
    position = {150, -458},
    handler = "spellshamanisticfocus",
    tooltips = {
        frFR = "|cffffffffFocalisation chamanique|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit le coût en mana de vos Horions de 45%.|r",
        enUS = "|cffffffffShamanistic Focus|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Reduces the mana cost of your Lightning Bolt by 45%.|r"
    }
},

{
    id = "spellAnticipation",
    name = "buttonSpellAnticipation",
    icon = "Interface/icons/spell_nature_mirrorimage",
    position = {260, -458},
    handler = "spellanticipation",
    tooltips = {
        frFR = "|cffffffffAnticipation|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 3% vos chances d'esquiver et réduit de 50% la durée de tous les effets de désarmement utilisés contre vous.\nNon cumulable avec les autres effets qui réduisent la durée du désarmement.|r",
        enUS = "|cffffffffAnticipation|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases your chance to dodge by 3% and reduces the duration of all disarm effects against you by 50%.|r"
    }
},

{
    id = "spellFlurry",
    name = "buttonSpellFlurry",
    icon = "Interface/icons/ability_ghoulfrenzy",
    position = {368, -458},
    handler = "spellflurry",
    tooltips = {
        frFR = "|cffffffffRafale|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Lorsque vous infligez un coup critique, augmente votre vitesse d'attaque de 30% pour les 3 prochaines attaques.|r",
        enUS = "|cffffffffFlurry|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100When you land a critical strike, increases your attack speed by 30% for the next 3 attacks.|r"
    }
},

{
    id = "spellToughness",
    name = "buttonSpellToughness",
    icon = "Interface/icons/spell_holy_devotion",
    position = {478, -458},
    handler = "spelltoughness",
    tooltips = {
        frFR = "|cffffffffRésistance|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente votre Endurance de 10% et réduit sur vous la durée des effets ralentissant le mouvement de 30%.|r",
        enUS = "|cffffffffToughness|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases your Stamina by 10% and reduces the duration of movement slowing effects on you by 30%.|r"
    }
},

{
    id = "spellImprovedWindfuryTotem",
    name = "buttonSpellImprovedWindfuryTotem",
    icon = "Interface/icons/spell_nature_windfury",
    position = {98, -510},
    handler = "spellimprovedwindfurytotem",
    tooltips = {
        frFR = "|cffffffffTotems Furie-des-vents améliorés|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente la hâte en mêlée de votre totem Furie-des-vents de 4%.|r",
        enUS = "|cffffffffImproved Windfury Totem|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases the melee haste of your Windfury Totem by 4%.|r"
    }
},
{
    id = "spellSpiritWeapons",
    name = "buttonSpellSpiritWeapons",
    icon = "Interface/icons/ability_parry",
    position = {205, -510},
    handler = "spellspiritweapons",
    tooltips = {
        frFR = "|cffffffffArmes spirituelles|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Donne une chance de parer les attaques de mêlée des ennemis et réduit toute la menace générée de 30%.|r",
        enUS = "|cffffffffSpirit Weapons|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Gives you a chance to parry melee attacks from enemies and reduces all generated threat by 30%.|r"
    }
},

{
    id = "spellMentalDexterity",
    name = "buttonSpellMentalDexterity",
    icon = "Interface/icons/spell_nature_bloodlust",
    position = {315, -510},
    handler = "spellmentaldexterity",
    tooltips = {
        frFR = "|cffffffffDextérité mentale|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente votre puissance d'attaque de 100% de votre Intelligence.|r",
        enUS = "|cffffffffMental Dexterity|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases your attack power by 100% of your Intelligence.|r"
    }
},

{
    id = "spellUnleashedRage",
    name = "buttonSpellUnleashedRage",
    icon = "Interface/icons/spell_nature_unleashedrage",
    position = {422, -510},
    handler = "spellunleashedrage",
    tooltips = {
        frFR = "|cffffffffRage libérée|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente votre expertise de 9, et augmente de 10% la puissance d'attaque de tous les membres du groupe ou du raid s'ils se trouvent à moins de 100 mètres du chaman.|r",
        enUS = "|cffffffffUnleashed Rage|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases your expertise by 9, and increases the attack power of all party or raid members within 100 yards of you by 10%.|r"
    }
},


-- CreateSpellButton("buttonSpellGuardianTotems", "Interface/icons/spell_nature_stoneskintotem", "|cffffffffTotems gardiens|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 20% le montant de points d'armure augmentés par votre Totem Peau de pierre et réduit le temps de recharge de votre Totem de glèbe de 2 sec.|r", "spellguardiantotems", 98, -405)
-- CreateSpellButton("buttonSpellThunderingStrikes", "Interface/icons/ability_thunderbolt", "|cffffffffFrappe foudroyante|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 5% vos chances d'infliger un coup critique avec tous les sorts et attaques.|r", "spellthunderingstrikes", 205, -405)
-- CreateSpellButton("buttonSpellImprovedGhostWolf", "Interface/icons/spell_nature_spiritwolf", "|cffffffffLoup fantôme amélioré|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit le temps d'incantation de votre sort Loup fantôme de 2 secondes.|r", "spellimprovedghostwolf", 315, -405)
-- CreateSpellButton("buttonSpellImprovedShields", "Interface/icons/spell_nature_lightningshield", "|cffffffffBoucliers améliorés|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 15% les dégâts infligés par les orbes de votre Bouclier de foudre,\nde 15% la quantité de mana obtenue grâce aux orbes de votre Bouclier d'eau et de 15% la quantité de soins obtenus avec vos orbes de Bouclier de terre.|r", "spellimprovedshields", 422, -405)
-- CreateSpellButton("buttonSpellElementalWeapons", "Interface/icons/spell_fire_flametounge", "|cffffffffArmes élémentaires|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 40% les dégâts infligés par l'effet de votre Arme Furie-des-vents, de 30% les dégâts des sorts de votre Arme Langue de feu et de 30% le bonus aux soins de votre Arme Viveterre.|r", "spellelementalweapons", 43, -458)
-- CreateSpellButton("buttonSpellShamanisticFocus", "Interface/icons/spell_nature_elementalabsorption", "|cffffffffFocalisation chamanique|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit le coût en mana de vos Horions de 45%.|r", "spellshamanisticfocus", 150, -458)
-- CreateSpellButton("buttonSpellAnticipation", "Interface/icons/spell_nature_mirrorimage", "|cffffffffAnticipation|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 3% vos chances d'esquiver et réduit de 50% la durée de tous les effets de désarmement utilisés contre vous.\nNon cumulable avec les autres effets qui réduisent la durée du désarmement.|r", "spellanticipation", 260, -458)
-- CreateSpellButton("buttonSpellFlurry", "Interface/icons/ability_ghoulfrenzy", "|cffffffffRafale|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Lorsque vous infligez un coup critique, augmente votre vitesse d'attaque de 30% pour les 3 prochaines attaques.|r", "spellflurry", 368, -458)
-- CreateSpellButton("buttonSpellToughness", "Interface/icons/spell_holy_devotion", "|cffffffffRésistance|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente votre Endurance de 10% et réduit sur vous la durée des effets ralentissant le mouvement de 30%.|r", "spelltoughness", 478, -458)
-- CreateSpellButton("buttonSpellImprovedWindfuryTotem", "Interface/icons/spell_nature_windfury", "|cffffffffTotems Furie-des-vents améliorés|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente la hâte en mêlée de votre totem Furie-des-vents de 4%.|r", "spellimprovedwindfurytotem", 98, -510)
-- CreateSpellButton("buttonSpellSpiritWeapons", "Interface/icons/ability_parry", "|cffffffffArmes spirituelles|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Donne une chance de parer les attaques de mêlée des ennemis et réduit toute la menace générée de 30%.|r", "spellspiritweapons", 205, -510)
-- CreateSpellButton("buttonSpellMentalDexterity", "Interface/icons/spell_nature_bloodlust", "|cffffffffDextérité mentale|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente votre puissance d'attaque de 100% de votre Intelligence.|r", "spellmentaldexterity", 315, -510)
-- CreateSpellButton("buttonSpellUnleashedRage", "Interface/icons/spell_nature_unleashedrage", "|cffffffffRage libérée|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente votre expertise de 9, et augmente de 10% la puissance d'attaque de tous les membres du groupe ou du raid s'ils se trouvent à moins de 100 mètres du chaman.|r", "spellunleashedrage", 422, -510)

-- Template 2

{
    id = "spellWeaponMastery",
    name = "buttonSpellWeaponMastery",
    icon = "Interface/icons/ability_hunter_swiftstrike",
    position = {663, -75},
    handler = "spellweaponmastery",
    tooltips = {
        frFR = "|cffffffffMaîtrise des armes|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 10% les dégâts que vous infligez avec toutes les armes.|r",
        enUS = "|cffffffffWeapon Mastery|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases your damage with all weapons by 10%.|r"
    }
},

{
    id = "spellFrozenPower",
    name = "buttonSpellFrozenPower",
    icon = "Interface/icons/spell_fire_bluecano",
    position = {770, -75},
    handler = "spellfrozenpower",
    tooltips = {
        frFR = "|cffffffffPuissance gelée|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 10% les dégâts infligés par vos sorts Éclair, Chaîne d'éclairs, Fouet de lave et Horion sur les cibles affectées par l'effet de votre Attaque Arme de givre,\net votre Horion de givre a 100% de chances d'immobiliser la cible dans la glace pendant 5 secondes lorsqu'il est utilisé sur des cibles se trouvant à 15 mètres ou plus de vous.|r",
        enUS = "|cffffffffFrozen Power|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases the damage of your Lightning, Chain Lightning, Lava Lash, and Frost Shock by 10% against targets affected by your Frost Weapon Attack.\nAdditionally, your Frost Shock has a 100% chance to freeze the target in place for 5 seconds if used on targets 15 yards or more away.|r"
    }
},

{
    id = "spellDualWieldSpecialization",
    name = "buttonSpellDualWieldSpecialization",
    icon = "Interface/icons/ability_dualwieldspecialization",
    position = {880, -75},
    handler = "spelldualwieldspecialization",
    tooltips = {
        frFR = "|cffffffffSpécialisation Ambidextrie|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 6% supplémentaires vos chances de toucher lorsque vous portez deux armes.|r",
        enUS = "|cffffffffDual Wield Specialization|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases your chance to hit by an additional 6% when dual-wielding.|r"
    }
},

{
    id = "spellDualWield",
    name = "buttonSpellDualWield",
    icon = "Interface/icons/ability_dualwield",
    position = {990, -75},
    handler = "spelldualwield",
    tooltips = {
        frFR = "|cffffffffAmbidextrie|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Permet d'équiper les armes à une main dans la main gauche.|r",
        enUS = "|cffffffffDual Wield|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Allows you to equip one-handed weapons in your off-hand.|r"
    }
},

{
    id = "spellStormstrike",
    name = "buttonSpellStormstrike",
    icon = "Interface/icons/ability_shaman_stormstrike",
    position = {1100, -75},
    handler = "spellstormstrike",
    tooltips = {
        frFR = "|cffffffffFrappe-tempête|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Attaque instantanément avec les deux armes.\nDe plus, les 4 prochaines sources de dégâts de Nature infligés à la cible par le chaman sont augmentées de 20%. Dure 12 secondes.|r",
        enUS = "|cffffffffStormstrike|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Instantly strike with both weapons. Additionally, the next 4 sources of Nature damage dealt to the target by the shaman are increased by 20%. Lasts 12 seconds.|r"
    }
},
{
    id = "spellStaticShock",
    name = "buttonSpellStaticShock",
    icon = "Interface/icons/spell_shaman_staticshock",
    position = {718, -130},
    handler = "spellstaticshock",
    tooltips = {
        frFR = "|cffffffffHorion statique|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Vous avez 6% de chances de toucher votre cible avec une charge d'orbe de Bouclier de foudre quand vous infligez des dégâts avec des attaques et techniques de mêlée, et votre Bouclier de foudre gagne 6 charges supplémentaires.|r",
        enUS = "|cffffffffStatic Shock|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100You have a 6% chance to hit your target with a charge of Lightning Shield orbs when dealing damage with melee attacks and abilities, and your Lightning Shield gains 6 additional charges.|r"
    }
},

{
    id = "spellLavaLash",
    name = "buttonSpellLavaLash",
    icon = "Interface/icons/ability_shaman_lavalash",
    position = {825, -130},
    handler = "spelllavalash",
    tooltips = {
        frFR = "|cffffffffFouet de lave|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Vous chargez votre arme en main gauche de lave, infligeant instantanément 100% des dégâts de l'arme en main gauche. Les dégâts sont augmentés de 25% si votre arme en main gauche est enchantée avec Langue de feu.|r",
        enUS = "|cffffffffLava Lash|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100You charge your off-hand weapon with lava, instantly dealing 100% of the off-hand weapon's damage. Damage is increased by 25% if your off-hand weapon is enchanted with Flame Tongue.|r"
    }
},

{
    id = "spellImprovedStormstrike",
    name = "buttonSpellImprovedStormstrike",
    icon = "Interface/icons/spell_shaman_improvedstormstrike",
    position = {935, -130},
    handler = "spellimprovedstormstrike",
    tooltips = {
        frFR = "|cffffffffFrappe-tempête amélioré|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Quand vous utilisez Frappe-tempête, vous avez 100% de chances de recevoir immédiatement 20% de votre mana de base.|r",
        enUS = "|cffffffffImproved Stormstrike|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100When you use Stormstrike, you have a 100% chance to immediately gain 20% of your base mana.|r"
    }
},

{
    id = "spellMentalQuickness",
    name = "buttonSpellMentalQuickness",
    icon = "Interface/icons/spell_nature_mentalquickness",
    position = {1045, -130},
    handler = "spellmentalquickness",
    tooltips = {
        frFR = "|cffffffffRapidité mentale|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit le coût en mana de vos sorts instantanés de chaman de 6% et augmente la puissance de vos sorts d'un montant égal à 30% de votre puissance d'attaque.|r",
        enUS = "|cffffffffMental Quickness|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Reduces the mana cost of your instant-cast Shaman spells by 6% and increases the power of your spells by an amount equal to 30% of your attack power.|r"
    }
},

{
    id = "spellShamanisticRage",
    name = "buttonSpellShamanisticRage",
    icon = "Interface/icons/spell_nature_shamanrage",
    position = {663, -184},
    handler = "spellshamanisticrage",
    tooltips = {
        frFR = "|cffffffffRage du chaman|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit tous les dégâts subis de 30% et donne à vos attaques en mêlée réussies une chance de régénérer un montant de mana égal à 15% de votre puissance d'attaque.\nCe sort peut être utilisé alors que vous êtes étourdi.\nDure 15 secondes.|r",
        enUS = "|cffffffffShamanistic Rage|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Reduces all damage taken by 30% and gives your successful melee attacks a chance to regenerate mana equal to 15% of your attack power.\nThis ability can be used while stunned.\nLasts 15 seconds.|r"
    }
},
{
    id = "spellEarthenPower",
    name = "buttonSpellEarthenPower",
    icon = "Interface/icons/spell_nature_earthelemental_totem",
    position = {770, -184},
    handler = "spellearthenpower",
    tooltips = {
        frFR = "|cffffffffPuissance terrestre|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Votre Totem de lien terrestre a 100% de chances à chacune de ses pulsations d'enlever tous les effets de ralentissement sur vous ainsi que sur les cibles alliées proches,\net votre Horion de terre réduit la vitesse d'attaque des ennemis de 10% supplémentaires.|r",
        enUS = "|cffffffffEarthen Power|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Your Earthbind Totem has a 100% chance with each pulse to remove all movement-impairing effects from you and nearby friendly targets, and your Earth Shock reduces the attack speed of enemies by an additional 10%.|r"
    }
},

{
    id = "spellMaelstromWeapon",
    name = "buttonSpellMaelstromWeapon",
    icon = "Interface/icons/spell_shaman_maelstromweapon",
    position = {880, -184},
    handler = "spellmaelstromweapon",
    tooltips = {
        frFR = "|cffffffffArme du Maelström|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Quand vous infligez des dégâts avec une arme de mêlée, vous avez une chance (plus élevée qu'au rang 4) de réduire le temps d'incantation de votre prochain sort\nEclair, Chaîne d'éclairs, Vague de soins inférieurs, Salve de guérison, Vague de soins ou Maléfice de 20%.\nCumulable jusqu'à 5 fois.\nDure 30 secondes.|r",
        enUS = "|cffffffffMaelstrom Weapon|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100When you deal damage with a melee weapon, you have a chance (higher than rank 4) to reduce the cast time of your next Lightning Bolt, Chain Lightning, Lesser Healing Wave, Healing Surge, Healing Wave, or Hex by 20%. Max 5 stacks.\nLasts 30 seconds.|r"
    }
},

{
    id = "spellFeralSpirit",
    name = "buttonSpellFeralSpirit",
    icon = "Interface/icons/spell_shaman_feralspirit",
    position = {990, -184},
    handler = "spellferalspirit",
    tooltips = {
        frFR = "|cffffffffEsprit farouche|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Invoque deux Esprits du loup qui obéissent au chaman.\nDure 45 secondes.|r",
        enUS = "|cffffffffFeral Spirit|r\n|cffffffffTalent|r |cffff8c1aEnhancement|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Summons two Spirit Wolves that follow the Shaman's commands.\nLasts 45 seconds.|r"
    }
},

{
    id = "spellImprovedHealingWave",
    name = "buttonSpellImprovedHealingWave",
    icon = "Interface/icons/spell_nature_magicimmunity",
    position = {1100, -184},
    handler = "spellimprovedhealingwave",
    tooltips = {
        frFR = "|cffffffffVague de soins améliorée|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit le temps d'incantation de votre sort Vague de soins de 0,5 secondes.|r",
        enUS = "|cffffffffImproved Healing Wave|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Reduces the cast time of your Healing Wave spell by 0.5 seconds.|r"
    }
},


-- CreateSpellButton("buttonSpellWeaponMastery", "Interface/icons/ability_hunter_swiftstrike", "|cffffffffMaîtrise des armes|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 10% les dégâts que vous infligez avec toutes les armes.|r", "spellweaponmastery", 663, -75)
-- CreateSpellButton("buttonSpellFrozenPower", "Interface/icons/spell_fire_bluecano", "|cffffffffPuissance gelée|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 10% les dégâts infligés par vos sorts Eclair, Chaîne d'éclairs, Fouet de lave et Horion sur les cibles affectées par l'effet de votre Attaque Arme de givre,\net votre Horion de givre a 100% de chances d'immobiliser la cible dans la glace pendant 5 seconds.\nlorsqu'il est utilisé sur des cibles se trouvant à 15 mètres ou plus de vous.|r", "spellfrozenpower", 770, -75)
-- CreateSpellButton("buttonSpellDualWieldSpecialization", "Interface/icons/ability_dualwieldspecialization", "|cffffffffSpécialisation Ambidextrie|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 6% supplémentaires vos chances de toucher lorsque vous portez deux armes.|r", "spelldualwieldspecialization", 880, -75)
-- CreateSpellButton("buttonSpellDualWield", "Interface/icons/ability_dualwield", "|cffffffffAmbidextrie|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Permet d'équiper les armes à une main dans la main gauche.|r", "spelldualwield", 990, -75)
-- CreateSpellButton("buttonSpellStormstrike", "Interface/icons/ability_shaman_stormstrike", "|cffffffffFrappe-tempête|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Attaque instantanément avec les deux armes.\nDe plus, les 4 prochaines sources de dégâts de Nature infligés à la cible par le chaman sont augmentées de 20%.\nDure 12 secondes.|r", "spellstormstrike", 1100, -75)
-- CreateSpellButton("buttonSpellStaticShock", "Interface/icons/spell_shaman_staticshock", "|cffffffffHorion statique|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Vous avez 6% de chances de toucher votre cible avec une charge d'orbe de Bouclier de foudre quand vous infligez des dégâts avec des attaques et techniques de mêlée,\net votre Bouclier de foudre gagne 6 charges supplémentaires.|r", "spellstaticshock", 718, -130)
-- CreateSpellButton("buttonSpellLavaLash", "Interface/icons/ability_shaman_lavalash", "|cffffffffFouet de lave|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Vous chargez votre arme en main gauche de lave, infligeant instantanément 100% des dégâts de l'arme en main gauche.\nLes dégâts sont augmentés de 25% si votre arme en main gauche est enchantée avec Langue de feu.|r", "spelllavalash", 825, -130)
-- CreateSpellButton("buttonSpellImprovedStormstrike", "Interface/icons/spell_shaman_improvedstormstrike", "|cffffffffFrappe-tempête amélioré|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Quand vous utilisez Frappe-tempête, vous avez 100% de chances de recevoir immédiatement 20% de votre mana de base.|r", "spellimprovedstormstrike", 935, -130)
-- CreateSpellButton("buttonSpellMentalQuickness", "Interface/icons/spell_nature_mentalquickness", "|cffffffffRapidité mentale|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit le coût en mana de vos sorts instantanés de chaman de 6% et augmente la puissance de vos sorts d'un montant égal à 30% de votre puissance d'attaque.|r", "spellmentalquickness", 1045, -130)
-- CreateSpellButton("buttonSpellShamanisticRage", "Interface/icons/spell_nature_shamanrage", "|cffffffffRage du chaman|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit tous les dégâts subis de 30% et donne à vos attaques en mêlée réussies une chance de régénérer un montant de mana égal à 15% de votre puissance d'attaque.\nCe sort peut être utilisé alors que vous êtes étourdi.\nDure 15 secondes.|r", "spellshamanisticrage", 663, -184)
-- CreateSpellButton("buttonSpellEarthenPower", "Interface/icons/spell_nature_earthelemental_totem", "|cffffffffPuissance terrestre|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Votre Totem de lien terrestre a 100% de chances à chacune de ses pulsations d'enlever tous les effets de ralentissement sur vous ainsi que sur les cibles alliées proches,\net votre Horion de terre réduit la vitesse d'attaque des ennemis de 10% supplémentaires.|r", "spellearthenpower", 770, -184)
-- CreateSpellButton("buttonSpellMaelstromWeapon", "Interface/icons/spell_shaman_maelstromweapon", "|cffffffffArme du Maelström|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Quand vous infligez des dégâts avec une arme de mêlée, vous avez une chance (plus élevée qu'au rang 4) de réduire le temps d'incantation de votre prochain sort\nEclair, Chaîne d'éclairs, Vague de soins inférieurs, Salve de guérison, Vague de soins ou Maléfice de 20%.\nCumulable jusqu'à 5 fois.\nDure 30 secondes.|r", "spellmaelstromweapon", 880, -184)
-- CreateSpellButton("buttonSpellFeralSpirit", "Interface/icons/spell_shaman_feralspirit", "|cffffffffEsprit farouche|r\n|cffffffffTalent|r |cffff8c1aAmélioration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Invoque deux Esprits du loup qui obéissent au chaman.\nDure 45 secondes.|r", "spellferalspirit", 990, -184)
-- CreateSpellButton("buttonSpellImprovedHealingWave", "Interface/icons/spell_nature_magicimmunity", "|cffffffffVague de soins améliorée|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit le temps d'incantation de votre sort Vague de soins de 0,5 secondes.", "spellimprovedhealingwave", 1100, -184)


-- Restauration

{
    id = "spellTotemicFocus",
    name = "buttonSpellTotemicFocus",
    icon = "Interface/icons/spell_nature_moonglow",
    position = {718, -240},
    handler = "spelltotemicfocus",
    tooltips = {
        frFR = "|cffffffffFocalisation totémique|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit le coût en mana de vos totems de 25%.|r",
        enUS = "|cffffffffTotemic Focus|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Reduces the mana cost of your Totems by 25%.|r"
    }
},

{
    id = "spellImprovedReincarnation",
    name = "buttonSpellImprovedReincarnation",
    icon = "Interface/icons/spell_nature_reincarnation",
    position = {825, -240},
    handler = "spellimprovedreincarnation",
    tooltips = {
        frFR = "|cffffffffRéincarnation améliorée|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit le temps de recharge de votre sort Réincarnation de 15 min.\net augmente les montants de points de vie et de mana avec lesquels vous vous réincarnez de 20% supplémentaires.|r",
        enUS = "|cffffffffImproved Reincarnation|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Reduces the cooldown of your Reincarnation spell by 15 minutes and increases the amount of health and mana you reincarnate with by 20%.|r"
    }
},

{
    id = "spellHealingGrace",
    name = "buttonSpellHealingGrace",
    icon = "Interface/icons/spell_nature_healingtouch",
    position = {935, -240},
    handler = "spellhealinggrace",
    tooltips = {
        frFR = "|cffffffffGrâce guérisseuse|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Diminue le niveau de menace généré par vos sorts de soins de 15% et réduit la probabilité que vos sorts utiles et vos effets de dégâts sur la durée soient dissipés de 30%.|r",
        enUS = "|cffffffffHealing Grace|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Reduces the threat generated by your healing spells by 15% and reduces the chance that your beneficial spells and damage-over-time effects are dispelled by 30%.|r"
    }
},

{
    id = "spellTidalFocus",
    name = "buttonSpellTidalFocus",
    icon = "Interface/icons/spell_frost_manarecharge",
    position = {1045, -240},
    handler = "spelltidalfocus",
    tooltips = {
        frFR = "|cffffffffFocalisation des flots|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit de 5% le coût en mana de vos sorts de soins.|r",
        enUS = "|cffffffffTidal Focus|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Reduces the mana cost of your healing spells by 5%.|r"
    }
},

{
    id = "spellImprovedWaterShield",
    name = "buttonSpellImprovedWaterShield",
    icon = "Interface/icons/ability_shaman_watershield",
    position = {663, -293},
    handler = "spellimprovedwatershield",
    tooltips = {
        frFR = "|cffffffffBouclier d'eau amélioré|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Vous avez 100% de chances de recevoir instantanément du mana comme si vous consommiez un orbe de Bouclier d'eau quand vous obtenez un effet critique avec vos sorts Vague de soins ou Remous,\n0.6% de chances quand vous obtenez un effet critique avec votre sort Vague de soins inférieurs, et 0.3% de chances quand vous obtenez un effet critique avec votre sort Salve de guérison.|r",
        enUS = "|cffffffffImproved Water Shield|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100You have a 100% chance to instantly gain mana as if you consumed a Water Shield orb when you score a critical effect with your Healing Wave or Surges,\n0.6% chance with a critical effect on Lesser Healing Wave, and 0.3% chance with a critical effect on Healing Surge.|r"
    }
},
{
    id = "spellHealingFocus",
    name = "buttonSpellHealingFocus",
    icon = "Interface/icons/spell_nature_healingwavelesser",
    position = {770, -293},
    handler = "spellhealingfocus",
    tooltips = {
        frFR = "|cffffffffFocalisation des soins|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit de 70% l'interruption causée par les attaques infligeant des dégâts pendant que vous incantez tout sort de soins de chaman.|r",
        enUS = "|cffffffffHealing Focus|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Reduces interruption caused by damage-dealing attacks by 70% while you are casting any Shaman healing spell.|r"
    }
},

{
    id = "spellTidalForce",
    name = "buttonSpellTidalForce",
    icon = "Interface/icons/spell_frost_frostbolt",
    position = {990, -293},
    handler = "spelltidalforce",
    tooltips = {
        frFR = "|cffffffffForce des flots|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente les chances d'obtenir un effet critique avec vos sorts Vague de soins, Vague de soins inférieurs et Salve de guérison de 60%.\nChaque soin critique réduit les chances de 20%.\nDure 20 secondes.|r",
        enUS = "|cffffffffTidal Force|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases the critical strike chance of your Healing Wave, Lesser Healing Wave, and Healing Surge by 60%.\nEach critical heal reduces this chance by 20%.\nLasts 20 seconds.|r"
    }
},

{
    id = "spellAncestralHealing",
    name = "buttonSpellAncestralHealing",
    icon = "Interface/icons/spell_nature_undyingstrength",
    position = {1100, -293},
    handler = "spellancestralhealing",
    tooltips = {
        frFR = "|cffffffffGuérison des anciens|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit de 10% les dégâts physiques subis par votre cible pendant 15 secondes.\naprès avoir reçu un effet critique de l'un de vos sorts de soins.|r",
        enUS = "|cffffffffAncestral Healing|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Reduces the physical damage taken by your target by 10% for 15 seconds after receiving a critical effect from one of your healing spells.|r"
    }
},

{
    id = "spellRestorativeTotems",
    name = "buttonSpellRestorativeTotems",
    icon = "Interface/icons/spell_nature_manaregentotem",
    position = {718, -348},
    handler = "spellrestorativetotems",
    tooltips = {
        frFR = "|cffffffffTotems de restauration|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 20% les effets de votre Totem Fontaine de mana et augmente de 45% le montant de points de vie rendus par votre Totem guérisseur.|r",
        enUS = "|cffffffffRestorative Totems|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases the effects of your Mana Spring Totem by 20% and increases the healing amount of your Healing Stream Totem by 45%.|r"
    }
},

{
    id = "spellTidalMastery",
    name = "buttonSpellTidalMastery",
    icon = "Interface/icons/spell_nature_tranquility",
    position = {825, -348},
    handler = "spelltidalmastery",
    tooltips = {
        frFR = "|cffffffffMaîtrise des flots|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente les chances d'obtenir un effet critique avec vos sorts de soins et d'éclair de 5%.|r",
        enUS = "|cffffffffTidal Mastery|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases the critical strike chance of your healing and lightning spells by 5%.|r"
    }
},
{
    id = "spellHealingWay",
    name = "buttonSpellHealingWay",
    icon = "Interface/icons/spell_nature_healingway",
    position = {935, -348},
    handler = "spellhealingway",
    tooltips = {
        frFR = "|cffffffffFlots de soins|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente le montant de points de vie rendus par votre sort Vague de soins de 25%.|r",
        enUS = "|cffffffffHealing Way|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases the healing done by your Healing Wave by 25%.|r"
    }
},

{
    id = "spellNaturesSwiftness",
    name = "buttonSpellNaturesSwiftness",
    icon = "Interface/icons/spell_nature_ravenform",
    position = {1045, -348},
    handler = "spellnaturesswiftness",
    tooltips = {
        frFR = "|cffffffffRapidité de la nature|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Lorsque cette technique est activée, votre prochain sort de Nature dont le temps d'incantation de base est inférieur à 10 sec.\ndevient un sort instantané.\nRapidité de la nature partage le temps de recharge de Maîtrise élémentaire.|r",
        enUS = "|cffffffffNature's Swiftness|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100When activated, your next Nature spell with a base casting time of less than 10 sec.\nbecomes instant cast.\nShares a cooldown with Elemental Mastery.|r"
    }
},

{
    id = "spellFocusedMind",
    name = "buttonSpellFocusedMind",
    icon = "Interface/icons/spell_nature_focusedmind",
    position = {663, -402},
    handler = "spellfocusedmind",
    tooltips = {
        frFR = "|cffffffffEsprit focalisé|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit de 30% la durée de tous les effets de silence ou d'interruption utilisés contre le chaman.\nCet effet ne se cumule pas avec d'autres effets similaires.|r",
        enUS = "|cffffffffFocused Mind|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Reduces the duration of all silence or interrupt effects used against the Shaman by 30%.\nThis effect does not stack with other similar effects.|r"
    }
},

{
    id = "spellPurification",
    name = "buttonSpellPurification",
    icon = "Interface/icons/spell_frost_wizardmark",
    position = {770, -402},
    handler = "spellpurificatione",
    tooltips = {
        frFR = "|cffffffffPurification|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 10% l'efficacité de vos sorts de soins.|r",
        enUS = "|cffffffffPurification|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases the effectiveness of your healing spells by 10%.|r"
    }
},

{
    id = "spellNaturesGuardian",
    name = "buttonSpellNaturesGuardian",
    icon = "Interface/icons/spell_nature_natureguardian",
    position = {880, -402},
    handler = "spellnaturesguardian",
    tooltips = {
        frFR = "|cffffffffGardien de la nature|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Chaque fois qu'une attaque vous inflige des dégâts qui vous font passer sous les 30% de points de vie, votre maximum de points de vie augmente de 15% pendant 10 secondes.\net votre niveau de menace envers cette cible est réduit.\nTemps de recharge de 30 secondes.|r",
        enUS = "|cffffffffNature's Guardian|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Each time an attack reduces your health below 30%, your maximum health increases by 15% for 10 seconds.\nand your threat against that target is reduced.\n30 seconds cooldown.|r"
    }
},
{
    id = "spellManaTideTotem",
    name = "buttonSpellManaTideTotem",
    icon = "Interface/icons/spell_frost_summonwaterelemental",
    position = {990, -402},
    handler = "spellmanatidetotem",
    tooltips = {
        frFR = "|cffffffffTotem de vague de mana|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Invoque aux pieds du lanceur de sorts un Totem de vague de mana pendant 21 sec.\nIl dispose d'un montant de points de vie égal à 10% de ceux du lanceur et rend 6% du total de mana toutes les 3 secondes aux membres du groupe qui se trouvent à moins de 30 mètres.|r",
        enUS = "|cffffffffMana Tide Totem|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Summons a Mana Tide Totem at the caster's feet for 21 sec.\nIt has 10% of the caster's health and restores 6% of the total mana every 3 seconds to group members within 30 yards.|r"
    }
},

{
    id = "spellCleanseSpirit",
    name = "buttonSpellCleanseSpirit",
    icon = "Interface/icons/ability_shaman_cleansespirit",
    position = {1100, -402},
    handler = "spellcleansespirit",
    tooltips = {
        frFR = "|cffffffffPurifier l'esprit|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Purifie l'esprit d'une cible alliée en annulant 1 effet de poison, 1 effet de maladie et 1 effet de malédiction.|r",
        enUS = "|cffffffffCleanse Spirit|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Cleanses the spirit of a friendly target by removing 1 poison, 1 disease, and 1 curse effect.|r"
    }
},

{
    id = "spellBlessingoftheEternals",
    name = "buttonSpellBlessingoftheEternals",
    icon = "Interface/icons/spell_shaman_blessingofeternals",
    position = {718, -456},
    handler = "spellblessingoftheeternals",
    tooltips = {
        frFR = "|cffffffffBénédiction des Eternels|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente les chances d'effet critique de vos sorts de 4% et augmente les chances d'appliquer l'effet de soins sur la durée de Viveterre de 80% quand la cible dispose de 35% ou moins de ses points de vie.|r",
        enUS = "|cffffffffBlessing of the Eternals|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases the critical chance of your spells by 4% and increases the chance to apply the Viveterre heal-over-time effect by 80% when the target is at 35% or less health.|r"
    }
},

{
    id = "spellImprovedChainHeal",
    name = "buttonSpellImprovedChainHeal",
    icon = "Interface/icons/spell_nature_healingwavegreater",
    position = {825, -456},
    handler = "spellimprovedchainheal",
    tooltips = {
        frFR = "|cffffffffSalve de guérison améliorée|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 20% le montant de points de vie rendus par votre sort Salve de guérison.|r",
        enUS = "|cffffffffImproved Chain Heal|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases the healing done by your Chain Heal spell by 20%.|r"
    }
},

{
    id = "spellNaturesBlessing",
    name = "buttonSpellNaturesBlessing",
    icon = "Interface/icons/spell_nature_natureblessing",
    position = {935, -456},
    handler = "spellnaturesblessing",
    tooltips = {
        frFR = "|cffffffffBénédiction de la nature|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente vos soins d'un montant égal à 15% de votre Intelligence.|r",
        enUS = "|cffffffffNature's Blessing|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases your healing by an amount equal to 15% of your Intelligence.|r"
    }
},
{
    id = "spellAncestralAwakening",
    name = "buttonSpellAncestralAwakening",
    icon = "Interface/icons/spell_shaman_ancestralawakening",
    position = {1045, -456},
    handler = "spellancestralawakening",
    tooltips = {
        frFR = "|cffffffffEveil ancestral|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Quand vous réussissez des soins critiques avec Vague de soins, Vague de soins inférieurs ou Remous, vous invoquez un Esprit ancestral à votre aide.\nIl rend instantanément à la cible alliée membre du groupe ou raid dans un rayon de 40 mètres dont le pourcentage de points de vie est le plus bas 30% du montant soigné.|r",
        enUS = "|cffffffffAncestral Awakening|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100When you score a critical heal with Healing Wave, Lesser Healing Wave, or Riptide, an Ancestral Spirit is summoned to your aid.\nIt instantly heals the lowest health target within 40 yards of your group or raid for 30% of the healing done.|r"
    }
},

{
    id = "spellEarthShield",
    name = "buttonSpellEarthShield",
    icon = "Interface/icons/spell_nature_skinofearth",
    position = {663, -510},
    handler = "spellearthshield",
    tooltips = {
        frFR = "|cffffffffBouclier de terre|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Protège la cible avec un bouclier de terre, qui réduit de 30% le temps d'incantation ou de canalisation de sort perdu quand elle subit des dégâts.\nLes attaques rendent 150 points de vie à la cible protégée.\nCet effet ne peut se produire qu’une fois toutes les quelques secondes.\n6 charges.\nDure 10 mn.\nBouclier de terre ne peut être placé que sur une cible à la fois et un seul Bouclier élémentaire peut être actif sur une cible à la fois.|r",
        enUS = "|cffffffffEarth Shield|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Protects the target with an Earth Shield, reducing 30% of the casting or channeling time lost when they take damage.\nAttacks heal the protected target for 150 health.\nThis effect can occur only once every few seconds.\n6 charges.\nLasts 10 min.\nOnly one Earth Shield can be placed on a target at a time, and only one Elemental Shield can be active on a target at once.|r"
    }
},

{
    id = "spellImprovedEarthShield",
    name = "buttonSpellImprovedEarthShield",
    icon = "Interface/icons/spell_nature_skinofearth",
    position = {770, -510},
    handler = "spellimprovedearthshield",
    tooltips = {
        frFR = "|cffffffffBouclier de terre amélioré|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente le nombre de charges de votre Bouclier de terre de 2, et augmente les soins prodigués par votre Bouclier de terre de 10%.|r",
        enUS = "|cffffffffImproved Earth Shield|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Increases the number of charges of your Earth Shield by 2, and increases the healing done by your Earth Shield by 10%.|r"
    }
},

{
    id = "spellTidalWaves",
    name = "buttonSpellTidalWaves",
    icon = "Interface/icons/spell_shaman_tidalwaves",
    position = {880, -510},
    handler = "spelltidalwaves",
    tooltips = {
        frFR = "|cffffffffRaz-de-marée|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Vous avez 100% de chances après avoir lancé Salve de guérison ou Remous de réduire le temps d'incantation de votre sort Vague de soins de 30% et d'augmenter les chances d'effet critique de votre sort\nVague de soins inférieurs de 25% jusqu'à ce que deux de ces sorts aient été lancés.\nDe plus, votre Vague de soins bénéficie de 20% supplémentaires des effets du bonus relatif aux soins et votre Vague de soins inférieurs de 10% supplémentaires des effets du bonus relatif aux soins.|r",
        enUS = "|cffffffffTidal Waves|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100After casting Chain Heal or Riptide, you have a 100% chance to reduce the cast time of Healing Wave by 30% and increase the critical strike chance of your Lesser Healing Wave by 25% until two of these spells have been cast.\nAdditionally, your Healing Wave benefits from 20% more healing bonuses, and your Lesser Healing Wave benefits from 10% more healing bonuses.|r"
    }
},

{
    id = "spellRiptide",
    name = "buttonSpellRiptide",
    icon = "Interface/icons/spell_nature_riptide",
    position = {990, -510},
    handler = "spellriptide",
    tooltips = {
        frFR = "|cffffffffRemous|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Rend à une cible alliée 639 à 691 points de vie plus 665 points de vie en 15 seconds.\nVotre prochaine Salve de guérison lancée sur cette cible primaire dans les 15 seconds consommera l'effet de soins sur la durée et augmentera le montant de soins de votre Salve de guérison de 25%.|r",
        enUS = "|cffffffffRiptide|r\n|cffffffffTalent|r |cff0cf200Restoration|r\n|cffffffffRequires|r |cff0070deShaman|r\n|cffffd100Heals a friendly target for 639 to 691 health plus 665 health over 15 seconds.\nYour next Chain Heal cast on this target within 15 seconds will consume the heal-over-time effect and increase the healing amount of Chain Heal by 25%.|r"
		}
	}
}


-- CreateSpellButton("buttonSpellTotemicFocus", "Interface/icons/spell_nature_moonglow", "|cffffffffFocalisation totémique|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit le coût en mana de vos totems de 25%.|r", "spelltotemicfocus", 718, -240)
-- CreateSpellButton("buttonSpellImprovedReincarnation", "Interface/icons/spell_nature_reincarnation", "|cffffffffRéincarnation améliorée|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit le temps de recharge de votre sort Réincarnation de 15 min.\net augmente les montants de points de vie et de mana avec lesquels vous vous réincarnez de 20% supplémentaires.|r", "spellimprovedreincarnation", 825, -240)
-- CreateSpellButton("buttonSpellHealingGrace", "Interface/icons/spell_nature_healingtouch", "|cffffffffGrâce guérisseuse|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Diminue le niveau de menace généré par vos sorts de soins de 15% et réduit la probabilité que vos sorts utiles et vos effets de dégâts sur la durée soient dissipés de 30%.|r", "spellhealinggrace", 935, -240)
-- CreateSpellButton("buttonSpellTidalFocus", "Interface/icons/spell_frost_manarecharge", "|cffffffffFocalisation des flots|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit de 5% le coût en mana de vos sorts de soins.|r", "spelltidalfocus", 1045, -240)
-- CreateSpellButton("buttonSpellImprovedWaterShield", "Interface/icons/ability_shaman_watershield", "|cffffffffBouclier d'eau amélioré|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Vous avez 100% de chances de recevoir instantanément du mana comme si vous consommiez un orbe de Bouclier d'eau quand vous obtenez un effet critique avec vos sorts Vague de soins ou Remous,\n0.6% de chances quand vous obtenez un effet critique avec votre sort Vague de soins inférieurs, et 0.3% de chances quand vous obtenez un effet critique avec votre sort Salve de guérison.|r", "spellimprovedwatershield", 663, -293)
-- CreateSpellButton("buttonSpellHealingFocus", "Interface/icons/spell_nature_healingwavelesser", "|cffffffffFocalisation des soins|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit de 70% l'interruption causée par les attaques infligeant des dégâts pendant que vous incantez tout sort de soins de chaman.|r", "spellhealingfocus", 770, -293)
-- CreateSpellButton("buttonSpellTidalForce", "Interface/icons/spell_frost_frostbolt", "|cffffffffForce des flots|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente les chances d'obtenir un effet critique avec vos sorts Vague de soins, Vague de soins inférieurs et Salve de guérison de 60%.\nChaque soin critique réduit les chances de 20%.\nDure 20 secondes.|r", "spelltidalforce", 990, -293)
-- CreateSpellButton("buttonSpellAncestralHealing", "Interface/icons/spell_nature_undyingstrength", "|cffffffffGuérison des anciens|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit de 10% les dégâts physiques subis par votre cible pendant 15 secondes.\naprès avoir reçu un effet critique de l'un de vos sorts de soins.|r", "spellancestralhealing", 1100, -293)
-- CreateSpellButton("buttonSpellRestorativeTotems", "Interface/icons/spell_nature_manaregentotem", "|cffffffffTotems de restauration|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 20% les effets de votre Totem Fontaine de mana et augmente de 45% le montant de points de vie rendus par votre Totem guérisseur.|r", "spellrestorativetotems", 718, -348)
-- CreateSpellButton("buttonSpellTidalMastery", "Interface/icons/spell_nature_tranquility", "|cffffffffMaîtrise des flots|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente les chances d'obtenir un effet critique avec vos sorts de soins et d'éclair de 5%.|r", "spelltidalmastery", 825, -348)
-- CreateSpellButton("buttonSpellHealingWay", "Interface/icons/spell_nature_healingway", "|cffffffffFlots de soins|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente le montant de points de vie rendus par votre sort Vague de soins de 25%.|r", "spellhealingway", 935, -348)
-- CreateSpellButton("buttonSpellNaturesSwiftness", "Interface/icons/spell_nature_ravenform", "|cffffffffRapidité de la nature|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Lorsque cette technique est activée, votre prochain sort de Nature dont le temps d'incantation de base est inférieur à 10 sec.\ndevient un sort instantané.\nRapidité de la nature partage le temps de recharge de Maîtrise élémentaire.|r", "spellnaturesswiftness", 1045, -348)
-- CreateSpellButton("buttonSpellFocusedMind", "Interface/icons/spell_nature_focusedmind", "|cffffffffEsprit focalisé|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Réduit de 30% la durée de tous les effets de silence ou d'interruption utilisés contre le chaman.\nCet effet ne se cumule pas avec d'autres effets similaires.|r", "spellfocusedmind", 663, -402)
-- CreateSpellButton("buttonSpellPurification", "Interface/icons/spell_frost_wizardmark", "|cffffffffPurification|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 10% l'efficacité de vos sorts de soins.|r", "spellpurificatione", 770, -402)
-- CreateSpellButton("buttonSpellNaturesGuardian", "Interface/icons/spell_nature_natureguardian", "|cffffffffGardien de la nature|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Chaque fois qu'une attaque vous inflige des dégâts qui vous font passer sous les 30% de points de vie, votre maximum de points de vie augmente de 15% pendant 10 secondes.\net votre niveau de menace envers cette cible est réduit.\nTemps de recharge de 30 secondes.|r", "spellnaturesguardian", 880, -402)
-- CreateSpellButton("buttonSpellManaTideTotem", "Interface/icons/spell_frost_summonwaterelemental", "|cffffffffTotem de vague de mana|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Invoque aux pieds du lanceur de sorts un Totem de vague de mana pendant 21 sec.\nIl dispose d'un montant de points de vie égal à 10% de ceux du lanceur et rend 6% du total de mana toutes les 3 secondes aux membres du groupe qui se trouvent à moins de 30 mètres.|r", "spellmanatidetotem", 990, -402)
-- CreateSpellButton("buttonSpellCleanseSpirit", "Interface/icons/ability_shaman_cleansespirit", "|cffffffffPurifier l'esprit|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Purifie l'esprit d'une cible alliée en annulant 1 effet de poison, 1 effet de maladie et 1 effet de malédiction.|r", "spellcleansespirit", 1100, -402)
-- CreateSpellButton("buttonSpellBlessingoftheEternals", "Interface/icons/spell_shaman_blessingofeternals", "|cffffffffBénédiction des Eternels|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente les chances d'effet critique de vos sorts de 4% et augmente les chances d'appliquer l'effet de soins sur la durée de Viveterre de 80% quand la cible dispose de 35% ou moins de ses points de vie.|r", "spellblessingoftheeternals", 718, -456)
-- CreateSpellButton("buttonSpellImprovedChainHeal", "Interface/icons/spell_nature_healingwavegreater", "|cffffffffSalve de guérison améliorée|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente de 20% le montant de points de vie rendus par votre sort Salve de guérison.|r", "spellimprovedchainheal", 825, -456)
-- CreateSpellButton("buttonSpellNaturesBlessing", "Interface/icons/spell_nature_natureblessing", "|cffffffffBénédiction de la nature|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente vos soins d'un montant égal à 15% de votre Intelligence.|r", "spellnaturesblessing", 935, -456)
-- CreateSpellButton("buttonSpellAncestralAwakening", "Interface/icons/spell_shaman_ancestralawakening", "|cffffffffEveil ancestral|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Quand vous réussissez des soins critiques avec Vague de soins, Vague de soins inférieurs ou Remous, vous invoquez un Esprit ancestral à votre aide.\nIl rend instantanément à la cible alliée membre du groupe ou raid dans un rayon de 40 mètres dont le pourcentage de points de vie est le plus bas 30% du montant soigné.|r", "spellancestralawakening", 1045, -456)
-- CreateSpellButton("buttonSpellEarthShield", "Interface/icons/spell_nature_skinofearth", "|cffffffffBouclier de terre|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Protège la cible avec un bouclier de terre, qui réduit de 30% le temps d'incantation ou de canalisation de sort perdu quand elle subit des dégâts.\nLes attaques rendent 150 points de vie à la cible protégée.\nCet effet ne peut se produire qu’une fois toutes les quelques secondes.\n6 charges.\nDure 10 mn.\nBouclier de terre ne peut être placé que sur une cible à la fois et un seul Bouclier élémentaire peut être actif sur une cible à la fois.|r", "spellearthshield", 663, -510)
-- CreateSpellButton("buttonSpellImprovedEarthShield", "Interface/icons/spell_nature_skinofearth", "|cffffffffBouclier de terre amélioré|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Augmente le nombre de charges de votre Bouclier de terre de 2, et augmente les soins prodigués par votre Bouclier de terre de 10%.|r", "spellimprovedearthshield", 770, -510)
-- CreateSpellButton("buttonSpellTidalWaves", "Interface/icons/spell_shaman_tidalwaves", "|cffffffffRaz-de-marée|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Vous avez 100% de chances après avoir lancé Salve de guérison ou Remous de réduire le temps d'incantation de votre sort Vague de soins de 30% et d'augmenter les chances d'effet critique de votre sort\nVague de soins inférieurs de 25% jusqu'à ce que deux de ces sorts aient été lancés.\nDe plus, votre Vague de soins bénéficie de 20% supplémentaires des effets du bonus relatif aux soins et votre Vague de soins inférieurs de 10% supplémentaires des effets du bonus relatif aux soins.|r", "spelltidalwaves", 880, -510)
-- CreateSpellButton("buttonSpellRiptide", "Interface/icons/spell_nature_riptide", "|cffffffffRemous|r\n|cffffffffTalent|r |cff0cf200Restauration|r\n|cffffffffRequiert|r |cff0070deChaman|r\n|cffffd100Rend à une cible alliée 639 à 691 points de vie plus 665 points de vie en 15 seconds.\nVotre prochaine Salve de guérison lancée sur cette cible primaire dans les 15 seconds consommera l'effet de soins sur la durée et augmentera le montant de soins de votre Salve de guérison de 25%.|r", "spellriptide", 990, -510)

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

-- Créez le bouton Save à l'intérieur de la fenêtre frameTalentShaman
local saveButton = CreateFrame("Button", "saveButton", frameTalentShaman, "UIPanelButtonTemplate")
saveButton:SetSize(85, 25)
saveButton:SetPoint("BOTTOMRIGHT", buttonTalentShamanClose, "BOTTOMLEFT", -185, 5) -- Place le bouton Save à gauche du bouton Close
saveButton:SetText(saveButtonText)

-- Fonction qui prend un screenshot quand le bouton est cliqué
saveButton:SetScript("OnClick", function()
    Screenshot()  -- Prendre un screenshot et l'enregistrer dans le dossier Screenshots du jeu
    print(screenshotMessage)  -- Affiche un message de confirmation en fonction de la locale
end)

-- Affiche l'UI des talents
--frameTalentShaman:Show()

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

-- Créez le bouton Reset à l'intérieur de la fenêtre frameTalentShaman
local buttonReset = CreateFrame("Button", "buttonReset", frameTalentShaman, "UIPanelButtonTemplate")
buttonReset:SetSize(85, 25)
buttonReset:SetPoint("BOTTOMRIGHT", buttonTalentShamanClose, "BOTTOMLEFT", -95, 5) -- Place le bouton Reset à gauche du bouton Reload
buttonReset:SetText(buttonResetText)

local function ResetTalents()
    -- Ajoutez ici la logique pour réinitialiser les talents du joueur
    AIO.Handle("TalentShamanspell", "ResetTalents")
    resetButtonClicked = true -- Marquez le bouton Réinitialiser comme cliqué
end

buttonReset:SetScript("OnClick", ResetTalents)

-- Créez le bouton Reload à l'intérieur de la fenêtre frameTalentShaman
local buttonReload = CreateFrame("Button", "buttonReload", frameTalentShaman, "UIPanelButtonTemplate")
buttonReload:SetSize(85, 25)
buttonReload:SetPoint("BOTTOMRIGHT", buttonTalentShamanClose, "BOTTOMLEFT", -5, 5) -- Place le bouton Reload à gauche du bouton Close
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

local function ReloadClient()
    -- Ajoutez une vérification pour s'assurer que le bouton Réinitialiser a été cliqué
    if resetButtonClicked then
        ReloadUI()
    else
        print("|cff00ffffVous ne pouvez <Actualiser> que lorsque vous <Réinitialiser> vos talents.")
    end
end

buttonReload:SetScript("OnClick", ReloadClient)

-- Ajoutez une variable globale pour suivre l'état de la fenêtre des talents
local talentsWindowOpen = false

local function OuvrirFermerInterfaceTalents()
    if talentsWindowOpen then
        frameTalentShaman:Hide()
        buttonReload:Hide()
        PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
    else
        frameTalentShaman:Show()
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
        frFR = "|cffffffffTalents|r |cff0070de(Chaman)|r\n\nL'éventail des talents disponibles\npour améliorer et spécialiser\nvotre personnage.",
        enUS = "|cffffffffTalents|r |cff0070de(Shaman)|r\n\nThe range of available talents\nfor enhancing and specializing\nyour character."
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

-- Vérifier si le joueur est un Shaman avant de créer le bouton
local playerClass = select(2, UnitClass("player")) -- Obtenir la classe du joueur
if playerClass == "SHAMAN" then
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
ShamanHandlers.UpdateTalentCount = function(player, talentsAppris)
    if fontTalentShamanFrameText then
        fontTalentShamanFrameText:SetText(talentsAppris .. " / " .. MAX_TALENTS)
    end
end

-- Mise à jour des points de talent utilisés avec texte localisé
ShamanHandlers.UpdateTalentPointsUsed = function(player, pointsUsed, pointsBeforeReset)
    -- Utilisation du texte localisé pour les points avant réinitialisation
    print(string.format(GetLocalizedPointsBeforeResetText(), pointsBeforeReset))
end

-- Affichage des talents restants (items 338404 dans le sac)
ShamanHandlers.UpdateTalentItemCount = function(player, count)
    if fontTalentPointsRemainingText then
        fontTalentPointsRemainingText:SetText("|cFF0070DETalents restants : " .. count .. "|r")
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
        fontTalentPointsRemainingText:SetText("|cFF0070DETalents restants : " .. (count or 0) .. "|r")
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
if playerClass == "SHAMAN" then
    -- Surcharge OnHide pour synchroniser talentsWindowOpen quand Échap est pressé
    local _originalOnHide = frameTalentShaman:GetScript("OnHide")
    frameTalentShaman:SetScript("OnHide", function(self)
        talentsWindowOpen = false
        if _originalOnHide then _originalOnHide(self) end
    end)
    -- WoW appelle automatiquement Hide() sur les frames listées ici quand Échap est pressé
    tinsert(UISpecialFrames, "frameTalentShaman")
end