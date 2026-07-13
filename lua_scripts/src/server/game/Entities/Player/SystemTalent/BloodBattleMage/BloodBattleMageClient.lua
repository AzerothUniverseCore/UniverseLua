local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local BloodbattlemageHandlers = AIO.AddHandlers("TalentBloodbattlemagespell", {})

function BloodbattlemageHandlers.ShowTalentBloodbattlemage(player)
    frameTalentBloodbattlemage:Show()
    -- Redemande au serveur l’état visuel au cas où
    AIO.Handle("TalentBloodbattlemagespell", "RequestLearnedTalents")
	-- Redemande le nombre de talents restants
    AIO.Handle("TalentBloodbattlemagespell", "GetTalentItemCount")
end

local MAX_TALENTS = 41 -- Définition du nombre maximal de talents que le joueur peut apprendre

local OPEN_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_final_trait_unlocked.ogg"
local CLOSE_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_trait_refund_end.ogg"
local SPELL_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_80_azeritearmor_rotationends_02.ogg"

-- Attribute window
local frameTalentBloodbattlemage = CreateFrame("Frame", "frameTalentBloodbattlemage", UIParent)
frameTalentBloodbattlemage:SetSize(1200, 650)
frameTalentBloodbattlemage:SetMovable(true)
frameTalentBloodbattlemage:EnableMouse(true)
frameTalentBloodbattlemage:RegisterForDrag("LeftButton")
frameTalentBloodbattlemage:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, -50) -- Adjust the X and Y coordinates
frameTalentBloodbattlemage:SetBackdrop(
{
    -- bgFile = "interface/TalentFrame/talentsclassbackgroundbbm2", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    bgFile = "interface/TalentFrame/Template/Class/BloodBattleMage/talentsclassbackgroundbloodbattlemage2", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedbbm", --Interface/DialogFrame/UI-DialogBox-Border
    edgeSize = 20,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})

-- Ajoutez la texture de l'icône du Mage de combat sanglant
local bloodbattlemageIcon = frameTalentBloodbattlemage:CreateTexture("BloodbattlemageIcon", "OVERLAY")
bloodbattlemageIcon:SetTexture("Interface\\TalentFrame\\Template\\Class\\BloodBattleMage\\IconeBloodbattlemage.blp")
bloodbattlemageIcon:SetSize(60, 60)
bloodbattlemageIcon:SetPoint("TOPLEFT", frameTalentBloodbattlemage, "TOPLEFT", -10, 10)

-- Template Talent Frame

-- Ajoute une textureone pour l'image BLP
local textureone = frameTalentBloodbattlemage:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
textureone:SetTexture("Interface\\TalentFrame\\Template\\Class\\Bloodbattlemage\\TalentFrameTemplate.blp")
textureone:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
textureone:SetPoint("TOPLEFT", frameTalentBloodbattlemage, "TOPLEFT", -150, 120) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentBloodbattlemage:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Ajoute une texturetwo pour l'image BLP
local texturetwo = frameTalentBloodbattlemage:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
texturetwo:SetTexture("Interface\\TalentFrame\\Template\\Class\\BloodBattleMage\\TalentFrameTemplateOriginal.blp")
texturetwo:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
texturetwo:SetPoint("TOPRIGHT", frameTalentBloodbattlemage, "TOPRIGHT", 150, 160) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentBloodbattlemage:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Drag & Drop
frameTalentBloodbattlemage:SetScript("OnDragStart", frameTalentBloodbattlemage.StartMoving)
frameTalentBloodbattlemage:SetScript("OnHide", frameTalentBloodbattlemage.StopMovingOrSizing)
frameTalentBloodbattlemage:SetScript("OnDragStop", frameTalentBloodbattlemage.StopMovingOrSizing)
frameTalentBloodbattlemage:Hide()

-- Nouveau template d'arête
frameTalentBloodbattlemage:SetBackdropBorderColor(0.5, 0, 0) -- Couleur rouge

-- Close button
local buttonTalentBloodbattlemageClose = CreateFrame("Button", "buttonTalentBloodbattlemageClose", frameTalentBloodbattlemage, "UIPanelCloseButton")
buttonTalentBloodbattlemageClose:SetPoint("TOPRIGHT", -12, -12)
buttonTalentBloodbattlemageClose:EnableMouse(true)
buttonTalentBloodbattlemageClose:SetSize(32, 32)

local function CloseTalentWindow()
    frameTalentBloodbattlemage:Hide()
    PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
end

-- Associez la fonction de fermeture au bouton de fermeture
buttonTalentBloodbattlemageClose:SetScript("OnClick", CloseTalentWindow)

-- Title bar
local frameTalentBloodbattlemageTitleBar = CreateFrame("Frame", "frameTalentBloodbattlemageTitleBar", frameTalentBloodbattlemage, nil)
frameTalentBloodbattlemageTitleBar:SetSize(135, 25)
frameTalentBloodbattlemageTitleBar:SetBackdrop(
{
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedbbm",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentBloodbattlemageTitleBar:SetPoint("TOP", 0, 20)

local fontTalentBloodbattlemageTitleText = frameTalentBloodbattlemageTitleBar:CreateFontString("fontTalentBloodbattlemageTitleText")
fontTalentBloodbattlemageTitleText:SetFont("Fonts\\FRIZQT__.TTF", 13)
fontTalentBloodbattlemageTitleText:SetSize(190, 5)
fontTalentBloodbattlemageTitleText:SetPoint("CENTER", 0, 0)
fontTalentBloodbattlemageTitleText:SetText("|cffFFC125Talents|r")

-- Détecte la langue du client
local locale = GetLocale() -- Retourne "enUS", "frFR", etc.

-- Table des traductions
local localizedTexts = {
    enUS = "|cffFFC125Battle Mage|r",
    frFR = "|cffFFC125Mage de combat|r",
}

-- Récupère le texte correspondant à la langue actuelle ou par défaut en anglais
local textToDisplay = localizedTexts[locale] or localizedTexts["enUS"]

-- Création de l'élément de texte
local fontTalentBloodbattlemageFrameText = frameTalentBloodbattlemageTitleBar:CreateFontString("fontTalentBloodbattlemageFrameText")
fontTalentBloodbattlemageFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentBloodbattlemageFrameText:SetSize(200, 5)
fontTalentBloodbattlemageFrameText:SetPoint("TOPLEFT", frameTalentBloodbattlemageTitleBar, "BOTTOMLEFT", -30, -35) -- Ajustez l'offset si nécessaire
fontTalentBloodbattlemageFrameText:SetText(textToDisplay)

-- Remplacez votre ligne existante pour la création du texte par celle-ci
local fontTalentBloodbattlemageFrameText = frameTalentBloodbattlemageTitleBar:CreateFontString("fontTalentBloodbattlemageFrameText")
fontTalentBloodbattlemageFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentBloodbattlemageFrameText:SetSize(200, 5)
fontTalentBloodbattlemageFrameText:SetPoint("TOPLEFT", frameTalentBloodbattlemageTitleBar, "BOTTOMLEFT", -30, -60) -- Adjust the Y offset as needed
fontTalentBloodbattlemageFrameText:SetText("0 / " .. MAX_TALENTS) -- Initialisez le texte avec 0 talents appris

-------------------------------------------------------------
-- Affichage "Talents restants" (item 338404 dans le sac)
-------------------------------------------------------------

local frameTalentPointsRemaining = CreateFrame("Frame", "frameTalentPointsRemaining", frameTalentBloodbattlemage, nil)
frameTalentPointsRemaining:SetSize(220, 30)
frameTalentPointsRemaining:SetBackdrop({
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedbbm",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentPointsRemaining:SetPoint("BOTTOMRIGHT", frameTalentBloodbattlemage, "BOTTOMRIGHT", -960, 10)

local fontTalentPointsRemainingText = frameTalentPointsRemaining:CreateFontString("fontTalentPointsRemainingText")
fontTalentPointsRemainingText:SetFont("Fonts\\FRIZQT__.TTF", 14)
fontTalentPointsRemainingText:SetSize(210, 20)
fontTalentPointsRemainingText:SetPoint("CENTER", 0, 0)
fontTalentPointsRemainingText:SetText("|cFFDD1133Talents restants : 0|r")
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
BloodbattlemageHandlers.UpdateLearnedTalents = function(player, learnedSpells)
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

    local button = CreateFrame("Button", name, frameTalentBloodbattlemage, nil)
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
                AIO.Handle("TalentBloodbattlemagespell", talentHandler, 1)
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

-- Magie du sang

-- Table des sorts
local spells = {
    {
        id = "spellImprovedBlood",
        name = "buttonSpellImprovedBlood",
        icon = "Interface/icons/ability_skeer_bloodletting",
        position = {225, -95},
        handler = "spellimprovedblood",
        tooltips = {
            frFR = "|cffffffffSanguinaire améliorée|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100A chacune de vos compétence de Sanguinaire, vous récupérer 5 point de sang.|r",
            enUS = "|cffffffffImproved Sanguinary|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Each time you use Sanguinary abilities, you recover 5 blood points.|r"
        }
    },
    {
        id = "spellSeedGrowth",
        name = "buttonSpellSeedGrowth",
        icon = "Interface/icons/spell_animarevendreth_orb",
        position = {335, -95},
        handler = "spellseedgrowth",
        tooltips = {
            frFR = "|cffffffffCroissance de graine|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Votre graine de sang croît de manière efficace, lui permettant d'augmenter la durée de son effet de 5 secondes.|r",
            enUS = "|cffffffffSeed Growth|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Your blood seed grows effectively, increasing its effect duration by 5 seconds.|r"
        }
    },
	{
        id = "spellOppressiveRay",
        name = "buttonSpellOppressiveRay",
        icon = "Interface/icons/ability_warlock_burningembers",
        position = {390, -150},
        handler = "spelloppressiveray",
        tooltips = {
            frFR = "|cffffffffRayon oppressant|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Les dégâts de rayon de sang sont augmentés de 75%.|r",
            enUS = "|cffffffffOppressive Ray|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100The damage of Blood Ray is increased by 75%.|r"
        }
    },
    {
        id = "spellBloodBundle",
        name = "buttonSpellBloodBundle",
        icon = "Interface/icons/ability_revendreth_shaman",
        position = {280, -150},
        handler = "spellbloodbundle",
        tooltips = {
            frFR = "|cffffffffFaisceau de sang|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Votre rayon de Sang augmente son nombre de cibles potentielles de 5.|r",
            enUS = "|cffffffffBlood Beam|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Your Blood Ray increases its potential target count by 5.|r"
        }
    },
    {
        id = "spellBloody",
        name = "buttonSpellBloody",
        icon = "Interface/icons/ability_revendreth_rogue",
        position = {169, -150},
        handler = "spellbloody",
        tooltips = {
            frFR = "|cffffffffSanguinolent|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Augmente de 15% les dégâts de votre sanguinaire.|r",
            enUS = "|cffffffffSanguine|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Increases the damage of your Sanguinary by 15%.|r"
        }
    },
    {
        id = "spellHomeothermal",
        name = "buttonSpellHomeothermal",
        icon = "Interface/icons/ability_revendreth_demonhunter",
        position = {115, -205},
        handler = "spellhomeothermal",
        tooltips = {
            frFR = "|cffffffffHoméotherme|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Votre sang se chauffe et inflige 11 dégâts par seconde aux ennemis proches.\nGénère 5 points de sang.|r",
            enUS = "|cffffffffHomeothermal|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Your blood heats up, dealing 11 damage per second to nearby enemies.\nGenerates 5 blood points.|r"
        }
    },
    {
        id = "spellTargeted",
        name = "buttonSpellTargeted",
        icon = "Interface/icons/Ability_Marksmanship",
        position = {335, -205},
        handler = "spelltargeted",
        tooltips = {
            frFR = "|cffffffffCiblage|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Augmente vos chances de toucher de vos sorts de 5%.|r",
            enUS = "|cffffffffTargeting|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Increases your spell hit chance by 5%.|r"
        }
    },
    {
        id = "spellEffusion",
        name = "buttonSpellEffusion",
        icon = "Interface/icons/ability_skeer_bloodletting",
        position = {225, -205},
        handler = "spelleffusion",
        tooltips = {
            frFR = "|cffffffffEffusion|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100À chaque attaque infligée par vos coups de mêlée, vous récupérez 5 points de sang.|r",
            enUS = "|cffffffffEffusion|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Each melee attack restores 5 blood points.|r"
        }
    },
	{
    id = "spellSeedPreparation",
    name = "buttonSpellSeedPreparation",
    icon = "Interface/icons/Spell_Nature_EnchantArmor",
    position = {444, -205},
    handler = "spellseedpreparation",
    tooltips = {
        frFR = "|cffffffffPréparation de graine|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Vous avez 20% de chance avec vos compétences de mêlée de provoquer Préparation de graine, mettant votre graine de sang instantanée.|r",
        enUS = "|cffffffffSeed Preparation|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100You have a 20% chance with your melee abilities to trigger Seed Preparation, making your blood seed instant.|r"
    }
},
{
    id = "spellBloodTransfusion",
    name = "buttonSpellBloodTransfusion",
    icon = "Interface/icons/spell_animarevendreth_nova",
    position = {170, -260},
    handler = "spellbloodtransfusion",
    tooltips = {
        frFR = "|cffffffffTransfusion Sanguine|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Transfusion l'entièreté de votre être 5 mètre plus loin.|r",
        enUS = "|cffffffffBlood Transfusion|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Transfuse your entire being 5 meters forward.|r"
    }
},
{
    id = "spellBloodTransfusionImprove",
    name = "buttonSpellBloodTransfusionImprove",
    icon = "Interface/icons/spell_animarevendreth_nova",
    position = {115, -315},
    handler = "spellbloodtransfusionimprove",
    tooltips = {
        frFR = "|cffffffffTransfusion amélioré|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Votre transfusion vous transportes 30 mètres plus loin.|r",
        enUS = "|cffffffffImproved Transfusion|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Your transfusion transports you 30 meters further.|r"
    }
},
{
    id = "spellSangThe",
    name = "buttonSpellSangThe",
    icon = "Interface/icons/INV_Drink_22",
    position = {390, -260},
    handler = "spellsangthe",
    tooltips = {
        frFR = "|cffffffffSang-Thé|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Votre puissance de sort reçoit un bénéfice supplémentaire de 150% de votre force.|r",
        enUS = "|cffffffffBlood-Tea|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Your spell power receives an additional benefit of 150% of your strength.|r"
    }
},
{
    id = "spellParasyteSeed",
    name = "buttonSpellParasyteSeed",
    icon = "Interface/icons/ability_felarakkoa_feldetonation_red",
    position = {444, -315},
    handler = "spellparasyteseed",
    tooltips = {
        frFR = "|cffffffffGraine parasyte|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Les dégâts périodiques de votre graine de sang peuvent à présent être des coups critiques.|r",
        enUS = "|cffffffffParasitic Seed|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100The periodic damage of your blood seed can now critically strike.|r"
    }
},
{
    id = "spellMentalConditioning",
    name = "buttonSpellMentalConditioning",
    icon = "Interface/icons/inv_alchemy_80_alchemiststone02",
    position = {170, -370},
    handler = "spellmentalconditioning",
    tooltips = {
        frFR = "|cffffffffConditionnement mental|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Augmente de 10% votre hâte des sorts.|r",
        enUS = "|cffffffffMental Conditioning|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Increases your spell haste by 10%.|r"
    }
},
{
    id = "spellWarmup",
    name = "buttonSpellWarmup",
    icon = "Interface/icons/sha_spell_fire_felfire_nightmare",
    position = {390, -370},
    handler = "spellwarmup",
    tooltips = {
        frFR = "|cffffffffEchauffement|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Augmente le temps ou vous conservez votre chaleur corporelle élever de 10 secondes.|r",
        enUS = "|cffffffffWarmup|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Increases the time you retain your body heat by 10 seconds.|r"
    }
},
{
    id = "spellBloodCirculation",
    name = "buttonSpellBloodCirculation",
    icon = "Interface/icons/inv_glove_cloth_revendreth_d_01",
    position = {497, -370},
    handler = "spellbloodcirculation",
    tooltips = {
        frFR = "|cffffffffCirculation sanguine|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Vos capacités physiques ainsi que vos attaques automatiques ont 20% de chance d'augmenter de 101% votre hâte des sorts.|r",
        enUS = "|cffffffffBlood Circulation|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Your physical abilities and auto-attacks have a 20% chance to increase your spell haste by 101%.|r"
    }
},
{
    id = "spellBloodEssence",
    name = "buttonSpellBloodEssence",
    icon = "Interface/icons/spell_animarevendreth_buff",
    position = {442, -422},
    handler = "spellbloodessence",
    tooltips = {
        frFR = "|cffffffffEssence de sang|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Dégâts augmentés de 15%.|r",
        enUS = "|cffffffffBlood Essence|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Increases your damage by 15%.|r"
    }
},
{
    id = "spellBloodyApparation",
    name = "buttonSpellBloodyApparation",
    icon = "Interface/icons/ability_revendreth_deathknight",
    position = {60, -370},
    handler = "spellbloodyapparation",
    tooltips = {
        frFR = "|cffffffffApparition sanglante|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Vous apparaissez dans le dos de votre adversaire, possédant un bonus de 5% aux dégâts de votre prochaine attaque dans les prochaines 3 secondes.|r",
        enUS = "|cffffffffBloody Apparition|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100You appear behind your opponent, gaining a 5% bonus to the damage of your next attack within 3 seconds.|r"
    }
},
{
    id = "spellHotBlood",
    name = "buttonSpellHotBlood",
    icon = "Interface/icons/inv_misc_boilingblood",
    position = {115, -422},
    handler = "spellhotblood",
    tooltips = {
        frFR = "|cffffffffSang chaud|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Chaque dégât infligé par votre rayon de sang offre une réduction du coût de votre prochaine compétence sanguinaire de 20% (cumulable 5 fois).|r",
        enUS = "|cffffffffHot Blood|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Each damage inflicted by your blood ray reduces the cost of your next blood skill by 20% (stackable 5 times).|r"
    }
},
{
    id = "spellNoBlood",
    name = "buttonSpellNoBlood",
    icon = "Interface/icons/inv_ misc_herb_marrowroot_leaf",
    position = {225, -422},
    handler = "spellnoblood",
    tooltips = {
        frFR = "|cffffffffManque de sang|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Augmente les dégâts de votre Prise de sang de 15%.|r",
        enUS = "|cffffffffLack of Blood|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Increases the damage of your Blood Grasp by 15%.|r"
    }
},
{
    id = "spellBloodSample",
    name = "buttonSpellBloodSample",
    icon = "Interface/icons/spell_animarevendreth_missile",
    position = {170, -478},
    handler = "spellbloodsample",
    tooltips = {
        frFR = "|cffffffffPrise de sang|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Extrait le sang sur une zone ciblée. Infligeant 1 dégât par 0.5 secondes, pendant 5 secondes.|r",
        enUS = "|cffffffffBlood Sample|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Extracts blood from a targeted area, dealing 1 damage every 0.5 seconds for 5 seconds.|r"
    }
},
	{
    id = "spellCollectiveDonation",
    name = "buttonSpellCollectiveDonation",
    icon = "Interface/icons/ability_revendreth_paladin",
    position = {225, -530},
    handler = "spellcollectivedonation",
    tooltips = {
        frFR = "|cffffffffDon collectif|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Donne 100 de chance de réduire le temps de recharge de votre Prise de sang de 0 seconde à chaque attaque automatique.|r",
        enUS = "|cffffffffCollective Donation|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Gives you 100% chance to reduce the cooldown of your Blood Grasp by 0 seconds with each auto-attack.|r"
    }
},
{
    id = "spellBloodFlow",
    name = "buttonSpellBloodFlow",
    icon = "Interface/icons/inv_artifact_corruptedbloodofzakajz",
    position = {335, -422},
    handler = "spellbloodflow",
    tooltips = {
        frFR = "|cffffffffFlôt de sang|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Vos attaques au corps à corps ont 99% de chance de provoquer que votre Sanguinaire ou Sanguinaire Pure ne coûteront aucun sang.|r",
        enUS = "|cffffffffBlood Flow|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Your melee attacks have a 99% chance to cause your Blood Frenzy or Pure Blood Frenzy to cost no blood.|r"
    }
},
{
    id = "spellBloodStorm",
    name = "buttonSpellBloodStorm",
    icon = "Interface/icons/spell_sandstorm",
    position = {390, -478},
    handler = "spellbloodstorm",
    tooltips = {
        frFR = "|cffffffffTempête de sang|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Votre tempête de sang inflige des dégâts imparable de 115% des dégâts de l'arme en main droite et 115% des dégâts de l'arme en main gauche à tous les ennemis proches.|r",
        enUS = "|cffffffffBlood Storm|r\n|cffffffffTalent|r |cfffc6703Blood Magic|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Your Blood Storm inflicts unresistable damage of 115% of your right-hand weapon damage and 115% of your left-hand weapon damage to all nearby enemies.|r"
    }
},
{
    id = "spellReinforcedBlood",
    name = "buttonSpellReinforcedBlood",
    icon = "Interface/icons/ability_malkorok_blightofyshaarj_red",
    position = {335, -530},
    handler = "spellreinforcedblood",
    tooltips = {
        frFR = "|cffffffffSang renforcé|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Renforce votre sang augmentant votre endurance de 5%.|r",
        enUS = "|cffffffffReinforced Blood|r\n|cffffffffTalent|r |cfff2f200Blood Sacrifice|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Strengthens your blood, increasing your stamina by 5%.|r"
    }
},

-- CreateSpellButton("buttonSpellImprovedBlood", "Interface/icons/ability_skeer_bloodletting", "|cffffffffSanguinaire améliorée|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100A chacune de vos compétence de Sanguinaire, vous récupérer 5 point de sang.|r", "spellimprovedblood", 225, -95)
-- CreateSpellButton("buttonSpellSeedGrowth", "Interface/icons/spell_animarevendreth_orb", "|cffffffffCroissance de graine|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Votre graine de sang croît de manière efficace, lui permettant d'augmenter la durée de son effet de 5 secondes.|r", "spellseedgrowth", 335, -95)
-- CreateSpellButton("buttonSpellOppressiveRay", "Interface/icons/ability_warlock_burningembers", "|cffffffffRayon oppressant|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Les dégats de rayon de sang sont augmenté de 75%.|r", "spelloppressiveray", 390, -150)
-- CreateSpellButton("buttonSpellBloodBundle", "Interface/icons/ability_revendreth_shaman", "|cffffffffFaisceau de sang|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Votre rayon de Sang augmente son nombre de cible potentiel de 5.|r", "spellbloodbundle", 280, -150)
-- CreateSpellButton("buttonSpellBloody", "Interface/icons/ability_revendreth_rogue", "|cffffffffSanguinolent|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Augmente de 15% les dégâts de votre sanguinaire.|r", "spellbloody", 169, -150)
-- CreateSpellButton("buttonSpellHomeothermal", "Interface/icons/ability_revendreth_demonhunter", "|cffffffffHoméotherme|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Votre sang se chauff et inflige 11 dégâts par seconde aux ennemis proches.\nGénère 5 point de sang.|r", "spellhomeothermal", 115, -205)
-- CreateSpellButton("buttonSpellTargeted", "Interface/icons/Ability_Marksmanship", "|cffffffffCiblage|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Augmente vos chances de toucher de vos sorts de 5%.|r", "spelltargeted", 335, -205)
-- CreateSpellButton("buttonSpellEffusion", "Interface/icons/ability_skeer_bloodletting", "|cffffffffEffusion|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100À chaque attaque infligé par vos coups de mêlées vous rendent 5 points de sang.|r", "spelleffusion", 225, -205)
-- CreateSpellButton("buttonSpellSeedPreparation", "Interface/icons/Spell_Nature_EnchantArmor", "|cffffffffPréparation de graine|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Vous avez 20% de chance avec vos compétences de mêlée de provoquer Préparation de graine, mettant votre graine de sang instantanée.|r", "spellseedpreparation", 444, -205)
-- CreateSpellButton("buttonSpellBloodTransfusion", "Interface/icons/spell_animarevendreth_nova", "|cffffffffTransfusion Sanguine|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Transfusion l'entièreté de votre être 5 mètre plus loin.|r", "spellbloodtransfusion", 170, -260)
-- CreateSpellButton("buttonSpellBloodTransfusionImprove", "Interface/icons/spell_animarevendreth_nova", "|cffffffffTransfusion amélioré|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Votre transfusion vous transportes 30 mètres plus loin.|r", "spellbloodtransfusionimprove", 115, -315)
-- CreateSpellButton("buttonSpellSangThe", "Interface/icons/INV_Drink_22", "|cffffffffSang-Thé|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Votre puissance de sort reçoit un bénéfice supplémentaire de 150% de votre force.|r", "spellsangthe", 390, -260)
-- CreateSpellButton("buttonSpellParasyteSeed", "Interface/icons/ability_felarakkoa_feldetonation_red", "|cffffffffGraine parasyte|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Les dégâts périodiques de votre graine de sang peuvent à présent être des coups critiques.|r", "spellparasyteseed", 444, -315)
-- CreateSpellButton("buttonSpellMentalConditioning", "Interface/icons/inv_alchemy_80_alchemiststone02", "|cffffffffConditionnement mental|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Augmente de 10% votre hâte des sorts.|r", "spellmentalconditioning", 170, -370)
-- CreateSpellButton("buttonSpellWarmup", "Interface/icons/sha_spell_fire_felfire_nightmare", "|cffffffffEchauffement|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Augmente le temps ou vous conservez votre chaleur corporelle élever de 10 secondes.|r", "spellwarmup", 390, -370)
-- CreateSpellButton("buttonSpellBloodCirculation", "Interface/icons/inv_glove_cloth_revendreth_d_01", "|cffffffffCirculation sanguine|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Vos capacitées physiques ainsi que vos attaques automatique ont 20% de chance d'augmente de 101% votre hâte des sorts.|r", "spellbloodcirculation", 497, -370)
-- CreateSpellButton("buttonSpellBloodEssence", "Interface/icons/spell_animarevendreth_buff", "|cffffffffEssence de sang|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Dégâts augmentés de 15%.|r", "spellbloodessence", 442, -422)
-- CreateSpellButton("buttonSpellBloodyApparation", "Interface/icons/ability_revendreth_deathknight", "|cffffffffApparation sanglante|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Vous apparaissez dans le dos de votre adversaire, possédant un bonus de 5% aux dégâts de votre prochaine attaque dans les prochaines 3 seconds.|r", "spellbloodyapparation", 60, -370)
-- CreateSpellButton("buttonSpellHotBlood", "Interface/icons/inv_misc_boilingblood", "|cffffffffSang chaud|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Chaque dégâts infligés par votre rayon de sang offre une réduction du coût de votre prochaine compétence sanguinaire de 20% (cumulable 5 fois).|r", "spellhotblood", 115, -422)
-- CreateSpellButton("buttonSpellNoBlood", "Interface/icons/inv_ misc_herb_marrowroot_leaf", "|cffffffffManque de sang|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Augmente les dégâts de votre Prise de sang de 15%.|r", "spellnoblood", 225, -422)
-- CreateSpellButton("buttonSpellBloodSample", "Interface/icons/spell_animarevendreth_missile", "|cffffffffPrise de sang|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Extrait le sang sur une zone ciblée. Infligeant 1 dégâts par 0.5 secondes, pendant 5 seconds.|r", "spellbloodsample", 170, -478)
-- CreateSpellButton("buttonSpellCollectiveDonation", "Interface/icons/ability_revendreth_paladin", "|cffffffffDon collectif|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Donne 100 de chance de réduire le temsp de recharge de votre Prise de sang de 0 seconde à chaque attaque automatique.|r", "spellcollectivedonation", 225, -530)
-- CreateSpellButton("buttonSpellBloodFlow", "Interface/icons/inv_artifact_corruptedbloodofzakajz", "|cffffffffFlôt de sang|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Vos attaques au corps ont 99% de chance de provoquer votre Sanguinaire ou Sanguinaire Pure ne couteront aucun sang.|r", "spellbloodflow", 335, -422)
-- CreateSpellButton("buttonSpellBloodStorm", "Interface/icons/spell_sandstorm", "|cffffffffTempête de sang|r\n|cffffffffTalent|r |cfffc6703Magie du Sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Votre tempête de sang inflige des dégâts imparable de 115% des dégâts de l'arme en main droite et 115% dégâts de l'arme en main gauche à tout les ennemis proches.|r", "spellbloodstorm", 390, -478)
-- CreateSpellButton("buttonSpellReinforcedBlood", "Interface/icons/ability_malkorok_blightofyshaarj_red", "|cffffffffSang renforcé|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Renforce votre sang augmentant votre endurance de 5%.|r", "spellreinforcedblood", 335, -530)

-- Template 2

-- Sacrifice de sang

{
    id = "spellAbilityMotivation",
    name = "buttonSpellAbilityMotivation",
    icon = "Interface/icons/spell_halo_purple",
    position = {805, -110},
    handler = "spellabilitymotivation",
    tooltips = {
        frFR = "|cffffffffAptitude : Motivation|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Canalise un puissant terrain de soutien, augmentant la vitesse de déplacement de 30% pour tous les alliés dans la zone.|r",
        enUS = "|cffffffffAbility: Motivation|r\n|cffffffffTalent|r |cfff2f200Blood Sacrifice|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Channels a powerful support field, increasing movement speed by 30% for all allies in the area.|r"
    }
},
{
    id = "spellAbilityBloodFlow",
    name = "buttonSpellAbilityBloodFlow",
    icon = "Interface/icons/sha_spell_shadow_shadesofdarkness_nightmare",
    position = {915, -110},
    handler = "spellabilitybloodflow",
    tooltips = {
        frFR = "|cffffffffAptitude : Afflux de sang|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Provoque un afflux de sang soudain à la tête des ennemis proches de vous. Étourdissant les cibles dans une portée de 8 mètres pendant 1 seconde.|r",
        enUS = "|cffffffffAbility: Blood Flow|r\n|cffffffffTalent|r |cfff2f200Blood Sacrifice|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Triggers a sudden blood surge to the heads of nearby enemies, stunning targets within 8 yards for 1 second.|r"
    }
},
{
    id = "spellAbilityCare",
    name = "buttonSpellAbilityCare",
    icon = "Interface/icons/spell_halo_blue",
    position = {750, -165},
    handler = "spellabilitycare",
    tooltips = {
        frFR = "|cffffffffAptitude : Soins|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Canalise un puissant terrain de soutien, augmentant les soins reçus de 25% pour tous les alliés dans la zone.|r",
        enUS = "|cffffffffAbility: Healing|r\n|cffffffffTalent|r |cfff2f200Blood Sacrifice|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Channels a powerful support field, increasing healing received by 25% for all allies in the area.|r"
    }
},
{
    id = "spellAbilityProtection",
    name = "buttonSpellAbilityProtection",
    icon = "Interface/icons/spell_halo_yellow",
    position = {807, -218},
    handler = "spellabilityprotection",
    tooltips = {
        frFR = "|cffffffffAptitude : Protection|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Canalise un puissant terrain de soutien, réduisant les dégâts subis de 25% pour tous les alliés dans la zone.|r",
        enUS = "|cffffffffAbility: Protection|r\n|cffffffffTalent|r |cfff2f200Blood Sacrifice|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Channels a powerful support field, reducing damage taken by 25% for all allies in the area.|r"
    }
},
{
    id = "spellAbilitySword",
    name = "buttonSpellAbilitySword",
    icon = "Interface/icons/spell_halo_red",
    position = {860, -165},
    handler = "spellabilitysword",
    tooltips = {
        frFR = "|cffffffffAptitude : Epée|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Canalise un puissant terrain de soutien, augmentant les dégâts infligés de 25% pour tous les alliés dans la zone.|r",
        enUS = "|cffffffffAbility: Sword|r\n|cffffffffTalent|r |cfff2f200Blood Sacrifice|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Channels a powerful support field, increasing damage dealt by 25% for all allies in the area.|r"
    }
},
{
    id = "spellAbilityProtector",
    name = "buttonSpellAbilityProtector",
    icon = "Interface/icons/spell_halo_green",
    position = {914, -218},
    handler = "spellabilityprotector",
    tooltips = {
        frFR = "|cffffffffAptitude : Protecteur|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Canalise un puissant terrain de soutien, recevant l'équivalent de 30% des dégâts subis par les alliés dans la zone.|r",
        enUS = "|cffffffffAbility: Protector|r\n|cffffffffTalent|r |cfff2f200Blood Sacrifice|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Channels a powerful support field, absorbing 30% of the damage taken by allies in the area.|r"
    }
},
	{
    id = "spellAbilityPureBlood",
    name = "buttonSpellAbilityPureBlood",
    icon = "Interface/icons/spell_animarevendreth_beam",
    position = {970, -165},
    handler = "spellabilitypureblood",
    tooltips = {
        frFR = "|cffffffffAptitude : Pure sang|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Canalise un puissant lien procurant à la cible 125% de dégâts prodigués.|r",
        enUS = "|cffffffffAbility: Pure Blood|r\n|cffffffffTalent|r |cfff2f200Blood Sacrifice|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Channels a powerful bond granting the target 125% of the damage dealt.|r"
    }
},
{
    id = "spellHarvestingSuffering",
    name = "buttonSpellHarvestingSuffering",
    icon = "Interface/icons/inv_misc_volatilelife",
    position = {699, -218},
    handler = "spellharvestingsuffering",
    tooltips = {
        frFR = "|cffffffffRécolte de souffrance|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Vous sentez la douleur que subissent vos alliés. Vous avez 10% de chance de recevoir 3 sang à chaque fois qu'un allié reçoit un dégât corps à corps.|r",
        enUS = "|cffffffffHarvesting Suffering|r\n|cffffffffTalent|r |cfff2f200Blood Sacrifice|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100You sense the pain your allies endure, with a 10% chance to receive 3 blood every time an ally takes melee damage.|r"
    }
},
{
    id = "spellBloodBarrier",
    name = "buttonSpellBloodBarrier",
    icon = "Interface/icons/achievement_emeraldnightmare",
    position = {1024, -218},
    handler = "spellbloodbarrier",
    tooltips = {
        frFR = "|cffffffffBarrière de sang|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Vous éparpillez votre sang afin de protéger vos alliés, leur donnant un bouclier absorbant 2400 points de dégâts.|r",
        enUS = "|cffffffffBlood Barrier|r\n|cffffffffTalent|r |cfff2f200Blood Sacrifice|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100You scatter your blood to protect your allies, granting them a shield that absorbs 2400 damage.|r"
    }
},
{
    id = "spellAbilityImprovement",
    name = "buttonSpellAbilityImprovement",
    icon = "Interface/icons/inv_misc_clothscrap_02",
    position = {750, -273},
    handler = "spellabilityimprovement",
    tooltips = {
        frFR = "|cffffffffAptitude : Amélioration|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Vous donnez de la force à vos alliés à moins de 40 mètres, leur procurant de la puissance d'attaque à hauteur de 10% de votre force.|r",
        enUS = "|cffffffffAbility: Improvement|r\n|cffffffffTalent|r |cfff2f200Blood Sacrifice|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100You grant strength to your allies within 40 yards, providing them with attack power equal to 10% of your strength.|r"
    }
},
{
    id = "spellAbilityPotential",
    name = "buttonSpellAbilityPotential",
    icon = "Interface/icons/inv_misc_clothscrap_03",
    position = {970, -273},
    handler = "spellabilitypotential",
    tooltips = {
        frFR = "|cffffffffAptitude : Potentiel|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Vous donnez du pouvoir à vos alliés à moins de 40 mètres, leur procurant de la puissance de sort à hauteur de 10% de votre force.|r",
        enUS = "|cffffffffAbility: Potential|r\n|cffffffffTalent|r |cfff2f200Blood Sacrifice|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100You grant power to your allies within 40 yards, providing them with spell power equal to 10% of your strength.|r"
    }
},

-- CreateSpellButton("buttonSpellAbilityMotivation", "Interface/icons/spell_halo_purple", "|cffffffffAptitude : Motivation|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Canalise un puissant terrain de soutien, augmentant la vitesse de déplacement de 30% pour tout les alliés dans la zone.|r", "spellabilitymotivation", 805, -110)
-- CreateSpellButton("buttonSpellAbilityBloodFlow", "Interface/icons/sha_spell_shadow_shadesofdarkness_nightmare", "|cffffffffAptitude : Afflux de sang|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Provoque un afflux de sang soudain à la tête aux ennemis proche de vous. Etourdisant les cibles dans une portée de 8 mètres pendand 1 seconds.|r", "spellabilitybloodflow", 915, -110)
-- CreateSpellButton("buttonSpellAbilityCare", "Interface/icons/spell_halo_blue", "|cffffffffAptitude : Soins|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Canalise un puissant terrain de soutien, augmentant les soins reçus de 25% pour tout les alliés dans la zone.|r", "spellabilitycare", 750, -165)
-- CreateSpellButton("buttonSpellAbilityProtection", "Interface/icons/spell_halo_yellow", "|cffffffffAptitude : Protection|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Canalise un puissant terrain de soutien, réduisant les dégâts subit de 25% pour tout les alliés dans la zone.|r", "spellabilityprotection", 807, -218)
-- CreateSpellButton("buttonSpellAbilitySword", "Interface/icons/spell_halo_red", "|cffffffffAptitude : Epée|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Canalise un puissant terrain de soutien, augmentant les dégâts infligés de 25% pour tout les alliés dans la zone.|r", "spellabilitysword", 860, -165)
-- CreateSpellButton("buttonSpellAbilityProtector", "Interface/icons/spell_halo_green", "|cffffffffAptitude : Protecteur|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Canalise un puissant terrain de soutien, recevant l'équivalant de 30% des dégâts subit par les alliés dans la zone.|r", "spellabilityprotector", 914, -218)
-- CreateSpellButton("buttonSpellAbilityPureBlood", "Interface/icons/spell_animarevendreth_beam", "|cffffffffAptitude : Pure sang|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Canalise un puissant lien procurant à la cible 125% de dégâts prodigués.|r", "spellabilitypureblood", 970, -165)
-- CreateSpellButton("buttonSpellHarvestingSuffering", "Interface/icons/inv_misc_volatilelife", "|cffffffffRécolte de souffrance|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Vous sentez la douleur que subisse vos alliés vous avez 10% de chance de recevoir 3 sang à chaque fois qu'un allié reçoit un dégâts corps à corps.|r", "spellharvestingsuffering", 699, -218)
-- CreateSpellButton("buttonSpellBloodBarrier", "Interface/icons/achievement_emeraldnightmare", "|cffffffffBarrière de sang|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Vous éparpiller votre sang afin de protéger vos alliés leurs donnant un bouclier absorbant 2400 points de dégâts.|r", "spellbloodbarrier", 1024, -218)
-- CreateSpellButton("buttonSpellAbilityImprovement", "Interface/icons/inv_misc_clothscrap_02", "|cffffffffAptitude : Amélioration|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Vous donnez de la force à vos alliés à moins de 40 mètres, leurs procurant de la puissance d'attaque à hauteur de 10% de votre force.|r", "spellabilityimprovement", 750, -273)
-- CreateSpellButton("buttonSpellAbilityPotential", "Interface/icons/inv_misc_clothscrap_03", "|cffffffffAptitude :  Potentiel|r\n|cffffffffTalent|r |cfff2f200Sacrifice de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Vous donnez du pouvoir à vos alliés à moins de 40 mètres, leurs procurant de la puissance de sort à hauteur de 10% de votre force.|r", "spellabilitypotential", 970, -273)

-- Blessure de sang

{
    id = "spellBloodProvocation",
    name = "buttonSpellBloodProvocation",
    icon = "Interface/icons/ability_revendreth_monk",
    position = {699, -325},
    handler = "spellbloodprovocation",
    tooltips = {
        frFR = "|cffffffffProvocation sanguine|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Provoque la cible et la force à vous attaquer. Aucun effet si la cible est déjà en train de vous attaquer.|r",
        enUS = "|cffffffffBlood Provocation|r\n|cffffffffTalent|r |cff00bfffBlood Wound|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Provokes the target and forces it to attack you. No effect if the target is already attacking you.|r"
    }
},
{
    id = "spellMartialKnowledge",
    name = "buttonSpellMartialKnowledge",
    icon = "Interface/icons/spell_misc_warsongfocus",
    position = {805, -325},
    handler = "spellmartialknowledge",
    tooltips = {
        frFR = "|cffffffffConnaissance martiale|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Augmente les chances de coups critiques de 100%.|r",
        enUS = "|cffffffffMartial Knowledge|r\n|cffffffffTalent|r |cff00bfffBlood Wound|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Increases critical hit chance by 100%.|r"
    }
},
{
    id = "spellMicroBalance",
    name = "buttonSpellMicroBalance",
    icon = "Interface/icons/spell_nzinsanity_desynchronized",
    position = {915, -325},
    handler = "spellmicrobalance",
    tooltips = {
        frFR = "|cffffffffMicro-balance|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Vous compactez votre sang, réduisant votre endurance de 10%, compensant cette perte par une réduction des dégâts subis de 10%.|r",
        enUS = "|cffffffffMicro-Balance|r\n|cffffffffTalent|r |cff00bfffBlood Wound|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100You compact your blood, reducing your stamina by 10%, compensating this loss by reducing damage taken by 10%.|r"
    }
},
{
    id = "spellMortalBloodOrb",
    name = "buttonSpellMortalBloodOrb",
    icon = "Interface/icons/ability_deathwing_bloodcorruption_earth",
    position = {1025, -325},
    handler = "spellmortalbloodorb",
    tooltips = {
        frFR = "|cffffffffMortel : Orbe de sang|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Invoque une orbe de sang qui absorbe le sang des cibles dans une distance de 10 mètres de l'orbe, augmentant ainsi les saignements prodigués aux cibles de 45%.|r",
        enUS = "|cffffffffMortal: Blood Orb|r\n|cffffffffTalent|r |cff00bfffBlood Wound|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Summons a blood orb that absorbs blood from targets within 10 yards, increasing bleeding effects on targets by 45%.|r"
    }
},
{
    id = "spellMortalMultipleContusion",
    name = "buttonSpellMortalMultipleContusion",
    icon = "Interface/icons/inv_offhand_1h_revendreth_d_01",
    position = {970, -380},
    handler = "spellmortalmultiplecontusion",
    tooltips = {
        frFR = "|cffffffffMortel : Contusion multiple|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Frappe une cible avec une force considérable infligeant à la cible des contusions, lui infligeant 400 dégâts par seconde pendant 5 secondes.|r",
        enUS = "|cffffffffMortal: Multiple Contusion|r\n|cffffffffTalent|r |cff00bfffBlood Wound|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Strikes a target with considerable force, causing contusions that deal 400 damage per second for 5 seconds.|r"
    }
},
{
    id = "spellMortalSurgicalStrike",
    name = "buttonSpellMortalSurgicalStrike",
    icon = "Interface/icons/Ability_Warrior_BloodBath",
    position = {1025, -434},
    handler = "spellmortalsurgicalstrike",
    tooltips = {
        frFR = "|cffffffffMortel : Frappe chirurgicale|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Frappe une cible avec une précision et une puissance hors-normes sur les points vitaux de l'ennemi,\nCette technique demande une concentration phénoménale et consomme par conséquent votre santé pour être effectuée.\nInfligeant 400 dégâts par seconde pendant 5 secondes.|r",
        enUS = "|cffffffffMortal: Surgical Strike|r\n|cffffffffTalent|r |cff00bfffBlood Wound|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Strikes a target with extraordinary precision and power on the vital points of the enemy. This technique requires phenomenal concentration and consumes your health to perform.\nDeals 400 damage per second for 5 seconds.|r"
    }
},
{
    id = "spellMortalDestruction",
    name = "buttonSpellMortalDestruction",
    icon = "Interface/icons/ability_rogue_ruthlessness",
    position = {970, -490},
    handler = "spellmortaldestruction",
    tooltips = {
        frFR = "|cffffffffMortel : Destruction|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Inflige 500% des dégâts de l'arme ainsi que 400 points de dégâts. Utilisable uniquement si la cible se trouve en dessous de 20% de vie.|r",
        enUS = "|cffffffffMortal: Destruction|r\n|cffffffffTalent|r |cff00bfffBlood Wound|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Deals 500% of weapon damage plus 400 damage. Usable only if the target is below 20% health.|r"
    }
},
{
    id = "spellCollectingBlood",
    name = "buttonSpellCollectingBlood",
    icon = "Interface/icons/_SpellCasting_Red",
    position = {915, -434},
    handler = "spellcollectingblood",
    tooltips = {
        frFR = "|cffffffffRécolte de sang|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Lorsque vous frappez votre cible, vous avez 99% de chance de récolter 5000 points de sang.|r",
        enUS = "|cffffffffCollecting Blood|r\n|cffffffffTalent|r |cff00bfffBlood Wound|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100When you strike your target, you have a 99% chance to collect 5000 blood points.|r"
    }
},
{
    id = "spellBloodyBlood",
    name = "buttonSpellBloodyBlood",
    icon = "Interface/icons/spell_holy_dizzy",
    position = {860, -490},
    handler = "spellbloodyblood",
    tooltips = {
        frFR = "|cffffffffSanguinolent|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Augmente les chances de coups critiques de 100% pour la compétence Sanguinaire.|r",
        enUS = "|cffffffffBloody Blood|r\n|cffffffffTalent|r |cff00bfffBlood Wound|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Increases critical hit chance by 100% for the Bloodthirst ability.|r"
    }
},
{
    id = "spellBloodshed",
    name = "buttonSpellBloodshed",
    icon = "Interface/icons/inv_misc_food_legion_gooamber_drop",
    position = {750, -380},
    handler = "spellbloodshed",
    tooltips = {
        frFR = "|cffffffffEffusion de sang|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Augmente les dégâts prodigués par votre saignement Mortel : Coup multiple de 100%.|r",
        enUS = "|cffffffffBloodshed|r\n|cffffffffTalent|r |cff00bfffBlood Wound|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Increases the damage dealt by your Mortal: Multiple Strike bleed by 100%.|r"
    }
},
{
    id = "spellLethalPowerfulImpulse",
    name = "buttonSpellLethalPowerfulImpulse",
    icon = "Interface/icons/inv_thrown_1h_deathwingraid_d_01",
    position = {699, -434},
    handler = "spelllethalpowerfulimpulse",
    tooltips = {
        frFR = "|cffffffffMortel : Impulsion puissante|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Lancer votre bâton d'une telle puissance que votre cible en restera clouée au sol.\nInfligeant 4501 à 5000 dégâts ainsi que renversant la cible pendant 2.5 secondes.|r",
        enUS = "|cffffffffMortal: Powerful Impulse|r\n|cffffffffTalent|r |cff00bfffBlood Wound|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Throw your staff with such power that your target will be pinned to the ground.\nDealing 4501 to 5000 damage and knocking the target down for 2.5 seconds.|r"
    }
},
{
    id = "spellInternalHemorrhage",
    name = "buttonSpellInternalHemorrhage",
    icon = "Interface/icons/inv_misc_food_legion_gooamber_multi",
    position = {805, -434},
    handler = "spellinternalhemorrhage",
    tooltips = {
        frFR = "|cffffffffHémorragie interne|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Augmente les dégâts produits par votre saignement Mortel : Frappe chirurgicale de 100%.|r",
        enUS = "|cffffffffInternal Hemorrhage|r\n|cffffffffTalent|r |cff00bfffBlood Wound|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100Increases the damage dealt by your Mortal: Surgical Strike bleed by 100%.|r"
    }
},
{
    id = "spellAnticipatedDestruction",
    name = "buttonSpellAnticipatedDestruction",
    icon = "Interface/icons/ability_butcher_exsanguination",
    position = {750, -490},
    handler = "spellanticipateddestruction",
    tooltips = {
        frFR = "|cffffffffDestruction anticipée|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Vous avez un taux de chance (avec vos saignements) de 15% de pouvoir exécuter votre Mortel : Destruction peu importe la santé de votre ennemi, et ne vous coûtera pas de points de vie.|r",
        enUS = "|cffffffffAnticipated Destruction|r\n|cffffffffTalent|r |cff00bfffBlood Wound|r\n|cffffffffRequires|r |cffeb0000Blood Battle Mage|r\n|cffffd100You have a 15% chance (with your bleeds) to execute your Mortal: Destruction regardless of your enemy's health, and it will not cost you any health points.|r"
		}
	}
}

-- CreateSpellButton("buttonSpellBloodProvocation", "Interface/icons/ability_revendreth_monk", "|cffffffffProvocation sanguine|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Provoque la cible et la force à vous attaquer. Aucun effet si la cible est déjà en train de vous attaquer.|r", "spellbloodprovocation", 699, -325)
-- CreateSpellButton("buttonSpellMartialKnowledge", "Interface/icons/spell_misc_warsongfocus", "|cffffffffConnaissance martial|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Augmente les chances de coups critiques de 100%.|r", "spellmartialknowledge", 805, -325)
-- CreateSpellButton("buttonSpellMicroBalance", "Interface/icons/spell_nzinsanity_desynchronized", "|cffffffffMicro-balance|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Vous compactez votre sang réduisant votre endurance de 10% compensant cette perte par une réduction de dégâts subit de 10%.|r", "spellmicrobalance", 915, -325)
-- CreateSpellButton("buttonSpellMortalBloodOrb", "Interface/icons/ability_deathwing_bloodcorruption_earth", "|cffffffffMortel : Orbe de sang|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Invoque une orbe de sang qui absorbe le sang des cibles dans une distance de 10 mètre de l'orbe, augmentant ainsi les saignements prodigués aux cibles de 45%.|r", "spellmortalbloodorb", 1025, -325)
-- CreateSpellButton("buttonSpellMortalMultipleContusion", "Interface/icons/inv_offhand_1h_revendreth_d_01", "|cffffffffMortel : Contusion multiple|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Frappe une cible avec une force considérable infligeant à la cible des contusions, lui infligeant 400 dégâts par seconde pendant 5 seconds.|r", "spellmortalmultiplecontusion", 970, -380)
-- CreateSpellButton("buttonSpellMortalSurgicalStrike", "Interface/icons/Ability_Warrior_BloodBath", "|cffffffffMortel : Frappe chirurgicale|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Frappe une cible avec une précision et une puissance hors-normes sur les points vitaux de l'ennemi,\ncette technique demande une concentration phénoménale et consomme par conséquent votre santé pour être effectuée.\nInfligeant 400 par seconde pendant 5 seconds.|r", "spellmortalsurgicalstrike", 1025, -434)
-- CreateSpellButton("buttonSpellMortalDestruction", "Interface/icons/ability_rogue_ruthlessness", "|cffffffffMortel : Destruction|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Inflige 500% des dégâts de l'arme ainsi que 400 point de dégâts. Utilisable uniquement si la cible se trouve en dessous de 20% de vie.|r", "spellmortaldestruction", 970, -490)
-- CreateSpellButton("buttonSpellCollectingBlood", "Interface/icons/_SpellCasting_Red", "|cffffffffRécolte de sang|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Lorsque vous tappez votre cible vous avez 99% de chance de récolter 5000 point de sang.|r", "spellcollectingblood", 915, -434)
-- CreateSpellButton("buttonSpellBloodyBlood", "Interface/icons/spell_holy_dizzy", "|cffffffffSanguinolent|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Augmente les chances de coups critique de 100% pour la compétence Sanguinaire.|r", "spellbloodyblood", 860, -490)
-- CreateSpellButton("buttonSpellBloodshed", "Interface/icons/inv_misc_food_legion_gooamber_drop", "|cffffffffEffusion de sang|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Augmente les dégâts prodigué par votre saignement Mortel : Coup multiple de 100%.|r", "spellbloodshed", 750, -380)
-- CreateSpellButton("buttonSpellLethalPowerfulImpulse", "Interface/icons/inv_thrown_1h_deathwingraid_d_01", "|cffffffffMortel : Impulsion puissante|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Lancer votre bâton d'une telle puissance que votre cible en restera cloué au sol.\nInfligeant 4501 to 5000 dégâts ainsi que renversant la cible pendant 2.5 seconds.|r", "spelllethalpowerfulimpulse", 699, -434)
-- CreateSpellButton("buttonSpellInternalHemorrhage", "Interface/icons/inv_misc_food_legion_gooamber_multi", "|cffffffffHémorragie interne|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Augmente les dégâts produits par votre saignement Mortel : Frappe chirurgical de 100%.|r", "spellinternalhemorrhage", 805, -434)
-- CreateSpellButton("buttonSpellAnticipatedDestruction", "Interface/icons/ability_butcher_exsanguination", "|cffffffffDestruction anticipé|r\n|cffffffffTalent|r |cff00bfffBlessure de sang|r\n|cffffffffRequiert|r |cffeb0000Mage de combat sanglant|r\n|cffffd100Vous avez un taux de chance (avec vos saignements) de 15% de pouvoir éxécuter votre Mortel : Destruction peu importe la santé de votre ennemi, et ne vous couteras pas de point de vie.|r", "spellanticipateddestruction", 750, -490)

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

-- Créez le bouton Save à l'intérieur de la fenêtre frameTalentBloodbattlemage
local saveButton = CreateFrame("Button", "saveButton", frameTalentBloodbattlemage, "UIPanelButtonTemplate")
saveButton:SetSize(85, 25)
saveButton:SetPoint("BOTTOMRIGHT", buttonTalentBloodbattlemageClose, "BOTTOMLEFT", -185, 5) -- Place le bouton Save à gauche du bouton Close
saveButton:SetText(saveButtonText)

-- Fonction qui prend un screenshot quand le bouton est cliqué
saveButton:SetScript("OnClick", function()
    Screenshot()  -- Prendre un screenshot et l'enregistrer dans le dossier Screenshots du jeu
    print(screenshotMessage)  -- Affiche un message de confirmation en fonction de la locale
end)

-- Affiche l'UI des talents
--frameTalentBloodbattlemage:Show()

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

-- Créez le bouton Reset à l'intérieur de la fenêtre frameTalentBloodbattlemage
local buttonReset = CreateFrame("Button", "buttonReset", frameTalentBloodbattlemage, "UIPanelButtonTemplate")
buttonReset:SetSize(85, 25)
buttonReset:SetPoint("BOTTOMRIGHT", buttonTalentBloodbattlemageClose, "BOTTOMLEFT", -95, 5) -- Place le bouton Reset à gauche du bouton Reload
buttonReset:SetText(buttonResetText)

local function ResetTalents()
    -- Ajoutez ici la logique pour réinitialiser les talents du joueur
    AIO.Handle("TalentBloodbattlemagespell", "ResetTalents")
    resetButtonClicked = true -- Marquez le bouton Réinitialiser comme cliqué
end

buttonReset:SetScript("OnClick", ResetTalents)

-- Créez le bouton Reload à l'intérieur de la fenêtre frameTalentBloodbattlemage
local buttonReload = CreateFrame("Button", "buttonReload", frameTalentBloodbattlemage, "UIPanelButtonTemplate")
buttonReload:SetSize(85, 25)
buttonReload:SetPoint("BOTTOMRIGHT", buttonTalentBloodbattlemageClose, "BOTTOMLEFT", -5, 5) -- Place le bouton Reload à gauche du bouton Close
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
        frameTalentBloodbattlemage:Hide()
        buttonReload:Hide()
        PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
    else
        frameTalentBloodbattlemage:Show()
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
        frFR = "|cffffffffTalents|r |cffeb0000(Mage de combat sanglant)|r\n\nL'éventail des talents disponibles\npour améliorer et spécialiser\nvotre personnage.",
        enUS = "|cffffffffTalents|r |cffeb0000(Blood Battle Mage)|r\n\nThe range of available talents\nfor enhancing and specializing\nyour character."
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

-- Vérifier si le joueur est un Bloodbattlemage avant de créer le bouton
local playerClass = select(2, UnitClass("player")) -- Obtenir la classe du joueur
if playerClass == "BLOODMAGE" then
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
BloodbattlemageHandlers.UpdateTalentCount = function(player, talentsAppris)
    if fontTalentBloodbattlemageFrameText then
        fontTalentBloodbattlemageFrameText:SetText(talentsAppris .. " / " .. MAX_TALENTS)
    end
end

-- Mise à jour des points de talent utilisés avec texte localisé
BloodbattlemageHandlers.UpdateTalentPointsUsed = function(player, pointsUsed, pointsBeforeReset)
    -- Utilisation du texte localisé pour les points avant réinitialisation
    print(string.format(GetLocalizedPointsBeforeResetText(), pointsBeforeReset))
end

-- Affichage des talents restants (items 338404 dans le sac)
BloodbattlemageHandlers.UpdateTalentItemCount = function(player, count)
    if fontTalentPointsRemainingText then
        fontTalentPointsRemainingText:SetText("|cFFDD1133Talents restants : " .. count .. "|r")
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
        fontTalentPointsRemainingText:SetText("|cFFDD1133Talents restants : " .. (count or 0) .. "|r")
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
if playerClass == "BLOODMAGE" then
    -- Surcharge OnHide pour synchroniser talentsWindowOpen quand Échap est pressé
    local _originalOnHide = frameTalentBloodbattlemage:GetScript("OnHide")
    frameTalentBloodbattlemage:SetScript("OnHide", function(self)
        talentsWindowOpen = false
        if _originalOnHide then _originalOnHide(self) end
    end)
    -- WoW appelle automatiquement Hide() sur les frames listées ici quand Échap est pressé
    tinsert(UISpecialFrames, "frameTalentBloodbattlemage")
end