local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local HunterHandlers = AIO.AddHandlers("TalentHunterspell", {})

function HunterHandlers.ShowTalentHunter(player)
    frameTalentHunter:Show()
    -- Redemande au serveur l’état visuel au cas où
    AIO.Handle("TalentHunterspell", "RequestLearnedTalents")
	-- Redemande le nombre de talents restants
    AIO.Handle("TalentHunterspell", "GetTalentItemCount")
end

local MAX_TALENTS = 60 -- Définition du nombre maximal de talents que le joueur peut apprendre

local OPEN_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_final_trait_unlocked.ogg"
local CLOSE_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_trait_refund_end.ogg"
local SPELL_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_80_azeritearmor_rotationends_02.ogg"

-- Attribute window
local frameTalentHunter = CreateFrame("Frame", "frameTalentHunter", UIParent)
frameTalentHunter:SetSize(1200, 650)
frameTalentHunter:SetMovable(true)
frameTalentHunter:EnableMouse(true)
frameTalentHunter:RegisterForDrag("LeftButton")
frameTalentHunter:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, -50) -- Adjust the X and Y coordinates
frameTalentHunter:SetBackdrop(
{
    -- bgFile = "interface/TalentFrame/talentsclassbackgroundHunter", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    bgFile = "interface/TalentFrame/talentsclassbackgroundhunter", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedhunter", --Interface/DialogFrame/UI-DialogBox-Border
    edgeSize = 20,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})

-- Ajoutez la texture de l'icône du Chasseur
local hunterIcon = frameTalentHunter:CreateTexture("HunterIcon", "OVERLAY")
hunterIcon:SetTexture("Interface\\TalentFrame\\Template\\Class\\Hunter\\IconeHunter.blp")
hunterIcon:SetSize(60, 60)
hunterIcon:SetPoint("TOPLEFT", frameTalentHunter, "TOPLEFT", -10, 10)

-- Template Talent Frame

-- Ajoute une textureone pour l'image BLP
local textureone = frameTalentHunter:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
textureone:SetTexture("Interface\\TalentFrame\\Template\\Class\\Hunter\\TalentFrameTemplate.blp")
textureone:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
textureone:SetPoint("TOPLEFT", frameTalentHunter, "TOPLEFT", -170, 140) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentHunter:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Ajoute une texturetwo pour l'image BLP
local texturetwo = frameTalentHunter:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
texturetwo:SetTexture("Interface\\TalentFrame\\Template\\Class\\Hunter\\TalentFrameTemplateOriginal.blp")
texturetwo:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
texturetwo:SetPoint("TOPRIGHT", frameTalentHunter, "TOPRIGHT", 170, 140) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentHunter:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Drag & Drop
frameTalentHunter:SetScript("OnDragStart", frameTalentHunter.StartMoving)
frameTalentHunter:SetScript("OnHide", frameTalentHunter.StopMovingOrSizing)
frameTalentHunter:SetScript("OnDragStop", frameTalentHunter.StopMovingOrSizing)
frameTalentHunter:Hide()

-- Nouveau template d'arête
frameTalentHunter:SetBackdropBorderColor(169, 210, 113) -- Couleur vert

-- Close button
local buttonTalentHunterClose = CreateFrame("Button", "buttonTalentHunterClose", frameTalentHunter, "UIPanelCloseButton")
buttonTalentHunterClose:SetPoint("TOPRIGHT", -12, -12)
buttonTalentHunterClose:EnableMouse(true)
buttonTalentHunterClose:SetSize(32, 32)

local function CloseTalentWindow()
    frameTalentHunter:Hide()
    PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
end

-- Associez la fonction de fermeture au bouton de fermeture
buttonTalentHunterClose:SetScript("OnClick", CloseTalentWindow)

-- Title bar
local frameTalentHunterTitleBar = CreateFrame("Frame", "frameTalentHunterTitleBar", frameTalentHunter, nil)
frameTalentHunterTitleBar:SetSize(135, 25)
frameTalentHunterTitleBar:SetBackdrop(
{
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedHunter",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentHunterTitleBar:SetPoint("TOP", 0, 20)

local fontTalentHunterTitleText = frameTalentHunterTitleBar:CreateFontString("fontTalentHunterTitleText")
fontTalentHunterTitleText:SetFont("Fonts\\FRIZQT__.TTF", 13)
fontTalentHunterTitleText:SetSize(190, 5)
fontTalentHunterTitleText:SetPoint("CENTER", 0, 0)
fontTalentHunterTitleText:SetText("|cffFFC125Talents|r")

-- Détecte la langue du client
local locale = GetLocale() -- Retourne "enUS", "frFR", etc.

-- Table des traductions
local localizedTexts = {
    enUS = "|cffFFC125Hunter|r",
    frFR = "|cffFFC125Chasseur|r",
}

-- Récupère le texte correspondant à la langue actuelle ou par défaut en anglais
local textToDisplay = localizedTexts[locale] or localizedTexts["enUS"]

local fontTalentHunterFrameText = frameTalentHunterTitleBar:CreateFontString("fontTalentHunterFrameText")
fontTalentHunterFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentHunterFrameText:SetSize(200, 5)
fontTalentHunterFrameText:SetPoint("TOPLEFT", frameTalentHunterTitleBar, "BOTTOMLEFT", -30, -35) -- Adjust the Y offset as needed
fontTalentHunterFrameText:SetText(textToDisplay)

-- Remplacez votre ligne existante pour la création du texte par celle-ci
local fontTalentHunterFrameText = frameTalentHunterTitleBar:CreateFontString("fontTalentHunterFrameText")
fontTalentHunterFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentHunterFrameText:SetSize(200, 5)
fontTalentHunterFrameText:SetPoint("TOPLEFT", frameTalentHunterTitleBar, "BOTTOMLEFT", -30, -60) -- Adjust the Y offset as needed
fontTalentHunterFrameText:SetText("0 / " .. MAX_TALENTS) -- Initialisez le texte avec 0 talents appris

-------------------------------------------------------------
-- Affichage "Talents restants" (item 338404 dans le sac)
-------------------------------------------------------------

local frameTalentPointsRemaining = CreateFrame("Frame", "frameTalentPointsRemaining", frameTalentHunter, nil)
frameTalentPointsRemaining:SetSize(220, 30)
frameTalentPointsRemaining:SetBackdrop({
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedhunter",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentPointsRemaining:SetPoint("BOTTOMRIGHT", frameTalentHunter, "BOTTOMRIGHT", -960, 10)

local fontTalentPointsRemainingText = frameTalentPointsRemaining:CreateFontString("fontTalentPointsRemainingText")
fontTalentPointsRemainingText:SetFont("Fonts\\FRIZQT__.TTF", 14)
fontTalentPointsRemainingText:SetSize(210, 20)
fontTalentPointsRemainingText:SetPoint("CENTER", 0, 0)
fontTalentPointsRemainingText:SetText("|cFFA9D271Talents restants : 0|r")
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
HunterHandlers.UpdateLearnedTalents = function(player, learnedSpells)
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

    local button = CreateFrame("Button", name, frameTalentHunter, nil)
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
                AIO.Handle("TalentHunterspell", talentHandler, 1)
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

-- Maitrise des Bêtes

-- Table des sorts
local spells = {
{
    id = "spellImprovedAspectoftheHawk",
    name = "buttonSpellImprovedAspectoftheHawk",
    icon = "Interface/icons/spell_nature_ravenform",
    position = {100, -80},
    handler = "spellimprovedaspectofthehawk",
    tooltips = {
        frFR = "|cffffffffAspect du faucon amélioré|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Pendant qu'Aspect du faucon ou Aspect du faucon-dragon est activé, toutes les attaques à distance normales ont 10% de chances d'augmenter la vitesse d'attaque à distance de 15% pendant 12 secondes.|r",
        enUS = "|cffffffffImproved Aspect of the Hawk|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100While Aspect of the Hawk or Aspect of the Dragonhawk is active, all normal ranged attacks have a 10% chance to increase ranged attack speed by 15% for 12 seconds.|r"
    }
},

{
    id = "spellEnduranceTraining",
    name = "buttonSpellEnduranceTraining",
    icon = "Interface/icons/spell_nature_reincarnation",
    position = {205, -75},
    handler = "spellendurancetraining",
    tooltips = {
        frFR = "|cffffffffEntraînement à l'Endurance|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente les points de vie de votre familier de 10% et votre total de points de vie de 5%.|r",
        enUS = "|cffffffffEndurance Training|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases your pet's health by 10% and your total health by 5%.|r"
    }
},

{
    id = "spellFocusedFire",
    name = "buttonSpellFocusedFire",
    icon = "Interface/icons/ability_hunter_silenthunter",
    position = {315, -75},
    handler = "spellfocusedfire",
    tooltips = {
        frFR = "|cffffffffSurvie focalisé|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Tous les dégâts que vous infligez sont augmentés de 2% tant que votre familier est actif et les chances de coup critique des techniques spéciales de votre familier sont augmentées de 20% tant qu'Ordre de tuer est actif.|r",
        enUS = "|cffffffffFocused Fire|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100All damage you deal is increased by 2% while your pet is active, and your pet's special ability critical strike chance is increased by 20% while Kill Command is active.|r"
    }
},

{
    id = "spellImprovedAspectoftheMonkey",
    name = "buttonSpellImprovedAspectoftheMonkey",
    icon = "Interface/icons/ability_hunter_aspectofthemonkey",
    position = {418, -80},
    handler = "spellimprovedaspectofthemonkey",
    tooltips = {
        frFR = "|cffffffffAspect du singe amélioré|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente le bonus d'Esquive conféré par Aspect du singe ou votre Aspect du faucon-dragon de 6%.|r",
        enUS = "|cffffffffImproved Aspect of the Monkey|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases the dodge bonus granted by Aspect of the Monkey or your Aspect of the Dragonhawk by 6%.|r"
    }
},

{
    id = "spellThickHide",
    name = "buttonSpellThickHide",
    icon = "Interface/icons/inv_misc_pelt_bear_03",
    position = {45, -130},
    handler = "spellthickhide",
    tooltips = {
        frFR = "|cffffffffPeau épaisse|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente le score d'armure de vos familiers de 20% et la valeur d'armure que vous apportent les objets de 10%.|r",
        enUS = "|cffffffffThick Hide|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases your pet's armor by 20% and the armor value provided by your gear by 10%.|r"
    }
},
{
    id = "spellImprovedRevivePet",
    name = "buttonSpellImprovedRevivePet",
    icon = "Interface/icons/ability_hunter_beastsoothe",
    position = {150, -130},
    handler = "spellimprovedrevivepet",
    tooltips = {
        frFR = "|cffffffffRessusciter le familier amélioré|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Le temps d'incantation du sort Ressusciter le familier est réduit de 6 sec., son coût en mana est diminué de 40% et le familier revient avec 30% de points de vie supplémentaires.|r",
        enUS = "|cffffffffImproved Revive Pet|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100The cast time of Revive Pet is reduced by 6 seconds, its mana cost is decreased by 40%, and your pet returns with 30% more health.|r"
    }
},

{
    id = "spellPathfinding",
    name = "buttonSpellPathfinding",
    icon = "Interface/icons/ability_mount_jungletiger",
    position = {260, -130},
    handler = "spellpathfinding",
    tooltips = {
        frFR = "|cffffffffScience des chemins|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente le bonus de vitesse de vos Aspects de la meute et du guépard de 8% et augmente la vitesse de votre monture de 10%. Ne se cumule pas avec les autres effets d'augmentation de vitesse de la monture.|r",
        enUS = "|cffffffffPathfinding|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases the speed bonus of your Aspect of the Pack and Aspect of the Cheetah by 8%, and increases your mount's speed by 10%. Does not stack with other mount speed increases.|r"
    }
},

{
    id = "spellAspectMastery",
    name = "buttonSpellAspectMastery",
    icon = "Interface/icons/ability_hunter_aspectmastery",
    position = {370, -130},
    handler = "spellaspectmastery",
    tooltips = {
        frFR = "|cffffffffMaîtrise des aspects|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Aspect de la vipère - Réduit la pénalité aux dégâts de 10%.\nAspect du singe - Réduit les dégâts que vous subissez pendant qu'il est actif de 5%.\nAspect du faucon - Augmente le bonus à la puissance d'attaque de 30%.\nAspect du faucon-dragon - Combine les bonus des aspects du singe et du faucon.|r",
        enUS = "|cffffffffAspect Mastery|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Viper Aspect - Reduces the damage penalty by 10%.\nMonkey Aspect - Reduces damage you take while active by 5%.\nHawk Aspect - Increases attack power bonus by 30%.\nDragonhawk Aspect - Combines the bonuses of Monkey and Hawk aspects.|r"
    }
},

{
    id = "spellUnleashedFury",
    name = "buttonSpellUnleashedFury",
    icon = "Interface/icons/ability_bullrush",
    position = {475, -133},
    handler = "spellunleashedfury",
    tooltips = {
        frFR = "|cffffffffFureur libérée|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente les dégâts infligés par vos familiers de 15%.|r",
        enUS = "|cffffffffUnleashed Fury|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases the damage dealt by your pets by 15%.|r"
    }
},

{
    id = "spellImprovedMendPet",
    name = "buttonSpellImprovedMendPet",
    icon = "Interface/icons/ability_hunter_mendpet",
    position = {96, -185},
    handler = "spellimprovedmendpet",
    tooltips = {
        frFR = "|cffffffffGuérison du familier améliorée|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Réduit le coût en mana de votre sort Guérison du familier de 20% et lui donne 50% de chances de faire disparaître 1 effet de malédiction, maladie, magie ou poison du familier à chaque itération.|r",
        enUS = "|cffffffffImproved Mend Pet|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Reduces the mana cost of your Mend Pet spell by 20% and gives it a 50% chance to remove 1 curse, disease, magic, or poison effect from your pet with each tick.|r"
    }
},
{
    id = "spellFerocity",
    name = "buttonSpellFerocity",
    icon = "Interface/icons/inv_misc_monsterclaw_04",
    position = {205, -185},
    handler = "spellferocity",
    tooltips = {
        frFR = "|cffffffffFerocité|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente de 10% les chances de votre familier d'infliger un coup critique.|r",
        enUS = "|cffffffffFerocity|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases your pet's chance to score a critical hit by 10%.|r"
    }
},

{
    id = "spellSpiritBond",
    name = "buttonSpellSpiritBond",
    icon = "Interface/icons/ability_druid_demoralizingroar",
    position = {315, -185},
    handler = "spellspiritbond",
    tooltips = {
        frFR = "|cffffffffEngagement spirituel|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Tant que votre familier est actif, vous et votre familier retrouvez 2% du total de vos points de vie toutes les 10 sec., et les soins prodigués à vous-même et à votre familier sont augmentés de 10%.|r",
        enUS = "|cffffffffSpirit Bond|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100While your pet is active, you and your pet both regenerate 2% of your total health every 10 seconds, and healing done to both you and your pet is increased by 10%.|r"
    }
},

{
    id = "spellIntimidation",
    name = "buttonSpellIntimidation",
    icon = "Interface/icons/ability_devour",
    position = {422, -185},
    handler = "spellintimidation",
    tooltips = {
        frFR = "|cffffffffIntimidation|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Ordonne à votre familier d'intimider la cible, générant un niveau élevé de menace et étourdissant la cible pendant 3 seconds.\nDure 15 seconds.|r",
        enUS = "|cffffffffIntimidation|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Commands your pet to intimidate the target, generating high threat and stunning the target for 3 seconds.\nLasts for 15 seconds.|r"
    }
},

{
    id = "spellBestialDiscipline",
    name = "buttonSpellBestialDiscipline",
    icon = "Interface/icons/spell_nature_abolishmagic",
    position = {527, -190},
    handler = "spellbestialdiscipline",
    tooltips = {
        frFR = "|cffffffffDiscipline bestiale|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente de 100% la régénération de focalisation de vos Familiers.|r",
        enUS = "|cffffffffBestial Discipline|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases your pet's Focus regeneration by 100%.|r"
    }
},

{
    id = "spellAnimalHandler",
    name = "buttonSpellAnimalHandler",
    icon = "Interface/icons/ability_hunter_animalhandler",
    position = {43, -240},
    handler = "spellanimalhandler",
    tooltips = {
        frFR = "|cffffffffDresseur|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente de 10% la puissance d'attaque de votre familier et augmente la durée de l'effet d'Appel du maître de 6 sec.|r",
        enUS = "|cffffffffAnimal Handler|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases your pet's attack power by 10% and increases the duration of Master’s Call by 6 seconds.|r"
    }
},
{
    id = "spellFrenzy",
    name = "buttonSpellFrenzy",
    icon = "Interface/icons/inv_misc_monsterclaw_03",
    position = {150, -240},
    handler = "spellfrenzy",
    tooltips = {
        frFR = "|cffffffffFrénésie|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Confère à votre familier 100% de chances de bénéficier d'un bonus de 30% à la vitesse d'attaque pendant 8 secondes après qu'il a infligé un coup critique.|r",
        enUS = "|cffffffffFrenzy|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Grants your pet 100% chance to gain a 30% attack speed bonus for 8 seconds after it scores a critical hit.|r"
    }
},

{
    id = "spellFerociousInspiration",
    name = "buttonSpellFerociousInspiration",
    icon = "Interface/icons/ability_hunter_ferociousinspiration",
    position = {368, -240},
    handler = "spellferociousinspiration",
    tooltips = {
        frFR = "|cffffffffInspiration féroce|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Tous les membres du groupe ou du raid voient tous leurs dégâts augmenter de 3% quand ils sont à moins de 100 mètres de votre familier.\nDe plus, augmente les dégâts infligés par Tir des arcanes et Tir assuré de 9%.|r",
        enUS = "|cffffffffFerocious Inspiration|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100All group or raid members have their damage increased by 3% when within 100 yards of your pet.\nAdditionally, increases Arcane Shot and Steady Shot damage by 9%.|r"
    }
},

{
    id = "spellBestialWrath",
    name = "buttonSpellBestialWrath",
    icon = "Interface/icons/ability_druid_ferociousbite",
    position = {478, -240},
    handler = "spellbestialwrath",
    tooltips = {
        frFR = "|cffffffffCourroux bestial|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Votre familier, fou de rage, inflige 50% de dégâts supplémentaires pendant 10 secondes.\nLorsqu’il est dans cet état, il n'éprouve ni pitié, ni remords, ni peur et ne peut plus être arrêté à moins d'être tué.|r",
        enUS = "|cffffffffBestial Wrath|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Your pet, overcome with rage, deals 50% increased damage for 10 seconds.\nWhile in this state, it is unstoppable unless killed.|r"
    }
},

{
    id = "spellCatlikeReflexes",
    name = "buttonSpellCatlikeReflexes",
    icon = "Interface/icons/ability_hunter_catlikereflexes",
    position = {98, -293},
    handler = "spellcatlikereflexes",
    tooltips = {
        frFR = "|cffffffffRéflexes félins|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente vos chances d'esquiver de 3% et celles de votre familier de 9% supplémentaires.\nDe plus, réduit le temps de recharge de votre technique Ordre de tuer de 30 sec.|r",
        enUS = "|cffffffffCatlike Reflexes|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases your dodge chance by 3% and your pet's by 9%. Additionally, reduces the cooldown of Kill Command by 30 seconds.|r"
    }
},

{
    id = "spellInvigoration",
    name = "buttonSpellInvigoration",
    icon = "Interface/icons/ability_hunter_invigeration",
    position = {205, -293},
    handler = "spellinvigoration",
    tooltips = {
        frFR = "|cffffffffRevigoration|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Quand votre familier réussit un coup critique avec une technique spéciale, vous avez 100% de chances de récupérer instantanément 1% de votre mana.|r",
        enUS = "|cffffffffInvigoration|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100When your pet scores a critical hit with a special ability, you have a 100% chance to instantly regain 1% of your mana.|r"
    }
},
{
    id = "spellSerpentsSwiftness",
    name = "buttonSpellSerpentsSwiftness",
    icon = "Interface/icons/ability_hunter_serpentswiftness",
    position = {315, -293},
    handler = "spellserpensswiftness",
    tooltips = {
        frFR = "|cffffffffRapidité du serpent|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente votre vitesse d'attaque en combat à distance de 20% et la vitesse d'attaque en mêlée de votre familier de 20%.|r",
        enUS = "|cffffffffSerpent's Swiftness|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases your ranged attack speed by 20% and your pet's melee attack speed by 20%.|r"
    }
},

{
    id = "spellLongevity",
    name = "buttonSpellLongevity",
    icon = "Interface/icons/ability_hunter_longevity",
    position = {422, -293},
    handler = "spelllongevity",
    tooltips = {
        frFR = "|cffffffffLongévité|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Réduit le temps de recharge de Courroux bestial, Intimidation et des techniques spéciales de familier de 30%.|r",
        enUS = "|cffffffffLongevity|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Reduces the cooldown of Bestial Wrath, Intimidation, and your pet's special abilities by 30%.|r"
    }
},

{
    id = "spellTheBeastWithin",
    name = "buttonSpellTheBeastWithin",
    icon = "Interface/icons/ability_hunter_beastwithin",
    position = {527, -295},
    handler = "spellthebeastwithin",
    tooltips = {
        frFR = "|cffffffffLa bête intérieure|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente tous les dégâts que vous infligez de 10% et lorsque votre familier est sous l'effet de Courroux bestial, vous aussi devenez fou de rage.\nVous infligez 10% de dégâts supplémentaires et le coût en mana de tous vos sorts est réduit de 50% pendant 10 secondes.\nTant que vous êtes dans cet état, vous n'éprouvez ni pitié, ni remords, ni peur, et vous ne pouvez plus être arrêté à moins d'être tué.|r",
        enUS = "|cffffffffThe Beast Within|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases all damage you deal by 10%. When your pet is under the effect of Bestial Wrath, you also become enraged.\nYou deal 10% increased damage and all of your spells' mana cost is reduced by 50% for 10 seconds.\nWhile in this state, you feel no pity, remorse, or fear, and cannot be stopped unless killed.|r"
    }
},

{
    id = "spellCobraStrikes",
    name = "buttonSpellCobraStrikes",
    icon = "Interface/icons/ability_hunter_cobrastrikes",
    position = {43, -350},
    handler = "spellcobrastrikes",
    tooltips = {
        frFR = "|cffffffffFrappes de cobra|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Lorsque vous réussissez un coup critique avec Tir des arcanes, Tir assuré ou Tir mortel, vous avez 60% de chances de permettre aux 2 prochaines attaques spéciales de votre familier d'être des coups critiques.|r",
        enUS = "|cffffffffCobra Strikes|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100When you score a critical hit with Arcane Shot, Steady Shot, or Chimera Shot, you have a 60% chance to make your pet's next 2 special attacks critical hits.|r"
    }
},

{
    id = "spellKindredSpirits",
    name = "buttonSpellKindredSpirits",
    icon = "Interface/icons/ability_hunter_separationanxiety",
    position = {150, -350},
    handler = "spellkindredspirits",
    tooltips = {
        frFR = "|cffffffffAmes soeurs|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente les dégâts infligés par votre familier de 20% et la vitesse de déplacement de votre familier ainsi que la vôtre de 10% tant que votre familier est actif.\nNe se cumule pas avec les autres effets qui augmentent la vitesse de déplacement.|r",
        enUS = "|cffffffffKindred Spirits|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases your pet's damage by 20% and both your and your pet's movement speed by 10% while your pet is active.\nDoes not stack with other movement speed increasing effects.|r"
    }
},
{
    id = "spellBeastMastery",
    name = "buttonSpellBeastMastery",
    icon = "Interface/icons/ability_hunter_beastmastery",
    position = {260, -350},
    handler = "spellbeastmastery",
    tooltips = {
        frFR = "|cffffffffMaîtrise des bêtes|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vous maîtrisez l'art de la maîtrise des bêtes, ce qui vous permet de dompter les familiers exotiques et augmente votre montant total de points en compétence de familiers de 4.|r",
        enUS = "|cffffffffBeast Mastery|r\n|cffffffffTalent|r |cff0067ceBeast Mastery|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100You master the art of Beast Mastery, allowing you to tame exotic pets and increasing your total pet skill points by 4.|r"
    }
},

{
    id = "spellImprovedConcussiveShot",
    name = "buttonSpellImprovedConcussiveShot",
    icon = "Interface/icons/spell_frost_stun",
    position = {368, -350},
    handler = "spellimprovedconcussiveshot",
    tooltips = {
        frFR = "|cffffffffTrait de choc amélioré|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente la durée de l'effet d'hébétement de votre Trait de choc de 2 sec.|r",
        enUS = "|cffffffffImproved Concussive Shot|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases the stun effect duration of your Concussive Shot by 2 seconds.|r"
    }
},

{
    id = "spellFocusedAim",
    name = "buttonSpellFocusedAim",
    icon = "Interface/icons/ability_hunter_focusedaim",
    position = {478, -350},
    handler = "spellfocusedaim",
    tooltips = {
        frFR = "|cffffffffVisée focalisée|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Réduit de 70% l'interruption causée par les attaques infligeant des dégâts pendant que vous lancez Tir assuré et augmente de 3% les chances de toucher.|r",
        enUS = "|cffffffffFocused Aim|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Reduces the interruption caused by damage-dealing attacks while casting Steady Shot by 70% and increases your hit chance by 3%.|r"
    }
},

-- CreateSpellButton("buttonSpellImprovedAspectoftheHawk", "Interface/icons/spell_nature_ravenform", "|cffffffffAspect du faucon amélioré|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Pendant qu'Aspect du faucon ou Aspect du faucon-dragon est activé, toutes les attaques à distance normales ont 10% de chances d'augmenter la vitesse d'attaque à distance de 15% pendant 12 secondes.|r", "spellimprovedaspectofthehawk", 100, -80)
-- CreateSpellButton("buttonSpellEnduranceTraining", "Interface/icons/spell_nature_reincarnation", "|cffffffffEntraînement à l'Endurance|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente les points de vie de votre familier de 10% et votre total de points de vie de 5%.|r", "spellendurancetraining", 205, -75)
-- CreateSpellButton("buttonSpellFocusedFire", "Interface/icons/ability_hunter_silenthunter", "|cffffffffSurvie focalisé|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Tous les dégâts que vous infligez sont augmentés de 2% tant que votre familier est actif et les chances de coup critique des techniques spéciales de votre familier sont augmentées de 20% tant qu'Ordre de tuer est actif.|r", "spellfocusedfire", 315, -75)
-- CreateSpellButton("buttonSpellImprovedAspectoftheMonkey", "Interface/icons/ability_hunter_aspectofthemonkey", "|cffffffffAspect du singe amélioré|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente le bonus d'Esquive conféré par Aspect du singe ou votre Aspect du faucon-dragon de 6%.|r", "spellimprovedaspectofthemonkey", 418, -80)
-- CreateSpellButton("buttonSpellThickHide", "Interface/icons/inv_misc_pelt_bear_03", "|cffffffffPeau épaisse|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente le score d'armure de vos familiers de 20% et la valeur d'armure que vous apportent les objets de 10%.|r", "spellthickhide", 45, -130)
-- CreateSpellButton("buttonSpellImprovedRevivePet", "Interface/icons/ability_hunter_beastsoothe", "|cffffffffRessusciter le familier amélioré|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Le temps d'incantation du sort Ressusciter le familier est réduit de 6 sec., son coût en mana est diminué de 40% et le familier revient avec 30% de points de vie supplémentaires.|r", "spellimprovedrevivepet", 150, -130)
-- CreateSpellButton("buttonSpellPathfinding", "Interface/icons/ability_mount_jungletiger", "|cffffffffScience des chemins|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente le bonus de vitesse de vos Aspects de la meute et du guépard de 8% et augmente la vitesse de votre monture de 10%.\nNe se cumule pas avec les autres effets d'augmentation de vitesse de la monture.|r", "spellpathfinding", 260, -130)
-- CreateSpellButton("buttonSpellAspectMastery", "Interface/icons/ability_hunter_aspectmastery", "|cffffffffMaîtrise des aspects|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Aspect de la vipère - Réduit la pénalité aux dégâts de 10%.\nAspect du singe - Réduit les dégâts que vous subissez pendant qu'il est actif de 5%.\nAspect du faucon - Augmente le bonus à la puissance d'attaque de 30%.\nAspect du faucon-dragon - Combine les bonus des aspects du singe et du faucon.|r", "spellaspectmastery", 370, -130)
-- CreateSpellButton("buttonSpellUnleashedFury", "Interface/icons/ability_bullrush", "|cffffffffFureur libérée|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente les dégâts infligés par vos familiers de 15%.|r", "spellunleashedfury", 475, -133)
-- CreateSpellButton("buttonSpellImprovedMendPet", "Interface/icons/ability_hunter_mendpet", "|cffffffffGuérison du familier améliorée|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Réduit le coût en mana de votre sort Guérison du familier de 20% et lui donne 50% de chances de faire disparaître 1 effet de malédiction, maladie, magie ou poison du familier à chaque itération.|r", "spellimprovedmendpet", 96, -185)
-- CreateSpellButton("buttonSpellFerocity", "Interface/icons/inv_misc_monsterclaw_04", "|cffffffffFerocité|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente de 10% les chances de votre familier d'infliger un coup critique.|r", "spellferocity", 205, -185)
-- CreateSpellButton("buttonSpellSpiritBond", "Interface/icons/ability_druid_demoralizingroar", "|cffffffffEngagement spirituel|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Tant que votre familier est actif, vous et votre familier retrouvez 2% du total de vos points de vie toutes les 10 sec., et les soins prodigués à vous-même et à votre familier sont augmentés de 10%.|r", "spellspiritbond", 315, -185)
-- CreateSpellButton("buttonSpellIntimidation", "Interface/icons/ability_devour", "|cffffffffIntimidation|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Ordonne à votre familier d'intimider la cible, générant un niveau élevé de menace et étourdissant la cible pendant 3 seconds.\nDure 15 seconds.|r", "spellintimidation", 422, -185)
-- CreateSpellButton("buttonSpellBestialDisciplinet", "Interface/icons/spell_nature_abolishmagic", "|cffffffffDiscipline bestiale|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente de 100% la régénération de focalisation de vos Familiers.|r", "spellbestialdiscipline", 527, -190)
-- CreateSpellButton("buttonSpellAnimalHandler", "Interface/icons/ability_hunter_animalhandler", "|cffffffffDresseur|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente de 10% la puissance d'attaque de votre familier et augmente la durée de l'effet d'Appel du maître de 6 sec.", "spellanimalhandler", 43, -240)
-- CreateSpellButton("buttonSpellFrenzy", "Interface/icons/inv_misc_monsterclaw_03", "|cffffffffFrénésie|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Confère à votre familier 100% de chances de bénéficier d'un bonus de 30% à la vitesse d'attaque pendant 8 seconds après qu'il a infligé un coup critique.|r", "spellfrenzy", 150, -240)
-- CreateSpellButton("buttonSpellFerociousInspiration", "Interface/icons/ability_hunter_ferociousinspiration", "|cffffffffInspiration féroce|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Tous les membres du groupe ou du raid voient tous leurs dégâts augmenter de 3% quand ils sont à moins de 100 mètres de votre familier.\nDe plus, augmente les dégâts infligés par Tir des arcanes et Tir assuré de 9%.|r", "spellferociousinspiration", 368, -240)
-- CreateSpellButton("buttonSpellBestialWrath", "Interface/icons/ability_druid_ferociousbite", "|cffffffffCourroux bestial|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Votre familier, fou de rage, inflige 50% de points de dégâts supplémentaires pendant 10 seconds.\nLorsqu’il est dans cet état, il n'éprouve ni pitié, ni remords, ni peur et ne peut plus être arrêté à moins d'être tué.|r", "spellbestialwrath", 478, -240)
-- CreateSpellButton("buttonSpellCatlikeReflexes", "Interface/icons/ability_hunter_catlikereflexes", "|cffffffffRéflexes félins|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente vos chances d'esquiver de 3% et celles de votre familier de 9% supplémentaires.\nDe plus, réduit le temps de recharge de votre technique Ordre de tuer de 30 sec.|r", "spellcatlikereflexes", 98, -293)
-- CreateSpellButton("buttonSpellInvigoration", "Interface/icons/ability_hunter_invigeration", "|cffffffffRevigoration|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Quand votre familier réussit un coup critique avec une technique spéciale, vous avez 100% de chances de récupérer instantanément 1% de votre mana.|r", "spellinvigoration", 205, -293)
-- CreateSpellButton("buttonSpellSerpentsSwiftness", "Interface/icons/ability_hunter_serpentswiftness", "|cffffffffRapidité du serpent|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente votre vitesse d'attaque en combat à distance de 20% et la vitesse d'attaque en mêlée de votre familier de 20%.|r", "spellserpensswiftness", 315, -293)
-- CreateSpellButton("buttonSpellLongevity", "Interface/icons/ability_hunter_longevity", "|cffffffffLongévité|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Réduit le temps de recharge de Courroux bestial, Intimidation et des techniques spéciales de familier de 30%.|r", "spelllongevity", 422, -293)
-- CreateSpellButton("buttonSpellTheBeastWithin", "Interface/icons/ability_hunter_beastwithin", "|cffffffffLa bête intérieure|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente tous les dégâts que vous infligez de 10% et lorsque votre familier est sous l'effet de Courroux bestial, vous aussi devenez fou de rage.\nVous infligez 10% de points de dégâts supplémentaires et le coût en mana de tous vos sorts est réduit de 50% pendant 10 seconds.\nTant que vous êtes dans cet état, vous n'éprouvez ni pitié, ni remords, ni peur, et vous ne pouvez plus être arrêté à moins d'être tué.|r", "spellthebeastwithin", 527, -295)
-- CreateSpellButton("buttonSpellCobraStrikes", "Interface/icons/ability_hunter_cobrastrikes", "|cffffffffFrappes de cobra|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Lorsque vous réussissez un coup critique avec Tir des arcanes, Tir assuré ou Tir mortel, vous avez 60% de chances de permettre aux 2 prochaines attaques spéciales de votre familier d'être des coups critiques.|r", "spellcobrastrikes", 43, -350)
-- CreateSpellButton("buttonSpellKindredSpirits", "Interface/icons/ability_hunter_separationanxiety", "|cffffffffAmes soeurs|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente les dégâts infligés par votre familier de 20% et la vitesse de déplacement de votre familier ainsi que la vôtre de 10% tant que votre familier est actif.\nNe se cumule pas avec les autres effets qui augmentent la vitesse de déplacement.|r", "spellkindredspirits", 150, -350)
-- CreateSpellButton("buttonSpellBeastMastery|r", "Interface/icons/ability_hunter_beastmastery", "|cffffffffMaîtrise des bêtes|r\n|cffffffffTalent|r |cff0067ceMaitrise des Bêtes|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vous maîtrisez l'art de la maîtrise des bêtes, ce qui vous permet de dompter les familiers exotiques et augmente votre montant total de points en compétence de familiers de 4.|r", "spellbeastmastery", 260, -350)
-- CreateSpellButton("buttonSpellImprovedConcussiveShot", "Interface/icons/spell_frost_stun", "|cffffffffTrait de choc amélioré|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente la durée de l'effet d'hébétement de votre Trait de choc de 2 sec.|r", "spellimprovedconcussiveshot", 368, -350)
-- CreateSpellButton("buttonSpellFocusedAim", "Interface/icons/ability_hunter_focusedaim", "|cffffffffVisée focalisée|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Réduit de 70% l'interruption causée par les attaques infligeant des dégâts pendant que vous lancez Tir assuré et augmente de 3% les chances de toucher.|r", "spellfocusedaim", 478, -350)

-- Précision

{
    id = "spellLethalShots",
    name = "buttonSpellLethalShots",
    icon = "Interface/icons/ability_searingarrow",
    position = {98, -405},
    handler = "spelllethalshots",
    tooltips = {
        frFR = "|cffffffffCoups fatals|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente vos chances d'infliger un coup critique avec vos armes à distance de 5%.|r",
        enUS = "|cffffffffLethal Shots|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases your chance to score a critical hit with ranged weapons by 5%.|r"
    }
},

{
    id = "spellCarefulAim",
    name = "buttonSpellCarefulAim",
    icon = "Interface/icons/ability_hunter_zenarchery",
    position = {205, -405},
    handler = "spellcarefulaim",
    tooltips = {
        frFR = "|cffffffffVisée minutieuse|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente votre puissance d'attaque à distance d'un montant égal à 100% de votre total d'Intelligence.|r",
        enUS = "|cffffffffCareful Aim|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases your ranged attack power by an amount equal to 100% of your total Intelligence.|r"
    }
},

{
    id = "spellImprovedHuntersMark",
    name = "buttonSpellImprovedHuntersMark",
    icon = "Interface/icons/ability_hunter_snipershot",
    position = {315, -405},
    handler = "spellimprovedhuntersmark",
    tooltips = {
        frFR = "|cffffffffMarque du chasseur améliorée|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente le bonus à la puissance d'attaque conféré par votre technique Marque du chasseur de 30% et réduit le coût en mana de votre technique Marque du chasseur de 100%.|r",
        enUS = "|cffffffffImproved Hunter's Mark|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases the attack power bonus granted by your Hunter's Mark by 30% and reduces its mana cost by 100%.|r"
    }
},

{
    id = "spellMortalShots",
    name = "buttonSpellMortalShots",
    icon = "Interface/icons/ability_piercedamage",
    position = {422, -405},
    handler = "spellmortalshots",
    tooltips = {
        frFR = "|cffffffffCoups mortels|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente le bonus de dégâts de vos coups critiques avec vos techniques à distance de 30%.|r",
        enUS = "|cffffffffMortal Shots|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases the damage bonus of your critical strikes with ranged abilities by 30%.|r"
    }
},

{
    id = "spellGofortheThroat",
    name = "buttonSpellGofortheThroat",
    icon = "Interface/icons/ability_hunter_goforthethroat",
    position = {43, -458},
    handler = "spellgoforthethroat",
    tooltips = {
        frFR = "|cffffffffA la gorge|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vos coups critiques à distance font générer à votre familier 50 points de focalisation.|r",
        enUS = "|cffffffffGo for the Throat|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Your ranged critical strikes cause your pet to generate 50 focus points.|r"
    }
},
{
    id = "spellImprovedArcaneShot",
    name = "buttonSpellImprovedArcaneShot",
    icon = "Interface/icons/ability_impalingbolt",
    position = {150, -458},
    handler = "spellimprovedarcaneshot",
    tooltips = {
        frFR = "|cffffffffTir des arcanes amélioré|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente les dégâts infligés par votre Tir des arcanes de 15%.|r",
        enUS = "|cffffffffImproved Arcane Shot|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases the damage dealt by your Arcane Shot by 15%.|r"
    }
},

{
    id = "spellAimedShot",
    name = "buttonSpellAimedShot",
    icon = "Interface/icons/inv_spear_07",
    position = {260, -458},
    handler = "spellaimedshot",
    tooltips = {
        frFR = "|cffffffffVisée|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Un tir précis qui augmente les points de dégâts infligés par votre attaque à distance de 5 et réduit les soins prodigués à cette cible de 50%.\nDure 10 secondes.|r",
        enUS = "|cffffffffAimed Shot|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100A precise shot that increases the damage done by your ranged attack by 5 and reduces the healing done to that target by 50%. Lasts 10 seconds.|r"
    }
},

{
    id = "spellRapidKilling",
    name = "buttonSpellRapidKilling",
    icon = "Interface/icons/ability_hunter_rapidkilling",
    position = {368, -458},
    handler = "spellrapidkilling",
    tooltips = {
        frFR = "|cffffffffTueur rapide|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Réduit le temps de recharge de votre technique Tir rapide de 2 min.\nDe plus, lorsque vous tuez un adversaire qui vous rapporte de l'expérience ou de l'honneur, votre prochaine utilisation de Visée, Tir des arcanes ou Tir de la chimère inflige 20% de dégâts supplémentaires.\nDure 20 secondes.|r",
        enUS = "|cffffffffRapid Killing|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Reduces the cooldown of your Rapid Fire by 2 min.\nAdditionally, when you kill an enemy that grants experience or honor, your next use of Aimed Shot, Arcane Shot, or Chimera Shot will deal 20% more damage. Lasts 20 seconds.|r"
    }
},

{
    id = "spellImprovedStings",
    name = "buttonSpellImprovedStings",
    icon = "Interface/icons/ability_hunter_quickshot",
    position = {478, -458},
    handler = "spellimprovedstings",
    tooltips = {
        frFR = "|cffffffffMorsures et piqûres améliorées|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente les points de dégâts infligés par Morsure de serpent et Piqûre de wyverne de 30% et les points de mana drainés par votre Morsure de vipère de 30%.\nDe plus, réduit la probabilité que les effets de dégâts sur la durée de vos morsures et piqûres soient dissipés de 30%.|r",
        enUS = "|cffffffffImproved Stings|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases the damage dealt by your Serpent Sting and Wyvern Sting by 30% and the mana drained by your Viper Sting by 30%.\nAdditionally, reduces the chance that the damage over time effects of your stings are dispelled by 30%.|r"
    }
},

{
    id = "spellEfficiency",
    name = "buttonSpellEfficiency",
    icon = "Interface/icons/spell_frost_wizardmark",
    position = {98, -510},
    handler = "spellefficiency",
    tooltips = {
        frFR = "|cffffffffEfficacité|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Réduit le coût en mana de vos Tirs, Morsures et Piqûres de 15%.|r",
        enUS = "|cffffffffEfficiency|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Reduces the mana cost of your Shots, Stings, and Bites by 15%.|r"
    }
},
{
    id = "spellConcussiveBarrage",
    name = "buttonSpellConcussiveBarrage",
    icon = "Interface/icons/spell_arcane_starfire",
    position = {205, -510},
    handler = "spellconcussivebarrage",
    tooltips = {
        frFR = "|cffffffffBarrage commotionnant|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vos attaques réussies avec Tir de la chimère et Flèches multiples vous confèrent 100% de chances d'hébéter la cible pendant 4 secondes.|r",
        enUS = "|cffffffffConcussive Barrage|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Your successful Chimera Shot and Multi-Shot attacks have a 100% chance to stun the target for 4 seconds.|r"
    }
},

{
    id = "spellReadiness",
    name = "buttonSpellReadiness",
    icon = "Interface/icons/ability_hunter_readiness",
    position = {315, -510},
    handler = "spellreadiness",
    tooltips = {
        frFR = "|cffffffffPromptitude|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Quand elle est activée, cette technique met immédiatement fin au temps de recharge de vos autres techniques de chasseur, sauf Courroux bestial.|r",
        enUS = "|cffffffffReadiness|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100When activated, this ability immediately resets the cooldown of your other hunter abilities, except Bestial Wrath.|r"
    }
},

{
    id = "spellBarrage",
    name = "buttonSpellBarrage",
    icon = "Interface/icons/ability_upgrademoonglaive",
    position = {422, -510},
    handler = "spellbarrage",
    tooltips = {
        frFR = "|cffffffffBarrage|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente les dégâts infligés par vos sorts Flèches multiples, Visée et Salve de 12%.|r",
        enUS = "|cffffffffBarrage|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases the damage dealt by your Multi-Shot, Aimed Shot, and Barrage abilities by 12%.|r"
    }
},

-- CreateSpellButton("buttonSpellLethalShots", "Interface/icons/ability_searingarrow", "|cffffffffCoups fatals|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente vos chances d'infliger un coup critique avec vos armes à distance de 5%.|r", "spelllethalshots", 98, -405)
-- CreateSpellButton("buttonSpellCarefulAim", "Interface/icons/ability_hunter_zenarchery", "|cffffffffVisée minutieuse|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente votre puissance d'attaque à distance d'un montant égal à 100% de votre total d'Intelligence.|r", "spellcarefulaim", 205, -405)
-- CreateSpellButton("buttonSpellImprovedHuntersMark", "Interface/icons/ability_hunter_snipershot", "|cffffffffMarque du chasseur améliorée|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente le bonus à la puissance d'attaque conféré par votre technique Marque du chasseur de 30% et réduit le coût en mana de votre technique Marque du chasseur de 100%.|r", "spellimprovedhuntersmark", 315, -405)
-- CreateSpellButton("buttonSpellMortalShots", "Interface/icons/ability_piercedamage", "|cffffffffCoups mortels|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente le bonus de dégâts de vos coups critiques avec vos techniques à distance de 30%.|r", "spellmortalshots", 422, -405)
-- CreateSpellButton("buttonSpellGofortheThroat", "Interface/icons/ability_hunter_goforthethroat", "|cffffffffA la gorge|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vos coups critiques à distance font générer à votre familier 50 points de focalisation.|r", "spellgoforthethroat", 43, -458)
-- CreateSpellButton("buttonSpellImprovedArcaneShot", "Interface/icons/ability_impalingbolt", "|cffffffffTir des arcanes amélioré|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente les dégâts infligés par votre Tir des arcanes de 15%.|r", "spellimprovedarcaneshot", 150, -458)
-- CreateSpellButton("buttonSpellAimedShot", "Interface/icons/inv_spear_07", "|cffffffffVisée|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Un tir précis qui augmente les points de dégâts infligés par votre attaque à distance de 5 et réduit les soins prodigués à cette cible de 50%.\nDure 10 secondes.|r", "spellaimedshot", 260, -458)
-- CreateSpellButton("buttonSpellRapidKilling", "Interface/icons/ability_hunter_rapidkilling", "|cffffffffTueur rapide|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Réduit le temps de recharge de votre technique Tir rapide de 2 min.\nDe plus, lorsque vous tuez un adversaire qui vous rapporte de l'expérience ou de l'honneur, votre prochaine utilisation de Visée, Tir des arcanes ou Tir de la chimère inflige 20% de dégâts supplémentaires.\nDure 20 secondes.|r", "spellrapidkilling", 368, -458)
-- CreateSpellButton("buttonSpellImprovedStings", "Interface/icons/ability_hunter_quickshot", "|cffffffffMorsures et piqûres améliorées|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente les points de dégâts infligés par Morsure de serpent et Piqûre de wyverne de 30% et les points de mana drainés par votre Morsure de vipère de 30%.\nDe plus, réduit la probabilité que les effets de dégâts sur la durée de vos morsures et piqûres soient dissipés de 30%.|r", "spellimprovedstings", 478, -458)
-- CreateSpellButton("buttonSpellEfficiency", "Interface/icons/spell_frost_wizardmark", "|cffffffffEfficacité|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Réduit le coût en mana de vos Tirs, Morsures et Piqûres de 15%.|r", "spellefficiency", 98, -510)
-- CreateSpellButton("buttonSpellConcussiveBarrage", "Interface/icons/spell_arcane_starfire", "|cffffffffBarrage commotionnant|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vos attaques réussies avec Tir de la chimère et Flèches multiples vous confèrent 100% de chances d'hébéter la cible pendant 4 secondes.|r", "spellconcussivebarrage", 205, -510)
-- CreateSpellButton("buttonSpellReadiness", "Interface/icons/ability_hunter_readiness", "|cffffffffPromptitude|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Quand elle est activée, cette technique met immédiatement fin au temps de recharge de vos autres techniques de chasseur, sauf Courroux bestial.|r", "spellreadiness", 315, -510)
-- CreateSpellButton("buttonSpellBarrage", "Interface/icons/ability_upgrademoonglaive", "|cffffffffBarrage|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente les dégâts infligés par vos sorts Flèches multiples, Visée et Salve de 12%.|r", "spellbarrage", 422, -510)

-- Template 2

{
    id = "spellCombatExperience",
    name = "buttonSpellCombatExperience",
    icon = "Interface/icons/ability_hunter_combatexperience",
    position = {663, -75},
    handler = "spellcombatexperience",
    tooltips = {
        frFR = "|cffffffffExpérience du combat|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente votre total d'Agilité et votre total d'Intelligence de 4%.|r",
        enUS = "|cffffffffCombat Experience|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases your total Agility and Intelligence by 4%.|r"
    }
},

{
    id = "spellRangedWeaponSpecialization",
    name = "buttonSpellRangedWeaponSpecialization",
    icon = "Interface/icons/inv_weapon_rifle_06",
    position = {770, -75},
    handler = "spellrangedweaponspecialization",
    tooltips = {
        frFR = "|cffffffffSpécialisation Armes à distance|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente les points de dégâts que vous infligez avec les armes à distance de 5%.|r",
        enUS = "|cffffffffRanged Weapon Specialization|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases the damage dealt by your ranged weapons by 5%.|r"
    }
},

{
    id = "spellPiercingShots",
    name = "buttonSpellPiercingShots",
    icon = "Interface/icons/ability_hunter_piercingshots",
    position = {880, -75},
    handler = "spellpiercingshots",
    tooltips = {
        frFR = "|cffffffffTirs perforants|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vos critiques réussis avec Visée, Tir assuré et Tir de la chimère font saigner la cible, qui perd un montant de points de vie égal à 30% des dégâts infligés en 8 secondes.|r",
        enUS = "|cffffffffPiercing Shots|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Your successful critical strikes with Aimed Shot, Steady Shot, and Chimera Shot cause the target to bleed, taking damage equal to 30% of the damage dealt over 8 seconds.|r"
    }
},

{
    id = "spellTrueshotAura",
    name = "buttonSpellTrueshotAura",
    icon = "Interface/icons/ability_trueshot",
    position = {990, -75},
    handler = "spelltrueshotaura",
    tooltips = {
        frFR = "|cffffffffAura de précision|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente de 10% la puissance d'attaque des membres du groupe ou du raid qui se trouvent dans un rayon de 100 mètres.\nDure jusqu'à annulation.|r",
        enUS = "|cffffffffTrueshot Aura|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases the attack power of party or raid members within 100 yards by 10%. Lasts until cancelled.|r"
    }
},

{
    id = "spellImprovedBarrage",
    name = "buttonSpellImprovedBarrage",
    icon = "Interface/icons/ability_upgrademoonglaive",
    position = {1100, -75},
    handler = "spellimprovedbarrage",
    tooltips = {
        frFR = "|cffffffffBarrage amélioré|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente vos chances de réaliser un coup critique avec vos techniques Flèches multiples et Visée de 12% et réduit de 100% les interruptions causées par les attaques infligeant des dégâts pendant que vous canalisez Salve.|r",
        enUS = "|cffffffffImproved Barrage|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases your critical strike chance with Multi-Shot and Aimed Shot by 12% and removes all interruptions caused by damage when channeling Barrage.|r"
    }
},
{
    id = "spellMasterMarksman",
    name = "buttonSpellMasterMarksman",
    icon = "Interface/icons/ability_hunter_mastermarksman",
    position = {718, -130},
    handler = "spellmastermarksman",
    tooltips = {
        frFR = "|cffffffffMaître tireur|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente vos chances de coup critique de 5% et réduit le coût en mana de votre Tir assuré, Visée et Tir de la chimère de 25%.|r",
        enUS = "|cffffffffMaster Marksman|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases your critical strike chance by 5% and reduces the mana cost of your Steady Shot, Aimed Shot, and Chimera Shot by 25%.|r"
    }
},

{
    id = "spellRapidRecuperation",
    name = "buttonSpellRapidRecuperation",
    icon = "Interface/icons/ability_hunter_rapidregeneration",
    position = {825, -130},
    handler = "spellrapidrecuperation",
    tooltips = {
        frFR = "|cffffffffRecouvrement rapide|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vous recevez 4% de votre mana toutes les 3 sec.\nquand vous êtes sous l'effet de Tir rapide, et vous recevez 2% de votre mana toutes les 2 sec.\npendant 6 secondes quand vous bénéficiez de Tueur rapide.|r",
        enUS = "|cffffffffRapid Recuperation|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100You regenerate 4% of your mana every 3 seconds while Rapid Fire is active, and 2% of your mana every 2 seconds for 6 seconds after killing an enemy with Rapid Killing.|r"
    }
},

{
    id = "spellWildQuiver",
    name = "buttonSpellWildQuiver",
    icon = "Interface/icons/ability_hunter_wildquiver",
    position = {935, -130},
    handler = "spellwildquiver",
    tooltips = {
        frFR = "|cffffffffCarquois sauvage|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vous avez 12% de chances de réaliser un tir supplémentaire lorsque vous infligez des dégâts avec votre tir automatique, infligeant 80% des dégâts de l'arme sous forme de dégâts de Nature.\nCarquois sauvage ne consomme pas de munitions.|r",
        enUS = "|cffffffffWild Quiver|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100You have a 12% chance to fire an additional shot when dealing damage with your Auto Shot, dealing 80% weapon damage as Nature damage. Wild Quiver does not consume ammunition.|r"
    }
},

{
    id = "spellSilencingShot",
    name = "buttonSpellSilencingShot",
    icon = "Interface/icons/ability_theblackarrow",
    position = {1045, -130},
    handler = "spellsilencingshot",
    tooltips = {
        frFR = "|cffffffffFlèche-bâillon|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Un tir qui inflige 50% des dégâts de l'arme et réduit la cible au silence pendant 3 secondes.\nLes incantations de sorts des victimes personnages non joueurs sont également interrompues pendant 3 secondes.|r",
        enUS = "|cffffffffSilencing Shot|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100A shot that deals 50% weapon damage and silences the target for 3 seconds. NPC spell casts are also interrupted for 3 seconds.|r"
    }
},

{
    id = "spellImprovedSteadyShot",
    name = "buttonSpellImprovedSteadyShot",
    icon = "Interface/icons/ability_hunter_improvedsteadyshot",
    position = {663, -184},
    handler = "spellimprovedsteadyshot",
    tooltips = {
        frFR = "|cffffffffTir assuré amélioré|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vos Tirs assurés réussis ont 15% de chances d'augmenter les dégâts infligés par votre prochaine utilisation de Visée,\nTir des arcanes ou Tir de la chimère de 15%, ainsi que de réduire le coût en mana de votre prochaine utilisation de Visée, Tir des arcanes ou Tir de la chimère de 20%.|r",
        enUS = "|cffffffffImproved Steady Shot|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Your successful Steady Shots have a 15% chance to increase the damage of your next Aimed Shot, Arcane Shot, or Chimera Shot by 15%, and reduce the mana cost of your next Aimed Shot, Arcane Shot, or Chimera Shot by 20%.|r"
    }
},
{
    id = "spellMarkedforDeath",
    name = "buttonSpellMarkedforDeath",
    icon = "Interface/icons/ability_hunter_assassinate",
    position = {770, -184},
    handler = "spellmarkedfordeath",
    tooltips = {
        frFR = "|cffffffffDésigné pour mourir|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente de 5% les dégâts infligés par vos tirs et par les techniques spéciales de votre familier sur les cibles marquées\net augmente de 10% le bonus aux dégâts des coups critiques de Visée, Tir des arcanes, Tir assuré, Tir mortel et Tir de la chimère.|r",
        enUS = "|cffffffffMarked for Death|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases the damage dealt by your shots and your pet's special abilities on marked targets by 5%, and increases the critical strike damage bonus of Aimed Shot, Arcane Shot, Steady Shot, Kill Shot, and Chimera Shot by 10%.|r"
    }
},

{
    id = "spellChimeraShot",
    name = "buttonSpellChimeraShot",
    icon = "Interface/icons/ability_hunter_chimerashot2",
    position = {880, -184},
    handler = "spellchimerashot",
    tooltips = {
        frFR = "|cffffffffTir de la chimère|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vous infligez 125% des dégâts de l'arme, réinitialisez la piqûre ou morsure actuelle sur votre cible et déclenchez un effet : Morsure de serpent - Inflige instantanément 40% des dégâts de votre Morsure de serpent.|r",
        enUS = "|cffffffffChimera Shot|r\n|cffffffffTalent|r |cffff8040Precision|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100You deal 125% weapon damage, reset the current sting or bite on your target, and trigger an effect: Serpent Sting - Instantly deals 40% of your Serpent Sting damage.|r"
    }
},

{
    id = "spellImprovedTracking",
    name = "buttonSpellImprovedTracking",
    icon = "Interface/icons/ability_hunter_improvedtracking",
    position = {990, -184},
    handler = "spellimprovedtracking",
    tooltips = {
        frFR = "|cffffffffPistage amélioré|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Lorsque le chasseur piste les bêtes, les démons, les draconiens, les élémentaires, les géants, les humanoïdes ou les morts-vivants, tous les dégâts infligés à ce type de créatures sont augmentés de 5%.|r",
        enUS = "|cffffffffImproved Tracking|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100While tracking Beasts, Demons, Dragonkin, Elementals, Giants, Humanoids, or Undead, all damage dealt to those creatures is increased by 5%.|r"
    }
},

{
    id = "spellHawkEye",
    name = "buttonSpellHawkEye",
    icon = "Interface/icons/ability_townwatch",
    position = {1100, -184},
    handler = "spellhawkeye",
    tooltips = {
        frFR = "|cffffffffOeil de faucon|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente la portée de vos armes à distance de 6 mètres.|r",
        enUS = "|cffffffffHawk Eye|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases the range of your ranged weapons by 6 yards.|r"
    }
},

-- CreateSpellButton("buttonSpellCombatExperience", "Interface/icons/ability_hunter_combatexperience", "|cffffffffExpérience du combat|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente votre total d'Agilité et votre total d'Intelligence de 4%.|r", "spellcombatexperience", 663, -75)
-- CreateSpellButton("buttonSpellRangedWeaponSpecialization", "Interface/icons/inv_weapon_rifle_06", "|cffffffffSpécialisation Armes à distance|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente les points de dégâts que vous infligez avec les armes à distance de 5%.|r", "spellrangedweaponspecialization", 770, -75)
-- CreateSpellButton("buttonSpellPiercingShots", "Interface/icons/ability_hunter_piercingshots", "|cffffffffTirs perforants|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vos critiques réussis avec Visée, Tir assuré et Tir de la chimère font saigner la cible, qui perd un montant de points de vie égal à 30% des dégâts infligés en 8 seconds.|r", "spellpiercingshots", 880, -75)
-- CreateSpellButton("buttonSpellTrueshotAura", "Interface/icons/ability_trueshot", "|cffffffffAura de précision|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente de 10% la puissance d'attaque des membres du groupe ou du raid qui se trouvent dans un rayon de 100 mètres.\nDure jusqu'à annulation.|r", "spelltrueshotaura", 990, -75)
-- CreateSpellButton("buttonSpellImprovedBarrage", "Interface/icons/ability_upgrademoonglaive", "|cffffffffBarrage amélioré|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente vos chances de réaliser un coup critique avec vos techniques Flèches multiples et Visée de 12% et réduit de 100% les interruptions causées par les attaques infligeant des dégâts pendant que vous canalisez Salve.|r", "spellimprovedbarrage", 1100, -75)
-- CreateSpellButton("buttonSpellMasterMarksman", "Interface/icons/ability_hunter_mastermarksman", "|cffffffffMaître tireur|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente vos chances de coup critique de 5% et réduit le coût en mana de votre Tir assuré, Visée et Tir de la chimère de 25%.|r", "spellmastermarksman", 718, -130)
-- CreateSpellButton("buttonSpellRapidRecuperation", "Interface/icons/ability_hunter_rapidregeneration", "|cffffffffRecouvrement rapide|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vous recevez 4% de votre mana toutes les 3 sec.\nquand vous êtes sous l'effet de Tir rapide, et vous recevez 2% de votre mana toutes les 2 sec.\npendant 6 secondes quand vous bénéficiez de Tueur rapide.|r", "spellrapidrecuperation", 825, -130)
-- CreateSpellButton("buttonSpellWildQuiver", "Interface/icons/ability_hunter_wildquiver", "|cffffffffCarquois sauvage|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vous avez 12% de chances de réaliser un tir supplémentaire lorsque vous infligez des dégâts avec votre tir automatique, infligeant 80% des dégâts de l'arme sous forme de dégâts de Nature.\nCarquois sauvage ne consomme pas de munitions.|r", "spellwildquiver", 935, -130)
-- CreateSpellButton("buttonSpellSilencingShot", "Interface/icons/ability_theblackarrow", "|cffffffffFlèche-bâillon|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Un tir qui inflige 50% des dégâts de l'arme et réduit la cible au silence pendant 3 secondes.\nLes incantations de sorts des victimes personnages non joueurs sont également interrompues pendant 3 secondes.|r", "spellsilencingshot", 1045, -130)
-- CreateSpellButton("buttonSpellImprovedSteadyShot", "Interface/icons/ability_hunter_improvedsteadyshot", "|cffffffffTir assuré amélioré|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vos Tirs assurés réussis ont 15% de chances d'augmenter les dégâts infligés par votre prochaine utilisation de Visée,\nTir des arcanes ou Tir de la chimère de 15%, ainsi que de réduire le coût en mana de votre prochaine utilisation de Visée, Tir des arcanes ou Tir de la chimère de 20%.|r", "spellimprovedsteadyshot", 663, -184)
-- CreateSpellButton("buttonSpellMarkedforDeath", "Interface/icons/ability_hunter_assassinate", "|cffffffffDésigné pour mourir|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente de 5% les dégâts infligés par vos tirs et par les techniques spéciales de votre familier sur les cibles marquées\net augmente de 10% le bonus aux dégâts des coups critiques de Visée, Tir des arcanes, Tir assuré, Tir mortel et Tir de la chimère.|r", "spellmarkedfordeath", 770, -184)
-- CreateSpellButton("buttonSpellChimeraShot", "Interface/icons/ability_hunter_chimerashot2", "|cffffffffTir de la chimère|r\n|cffffffffTalent|r |cffff8040Précision|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vous infligez 125% des dégâts de l'arme, réinitialisez la piqûre ou morsure actuelle sur votre cible et déclenchez un effet : Morsure de serpent - Inflige instantanément 40% des dégâts de votre Morsure de serpent.|r", "spellchimerashot", 880, -184)
-- CreateSpellButton("buttonSpellImprovedTracking", "Interface/icons/ability_hunter_improvedtracking", "|cffffffffPistage amélioré|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Lorsque le chasseur piste les bêtes, les démons, les draconiens, les élémentaires, les géants, les humanoïdes ou les morts-vivants, tous les dégâts infligés à ce type de créatures sont augmentés de 5%.|r", "spellimprovedtracking", 990, -184)
-- CreateSpellButton("buttonSpellHawkEye", "Interface/icons/ability_townwatch", "|cffffffffOeil de faucon|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente la portée de vos armes à distance de 6 mètres.|r", "spellhawkeye", 1100, -184)


-- Survie

{
    id = "spellSavageStrikes",
    name = "buttonSpellSavageStrikes",
    icon = "Interface/icons/ability_racial_bloodrage",
    position = {718, -240},
    handler = "spellsavagestrikes",
    tooltips = {
        frFR = "|cffffffffFrappes sauvages|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente de 20% les chances d'infliger un coup critique avec Attaque du raptor, Morsure de la mangouste et Contre-attaque.|r",
        enUS = "|cffffffffSavage Strikes|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases your chance to deal a critical strike by 20% with Raptor Strike, Mongoose Bite, and Counterattack.|r"
    }
},

{
    id = "spellSurefooted",
    name = "buttonSpellSurefooted",
    icon = "Interface/icons/ability_kick",
    position = {825, -240},
    handler = "spellsurefooted",
    tooltips = {
        frFR = "|cffffffffPied sûr|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Diminue la durée des effets affectant le mouvement de 30%.|r",
        enUS = "|cffffffffSurefooted|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Reduces the duration of movement impairing effects by 30%.|r"
    }
},

{
    id = "spellEntrapment",
    name = "buttonSpellEntrapment",
    icon = "Interface/icons/spell_nature_stranglevines",
    position = {935, -240},
    handler = "spellentrapment",
    tooltips = {
        frFR = "|cffffffffPiège|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Lorsque votre Piège de givre ou Piège à serpent est déclenché, vous emprisonnez toutes les cibles affectées, les empêchant de se déplacer pendant 4 secondes.|r",
        enUS = "|cffffffffEntrapment|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100When your Freezing Trap or Snake Trap is triggered, all affected targets are entangled, preventing them from moving for 4 seconds.|r"
    }
},

{
    id = "spellTrapMastery",
    name = "buttonSpellTrapMastery",
    icon = "Interface/icons/ability_ensnare",
    position = {1045, -240},
    handler = "spelltrapmastery",
    tooltips = {
        frFR = "|cffffffffMaîtrise des pièges|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Piège de givre et Piège givrant - Augmente la durée de 30%.\nPiège d'immolation, Piège explosif et Flèche noire - Augmente les dégâts périodiques infligés de 30%.\nPiège à serpent - Augmente le nombre de serpents.|r",
        enUS = "|cffffffffTrap Mastery|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Freezing Trap and Frost Trap - Increases their duration by 30%.\nImmolation Trap, Explosive Trap, and Black Arrow - Increases periodic damage dealt by 30%.\nSnake Trap - Increases the number of snakes.|r"
    }
},

{
    id = "spellSurvivalInstincts",
    name = "buttonSpellSurvivalInstincts",
    icon = "Interface/icons/ability_hunter_survivalinstincts",
    position = {663, -293},
    handler = "spellsurvivalinstincts",
    tooltips = {
        frFR = "|cffffffffInstincts de survie|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Réduit tous les dégâts subis de 4% et augmente les chances de coup critique de vos Tirs des arcanes, Tirs assurés et Tirs explosifs de 4%.|r",
        enUS = "|cffffffffSurvival Instincts|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Reduces all damage taken by 4% and increases the critical strike chance of your Arcane Shot, Steady Shot, and Explosive Shot by 4%.|r"
    }
},
{
    id = "spellSurvivalist",
    name = "buttonSpellSurvivalist",
    icon = "Interface/icons/spell_shadow_twilight",
    position = {770, -293},
    handler = "spellsurvivalist",
    tooltips = {
        frFR = "|cffffffffSurvivant|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente votre Endurance de 10%.|r",
        enUS = "|cffffffffSurvivalist|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases your Stamina by 10%.|r"
    }
},

{
    id = "spellScatterShot",
    name = "buttonSpellScatterShot",
    icon = "Interface/icons/ability_golemstormbolt",
    position = {990, -293},
    handler = "spellscattershot",
    tooltips = {
        frFR = "|cffffffffFlèche de dispersion|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Un tir à courte distance qui inflige 50% des dégâts de l'arme et désoriente la cible pendant 4 secondes.\nSi la cible subit des dégâts, l'effet est annulé.\nInterrompt l'attaque lors de son utilisation.|r",
        enUS = "|cffffffffScatter Shot|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100A short-range shot that deals 50% weapon damage and disorients the target for 4 seconds.\nIf the target takes damage, the effect is cancelled.\nInterrupts the attack upon use.|r"
    }
},

{
    id = "spellDeflection",
    name = "buttonSpellDeflection",
    icon = "Interface/icons/ability_parry",
    position = {1100, -293},
    handler = "spelldeflection",
    tooltips = {
        frFR = "|cffffffffDéviation|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente vos chances de Parer de 3% et réduit la durée de tous les effets de désarmement sur vous de 50%.\nNon cumulable avec les autres effets qui réduisent la durée du désarmement.|r",
        enUS = "|cffffffffDeflection|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases your Parry chance by 3% and reduces the duration of all disarm effects on you by 50%.\nNot stackable with other disarm duration-reduction effects.|r"
    }
},

{
    id = "spellSurvivalTactics",
    name = "buttonSpellSurvivalTactics",
    icon = "Interface/icons/ability_rogue_feigndeath",
    position = {718, -348},
    handler = "spellsurvivaltactics",
    tooltips = {
        frFR = "|cffffffffTactique de survie|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Réduit la probabilité que l'on résiste à votre technique Feindre la mort et à tous vos sorts de pièges de 4% et réduit le temps de recharge de votre technique Désengagement de 4 sec.|r",
        enUS = "|cffffffffSurvival Tactics|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Reduces the chance for your Feign Death technique and all your trap spells to be resisted by 4% and reduces the cooldown of your Disengage ability by 4 seconds.|r"
    }
},

{
    id = "spellTNT",
    name = "buttonSpellTNT",
    icon = "Interface/icons/inv_misc_bomb_05",
    position = {825, -348},
    handler = "spelltnt",
    tooltips = {
        frFR = "|cffffffffT.N.T.|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente les dégâts infligés par votre Tir explosif, votre Piège explosif, votre Flèche noire et votre Piège d'immolation de 6%.|r",
        enUS = "|cffffffffT.N.T.|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases the damage dealt by your Explosive Shot, Explosive Trap, Black Arrow, and Immolation Trap by 6%.|r"
    }
},
{
    id = "spellLockandLoad",
    name = "buttonSpellLockandLoad",
    icon = "Interface/icons/ability_hunter_lockandload",
    position = {935, -348},
    handler = "spelllockandload",
    tooltips = {
        frFR = "|cffffffffPrêt à tirer|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vous avez 100% de chances lorsque vous piégez une cible avec Piège givrant, Flèche givrante ou Piège de givre et 6% de chances lorsque vous infligez des dégâts périodiques avec Piège d'immolation,\nPiège explosif ou Flèche noire que vos 2 prochains sorts Tir des arcanes ou Tir explosif ne déclenchent pas de temps de recharge, ne coûtent pas de mana et ne consomment pas de munitions.\nCet effet a un temps de recharge de 22 sec.|r",
        enUS = "|cffffffffLock and Load|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100You have a 100% chance when you trap a target with Freezing Trap, Frost Arrow or Frost Trap, and a 6% chance when you deal periodic damage with Immolation Trap, Explosive Trap, or Black Arrow, that your next 2 Arcane Shot or Explosive Shot will not trigger a cooldown, will not cost mana, and will not consume ammunition.\nThis effect has a cooldown of 22 seconds.|r"
    }
},

{
    id = "spellHuntervsWild",
    name = "buttonSpellHuntervsWild",
    icon = "Interface/icons/ability_hunter_huntervswild",
    position = {1045, -348},
    handler = "spellhuntervswild",
    tooltips = {
        frFR = "|cffffffffFace à la nature|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente votre puissance d'attaque et votre puissance d'attaque à distance, ainsi que celles de votre familier, d'un montant égal à 30% de votre total d'Endurance.|r",
        enUS = "|cffffffffHunter vs Wild|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases your Attack Power and Ranged Attack Power, as well as your pet's, by an amount equal to 30% of your total Stamina.|r"
    }
},

{
    id = "spellKillerInstinct",
    name = "buttonSpellKillerInstinct",
    icon = "Interface/icons/spell_holy_blessingofstamina",
    position = {663, -402},
    handler = "spellkillerinstinct",
    tooltips = {
        frFR = "|cffffffffInstinct du tueur|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente vos chances d'infliger un coup critique avec toutes vos attaques de 3%.|r",
        enUS = "|cffffffffKiller Instinct|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases your chance to critically strike with all your attacks by 3%.|r"
    }
},

{
    id = "spellImprovedBlizzard",
    name = "buttonSpellImprovedBlizzard",
    icon = "Interface/icons/spell_frost_icestorm",
    position = {770, -402},
    handler = "spellimprovedblizzard",
    tooltips = {
        frFR = "|cffffffffBlizzard amélioré|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Ajoute un effet d'engourdissement à votre sort Blizzard.\nIl réduit la vitesse de déplacement de la cible de 50%.\nDure 1.5 seconds.|r",
        enUS = "|cffffffffImproved Blizzard|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Adds a slowing effect to your Blizzard spell.\nIt reduces the target's movement speed by 50%.\nLasts for 1.5 seconds.|r"
    }
},

{
    id = "spellCounterattack",
    name = "buttonSpellCounterattack",
    icon = "Interface/icons/ability_warrior_challange",
    position = {880, -402},
    handler = "spellcounterattack",
    tooltips = {
        frFR = "|cffffffffContre-attaque|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Une attaque disponible après avoir paré une attaque de l'adversaire.\nElle inflige 1 point de dégâts et immobilise la cible pendant 5 secondes.\nContre-attaque ne peut pas être bloquée, esquivée ou parée.|r",
        enUS = "|cffffffffCounterattack|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100An attack available after parrying an opponent's attack.\nIt deals 1 damage and stuns the target for 5 seconds.\nCounterattack cannot be blocked, dodged, or parried.|r"
    }
},
{
    id = "spellLightningReflexes",
    name = "buttonSpellLightningReflexes",
    icon = "Interface/icons/spell_nature_invisibilty",
    position = {990, -402},
    handler = "spelllightningreflexes",
    tooltips = {
        frFR = "|cffffffffRéflexes éclairs|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente votre Agilité de 15%.|r",
        enUS = "|cffffffffLightning Reflexes|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases your Agility by 15%.|r"
    }
},

{
    id = "spellResourcefulness",
    name = "buttonSpellResourcefulness",
    icon = "Interface/icons/ability_hunter_resourcefulness",
    position = {1100, -402},
    handler = "spellresourcefulness",
    tooltips = {
        frFR = "|cffffffffRessource|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Réduit le coût en mana de tous les pièges et techniques de mêlée ainsi que de Flèche noire de 60% et réduit le temps de recharge de tous les pièges et de Flèche noire de 6 sec.|r",
        enUS = "|cffffffffResourcefulness|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Reduces the mana cost of all traps, melee abilities, and Black Arrow by 60% and reduces the cooldown of all traps and Black Arrow by 6 seconds.|r"
    }
},

{
    id = "spellExposeWeakness",
    name = "buttonSpellExposeWeakness",
    icon = "Interface/icons/ability_rogue_findweakness",
    position = {718, -456},
    handler = "spellexposeweakness",
    tooltips = {
        frFR = "|cffffffffPerce-faille|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vos coups critiques à distance ont 100% de chances de vous faire bénéficier de Perce-faille.\nPerce-faille augmente votre puissance d'attaque de 25% de votre Agilité pendant 7 secondes.|r",
        enUS = "|cffffffffExpose Weakness|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Your ranged critical hits have a 100% chance to apply Expose Weakness.\nExpose Weakness increases your Attack Power by 25% of your Agility for 7 seconds.|r"
    }
},

{
    id = "spellWyvernSting",
    name = "buttonSpellWyvernSting",
    icon = "Interface/icons/inv_spear_02",
    position = {825, -456},
    handler = "spellwyvernsting",
    tooltips = {
        frFR = "|cffffffffPiqûre de wyverne|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Une piqûre qui endort la cible pendant 30 secondes.\nTout point de dégâts subi par la cible annule l'effet.\nQuand la cible se réveille, la Piqûre inflige 300 points de dégâts de Nature en 6 secondes.\nUne seule technique de Morsure ou de Piqûre par chasseur peut être active sur la cible en même temps.|r",
        enUS = "|cffffffffWyvern Sting|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100A sting that puts the target to sleep for 30 seconds.\nAny damage caused will cancel the effect.\nWhen the target wakes up, the Sting deals 300 Nature damage over 6 seconds.\nOnly one Hunter Sting or Bite effect can be active on the target at a time.|r"
    }
},

{
    id = "spellThrilloftheHunt",
    name = "buttonSpellThrilloftheHunt",
    icon = "Interface/icons/ability_hunter_thrillofthehunt",
    position = {935, -456},
    handler = "spellthrillofthehunt",
    tooltips = {
        frFR = "|cffffffffFrisson de la chasse|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vous confère 100% de chances de récupérer 40% du coût en mana de n'importe quel tir lorsqu'il inflige un coup critique.|r",
        enUS = "|cffffffffThrill of the Hunt|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Grants you a 100% chance to regain 40% of the mana cost of any shot when it critically strikes.|r"
    }
},
{
    id = "spellMasterTactician",
    name = "buttonSpellMasterTactician",
    icon = "Interface/icons/ability_hunter_mastertactitian",
    position = {1045, -456},
    handler = "spellmastertactician",
    tooltips = {
        frFR = "|cffffffffMaître tacticien|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vos attaques à distance réussies ont 10% de chances d'augmenter vos chances de coup critique avec toutes les attaques de 10% pendant 8 secondes.|r",
        enUS = "|cffffffffMaster Tactician|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Your successful ranged attacks have a 10% chance to increase your critical strike chance with all attacks by 10% for 8 seconds.|r"
    }
},

{
    id = "spellNoxiousStings",
    name = "buttonSpellNoxiousStings",
    icon = "Interface/icons/ability_hunter_potentvenom",
    position = {663, -510},
    handler = "spellnoxiousstings",
    tooltips = {
        frFR = "|cffffffffPiqûres nocives|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Si Piqûre de wyverne est dissipée, celui qui la dissipe est également affecté par Piqûre de wyverne pour une durée de 50% du temps restant.\nAugmente également tous les dégâts que vous infligez aux cibles affectées par votre Morsure de serpent de 3%.|r",
        enUS = "|cffffffffNoxious Stings|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100If Wyvern Sting is dispelled, the dispeller is also afflicted by Wyvern Sting for 50% of the remaining duration.\nAlso increases all damage you deal to targets afflicted by your Serpent Sting by 3%.|r"
    }
},

{
    id = "spellPointofNoEscape",
    name = "buttonSpellPointofNoEscape",
    icon = "Interface/icons/ability_hunter_pointofnoescape",
    position = {770, -510},
    handler = "spellpointofnoescape",
    tooltips = {
        frFR = "|cffffffffPlus d'échappatoire|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente de 6% les chances de réussir un coup critique avec toutes vos attaques sur les cibles affectées par vos Pièges de givre, Pièges givrants et Flèches givrantes.|r",
        enUS = "|cffffffffPoint of No Escape|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases critical strike chance of all your attacks by 6% on targets affected by your Frost Traps, Freezing Traps, and Frost Arrows.|r"
    }
},

{
    id = "spellBlackArrow",
    name = "buttonSpellBlackArrow",
    icon = "Interface/icons/spell_shadow_painspike",
    position = {880, -510},
    handler = "spellblackarrow",
    tooltips = {
        frFR = "|cffffffffFlèche noire|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Tire une Flèche noire sur la cible, ce qui augmente tous les dégâts que vous infligez à la cible de 6% et inflige 1116 points de dégâts d'Ombre en 15 secondes.\nFlèche noire partage le temps de recharge de vos sorts de piège.|r",
        enUS = "|cffffffffBlack Arrow|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Fires a Black Arrow at the target, increasing all damage you deal to the target by 6% and dealing 1116 Shadow damage over 15 seconds.\nBlack Arrow shares cooldown with your trap spells.|r"
    }
},

{
    id = "spellSniperTraining",
    name = "buttonSpellSniperTraining",
    icon = "Interface/icons/ability_hunter_longshots",
    position = {990, -510},
    handler = "spellsnipertraining",
    tooltips = {
        frFR = "|cffffffffEntraînement de sniper|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente les chances de coup critique de votre technique Tir mortel de 15%, et si vous restez immobile pendant 6 sec.,\nvous bénéficiez d'Entraînement de sniper qui augmente les dégâts infligés avec Tir assuré, Visée, Flèche noire et Tir explosif de 6% pendant 15 secondes.|r",
        enUS = "|cffffffffSniper Training|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases the critical strike chance of your Kill Shot ability by 15%, and if you remain stationary for 6 seconds,\nyou gain Sniper Training, which increases the damage of your Steady Shot, Aimed Shot, Black Arrow, and Explosive Shot by 6% for 15 seconds.|r"
    }
},
{
    id = "spellHuntingParty",
    name = "buttonSpellHuntingParty",
    icon = "Interface/icons/ability_hunter_huntingparty",
    position = {1100, -510},
    handler = "spellhuntingparty",
    tooltips = {
        frFR = "|cffffffffPartie de chasse|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente votre total d'Agilité de 3% supplémentaires, et vos coups critiques réussis avec Tir des arcanes,\nTir explosif et Tir assuré ont 100% de chances de faire bénéficier jusqu'à 10 membres du groupe ou raid d'une régénération de mana égale à 1% du maximum de mana toutes les 5 sec.\nDure 15 secondes.|r",
        enUS = "|cffffffffHunting Party|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100Increases your total Agility by an additional 3%, and your successful critical strikes with Arcane Shot,\nExplosive Shot, and Steady Shot have a 100% chance to grant up to 10 party or raid members mana regeneration equal to 1% of their maximum mana every 5 sec.\nLasts 15 seconds.|r"
    }
},

{
    id = "spellExplosiveShot",
    name = "buttonSpellExplosiveShot",
    icon = "Interface/icons/ability_hunter_explosiveshot",
    position = {1100, -510},
    handler = "spellexplosiveshot",
    tooltips = {
        frFR = "|cffffffffTir explosif|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vous lancez une charge explosive sur la cible, infligeant 216-244 points de dégâts de Feu.\nLa charge explose ensuite sur la cible toutes les secondes pendant 2 secondes.\nsupplémentaires.|r",
        enUS = "|cffffffffExplosive Shot|r\n|cffffffffTalent|r |cff00ea00Survival|r\n|cffffffffRequires|r |cffa9d271Hunter|r\n|cffffd100You fire an explosive charge at the target, dealing 216-244 Fire damage.\nThe charge then explodes on the target every second for an additional 2 seconds.|r"
		}
	}
}

-- CreateSpellButton("buttonSpellSavageStrikes", "Interface/icons/ability_racial_bloodrage", "|cffffffffFrappes sauvages|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente de 20% les chances d'infliger un coup critique avec Attaque du raptor, Morsure de la mangouste et Contre-attaque.|r", "spellsavagestrikes", 718, -240)
-- CreateSpellButton("buttonSpellSurefooted", "Interface/icons/ability_kick", "|cffffffffPied sûr|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Diminue la durée des effets affectant le mouvement de 30%.|r", "spellsurefooted", 825, -240)
-- CreateSpellButton("buttonSpellEntrapment", "Interface/icons/spell_nature_stranglevines", "|cffffffffPiège|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Lorsque votre Piège de givre ou Piège à serpent est déclenché, vous emprisonnez toutes les cibles affectées, les empêchant de se déplacer pendant 4 secondes.|r", "spellentrapment", 935, -240)
-- CreateSpellButton("buttonSpellTrapMastery", "Interface/icons/ability_ensnare", "|cffffffffMaîtrise des pièges|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Piège de givre et Piège givrant - Augmente la durée de 30%.\nPiège d'immolation, Piège explosif et Flèche noire - Augmente les dégâts périodiques infligés de 30%.\nPiège à serpent - Augmente le nombre de serpents.|r", "spelltrapmastery", 1045, -240)
-- CreateSpellButton("buttonSpellSurvivalInstincts", "Interface/icons/ability_hunter_survivalinstincts", "|cffffffffInstincts de survie|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Réduit tous les dégâts subis de 4% et augmente les chances de coup critique de vos Tirs des arcanes, Tirs assurés et Tirs explosifs de 4%.|r", "spellsurvivalinstincts", 663, -293)
-- CreateSpellButton("buttonSpellSurvivalist", "Interface/icons/spell_shadow_twilight", "|cffffffffSurvivant|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente votre Endurance de 10%.|r", "spellsurvivalist", 770, -293)
-- CreateSpellButton("buttonSpellScatterShot", "Interface/icons/ability_golemstormbolt", "|cffffffffFlèche de dispersion|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Un tir à courte distance qui inflige 50% des dégâts de l'arme et désoriente la cible pendant 4 secondes.\nSi la cible subit des dégâts, l'effet est annulé.\nInterrompt l'attaque lors de son utilisation.|r", "spellscattershot", 990, -293)
-- CreateSpellButton("buttonSpellDeflection", "Interface/icons/ability_parry", "|cffffffffDéviation|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente vos chances de Parer de 3% et réduit la durée de tous les effets de désarmement sur vous de 50%.\nNon cumulable avec les autres effets qui réduisent la durée du désarmement.|r", "spelldeflection", 1100, -293)
-- CreateSpellButton("buttonSpellSurvivalTactics", "Interface/icons/ability_rogue_feigndeath", "|cffffffffTactique de survie|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Réduit la probabilité que l'on résiste à votre technique Feindre la mort et à tous vos sorts de pièges de 4% et réduit le temps de recharge de votre technique Désengagement de 4 sec.|r", "spellsurvivaltactics", 718, -348)
-- CreateSpellButton("buttonSpellTNT", "Interface/icons/inv_misc_bomb_05", "|cffffffffT.N.T.|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente les dégâts infligés par votre Tir explosif, votre Piège explosif, votre Flèche noire et votre Piège d'immolation de 6%.|r", "spelltnt", 825, -348)
-- CreateSpellButton("buttonSpellLockandLoad", "Interface/icons/ability_hunter_lockandload", "|cffffffffPrêt à tirer|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vous avez 100% de chances lorsque vous piégez une cible avec Piège givrant, Flèche givrante ou Piège de givre et 6% de chances lorsque vous infligez des dégâts périodiques avec Piège d'immolation,\nPiège explosif ou Flèche noire que vos 2 prochains sorts Tir des arcanes ou Tir explosif ne déclenchent pas de temps de recharge, ne coûtent pas de mana et ne consomment pas de munitions.\nCet effet a un temps de recharge de 22 sec.|r", "spelllockandload", 935, -348)
-- CreateSpellButton("buttonSpellHuntervsWild", "Interface/icons/ability_hunter_huntervswild", "|cffffffffFace à la nature|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente votre puissance d'attaque et votre puissance d'attaque à distance, ainsi que celles de votre familier, d'un montant égal à 30% de votre total d'Endurance.|r", "spellhuntervswild", 1045, -348)
-- CreateSpellButton("buttonSpellKillerInstinct", "Interface/icons/spell_holy_blessingofstamina", "|cffffffffInstinct du tueur|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente vos chances d'infliger un coup critique avec toutes vos attaques de 3%.|r", "spellkillerinstinct", 663, -402)
-- CreateSpellButton("buttonSpellImprovedBlizzard", "Interface/icons/spell_frost_icestorm", "|cffffffffBlizzard amélioré|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Ajoute un effet d'engourdissement à votre sort Blizzard.\nIl réduit la vitesse de déplacement de la cible de 50%.\nDure 1.5 seconds.|r", "spellimprovedblizzard", 770, -402)
-- CreateSpellButton("buttonSpellCounterattack", "Interface/icons/ability_warrior_challange", "|cffffffffContre-attaque|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Une attaque disponible après avoir paré une attaque de l'adversaire.\nElle inflige 1 points de dégâts et immobilise la cible pendant 5 seconds.\nContre-attaque ne peut pas être bloquée, esquivée ou parée.|r", "spellcounterattack", 880, -402)
-- CreateSpellButton("buttonSpellLightningReflexes", "Interface/icons/spell_nature_invisibilty", "|cffffffffRéflexes éclairs|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente votre Agilité de 15%.|r", "spelllightningreflexes", 990, -402)
-- CreateSpellButton("buttonSpellResourcefulness", "Interface/icons/ability_hunter_resourcefulness", "|cffffffffRessource|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Réduit le coût en mana de tous les pièges et techniques de mêlée ainsi que de Flèche noire de 60% et réduit le temps de recharge de tous les pièges et de Flèche noire de 6 sec.|r", "spellresourcefulness", 1100, -402)
-- CreateSpellButton("buttonSpellExposeWeakness", "Interface/icons/ability_rogue_findweakness", "|cffffffffPerce-faille|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vos coups critiques à distance ont 100% de chances de vous faire bénéficier de Perce-faille.\nPerce-faille augmente votre puissance d'attaque de 25% de votre Agilité pendant 7 secondes.|r", "spellexposeweakness", 718, -456)
-- CreateSpellButton("buttonSpellWyvernSting", "Interface/icons/inv_spear_02", "|cffffffffPiqûre de wyverne|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Une piqûre qui endort la cible pendant 30 secondes.\nTout point de dégâts subi par la cible annule l'effet.\nQuand la cible se réveille, la Piqûre inflige 300 points de dégâts de Nature en 6 secondes.\nUne seule technique de Morsure ou de Piqûre par chasseur peut être active sur la cible en même temps.|r", "spellwyvernsting", 825, -456)
-- CreateSpellButton("buttonSpellThrilloftheHunt", "Interface/icons/ability_hunter_thrillofthehunt", "|cffffffffFrisson de la chasse|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vous confère 100% de chances de récupérer 40% du coût en mana de n'importe quel tir lorsqu'il inflige un coup critique.|r", "spellthrillofthehunt", 935, -456)
-- CreateSpellButton("buttonSpellMasterTactician", "Interface/icons/ability_hunter_mastertactitian", "|cffffffffMaître tacticien|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vos attaques à distance réussies ont 10% de chances d'augmenter vos chances de coup critique avec toutes les attaques de 10% pendant 8 secondes.|r", "spellmastertactician", 1045, -456)
-- CreateSpellButton("buttonSpellNoxiousStings", "Interface/icons/ability_hunter_potentvenom", "|cffffffffPiqûres nocives|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Si Piqûre de wyverne est dissipée, celui qui la dissipe est également affecté par Piqûre de wyverne pour une durée de 50% du temps restant.\nAugmente également tous les dégâts que vous infligez aux cibles affectées par votre Morsure de serpent de 3%.|r", "spellnoxiousstings", 663, -510)
-- CreateSpellButton("buttonSpellPointofNoEscape", "Interface/icons/ability_hunter_pointofnoescape", "|cffffffffPlus d'échappatoire|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente de 6% les chances de réussir un coup critique avec toutes vos attaques sur les cibles affectées par vos Pièges de givre, Pièges givrants et Flèches givrantes.|r", "spellpointofnoescape", 770, -510)
-- CreateSpellButton("buttonSpellBlackArrow", "Interface/icons/spell_shadow_painspike", "|cffffffffFlèche noire|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Tire une Flèche noire sur la cible, ce qui augmente tous les dégâts que vous infligez à la cible de 6% et inflige 1116 points de dégâts d'Ombre en 15 secondes.\nFlèche noire partage le temps de recharge de vos sorts de piège.|r", "spellblackarrow", 880, -510)
-- CreateSpellButton("buttonSpellSniperTraining", "Interface/icons/ability_hunter_longshots", "|cffffffffEntraînement de sniper|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente les chances de coup critique de votre technique Tir mortel de 15%, et si vous restez immobile pendant 6 sec.,\nvous bénéficiez d'Entraînement de sniper qui augmente les dégâts infligés avec Tir assuré, Visée, Flèche noire et Tir explosif de 6% pendant 15 secondes.|r", "spellsnipertraining", 990, -510)
-- CreateSpellButton("buttonSpellHuntingParty", "Interface/icons/ability_hunter_huntingparty", "|cffffffffPartie de chasse|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Augmente votre total d'Agilité de 3% supplémentaires, et vos coups critiques réussis avec Tir des arcanes,\nTir explosif et Tir assuré ont 100% de chances de faire bénéficier jusqu'à 10 membres du groupe ou raid d'une régénération de mana égale à 1% du maximum de mana toutes les 5 sec.\nDure 15 secondes.|r", "spellhuntingparty", 1100, -510)
-- CreateSpellButton("buttonSpellExplosiveShot", "Interface/icons/ability_hunter_explosiveshot", "|cffffffffTir explosif|r\n|cffffffffTalent|r |cff00ea00Survie|r\n|cffffffffRequiert|r |cffa9d271Chasseur|r\n|cffffd100Vous lancez une charge explosive sur la cible, infligeant 216-244 points de dégâts de Feu.\nLa charge explose ensuite sur la cible toutes les secondes pendant 2 secondes.\nsupplémentaires.|r", "spellexplosiveshot", 1100, -510)

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

-- Créez le bouton Save à l'intérieur de la fenêtre frameTalentHunter
local saveButton = CreateFrame("Button", "saveButton", frameTalentHunter, "UIPanelButtonTemplate")
saveButton:SetSize(85, 25)
saveButton:SetPoint("BOTTOMRIGHT", buttonTalentHunterClose, "BOTTOMLEFT", -185, 5) -- Place le bouton Save à gauche du bouton Close
saveButton:SetText(saveButtonText)

-- Fonction qui prend un screenshot quand le bouton est cliqué
saveButton:SetScript("OnClick", function()
    Screenshot()  -- Prendre un screenshot et l'enregistrer dans le dossier Screenshots du jeu
    print(screenshotMessage)  -- Affiche un message de confirmation en fonction de la locale
end)

-- Affiche l'UI des talents
--frameTalentHunter:Show()

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

-- Créez le bouton Reset à l'intérieur de la fenêtre frameTalentHunter
local buttonReset = CreateFrame("Button", "buttonReset", frameTalentHunter, "UIPanelButtonTemplate")
buttonReset:SetSize(85, 25)
buttonReset:SetPoint("BOTTOMRIGHT", buttonTalentHunterClose, "BOTTOMLEFT", -95, 5) -- Place le bouton Reset à gauche du bouton Reload
buttonReset:SetText(buttonResetText)

local function ResetTalents()
    -- Ajoutez ici la logique pour réinitialiser les talents du joueur
    AIO.Handle("TalentHunterspell", "ResetTalents")
    resetButtonClicked = true -- Marquez le bouton Réinitialiser comme cliqué
end

buttonReset:SetScript("OnClick", ResetTalents)

-- Créez le bouton Reload à l'intérieur de la fenêtre frameTalentHunter
local buttonReload = CreateFrame("Button", "buttonReload", frameTalentHunter, "UIPanelButtonTemplate")
buttonReload:SetSize(85, 25)
buttonReload:SetPoint("BOTTOMRIGHT", buttonTalentHunterClose, "BOTTOMLEFT", -5, 5) -- Place le bouton Reload à gauche du bouton Close
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
        frameTalentHunter:Hide()
        buttonReload:Hide()
        PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
    else
        frameTalentHunter:Show()
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
        frFR = "|cffffffffTalents|r |cffa9d271(Chasseur)|r\n\nL'éventail des talents disponibles\npour améliorer et spécialiser\nvotre personnage.",
        enUS = "|cffffffffTalents|r |cffa9d271(Hunter)|r\n\nThe range of available talents\nfor enhancing and specializing\nyour character."
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

-- Vérifier si le joueur est un Hunter avant de créer le bouton
local playerClass = select(2, UnitClass("player")) -- Obtenir la classe du joueur
if playerClass == "HUNTER" then
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
HunterHandlers.UpdateTalentCount = function(player, talentsAppris)
    if fontTalentHunterFrameText then
        fontTalentHunterFrameText:SetText(talentsAppris .. " / " .. MAX_TALENTS)
    end
end

-- Mise à jour des points de talent utilisés avec texte localisé
HunterHandlers.UpdateTalentPointsUsed = function(player, pointsUsed, pointsBeforeReset)
    -- Utilisation du texte localisé pour les points avant réinitialisation
    print(string.format(GetLocalizedPointsBeforeResetText(), pointsBeforeReset))
end

-- Affichage des talents restants (items 338404 dans le sac)
HunterHandlers.UpdateTalentItemCount = function(player, count)
    if fontTalentPointsRemainingText then
        fontTalentPointsRemainingText:SetText("|cFFA9D271Talents restants : " .. count .. "|r")
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
        fontTalentPointsRemainingText:SetText("|cFFA9D271Talents restants : " .. (count or 0) .. "|r")
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
if playerClass == "HUNTER" then
    -- Surcharge OnHide pour synchroniser talentsWindowOpen quand Échap est pressé
    local _originalOnHide = frameTalentHunter:GetScript("OnHide")
    frameTalentHunter:SetScript("OnHide", function(self)
        talentsWindowOpen = false
        if _originalOnHide then _originalOnHide(self) end
    end)
    -- WoW appelle automatiquement Hide() sur les frames listées ici quand Échap est pressé
    tinsert(UISpecialFrames, "frameTalentHunter")
end