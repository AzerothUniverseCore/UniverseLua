local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local PriestHandlers = AIO.AddHandlers("TalentPriestspell", {})

function PriestHandlers.ShowTalentPriest(player)
    frameTalentPriest:Show()
    -- Redemande au serveur l’état visuel au cas où
    AIO.Handle("TalentPriestspell", "RequestLearnedTalents")
	-- Redemande le nombre de talents restants
    AIO.Handle("TalentPriestspell", "GetTalentItemCount")
end

local MAX_TALENTS = 60 -- Définition du nombre maximal de talents que le joueur peut apprendre

local OPEN_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_final_trait_unlocked.ogg"
local CLOSE_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_trait_refund_end.ogg"
local SPELL_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_80_azeritearmor_rotationends_02.ogg"

-- Attribute window
local frameTalentPriest = CreateFrame("Frame", "frameTalentPriest", UIParent)
frameTalentPriest:SetSize(1200, 650)
frameTalentPriest:SetMovable(true)
frameTalentPriest:EnableMouse(true)
frameTalentPriest:RegisterForDrag("LeftButton")
frameTalentPriest:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, -50) -- Adjust the X and Y coordinates
frameTalentPriest:SetBackdrop(
{
    -- bgFile = "interface/TalentFrame/talentsclassbackgroundPriest", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    bgFile = "interface/TalentFrame/Template/Class/Priest/talentsclassbackgroundpriest", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedpriest", --Interface/DialogFrame/UI-DialogBox-Border
    edgeSize = 20,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})

-- Ajoutez la texture de l'icône du Prêtre
local priestIcon = frameTalentPriest:CreateTexture("PriestIcon", "OVERLAY")
priestIcon:SetTexture("Interface\\TalentFrame\\Template\\Class\\Priest\\IconePriest.blp")
priestIcon:SetSize(60, 60)
priestIcon:SetPoint("TOPLEFT", frameTalentPriest, "TOPLEFT", -10, 10)

-- Template Talent Frame

-- Ajoute une textureone pour l'image BLP
local textureone = frameTalentPriest:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
textureone:SetTexture("Interface\\TalentFrame\\Template\\Class\\Priest\\TalentFrameTemplate.blp")
textureone:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
textureone:SetPoint("TOPLEFT", frameTalentPriest, "TOPLEFT", -170, 140) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentPriest:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Ajoute une texturetwo pour l'image BLP
local texturetwo = frameTalentPriest:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
texturetwo:SetTexture("Interface\\TalentFrame\\Template\\Class\\Priest\\TalentFrameTemplateOriginal.blp")
texturetwo:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
texturetwo:SetPoint("TOPRIGHT", frameTalentPriest, "TOPRIGHT", 170, 140) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentPriest:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Drag & Drop
frameTalentPriest:SetScript("OnDragStart", frameTalentPriest.StartMoving)
frameTalentPriest:SetScript("OnHide", frameTalentPriest.StopMovingOrSizing)
frameTalentPriest:SetScript("OnDragStop", frameTalentPriest.StopMovingOrSizing)
frameTalentPriest:Hide()

-- Nouveau template d'arête
frameTalentPriest:SetBackdropBorderColor(255, 255, 255) -- Couleur blanc

-- Close button
local buttonTalentPriestClose = CreateFrame("Button", "buttonTalentPriestClose", frameTalentPriest, "UIPanelCloseButton")
buttonTalentPriestClose:SetPoint("TOPRIGHT", -12, -12)
buttonTalentPriestClose:EnableMouse(true)
buttonTalentPriestClose:SetSize(32, 32)

local function CloseTalentWindow()
    frameTalentPriest:Hide()
    PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
end

-- Associez la fonction de fermeture au bouton de fermeture
buttonTalentPriestClose:SetScript("OnClick", CloseTalentWindow)

-- Title bar
local frameTalentPriestTitleBar = CreateFrame("Frame", "frameTalentPriestTitleBar", frameTalentPriest, nil)
frameTalentPriestTitleBar:SetSize(135, 25)
frameTalentPriestTitleBar:SetBackdrop(
{
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedpriest",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentPriestTitleBar:SetPoint("TOP", 0, 20)

local fontTalentPriestTitleText = frameTalentPriestTitleBar:CreateFontString("fontTalentPriestTitleText")
fontTalentPriestTitleText:SetFont("Fonts\\FRIZQT__.TTF", 13)
fontTalentPriestTitleText:SetSize(190, 5)
fontTalentPriestTitleText:SetPoint("CENTER", 0, 0)
fontTalentPriestTitleText:SetText("|cffFFC125Talents|r")

-- Détecte la langue du client
local locale = GetLocale() -- Retourne "enUS", "frFR", etc.

-- Table des traductions
local localizedTexts = {
    enUS = "|cffFFC125Priest|r",
    frFR = "|cffFFC125Prêtre|r",
}

-- Récupère le texte correspondant à la langue actuelle ou par défaut en anglais
local textToDisplay = localizedTexts[locale] or localizedTexts["enUS"]

local fontTalentPriestFrameText = frameTalentPriestTitleBar:CreateFontString("fontTalentPriestFrameText")
fontTalentPriestFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentPriestFrameText:SetSize(200, 5)
fontTalentPriestFrameText:SetPoint("TOPLEFT", frameTalentPriestTitleBar, "BOTTOMLEFT", -30, -35) -- Adjust the Y offset as needed
fontTalentPriestFrameText:SetText(textToDisplay)

-- Remplacez votre ligne existante pour la création du texte par celle-ci
local fontTalentPriestFrameText = frameTalentPriestTitleBar:CreateFontString("fontTalentPriestFrameText")
fontTalentPriestFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentPriestFrameText:SetSize(200, 5)
fontTalentPriestFrameText:SetPoint("TOPLEFT", frameTalentPriestTitleBar, "BOTTOMLEFT", -30, -60) -- Adjust the Y offset as needed
fontTalentPriestFrameText:SetText("0 / " .. MAX_TALENTS) -- Initialisez le texte avec 0 talents appris

-------------------------------------------------------------
-- Affichage "Talents restants" (item 338404 dans le sac)
-------------------------------------------------------------

local frameTalentPointsRemaining = CreateFrame("Frame", "frameTalentPointsRemaining", frameTalentPriest, nil)
frameTalentPointsRemaining:SetSize(220, 30)
frameTalentPointsRemaining:SetBackdrop({
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedpriest",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentPointsRemaining:SetPoint("BOTTOMRIGHT", frameTalentPriest, "BOTTOMRIGHT", -960, 10)

local fontTalentPointsRemainingText = frameTalentPointsRemaining:CreateFontString("fontTalentPointsRemainingText")
fontTalentPointsRemainingText:SetFont("Fonts\\FRIZQT__.TTF", 14)
fontTalentPointsRemainingText:SetSize(210, 20)
fontTalentPointsRemainingText:SetPoint("CENTER", 0, 0)
fontTalentPointsRemainingText:SetText("|cFFFFFFFFTalents restants : 0|r")
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
PriestHandlers.UpdateLearnedTalents = function(player, learnedSpells)
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

    local button = CreateFrame("Button", name, frameTalentPriest, nil)
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
                AIO.Handle("TalentPriestspell", talentHandler, 1)
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

-- Discipline

-- Table des sorts
local spells = {
{
    id = "spellUnbreakableWill",
    name = "buttonSpellUnbreakableWill",
    icon = "Interface/icons/spell_magic_magearmor",
    position = {100, -80},
    handler = "spellunbreakablewill",
    tooltips = {
        frFR = "|cffffffffVolonté inflexible|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit la durée des effets d'étourdissement, de peur et de silence contre vous de 30% supplémentaires.|r",
        enUS = "|cffffffffUnbreakable Will|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Reduces the duration of stuns, fears, and silences against you by an additional 30%.|r"
    }
},
{
    id = "spellTwinDisciplines",
    name = "buttonSpellTwinDisciplines",
    icon = "Interface/icons/spell_holy_sealofvengeance",
    position = {205, -75},
    handler = "spelltwindisciplines",
    tooltips = {
        frFR = "|cffffffffDisciplines jumelles|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente de 5% les dégâts et les soins produits par vos sorts instantanés.|r",
        enUS = "|cffffffffTwin Disciplines|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases the damage and healing of your instant cast spells by 5%.|r"
    }
},
{
    id = "spellSilentResolve",
    name = "buttonSpellSilentResolve",
    icon = "Interface/icons/spell_nature_manaregentotem",
    position = {315, -75},
    handler = "spellsilentresolve",
    tooltips = {
        frFR = "|cffffffffRésolution silencieuse|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Diminue la menace générée par vos sorts du Sacré et de Discipline de 20% et réduit la probabilité que vos sorts bénéfiques et effets de dégâts sur la durée soient dissipés de 30%.|r",
        enUS = "|cffffffffSilent Resolve|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Reduces the threat generated by your Holy and Discipline spells by 20%, and reduces the chance that your beneficial spells and damage-over-time effects will be dispelled by 30%.|r"
    }
},
{
    id = "spellImprovedInnerFire",
    name = "buttonSpellImprovedInnerFire",
    icon = "Interface/icons/spell_holy_innerfire",
    position = {418, -80},
    handler = "spellimprovedinnerfire",
    tooltips = {
        frFR = "|cffffffffFeu intérieur amélioré|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente l'effet de votre sort Feu intérieur de 45% et augmente son nombre total de charges de 12.|r",
        enUS = "|cffffffffImproved Inner Fire|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases the effect of your Inner Fire spell by 45%, and increases its total charges by 12.|r"
    }
},
{
    id = "spellImprovedPowerWordFortitude",
    name = "buttonSpellImprovedPowerWordFortitude",
    icon = "Interface/icons/spell_holy_wordfortitude",
    position = {45, -130},
    handler = "spellimprovedpowerwordfortitude",
    tooltips = {
        frFR = "|cffffffffMot de pouvoir : Robustesse amélioré|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente les effets de vos sorts Mot de pouvoir : Robustesse et Prière de robustesse de 30%, en plus d'augmenter votre total d'Endurance de 4%.|r",
        enUS = "|cffffffffImproved Power Word: Fortitude|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases the effects of your Power Word: Fortitude and Prayer of Fortitude by 30%, and also increases your total Stamina by 4%.|r"
    }
},
{
    id = "spellMartyrdom",
    name = "buttonSpellMartyrdom",
    icon = "Interface/icons/spell_nature_tranquility",
    position = {150, -130},
    handler = "spellmartyrdom",
    tooltips = {
        frFR = "|cffffffffMartyre|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Vous confère 100% de chances de bénéficier de l'effet Incantation focalisée pendant 6 seconds après avoir été victime d'un coup critique en mêlée ou à distance.\nCet effet réduit les interruptions causées par les attaques infligeant des dégâts pendant l'incantation de sorts de prêtre et réduit la durée des effets d'interruption de 20%.|r",
        enUS = "|cffffffffMartyrdom|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Grants you a 100% chance to gain the Focused Casting effect for 6 seconds after being critically hit by a melee or ranged attack.\nThis effect reduces interruptions caused by damage-dealing attacks during priest spell casts and reduces the duration of interruption effects by 20%.|r"
    }
},
{
    id = "spellMeditation",
    name = "buttonSpellMeditation",
    icon = "Interface/icons/spell_nature_sleep",
    position = {260, -130},
    handler = "spellmeditation",
    tooltips = {
        frFR = "|cffffffffMéditation|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Vous confère 50% de votre vitesse de récupération du mana normale pendant l'incantation.|r",
        enUS = "|cffffffffMeditation|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Grants you 50% of your normal mana regeneration speed while casting.|r"
    }
},
{
    id = "spellInnerFocus",
    name = "buttonSpellInnerFocus",
    icon = "Interface/icons/spell_frost_windwalkon",
    position = {370, -130},
    handler = "spellinnerfocus",
    tooltips = {
        frFR = "|cffffffffFocalisation améliorée|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Lorsqu'elle est activée, cette technique réduit de 100% le coût en mana de votre prochain sort et augmente ses chances d'infliger un effet critique de 25%, si ce sort peut avoir un effet critique.|r",
        enUS = "|cffffffffInner Focus|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100When activated, this technique reduces the mana cost of your next spell by 100% and increases its critical strike chance by 25%, if the spell can crit.|r"
    }
},
{
    id = "spellImprovedPowerWordShield",
    name = "buttonSpellImprovedPowerWordShield",
    icon = "Interface/icons/spell_holy_powerwordshield",
    position = {475, -133},
    handler = "spellimprovedpowerwordshield",
    tooltips = {
        frFR = "|cffffffffMot de pouvoir : Bouclier amélioré|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente les dégâts absorbés par votre Mot de pouvoir : Bouclier de 15%.|r",
        enUS = "|cffffffffImproved Power Word: Shield|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases the amount of damage absorbed by your Power Word: Shield by 15%.|r"
    }
},
{
    id = "spellAbsolution",
    name = "buttonSpellAbsolution",
    icon = "Interface/icons/spell_holy_absolution",
    position = {96, -185},
    handler = "spellabsolution",
    tooltips = {
        frFR = "|cffffffffAbsolution|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le coût en mana de vos sorts Dissipation de la magie, Guérison des maladies, Abolir maladie et Dissipation de masse de 15%.|r",
        enUS = "|cffffffffAbsolution|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Reduces the mana cost of your Magic Dispel, Disease Healing, Cure Disease, and Mass Dispel spells by 15%.|r"
    }
},
{
    id = "spellMentalAgility",
    name = "buttonSpellMentalAgility",
    icon = "Interface/icons/ability_hibernation",
    position = {205, -185},
    handler = "spellmentalagility",
    tooltips = {
        frFR = "|cffffffffSagacité|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le coût en mana de vos sorts instantanés de 10%.|r",
        enUS = "|cffffffffMental Agility|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Reduces the mana cost of your instant spells by 10%.|r"
    }
},
{
    id = "spellImprovedManaBurn",
    name = "buttonSpellImprovedManaBurn",
    icon = "Interface/icons/spell_shadow_manaburn",
    position = {315, -185},
    handler = "spellimprovedmanaburn",
    tooltips = {
        frFR = "|cffffffffBrûlure de mana améliorée|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le temps d'incantation du sort Brûlure de mana de 1 seconde.|r",
        enUS = "|cffffffffImproved Mana Burn|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Reduces the casting time of your Mana Burn spell by 1 second.|r"
    }
},
{
    id = "spellReflectiveShield",
    name = "buttonSpellReflectiveShield",
    icon = "Interface/icons/spell_holy_powerwordshield",
    position = {422, -185},
    handler = "spellreflectiveshield",
    tooltips = {
        frFR = "|cffffffffBouclier réflecteur|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Renvoie 45% des dégâts que vous absorbez avec votre Mot de pouvoir : Bouclier à l'attaquant.\nCes dégâts ne génèrent pas de menace.|r",
        enUS = "|cffffffffReflective Shield|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Reflects 45% of the damage you absorb with Power Word: Shield back to the attacker.\nThese damage do not generate threat.|r"
    }
},
{
    id = "spellMentalStrength",
    name = "buttonSpellMentalStrength",
    icon = "Interface/icons/spell_nature_enchantarmor",
    position = {527, -190},
    handler = "spellmentalstrength",
    tooltips = {
        frFR = "|cffffffffForce mentale|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente votre total d'Intelligence de 15%.|r",
        enUS = "|cffffffffMental Strength|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases your total Intelligence by 15%.|r"
    }
},
{
    id = "spellSoulWarding",
    name = "buttonSpellSoulWarding",
    icon = "Interface/icons/spell_holy_pureofheart",
    position = {43, -240},
    handler = "spellsoulwarding",
    tooltips = {
        frFR = "|cffffffffProtection de l'âme|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le temps de recharge de votre technique Mot de pouvoir : Bouclier de 4 sec.\net réduit son coût en mana de 15%.|r",
        enUS = "|cffffffffSoul Warding|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Reduces the cooldown of your Power Word: Shield ability by 4 seconds and reduces its mana cost by 15%.|r"
    }
},
{
    id = "spellFocusedPower",
    name = "buttonSpellFocusedPower",
    icon = "Interface/icons/spell_shadow_focusedpower",
    position = {150, -240},
    handler = "spellfocusedpower",
    tooltips = {
        frFR = "|cffffffffPuissance focalisée|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente les dégâts et les soins produits par vos sorts de 4%.\nDe plus, le temps d'incantation de Dissipation de masse est réduit de 1 seconde.|r",
        enUS = "|cffffffffFocused Power|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases the damage and healing done by your spells by 4%.\nAdditionally, the cast time of Mass Dispel is reduced by 1 second.|r"
    }
},
{
    id = "spellEnlightenment",
    name = "buttonSpellEnlightenment",
    icon = "Interface/icons/spell_arcane_mindmastery",
    position = {368, -240},
    handler = "spellenlightenment",
    tooltips = {
        frFR = "|cffffffffIllumination|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente votre total d'Esprit de 6% et augmente votre hâte des sorts de 6%.|r",
        enUS = "|cffffffffEnlightenment|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases your Spirit by 6% and your spell haste by 6%.|r"
    }
},
{
    id = "spellFocusedWill",
    name = "buttonSpellFocusedWill",
    icon = "Interface/icons/spell_arcane_focusedpower",
    position = {478, -240},
    handler = "spellfocusedwill",
    tooltips = {
        frFR = "|cffffffffVolonté focalisée|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente les chances d'effet critique de vos sorts de 3%, et après avoir subi un coup critique, vous bénéficiez de l'effet Volonté focalisée,\nqui réduit tous les dégâts subis de 4% et augmente les effets des soins sur vous de 5%.\nCumulable jusqu'à 3 fois.\nDure 8 secondes.|r",
        enUS = "|cffffffffFocused Will|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases the critical strike chance of your spells by 3%, and after being critically hit, you gain the Focused Will effect,\nwhich reduces all damage taken by 4% and increases healing effects on you by 5%.\nStacks up to 3 times.\nLasts 8 seconds.|r"
    }
},
{
    id = "spellPowerInfusion",
    name = "buttonSpellPowerInfusion",
    icon = "Interface/icons/spell_holy_powerinfusion",
    position = {98, -293},
    handler = "spellpowerinfusion",
    tooltips = {
        frFR = "|cffffffffInfusion de puissance|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Imprègne la cible de puissance, ce qui augmente la vitesse d'incantation des sorts de 20% et réduit le coût en mana de tous les sorts de 20%.\nDure 15 secondes.|r",
        enUS = "|cffffffffPower Infusion|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Infuses the target with power, increasing their spell casting speed by 20% and reducing the mana cost of all their spells by 20%.\nLasts 15 seconds.|r"
    }
},
{
    id = "spellImprovedFlashHeal",
    name = "buttonSpellImprovedFlashHeal",
    icon = "Interface/icons/spell_holy_chastise",
    position = {205, -293},
    handler = "spellimprovedflashheal",
    tooltips = {
        frFR = "|cffffffffSoins rapides améliorés|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le coût en mana de vos Soins rapides de 15% et augmente leurs chances d'effet critique de 10% sur les cibles alliées ne disposant que de 50% ou moins de leurs points de vie.|r",
        enUS = "|cffffffffImproved Flash Heal|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Reduces the mana cost of your Flash Heal by 15% and increases its critical strike chance by 10% on allies with 50% or less health.|r"
    }
},
{
    id = "spellRenewedHope",
    name = "buttonSpellRenewedHope",
    icon = "Interface/icons/spell_holy_holyprotection",
    position = {315, -293},
    handler = "spellrenewedhope",
    tooltips = {
        frFR = "|cffffffffRegain d'espoir|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente les chances d'effet critique de vos sorts Soins rapides, Soins supérieurs et Pénitence (soins) de 4% sur les cibles affectées par l'effet Ame affaiblie,\net vous avez 100% de chances de réduire tous les dégâts subis par tous les membres alliés du groupe et du raid de 3% pendant 60 secondes quand vous lancez Mot de pouvoir : Bouclier.\nCet effet a un temps de recharge de 15 sec.|r",
        enUS = "|cffffffffRenewed Hope|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases the critical strike chance of your Flash Heal, Greater Heal, and Penance (healing) by 4% on targets affected by Weakening Soul.\nYou also have a 100% chance to reduce all damage taken by all party and raid members by 3% for 60 seconds when you cast Power Word: Shield.\nThis effect has a 15-second cooldown.|r"
    }
},
{
    id = "spellRapture",
    name = "buttonSpellRapture",
    icon = "Interface/icons/spell_holy_rapture",
    position = {422, -293},
    handler = "spellrapture",
    tooltips = {
        frFR = "|cffffffffExtase|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Quand votre Mot de pouvoir : Bouclier est complètement absorbé ou dissipé, vous recevez instantanément 2,5% de votre total de mana,\net vous avez 100% de chances de donner à la cible protégée 2% de son total de mana, 8 points de rage, 16 points d'énergie ou 32 points de puissance runique.\nCet effet ne peut se produire plus d'une fois toutes les 12 secondes.|r",
        enUS = "|cffffffffRapture|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100When your Power Word: Shield is completely absorbed or dispelled, you instantly receive 2.5% of your total mana,\nand you have a 100% chance to grant the shielded target 2% of their total mana, 8 rage, 16 energy, or 32 runic power.\nThis effect can occur no more than once every 12 seconds.|r"
    }
},
{
    id = "spellAspiration",
    name = "buttonSpellAspiration",
    icon = "Interface/icons/spell_holy_aspiration",
    position = {527, -295},
    handler = "spellaspiration",
    tooltips = {
        frFR = "|cffffffffAspiration|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le temps de recharge de vos sorts Focalisation améliorée, Infusion de puissance, Suppression de la douleur et Pénitence de 20%.|r",
        enUS = "|cffffffffAspiration|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Reduces the cooldown of your Improved Focus, Power Infusion, Pain Suppression, and Penance by 20%.|r"
    }
},
{
    id = "spellDivineAegis",
    name = "buttonSpellDivineAegis",
    icon = "Interface/icons/spell_holy_devineaegis",
    position = {43, -350},
    handler = "spelldivineaegis",
    tooltips = {
        frFR = "|cffffffffEgide divine|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Les soins critiques créent un bouclier de protection autour de la cible, qui absorbe un montant de dégâts égal à 30% des soins reçus.\nDure 12 secondes.|r",
        enUS = "|cffffffffDivine Aegis|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Critical heals create a protective shield around the target that absorbs damage equal to 30% of the healing received.\nLasts 12 seconds.|r"
    }
},
{
    id = "spellPainSuppression",
    name = "buttonSpellPainSuppression",
    icon = "Interface/icons/spell_holy_painsupression",
    position = {150, -350},
    handler = "spellpainsuppression",
    tooltips = {
        frFR = "|cffffffffSuppression de la douleur|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit instantanément la menace d'une cible alliée de 5%, réduit tous les dégâts subis de 40% et augmente la résistance aux mécanismes de Dissipation de 65% pendant 8 secondes.|r",
        enUS = "|cffffffffPain Suppression|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Instantly reduces the threat of a friendly target by 5%, reduces all damage taken by 40%, and increases resistance to Dispel effects by 65% for 8 seconds.|r"
    }
},
{
    id = "spellGrace",
    name = "buttonSpellGrace",
    icon = "Interface/icons/spell_holy_hopeandgrace",
    position = {260, -350},
    handler = "spellgrace",
    tooltips = {
        frFR = "|cffffffffGrâce|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Vos sorts Soins rapides, Soins supérieurs et Pénitence ont 100% de chances de donner la Grâce à la cible, ce qui augmente tous les soins que lui prodigue le prêtre de 3%.\nCet effet est cumulable jusqu'à 3 fois et dure 15 secondes.\nGrâce ne peut être active que sur une cible à la fois.|r",
        enUS = "|cffffffffGrace|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Your Flash Heal, Greater Heal, and Penance have a 100% chance to grant Grace to the target, increasing all healing done by the Priest on that target by 3%.\nThis effect is stackable up to 3 times and lasts for 15 seconds.\nOnly one target can have Grace at a time.|r"
    }
},
{
    id = "spellBorrowedTime",
    name = "buttonSpellBorrowedTime",
    icon = "Interface/icons/spell_holy_borrowedtime",
    position = {368, -350},
    handler = "spellborrowedtime",
    tooltips = {
        frFR = "|cffffffffSursis|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Fait bénéficier votre prochain sort de 25% de hâte des sorts supplémentaire après avoir lancé Mot de pouvoir : Bouclier,\net augmente les dégâts absorbés par votre Mot de pouvoir : Bouclier d'un montant égal à 40% de votre puissance des sorts.|r",
        enUS = "|cffffffffBorrowed Time|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Your next spell benefits from an additional 25% haste after casting Power Word: Shield,\nand increases the damage absorbed by your Power Word: Shield by an amount equal to 40% of your spell power.|r"
    }
},
{
    id = "spellPenance",
    name = "buttonSpellPenance",
    icon = "Interface/icons/spell_holy_penance",
    position = {478, -350},
    handler = "spellpenance",
    tooltips = {
        frFR = "|cffffffffPénitence|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Lance une salve de lumière sacrée sur la cible et inflige 240 points de dégâts du Sacré à un ennemi ou rend 670 à 756 points de vie à un allié instantanément et toutes les 1 sec.\npendant 2 secondes.|r",
        enUS = "|cffffffffPenance|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Launches a burst of holy light at the target, dealing 240 Holy damage to an enemy or healing an ally for 670 to 756 health instantly and every second for 2 seconds.|r"
    }
},


-- CreateSpellButton("buttonSpellUnbreakableWill", "Interface/icons/spell_magic_magearmor", "|cffffffffVolonté inflexible|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit la durée des effets d'étourdissement, de peur et de silence contre vous de 30% supplémentaires.|r", "spellunbreakablewill", 100, -80)
-- CreateSpellButton("buttonSpellTwinDisciplines", "Interface/icons/spell_holy_sealofvengeance", "|cffffffffDisciplines jumelles|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente de 5% les dégâts et les soins produits par vos sorts instantanés.|r", "spelltwindisciplines", 205, -75)
-- CreateSpellButton("buttonSpellSilentResolve", "Interface/icons/spell_nature_manaregentotem", "|cffffffffRésolution silencieuse|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Diminue la menace générée par vos sorts du Sacré et de Discipline de 20% et réduit la probabilité que vos sorts bénéfiques et effets de dégâts sur la durée soient dissipés de 30%.|r", "spellsilentresolve", 315, -75)
-- CreateSpellButton("buttonSpellImprovedInnerFire", "Interface/icons/spell_holy_innerfire", "|cffffffffFeu intérieur amélioré|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente l'effet de votre sort Feu intérieur de 45% et augmente son nombre total de charges de 12.|r", "spellimprovedinnerfire", 418, -80)
-- CreateSpellButton("buttonSpellImprovedPowerWordFortitude", "Interface/icons/spell_holy_wordfortitude", "|cffffffffMot de pouvoir : Robustesse amélioré|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente les effets de vos sorts Mot de pouvoir : Robustesse et Prière de robustesse de 30%, en plus d'augmenter votre total d'Endurance de 4%.|r", "spellimprovedpowerwordfortitude", 45, -130)
-- CreateSpellButton("buttonSpellMartyrdom", "Interface/icons/spell_nature_tranquility", "|cffffffffMartyre|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Vous confère 100% de chances de bénéficier de l'effet Incantation focalisée pendant 6 seconds après avoir été victime d'un coup critique en mêlée ou à distance.\nCet effet réduit les interruptions causées par les attaques infligeant des dégâts pendant l'incantation de sorts de prêtre et réduit la durée des effets d'interruption de 20%.|r", "spellmartyrdom", 150, -130)
-- CreateSpellButton("buttonSpellMeditation", "Interface/icons/spell_nature_sleep", "|cffffffffMéditation|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Vous confère 50% de votre vitesse de récupération du mana normale pendant l'incantation.|r", "spellmeditation", 260, -130)
-- CreateSpellButton("buttonSpellInnerFocus", "Interface/icons/spell_frost_windwalkon", "|cffffffffFocalisation améliorée|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Lorsqu'elle est activée, cette technique réduit de 100% le coût en mana de votre prochain sort et augmente ses chances d'infliger un effet critique de 25%, si ce sort peut avoir un effet critique.|r", "spellinnerfocus", 370, -130)
-- CreateSpellButton("buttonSpellImprovedPowerWordShield", "Interface/icons/spell_holy_powerwordshield", "|cffffffffMot de pouvoir : Bouclier amélioré|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente les dégâts absorbés par votre Mot de pouvoir : Bouclier de 15%.|r", "spellimprovedpowerwordshield", 475, -133)
-- CreateSpellButton("buttonSpellAbsolution", "Interface/icons/spell_holy_absolution", "|cffffffffAbsolution|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le coût en mana de vos sorts Dissipation de la magie, Guérison des maladies, Abolir maladie et Dissipation de masse de 15%.|r", "spellabsolution", 96, -185)
-- CreateSpellButton("buttonSpellMentalAgility", "Interface/icons/ability_hibernation", "|cffffffffSagacité|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le coût en mana de vos sorts instantanés de 10%.|r", "spellmentalagility", 205, -185)
-- CreateSpellButton("buttonSpellImprovedManaBurn", "Interface/icons/spell_shadow_manaburn", "|cffffffffBrûlure de mana améliorée|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le temps d'incantation du sort Brûlure de mana de 1 seconde.|r", "spellimprovedmanaburn", 315, -185)
-- CreateSpellButton("buttonSpellReflectiveShield", "Interface/icons/spell_holy_powerwordshield", "|cffffffffBouclier réflecteur|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Renvoie 45% des dégâts que vous absorbez avec votre Mot de pouvoir : Bouclier à l'attaquant.\nCes dégâts ne génèrent pas de menace.|r", "spellreflectiveshield", 422, -185)
-- CreateSpellButton("buttonSpellMentalStrength", "Interface/icons/spell_nature_enchantarmor", "|cffffffffForce mentale|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente votre total d'Intelligence de 15%.|r", "spellmentalstrength", 527, -190)
-- CreateSpellButton("buttonSpellSoulWarding", "Interface/icons/spell_holy_pureofheart", "|cffffffffProtection de l'âme|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le temps de recharge de votre technique Mot de pouvoir : Bouclier de 4 sec.\net réduit son coût en mana de 15%.", "spellsoulwarding", 43, -240)
-- CreateSpellButton("buttonSpellFocusedPower", "Interface/icons/spell_shadow_focusedpower", "|cffffffffPuissance focalisée|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente les dégâts et les soins produits par vos sorts de 4%.\nDe plus, le temps d'incantation de Dissipation de masse est réduit de 1 seconde.|r", "spellfocusedpower", 150, -240)
-- CreateSpellButton("buttonSpellEnlightenment", "Interface/icons/spell_arcane_mindmastery", "|cffffffffIllumination|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente votre total d'Esprit de 6% et augmente votre hâte des sorts de 6%.|r", "spellenlightenment", 368, -240)
-- CreateSpellButton("buttonSpellFocusedWill", "Interface/icons/spell_arcane_focusedpower", "|cffffffffVolonté focalisée|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente les chances d'effet critique de vos sorts de 3%, et après avoir subi un coup critique, vous bénéficiez de l'effet Volonté focalisée,\nqui réduit tous les dégâts subis de 4% et augmente les effets des soins sur vous de 5%.\nCumulable jusqu'à 3 fois.\nDure 8 secondes.|r", "spellfocusedwill", 478, -240)
-- CreateSpellButton("buttonSpellPowerInfusion", "Interface/icons/spell_holy_powerinfusion", "|cffffffffInfusion de puissance|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Imprègne la cible de puissance, ce qui augmente la vitesse d'incantation des sorts de 20% et réduit le coût en mana de tous les sorts de 20%.\nDure 15 secondes.|r", "spellpowerinfusion", 98, -293)
-- CreateSpellButton("buttonSpellImprovedFlashHeal", "Interface/icons/spell_holy_chastise", "|cffffffffSoins rapides améliorés|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le coût en mana de vos Soins rapides de 15% et augmente leurs chances d'effet critique de 10% sur les cibles alliées ne disposant que de 50% ou moins de leurs points de vie.|r", "spellimprovedflashheal", 205, -293)
-- CreateSpellButton("buttonSpellRenewedHope", "Interface/icons/spell_holy_holyprotection", "|cffffffffRegain d'espoir|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente les chances d'effet critique de vos sorts Soins rapides, Soins supérieurs et Pénitence (soins) de 4% sur les cibles affectées par l'effet Ame affaiblie,\net vous avez 100% de chances de réduire tous les dégâts subis par tous les membres alliés du groupe et du raid de 3% pendant 60 secondes quand vous lancez Mot de pouvoir : Bouclier.\nCet effet a un temps de recharge de 15 sec.|r", "spellrenewedhope", 315, -293)
-- CreateSpellButton("buttonSpellRapture", "Interface/icons/spell_holy_rapture", "|cffffffffExtase|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Quand votre Mot de pouvoir : Bouclier est complètement absorbé ou dissipé, vous recevez instantanément 2,5% de votre total de mana,\net vous avez 100% de chances de donner à la cible protégée 2% de son total de mana, 8 points de rage, 16 points d'énergie ou 32 points de puissance runique.\nCet effet ne peut se produire plus d'une fois toutes les 12 secondes.|r", "spellrapture", 422, -293)
-- CreateSpellButton("buttonSpellAspiration", "Interface/icons/spell_holy_aspiration", "|cffffffffAspiration|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le temps de recharge de vos sorts Focalisation améliorée, Infusion de puissance, Suppression de la douleur et Pénitence de 20%.|r", "spellaspiration", 527, -295)
-- CreateSpellButton("buttonSpellDivineAegis", "Interface/icons/spell_holy_devineaegis", "|cffffffffEgide divine|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Les soins critiques créent un bouclier de protection autour de la cible, qui absorbe un montant de dégâts égal à 30% des soins reçus.\nDure 12 secondes.|r", "spelldivineaegis", 43, -350)
-- CreateSpellButton("buttonSpellPainSuppression", "Interface/icons/spell_holy_painsupression", "|cffffffffSuppression de la douleur|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit instantanément la menace d'une cible alliée de 5%, réduit tous les dégâts subis de 40% et augmente la résistance aux mécanismes de Dissipation de 65% pendant 8 secondes.|r", "spellpainsuppression", 150, -350)
-- CreateSpellButton("buttonSpellGrace|r", "Interface/icons/spell_holy_hopeandgrace", "|cffffffffGrâce|r\n|cffffffffTalent|r |cffffffbfDiscipline|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Vos sorts Soins rapides, Soins supérieurs et Pénitence ont 100% de chances de donner la Grâce à la cible, ce qui augmente tous les soins que lui prodigue le prêtre de 3%.\nCet effet est cumulable jusqu'à 3 fois et dure 15 secondes.\nGrâce ne peut être active que sur une cible à la fois.|r", "spellgrace", 260, -350)
-- CreateSpellButton("buttonSpellBorrowedTime", "Interface/icons/spell_holy_borrowedtime", "|cffffffffSursis|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Fait bénéficier votre prochain sort de 25% de hâte des sorts supplémentaire après avoir lancé Mot de pouvoir : Bouclier,\net augmente les dégâts absorbés par votre Mot de pouvoir : Bouclier d'un montant égal à 40% de votre puissance des sorts.|r", "spellborrowedtime", 368, -350)
-- CreateSpellButton("buttonSpellPenance", "Interface/icons/spell_holy_penance", "|cffffffffPénitence|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Lance une salve de lumière sacrée sur la cible et inflige 240 points de dégâts du Sacré à un ennemi ou rend 670 à 756 points de vie à un allié instantanément et toutes les 1 sec.\npendant 2 secondes.|r", "spellpenance", 478, -350)

-- Sacré

{
    id = "spellHealingFocus",
    name = "buttonSpellHealingFocus",
    icon = "Interface/icons/spell_holy_healingfocus",
    position = {98, -405},
    handler = "spellhealingfocus",
    tooltips = {
        frFR = "|cffffffffFocalisation des soins|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit de 70% l'interruption causée par les attaques infligeant des dégâts pendant que vous incantez tout sort de soins.|r",
        enUS = "|cffffffffHealing Focus|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Reduces interruption caused by damage-dealing attacks by 70% while casting any healing spell.|r"
    }
},
{
    id = "spellImprovedRenew",
    name = "buttonSpellImprovedRenew",
    icon = "Interface/icons/spell_holy_renew",
    position = {205, -405},
    handler = "spellimprovedrenew",
    tooltips = {
        frFR = "|cffffffffRénovation améliorée|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente de 15% le montant de points de vie rendus par votre sort Rénovation.|r",
        enUS = "|cffffffffImproved Renew|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases the healing done by your Renew spell by 15%.|r"
    }
},
{
    id = "spellHolySpecialization",
    name = "buttonSpellHolySpecialization",
    icon = "Interface/icons/spell_holy_sealofsalvation",
    position = {315, -405},
    handler = "spellholyspecialization",
    tooltips = {
        frFR = "|cffffffffSpécialisation (Sacré)|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente les chances d'obtenir un effet critique avec vos sorts du Sacré de 5%.|r",
        enUS = "|cffffffffHoly Specialization|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases the chance to critically hit with your Holy spells by 5%.|r"
    }
},
{
    id = "spellSpellWarding",
    name = "buttonSpellSpellWarding",
    icon = "Interface/icons/spell_holy_spellwarding",
    position = {422, -405},
    handler = "spellspellwarding",
    tooltips = {
        frFR = "|cffffffffProtection contre les sorts|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit tous les dégâts des sorts subis de 10%.|r",
        enUS = "|cffffffffSpell Warding|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Reduces all spell damage taken by 10%.|r"
    }
},
{
    id = "spellDivineFury",
    name = "buttonSpellDivineFury",
    icon = "Interface/icons/spell_holy_sealofwrath",
    position = {43, -458},
    handler = "spelldivinefury",
    tooltips = {
        frFR = "|cffffffffFureur divine|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le temps d'incantation de vos sorts Châtiment, Flammes sacrées, Soins et Soins supérieurs de 0,5 sec.|r",
        enUS = "|cffffffffDivine Fury|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Reduces the casting time of your Smite, Holy Fire, Heal, and Greater Heal spells by 0.5 seconds.|r"
    }
},
{
    id = "spellDesperatePrayer",
    name = "buttonSpellDesperatePrayer",
    icon = "Interface/icons/spell_holy_restoration",
    position = {150, -458},
    handler = "spelldesperateprayer",
    tooltips = {
        frFR = "|cffffffffPrière du désespoir|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Rend instantanément 263 à 325 points de vie au lanceur de sorts.|r",
        enUS = "|cffffffffDesperate Prayer|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Instantly restores 263 to 325 health to the caster.|r"
    }
},
{
    id = "spellBlessedRecovery",
    name = "buttonSpellBlessedRecovery",
    icon = "Interface/icons/spell_holy_blessedrecovery",
    position = {260, -458},
    handler = "spellblessedrecovery",
    tooltips = {
        frFR = "|cffffffffRétablissement béni|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Lorsque vous avez été frappé par un coup critique en mêlée ou à distance, Rétablissement béni vous rend 15% des points de dégâts subis en 6 secondes.\nLes coups critiques supplémentaires subis pendant l'effet augmentent les soins reçus.|r",
        enUS = "|cffffffffBlessed Recovery|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100When you are critically hit by a melee or ranged attack, Blessed Recovery restores 15% of the damage taken over 6 seconds.\nAdditional critical hits during the effect increase the healing received.|r"
    }
},
{
    id = "spellInspiration",
    name = "buttonSpellInspiration",
    icon = "Interface/icons/spell_holy_layonhands",
    position = {368, -458},
    handler = "spellinspiration",
    tooltips = {
        frFR = "|cffffffffInspiration|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit de 10% les dégâts physiques subis par votre cible pendant 15 secondes.\naprès avoir reçu un effet critique de l'un des sorts suivants : Soins rapides, Soins, Soins supérieurs, Soins de lien, Pénitence, Prière de guérison, Prière de soins ou Cercle de soins.|r",
        enUS = "|cffffffffInspiration|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Reduces physical damage taken by your target by 10% for 15 seconds\nafter receiving a critical effect from one of the following spells: Renew, Heal, Greater Heal, Prayer of Healing, Penance, Circle of Healing.|r"
    }
},
{
    id = "spellHolyReach",
    name = "buttonSpellHolyReach",
    icon = "Interface/icons/spell_holy_purify",
    position = {478, -458},
    handler = "spellholyreach",
    tooltips = {
        frFR = "|cffffffffAllonge du Sacré|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente de 20% la portée de vos sorts Châtiment et Flammes sacrées et le rayon d'effet de vos sorts Prière de soins, Nova sacrée, Hymne divin et Cercle de soins.|r",
        enUS = "|cffffffffHoly Reach|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases the range of your Smite and Holy Fire spells by 20%, and the radius of your Prayer of Healing, Holy Nova, Divine Hymn, and Circle of Healing by 20%.|r"
    }
},
{
    id = "spellImprovedHealing",
    name = "buttonSpellImprovedHealing",
    icon = "Interface/icons/spell_holy_heal02",
    position = {98, -510},
    handler = "spellimprovedhealing",
    tooltips = {
        frFR = "|cffffffffSoin amélioré|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le coût en mana de vos sorts Soins inférieurs, Soins, Soins supérieurs, Hymne divin et Pénitence de 15%.|r",
        enUS = "|cffffffffImproved Healing|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Reduces the mana cost of your Lesser Heal, Heal, Greater Heal, Divine Hymn, and Penance by 15%.|r"
    }
},
{
    id = "spellSearingLight",
    name = "buttonSpellSearingLight",
    icon = "Interface/icons/spell_holy_searinglightpriest",
    position = {205, -510},
    handler = "spellsearinglight",
    tooltips = {
        frFR = "|cffffffffLumière incendiaire|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente de 10% les dégâts infligés par vos sorts Châtiment, Flammes sacrées, Nova sacrée et Pénitence.|r",
        enUS = "|cffffffffSearing Light|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases the damage of your Smite, Holy Fire, Holy Nova, and Penance by 10%.|r"
    }
},
{
    id = "spellHealingPrayers",
    name = "buttonSpellHealingPrayers",
    icon = "Interface/icons/spell_holy_prayerofhealing02",
    position = {315, -510},
    handler = "spellhealingprayers",
    tooltips = {
        frFR = "|cffffffffPrières guérisseuses|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le coût en mana de vos sorts Prière de soins et Prière de guérison de 20%.|r",
        enUS = "|cffffffffHealing Prayers|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Reduces the mana cost of your Prayer of Healing and Prayer of Mending by 20%.|r"
    }
},
{
    id = "spellSpiritofRedemption",
    name = "buttonSpellSpiritofRedemption",
    icon = "Interface/icons/inv_enchant_essenceeternallarge",
    position = {422, -510},
    handler = "spellspiritofredemption",
    tooltips = {
        frFR = "|cffffffffEsprit de rédemption|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente le total d'Esprit de 5%, et au moment de sa mort, le prêtre devient l'Esprit de rédemption pendant 15 secondes.\nL'Esprit de rédemption ne peut pas se déplacer ou attaquer, ni être attaqué ou ciblé par aucun sort ou effet.\nTant qu'il est sous cette forme, le prêtre peut lancer tout sort de soins sans le moindre coût.\nÀ la fin de l'effet, le prêtre meurt.|r",
        enUS = "|cffffffffSpirit of Redemption|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases your Spirit by 5%, and upon death, the priest becomes the Spirit of Redemption for 15 seconds.\nThe Spirit of Redemption cannot move or attack, nor be attacked or targeted by any spells or effects.\nWhile in this form, the priest can cast healing spells with no cost.\nAt the end of the effect, the priest dies.|r"
    }
},


-- CreateSpellButton("buttonSpellHealingFocus", "Interface/icons/spell_holy_healingfocus", "|cffffffffFocalisation des soins|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit de 70% l'interruption causée par les attaques infligeant des dégâts pendant que vous incantez tout sort de soins.|r", "spellhealingfocus", 98, -405)
-- CreateSpellButton("buttonSpellImprovedRenew", "Interface/icons/spell_holy_renew", "|cffffffffRénovation améliorée|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente de 15% le montant de points de vie rendus par votre sort Rénovation.|r", "spellimprovedrenew", 205, -405)
-- CreateSpellButton("buttonSpellHolySpecialization", "Interface/icons/spell_holy_sealofsalvation", "|cffffffffSpécialisation (Sacré)|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente les chances d'obtenir un effet critique avec vos sorts du Sacré de 5%.|r", "spellholyspecialization", 315, -405)
-- CreateSpellButton("buttonSpellSpellWarding", "Interface/icons/spell_holy_spellwarding", "|cffffffffProtection contre les sorts|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit tous les dégâts des sorts subis de 10%.|r", "spellspellwarding", 422, -405)
-- CreateSpellButton("buttonSpellDivineFury", "Interface/icons/spell_holy_sealofwrath", "|cffffffffFureur divine|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le temps d'incantation de vos sorts Châtiment, Flammes sacrées, Soins et Soins supérieurs de 0,5 sec.|r", "spelldivinefury", 43, -458)
-- CreateSpellButton("buttonSpellDesperatePrayer", "Interface/icons/spell_holy_restoration", "|cffffffffPrière du désespoir|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Rend instantanément 263 à 325 points de vie au lanceur de sorts.|r", "spelldesperateprayer", 150, -458)
-- CreateSpellButton("buttonSpellBlessedRecovery", "Interface/icons/spell_holy_blessedrecovery", "|cffffffffRétablissement béni|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Lorsque vous avez été frappé par un coup critique en mêlée ou à distance, Rétablissement béni vous rend 15% des points de dégâts subis en 6 seconds.\nLes coups critiques supplémentaires subis pendant l'effet augmentent les soins reçus.|r", "spellblessedrecovery", 260, -458)
-- CreateSpellButton("buttonSpellInspiration", "Interface/icons/spell_holy_layonhands", "|cffffffffInspiration|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit de 10% les dégâts physiques subis par votre cible pendant 15 secondes.\naprès avoir reçu un effet critique de l'un des sorts suivants : Soins rapides, Soins, Soins supérieurs, Soins de lien, Pénitence, Prière de guérison, Prière de soins ou Cercle de soins.|r", "spellinspiration", 368, -458)
-- CreateSpellButton("buttonSpellHolyReach", "Interface/icons/spell_holy_purify", "|cffffffffAllonge du Sacré|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente de 20% la portée de vos sorts Châtiment et Flammes sacrées et le rayon d'effet de vos sorts Prière de soins, Nova sacrée, Hymne divin et Cercle de soins.|r", "spellholyreach", 478, -458)
-- CreateSpellButton("buttonSpellImprovedHealing", "Interface/icons/spell_holy_heal02", "|cffffffffSoin amélioré|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le coût en mana de vos sorts Soins inférieurs, Soins, Soins supérieurs, Hymne divin et Pénitence de 15%.|r", "spellimprovedhealing", 98, -510)
-- CreateSpellButton("buttonSpellSearingLight", "Interface/icons/spell_holy_searinglightpriest", "|cffffffffLumière incendiaire|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente de 10% les dégâts infligés par vos sorts Châtiment, Flammes sacrées, Nova sacrée et Pénitence.|r", "spellsearinglight", 205, -510)
-- CreateSpellButton("buttonSpellHealingPrayers", "Interface/icons/spell_holy_prayerofhealing02", "|cffffffffPrières guérisseuses|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le coût en mana de vos sorts Prière de soins et Prière de guérison de 20%.|r", "spellhealingprayers", 315, -510)
-- CreateSpellButton("buttonSpellSpiritofRedemption", "Interface/icons/inv_enchant_essenceeternallarge", "|cffffffffEsprit de rédemption|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente le total d'Esprit de 5%, et au moment de sa mort, le prêtre devient l'Esprit de rédemption pendant 15 secondes.\nL'Esprit de rédemption ne peut pas se déplacer ou attaquer, ni être attaqué ou ciblé par aucun sort ou effet.\nTant qu'il est sous cette forme, le prêtre peut lancer tout sort de soins sans le moindre coût.\nÀ la fin de l'effet, le prêtre meurt.|r", "spellspiritofredemption", 422, -510)

-- Template 2

{
    id = "spellSpiritualGuidance",
    name = "buttonSpellSpiritualGuidance",
    icon = "Interface/icons/spell_holy_spiritualguidence",
    position = {663, -75},
    handler = "spellspiritualguidance",
    tooltips = {
        frFR = "|cffffffffDirection spirituelle|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente la puissance des sorts d'un montant égal à 25% de votre Esprit total.|r",
        enUS = "|cffffffffSpiritual Guidance|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases your spell power by an amount equal to 25% of your total Spirit.|r"
    }
},
{
    id = "spellSurgeofLight",
    name = "buttonSpellSurgeofLight",
    icon = "Interface/icons/spell_holy_surgeoflight",
    position = {770, -75},
    handler = "spellsurgeoflight",
    tooltips = {
        frFR = "|cffffffffVague de Lumière|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Vos coups critiques avec les sorts confèrent 50% de chances à votre prochain sort Châtiment ou Soins rapides d'être instantané et de ne pas coûter de mana, mais sans pouvoir être un coup critique.\nCet effet dure 10 secondes.|r",
        enUS = "|cffffffffSurge of Light|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Your critical strikes with spells grant a 50% chance for your next Smite or Flash Heal to be instant and cost no mana, but it cannot be a critical hit.\nThis effect lasts for 10 seconds.|r"
    }
},
{
    id = "spellSpiritualHealing",
    name = "buttonSpellSpiritualHealing",
    icon = "Interface/icons/spell_nature_moonglow",
    position = {880, -75},
    handler = "spellspiritualsealing",
    tooltips = {
        frFR = "|cffffffffSoins spirituels|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente le montant de points de vie rendus par vos sorts de soins de 10%.|r",
        enUS = "|cffffffffSpiritual Healing|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases the healing done by your healing spells by 10%.|r"
    }
},
{
    id = "spellHolyConcentration",
    name = "buttonSpellHolyConcentration",
    icon = "Interface/icons/spell_holy_fanaticism",
    position = {990, -75},
    handler = "spellholyconcentration",
    tooltips = {
        frFR = "|cffffffffConcentration sacrée|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Votre régénération de mana due à l'Esprit est augmentée de 50% pendant 8 secondes.\naprès avoir réussi des soins critiques avec Soins rapides, Soins supérieurs, Soins de lien ou Rénovation surpuissante.|r",
        enUS = "|cffffffffHoly Concentration|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Your Spirit-based mana regeneration is increased by 50% for 8 seconds after landing a critical heal with Flash Heal, Greater Heal, Binding Heal, or Empowered Renew.|r"
    }
},
{
    id = "spellLightwell",
    name = "buttonSpellLightwell",
    icon = "Interface/icons/spell_holy_summonlightwell",
    position = {1100, -75},
    handler = "spelllightwell",
    tooltips = {
        frFR = "|cffffffffPuits de lumière|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Crée un Puits de lumière sacré.\nLes joueurs alliés peuvent cliquer sur le Puits de lumière pour recevoir 801 points de vie en 6 secondes.\nL'effet est annulé si vous subissez des dégâts égaux à 30% de votre total de points de vie.\nLa durée du Puits de lumière est de 3 mn ou bien 10 utilisations.|r",
        enUS = "|cffffffffLightwell|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Summons a Sacred Lightwell.\nAllied players can click the Lightwell to receive 801 health over 6 seconds.\nThe effect is canceled if you take damage equal to 30% of your total health.\nThe Lightwell lasts for 3 minutes or 10 uses.|r"
    }
},
{
    id = "spellBlessedResilience",
    name = "buttonSpellBlessedResilience",
    icon = "Interface/icons/spell_holy_blessedresillience",
    position = {718, -130},
    handler = "spellblessedresilience",
    tooltips = {
        frFR = "|cffffffffRésilience bénie|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente l'efficacité de vos sorts de soins de 3%, et les coups critiques contre vous ont 60% de chances de vous empêcher d'être à nouveau frappé par un coup critique pendant 6 secondes.|r",
        enUS = "|cffffffffBlessed Resilience|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases the effectiveness of your healing spells by 3%, and critical strikes against you have a 60% chance to prevent you from being critically hit again for 6 seconds.|r"
    }
},
{
    id = "spellBodyandSoul",
    name = "buttonSpellBodyandSoul",
    icon = "Interface/icons/spell_holy_symbolofhope",
    position = {825, -130},
    handler = "spellbodyandsoul",
    tooltips = {
        frFR = "|cffffffffCorps et âme|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Quand vous lancez Mot de pouvoir : Bouclier, vous augmentez la vitesse de déplacement de la cible de 60% pendant 4 secondes,\net vous avez 100% de chances lorsque vous lancez Abolir maladie sur vous-même d'également dissiper 1 effet de poison en plus des maladies.|r",
        enUS = "|cffffffffBody and Soul|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100When you cast Power Word: Shield, you increase the target's movement speed by 60% for 4 seconds,\nand you have a 100% chance to also dispel 1 poison effect in addition to diseases when you cast Dispel Disease on yourself.|r"
    }
},
{
    id = "spellEmpoweredHealing",
    name = "buttonSpellEmpoweredHealing",
    icon = "Interface/icons/spell_holy_greaterheal",
    position = {935, -130},
    handler = "spellempoweredhealing",
    tooltips = {
        frFR = "|cffffffffSoins surpuissants|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Votre sort Soins supérieurs bénéficie de 40% supplémentaires, tandis que vos Soins rapides et Soins de lien bénéficient de 20% supplémentaires des effets du bonus relatif aux soins.|r",
        enUS = "|cffffffffEmpowered Healing|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Your Greater Heal gains an additional 40%, while your Flash Heal and Binding Heal gain an additional 20% from your healing power bonus.|r"
    }
},
{
    id = "spellSerendipity",
    name = "buttonSpellSerendipity",
    icon = "Interface/icons/spell_holy_serendipity",
    position = {1045, -130},
    handler = "spellserendipity",
    tooltips = {
        frFR = "|cffffffffHeureux hasard|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Quand vous soignez avec Soins de lien ou Soins rapides, le temps d'incantation de votre prochain sort Soins supérieurs ou Prière de soins est réduit de 12%.\nCumulable jusqu'à 3 fois.\nDure 20 secondes.|r",
        enUS = "|cffffffffSerendipity|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100When you heal with Binding Heal or Flash Heal, the casting time of your next Greater Heal or Prayer of Healing is reduced by 12%.\nStackable up to 3 times.\nLasts for 20 seconds.|r"
    }
},
{
    id = "spellEmpoweredRenew",
    name = "buttonSpellEmpoweredRenew",
    icon = "Interface/icons/ability_paladin_infusionoflight",
    position = {663, -184},
    handler = "spellempoweredrenew",
    tooltips = {
        frFR = "|cffffffffRénovation surpuissante|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Votre sort Rénovation bénéficie de 15% supplémentaires de votre bonus aux soins, et votre Rénovation rend instantanément à la cible 15% de l'effet périodique total.|r",
        enUS = "|cffffffffEmpowered Renew|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Your Renew gains an additional 15% of your healing power bonus, and your Renew instantly heals the target for 15% of the total periodic effect.|r"
    }
},
{
    id = "spellCircleofHealing",
    name = "buttonSpellCircleofHealing",
    icon = "Interface/icons/spell_holy_circleofrenewal",
    position = {770, -184},
    handler = "spellcircleofhealing",
    tooltips = {
        frFR = "|cffffffffCercle de soins|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Rend à 6 membres au maximum du groupe ou du raid alliés se trouvant à moins de 15 mètres de la cible 343 à 379 points de vie.|r",
        enUS = "|cffffffffCircle of Healing|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Heals up to 6 party or raid members within 15 yards of the target for 343 to 379 health.|r"
    }
},
{
    id = "spellTestofFaith",
    name = "buttonSpellTestofFaith",
    icon = "Interface/icons/spell_holy_testoffaith",
    position = {880, -184},
    handler = "spelltestoffaith",
    tooltips = {
        frFR = "|cffffffffEpreuve de la Foi|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente les soins de 12% sur les cibles alliées qui ne disposent plus que de 50% ou moins de leurs points de vie.|r",
        enUS = "|cffffffffTest of Faith|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases healing by 12% on allied targets who are at or below 50% health.|r"
    }
},
{
    id = "spellDivineProvidence",
    name = "buttonSpellDivineProvidence",
    icon = "Interface/icons/spell_holy_divineprovidence",
    position = {990, -184},
    handler = "spelldivineprovidence",
    tooltips = {
        frFR = "|cffffffffProvidence divine|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente de 10% le montant de points de vie rendus par Cercle de soins, Soins de lien, Nova sacrée,\nPrière de soins, Hymne divin et Prière de guérison, et réduit de 30% le temps de recharge de votre Prière de guérison.|r",
        enUS = "|cffffffffDivine Providence|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases healing done by Circle of Healing, Binding Heal, Holy Nova, Prayer of Healing, Divine Hymn, and Prayer of Mending by 10%, and reduces the cooldown of Prayer of Healing by 30%.|r"
    }
},
{
    id = "spellGuardianSpirit",
    name = "buttonSpellGuardianSpirit",
    icon = "Interface/icons/spell_holy_guardianspirit",
    position = {1100, -184},
    handler = "spellguardianspirit",
    tooltips = {
        frFR = "|cffffffffEsprit gardien|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Fait appel à un esprit gardien pour veiller sur la cible alliée.\nL'esprit augmente les soins prodigués à la cible de 40% et l'empêche également de mourir en se sacrifiant pour elle.\nCe sacrifice met fin à l'effet mais rend à la cible 50% de ses points de vie maximum.\nDure 10 secondes.|r",
        enUS = "|cffffffffGuardian Spirit|r\n|cffffffffTalent|r |cffffffffHoly|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Summons a guardian spirit to watch over the target ally.\nThe spirit increases healing done to the target by 40% and also prevents the target from dying by sacrificing itself.\nThe sacrifice ends the effect but restores 50% of the target's maximum health.\nLasts 10 seconds.|r"
    }
},


-- CreateSpellButton("buttonSpellSpiritualGuidance", "Interface/icons/spell_holy_spiritualguidence", "|cffffffffDirection spirituelle|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente la puissance des sorts d'un montant égal à 25% de votre Esprit total.|r", "spellspiritualguidance", 663, -75)
-- CreateSpellButton("buttonSpellSurgeofLight", "Interface/icons/spell_holy_surgeoflight", "|cffffffffVague de Lumière|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Vos coups critiques avec les sorts confèrent 50% de chances à votre prochain sort Châtiment ou Soins rapides d'être instantané et de ne pas coûter de mana, mais sans pouvoir être un coup critique.\nCet effet dure 10 secondes.|r", "spellsurgeoflight", 770, -75)
-- CreateSpellButton("buttonSpellSpiritualHealing", "Interface/icons/spell_nature_moonglow", "|cffffffffSoins spirituels|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente le montant de points de vie rendus par vos sorts de soins de 10%.|r", "spellspiritualsealing", 880, -75)
-- CreateSpellButton("buttonSpellHolyConcentration", "Interface/icons/spell_holy_fanaticism", "|cffffffffConcentration sacrée|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Votre régénération de mana due à l'Esprit est augmentée de 50% pendant 8 seconds.\naprès avoir réussi des soins critiques avec Soins rapides, Soins supérieurs, Soins de lien ou Rénovation surpuissante.|r", "spellholyconcentration", 990, -75)
-- CreateSpellButton("buttonSpellLightwell", "Interface/icons/spell_holy_summonlightwell", "|cffffffffPuits de lumière|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Crée un Puits de lumière sacré.\nLes joueurs alliés peuvent cliquer sur le Puits de lumière pour recevoir 801 points de vie en 6 secondes.\nL'effet est annulé si vous subissez des dégâts égaux à 30% de votre total de points de vie.\nLa durée du Puits de lumière est de 3 mn ou bien 10 utilisations.|r", "spelllightwell", 1100, -75)
-- CreateSpellButton("buttonSpellBlessedResilience", "Interface/icons/spell_holy_blessedresillience", "|cffffffffRésilience bénie|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente l'efficacité de vos sorts de soins de 3%, et les coups critiques contre vous ont 60% de chances de vous empêcher d'être à nouveau frappé par un coup critique pendant 6 secondes.|r", "spellblessedresilience", 718, -130)
-- CreateSpellButton("buttonSpellBodyandSoul", "Interface/icons/spell_holy_symbolofhope", "|cffffffffCorps et âme|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Quand vous lancez Mot de pouvoir : Bouclier, vous augmentez la vitesse de déplacement de la cible de 60% pendant 4 secondes.,\net vous avez 100% de chances lorsque vous lancez Abolir maladie sur vous-même d'également dissiper 1 effet de poison en plus des maladies.|r", "spellbodyandsoul", 825, -130)
-- CreateSpellButton("buttonSpellEmpoweredHealing", "Interface/icons/spell_holy_greaterheal", "|cffffffffSoins surpuissants|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Votre sort Soins supérieurs bénéficie de 40% supplémentaires, tandis que vos Soins rapides et Soins de lien bénéficient de 20% supplémentaires des effets du bonus relatif aux soins.|r", "spellempoweredhealing", 935, -130)
-- CreateSpellButton("buttonSpellSerendipity", "Interface/icons/spell_holy_serendipity", "|cffffffffHeureux hasard|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Quand vous soignez avec Soins de lien ou Soins rapides, le temps d'incantation de votre prochain sort Soins supérieurs ou Prière de soins est réduit de 12%.\nCumulable jusqu'à 3 fois.\nDure 20 secondes.|r", "spellserendipity", 1045, -130)
-- CreateSpellButton("buttonSpellEmpoweredRenew", "Interface/icons/ability_paladin_infusionoflight", "|cffffffffRénovation surpuissante|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Votre sort Rénovation bénéficie de 15% supplémentaires de votre bonus aux soins, et votre Rénovation rend instantanément à la cible 15% de l'effet périodique total.|r", "spellempoweredrenew", 663, -184)
-- CreateSpellButton("buttonSpellCircleofHealing", "Interface/icons/spell_holy_circleofrenewal", "|cffffffffCercle de soins|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Rend à 6 membres au maximum du groupe ou du raid alliés se trouvant à moins de 15 mètres de la cible 343 à 379 points de vie.|r", "spellcircleofhealing", 770, -184)
-- CreateSpellButton("buttonSpellTestofFaith", "Interface/icons/spell_holy_testoffaith", "|cffffffffEpreuve de la Foi|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente les soins de 12% sur les cibles alliées qui ne disposent plus que de 50% ou moins de leurs points de vie.|r", "spelltestoffaith", 880, -184)
-- CreateSpellButton("buttonSpellDivineProvidence", "Interface/icons/spell_holy_divineprovidence", "|cffffffffProvidence divine|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente de 10% le montant de points de vie rendus par Cercle de soins, Soins de lien, Nova sacrée,\nPrière de soins, Hymne divin et Prière de guérison, et réduit de 30% le temps de recharge de votre Prière de guérison.|r", "spelldivineprovidence", 990, -184)
-- CreateSpellButton("buttonSpellGuardianSpirit", "Interface/icons/spell_holy_guardianspirit", "|cffffffffEsprit gardien|r\n|cffffffffTalent|r |cffffffffSacré|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Fait appel à un esprit gardien pour veiller sur la cible alliée.\nL'esprit augmente les soins prodigués à la cible de 40% et l'empêche également de mourir en se sacrifiant pour elle.\nCe sacrifice met fin à l'effet mais rend à la cible 50% de ses points de vie maximum.\nDure 10 secondes.", "spellguardianspirit", 1100, -184)


-- Ombre

{
    id = "spellSpiritTap",
    name = "buttonSpellSpiritTap",
    icon = "Interface/icons/spell_shadow_requiem",
    position = {718, -240},
    handler = "spellspirittap",
    tooltips = {
        frFR = "|cffffffffConnexion spirituelle|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Vous donne 100% de chances de gagner un bonus de 100% à l'Esprit après avoir tué une cible qui rapporte de l'expérience ou de l'honneur.\nVotre mana se régénère à 83% de la vitesse de récupération normale pendant l'incantation de sorts.\nDure 15 secondes.|r",
        enUS = "|cffffffffSpirit Tap|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Gives you 100% chance to gain a 100% bonus to Spirit after killing a target that grants experience or honor.\nYour mana regeneration is at 83% of normal speed while casting spells.\nLasts 15 seconds.|r"
    }
},
{
    id = "spellImprovedSpiritTap",
    name = "buttonSpellImprovedSpiritTap",
    icon = "Interface/icons/spell_shadow_requiem",
    position = {825, -240},
    handler = "spellimprovedspirittap",
    tooltips = {
        frFR = "|cffffffffConnexion spirituelle améliorée|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Vos coups critiques réussis avec Attaque mentale et Mot de l'ombre : Mort ont 100% de chances vos coups critiques avec Fouet mental ont 50% de chances d'augmenter votre total d'Esprit de 10%.\nPendant ce temps, votre mana se régénèrera à un taux de 33% lors des incantations.\nDure 8 secondes.|r",
        enUS = "|cffffffffImproved Spirit Tap|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Your critical hits with Mind Blast and Shadow Word: Death have a 100% chance to increase your Spirit by 10%.\nCritical hits with Mind Flay have a 50% chance to do the same.\nWhile active, your mana regeneration is 33% faster while casting spells.\nLasts 8 seconds.|r"
    }
},
{
    id = "spellDarkness",
    name = "buttonSpellDarkness",
    icon = "Interface/icons/spell_shadow_twilight",
    position = {935, -240},
    handler = "spelldarkness",
    tooltips = {
        frFR = "|cffffffffTénèbres|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente les dégâts de vos sorts d'Ombre de 10%.|r",
        enUS = "|cffffffffDarkness|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases the damage of your Shadow spells by 10%.|r"
    }
},
{
    id = "spellShadowAffinity",
    name = "buttonSpellShadowAffinity",
    icon = "Interface/icons/spell_shadow_shadowward",
    position = {1045, -240},
    handler = "spellshadowaffinity",
    tooltips = {
        frFR = "|cffffffffAffinité avec l'Ombre|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit la menace générée par vos sorts d'Ombre de 25%, et vous recevez 15% de votre mana de base quand vos sorts Mot de l'ombre : Douleur ou Toucher vampirique sont dissipés.|r",
        enUS = "|cffffffffShadow Affinity|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Reduces threat caused by your Shadow spells by 25%, and you gain 15% of your base mana when your Shadow Word: Pain or Vampiric Touch are dispelled.|r"
    }
},
{
    id = "spellImprovedShadowWordPain",
    name = "buttonSpellImprovedShadowWordPain",
    icon = "Interface/icons/spell_shadow_shadowwordpain",
    position = {663, -293},
    handler = "spellimprovedshadowwordpain",
    tooltips = {
        frFR = "|cffffffffMot de l'ombre : Douleur amélioré|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente les dégâts infligés par votre sort Mot de l'ombre : Douleur de 6%.|r",
        enUS = "|cffffffffImproved Shadow Word: Pain|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases the damage dealt by your Shadow Word: Pain by 6%.|r"
    }
},
{
    id = "spellShadowFocus",
    name = "buttonSpellShadowFocus",
    icon = "Interface/icons/spell_shadow_burningspirit",
    position = {770, -293},
    handler = "spellshadowfocus",
    tooltips = {
        frFR = "|cffffffffFocalisation de l'ombre|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente vos chances de toucher avec vos sorts d'Ombre de 3%, et réduit le coût en mana de vos sorts d'Ombre de 6%.|r",
        enUS = "|cffffffffShadow Focus|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases your chance to hit with Shadow spells by 3%, and reduces the mana cost of your Shadow spells by 6%.|r"
    }
},
{
    id = "spellImprovedPsychicScream",
    name = "buttonSpellImprovedPsychicScream",
    icon = "Interface/icons/spell_shadow_psychicscream",
    position = {990, -293},
    handler = "spellimprovedpsychicscream",
    tooltips = {
        frFR = "|cffffffffCri psychique amélioré|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le temps de recharge de votre sort Cri psychique de 4 sec.|r",
        enUS = "|cffffffffImproved Psychic Scream|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Reduces the cooldown of your Psychic Scream ability by 4 seconds.|r"
    }
},
{
    id = "spellImprovedMindBlast",
    name = "buttonSpellImprovedMindBlast",
    icon = "Interface/icons/spell_shadow_unholyfrenzy",
    position = {1100, -293},
    handler = "spellimprovedmindblast",
    tooltips = {
        frFR = "|cffffffffAttaque mentale améliorée|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le temps de recharge de votre sort Attaque mentale de 2.5 sec.,\net tant que vous êtes en forme d'Ombre il a également 100% de chances de réduire tous les soins prodigués à la cible de 20% pendant 10 secondes.|r",
        enUS = "|cffffffffImproved Mind Blast|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Reduces the cooldown of your Mind Blast by 2.5 seconds, and while in Shadowform, it also has a 100% chance to reduce all healing received by the target by 20% for 10 seconds.|r"
    }
},
{
    id = "spellMindFlay",
    name = "buttonSpellMindFlay",
    icon = "Interface/icons/spell_shadow_siphonmana",
    position = {718, -348},
    handler = "spellmindflay",
    tooltips = {
        frFR = "|cffffffffFouet mental|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Attaque l'esprit de la cible avec l'énergie de l'Ombre.\nInflige 45 points de dégâts d'Ombre en 3 secondes.\net réduit la vitesse de la cible de 50%.|r",
        enUS = "|cffffffffMind Flay|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Attacks the target's mind with Shadow energy.\nDeals 45 Shadow damage over 3 seconds.\nReduces the target's movement speed by 50%.|r"
    }
},
{
    id = "spellVeiledShadows",
    name = "buttonSpellVeiledShadows",
    icon = "Interface/icons/spell_magic_lesserinvisibilty",
    position = {825, -348},
    handler = "spellveiledshadows",
    tooltips = {
        frFR = "|cffffffffOmbres voilées|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le temps de recharge de votre technique Oubli de 6 sec.\net celui de votre technique Ombrefiel de 2 minutes.|r",
        enUS = "|cffffffffVeiled Shadows|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Reduces the cooldown of your Forgetfulness by 6 seconds, and your Shadowfiend ability by 2 minutes.|r"
    }
},
{
    id = "spellShadowReach",
    name = "buttonSpellShadowReach",
    icon = "Interface/icons/spell_shadow_chilltouch",
    position = {935, -348},
    handler = "spellshadowreach",
    tooltips = {
        frFR = "|cffffffffAllonge de l'Ombre|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente de 20% la portée de vos sorts offensifs d'Ombre.|r",
        enUS = "|cffffffffShadow Reach|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases the range of your offensive Shadow spells by 20%.|r"
    }
},
{
    id = "spellShadowWeaving",
    name = "buttonSpellShadowWeaving",
    icon = "Interface/icons/spell_shadow_blackplague",
    position = {1045, -348},
    handler = "spellshadowweaving",
    tooltips = {
        frFR = "|cffffffffTissage de l'ombre|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Vos sorts d'Ombre infligeant des dégâts ont 100% de chances d'augmenter les dégâts d'Ombre que vous infligez de 2% pendant 15 secondes.\nCumulable jusqu'à 5 fois.|r",
        enUS = "|cffffffffShadow Weaving|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Your damage-dealing Shadow spells have a 100% chance to increase the damage you deal with Shadow spells by 2% for 15 seconds.\nStacks up to 5 times.|r"
    }
},
{
    id = "spellSilence",
    name = "buttonSpellSilence",
    icon = "Interface/icons/spell_shadow_impphaseshift",
    position = {663, -402},
    handler = "spellsilence",
    tooltips = {
        frFR = "|cffffffffSilence|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Rend la cible silencieuse, l'empêchant de lancer des sorts pendant 5 secondes.\nLes incantations de sorts des victimes personnages non joueurs sont également interrompues pendant 3 secondes.|r",
        enUS = "|cffffffffSilence|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Silences the target, preventing them from casting spells for 5 seconds.\nThe spellcasting of NPC victims is also interrupted for 3 seconds.|r"
    }
},
{
    id = "spellVampiricEmbrace",
    name = "buttonSpellVampiricEmbrace",
    icon = "Interface/icons/spell_shadow_unsummonbuilding",
    position = {770, -402},
    handler = "spellvampiricembrace",
    tooltips = {
        frFR = "|cffffffffEtreinte vampirique|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Vous emplit de l'énergie de l'étreinte de l'Ombre, qui vous soigne pour 15% et les autres membres du groupe pour 3% de tous les dégâts d'Ombre que vous infligez avec des sorts monocibles pendant 30 minutes.|r",
        enUS = "|cffffffffVampiric Embrace|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Fills you with the energy of Vampiric Embrace, healing you for 15% and other group members for 3% of all Shadow damage you deal with single-target spells for 30 minutes.|r"
    }
},
{
    id = "spellImprovedVampiricEmbrace",
    name = "buttonSpellImprovedVampiricEmbrace",
    icon = "Interface/icons/spell_shadow_improvedvampiricembrace",
    position = {880, -402},
    handler = "spellimprovedvampiricembrace",
    tooltips = {
        frFR = "|cffffffffEtreinte vampirique améliorée|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente de 67% les soins prodigués par Etreinte vampirique.|r",
        enUS = "|cffffffffImproved Vampiric Embrace|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases the healing from Vampiric Embrace by 67%.|r"
    }
},
{
    id = "spellFocusedMind",
    name = "buttonSpellFocusedMind",
    icon = "Interface/icons/spell_nature_focusedmind",
    position = {990, -402},
    handler = "spellfocusedmind",
    tooltips = {
        frFR = "|cffffffffEsprit focalisé|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le coût en mana de vos sorts Attaque mentale, Contrôle mental, Fouet mental et Incandescence mentale de 15%.|r",
        enUS = "|cffffffffFocused Mind|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Reduces the mana cost of your Mind Blast, Mind Control, Mind Flay, and Mind Sear by 15%.|r"
    }
},
{
    id = "spellMindMelt",
    name = "buttonSpellMindMelt",
    icon = "Interface/icons/spell_shadow_skull",
    position = {1100, -402},
    handler = "spellmindmelt",
    tooltips = {
        frFR = "|cffffffffFonte de l'esprit|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente les chances de coup critique de vos sorts Attaque mentale, Fouet mental et Incandescence mentale de 4%,\net augmente les chances de coup critique périodique de vos sorts Toucher vampirique, Peste dévorante et Mot de l'ombre : Douleur de 6%.|r",
        enUS = "|cffffffffMind Melt|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases the critical strike chance of your Mind Blast, Mind Flay, and Mind Sear by 4%,\nand increases the critical strike chance of your periodic spells Vampiric Touch, Devouring Plague, and Shadow Word: Pain by 6%.|r"
    }
},
{
    id = "spellImprovedDevouringPlague",
    name = "buttonSpellImprovedDevouringPlague",
    icon = "Interface/icons/spell_shadow_devouringplague",
    position = {718, -456},
    handler = "spellimproveddevouringplague",
    tooltips = {
        frFR = "|cffffffffPeste dévorante améliorée|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente les dégâts périodiques infligés par votre Peste dévorante de 15%,\net quand vous la lancez vous infligez instantanément un montant de dégâts égal à 30% du total de son effet périodique.|r",
        enUS = "|cffffffffImproved Devouring Plague|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases the periodic damage of your Devouring Plague by 15%,\nand when cast, it deals an instant damage equal to 30% of its total periodic effect.|r"
    }
},
{
    id = "spellShadowform",
    name = "buttonSpellShadowform",
    icon = "Interface/icons/spell_shadow_shadowform",
    position = {825, -456},
    handler = "spellshadowform",
    tooltips = {
        frFR = "|cffffffffForme d'Ombre|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Adopte une Forme d'Ombre qui augmente de 15% les dégâts d'Ombre que vous infligez en plus de réduire de 15% tous les dégâts que vous subissez et de 30% la menace générée.\nCependant, vous ne pouvez pas lancer de sorts du Sacré lorsque vous êtes sous cette forme, à part Guérison des maladies et Abolir maladie.\nLes dégâts périodiques de vos sorts Mot de l'ombre : Douleur, Peste dévorante et Toucher vampirique sont augmentés de 100% quand ils sont critiques,\nPeste dévorante et Toucher vampirique bénéficient également du bonus de hâte.|r",
        enUS = "|cffffffffShadowform|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Adopts a Shadowform that increases the damage of your Shadow spells by 15%, reduces all damage taken by 15%, and reduces threat generation by 30%.\nHowever, you cannot cast Holy spells while in this form, except for Disease Cure and Abolish Disease.\nThe periodic damage of your Shadow Word: Pain, Devouring Plague, and Vampiric Touch is increased by 100% when they critically hit,\nDevouring Plague and Vampiric Touch also benefit from haste bonuses.|r"
    }
},
{
    id = "spellShadowPower",
    name = "buttonSpellShadowPower",
    icon = "Interface/icons/spell_shadow_shadowpower",
    position = {935, -456},
    handler = "spellshadowpower",
    tooltips = {
        frFR = "|cffffffffPuissance de l'ombre|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente le bonus de dégâts des coups critiques de vos sorts Attaque mentale, Fouet mental et Mot de l'ombre : Mort de 100%.|r",
        enUS = "|cffffffffShadow Power|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases the critical strike damage bonus of your Mind Blast, Mind Flay, and Shadow Word: Death by 100%.|r"
    }
},
{
    id = "spellImprovedShadowform",
    name = "buttonSpellImprovedShadowform",
    icon = "Interface/icons/spell_shadow_summonvoidwalker",
    position = {1045, -456},
    handler = "spellimprovedshadowform",
    tooltips = {
        frFR = "|cffffffffForme d'Ombre améliorée|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Votre technique Oubli a maintenant 100% de chances d'annuler tous les effets affectant le déplacement lorsque vous êtes en forme d'Ombre.\nRéduit de 70% le temps d'incantation ou de canalisation perdu provoqué par les dégâts pendant l'incantation des sorts d'Ombre lorsque vous êtes en forme d'Ombre.|r",
        enUS = "|cffffffffImproved Shadowform|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Your Fade ability now has 100% chance to cancel all movement impairing effects when in Shadowform.\nAdditionally, it reduces the time lost due to damage during casting or channeling Shadow spells by 70% while in Shadowform.|r"
    }
},
{
    id = "spellMisery",
    name = "buttonSpellMisery",
    icon = "Interface/icons/spell_shadow_misery",
    position = {663, -510},
    handler = "spellmisery",
    tooltips = {
        frFR = "|cffffffffMisère|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Vos sorts Mot de l'ombre : Douleur, Fouet mental et Toucher vampirique augmentent aussi les chances de toucher des sorts néfastes de 3% pendant 24 secondes.\nAugmente également de 15% l'avantage octroyé par votre puissance des sorts dont bénéficient Attaque mentale, Fouet mental et Incandescence mentale.|r",
        enUS = "|cffffffffMisery|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Your Shadow Word: Pain, Mind Flay, and Vampiric Touch also increase the chance for harmful spells to hit by 3% for 24 seconds.\nAlso increases the effect of Spell Power by 15% for your Mind Blast, Mind Flay, and Mind Sear.|r"
    }
},
{
    id = "spellPsychicHorror",
    name = "buttonSpellPsychicHorror",
    icon = "Interface/icons/spell_shadow_psychichorrors",
    position = {770, -510},
    handler = "spellpsychichorror",
    tooltips = {
        frFR = "|cffffffffHorreur psychique|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Vous terrifiez la cible, qui tremble, horrifiée, pendant 3 secondes et laisse tomber son arme tenue en main droite et ses armes à distance pendant 10 secondes.|r",
        enUS = "|cffffffffPsychic Horror|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Terrifies the target, causing them to tremble in fear for 3 seconds and drop their weapon held in the right hand and ranged weapons for 10 seconds.|r"
    }
},
{
    id = "spellVampiricTouch",
    name = "buttonSpellVampiricTouch",
    icon = "Interface/icons/spell_holy_stoicism",
    position = {880, -510},
    handler = "spellvampirictouch",
    tooltips = {
        frFR = "|cffffffffToucher vampirique|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Inflige 450 points de dégâts d'Ombre en 15 secondes.\nà votre cible et fait recevoir à un maximum de 10 membres du groupe ou du raid un montant de mana égal à 1% de leur maximum de mana toutes les 5 sec.\nquand vous infligez des dégâts avec Attaque mentale.\nDe plus, si le Toucher vampirique est dissipé, il inflige 720 points de dégâts à la cible affectée.|r",
        enUS = "|cffffffffVampiric Touch|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Deals 450 Shadow damage over 15 seconds to your target and returns 1% of their max mana every 5 seconds to up to 10 members of your group or raid when you deal damage with Mind Blast.\nAdditionally, if Vampiric Touch is dispelled, it deals 720 damage to the affected target.|r"
    }
},
{
    id = "spellPainandSuffering",
    name = "buttonSpellPainandSuffering",
    icon = "Interface/icons/spell_shadow_painandsuffering",
    position = {990, -510},
    handler = "spellpainandsufferings",
    tooltips = {
        frFR = "|cffffffffDouleur et souffrance|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Votre Fouet mental a 100% de chances de réinitialiser la durée de Mot de l'ombre : Douleur sur la cible et il réduit les dégâts que vous inflige votre propre Mot de l'ombre : Mort de 30%.|r",
        enUS = "|cffffffffPain and Suffering|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Your Mind Flay has a 100% chance to reset the duration of Shadow Word: Pain on the target and reduces the damage you deal with your own Shadow Word: Death by 30%.|r"
    }
},
{
    id = "spellTwistedFaith",
    name = "buttonSpellTwistedFaith",
    icon = "Interface/icons/spell_shadow_mindtwisting",
    position = {1100, -510},
    handler = "spelltwistedfaith",
    tooltips = {
        frFR = "|cffffffffFoi distordue|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente la puissance de vos sorts de 20% de votre total d'Esprit,\net les dégâts que vous infligez avec Fouet mental et Attaque mentale sont augmentés de 10% si votre cible est affectée par Mot de l'ombre : Douleur.|r",
        enUS = "|cffffffffTwisted Faith|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Increases the power of your spells by 20% of your total Spirit,\nand the damage dealt by your Mind Flay and Mind Blast is increased by 10% if your target is affected by Shadow Word: Pain.|r"
    }
},
{
    id = "spellDispersion",
    name = "buttonSpellDispersion",
    icon = "Interface/icons/spell_shadow_dispersion",
    position = {880, -293},
    handler = "spelldispersion",
    tooltips = {
        frFR = "|cffffffffDispersion|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Votre corps devient de l'énergie d'ombre pure, ce qui réduit tous les dégâts subis de 90%.\nVous ne pouvez pas attaquer ni lancer de sorts, mais vous régénérez 6% de votre mana toutes les 1 sec.\npendant 6 secondes.\nDispersion peut être lancé lorsque vous êtes étourdi, apeuré ou réduit au silence,\ndissipe tous les effets affectant le déplacement à son lancement et vous rend insensible à eux tant que vous êtes de l'énergie pure.|r",
        enUS = "|cffffffffDispersion|r\n|cffffffffTalent|r |cff919191Shadow|r\n|cffffffffRequires|r |cffffffffPriest|r\n|cffffd100Your body becomes pure shadow energy, reducing all damage taken by 90%.\nYou cannot attack or cast spells, but you regenerate 6% of your mana every second for 6 seconds.\nDispersion can be cast when stunned, feared, or silenced,\ndispels all movement-impairing effects upon activation and makes you immune to them while in pure energy form.|r"
		}
	}
}


-- CreateSpellButton("buttonSpellSpiritTap", "Interface/icons/spell_shadow_requiem", "|cffffffffConnexion spirituelle|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Vous donne 100% de chances de gagner un bonus de 100% à l'Esprit après avoir tué une cible qui rapporte de l'expérience ou de l'honneur.\nVotre mana se régénère à 83% de la vitesse de récupération normale pendant l'incantation de sorts.\nDure 15 secondes.|r", "spellspirittap", 718, -240)
-- CreateSpellButton("buttonSpellImprovedSpiritTap", "Interface/icons/spell_shadow_requiem", "|cffffffffConnexion spirituelle améliorée|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Vos coups critiques réussis avec Attaque mentale et Mot de l'ombre : Mort ont 100% de chances vos coups critiques avec Fouet mental ont 50% de chances d'augmenter votre total d'Esprit de 10%.\nPendant ce temps, votre mana se régénèrera à un taux de 33% lors des incantations.\nDure 8 secondes.|r", "spellimprovedspirittap", 825, -240)
-- CreateSpellButton("buttonSpellDarkness", "Interface/icons/spell_shadow_twilight", "|cffffffffTénèbres|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente les dégâts de vos sorts d'Ombre de 10%.|r", "spelldarkness", 935, -240)
-- CreateSpellButton("buttonSpellShadowAffinity", "Interface/icons/spell_shadow_shadowward", "|cffffffffAffinité avec l'Ombre|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit la menace générée par vos sorts d'Ombre de 25%, et vous recevez 15% de votre mana de base quand vos sorts Mot de l'ombre : Douleur ou Toucher vampirique sont dissipés.|r", "spellshadowaffinity", 1045, -240)
-- CreateSpellButton("buttonSpellImprovedShadowWordPain", "Interface/icons/spell_shadow_shadowwordpain", "|cffffffffMot de l'ombre : Douleur amélioré|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente les dégâts infligés par votre sort Mot de l'ombre : Douleur de 6%.|r", "spellimprovedshadowwordpain", 663, -293)
-- CreateSpellButton("buttonSpellShadowFocus", "Interface/icons/spell_shadow_burningspirit", "|cffffffffFocalisation de l'ombre|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente vos chances de toucher avec vos sorts d'Ombre de 3%, et réduit le coût en mana de vos sorts d'Ombre de 6%.|r", "spellshadowfocus", 770, -293)
-- CreateSpellButton("buttonSpellImprovedPsychicScream", "Interface/icons/spell_shadow_psychicscream", "|cffffffffCri psychique amélioré|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le temps de recharge de votre sort Cri psychique de 4 sec.|r", "spellimprovedpsychicscream", 990, -293)
-- CreateSpellButton("buttonSpellImprovedMindBlast", "Interface/icons/spell_shadow_unholyfrenzy", "|cffffffffAttaque mentale améliorée|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le temps de recharge de votre sort Attaque mentale de 2.5 sec.,\net tant que vous êtes en forme d'Ombre il a également 100% de chances de réduire tous les soins prodigués à la cible de 20% pendant 10 secondes.|r", "spellimprovedmindblast", 1100, -293)
-- CreateSpellButton("buttonSpellMindFlay", "Interface/icons/spell_shadow_siphonmana", "|cffffffffFouet mental|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Attaque l'esprit de la cible avec l'énergie de l'Ombre.\nInflige 45 points de dégâts d'Ombre en 3 secondes.\net réduit la vitesse de la cible de 50%.|r", "spellmindflay", 718, -348)
-- CreateSpellButton("buttonSpellVeiledShadows", "Interface/icons/spell_magic_lesserinvisibilty", "|cffffffffOmbres voilées|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le temps de recharge de votre technique Oubli de 6 sec.\net celui de votre technique Ombrefiel de 2 minutes.|r", "spellveiledshadows", 825, -348)
-- CreateSpellButton("buttonSpellShadowReach", "Interface/icons/spell_shadow_chilltouch", "|cffffffffAllonge de l'Ombre|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente de 20% la portée de vos sorts offensifs d'Ombre.|r", "spellshadowreacht", 935, -348)
-- CreateSpellButton("buttonSpellShadowWeaving", "Interface/icons/spell_shadow_blackplague", "|cffffffffTissage de l'ombre|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Vos sorts d'Ombre infligeant des dégâts ont 100% de chances d'augmenter les dégâts d'Ombre que vous infligez de 2% pendant 15 seconds.\nCumulable jusqu'à 5 fois.|r", "spellshadowweaving", 1045, -348)
-- CreateSpellButton("buttonSpellSilence", "Interface/icons/spell_shadow_impphaseshift", "|cffffffffSilence|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Rend la cible silencieuse, l'empêchant de lancer des sorts pendant 5 secondes.\nLes incantations de sorts des victimes personnages non joueurs sont également interrompues pendant 3 secondes.|r", "spellsilence", 663, -402)
-- CreateSpellButton("buttonSpellVampiricEmbrace", "Interface/icons/spell_shadow_unsummonbuilding", "|cffffffffEtreinte vampirique|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Vous emplit de l'énergie de l'étreinte de l'Ombre, qui vous soigne pour 15% et les autres membres du groupe pour 3% de tous les dégâts d'Ombre que vous infligez avec des sorts monocibles pendant 30 mn.|r", "spellvampiricembrace", 770, -402)
-- CreateSpellButton("buttonSpellImprovedVampiricEmbrace", "Interface/icons/spell_shadow_improvedvampiricembrace", "|cffffffffEtreinte vampirique améliorée|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente de 67% les soins prodigués par Etreinte vampirique.|r", "spellimprovedvampiricembrace", 880, -402)
-- CreateSpellButton("buttonSpellFocusedMind", "Interface/icons/spell_nature_focusedmind", "|cffffffffEsprit focalisé|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Réduit le coût en mana de vos sorts Attaque mentale, Contrôle mental, Fouet mental et Incandescence mentale de 15%.|r", "spellfocusedmind", 990, -402)
-- CreateSpellButton("buttonSpellMindMelt", "Interface/icons/spell_shadow_skull", "|cffffffffFonte de l'esprit|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente les chances de coup critique de vos sorts Attaque mentale, Fouet mental et Incandescence mentale de 4%,\net augmente les chances de coup critique périodique de vos sorts Toucher vampirique, Peste dévorante et Mot de l'ombre : Douleur de 6%.|r", "spellmindmelt", 1100, -402)
-- CreateSpellButton("buttonSpellImprovedDevouringPlague", "Interface/icons/spell_shadow_devouringplague", "|cffffffffPeste dévorante améliorée|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente les dégâts périodiques infligés par votre Peste dévorante de 15%,\net quand vous la lancez vous infligez instantanément un montant de dégâts égal à 30% du total de son effet périodique.|r", "spellimproveddevouringplague", 718, -456)
-- CreateSpellButton("buttonSpellShadowform", "Interface/icons/spell_shadow_shadowform", "|cffffffffForme d'Ombre|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Adopte une Forme d'Ombre qui augmente de 15% les dégâts d'Ombre que vous infligez en plus de réduire de 15% tous les dégâts que vous subissez et de 30% la menace générée.\nCependant, vous ne pouvez pas lancer de sorts du Sacré lorsque vous êtes sous cette forme, à part Guérison des maladies et Abolir maladie.\nLes dégâts périodiques de vos sorts Mot de l'ombre : Douleur, Peste dévorante et Toucher vampirique sont augmentés de 100% quand ils sont critiques,\nPeste dévorante et Toucher vampirique bénéficient également du bonus de hâte.|r", "spellshadowform", 825, -456)
-- CreateSpellButton("buttonSpellShadowPower", "Interface/icons/spell_shadow_shadowpower", "|cffffffffPuissance de l'ombre|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente le bonus de dégâts des coups critiques de vos sorts Attaque mentale, Fouet mental et Mot de l'ombre : Mort de 100%.|r", "spellshadowpower", 935, -456)
-- CreateSpellButton("buttonSpellImprovedShadowform", "Interface/icons/spell_shadow_summonvoidwalker", "|cffffffffForme d'Ombre améliorée|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Votre technique Oubli a maintenant 100% de chances d'annuler tous les effets affectant le déplacement lorsque vous êtes en forme d'Ombre.\nRéduit de 70% le temps d'incantation ou de canalisation perdu provoqué par les dégâts pendant l'incantation des sorts d'Ombre lorsque vous êtes en forme d'Ombre.|r", "spellimprovedshadowform", 1045, -456)
-- CreateSpellButton("buttonSpellMisery", "Interface/icons/spell_shadow_misery", "|cffffffffMisère|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Vos sorts Mot de l'ombre : Douleur, Fouet mental et Toucher vampirique augmentent aussi les chances de toucher des sorts néfastes de 3% pendant 24 secondes.\nAugmente également de 15% l'avantage octroyé par votre puissance des sorts dont bénéficient Attaque mentale, Fouet mental et Incandescence mentale.|r", "spellmisery", 663, -510)
-- CreateSpellButton("buttonSpellPsychicHorror", "Interface/icons/spell_shadow_psychichorrors", "|cffffffffHorreur psychique|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Vous terrifiez la cible, qui tremble, horrifiée, pendant 3 secondes et laisse tomber son arme tenue en main droite et ses armes à distance pendant 10 secondes.|r", "spellpsychichorror", 770, -510)
-- CreateSpellButton("buttonSpellVampiricTouch", "Interface/icons/spell_holy_stoicism", "|cffffffffToucher vampirique|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Inflige 450 points de dégâts d'Ombre en 15 seconds.\nà votre cible et fait recevoir à un maximum de 10 membres du groupe ou du raid un montant de mana égal à 1% de leur maximum de mana toutes les 5 sec.\nquand vous infligez des dégâts avec Attaque mentale.\nDe plus, si le Toucher vampirique est dissipé, il inflige 720 points de dégâts à la cible affectée.|r", "spellvampirictouch", 880, -510)
-- CreateSpellButton("buttonSpellPainandSuffering", "Interface/icons/spell_shadow_painandsuffering", "|cffffffffDouleur et souffrance|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Votre Fouet mental a 100% de chances de réinitialiser la durée de Mot de l'ombre : Douleur sur la cible et il réduit les dégâts que vous inflige votre propre Mot de l'ombre : Mort de 30%.|r", "spellpainandsufferings", 990, -510)
-- CreateSpellButton("buttonSpellTwistedFaith", "Interface/icons/spell_shadow_mindtwisting", "|cffffffffFoi distordue|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Augmente la puissance de vos sorts de 20% de votre total d'Esprit,\net les dégâts que vous infligez avec Fouet mental et Attaque mentale sont augmentés de 10% si votre cible est affectée par Mot de l'ombre : Douleur.|r", "spelltwistedfaith", 1100, -510)
-- CreateSpellButton("buttonSpellDispersion", "Interface/icons/spell_shadow_dispersion", "|cffffffffDispersion|r\n|cffffffffTalent|r |cff919191Ombre|r\n|cffffffffRequiert|r |cffffffffPrêtre|r\n|cffffd100Votre corps devient de l'énergie d'ombre pure, ce qui réduit tous les dégâts subis de 90%.\nVous ne pouvez pas attaquer ni lancer de sorts, mais vous régénérez 6% de votre mana toutes les 1 sec.\npendant 6 seconds.\nDispersion peut être lancé lorsque vous êtes étourdi, apeuré ou réduit au silence,\ndissipe tous les effets affectant le déplacement à son lancement et vous rend insensible à eux tant que vous êtes de l'énergie pure.|r", "spelldispersion", 880, -293)

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

-- Créez le bouton Save à l'intérieur de la fenêtre frameTalentPriest
local saveButton = CreateFrame("Button", "saveButton", frameTalentPriest, "UIPanelButtonTemplate")
saveButton:SetSize(85, 25)
saveButton:SetPoint("BOTTOMRIGHT", buttonTalentPriestClose, "BOTTOMLEFT", -185, 5) -- Place le bouton Save à gauche du bouton Close
saveButton:SetText(saveButtonText)

-- Fonction qui prend un screenshot quand le bouton est cliqué
saveButton:SetScript("OnClick", function()
    Screenshot()  -- Prendre un screenshot et l'enregistrer dans le dossier Screenshots du jeu
    print(screenshotMessage)  -- Affiche un message de confirmation en fonction de la locale
end)

-- Affiche l'UI des talents
--frameTalentPriest:Show()

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

-- Créez le bouton Reset à l'intérieur de la fenêtre frameTalentPriest
local buttonReset = CreateFrame("Button", "buttonReset", frameTalentPriest, "UIPanelButtonTemplate")
buttonReset:SetSize(85, 25)
buttonReset:SetPoint("BOTTOMRIGHT", buttonTalentPriestClose, "BOTTOMLEFT", -95, 5) -- Place le bouton Reset à gauche du bouton Reload
buttonReset:SetText(buttonResetText)

local function ResetTalents()
    -- Ajoutez ici la logique pour réinitialiser les talents du joueur
    AIO.Handle("TalentPriestspell", "ResetTalents")
    resetButtonClicked = true -- Marquez le bouton Réinitialiser comme cliqué
end

buttonReset:SetScript("OnClick", ResetTalents)

-- Créez le bouton Reload à l'intérieur de la fenêtre frameTalentPriest
local buttonReload = CreateFrame("Button", "buttonReload", frameTalentPriest, "UIPanelButtonTemplate")
buttonReload:SetSize(85, 25)
buttonReload:SetPoint("BOTTOMRIGHT", buttonTalentPriestClose, "BOTTOMLEFT", -5, 5) -- Place le bouton Reload à gauche du bouton Close
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
        frameTalentPriest:Hide()
        buttonReload:Hide()
        PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
    else
        frameTalentPriest:Show()
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
        frFR = "|cffffffffTalents|r |cffffffff(Prêtre)|r\n\nL'éventail des talents disponibles\npour améliorer et spécialiser\nvotre personnage.",
        enUS = "|cffffffffTalents|r |cffffffff(Priest)|r\n\nThe range of available talents\nfor enhancing and specializing\nyour character."
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

-- Vérifier si le joueur est un Priest avant de créer le bouton
local playerClass = select(2, UnitClass("player")) -- Obtenir la classe du joueur
if playerClass == "PRIEST" then
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
PriestHandlers.UpdateTalentCount = function(player, talentsAppris)
    if fontTalentPriestFrameText then
        fontTalentPriestFrameText:SetText(talentsAppris .. " / " .. MAX_TALENTS)
    end
end

-- Mise à jour des points de talent utilisés avec texte localisé
PriestHandlers.UpdateTalentPointsUsed = function(player, pointsUsed, pointsBeforeReset)
    -- Utilisation du texte localisé pour les points avant réinitialisation
    print(string.format(GetLocalizedPointsBeforeResetText(), pointsBeforeReset))
end

-- Affichage des talents restants (items 338404 dans le sac)
PriestHandlers.UpdateTalentItemCount = function(player, count)
    if fontTalentPointsRemainingText then
        fontTalentPointsRemainingText:SetText("|cFFFFFFFFTalents restants : " .. count .. "|r")
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
        fontTalentPointsRemainingText:SetText("|cFFFFFFFFTalents restants : " .. (count or 0) .. "|r")
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
if playerClass == "PRIEST" then
    -- Surcharge OnHide pour synchroniser talentsWindowOpen quand Échap est pressé
    local _originalOnHide = frameTalentPriest:GetScript("OnHide")
    frameTalentPriest:SetScript("OnHide", function(self)
        talentsWindowOpen = false
        if _originalOnHide then _originalOnHide(self) end
    end)
    -- WoW appelle automatiquement Hide() sur les frames listées ici quand Échap est pressé
    tinsert(UISpecialFrames, "frameTalentPriest")
end