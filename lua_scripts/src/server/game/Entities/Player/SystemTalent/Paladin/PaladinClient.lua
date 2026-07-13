local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local PaladinHandlers = AIO.AddHandlers("TalentPaladinspell", {})

function PaladinHandlers.ShowTalentPaladin(player)
    frameTalentPaladin:Show()
    -- Redemande au serveur l’état visuel au cas où
    AIO.Handle("TalentPaladinspell", "RequestLearnedTalents")
	-- Redemande le nombre de talents restants
    AIO.Handle("TalentPaladinspell", "GetTalentItemCount")
end

local MAX_TALENTS = 60 -- Définition du nombre maximal de talents que le joueur peut apprendre

local OPEN_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_final_trait_unlocked.ogg"
local CLOSE_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_trait_refund_end.ogg"
local SPELL_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_80_azeritearmor_rotationends_02.ogg"

-- Attribute window
local frameTalentPaladin = CreateFrame("Frame", "frameTalentPaladin", UIParent)
frameTalentPaladin:SetSize(1200, 650)
frameTalentPaladin:SetMovable(true)
frameTalentPaladin:EnableMouse(true)
frameTalentPaladin:RegisterForDrag("LeftButton")
frameTalentPaladin:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, -50) -- Adjust the X and Y coordinates
frameTalentPaladin:SetBackdrop(
{
    -- bgFile = "interface/TalentFrame/talentsclassbackgroundPaladin", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    bgFile = "interface/TalentFrame/Template/Class/Paladin/talentsclassbackgroundpaladin3", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedpaladin", --Interface/DialogFrame/UI-DialogBox-Border
    edgeSize = 20,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})

-- Ajoutez la texture de l'icône du Paladin
local paladinIcon = frameTalentPaladin:CreateTexture("PaladinIcon", "OVERLAY")
paladinIcon:SetTexture("Interface\\TalentFrame\\Template\\Class\\Paladin\\IconePaladin.blp")
paladinIcon:SetSize(60, 60)
paladinIcon:SetPoint("TOPLEFT", frameTalentPaladin, "TOPLEFT", -10, 10)

-- Template Talent Frame

-- Ajoute une textureone pour l'image BLP
local textureone = frameTalentPaladin:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
textureone:SetTexture("Interface\\TalentFrame\\Template\\Class\\Paladin\\TalentFrameTemplate.blp")
textureone:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
textureone:SetPoint("TOPLEFT", frameTalentPaladin, "TOPLEFT", -170, 140) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentPaladin:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Ajoute une texturetwo pour l'image BLP
local texturetwo = frameTalentPaladin:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
texturetwo:SetTexture("Interface\\TalentFrame\\Template\\Class\\Paladin\\TalentFrameTemplateOriginal.blp")
texturetwo:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
texturetwo:SetPoint("TOPRIGHT", frameTalentPaladin, "TOPRIGHT", 170, 140) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentPaladin:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Drag & Drop
frameTalentPaladin:SetScript("OnDragStart", frameTalentPaladin.StartMoving)
frameTalentPaladin:SetScript("OnHide", frameTalentPaladin.StopMovingOrSizing)
frameTalentPaladin:SetScript("OnDragStop", frameTalentPaladin.StopMovingOrSizing)
frameTalentPaladin:Hide()

-- Nouveau template d'arête
frameTalentPaladin:SetBackdropBorderColor(135, 135, 237) -- Couleur pourpre

-- Close button
local buttonTalentPaladinClose = CreateFrame("Button", "buttonTalentPaladinClose", frameTalentPaladin, "UIPanelCloseButton")
buttonTalentPaladinClose:SetPoint("TOPRIGHT", -12, -12)
buttonTalentPaladinClose:EnableMouse(true)
buttonTalentPaladinClose:SetSize(32, 32)

local function CloseTalentWindow()
    frameTalentPaladin:Hide()
    PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
end

-- Associez la fonction de fermeture au bouton de fermeture
buttonTalentPaladinClose:SetScript("OnClick", CloseTalentWindow)

-- Title bar
local frameTalentPaladinTitleBar = CreateFrame("Frame", "frameTalentPaladinTitleBar", frameTalentPaladin, nil)
frameTalentPaladinTitleBar:SetSize(135, 25)
frameTalentPaladinTitleBar:SetBackdrop(
{
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedpaladin",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentPaladinTitleBar:SetPoint("TOP", 0, 20)

local fontTalentPaladinTitleText = frameTalentPaladinTitleBar:CreateFontString("fontTalentPaladinTitleText")
fontTalentPaladinTitleText:SetFont("Fonts\\FRIZQT__.TTF", 13)
fontTalentPaladinTitleText:SetSize(190, 5)
fontTalentPaladinTitleText:SetPoint("CENTER", 0, 0)
fontTalentPaladinTitleText:SetText("|cffFFC125Talents|r")

-- Détecte la langue du client
local locale = GetLocale() -- Retourne "enUS", "frFR", etc.

-- Table des traductions
local localizedTexts = {
    enUS = "|cffFFC125Paladin|r",
    frFR = "|cffFFC125Paladin|r",
}

-- Récupère le texte correspondant à la langue actuelle ou par défaut en anglais
local textToDisplay = localizedTexts[locale] or localizedTexts["enUS"]

local fontTalentPaladinFrameText = frameTalentPaladinTitleBar:CreateFontString("fontTalentPaladinFrameText")
fontTalentPaladinFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentPaladinFrameText:SetSize(200, 5)
fontTalentPaladinFrameText:SetPoint("TOPLEFT", frameTalentPaladinTitleBar, "BOTTOMLEFT", -30, -35) -- Adjust the Y offset as needed
fontTalentPaladinFrameText:SetText(textToDisplay)

-- Remplacez votre ligne existante pour la création du texte par celle-ci
local fontTalentPaladinFrameText = frameTalentPaladinTitleBar:CreateFontString("fontTalentPaladinFrameText")
fontTalentPaladinFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentPaladinFrameText:SetSize(200, 5)
fontTalentPaladinFrameText:SetPoint("TOPLEFT", frameTalentPaladinTitleBar, "BOTTOMLEFT", -30, -60) -- Adjust the Y offset as needed
fontTalentPaladinFrameText:SetText("0 / " .. MAX_TALENTS) -- Initialisez le texte avec 0 talents appris

-------------------------------------------------------------
-- Affichage "Talents restants" (item 338404 dans le sac)
-------------------------------------------------------------

local frameTalentPointsRemaining = CreateFrame("Frame", "frameTalentPointsRemaining", frameTalentPaladin, nil)
frameTalentPointsRemaining:SetSize(220, 30)
frameTalentPointsRemaining:SetBackdrop({
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedpaladin",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentPointsRemaining:SetPoint("BOTTOMRIGHT", frameTalentPaladin, "BOTTOMRIGHT", -960, 10)

local fontTalentPointsRemainingText = frameTalentPointsRemaining:CreateFontString("fontTalentPointsRemainingText")
fontTalentPointsRemainingText:SetFont("Fonts\\FRIZQT__.TTF", 14)
fontTalentPointsRemainingText:SetSize(210, 20)
fontTalentPointsRemainingText:SetPoint("CENTER", 0, 0)
fontTalentPointsRemainingText:SetText("|cFFF58CBATalents restants : 0|r")
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
PaladinHandlers.UpdateLearnedTalents = function(player, learnedSpells)
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

    local button = CreateFrame("Button", name, frameTalentPaladin, nil)
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
                AIO.Handle("TalentPaladinspell", talentHandler, 1)
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

-- Sacré

-- Table des sorts
local spells = {
{
    id = "spellSpiritualFocus",
    name = "buttonSpellSpiritualFocus",
    icon = "Interface/icons/spell_arcane_blink",
    position = {100, -80},
    handler = "spellspiritualfocus",
    tooltips = {
        frFR = "|cffffffffFocalisation spirituelle|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit de 70% l'interruption causée par les attaques infligeant des dégâts pendant que vous incantez Lumière sacrée et Eclair lumineux.|r",
        enUS = "|cffffffffSpiritual Focus|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Reduces the interruption caused by damage-dealing attacks while casting Holy Light and Flash of Light by 70%.|r"
    }
},

{
    id = "spellSealsofthePure",
    name = "buttonSpellSealsofthePure",
    icon = "Interface/icons/ability_thunderbolt",
    position = {205, -75},
    handler = "spellsealsofthepure",
    tooltips = {
        frFR = "|cffffffffSceaux des purs|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente de 15% les dégâts infligés par vos Sceaux de piété, de vengeance et de corruption ainsi que les effets de leurs Jugements.|r",
        enUS = "|cffffffffSeals of the Pure|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases the damage dealt by your Seals of Righteousness, Vengeance, and Corruption as well as the effects of their Judgements by 15%.|r"
    }
},

{
    id = "spellHealingLight",
    name = "buttonSpellHealingLight",
    icon = "Interface/icons/spell_holy_holybolt",
    position = {315, -75},
    handler = "spellhealinglight",
    tooltips = {
        frFR = "|cffffffffLumière guérisseuse|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente le montant de points de vie rendus par vos sorts Lumière sacrée et Eclair lumineux ainsi que l'efficacité des sorts Horion sacré de 12%.|r",
        enUS = "|cffffffffHealing Light|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases the amount of healing done by your Holy Light and Flash of Light spells as well as the effectiveness of your Holy Shock spells by 12%.|r"
    }
},

{
    id = "spellDivineIntellect",
    name = "buttonSpellDivineIntellect",
    icon = "Interface/icons/spell_nature_sleep",
    position = {418, -80},
    handler = "spelldivineintellect",
    tooltips = {
        frFR = "|cffffffffIntelligence divine|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente votre total d'Intelligence de 10%.|r",
        enUS = "|cffffffffDivine Intellect|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases your total Intelligence by 10%.|r"
    }
},

{
    id = "spellUnyieldingFaith",
    name = "buttonSpellUnyieldingFaith",
    icon = "Interface/icons/spell_holy_unyieldingfaith",
    position = {45, -130},
    handler = "spellunyieldingfaith",
    tooltips = {
        frFR = "|cffffffffFoi inflexible|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit de 30% la durée de tous les effets de Peur et de Désorientation.|r",
        enUS = "|cffffffffUnyielding Faith|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Reduces the duration of all Fear and Disorient effects by 30%.|r"
    }
},
{
    id = "spellAuraMastery",
    name = "buttonSpellAuraMastery",
    icon = "Interface/icons/spell_holy_auramastery",
    position = {150, -130},
    handler = "spellauramastery",
    tooltips = {
        frFR = "|cffffffffMaîtrise des auras|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Permet à votre Aura de concentration de rendre toutes les cibles affectées insensibles aux effets de silence et d'interruption ainsi que d'améliorer les effets de toutes les autres auras de 100%.\nDure 6 secondes.|r",
        enUS = "|cffffffffAura Mastery|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Allows your Concentration Aura to make all affected targets immune to silence and interrupt effects, and increases the effects of all other auras by 100%.\nLasts 6 seconds.|r"
    }
},

{
    id = "spellIllumination",
    name = "buttonSpellIllumination",
    icon = "Interface/icons/spell_holy_greaterheal",
    position = {260, -130},
    handler = "spellillumination",
    tooltips = {
        frFR = "|cffffffffIllumination|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Lorsque vous obtenez un effet critique avec Eclair lumineux, Lumière sacrée, ou le sort de soins Horion sacré,\nvous avez 100% de chances de recevoir un montant de mana égal à 30% du coût de base du sort.|r",
        enUS = "|cffffffffIllumination|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100When you score a critical hit with Flash of Light, Holy Light, or the healing spell Holy Shock, you have a 100% chance to gain mana equal to 30% of the spell's base cost.|r"
    }
},

{
    id = "spellImprovedLayonHands",
    name = "buttonSpellImprovedLayonHands",
    icon = "Interface/icons/spell_holy_layonhands",
    position = {370, -130},
    handler = "spellimprovedlayonhands",
    tooltips = {
        frFR = "|cffffffffImposition des mains améliorée|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100La cible de votre sort Imposition des mains bénéficie d'une réduction de 20% des dégâts physiques qu'elle subit pendant 15 secondes.\nDe plus, le temps de recharge de votre sort Imposition des mains est réduit de 4 min.|r",
        enUS = "|cffffffffImproved Lay on Hands|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100The target of your Lay on Hands spell receives a 20% reduction in physical damage taken for 15 seconds.\nAdditionally, the cooldown of your Lay on Hands is reduced by 4 minutes.|r"
    }
},

{
    id = "spellImprovedConcentrationAura",
    name = "buttonSpellImprovedConcentrationAura",
    icon = "Interface/icons/spell_holy_mindsooth",
    position = {475, -133},
    handler = "spellimprovedconcentrationaura",
    tooltips = {
        frFR = "|cffffffffAura de concentration améliorée|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente de 15% supplémentaires l'effet de votre Aura de concentration, et tant que n'importe quelle Aura est active,\nréduit de 30% la durée de tout effet de silence ou d'interruption utilisé contre un membre du groupe affecté.\nLa réduction de durée ne se cumule avec aucun autre effet.|r",
        enUS = "|cffffffffImproved Concentration Aura|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases the effect of your Concentration Aura by an additional 15%, and while any Aura is active, reduces the duration of all silence or interrupt effects used against a group member by 30%.\nThis duration reduction does not stack with any other effect.|r"
    }
},

{
    id = "spellImprovedBlessingofWisdom",
    name = "buttonSpellImprovedBlessingofWisdom",
    icon = "Interface/icons/spell_holy_sealofwisdom",
    position = {96, -185},
    handler = "spellimprovedblessingofwisdom",
    tooltips = {
        frFR = "|cffffffffBénédiction de sagesse améliorée|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente l'effet de votre sort Bénédiction de sagesse de 20%.|r",
        enUS = "|cffffffffImproved Blessing of Wisdom|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases the effect of your Blessing of Wisdom spell by 20%.|r"
    }
},
{
    id = "spellBlessedHands",
    name = "buttonSpellBlessedHands",
    icon = "Interface/icons/ability_paladin_blessedhands",
    position = {205, -185},
    handler = "spellblessedhands",
    tooltips = {
        frFR = "|cffffffffMains bénies|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit le coût en mana de Main de liberté, Main de sacrifice et Main de salut de 30% en plus d'augmenter l'efficacité de Main de salut de 100% et celle de Main de sacrifice de 10% supplémentaires.|r",
        enUS = "|cffffffffBlessed Hands|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Reduces the mana cost of Hand of Freedom, Hand of Sacrifice, and Hand of Salvation by 30%, and increases the effectiveness of Hand of Salvation by 100% and Hand of Sacrifice by an additional 10%.|r"
    }
},

{
    id = "spellPureofHeart",
    name = "buttonSpellPureofHeart",
    icon = "Interface/icons/spell_holy_pureofheart",
    position = {315, -185},
    handler = "spellpureofheart",
    tooltips = {
        frFR = "|cffffffffPur de coeur|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit de 30% la durée des effets de malédiction, de maladie et de poison.|r",
        enUS = "|cffffffffPure of Heart|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Reduces the duration of Curse, Disease, and Poison effects by 30%.|r"
    }
},

{
    id = "spellDivineFavor",
    name = "buttonSpellDivineFavor",
    icon = "Interface/icons/spell_holy_heal",
    position = {422, -185},
    handler = "spelldivinefavor",
    tooltips = {
        frFR = "|cffffffffFaveur divine|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Une fois activé, confère 100% de chances à votre prochain sort Eclair lumineux, Lumière sacrée ou Horion sacré d'avoir un effet critique.|r",
        enUS = "|cffffffffDivine Favor|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100When activated, gives your next Flash of Light, Holy Light, or Holy Shock a 100% chance to critically strike.|r"
    }
},

{
    id = "spellSanctifiedLight",
    name = "buttonSpellSanctifiedLight",
    icon = "Interface/icons/spell_holy_healingaura",
    position = {527, -190},
    handler = "spellsanctifiedlight",
    tooltips = {
        frFR = "|cffffffffLumière sanctifiée|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente de 6% vos chances de réaliser un effet critique avec vos sorts Lumière sacrée et Horion sacré.|r",
        enUS = "|cffffffffSanctified Light|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases your critical strike chance with Holy Light and Holy Shock by 6%.|r"
    }
},

{
    id = "spellPurifyingPower",
    name = "buttonSpellPurifyingPower",
    icon = "Interface/icons/spell_holy_purifyingpower",
    position = {43, -240},
    handler = "spellpurifyingpower",
    tooltips = {
        frFR = "|cffffffffPuissance purifiante|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit de 10% le coût en mana de vos sorts Epuration, Purification et Consécration et réduit de 33% le temps de recharge de vos sorts Exorcisme et Colère divine.|r",
        enUS = "|cffffffffPurifying Power|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Reduces the mana cost of your Cleanse, Purify, and Consecration by 10%, and reduces the cooldown of Exorcism and Divine Wrath by 33%.|r"
    }
},
{
    id = "spellHolyPower",
    name = "buttonSpellHolyPower",
    icon = "Interface/icons/spell_holy_power",
    position = {150, -240},
    handler = "spellholypower",
    tooltips = {
        frFR = "|cffffffffPuissance sacrée|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente les chances d'obtenir un effet critique avec vos sorts du Sacré de 5%.|r",
        enUS = "|cffffffffHoly Power|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases your chance to critically strike with your Holy spells by 5%.|r"
    }
},

{
    id = "spellLightsGrace",
    name = "buttonSpellLightsGrace",
    icon = "Interface/icons/spell_holy_lightsgrace",
    position = {368, -240},
    handler = "spelllightsgrace",
    tooltips = {
        frFR = "|cffffffffPuissance purifiante|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit de 10% le coût en mana de vos sorts Epuration, Purification et Consécration et réduit de 33% le temps de recharge de vos sorts Exorcisme et Colère divine.|r",
        enUS = "|cffffffffLights Grace|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Reduces the mana cost of your Cleanse, Purify, and Consecration by 10%, and reduces the cooldown of Exorcism and Divine Wrath by 33%.|r"
    }
},

{
    id = "spellHolyShock",
    name = "buttonSpellHolyShock",
    icon = "Interface/icons/spell_holy_searinglight",
    position = {478, -240},
    handler = "spellholyshock",
    tooltips = {
        frFR = "|cffffffffHorion sacré|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100L'énergie sacrée frappe la cible et inflige 314 à 340 points de dégâts du Sacré à un ennemi, ou bien rend à un allié 481 à 519 points de vie.|r",
        enUS = "|cffffffffHoly Shock|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Holy energy strikes the target, dealing 314 to 340 Holy damage to an enemy, or healing an ally for 481 to 519 health.|r"
    }
},

{
    id = "spellBlessedLife",
    name = "buttonSpellBlessedLife",
    icon = "Interface/icons/spell_holy_blessedlife",
    position = {98, -293},
    handler = "spellblessedlife",
    tooltips = {
        frFR = "|cffffffffVie bénie|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Vous confère 10% de chances que les attaques contre vous n'infligent que la moitié des dégâts.|r",
        enUS = "|cffffffffBlessed Life|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Gives you a 10% chance to have attacks against you deal only half the damage.|r"
    }
},

{
    id = "spellSacredCleansing",
    name = "buttonSpellSacredCleansing",
    icon = "Interface/icons/ability_paladin_sacredcleansing",
    position = {205, -293},
    handler = "spellsacredcleansing",
    tooltips = {
        frFR = "|cffffffffPurification sacrée|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Votre sort Epuration a 30% de chances d'augmenter la résistance de la cible aux maladies, à la magie et au poison de 30% pendant 10 secondes.|r",
        enUS = "|cffffffffSacred Cleansing|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Your Cleanse spell has a 30% chance to increase the target's resistance to Disease, Magic, and Poison by 30% for 10 seconds.|r"
    }
},
{
    id = "spellHolyGuidance",
    name = "buttonSpellHolyGuidance",
    icon = "Interface/icons/spell_holy_holyguidance",
    position = {315, -293},
    handler = "spellholyguidance",
    tooltips = {
        frFR = "|cffffffffSoutien sacré|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente la puissance de vos sorts de 20% de votre total d'Intelligence.|r",
        enUS = "|cffffffffHoly Guidance|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases the power of your spells by 20% of your total Intelligence.|r"
    }
},

{
    id = "spellDivineIllumination",
    name = "buttonSpellDivineIllumination",
    icon = "Interface/icons/spell_holy_divineillumination",
    position = {422, -293},
    handler = "spelldivineillumination",
    tooltips = {
        frFR = "|cffffffffIllumination divine|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit le coût en mana de tous les sorts de 50% pendant 15 secondes.|r",
        enUS = "|cffffffffDivine Illumination|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Reduces the mana cost of all your spells by 50% for 15 seconds.|r"
    }
},

{
    id = "spellJudgementsofthePure",
    name = "buttonSpellJudgementsofthePure",
    icon = "Interface/icons/ability_paladin_judgementofthepure",
    position = {527, -295},
    handler = "spelljudgementsofthepure",
    tooltips = {
        frFR = "|cffffffffJugements des purs|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente les dégâts infligés par vos sorts de Sceau et de Jugement de 25%, et vos sorts de Jugement augmentent votre vitesse d'incantation et votre hâte en mêlée de 15% pendant 60 secondes.|r",
        enUS = "|cffffffffJudgements of the Pure|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases the damage of your Seal and Judgement spells by 25%, and your Judgement spells increase your casting speed and melee haste by 15% for 60 seconds.|r"
    }
},

{
    id = "spellInfusionofLight",
    name = "buttonSpellInfusionofLight",
    icon = "Interface/icons/ability_paladin_infusionoflight",
    position = {43, -350},
    handler = "spellinfusionoflight",
    tooltips = {
        frFR = "|cffffffffImprégnation de lumière|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Vos coups critiques avec Horion sacré réduisent le temps d'incantation de votre prochain sort Eclair lumineux de 1,5 sec.\nou augmentent les chances de critique de votre prochaine Lumière sacrée de 20%.\nDe plus, votre Eclair lumineux rend aux cibles affectées par Bouclier saint 100% de points de vie supplémentaires en 12 secondes.|r",
        enUS = "|cffffffffInfusion of Light|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Your critical hits with Holy Shock reduce the cast time of your next Holy Light by 1.5 seconds, or increase the crit chance of your next Holy Light by 20%. Additionally, your Holy Light heals targets affected by Sacred Shield for 100% more for 12 seconds.|r"
    }
},

{
    id = "spellEnlightenedJudgements",
    name = "buttonSpellEnlightenedJudgements",
    icon = "Interface/icons/ability_paladin_enlightenedjudgements",
    position = {150, -350},
    handler = "spellenlightenedjudgements",
    tooltips = {
        frFR = "|cffffffffJugements éclairés|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente de 30 mètres la portée de votre Jugement de Lumière et de votre Jugement de sagesse en plus d'augmenter de 4% vos chances de toucher.|r",
        enUS = "|cffffffffEnlightened Judgements|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases the range of your Judgement of Light and Judgement of Wisdom by 30 yards, and increases your chance to hit by 4%.|r"
    }
},
{
    id = "spellBeaconofLight",
    name = "buttonSpellBeaconofLight",
    icon = "Interface/icons/ability_paladin_beaconoflight",
    position = {260, -350},
    handler = "spellbeaconoflight",
    tooltips = {
        frFR = "|cffffffffGuide de lumière|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100La cible devient un guide de lumière pour tous les membres de votre groupe ou raid se trouvant dans un rayon de 60 mètres.\nTous les soins que vous lancez sur ces cibles soignent également le Guide pour un montant de points de vie égal à 100% des soins prodigués.\nUne seule cible à la fois peut être le Guide de lumière.\nDure 60 secondes.|r",
        enUS = "|cffffffffBeacon of Light|r\n|cffffffffTalent|r |cffffff80Holy|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100The target becomes a Beacon of Light for all members of your group or raid within 60 yards.\nAll healing you do on these targets also heals the Beacon for an amount equal to 100% of the healing done.\nOnly one target can be the Beacon at a time.\nLasts for 60 seconds.|r"
    }
},

{
    id = "spellDivinity",
    name = "buttonSpellDivinity",
    icon = "Interface/icons/spell_holy_blindingheal",
    position = {368, -350},
    handler = "spelldivinity",
    tooltips = {
        frFR = "|cffffffffDivinité|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente tous les soins que vous prodiguez et tous les effets de soins sur vous de 5%.|r",
        enUS = "|cffffffffDivinity|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases all healing you do and all healing effects on you by 5%.|r"
    }
},

{
    id = "spellDivineStrength",
    name = "buttonDivineStrength",
    icon = "Interface/icons/ability_golemthunderclap",
    position = {478, -350},
    handler = "spelldivinestrength",
    tooltips = {
        frFR = "|cffffffffForce divine|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente votre total de Force de 15%.|r",
        enUS = "|cffffffffDivine Strength|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases your total Strength by 15%.|r"
    }
},


-- CreateSpellButton("buttonSpellSpiritualFocus", "Interface/icons/spell_arcane_blink", "|cffffffffFocalisation spirituelle|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit de 70% l'interruption causée par les attaques infligeant des dégâts pendant que vous incantez Lumière sacrée et Eclair lumineux.|r", "spellspiritualfocus", 100, -80)
-- CreateSpellButton("buttonSpellSealsofthePure", "Interface/icons/ability_thunderbolt", "|cffffffffSceaux des purs|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente de 15% les dégâts infligés par vos Sceaux de piété, de vengeance et de corruption ainsi que les effets de leurs Jugements.|r", "spellsealsofthepure", 205, -75)
-- CreateSpellButton("buttonSpellHealingLight", "Interface/icons/spell_holy_holybolt", "|cffffffffLumière guérisseuse|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente le montant de points de vie rendus par vos sorts Lumière sacrée et Eclair lumineux ainsi que l'efficacité des sorts Horion sacré de 12%.|r", "spellhealinglight", 315, -75)
-- CreateSpellButton("buttonSpellDivineIntellect", "Interface/icons/spell_nature_sleep", "|cffffffffIntelligence divine|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente votre total d'Intelligence de 10%.|r", "spelldivineintellect", 418, -80)
-- CreateSpellButton("buttonSpellUnyieldingFaith", "Interface/icons/spell_holy_unyieldingfaith", "|cffffffffFoi inflexible|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit de 30% la durée de tous les effets de Peur et de Désorientation.|r", "spellunyieldingfaith", 45, -130)
-- CreateSpellButton("buttonSpellAuraMastery", "Interface/icons/spell_holy_auramastery", "|cffffffffMaîtrise des auras|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Permet à votre Aura de concentration de rendre toutes les cibles affectées insensibles aux effets de silence et d'interruption ainsi que d'améliorer les effets de toutes les autres auras de 100%.\nDure 6 secondes.|r", "spellauramastery", 150, -130)
-- CreateSpellButton("buttonSpellIllumination", "Interface/icons/spell_holy_greaterheal", "|cffffffffIllumination|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Lorsque vous obtenez un effet critique avec Eclair lumineux, Lumière sacrée, ou le sort de soins Horion sacré, vous avez 100% de chances de recevoir un montant de mana égal à 30% du coût de base du sort.|r", "spellillumination", 260, -130)
-- CreateSpellButton("buttonSpellImprovedLayonHands", "Interface/icons/spell_holy_layonhands", "|cffffffffImposition des mains améliorée|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100La cible de votre sort Imposition des mains bénéficie d'une réduction de 20% des dégâts physiques qu'elle subit pendant 15 secondes.\nDe plus, le temps de recharge de votre sort Imposition des mains est réduit de 4 min.|r", "spellimprovedlayonhands", 370, -130)
-- CreateSpellButton("buttonSpellImprovedConcentrationAura", "Interface/icons/spell_holy_mindsooth", "|cffffffffAura de concentration améliorée|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente de 15% supplémentaires l'effet de votre Aura de concentration, et tant que n'importe quelle Aura est active, réduit de 30% la durée de tout effet de silence ou d'interruption utilisé contre un membre du groupe affecté.\nLa réduction de durée ne se cumule avec aucun autre effet.|r", "spellimprovedconcentrationaura", 475, -133)
-- CreateSpellButton("buttonSpellImprovedBlessingofWisdom", "Interface/icons/spell_holy_sealofwisdom", "|cffffffffBénédiction de sagesse améliorée|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente l'effet de votre sort Bénédiction de sagesse de 20%.|r", "spellimprovedblessingofwisdom", 96, -185)
-- CreateSpellButton("buttonSpellBlessedHands", "Interface/icons/ability_paladin_blessedhands", "|cffffffffMains bénies|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit le coût en mana de Main de liberté, Main de sacrifice et Main de salut de 30% en plus d'augmenter l'efficacité de Main de salut de 100% et celle de Main de sacrifice de 10% supplémentaires.|r", "spellblessedhands", 205, -185)
-- CreateSpellButton("buttonSpellPureofHeart", "Interface/icons/spell_holy_pureofheart", "|cffffffffPur de coeur|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit de 30% la durée des effets de malédiction, de maladie et de poison.|r", "spellpureofheart", 315, -185)
-- CreateSpellButton("buttonSpellDivineFavor", "Interface/icons/spell_holy_heal", "|cffffffffFaveur divine|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Une fois activé, confère 100% de chances à votre prochain sort Eclair lumineux, Lumière sacrée ou Horion sacré d'avoir un effet critique.|r", "spelldivinefavor", 422, -185)
-- CreateSpellButton("buttonSpellSanctifiedLight", "Interface/icons/spell_holy_healingaura", "|cffffffffLumière sanctifiée|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente de 6% vos chances de réaliser un effet critique avec vos sorts Lumière sacrée et Horion sacré.|r", "spellsanctifiedlight", 527, -190)
-- CreateSpellButton("buttonSpellPurifyingPower", "Interface/icons/spell_holy_purifyingpower", "|cffffffffPuissance purifiante|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit de 10% le coût en mana de vos sorts Epuration, Purification et Consécration et réduit de 33% le temps de recharge de vos sorts Exorcisme et Colère divine.|r", "spellpurifyingpower", 43, -240)
-- CreateSpellButton("buttonSpellHolyPower", "Interface/icons/spell_holy_power", "|cffffffffPuissance sacrée|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente les chances d'obtenir un effet critique avec vos sorts du Sacré de 5%.|r", "spellholypower", 150, -240)
-- CreateSpellButton("buttonSpellLightsGrace", "Interface/icons/spell_holy_lightsgrace", "|cffffffffPuissance purifiante|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit de 10% le coût en mana de vos sorts Epuration, Purification et Consécration et réduit de 33% le temps de recharge de vos sorts Exorcisme et Colère divine.|r", "spelllightsgrace", 368, -240)
-- CreateSpellButton("buttonSpellHolyShock", "Interface/icons/spell_holy_searinglight", "|cffffffffHorion sacré|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100L'énergie sacrée frappe la cible et inflige 314 à 340 points de dégâts du Sacré à un ennemi, ou bien rend à un allié 481 à 519 points de vie.|r", "spellholyshock", 478, -240)
-- CreateSpellButton("buttonSpellBlessedLife", "Interface/icons/spell_holy_blessedlife", "|cffffffffVie bénie|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Vous confère 10% de chances que les attaques contre vous n'infligent que la moitié des dégâts.|r", "spellblessedlife", 98, -293)
-- CreateSpellButton("buttonSpellSacredCleansing", "Interface/icons/ability_paladin_sacredcleansing", "|cffffffffPurification sacrée|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Votre sort Epuration a 30% de chances d'augmenter la résistance de la cible aux maladies, à la magie et au poison de 30% pendant 10 secondes.|r", "spellsacredcleansing", 205, -293)
-- CreateSpellButton("buttonSpellHolyGuidance", "Interface/icons/spell_holy_holyguidance", "|cffffffffSoutien sacré|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente la puissance de vos sorts de 20% de votre total d'Intelligence.|r", "spellholyguidance", 315, -293)
-- CreateSpellButton("buttonSpellDivineIllumination", "Interface/icons/spell_holy_divineillumination", "|cffffffffIllumination divine|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit le coût en mana de tous les sorts de 50% pendant 15 secondes.|r", "spelldivineillumination", 422, -293)
-- CreateSpellButton("buttonSpellJudgementsofthePure", "Interface/icons/ability_paladin_judgementofthepure", "|cffffffffJugements des purs|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente les dégâts infligés par vos sorts de Sceau et de Jugement de 25%, et vos sorts de Jugement augmentent votre vitesse d'incantation et votre hâte en mêlée de 15% pendant 60 secondes.|r", "spelljudgementsofthepure", 527, -295)
-- CreateSpellButton("buttonSpellInfusionofLight", "Interface/icons/ability_paladin_infusionoflight", "|cffffffffImprégnation de lumière|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Vos coups critiques avec Horion sacré réduisent le temps d'incantation de votre prochain sort Eclair lumineux de 1,5 sec.\nou augmentent les chances de critique de votre prochaine Lumière sacrée de 20%.\nDe plus, votre Eclair lumineux rend aux cibles affectées par Bouclier saint 100% de points de vie supplémentaires en 12 secondes.|r", "spellinfusionoflight", 43, -350)
-- CreateSpellButton("buttonSpellEnlightenedJudgements", "Interface/icons/ability_paladin_enlightenedjudgements", "|cffffffffJugements éclairés|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente de 30 mètres la portée de votre Jugement de Lumière et de votre Jugement de sagesse en plus d'augmenter de 4% vos chances de toucher.", "spellenlightenedjudgements", 150, -350)
-- CreateSpellButton("buttonSpellBeaconofLight", "Interface/icons/ability_paladin_beaconoflight", "|cffffffffGuide de lumière|r\n|cffffffffTalent|r |cffffff80Sacré|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100La cible devient un guide de lumière pour tous les membres de votre groupe ou raid se trouvant dans un rayon de 60 mètres.\nTous les soins que vous lancez sur ces cibles soignent également le Guide pour un montant de points de vie égal à 100% des soins prodigués.\nUne seule cible à la fois peut être le Guide de lumière.\nDure 60 secondes.|r", "spellbeaconoflight", 260, -350)
-- CreateSpellButton("buttonSpellDivinity", "Interface/icons/spell_holy_blindingheal", "|cffffffffDivinité|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente tous les soins que vous prodiguez et tous les effets de soins sur vous de 5%.|r", "spelldivinity", 368, -350)
-- CreateSpellButton("buttonDivineStrength", "Interface/icons/ability_golemthunderclap", "|cffffffffForce divine|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente votre total de Force de 15%.|r", "spelldivinestrength", 478, -350)

-- Protection

{
    id = "spellStoicism",
    name = "buttonSpellStoicism",
    icon = "Interface/icons/spell_holy_stoicism",
    position = {98, -405},
    handler = "spellstoicism",
    tooltips = {
        frFR = "|cffffffffStoïcisme|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit la durée de tous les effets d'étourdissement de 30% supplémentaires, et réduit la probabilité que vos sorts utiles et vos effets de dégâts sur la durée soient dissipés de 30% supplémentaires.|r",
        enUS = "|cffffffffStoicism|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Reduces the duration of all stuns by an additional 30%, and reduces the chance for your beneficial spells and damage over time effects to be dispelled by an additional 30%.|r"
    }
},

{
    id = "spellGuardiansFavor",
    name = "buttonSpellGuardiansFavor",
    icon = "Interface/icons/spell_holy_sealofprotection",
    position = {205, -405},
    handler = "spellguardiansfavor",
    tooltips = {
        frFR = "|cffffffffFaveur du Gardien|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit le temps de recharge de votre Main de protection de 2 min.\net augmente la durée de votre Main de liberté de 4 sec.|r",
        enUS = "|cffffffffGuardians' Favor|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Reduces the cooldown of your Hand of Protection by 2 minutes, and increases the duration of your Hand of Freedom by 4 seconds.|r"
    }
},

{
    id = "spellAnticipation",
    name = "buttonSpellAnticipation",
    icon = "Interface/icons/spell_magic_lesserinvisibilty",
    position = {315, -405},
    handler = "spellanticipation",
    tooltips = {
        frFR = "|cffffffffAnticipation|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente vos chances d'esquiver de 5%.|r",
        enUS = "|cffffffffAnticipation|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases your chance to dodge by 5%.|r"
    }
},

{
    id = "spellDivineSacrifice",
    name = "buttonSpellDivineSacrifice",
    icon = "Interface/icons/spell_holy_powerwordbarrier",
    position = {422, -405},
    handler = "spelldivinesacrifice",
    tooltips = {
        frFR = "|cffffffffSacrifice divin|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd10030% de tous les dégâts subis par les membres du groupe se trouvant à moins de 30 mètres\nsont redirigés vers le paladin (jusqu'à un maximum de 40% des points de vie du paladin multiplié par le nombre de membres du groupe).\nLes dégâts qui font passer le paladin sous les 20% de points de vie interrompent l'effet.\nDure 10 secondes.|r",
        enUS = "|cffffffffDivine Sacrifice|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd10030% of all damage taken by group members within 30 yards is redirected to the paladin (up to a maximum of 40% of the paladin's health, multiplied by the number of group members).\nDamage that reduces the paladin's health below 20% interrupts the effect.\nLasts for 10 seconds.|r"
    }
},

{
    id = "spellImprovedRighteousFury",
    name = "buttonSpellImprovedRighteousFury",
    icon = "Interface/icons/spell_holy_sealoffury",
    position = {43, -458},
    handler = "spellimprovedrighteousfury",
    tooltips = {
        frFR = "|cffffffffFureur vertueuse améliorée|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Tant que la Fureur vertueuse est active, tous les dégâts subis sont réduits de 6%.|r",
        enUS = "|cffffffffImproved Righteous Fury|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100While Righteous Fury is active, all damage taken is reduced by 6%.|r"
    }
},
{
    id = "spellToughness",
    name = "buttonSpellToughness",
    icon = "Interface/icons/spell_holy_devotion",
    position = {150, -458},
    handler = "spelltoughness",
    tooltips = {
        frFR = "|cffffffffRésistance|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente la valeur d'armure des objets de 10% et réduit la durée de tous les effets affectant le déplacement de 30%.|r",
        enUS = "|cffffffffToughness|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases the armor value of your gear by 10%, and reduces the duration of all movement-affecting effects by 30%.|r"
    }
},

{
    id = "spellDivineGuardian",
    name = "buttonSpellDivineGuardian",
    icon = "Interface/icons/spell_holy_powerwordbarrier",
    position = {260, -458},
    handler = "spelldivineguardian",
    tooltips = {
        frFR = "|cffffffffGardien divin|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Lorsque Sacrifice divin est actif, les membres de votre groupe ou raid dans un rayon de 30 mètres subissent 20% de dégâts en moins pendant 6 secondes.\nDe plus, augmente la durée de votre Bouclier saint de 100% et le montant absorbé de 20%.|r",
        enUS = "|cffffffffDivine Guardian|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100When Divine Sacrifice is active, all members of your group or raid within 30 yards take 20% less damage for 6 seconds.\nAdditionally, increases the duration of your Divine Shield by 100% and the amount absorbed by 20%.|r"
    }
},

{
    id = "spellImprovedHammerofJustice",
    name = "buttonSpellImprovedHammerofJustice",
    icon = "Interface/icons/spell_holy_sealofmight",
    position = {368, -458},
    handler = "spellimprovedhammerofjustice",
    tooltips = {
        frFR = "|cffffffffMarteau de la justice amélioré|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit le temps de recharge de votre sort Marteau de la justice de 20 sec.|r",
        enUS = "|cffffffffImproved Hammer of Justice|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Reduces the cooldown of your Hammer of Justice by 20 seconds.|r"
    }
},

{
    id = "spellImprovedDevotionAura",
    name = "buttonSpellImprovedDevotionAura",
    icon = "Interface/icons/spell_holy_devotionaura",
    position = {478, -458},
    handler = "spellimproveddevotionaura",
    tooltips = {
        frFR = "|cffffffffAura de dévotion améliorée|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente de 50% le bonus d'armure que confère votre Aura de dévotion et augmente de 6% le montant de points de vie rendus à toute cible affectée par une de vos Auras.|r",
        enUS = "|cffffffffImproved Devotion Aura|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases the armor bonus granted by your Devotion Aura by 50%, and increases the amount of health restored to any target affected by your Auras by 6%.|r"
    }
},

{
    id = "spellBlessingofSanctuary",
    name = "buttonSpellBlessingofSanctuary",
    icon = "Interface/icons/spell_nature_lightningshield",
    position = {98, -510},
    handler = "spellblessingofsanctuary",
    tooltips = {
        frFR = "|cffffffffBénédiction du sanctuaire|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Place une Bénédiction sur la cible alliée qui réduit les dégâts infligés par toutes les sources de 3% pendant 10 mn et augmente la Force et l'Endurance de 10%.\nDe plus, quand la cible bloque, pare ou esquive une attaque de mêlée, la cible reçoit 2% de son mana maximum affiché.\nLes personnages ne peuvent bénéficier que des effets d'une seule Bénédiction par paladin à la fois.|r",
        enUS = "|cffffffffBlessing of Sanctuary|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Places a Blessing on the target that reduces damage taken from all sources by 3% for 10 minutes and increases Strength and Stamina by 10%. Additionally, when the target blocks, parries, or dodges a melee attack, they receive 2% of their maximum mana.\nOnly one Blessing per paladin can be on a target at a time.|r"
    }
},
{
    id = "spellReckoning",
    name = "buttonSpellReckoning",
    icon = "Interface/icons/spell_holy_blessingofstrength",
    position = {205, -510},
    handler = "spellreckoning",
    tooltips = {
        frFR = "|cffffffffRétribution|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Confère 10% de chances lorsque vous êtes victime d'une attaque qui vous inflige des dégâts\nou que vous l'avez bloquée de bénéficier d'une attaque supplémentaire avec les 4 frappes suivantes dans les 8 secondes.|r",
        enUS = "|cffffffffReckoning|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Grants a 10% chance that when you are hit by an attack or block it, you will gain an additional attack with your next 4 strikes within 8 seconds.|r"
    }
},

{
    id = "spellSacredDuty",
    name = "buttonSpellSacredDuty",
    icon = "Interface/icons/spell_holy_divineintervention",
    position = {315, -510},
    handler = "spellsacredduty",
    tooltips = {
        frFR = "|cffffffffDevoir sacré|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente votre total d'Endurance de 4% et réduit le temps de recharge de vos sorts Bouclier divin et Protection divine de 60 sec.|r",
        enUS = "|cffffffffSacred Duty|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases your Stamina by 4% and reduces the cooldown of your Divine Shield and Divine Protection by 60 seconds.|r"
    }
},

{
    id = "spellOneHandedWeaponSpecialization",
    name = "buttonSpellOneHandedWeaponSpecialization",
    icon = "Interface/icons/inv_sword_20",
    position = {422, -510},
    handler = "spellonehandedweaponspecialization",
    tooltips = {
        frFR = "|cffffffffSpécialisation Arme 1M|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente tous les dégâts que vous infligez de 10% quand une arme de mêlée à une main est équipée.|r",
        enUS = "|cffffffffOne-Handed Weapon Specialization|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases all damage you deal by 10% when a one-handed melee weapon is equipped.|r"
    }
},


-- CreateSpellButton("buttonSpellStoicism", "Interface/icons/spell_holy_stoicism", "|cffffffffStoïcisme|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit la durée de tous les effets d'étourdissement de 30% supplémentaires, et réduit la probabilité que vos sorts utiles et vos effets de dégâts sur la durée soient dissipés de 30% supplémentaires.|r", "spellstoicism", 98, -405)
-- CreateSpellButton("buttonSpellGuardiansFavor", "Interface/icons/spell_holy_sealofprotection", "|cffffffffFaveur du Gardien|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit le temps de recharge de votre Main de protection de 2 min.\net augmente la durée de votre Main de liberté de 4 sec.|r", "spellguardiansfavor", 205, -405)
-- CreateSpellButton("buttonSpellAnticipation", "Interface/icons/spell_magic_lesserinvisibilty", "|cffffffffAnticipation|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente vos chances d'esquiver de 5%..|r", "spellanticipation", 315, -405)
-- CreateSpellButton("buttonSpellDivineSacrifice", "Interface/icons/spell_holy_powerwordbarrier", "|cffffffffSacrifice divin|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd10030% de tous les dégâts subis par les membres du groupe se trouvant à moins de 30 mètres sont redirigés vers le paladin (jusqu'à un maximum de 40% des points de vie du paladin multiplié par le nombre de membres du groupe).\nLes dégâts qui font passer le paladin sous les 20% de points de vie interrompent l'effet.\nDure 10 seconds.|r", "spelldivinesacrifice", 422, -405)
-- CreateSpellButton("buttonSpellImprovedRighteousFury", "Interface/icons/spell_holy_sealoffury", "|cffffffffFureur vertueuse améliorée|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Tant que la Fureur vertueuse est active, tous les dégâts subis sont réduits de 6%.|r", "spellimprovedrighteousfury", 43, -458)
-- CreateSpellButton("buttonSpellToughness", "Interface/icons/spell_holy_devotion", "|cffffffffRésistance|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente la valeur d'armure des objets de 10% et réduit la durée de tous les effets affectant le déplacement de 30%.|r", "spelltoughness", 150, -458)
-- CreateSpellButton("buttonSpellDivineGuardian", "Interface/icons/spell_holy_powerwordbarrier", "|cffffffffGardien divin|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Lorsque Sacrifice divin est actif, les membres de votre groupe ou raid dans un rayon de 30 mètres subissent 20% de dégâts en moins pendant 6 secondes.\nDe plus, augmente la durée de votre Bouclier saint de 100% et le montant absorbé de 20%.|r", "spelldivineguardian", 260, -458)
-- CreateSpellButton("buttonSpellImprovedHammerofJustice", "Interface/icons/spell_holy_sealofmight", "|cffffffffMarteau de la justice amélioré|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit le temps de recharge de votre sort Marteau de la justice de 20 sec.|r", "spellimprovedhammerofjustice", 368, -458)
-- CreateSpellButton("buttonSpellImprovedDevotionAura", "Interface/icons/spell_holy_devotionaura", "|cffffffffAura de dévotion améliorée|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente de 50% le bonus d'armure que confère votre Aura de dévotion et augmente de 6% le montant de points de vie rendus à toute cible affectée par une de vos Auras.|r", "spellimproveddevotionaura", 478, -458)
-- CreateSpellButton("buttonSpellBlessingofSanctuary", "Interface/icons/spell_nature_lightningshield", "|cffffffffBénédiction du sanctuaire|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Place une Bénédiction sur la cible alliée qui réduit les dégâts infligés par toutes les sources de 3% pendant 10 mn et augmente la Force et l'Endurance de 10%.\nDe plus, quand la cible bloque, pare ou esquive une attaque de mêlée, la cible reçoit 2% de son mana maximum affiché.\nLes personnages ne peuvent bénéficier que des effets d'une seule Bénédiction par paladin à la fois.|r", "spellblessingofsanctuary", 98, -510)
-- CreateSpellButton("buttonSpellReckoning", "Interface/icons/spell_holy_blessingofstrength", "|cffffffffRétribution|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Confère 10% de chances lorsque vous êtes victime d'une attaque qui vous inflige des dégâts ou que vous l'avez bloquée de bénéficier d'une attaque supplémentaire avec les 4 frappes suivantes dans les 8 seconds.|r", "spellreckoning", 205, -510)
-- CreateSpellButton("buttonSpellSacredDuty", "Interface/icons/spell_holy_divineintervention", "|cffffffffDevoir sacré|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente votre total d'Endurance de 4% et réduit le temps de recharge de vos sorts Bouclier divin et Protection divine de 60 sec..|r", "spellsacredduty", 315, -510)
-- CreateSpellButton("buttonSpellOneHandedWeaponSpecialization", "Interface/icons/inv_sword_20", "|cffffffffSpécialisation Arme 1M|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente tous les dégâts que vous infligez de 10% quand une arme de mêlée à une main est équipée.|r", "spellonehandedweaponspecialization", 422, -510)

-- Template 2

{
    id = "spellSpiritualAttunement",
    name = "buttonSpiritualAttunement",
    icon = "Interface/icons/spell_holy_revivechampion",
    position = {663, -75},
    handler = "spellimprovedscorch",
    tooltips = {
        frFR = "|cffffffffHarmonisation spirituelle|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Une technique passive qui donne des points de mana au paladin lorsqu'il est soigné par les sorts d'autres cibles alliées.\nLa quantité de mana reçue est égale à 10% des points de vie rendus.|r",
        enUS = "|cffffffffSpiritual Attunement|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100A passive technique that gives mana to the paladin when healed by other allied targets' spells.\nThe amount of mana received is equal to 10% of the health restored.|r"
    }
},

{
    id = "spellHolyShield",
    name = "buttonSpellHolyShield",
    icon = "Interface/icons/spell_holy_blessingofprotection",
    position = {770, -75},
    handler = "spellholyshield",
    tooltips = {
        frFR = "|cffffffffBouclier sacré|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente les chances de bloquer de 30% pendant 10 secondes et inflige 79 points de dégâts du Sacré pour chaque attaque bloquée pendant qu'il est actif.\nChaque blocage dépense une charge.\n8 charges.|r",
        enUS = "|cffffffffHoly Shield|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases your block chance by 30% for 10 seconds and inflicts 79 Holy damage for each attack blocked while active.\nEach block consumes one charge.\n8 charges.|r"
    }
},

{
    id = "spellArdentDefender",
    name = "buttonSpellArdentDefender",
    icon = "Interface/icons/spell_holy_ardentdefender",
    position = {880, -75},
    handler = "spellardentdefender",
    tooltips = {
        frFR = "|cffffffffArdent défenseur|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Les dégâts qui vous font descendre sous les 35% de points de vie sont réduits de 20%.\nDe plus, les attaques qui normalement vous tueraient vous rendent jusqu'à 30% de votre maximum de points de vie (en fonction de votre défense).\nCet effet de soins ne peut se produire plus d'une fois toutes les 120 secondes.|r",
        enUS = "|cffffffffArdent Defender|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Damage that would reduce you below 35% health is reduced by 20%.\nAdditionally, attacks that would normally kill you heal you for up to 30% of your maximum health (based on your defense).\nThis healing effect cannot occur more than once every 120 seconds.|r"
    }
},

{
    id = "spellRedoubt",
    name = "buttonSpellRedoubt",
    icon = "Interface/icons/ability_defend",
    position = {990, -75},
    handler = "spellredoubt",
    tooltips = {
        frFR = "|cffffffffRedoute|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente votre valeur de blocage de 30% et les attaques en mêlée et à distance contre vous qui infligent des dégâts ont 10% de chances d’augmenter vos chances de blocage de 30%.\nDure 10 secondes ou bloque 5 attaques.|r",
        enUS = "|cffffffffRedoubt|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases your block value by 30% and melee and ranged attacks against you that deal damage have a 10% chance to increase your block chance by 30%.\nLasts 10 seconds or blocks 5 attacks.|r"
    }
},

{
    id = "spellCombatExpertise",
    name = "buttonSpellCombatExpertise",
    icon = "Interface/icons/spell_holy_weaponmastery",
    position = {1100, -75},
    handler = "spellcombatexpertise",
    tooltips = {
        frFR = "|cffffffffExpertise en combat|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente votre expertise de 6, ainsi que votre total d'Endurance et vos chances de coup critique de 6%.|r",
        enUS = "|cffffffffCombat Expertise|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases your expertise by 6, as well as your Stamina and Critical Strike Chance by 6%.|r"
    }
},
{
    id = "spellTouchedbytheLight",
    name = "buttonSpellTouchedbytheLight",
    icon = "Interface/icons/ability_paladin_touchedbylight",
    position = {718, -130},
    handler = "spelltouchedbythelight",
    tooltips = {
        frFR = "|cffffffffTouché par la Lumière|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente votre puissance des sorts d'un montant égal à 60% de votre Force et augmente les points de vie rendus par vos soins critiques de 30%.|r",
        enUS = "|cffffffffTouched by the Light|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases your spell power by an amount equal to 60% of your Strength and increases the healing done by your critical heals by 30%.|r"
    }
},

{
    id = "spellAvengersShield",
    name = "buttonSpellAvengersShield",
    icon = "Interface/icons/spell_holy_avengersshield",
    position = {825, -130},
    handler = "spellavengersshield",
    tooltips = {
        frFR = "|cffffffffBouclier du vengeur|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Lance sur un ennemi un bouclier sacré qui inflige de 501 à 597 points de dégâts du Sacré, l'hébète et rebondit ensuite sur des ennemis proches.\nLe sort frappe 3 cibles au total.\nDure 10 secondes.|r",
        enUS = "|cffffffffAvenger's Shield|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Throws a holy shield at an enemy dealing 501 to 597 Holy damage, stunning them and then bouncing to nearby enemies.\nThe spell hits 3 targets in total.\nLasts 10 seconds.|r"
    }
},

{
    id = "spellGuardedbytheLight",
    name = "buttonSpellGuardedbytheLight",
    icon = "Interface/icons/ability_paladin_gaurdedbythelight",
    position = {935, -130},
    handler = "spellguardedbythelight",
    tooltips = {
        frFR = "|cffffffffGardé par la Lumière|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit les dégâts des sorts subis de 6% et confère 100% de chances de réinitialiser la durée de votre Supplique divine lorsque vous touchez un ennemi.\nDe plus, le risque que votre Supplique divine soit dissipée est réduit de 100%.|r",
        enUS = "|cffffffffGuarded by the Light|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Reduces spell damage taken by 6% and grants 100% chance to reset the duration of your Divine Plea when you strike an enemy.\nAdditionally, the chance for your Divine Plea to be dispelled is reduced by 100%.|r"
    }
},

{
    id = "spellShieldoftheTemplar",
    name = "buttonSpellShieldoftheTemplar",
    icon = "Interface/icons/ability_paladin_shieldofthetemplar",
    position = {1045, -130},
    handler = "spellthieldofthetemplar",
    tooltips = {
        frFR = "|cffffffffBouclier du templier|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit tous les dégâts subis de 3% et confère à votre Bouclier du vengeur 100% de chances de réduire vos cibles au silence pendant 3 secondes.|r",
        enUS = "|cffffffffShield of the Templar|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Reduces all damage taken by 3% and gives your Avenger's Shield 100% chance to silence your targets for 3 seconds.|r"
    }
},

{
    id = "spellJudgementsoftheJust",
    name = "buttonSpellJudgementsoftheJust",
    icon = "Interface/icons/ability_paladin_judgementsofthejust",
    position = {663, -184},
    handler = "spelljudgementsofthejust",
    tooltips = {
        frFR = "|cffffffffJugements des justes|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit le temps de recharge de votre Marteau de la justice de 10 sec., augmente la durée de l'effet de votre Sceau de justice de 1 sec.\nDe plus, vos sorts de Jugement réduisent également la vitesse d'attaque en mêlée de la cible de 20%.|r",
        enUS = "|cffffffffJudgements of the Just|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Reduces the cooldown of your Hammer of Justice by 10 seconds, increases the duration of your Seal of Justice effect by 1 second.\nAdditionally, your Judgement spells also reduce the target's melee attack speed by 20%.|r"
    }
},
{
    id = "spellHammeroftheRighteous",
    name = "buttonSpellHammeroftheRighteous",
    icon = "Interface/icons/ability_paladin_hammeroftherighteous",
    position = {770, -184},
    handler = "spellhammeroftherighteous",
    tooltips = {
        frFR = "|cffffffffMarteau du vertueux|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Frappe avec un marteau la cible actuelle ainsi que 2 cibles proches supplémentaires au plus, infligeant 4 fois par seconde les dégâts de votre arme en main droite sous forme de dégâts du Sacré.|r",
        enUS = "|cffffffffHammer of the Righteous|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Strikes the current target and up to 2 additional nearby targets, dealing 4 attacks per second with your main hand weapon's damage as Holy damage.|r"
    }
},

{
    id = "spellDeflection",
    name = "buttonSpellDeflection",
    icon = "Interface/icons/ability_parry",
    position = {880, -184},
    handler = "spelldeflection",
    tooltips = {
        frFR = "|cffffffffDéviation|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente vos chances de Parer de 5%.|r",
        enUS = "|cffffffffDeflection|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases your Parry chance by 5%.|r"
    }
},

{
    id = "spellBenediction",
    name = "buttonSpellBenediction",
    icon = "Interface/icons/spell_frost_windwalkon",
    position = {990, -184},
    handler = "spellbenediction",
    tooltips = {
        frFR = "|cffffffffBénédiction|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit le coût en mana de tous les sorts à l'incantation instantanée de 10%.|r",
        enUS = "|cffffffffBenediction|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Reduces the mana cost of all instant-cast spells by 10%.|r"
    }
},

{
    id = "spellImprovedJudgements",
    name = "buttonSpellImprovedJudgements",
    icon = "Interface/icons/spell_holy_righteousfury",
    position = {1100, -184},
    handler = "spellimprovedjudgements",
    tooltips = {
        frFR = "|cffffffffJugements améliorés|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit le temps de recharge de vos sorts de Jugement de 2 sec.|r",
        enUS = "|cffffffffImproved Judgements|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Reduces the cooldown of your Judgement spells by 2 seconds.|r"
    }
},

-- CreateSpellButton("buttonSpiritualAttunement", "Interface/icons/spell_holy_revivechampion", "|cffffffffHarmonisation spirituelle|r\n|cffffffffTalent|r |cff0080ffProtectionProtectionProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Une technique passive qui donne des points de mana au paladin lorsqu'il est soigné par les sorts d'autres cibles alliées.\nLa quantité de mana reçue est égale à 10% des points de vie rendus.|r", "spellimprovedscorch", 663, -75)
-- CreateSpellButton("buttonSpellHolyShield", "Interface/icons/spell_holy_blessingofprotection", "|cffffffffBouclier sacré|r\n|cffffffffTalent|r |cff0080ffProtectionProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente les chances de bloquer de 30% pendant 10 secondes et inflige 79 points de dégâts du Sacré pour chaque attaque bloquée pendant qu'il est actif.\nChaque blocage dépense une charge.\n8 charges.|r", "spellholyshield", 770, -75)
-- CreateSpellButton("buttonSpellArdentDefender", "Interface/icons/spell_holy_ardentdefender", "|cffffffffArdent défenseur|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Les dégâts qui vous font descendre sous les 35% de points de vie sont réduits de 20%.\nDe plus, les attaques qui normalement vous tueraient vous rendent jusqu'à 30% de votre maximum de points de vie (en fonction de votre défense).\nCet effet de soins ne peut se produire plus d'une fois toutes les 120 seconds.|r", "spellardentdefender", 880, -75)
-- CreateSpellButton("buttonSpellRedoubt", "Interface/icons/ability_defend", "|cffffffffRedoute|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente votre valeur de blocage de 30% et les attaques en mêlée et à distance contre vous qui infligent des dégâts ont 10% de chances d’augmenter vos chances de blocage de 30%.\nDure 10 secondes ou bloque 5 attaques.|r", "spellredoubt", 990, -75)
-- CreateSpellButton("buttonSpellCombatExpertise", "Interface/icons/spell_holy_weaponmastery", "|cffffffffExpertise en combat|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente votre expertise de 6, ainsi que votre total d'Endurance et vos chances de coup critique de 6%.|r", "spellcombatexpertise", 1100, -75)
-- CreateSpellButton("buttonSpellTouchedbytheLight", "Interface/icons/ability_paladin_touchedbylight", "|cffffffffTouché par la Lumière|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente votre puissance des sorts d'un montant égal à 60% de votre Force et augmente les points de vie rendus par vos soins critiques de 30%.|r", "spelltouchedbythelight", 718, -130)
-- CreateSpellButton("buttonSpellAvengersShield", "Interface/icons/spell_holy_avengersshield", "|cffffffffBouclier du vengeur|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Lance sur un ennemi un bouclier sacré qui inflige de 501 à 597 points de dégâts du Sacré, l'hébète et rebondit ensuite sur des ennemis proches.\nLe sort frappe 3 cibles au total.\nDure 10 secondes.|r", "spellavengersshield", 825, -130)
-- CreateSpellButton("buttonSpellGuardedbytheLight", "Interface/icons/ability_paladin_gaurdedbythelight", "|cffffffffGardé par la Lumière|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit les dégâts des sorts subis de 6% et confère 100% de chances de réinitialiser la durée de votre Supplique divine lorsque vous touchez un ennemi.\nDe plus, le risque que votre Supplique divine soit dissipée est réduit de 100%.|r", "spellguardedbythelight", 935, -130)
-- CreateSpellButton("buttonSpellShieldoftheTemplar", "Interface/icons/ability_paladin_shieldofthetemplar", "|cffffffffBouclier du templier|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit tous les dégâts subis de 3% et confère à votre Bouclier du vengeur 100% de chances de réduire vos cibles au silence pendant 3 secondes.|r", "spellthieldofthetemplar", 1045, -130)
-- CreateSpellButton("buttonSpellJudgementsoftheJust", "Interface/icons/ability_paladin_judgementsofthejust", "|cffffffffJugements des justes|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit le temps de recharge de votre Marteau de la justice de 10 sec., augmente la durée de l'effet de votre Sceau de justice de 1 sec.\net vos sorts de Jugement réduisent également la vitesse d'attaque en mêlée de la cible de 20%.|r", "spelljudgementsofthejust", 663, -184)
-- CreateSpellButton("buttonSpellHammeroftheRighteous", "Interface/icons/ability_paladin_hammeroftherighteous", "|cffffffffMarteau du vertueux|r\n|cffffffffTalent|r |cff0080ffProtection|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Frappe avec un marteau la cible actuelle ainsi que 2 cibles proches supplémentaires au plus, infligeant 4 fois par seconde les dégâts de votre arme en main droite sous forme de dégâts du Sacré.|r", "spellhammeroftherighteous", 770, -184)
-- CreateSpellButton("buttonSpellDeflection", "Interface/icons/ability_parry", "|cffffffffDéviation|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente vos chances de Parer de 5%.|r", "spelldeflection", 880, -184)
-- CreateSpellButton("buttonSpellBenediction", "Interface/icons/spell_frost_windwalkon", "|cffffffffBénédiction|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit le coût en mana de tous les sorts à l'incantation instantanée de 10%.|r", "spellbenediction", 990, -184)
-- CreateSpellButton("buttonSpellImprovedJudgements", "Interface/icons/spell_holy_righteousfury", "|cffffffffJugements améliorés|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit le temps de recharge de vos sorts de Jugement de 2 sec.", "spellimprovedjudgements", 1100, -184)


-- Vindicte

{
    id = "spellHeartoftheCrusader",
    name = "buttonSpellHeartoftheCrusader",
    icon = "Interface/icons/spell_holy_holysmite",
    position = {718, -240},
    handler = "spellheartofthecrusader",
    tooltips = {
        frFR = "|cffffffffCoeur du Croisé|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100En plus des effets normaux, vos sorts de Jugement augmentent de 3% supplémentaires les chances de coup critique de toutes les attaques effectuées contre cette cible.|r",
        enUS = "|cffffffffHeart of the Crusader|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100In addition to normal effects, your Judgement spells increase the critical strike chance of all attacks against the target by an additional 3%.|r"
    }
},

{
    id = "spellImprovedBlessingofMight",
    name = "buttonSpellImprovedBlessingofMight",
    icon = "Interface/icons/spell_holy_fistofjustice",
    position = {825, -240},
    handler = "spellimprovedblessingofmight",
    tooltips = {
        frFR = "|cffffffffBénédiction de puissance améliorée|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente le bonus à la puissance d'attaque conféré par votre Bénédiction de puissance de 25%.|r",
        enUS = "|cffffffffImproved Blessing of Might|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases the attack power bonus granted by your Blessing of Might by 25%.|r"
    }
},

{
    id = "spellVindication",
    name = "buttonSpellVindication",
    icon = "Interface/icons/spell_holy_vindication",
    position = {935, -240},
    handler = "spellindication",
    tooltips = {
        frFR = "|cffffffffJustification|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Confère aux attaques du paladin qui infligent des dégâts une chance de réduire la puissance d'attaque de la cible de 46 pendant 10 secondes.|r",
        enUS = "|cffffffffVindication|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Gives your damaging attacks a chance to reduce the target's attack power by 46 for 10 seconds.|r"
    }
},

{
    id = "spellConviction",
    name = "buttonSpellConviction",
    icon = "Interface/icons/spell_holy_retributionaura",
    position = {1045, -240},
    handler = "spellconviction",
    tooltips = {
        frFR = "|cffffffffConviction|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente vos chances d'infliger un coup critique avec tous les sorts et les attaques de 5%.|r",
        enUS = "|cffffffffConviction|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases your chance to critically hit with all spells and attacks by 5%.|r"
    }
},

{
    id = "spellSealofCommand",
    name = "buttonSpellSealofCommand",
    icon = "Interface/icons/ability_warrior_innerrage",
    position = {663, -293},
    handler = "spellsealofcommand",
    tooltips = {
        frFR = "|cffffffffSceau d'autorité|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Toutes les attaques en mêlée infligent de 53 à 54 points de dégâts du Sacré supplémentaires.\nQuand il est utilisé avec des attaques ou techniques qui frappent une cible unique, ces dégâts du Sacré supplémentaires s'abattent sur un maximum de 2 cibles supplémentaires.\nDure 30 mn.\nLibérez l'énergie de ce Sceau pour juger un ennemi et lui infliger instantanément de 107 à 108 points de dégâts du Sacré.|r",
        enUS = "|cffffffffSeal of Command|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100All melee attacks deal an additional 53 to 54 Holy damage.\nWhen used with single-target attacks or abilities, this Holy damage hits up to 2 additional targets.\nLasts 30 minutes.\nRelease the energy of this Seal to Judgement an enemy and deal 107 to 108 Holy damage instantly.|r"
    }
},
{
    id = "spellPursuitofJustice",
    name = "buttonSpellPursuitofJustice",
    icon = "Interface/icons/spell_holy_persuitofjustice",
    position = {770, -293},
    handler = "spellpursuitofjustice",
    tooltips = {
        frFR = "|cffffffffPoursuite de la justice|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit la durée de tous les effets de désarmement de 50% et augmente votre vitesse de déplacement et la vitesse de déplacement de votre monture de 15%.\nNe s'additionne pas avec les autres effets qui augmentent la vitesse de déplacement.|r",
        enUS = "|cffffffffPursuit of Justice|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Reduces the duration of all disarm effects by 50% and increases your movement speed and mount speed by 15%.\nDoes not stack with other movement speed-increasing effects.|r"
    }
},

{
    id = "spellEyeforanEye",
    name = "buttonSpellEyeforanEye",
    icon = "Interface/icons/spell_holy_eyeforaneye",
    position = {990, -293},
    handler = "spelleyeforaneye",
    tooltips = {
        frFR = "|cffffffffOeil pour oeil|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Tous les coups critiques contre vous infligent également 10% des dégâts que vous subissez à l'attaquant.\nLes points de dégâts causés par Oeil pour oeil ne peuvent excéder 50% du total des points de vie du paladin.|r",
        enUS = "|cffffffffEye for an Eye|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100All critical strikes against you deal 10% of the damage you take to the attacker.\nThe damage dealt by Eye for an Eye cannot exceed 50% of the Paladin's total health.|r"
    }
},

{
    id = "spellSanctityofBattle",
    name = "buttonSpellSanctityofBattle",
    icon = "Interface/icons/spell_holy_holysmite",
    position = {1100, -293},
    handler = "spellsanctityofbattle",
    tooltips = {
        frFR = "|cffffffffBataille sainte|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente vos chances de réussir des coups critiques avec tous les sorts et attaques de 3% et augmente les dégâts infligés par Exorcisme et Inquisition de 15%.|r",
        enUS = "|cffffffffSanctity of Battle|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases your chance to critically hit with all spells and attacks by 3% and increases the damage dealt by Exorcism and Inquisition by 15%.|r"
    }
},

{
    id = "spellCrusade",
    name = "buttonSpellCrusade",
    icon = "Interface/icons/spell_holy_crusade",
    position = {718, -348},
    handler = "spellcrusade",
    tooltips = {
        frFR = "|cffffffffCroisade|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente tous les dégâts infligés de 3% et tous les dégâts infligés aux humanoïdes, démons, morts-vivants et élémentaires de 3% supplémentaires.|r",
        enUS = "|cffffffffCrusade|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases all damage dealt by 3%, and increases damage dealt to Humanoids, Demons, Undead, and Elementals by an additional 3%.|r"
    }
},

{
    id = "spellTwoHandedWeaponSpecialization",
    name = "buttonSpellTwoHandedWeaponSpecialization",
    icon = "Interface/icons/inv_hammer_04",
    position = {825, -348},
    handler = "spelltwohandedweaponspecialization",
    tooltips = {
        frFR = "|cffffffffSpécialisation Arme 2M|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente les points de dégâts que vous infligez avec les armes de mêlée à deux mains de 6%.|r",
        enUS = "|cffffffffTwo-Handed Weapon Specialization|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases the damage dealt with two-handed melee weapons by 6%.|r"
    }
},
{
    id = "spellSanctifiedRetribution",
    name = "buttonSpellSanctifiedRetribution",
    icon = "Interface/icons/spell_holy_mindvision",
    position = {935, -348},
    handler = "spellsanctifiedretribution",
    tooltips = {
        frFR = "|cffffffffVindicte sanctifiée|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente les dégâts infligés par Aura de vindicte de 50%, et tous les dégâts infligés par les cibles alliées affectées par l'une de vos Auras sont augmentés de 3%.|r",
        enUS = "|cffffffffSanctified Retribution|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases the damage dealt by Retribution Aura by 50%, and all damage dealt by allied targets affected by any of your Auras is increased by 3%.|r"
    }
},

{
    id = "spellVengeance",
    name = "buttonSpellVengeance",
    icon = "Interface/icons/ability_racial_avatar",
    position = {1045, -348},
    handler = "spellvengeance",
    tooltips = {
        frFR = "|cffffffffVengeance|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Après un coup critique obtenu en frappant avec une arme, ou avec un sort ou une technique, vous infligez 3% de points de dégâts physiques et du Sacré supplémentaires pendant 30 secondes.\nCet effet est cumulable jusqu'à 3 fois.|r",
        enUS = "|cffffffffVengeance|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100After a critical hit with a weapon, spell, or ability, you deal 3% additional Physical and Holy damage for 30 seconds.\nThis effect stacks up to 3 times.|r"
    }
},

{
    id = "spellDivinePurpose",
    name = "buttonSpellDivinePurpose",
    icon = "Interface/icons/spell_holy_divinepurpose",
    position = {663, -402},
    handler = "spelldivinepurpose",
    tooltips = {
        frFR = "|cffffffffDessein divin|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit la probabilité que vous soyez touché par les sorts et les attaques à distance de 4% et confère à votre sort Main de liberté 100% de chances d'annuler tous les effets d'étourdissement sur la cible.|r",
        enUS = "|cffffffffDivine Purpose|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Reduces the chance to be hit by spells and ranged attacks by 4% and grants your Hand of Freedom 100% chance to remove all stun effects from the target.|r"
    }
},

{
    id = "spellTheArtofWar",
    name = "buttonSpellTheArtofWar",
    icon = "Interface/icons/ability_paladin_artofwar",
    position = {770, -402},
    handler = "spelltheartofwar",
    tooltips = {
        frFR = "|cffffffffL'art de la guerre|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente les dégâts de vos techniques de Jugement, Inquisition et Tempête divine de 10%,\net quand vous réussissez un coup critique avec vos attaques de mêlée, votre prochain sort Eclair lumineux ou Exorcisme est instantané.|r",
        enUS = "|cffffffffThe Art of War|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases the damage of your Judgment, Inquisition, and Divine Storm abilities by 10%, and when you score a critical hit with your melee attacks, your next Holy Shock or Exorcism is instant cast.|r"
    }
},

{
    id = "spellRepentance",
    name = "buttonSpellRepentance",
    icon = "Interface/icons/spell_holy_prayerofhealing",
    position = {880, -402},
    handler = "spellrepentance",
    tooltips = {
        frFR = "|cffffffffRepentir|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Plonge la cible ennemie dans une transe méditative qui la stupéfie pendant 60 secondes.\nau maximum et annule l'effet de Vengeance vertueuse.\nSi la cible subit des dégâts, elle se réveille.\nNe fonctionne que sur les démons, les draconiens, les géants, les humanoïdes et les morts-vivants.|r",
        enUS = "|cffffffffRepentance|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Places the enemy target in a meditative trance that incapacitates them for up to 60 seconds and removes the effect of Divine Vengeance.\nIf the target takes damage, they will awaken.\nWorks only on Demons, Draconians, Giants, Humanoids, and Undead.|r"
    }
},
{
    id = "spellJudgementsoftheWise",
    name = "buttonSpellJudgementsoftheWise",
    icon = "Interface/icons/ability_paladin_judgementofthewise",
    position = {990, -402},
    handler = "spelljudgementsofthewise",
    tooltips = {
        frFR = "|cffffffffJugements des sages|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Vos sorts de Jugement infligeant des dégâts ont 100% de chances de conférer à jusqu'à 10 membres du groupe ou raid l'effet Requinquage,\nqui les fait bénéficier d'une régénération de mana égale à 1% de leur maximum de mana toutes les 5 sec.\npendant 15 secondes., ainsi que de vous rendre instantanément 25% de votre mana de base.|r",
        enUS = "|cffffffffJudgements of the Wise|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Your Judgment spells that deal damage have a 100% chance to grant up to 10 party or raid members the Rejuvenation effect,\nwhich grants them 1% of their maximum mana every 5 seconds for 15 seconds, and restore 25% of your base mana instantly.|r"
    }
},

{
    id = "spellFanaticism",
    name = "buttonSpellFanaticism",
    icon = "Interface/icons/spell_holy_fanaticism",
    position = {1100, -402},
    handler = "spellfanaticism",
    tooltips = {
        frFR = "|cffffffffFanatisme|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente de 18% les chances d'obtenir un coup critique avec tous les Jugements qui peuvent en infliger et réduit la menace de toutes les actions de 30%, sauf sous l'effet de Fureur vertueuse.|r",
        enUS = "|cffffffffFanaticism|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases your chance to score a critical hit with all Judgment spells by 18% and reduces threat from all actions by 30%, except when under the effect of Divine Fury.|r"
    }
},

{
    id = "spellSanctifiedWrath",
    name = "buttonSpellSanctifiedWrath",
    icon = "Interface/icons/ability_paladin_sanctifiedwrath",
    position = {718, -456},
    handler = "spellsanctifiedwrath",
    tooltips = {
        frFR = "|cffffffffCourroux sanctifié|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente les chances de coup critique de Marteau de courroux de 50%, réduit le temps de recharge de Courroux vengeur de 60 sec.\net tant que vous êtes affecté par Courroux vengeur 50% de tous les dégâts infligés évitent les effets de réduction des dégâts.|r",
        enUS = "|cffffffffSanctified Wrath|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases the critical strike chance of Crusader Strike by 50%, reduces the cooldown of Avenging Wrath by 60 seconds,\nand while affected by Avenging Wrath, 50% of all damage you deal ignores damage reduction effects.|r"
    }
},

{
    id = "spellSwiftRetribution",
    name = "buttonSpellSwiftRetribution",
    icon = "Interface/icons/ability_paladin_swiftretribution",
    position = {825, -456},
    handler = "spellswiftretribution",
    tooltips = {
        frFR = "|cffffffffVindicte rapide|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Vos Auras augmentent également les vitesses d'incantation et d'attaque en mêlée et à distance de 3%.|r",
        enUS = "|cffffffffSwift Retribution|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Your Auras also increase casting speed and melee and ranged attack speed by 3%.|r"
    }
},

{
    id = "spellCrusaderStrike",
    name = "buttonSpellCrusaderStrike",
    icon = "Interface/icons/spell_holy_crusaderstrike",
    position = {935, -456},
    handler = "spellcrusaderstrike",
    tooltips = {
        frFR = "|cffffffffInquisition|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Une attaque instantanée qui inflige 93% des dégâts de l'arme.|r",
        enUS = "|cffffffffCrusader Strike|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100An instant attack that deals 93% weapon damage.|r"
    }
},
{
    id = "spellSheathofLight",
    name = "buttonSpellSheathofLight",
    icon = "Interface/icons/ability_paladin_sheathoflight",
    position = {1045, -456},
    handler = "spellsheathoflight",
    tooltips = {
        frFR = "|cffffffffFourreau de lumière|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente votre puissance des sorts d'un montant égal à 30% de votre puissance d'attaque et vos sorts\nde soins critiques rendent à la cible un montant de points de vie égal à 60% des points de vie rendus en 12 secondes.|r",
        enUS = "|cffffffffSheath of Light|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100Increases your spell power by an amount equal to 30% of your attack power and your critical healing spells will heal the target for 60% of the healing amount over 12 seconds.|r"
    }
},

{
    id = "spellRighteousVengeance",
    name = "buttonSpellRighteousVengeance",
    icon = "Interface/icons/ability_paladin_righteousvengeance",
    position = {771, -510},
    handler = "spellrighteousvengeance",
    tooltips = {
        frFR = "|cffffffffVengeance vertueuse|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Quand vos sorts de Jugement, Inquisition ou Tempête divine infligent un coup critique, votre cible subira 30% de dégâts supplémentaires en 8 secondes.|r",
        enUS = "|cffffffffRighteous Vengeance|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100When your Judgment, Inquisition, or Divine Storm spells critically hit, your target will suffer 30% additional damage for 8 seconds.|r"
    }
},

{
    id = "spellDivineStorm",
    name = "buttonSpellDivineStorm",
    icon = "Interface/icons/ability_paladin_divinestorm",
    position = {988, -510},
    handler = "spelldivinestorm",
    tooltips = {
        frFR = "|cffffffffTempête divine|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Une attaque instantanée avec une arme qui inflige 110% des dégâts de l'arme à un maximum de 4 ennemis se trouvant à moins de 8 mètres.\nLa Tempête divine soigne jusqu'à 3 membres du groupe ou du raid pour un total de 25% des dégâts infligés.|r",
        enUS = "|cffffffffDivine Storm|r\n|cffffffffTalent|r |cffff8040Retribution|r\n|cffffffffRequires|r |cfff58cbaPaladin|r\n|cffffd100An instant weapon attack that deals 110% weapon damage to a maximum of 4 enemies within 8 yards.\nDivine Storm heals up to 3 party or raid members for 25% of the damage dealt.|r"
		}
	}
}

-- CreateSpellButton("buttonSpellHeartoftheCrusader", "Interface/icons/spell_holy_holysmite", "|cffffffffCoeur du Croisé|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100En plus des effets normaux, vos sorts de Jugement augmentent de 3% supplémentaires les chances de coup critique de toutes les attaques effectuées contre cette cible.|r", "spellheartofthecrusader", 718, -240)
-- CreateSpellButton("buttonSpellImprovedBlessingofMight", "Interface/icons/spell_holy_fistofjustice", "|cffffffffBénédiction de puissance améliorée|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente le bonus à la puissance d'attaque conféré par votre Bénédiction de puissance de 25%.|r", "spellimprovedblessingofmight", 825, -240)
-- CreateSpellButton("buttonSpellVindication", "Interface/icons/spell_holy_vindication", "|cffffffffJustification|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Confère aux attaques du paladin qui infligent des dégâts une chance de réduire la puissance d'attaque de la cible de 46 pendant 10 secondes.|r", "spellindication", 935, -240)
-- CreateSpellButton("buttonSpellConviction", "Interface/icons/spell_holy_retributionaura", "|cffffffffConviction|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente vos chances d'infliger un coup critique avec tous les sorts et les attaques de 5%.|r", "spellconviction", 1045, -240)
-- CreateSpellButton("buttonSpellSealofCommand", "Interface/icons/ability_warrior_innerrage", "|cffffffffSceau d'autorité|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Toutes les attaques en mêlée infligent de 53 à 54 points de dégâts du Sacré supplémentaires.\nQuand il est utilisé avec des attaques ou techniques qui frappent une cible unique, ces dégâts du Sacré supplémentaires s'abattent sur un maximum de 2 cibles supplémentaires.\nDure 30 mn.\nLibérez l'énergie de ce Sceau pour juger un ennemi et lui infliger instantanément de 107 à 108 points de dégâts du Sacré.|r", "spellsealofcommand", 663, -293)
-- CreateSpellButton("buttonSpellPursuitofJustice", "Interface/icons/spell_holy_persuitofjustice", "|cffffffffPoursuite de la justice|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit la durée de tous les effets de désarmement de 50% et augmente votre vitesse de déplacement et la vitesse de déplacement de votre monture de 15%.\nNe s'additionne pas avec les autres effets qui augmentent la vitesse de déplacement.|r", "spellpursuitofjustice", 770, -293)
-- CreateSpellButton("buttonSpellEyeforanEye", "Interface/icons/spell_holy_eyeforaneye", "|cffffffffOeil pour oeil|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Tous les coups critiques contre vous infligent également 10% des dégâts que vous subissez à l'attaquant.\nLes points de dégâts causés par Oeil pour oeil ne peuvent excéder 50% du total des points de vie du paladin.|r", "spelleyeforaneye", 990, -293)
-- CreateSpellButton("buttonSpellSanctityofBattle", "Interface/icons/spell_holy_holysmite", "|cffffffffBataille sainte|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente vos chances de réussir des coups critiques avec tous les sorts et attaques de 3% et augmente les dégâts infligés par Exorcisme et Inquisition de 15%.|r", "spellsanctityofbattle", 1100, -293)
-- CreateSpellButton("buttonSpellCrusade", "Interface/icons/spell_holy_crusade", "|cffffffffCroisade|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente tous les dégâts infligés de 3% et tous les dégâts infligés aux humanoïdes, démons, morts-vivants et élémentaires de 3% supplémentaires.|r", "spellcrusade", 718, -348)
-- CreateSpellButton("buttonSpellTwoHandedWeaponSpecialization", "Interface/icons/inv_hammer_04", "|cffffffffSpécialisation Arme 2M|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente les points de dégâts que vous infligez avec les armes de mêlée à deux mains de 6%.|r", "spelltwohandedweaponspecialization", 825, -348)
-- CreateSpellButton("buttonSpellSanctifiedRetribution", "Interface/icons/spell_holy_mindvision", "|cffffffffVindicte sanctifiée|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente les dégâts infligés par Aura de vindicte de 50%, et tous les dégâts infligés par les cibles alliées affectées par l'une de vos Auras sont augmentés de 3%.|r", "spellsanctifiedretribution", 935, -348)
-- CreateSpellButton("buttonSpellVengeance", "Interface/icons/ability_racial_avatar", "|cffffffffVengeance|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Après un coup critique obtenu en frappant avec une arme, ou avec un sort ou une technique, vous infligez 3% de points de dégâts physiques et du Sacré supplémentaires pendant 30 secondes.\nCet effet est cumulable jusqu'à 3 fois.|r", "spellvengeance", 1045, -348)
-- CreateSpellButton("buttonSpellDivinePurpose", "Interface/icons/spell_holy_divinepurpose", "|cffffffffDessein divin|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Réduit la probabilité que vous soyez touché par les sorts et les attaques à distance de 4% et confère à votre sort Main de liberté 100% de chances d'annuler tous les effets d'étourdissement sur la cible.|r", "spelldivinepurpose", 663, -402)
-- CreateSpellButton("buttonSpellTheArtofWar", "Interface/icons/ability_paladin_artofwar", "|cffffffffL'art de la guerre|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente les dégâts de vos techniques de Jugement, Inquisition et Tempête divine de 10%, et quand vous réussissez un coup critique avec vos attaques de mêlée, votre prochain sort Eclair lumineux ou Exorcisme est instantané.|r", "spelltheartofwar", 770, -402)
-- CreateSpellButton("buttonSpellRepentance", "Interface/icons/spell_holy_prayerofhealing", "|cffffffffRepentir|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Plonge la cible ennemie dans une transe méditative qui la stupéfie pendant 60 secondes.\nau maximum et annule l'effet de Vengeance vertueuse.\nSi la cible subit des dégâts, elle se réveille.\nNe fonctionne que sur les démons, les draconiens, les géants, les humanoïdes et les morts-vivants.|r", "spellrepentance", 880, -402)
-- CreateSpellButton("buttonSpellJudgementsoftheWise", "Interface/icons/ability_paladin_judgementofthewise", "|cffffffffJugements des sages|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Vos sorts de Jugement infligeant des dégâts ont 100% de chances de conférer à jusqu'à 10 membres du groupe ou raid l'effet Requinquage,\nqui les fait bénéficier d'une régénération de mana égale à 1% de leur maximum de mana toutes les 5 sec.\npendant 15 secondes., ainsi que de vous rendre instantanément 25% de votre mana de base.|r", "spelljudgementsofthewise", 990, -402)
-- CreateSpellButton("buttonSpellFanaticism", "Interface/icons/spell_holy_fanaticism", "|cffffffffFanatisme|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente de 18% les chances d'obtenir un coup critique avec tous les Jugements qui peuvent en infliger et réduit la menace de toutes les actions de 30%, sauf sous l'effet de Fureur vertueuse.|r", "spellfanaticism", 1100, -402)
-- CreateSpellButton("buttonSpellSanctifiedWrath", "Interface/icons/ability_paladin_sanctifiedwrath", "|cffffffffCourroux sanctifié|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente les chances de coup critique de Marteau de courroux de 50%, réduit le temps de recharge de Courroux vengeur de 60 sec.\net tant que vous êtes affecté par Courroux vengeur 50% de tous les dégâts infligés évitent les effets de réduction des dégâts.|r", "spellsanctifiedwrath", 718, -456)
-- CreateSpellButton("buttonSpellSwiftRetribution", "Interface/icons/ability_paladin_swiftretribution", "|cffffffffVindicte rapide|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Vos Auras augmentent également les vitesses d'incantation et d'attaque en mêlée et à distance de 3%.|r", "spellswiftretribution", 825, -456)
-- CreateSpellButton("buttonSpellCrusaderStrike", "Interface/icons/spell_holy_crusaderstrike", "|cffffffffInquisition|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Une attaque instantanée qui inflige 93% des dégâts de l'arme.|r", "spellcrusaderstrike", 935, -456)
-- CreateSpellButton("buttonSpellSheathofLight", "Interface/icons/ability_paladin_sheathoflight", "|cffffffffFourreau de lumière|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Augmente votre puissance des sorts d'un montant égal à 30% de votre puissance d'attaque et vos sorts de soins critiques rendent à la cible un montant de points de vie égal à 60% des points de vie rendus en 12 secondes.|r", "spellsheathoflight", 1045, -456)
-- CreateSpellButton("buttonSpellRighteousVengeance", "Interface/icons/ability_paladin_righteousvengeance", "|cffffffffVengeance vertueuse|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Quand vos sorts de Jugement, Inquisition ou Tempête divine infligent un coup critique, votre cible subira 30% de dégâts supplémentaires en 8 secondes.|r", "spellrighteousvengeance", 771, -510)
-- CreateSpellButton("buttonSpellDivineStorm", "Interface/icons/ability_paladin_divinestorm", "|cffffffffTempête divine|r\n|cffffffffTalent|r |cffff8040Vindicte|r\n|cffffffffRequiert|r |cfff58cbaPaladin|r\n|cffffd100Une attaque instantanée avec une arme qui inflige 110% des dégâts de l'arme à un maximum de 4 ennemis se trouvant à moins de 8 mètres.\nLa Tempête divine soigne jusqu'à 3 membres du groupe ou du raid pour un total de 25% des dégâts infligés.|r", "spelldivinestorm", 988, -510)

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

-- Créez le bouton Save à l'intérieur de la fenêtre frameTalentPaladin
local saveButton = CreateFrame("Button", "saveButton", frameTalentPaladin, "UIPanelButtonTemplate")
saveButton:SetSize(85, 25)
saveButton:SetPoint("BOTTOMRIGHT", buttonTalentPaladinClose, "BOTTOMLEFT", -185, 5) -- Place le bouton Save à gauche du bouton Close
saveButton:SetText(saveButtonText)

-- Fonction qui prend un screenshot quand le bouton est cliqué
saveButton:SetScript("OnClick", function()
    Screenshot()  -- Prendre un screenshot et l'enregistrer dans le dossier Screenshots du jeu
    print(screenshotMessage)  -- Affiche un message de confirmation en fonction de la locale
end)

-- Affiche l'UI des talents
--frameTalentPaladin:Show()

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

-- Créez le bouton Reset à l'intérieur de la fenêtre frameTalentPaladin
local buttonReset = CreateFrame("Button", "buttonReset", frameTalentPaladin, "UIPanelButtonTemplate")
buttonReset:SetSize(85, 25)
buttonReset:SetPoint("BOTTOMRIGHT", buttonTalentPaladinClose, "BOTTOMLEFT", -95, 5) -- Place le bouton Reset à gauche du bouton Reload
buttonReset:SetText(buttonResetText)

local function ResetTalents()
    -- Ajoutez ici la logique pour réinitialiser les talents du joueur
    AIO.Handle("TalentPaladinspell", "ResetTalents")
    resetButtonClicked = true -- Marquez le bouton Réinitialiser comme cliqué
end

buttonReset:SetScript("OnClick", ResetTalents)

-- Créez le bouton Reload à l'intérieur de la fenêtre frameTalentPaladin
local buttonReload = CreateFrame("Button", "buttonReload", frameTalentPaladin, "UIPanelButtonTemplate")
buttonReload:SetSize(85, 25)
buttonReload:SetPoint("BOTTOMRIGHT", buttonTalentPaladinClose, "BOTTOMLEFT", -5, 5) -- Place le bouton Reload à gauche du bouton Close
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
        frameTalentPaladin:Hide()
        buttonReload:Hide()
        PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
    else
        frameTalentPaladin:Show()
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
        frFR = "|cffffffffTalents|r |cfff58cba(Paladin)|r\n\nL'éventail des talents disponibles\npour améliorer et spécialiser\nvotre personnage.",
        enUS = "|cffffffffTalents|r |cfff58cba(Paladin)|r\n\nThe range of available talents\nfor enhancing and specializing\nyour character."
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

-- Vérifier si le joueur est un Paladin avant de créer le bouton
local playerClass = select(2, UnitClass("player")) -- Obtenir la classe du joueur
if playerClass == "PALADIN" then
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
PaladinHandlers.UpdateTalentCount = function(player, talentsAppris)
    if fontTalentPaladinFrameText then
        fontTalentPaladinFrameText:SetText(talentsAppris .. " / " .. MAX_TALENTS)
    end
end

-- Mise à jour des points de talent utilisés avec texte localisé
PaladinHandlers.UpdateTalentPointsUsed = function(player, pointsUsed, pointsBeforeReset)
    -- Utilisation du texte localisé pour les points avant réinitialisation
    print(string.format(GetLocalizedPointsBeforeResetText(), pointsBeforeReset))
end

-- Affichage des talents restants (items 338404 dans le sac)
PaladinHandlers.UpdateTalentItemCount = function(player, count)
    if fontTalentPointsRemainingText then
        fontTalentPointsRemainingText:SetText("|cFFF58CBATalents restants : " .. count .. "|r")
    end
end

-------------------------------------------------------------
-- ✅ CORRECTION : mise à jour automatique quand le sac change
-- BAG_UPDATE se déclenche à chaque ajout/retrait d'item dans l'inventaire
-- On utilise GetItemCount() côté client directement, sans aller/retour serveur
-------------------------------------------------------------
local TALENT_ITEM_ID = 338404

local function UpdateTalentCountFromBag()
    local count = GetItemCount(TALENT_ITEM_ID, false, true)
    if fontTalentPointsRemainingText then
        fontTalentPointsRemainingText:SetText("|cFFF58CBATalents restants : " .. (count or 0) .. "|r")
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
if playerClass == "PALADIN" then
    -- Surcharge OnHide pour synchroniser talentsWindowOpen quand Échap est pressé
    local _originalOnHide = frameTalentPaladin:GetScript("OnHide")
    frameTalentPaladin:SetScript("OnHide", function(self)
        talentsWindowOpen = false
        if _originalOnHide then _originalOnHide(self) end
    end)
    -- WoW appelle automatiquement Hide() sur les frames listées ici quand Échap est pressé
    tinsert(UISpecialFrames, "frameTalentPaladin")
end
