local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local MageHandlers = AIO.AddHandlers("TalentMagespell", {})

function MageHandlers.ShowTalentMage(player)
    frameTalentMage:Show()
    -- Redemande au serveur l’état visuel au cas où
    AIO.Handle("TalentMagespell", "RequestLearnedTalents")
	-- Redemande le nombre de talents restants
    AIO.Handle("TalentMagespell", "GetTalentItemCount")
end

local MAX_TALENTS = 60 -- Définition du nombre maximal de talents que le joueur peut apprendre

local OPEN_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_final_trait_unlocked.ogg"
local CLOSE_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_trait_refund_end.ogg"
local SPELL_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_80_azeritearmor_rotationends_02.ogg"

-- Attribute window
local frameTalentMage = CreateFrame("Frame", "frameTalentMage", UIParent)
frameTalentMage:SetSize(1200, 650)
frameTalentMage:SetMovable(true)
frameTalentMage:EnableMouse(true)
frameTalentMage:RegisterForDrag("LeftButton")
frameTalentMage:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, -50) -- Adjust the X and Y coordinates
frameTalentMage:SetBackdrop(
{
    -- bgFile = "interface/TalentFrame/talentsclassbackgroundMage", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    bgFile = "interface/TalentFrame/Template/Class/Mage/talentsclassbackgroundmage2", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedmage", --Interface/DialogFrame/UI-DialogBox-Border
    edgeSize = 20,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})

-- Ajoutez la texture de l'icône du Mage
local mageIcon = frameTalentMage:CreateTexture("MageIcon", "OVERLAY")
mageIcon:SetTexture("Interface\\TalentFrame\\Template\\Class\\Mage\\IconeMage.blp")
mageIcon:SetSize(60, 60)
mageIcon:SetPoint("TOPLEFT", frameTalentMage, "TOPLEFT", -10, 10)

-- Template Talent Frame

-- Ajoute une textureone pour l'image BLP
local textureone = frameTalentMage:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
textureone:SetTexture("Interface\\TalentFrame\\Template\\Class\\Mage\\TalentFrameTemplate.blp")
textureone:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
textureone:SetPoint("TOPLEFT", frameTalentMage, "TOPLEFT", -170, 140) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentMage:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Ajoute une texturetwo pour l'image BLP
local texturetwo = frameTalentMage:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
texturetwo:SetTexture("Interface\\TalentFrame\\Template\\Class\\Mage\\TalentFrameTemplateOriginal.blp")
texturetwo:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
texturetwo:SetPoint("TOPRIGHT", frameTalentMage, "TOPRIGHT", 170, 140) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentMage:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Drag & Drop
frameTalentMage:SetScript("OnDragStart", frameTalentMage.StartMoving)
frameTalentMage:SetScript("OnHide", frameTalentMage.StopMovingOrSizing)
frameTalentMage:SetScript("OnDragStop", frameTalentMage.StopMovingOrSizing)
frameTalentMage:Hide()

-- Nouveau template d'arête
frameTalentMage:SetBackdropBorderColor(0.5, 0.7, 1) -- Couleur Bleu Ciel / talentsclassbackgroundmage2 / talentsclassbackgroundmage3

-- Nouveau template d'arête
-- frameTalentMage:SetBackdropBorderColor(199, 156, 110) -- Couleur marron / talentsclassbackgroundmage

-- Close button
local buttonTalentMageClose = CreateFrame("Button", "buttonTalentMageClose", frameTalentMage, "UIPanelCloseButton")
buttonTalentMageClose:SetPoint("TOPRIGHT", -12, -12)
buttonTalentMageClose:EnableMouse(true)
buttonTalentMageClose:SetSize(32, 32)

local function CloseTalentWindow()
    frameTalentMage:Hide()
    PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
end

-- Associez la fonction de fermeture au bouton de fermeture
buttonTalentMageClose:SetScript("OnClick", CloseTalentWindow)

-- Title bar
local frameTalentMageTitleBar = CreateFrame("Frame", "frameTalentMageTitleBar", frameTalentMage, nil)
frameTalentMageTitleBar:SetSize(135, 25)
frameTalentMageTitleBar:SetBackdrop(
{
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedmage",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentMageTitleBar:SetPoint("TOP", 0, 20)

local fontTalentMageTitleText = frameTalentMageTitleBar:CreateFontString("fontTalentMageTitleText")
fontTalentMageTitleText:SetFont("Fonts\\FRIZQT__.TTF", 13)
fontTalentMageTitleText:SetSize(190, 5)
fontTalentMageTitleText:SetPoint("CENTER", 0, 0)
fontTalentMageTitleText:SetText("|cffFFC125Talents|r")

-- Détecte la langue du client
local locale = GetLocale() -- Retourne "enUS", "frFR", etc.

-- Table des traductions
local localizedTexts = {
    enUS = "|cffFFC125Mage|r",
    frFR = "|cffFFC125Mage|r",
}

-- Récupère le texte correspondant à la langue actuelle ou par défaut en anglais
local textToDisplay = localizedTexts[locale] or localizedTexts["enUS"]

local fontTalentMageFrameText = frameTalentMageTitleBar:CreateFontString("fontTalentMageFrameText")
fontTalentMageFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentMageFrameText:SetSize(200, 5)
fontTalentMageFrameText:SetPoint("TOPLEFT", frameTalentMageTitleBar, "BOTTOMLEFT", -30, -35) -- Adjust the Y offset as needed
fontTalentMageFrameText:SetText(textToDisplay)

-- Remplacez votre ligne existante pour la création du texte par celle-ci
local fontTalentMageFrameText = frameTalentMageTitleBar:CreateFontString("fontTalentMageFrameText")
fontTalentMageFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentMageFrameText:SetSize(200, 5)
fontTalentMageFrameText:SetPoint("TOPLEFT", frameTalentMageTitleBar, "BOTTOMLEFT", -30, -60) -- Adjust the Y offset as needed
fontTalentMageFrameText:SetText("0 / " .. MAX_TALENTS) -- Initialisez le texte avec 0 talents appris

-------------------------------------------------------------
-- Affichage "Talents restants" (item 338404 dans le sac)
-------------------------------------------------------------

local frameTalentPointsRemaining = CreateFrame("Frame", "frameTalentPointsRemaining", frameTalentMage, nil)
frameTalentPointsRemaining:SetSize(220, 30)
frameTalentPointsRemaining:SetBackdrop({
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedmage",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentPointsRemaining:SetPoint("BOTTOMRIGHT", frameTalentMage, "BOTTOMRIGHT", -960, 10)

local fontTalentPointsRemainingText = frameTalentPointsRemaining:CreateFontString("fontTalentPointsRemainingText")
fontTalentPointsRemainingText:SetFont("Fonts\\FRIZQT__.TTF", 14)
fontTalentPointsRemainingText:SetSize(210, 20)
fontTalentPointsRemainingText:SetPoint("CENTER", 0, 0)
fontTalentPointsRemainingText:SetText("|cFF40C7EBTalents restants : 0|r")
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
MageHandlers.UpdateLearnedTalents = function(player, learnedSpells)
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

    local button = CreateFrame("Button", name, frameTalentMage, nil)
    button:SetSize(40, 40)
    button:EnableMouse(true)
    button:SetNormalTexture(texturePath)
    button:SetPushedTexture("Interface/Buttons/checkbuttonhilight")
    button:SetHighlightTexture("Interface/Buttons/checkbuttonhilight")
    button:SetPoint("TOPLEFT", positionX, positionY)
	
	-- Stocker le bouton pour pouvoir le mettre à jour plus tard
    spellButtons[talentHandler] = button
	
	--  AJOUT DU CADRE VISUEL SUPERPOSÉ SUR LE BOUTON
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
button.learnIndicator = learnIndicator --  rendre accessible à l’extérieur

-- Texte pour afficher l'état du bouton (0 ou 1)
local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
buttonText:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
button.buttonText = buttonText --  rendre accessible à l’extérieur

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
                AIO.Handle("TalentMagespell", talentHandler, 1)
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

-- Arcanes

-- Table des sorts
local spells = {
{
    id = "spellArcaneSubtlety",
    name = "buttonSpellArcaneSubtlety",
    icon = "Interface/icons/spell_holy_dispelmagic",
    position = {100, -80},
    handler = "spellarcanesubtlety",
    tooltips = {
        frFR = "|cffffffffSubtilité des arcanes|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit de 30% les chances que vos sorts bénéfiques soient dissipés et réduit de 40% la menace générée par vos sorts des Arcanes.|r",
        enUS = "|cffffffffArcane Subtlety|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Reduces the chance for your beneficial spells to be dispelled by 30% and reduces the threat generated by your Arcane spells by 40%.|r"
    }
},

{
    id = "spellArcaneFocus",
    name = "buttonSpellArcaneFocus",
    icon = "Interface/icons/spell_holy_devotion",
    position = {205, -75},
    handler = "spellarcanefocus",
    tooltips = {
        frFR = "|cffffffffFocalisation des arcanes|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente les chances de toucher et réduit le coût en mana de vos sorts des Arcanes de 3%.|r",
        enUS = "|cffffffffArcane Focus|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases your chance to hit and reduces the mana cost of your Arcane spells by 3%.|r"
    }
},

{
    id = "spellArcaneStability",
    name = "buttonSpellArcaneStability",
    icon = "Interface/icons/spell_nature_starfall",
    position = {315, -75},
    handler = "spellarcanestability",
    tooltips = {
        frFR = "|cffffffffStabilité arcanique|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit de 100% l'interruption causée par les attaques infligeant des dégâts pendant que vous incantez Projectiles des arcanes et Déflagration des arcanes.|r",
        enUS = "|cffffffffArcane Stability|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Reduces 100% of the interruption caused by damage-dealing attacks while casting Arcane Missiles and Arcane Explosion.|r"
    }
},

{
    id = "spellArcaneFortitude",
    name = "buttonSpellArcaneFortitude",
    icon = "Interface/icons/spell_arcane_arcaneresilience",
    position = {418, -80},
    handler = "spellarcanefortitude",
    tooltips = {
        frFR = "|cffffffffRobustesse des arcanes|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente votre Armure d'un montant égal à 150% de votre Intelligence.|r",
        enUS = "|cffffffffArcane Fortitude|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases your Armor by an amount equal to 150% of your Intelligence.|r"
    }
},

{
    id = "spellMagicAbsorption",
    name = "buttonSpellMagicAbsorption",
    icon = "Interface/icons/spell_nature_astralrecalgroup",
    position = {150, -130},
    handler = "spellmagicabsorption",
    tooltips = {
        frFR = "|cffffffffAbsorption de magie|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente toutes les résistances d'1 par niveau.\nTous les sorts auxquels vous résistez entièrement restaurent 2% de votre total de mana.\nTemps de recharge d'1 sec.|r",
        enUS = "|cffffffffMagic Absorption|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases all resistances by 1 per level.\nAny spell you fully resist restores 2% of your total mana.\nCooldown of 1 sec.|r"
    }
},
{
    id = "spellArcaneConcentration",
    name = "buttonSpellArcaneConcentration",
    icon = "Interface/icons/spell_shadow_manaburn",
    position = {260, -130},
    handler = "spellarcaneconcentration",
    tooltips = {
        frFR = "|cffffffffConcentration des arcanes|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Vous confère 10% de chances d'entrer dans un état d'Idées claires après avoir infligé des dégâts avec un sort à la cible.\nCet état réduit le coût en mana de votre prochain sort de 100%.|r",
        enUS = "|cffffffffArcane Concentration|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Gives you a 10% chance to enter Clearcasting state after dealing damage with a spell to the target.\nThis state reduces the mana cost of your next spell by 100%.|r"
    }
},

{
    id = "spellMagicAttunement",
    name = "buttonSpellMagicAttunement",
    icon = "Interface/icons/spell_nature_abolishmagic",
    position = {370, -130},
    handler = "spellmagicattunement",
    tooltips = {
        frFR = "|cffffffffHarmonisation de la magie|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 6 mètres la portée de vos sorts des Arcanes et de 50% les effets de vos sorts Amplification de la magie et Atténuation de la magie.|r",
        enUS = "|cffffffffMagic Attunement|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases the range of your Arcane spells by 6 meters and increases the effects of your Arcane Amplification and Arcane Attunement spells by 50%.|r"
    }
},

{
    id = "spellSpellImpact",
    name = "buttonSpellImpact",
    icon = "Interface/icons/spell_nature_wispsplode",
    position = {475, -133},
    handler = "spellspellimpact",
    tooltips = {
        frFR = "|cffffffffImpact des sorts|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 6% supplémentaires les dégâts de vos sorts Explosion des arcanes, Déflagration des arcanes, Vague explosive, Trait de feu, Brûlure, Boule de feu, Javelot de glace et Cône de froid.|r",
        enUS = "|cffffffffSpell Impact|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases the damage of your Arcane Explosion, Arcane Blast, Arcane Wave, Fireball, Scorch, Fire Blast, Ice Lance, and Cone of Cold spells by 6%.|r"
    }
},

{
    id = "spellStudentofthemind",
    name = "buttonSpellFocusMagic",
    icon = "Interface/icons/ability_mage_studentofthemind",
    position = {96, -185},
    handler = "spellstudentofthemind",
    tooltips = {
        frFR = "|cffffffffEtudiant de la raison|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente votre total d'Esprit de 10%.|r",
        enUS = "|cffffffffStudent of the Mind|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases your total Spirit by 10%.|r"
    }
},

{
    id = "spellFocusmagic",
    name = "buttonSpellGrimReach",
    icon = "Interface/icons/spell_arcane_studentofmagic",
    position = {205, -185},
    handler = "spellfocusmagic",
    tooltips = {
        frFR = "|cffffffffFocalisation de la magie|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 3% les chances de coup critique de la cible avec les sorts.\nQuand la cible réussit un coup critique, les chances de coup critique avec les sorts du lanceur sont augmentées de 3% pendant 10 secondes.\nNe peut être lancé sur soi-même.|r",
        enUS = "|cffffffffFocus Magic|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases the target's spell critical strike chance by 3%.\nWhen the target critically strikes, the caster's spell critical strike chance is increased by 3% for 10 seconds.\nCannot be cast on yourself.|r"
    }
},
{
    id = "spellArcaneShielding",
    name = "buttonSpellArcaneShielding",
    icon = "Interface/icons/spell_shadow_detectlesserinvisibility",
    position = {315, -185},
    handler = "spellarcaneshielding",
    tooltips = {
        frFR = "|cffffffffSauvegarde des arcanes|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit de 33% le mana perdu par point de dégâts reçu lorsque Bouclier de mana est actif et augmente de 50% les résistances conférées par Armure du mage.|r",
        enUS = "|cffffffffArcane Shielding|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Reduces the mana lost per point of damage taken by 33% when Mana Shield is active and increases the resistances granted by Mage Armor by 50%.|r"
    }
},

{
    id = "spellImprovedCounterspell",
    name = "buttonSpellImprovedCounterspell",
    icon = "Interface/icons/spell_frost_iceshock",
    position = {422, -185},
    handler = "spellimprovedcounterspell",
    tooltips = {
        frFR = "|cffffffffContresort amélioré|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Votre Contresort réduit également la cible au silence pendant 4 secondes.|r",
        enUS = "|cffffffffImproved Counterspell|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Your Counterspell also silences the target for 4 seconds.|r"
    }
},

{
    id = "spellArcaneMeditation",
    name = "buttonSpellArcaneMeditation",
    icon = "Interface/icons/spell_shadow_siphonmana",
    position = {527, -190},
    handler = "spellarcanemeditation",
    tooltips = {
        frFR = "|cffffffffMéditation des arcanes|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Vous confère 50% de votre vitesse de récupération du mana normale pendant l'incantation.|r",
        enUS = "|cffffffffArcane Meditation|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Gives you 50% of your normal mana regeneration speed while casting.|r"
    }
},

{
    id = "spellTormenttheWeak",
    name = "buttonSpellTormenttheWeak",
    icon = "Interface/icons/ability_mage_tormentoftheweak",
    position = {43, -240},
    handler = "spelltormentheweak",
    tooltips = {
        frFR = "|cffffffffTourmenter les faibles|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Vos techniques Éclair de givre, Boule de feu, Éclair de givrefeu, Explosion pyrotechnique, Projectiles des arcanes,\nDéflagration des arcanes et Barrage des arcanes infligent 12% de dégâts supplémentaires aux cibles piégées ou ralenties.|r",
        enUS = "|cffffffffTorment the Weak|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Your Frostbolt, Fireball, Ice Lance, Pyroblast, Arcane Missiles, Arcane Blast, and Arcane Barrage deal 12% increased damage to frozen or slowed targets.|r"
    }
},

{
    id = "spellImprovedBlink",
    name = "buttonSpellImprovedBlink",
    icon = "Interface/icons/spell_arcane_blink",
    position = {150, -240},
    handler = "spellimprovedblink",
    tooltips = {
        frFR = "|cffffffffTransfert amélioré|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit le coût en mana de Transfert de 50% et pendant 4 secondes après l'avoir lancé, la probabilité que vous soyez touché par tous les sorts et attaques est réduite de 30%.|r",
        enUS = "|cffffffffImproved Blink|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Reduces the mana cost of Blink by 50% and for 4 seconds after casting, your chance to be hit by all spells and attacks is reduced by 30%.|r"
    }
},
{
    id = "spellPresenceofMind",
    name = "buttonSpellPresenceofMind",
    icon = "Interface/icons/spell_nature_enchantarmor",
    position = {368, -240},
    handler = "spellpresenceofmind",
    tooltips = {
        frFR = "|cffffffffPrésence spirituelle|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Lorsque cette technique est activée, votre prochain sort de mage dont le temps d'incantation est inférieur à 10 sec.\ndevient un sort instantané.|r",
        enUS = "|cffffffffPresence of Mind|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100When activated, your next mage spell with a casting time less than 10 seconds becomes an instant cast.|r"
    }
},

{
    id = "spellArcaneMind",
    name = "buttonSpellArcaneMind",
    icon = "Interface/icons/spell_shadow_charm",
    position = {478, -240},
    handler = "spellarcanemind",
    tooltips = {
        frFR = "|cffffffffEsprit des arcanes|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente votre total d'Intelligence de 15%.|r",
        enUS = "|cffffffffArcane Mind|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases your total Intelligence by 15%.|r"
    }
},

{
    id = "spellPrismaticCloak",
    name = "buttonSpellPrismaticCloak",
    icon = "Interface/icons/spell_arcane_prismaticcloak",
    position = {98, -293},
    handler = "spellprismaticcloak",
    tooltips = {
        frFR = "|cffffffffCape prismatique|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit tous les dégâts subis de 6% et réduit le temps de disparition de votre sort Invisibilité de 3 sec.|r",
        enUS = "|cffffffffPrismatic Cloak|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Reduces all damage taken by 6% and reduces the fade time of your Invisibility spell by 3 seconds.|r"
    }
},

{
    id = "spellArcaneInstability",
    name = "buttonSpellArcaneInstability",
    icon = "Interface/icons/spell_shadow_teleport",
    position = {205, -293},
    handler = "spellarcaneinstability",
    tooltips = {
        frFR = "|cffffffffInstabilité des arcanes|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 3% les dégâts infligés par vos sorts et vos chances de coup critique.|r",
        enUS = "|cffffffffArcane Instability|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases your spell damage and critical strike chance by 3%.|r"
    }
},

{
    id = "spellArcanePotency",
    name = "buttonSpellArcanePotency",
    icon = "Interface/icons/spell_arcane_arcanepotency",
    position = {315, -293},
    handler = "spellarcanepotency",
    tooltips = {
        frFR = "|cffffffffToute-puissance des arcanes|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 30% les chances de coup critique de tous les sorts infligeant des dégâts lancés sous l'effet d'Idées claires ou Présence spirituelle.|r",
        enUS = "|cffffffffArcane Potency|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases your critical strike chance by 30% for all damage-dealing spells cast under the effects of Clearcasting or Presence of Mind.|r"
    }
},
{
    id = "spellArcaneEmpowerment",
    name = "buttonSpellArcaneEmpowerment",
    icon = "Interface/icons/spell_nature_starfall",
    position = {422, -293},
    handler = "spellarcaneempowerment",
    tooltips = {
        frFR = "|cffffffffRenforcement arcanique|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente les dégâts de votre sort Projectiles des arcanes d'un montant égal à 45% de votre puissance des sorts et les dégâts de Déflagration des arcanes de 9% de votre puissance des sorts.\nDe plus, augmente les dégâts de tous les membres du groupe et du raid se trouvant à moins de 100 mètres de 3%.|r",
        enUS = "|cffffffffArcane Empowerment|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases the damage of your Arcane Missiles by an amount equal to 45% of your spell power and the damage of Arcane Explosion by 9% of your spell power.\nAdditionally, increases the damage of all party and raid members within 100 yards by 3%.|r"
    }
},

{
    id = "spellArcanePower",
    name = "buttonSpellArcanePower",
    icon = "Interface/icons/spell_nature_lightning",
    position = {527, -295},
    handler = "spellarcanepower",
    tooltips = {
        frFR = "|cffffffffPouvoir des arcanes|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Lorsqu'il est activé, vos sorts infligent 20% de points de dégâts supplémentaires et ils vous coûtent 20% de points de mana supplémentaires.\nCet effet dure 15 sec.|r",
        enUS = "|cffffffffArcane Power|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100When activated, your spells deal 20% additional damage but cost 20% more mana.\nThis effect lasts for 15 seconds.|r"
    }
},

{
    id = "spellIncantersAbsorption",
    name = "buttonSpellIncantersAbsorption",
    icon = "Interface/icons/ability_mage_incantersabsorbtion",
    position = {43, -350},
    handler = "spellincantersabsorption",
    tooltips = {
        frFR = "|cffffffffAbsorption de l'incantateur|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Lorsque votre Bouclier de mana, Gardien de givre, Gardien de feu ou Barrière de glace absorbe des dégâts, les dégâts infligés par vos sorts sont augmentés de 15% du montant absorbé pendant 10 secondes.|r",
        enUS = "|cffffffffIncanter's Absorption|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100When your Mana Shield, Frost Ward, Fire Ward, or Ice Barrier absorbs damage, the damage dealt by your spells is increased by 15% of the absorbed amount for 10 seconds.|r"
    }
},

{
    id = "spellArcaneFlows",
    name = "buttonSpellArcaneFlows",
    icon = "Interface/icons/ability_mage_potentspirit",
    position = {150, -350},
    handler = "spellarcaneflows",
    tooltips = {
        frFR = "|cffffffffFlux arcaniques|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit le temps de recharge de vos sorts Présence spirituelle, Pouvoir des arcanes et Invisibilité de 30% et le temps de recharge de votre sort Evocation de 2 min.|r",
        enUS = "|cffffffffArcane Flows|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Reduces the cooldown of your Presence of Mind, Arcane Power, and Invisibility spells by 30% and reduces the cooldown of your Evocation spell by 2 minutes.|r"
    }
},

{
    id = "spellMindMastery",
    name = "buttonSpellMindMastery",
    icon = "Interface/icons/spell_arcane_mindmastery",
    position = {260, -350},
    handler = "spellmindmastery",
    tooltips = {
        frFR = "|cffffffffMaîtrise mentale|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente la puissance des sorts d'un montant égal à 15% de votre Intelligence totale.|r",
        enUS = "|cffffffffMind Mastery|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases spell power by an amount equal to 15% of your total Intelligence.|r"
    }
},
{
    id = "spellSlow",
    name = "buttonSpellSlow",
    icon = "Interface/icons/spell_nature_slow",
    position = {368, -350},
    handler = "spellslow",
    tooltips = {
        frFR = "|cffffffffLenteur|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit la vitesse de déplacement de la cible de 60%, augmente le temps entre les attaques à distance de 60% et augmente le temps d'incantation de 30%.\nDure 15 secondes.\nLenteur ne peut affecter qu'une seule cible à la fois.|r",
        enUS = "|cffffffffSlow|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Reduces the target's movement speed by 60%, increases the time between ranged attacks by 60%, and increases casting time by 30%.\nLasts 15 seconds.\nSlow can only affect one target at a time.|r"
    }
},

{
    id = "spellMissileBarrage",
    name = "buttonSpellMissileBarrage",
    icon = "Interface/icons/ability_mage_missilebarrage",
    position = {478, -350},
    handler = "spellmissilebarrage",
    tooltips = {
        frFR = "|cffffffffBarrage de projectiles|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Confère à votre Déflagration des arcanes 40% de chances et à vos sorts Barrage des arcanes, Boule de feu, Eclair de givre\net Eclair de givrefeu 20% de chances de réduire la durée de canalisation du prochain sort Projectiles des arcanes de 2.5 sec.\net réduit le coût en mana de 100%.\nDes projectiles sont tirés toutes les 0,5 sec.|r",
        enUS = "|cffffffffMissile Barrage|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Gives your Arcane Blast a 40% chance and your Arcane Barrage, Fireball, Frostbolt,\nand Frostfire Bolt a 20% chance to reduce the channeling duration of the next Arcane Missiles spell by 2.5 sec.\nAlso reduces the mana cost by 100%.\nProjectiles are fired every 0.5 sec.|r"
    }
},


-- CreateSpellButton("buttonSpellArcaneSubtlety", "Interface/icons/spell_holy_dispelmagic", "|cffffffffSubtilité des arcanes|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit de 30% les chances que vos sorts bénéfiques soient dissipés et réduit de 40% la menace générée par vos sorts des Arcanes.|r", "spellarcanesubtlety", 100, -80)
-- CreateSpellButton("buttonSpellArcaneFocus", "Interface/icons/spell_holy_devotion", "|cffffffffFocalisation des arcanes|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente les chances de toucher et réduit le coût en mana de vos sorts des Arcanes de 3%.|r", "spellarcanefocus", 205, -75)
-- CreateSpellButton("buttonSpellArcaneStability", "Interface/icons/spell_nature_starfall", "|cffffffffStabilité arcanique|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit de 100% l'interruption causée par les attaques infligeant des dégâts pendant que vous incantez Projectiles des arcanes et Déflagration des arcanes.|r", "spellarcanestability", 315, -75)
-- CreateSpellButton("buttonSpellArcaneFortitude", "Interface/icons/spell_arcane_arcaneresilience", "|cffffffffRobustesse des arcanes|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente votre Armure d'un montant égal à 150% de votre Intelligence.|r", "spellarcanefortitude", 418, -80)
-- CreateSpellButton("buttonSpellMagicAbsorption", "Interface/icons/spell_nature_astralrecalgroup", "|cffffffffAbsorption de magie|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente toutes les résistances d'1 par niveau.\nTous les sorts auxquels vous résistez entièrement restaurent 2% de votre total de mana.\nTemps de recharge d'1 sec.|r", "spellmagicabsorption", 150, -130)
-- CreateSpellButton("buttonSpellArcaneConcentration", "Interface/icons/spell_shadow_manaburn", "|cffffffffConcentration des arcanes|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Vous confère 10% de chances d'entrer dans un état d'Idées claires après avoir infligé des dégâts avec un sort à la cible.\nCet état réduit le coût en mana de votre prochain sort de 100%.|r", "spellarcaneconcentration", 260, -130)
-- CreateSpellButton("buttonSpellMagicAttunement", "Interface/icons/spell_nature_abolishmagic", "|cffffffffHarmonisation de la magie|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 6 mètres la portée de vos sorts des Arcanes et de 50% les effets de vos sorts Amplification de la magie et Atténuation de la magie.|r", "spellmagicattunement", 370, -130)
-- CreateSpellButton("buttonSpellImpact", "Interface/icons/spell_nature_wispsplode", "|cffffffffImpact des sorts|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 6% supplémentaires les dégâts de vos sorts Explosion des arcanes, Déflagration des arcanes, Vague explosive, Trait de feu, Brûlure, Boule de feu, Javelot de glace et Cône de froid.|r", "spellspellimpact", 475, -133)
-- CreateSpellButton("buttonSpellFocusMagic", "Interface/icons/ability_mage_studentofthemind", "|cffffffffEtudiant de la raison|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente votre total d'Esprit de 10%.|r", "spellstudentofthemind", 96, -185)
-- CreateSpellButton("buttonSpellGrimReach", "Interface/icons/spell_arcane_studentofmagic", "|cffffffffFocalisation de la magie|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 3% les chances de coup critique de la cible avec les sorts.\nQuand la cible réussit un coup critique, les chances de coup critique avec les sorts du lanceur sont augmentées de 3% pendant 10 seconds.\nNe peut être lancé sur soi-même.|r", "spellfocusmagic", 205, -185)
-- CreateSpellButton("buttonSpellArcaneShielding", "Interface/icons/spell_shadow_detectlesserinvisibility", "|cffffffffSauvegarde des arcanes|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit de 33% le mana perdu par point de dégâts reçu lorsque Bouclier de mana est actif et augmente de 50% les résistances conférées par Armure du mage.|r", "spellarcaneshielding", 315, -185)
-- CreateSpellButton("buttonSpellImprovedCounterspell", "Interface/icons/spell_frost_iceshock", "|cffffffffContresort amélioré|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Votre Contresort réduit également la cible au silence pendant 4 seconds.|r", "spellimprovedcounterspell", 422, -185)
-- CreateSpellButton("buttonSpellArcaneMeditation", "Interface/icons/spell_shadow_siphonmana", "|cffffffffMéditation des arcanes|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Vous confère 50% de votre vitesse de récupération du mana normale pendant l'incantation.|r", "spellarcanemeditation", 527, -190)
-- CreateSpellButton("buttonSpellTormenttheWeak", "Interface/icons/ability_mage_tormentoftheweak", "|cffffffffTourmenter les faibles|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Vos techniques Eclair de givre, Boule de feu, Eclair de givrefeu, Explosion pyrotechnique, Projectiles des arcanes,\nDéflagration des arcanes et Barrage des arcanes infligent 12% de dégâts supplémentaires aux cibles piégées ou ralenties.|r", "spelltormentheweak", 43, -240)
-- CreateSpellButton("buttonSpellImprovedBlink", "Interface/icons/spell_arcane_blink", "|cffffffffTransfert amélioré|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit le coût en mana de Transfert de 50% et pendant 4 seconds après l'avoir lancé, la probabilité que vous soyez touché par tous les sorts et attaques est réduite de 30%.|r", "spellimprovedblink", 150, -240)
-- CreateSpellButton("buttonSpellPresenceofMind", "Interface/icons/spell_nature_enchantarmor", "|cffffffffPrésence spirituelle|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Lorsque cette technique est activée, votre prochain sort de mage dont le temps d'incantation est inférieur à 10 sec.\ndevient un sort instantané.|r", "spellpresenceofmind", 368, -240)
-- CreateSpellButton("buttonSpellArcaneMind", "Interface/icons/spell_shadow_charm", "|cffffffffEsprit des arcanes|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente votre total d'Intelligence de 15%.|r", "spellarcanemind", 478, -240)
-- CreateSpellButton("buttonSpellPrismaticCloak", "Interface/icons/spell_arcane_prismaticcloak", "|cffffffffCape prismatique|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit tous les dégâts subis de 6% et réduit le temps de disparition de votre sort Invisibilité de 3 sec.|r", "spellprismaticcloak", 98, -293)
-- CreateSpellButton("buttonSpellArcaneInstability", "Interface/icons/spell_shadow_teleport", "|cffffffffInstabilité des arcanes|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 3% les dégâts infligés par vos sorts et vos chances de coup critique.|r", "spellarcaneinstability", 205, -293)
-- CreateSpellButton("buttonSpellArcanePotency", "Interface/icons/spell_arcane_arcanepotency", "|cffffffffToute-puissance des arcanes|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 30% les chances de coup critique de tous les sorts infligeant des dégâts lancés sous l'effet d'Idées claires ou Présence spirituelle.|r", "spellarcanepotency", 315, -293)
-- CreateSpellButton("buttonSpellArcaneEmpowerment", "Interface/icons/spell_nature_starfall", "|cffffffffRenforcement arcanique|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente les dégâts de votre sort Projectiles des arcanes d'un montant égal à 45% de votre puissance des sorts et les dégâts de Déflagration des arcanes de 9% de votre puissance des sorts.\nDe plus, augmente les dégâts de tous les membres du groupe et du raid se trouvant à moins de 100 mètres de 3%.|r", "spellarcaneempowerment", 422, -293)
-- CreateSpellButton("buttonSpellArcanePower", "Interface/icons/spell_nature_lightning", "|cffffffffPouvoir des arcanes|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Lorsqu'il est activé, vos sorts infligent 20% de points de dégâts supplémentaires et ils vous coûtent 20% de points de mana supplémentaires.\nCet effet dure 15 sec.|r", "spellarcanepower", 527, -295)
-- CreateSpellButton("buttonSpellIncantersAbsorption", "Interface/icons/ability_mage_incantersabsorbtion", "|cffffffffAbsorption de l'incantateur|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Lorsque votre Bouclier de mana, Gardien de givre, Gardien de feu ou Barrière de glace absorbe des dégâts, les dégâts infligés par vos sorts sont augmentés de 15% du montant absorbé pendant 10 seconds.|r", "spellincantersabsorption", 43, -350)
-- CreateSpellButton("buttonSpellArcaneFlows", "Interface/icons/ability_mage_potentspirit", "|cffffffffFlux arcaniques|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit le temps de recharge de vos sorts Présence spirituelle, Pouvoir des arcanes et Invisibilité de 30% et le temps de recharge de votre sort Evocation de 2 min.|r", "spellarcaneflows", 150, -350)
-- CreateSpellButton("buttonSpellMindMastery", "Interface/icons/spell_arcane_mindmastery", "|cffffffffMaîtrise mentale|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente la puissance des sorts d'un montant égal à 15% de votre Intelligence totale.|r", "spellmindmastery", 260, -350)
-- CreateSpellButton("buttonSpellSlow", "Interface/icons/spell_nature_slow", "|cffffffffLenteur|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit la vitesse de déplacement de la cible de 60%, augmente le temps entre les attaques à distance de 60% et augmente le temps d'incantation de 30%.\nDure 15 seconds.\nLenteur ne peut affecter qu'une seule cible à la fois.|r", "spellslow", 368, -350)
-- CreateSpellButton("buttonSpellMissileBarrage", "Interface/icons/ability_mage_missilebarrage", "|cffffffffBarrage de projectiles|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Confère à votre Déflagration des arcanes 40% de chances et à vos sorts Barrage des arcanes, Boule de feu, Eclair de givre\net Eclair de givrefeu 20% de chances de réduire la durée de canalisation du prochain sort Projectiles des arcanes de 2.5 sec.\net réduit le coût en mana de 100%.\nDes projectiles sont tirés toutes les 0,5 sec.|r", "spellmissilebarrage", 478, -350)

-- Feu

{
    id = "spellNetherwindPresence",
    name = "buttonSpellNetherwindPresence",
    icon = "Interface/icons/ability_mage_netherwindpresence",
    position = {98, -405},
    handler = "spellnetherwindpresence",
    tooltips = {
        frFR = "|cffffffffPrésence de vent du Néant|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 6% votre hâte des sorts.|r",
        enUS = "|cffffffffNetherwind Presence|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases your spell haste by 6%.|r"
    }
},

{
    id = "spellSpellPower",
    name = "buttonSpellSpellPower",
    icon = "Interface/icons/spell_arcane_arcanetorrent",
    position = {205, -405},
    handler = "spellspellpower",
    tooltips = {
        frFR = "|cffffffffPuissance des sorts|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente les points de dégâts supplémentaires infligés par les coups critiques de tous vos sorts de 50%.|r",
        enUS = "|cffffffffSpell Power|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases the additional damage dealt by critical strikes from all your spells by 50%.|r"
    }
},

{
    id = "spellArcaneBarrage",
    name = "buttonSpellArcaneBarrage",
    icon = "Interface/icons/ability_mage_arcanebarrage",
    position = {315, -405},
    handler = "spellarcanebarrage",
    tooltips = {
        frFR = "|cffffffffBarrage des arcanes|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Lance plusieurs projectiles sur la cible ennemie et lui inflige 401 à 485 points de dégâts des Arcanes.|r",
        enUS = "|cffffffffArcane Barrage|r\n|cffffffffTalent|r |cff7755fdArcane|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Launches several projectiles at the enemy target, dealing 401 to 485 Arcane damage.|r"
    }
},

{
    id = "spellImprovedFireBlast",
    name = "buttonSpellImprovedFireBlast",
    icon = "Interface/icons/spell_fire_fireball",
    position = {422, -405},
    handler = "spellimprovedfireblast",
    tooltips = {
        frFR = "|cffffffffTrait de feu amélioré|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit le temps de recharge de votre sort Trait de feu de 2 secondes.|r",
        enUS = "|cffffffffImproved Fire Blast|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Reduces the cooldown of your Fire Blast spell by 2 seconds.|r"
    }
},

{
    id = "spellIncineration",
    name = "buttonSpellIncineration",
    icon = "Interface/icons/spell_fire_flameshock",
    position = {43, -458},
    handler = "spellincineration",
    tooltips = {
        frFR = "|cffffffffIncinération|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 6% les chances d'infliger un coup critique avec vos sorts Trait de feu, Brûlure, Déflagration des arcanes et Cône de froid.|r",
        enUS = "|cffffffffIncineration|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases the chance to score a critical strike with your Fireball, Fire Blast, Arcane Explosion, and Cone of Cold by 6%.|r"
    }
},
{
    id = "spellImprovedFireball",
    name = "buttonSpellImprovedFireball",
    icon = "Interface/icons/spell_fire_flamebolt",
    position = {150, -458},
    handler = "spellimprovedfireball",
    tooltips = {
        frFR = "|cffffffffBoule de feu améliorée|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit le temps d'incantation de votre sort Boule de feu de 0.5 secondes.|r",
        enUS = "|cffffffffImproved Fireball|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Reduces the casting time of your Fireball spell by 0.5 seconds.|r"
    }
},

{
    id = "spellIgnite",
    name = "buttonSpellIgnite",
    icon = "Interface/icons/spell_fire_incinerate",
    position = {260, -458},
    handler = "spellignite",
    tooltips = {
        frFR = "|cffffffffEnflammer|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Les coups critiques causés par vos sorts de Feu enflamment la cible, ce qui lui inflige un montant de dégâts supplémentaire égal à 40% des dégâts de votre sort en 4 secondes.|r",
        enUS = "|cffffffffIgnite|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Critical strikes caused by your Fire spells ignite the target, dealing additional damage equal to 40% of your spell's damage over 4 seconds.|r"
    }
},

{
    id = "spellBurningDetermination",
    name = "buttonSpellBurningDetermination",
    icon = "Interface/icons/spell_fire_totemofwrath",
    position = {368, -458},
    handler = "spellburningdetermination",
    tooltips = {
        frFR = "|cffffffffDétermination brûlante|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Quand vous êtes interrompu ou réduit au silence, vous avez 100% de chances de devenir insensible au prochain mécanisme d'interruption ou de silence.\nDure 20 secondes.|r",
        enUS = "|cffffffffBurning Determination|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100When interrupted or silenced, you have a 100% chance to become immune to the next interrupt or silence mechanism.\nLasts 20 seconds.|r"
    }
},

{
    id = "spellWorldinFlames",
    name = "buttonSpellWorldinFlames",
    icon = "Interface/icons/ability_mage_worldinflames",
    position = {478, -458},
    handler = "spellworlinflames",
    tooltips = {
        frFR = "|cffffffffMonde en flammes|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 6% vos chances de réaliser un coup critique avec vos sorts Choc de flammes, Explosion pyrotechnique, Vague explosive, Souffle du dragon, Bombe vivante, Blizzard et Explosion des arcanes.|r",
        enUS = "|cffffffffWorld in Flames|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases your chance to score a critical strike by 6% with your Fire Blast, Pyroblast, Firestorm, Dragon's Breath, Living Bomb, Blizzard, and Arcane Explosion.|r"
    }
},

{
    id = "spellFlameThrowing",
    name = "buttonSpellFlameThrowing",
    icon = "Interface/icons/spell_fire_flare",
    position = {98, -510},
    handler = "spellflamethrowing",
    tooltips = {
        frFR = "|cffffffffJet de flammes|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente la portée de tous les sorts de Feu excepté Eclair de givrefeu de 6 mètres.|r",
        enUS = "|cffffffffFlame Throwing|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases the range of all your Fire spells, except for Frostbolt, by 6 yards.|r"
    }
},
{
    id = "spellImpact",
    name = "buttonSpellImpact",
    icon = "Interface/icons/spell_fire_meteorstorm",
    position = {205, -510},
    handler = "spellimpact",
    tooltips = {
        frFR = "|cffffffffImpact|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Confère 10% de chances à vos sorts de dégâts de permettre à votre prochain Trait de feu d'étourdir la cible pendant 2 secondes.|r",
        enUS = "|cffffffffImpact|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Grants a 10% chance for your damage spells to cause your next Fire Blast to stun the target for 2 seconds.|r"
    }
},

{
    id = "spellPyroblast",
    name = "buttonSpellPyroblast",
    icon = "Interface/icons/spell_fire_fireball02",
    position = {315, -510},
    handler = "spellpyroblast",
    tooltips = {
        frFR = "|cffffffffExplosion pyrotechnique|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Lance un immense rocher enflammé qui inflige 163 à 215 points de dégâts de Feu et 60 à 64 points de dégâts de Feu supplémentaires en 12 secondes.|r",
        enUS = "|cffffffffPyroblast|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Launches a massive fireball that deals 163 to 215 Fire damage and 60 to 64 additional Fire damage over 12 seconds.|r"
    }
},

{
    id = "spellBurningSoul",
    name = "buttonSpellBurningSoul",
    icon = "Interface/icons/spell_fire_fire",
    position = {422, -510},
    handler = "spellburningsoul",
    tooltips = {
        frFR = "|cffffffffÂme ardente|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit l'interruption causée par les attaques infligeant des dégâts pendant que vous incantez des sorts de Feu de 70% et réduit la menace générée par vos sorts de Feu de 20%.|r",
        enUS = "|cffffffffBurning Soul|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Reduces interruption caused by damage-dealing attacks while casting Fire spells by 70% and reduces the threat generated by your Fire spells by 20%.|r"
    }
},


-- CreateSpellButton("buttonSpellNetherwindPresence", "Interface/icons/ability_mage_netherwindpresence", "|cffffffffPrésence de vent du Néant|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 6% votre hâte des sorts.|r", "spellnetherwindpresence", 98, -405)
-- CreateSpellButton("buttonSpellSpellPower", "Interface/icons/spell_arcane_arcanetorrent", "|cffffffffPuissance des sorts|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente les points de dégâts supplémentaires infligés par les coups critiques de tous vos sorts de 50%.|r", "spellspellpower", 205, -405)
-- CreateSpellButton("buttonSpellArcaneBarrage", "Interface/icons/ability_mage_arcanebarrage", "|cffffffffBarrage des arcanes|r\n|cffffffffTalent|r |cff7755fdArcanes|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Lance plusieurs projectiles sur la cible ennemie et lui inflige 401 à 485 points de dégâts des Arcanes.|r", "spellarcanebarrage", 315, -405)
-- CreateSpellButton("buttonSpellImprovedFireBlast", "Interface/icons/spell_fire_fireball", "|cffffffffTrait de feu amélioré|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit le temps de recharge de votre sort Trait de feu de 2 secondes.|r", "spellimprovedfireblast", 422, -405)
-- CreateSpellButton("buttonSpellIncineration", "Interface/icons/spell_fire_flameshock", "|cffffffffIncinération|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 6% les chances d'infliger un coup critique avec vos sorts Trait de feu, Brûlure, Déflagration des arcanes et Cône de froid.|r", "spellincineration", 43, -458)
-- CreateSpellButton("buttonSpellImprovedFireball", "Interface/icons/spell_fire_flamebolt", "|cffffffffBoule de feu améliorée|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit le temps d'incantation de votre sort Boule de feu de 0.5 secondes.|r", "spellimprovedfireball", 150, -458)
-- CreateSpellButton("buttonSpellIgnite", "Interface/icons/spell_fire_incinerate", "|cffffffffEnflammer|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Les coups critiques causés par vos sorts de Feu enflamment la cible, ce qui lui inflige un montant de dégâts supplémentaire égal à 40% des dégâts de votre sort en 4 seconds.|r", "spellignite", 260, -458)
-- CreateSpellButton("buttonSpellBurningDetermination", "Interface/icons/spell_fire_totemofwrath", "|cffffffffDétermination brûlante|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Quand vous êtes interrompu ou réduit au silence, vous avez 100% de chances de devenir insensible au prochain mécanisme d'interruption ou de silence.\nDure 20 seconds.|r", "spellburningdetermination", 368, -458)
-- CreateSpellButton("buttonSpellWorldinFlames", "Interface/icons/ability_mage_worldinflames", "|cffffffffMonde en flammes|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 6% vos chances de réaliser un coup critique avec vos sorts Choc de flammes, Explosion pyrotechnique, Vague explosive, Souffle du dragon, Bombe vivante, Blizzard et Explosion des arcanes.|r", "spellworlinflames", 478, -458)
-- CreateSpellButton("buttonSpellFlameThrowing", "Interface/icons/spell_fire_flare", "|cffffffffJet de flammes|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente la portée de tous les sorts de Feu excepté Eclair de givrefeu de 6 mètres.|r", "spellflamethrowing", 98, -510)
-- CreateSpellButton("buttonSpellImpact", "Interface/icons/spell_fire_meteorstorm", "|cffffffffImpact|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Confère 10% de chances à vos sorts de dégâts de permettre à votre prochain Trait de feu d'étourdir la cible pendant 2 seconds.|r", "spellimpact", 205, -510)
-- CreateSpellButton("buttonSpellPyroblast", "Interface/icons/spell_fire_fireball02", "|cffffffffExplosion pyrotechnique|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Lance un immense rocher enflammé qui inflige 163 à 215 points de dégâts de Feu et 60 à 64 points de dégâts de Feu supplémentaires en 12 seconds.|r", "spellpyroblast", 315, -510)
-- CreateSpellButton("buttonSpellBurningSoul", "Interface/icons/spell_fire_fire", "|cffffffffAme ardente|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit l'interruption causée par les attaques infligeant des dégâts pendant que vous incantez des sorts de Feu de 70% et réduit la menace générée par vos sorts de Feu de 20%.|r", "spellburningsoul", 422, -510)

-- Template 2

{
    id = "spellImprovedScorch",
    name = "buttonSpellImprovedScorch",
    icon = "Interface/icons/spell_fire_soulburn",
    position = {663, -75},
    handler = "spellimprovedscorch",
    tooltips = {
        frFR = "|cffffffffBrûlure améliorée|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente vos chances de coup critique avec Brûlure, Boule de feu et Éclair de givrefeu de 3% supplémentaires\net vos sorts de Brûlure infligeant des dégâts ont 100% de chances de rendre votre cible vulnérable aux dégâts de sorts.\nCette vulnérabilité augmente les chances de coup critique avec les sorts contre cette cible de 5% et dure 30 secondes.|r",
        enUS = "|cffffffffImproved Scorch|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases your critical strike chance with Scorch, Fireball, and Frostfire Bolt by an additional 3%. Your Scorch damage spells also have a 100% chance to debuff the target, making them vulnerable to spell damage. This vulnerability increases critical strike chance against the target by 5% and lasts for 30 seconds.|r"
    }
},

{
    id = "spellMoltenShields",
    name = "buttonSpellMoltenShields",
    icon = "Interface/icons/spell_fire_firearmor",
    position = {770, -75},
    handler = "spellmoltenshields",
    tooltips = {
        frFR = "|cffffffffBoucliers de la fournaise|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Confère à vos sorts Gardien de feu et Gardien de givre 30% de chances de renvoyer les sorts tant qu'ils sont actifs.\nDe plus, votre Armure de la fournaise a 100% de chances d'affecter les attaques à distance et les sorts.|r",
        enUS = "|cffffffffMolten Shields|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Gives your Fire Ward and Frost Ward spells a 30% chance to reflect spells while active. Additionally, your Molten Armor has a 100% chance to affect ranged attacks and spells.|r"
    }
},

{
    id = "spellMasterofElements",
    name = "buttonSpellMasterofElements",
    icon = "Interface/icons/spell_fire_masterofelements",
    position = {880, -75},
    handler = "spellmasterofelements",
    tooltips = {
        frFR = "|cffffffffMaître des éléments|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Les coups critiques obtenus avec les sorts vous rendront 30% de leur coût en mana de base.|r",
        enUS = "|cffffffffMaster of Elements|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Critical strikes with your spells will refund 30% of their base mana cost.|r"
    }
},

{
    id = "spellPlayingwithFire",
    name = "buttonSpellPlayingwithFire",
    icon = "Interface/icons/spell_fire_playingwithfire",
    position = {990, -75},
    handler = "spellplayingwithfire",
    tooltips = {
        frFR = "|cffffffffJouer avec le feu|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente tous les dégâts des sorts causés de 3% et tous les dégâts des sorts subis de 3%.|r",
        enUS = "|cffffffffPlaying with Fire|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases all spell damage dealt by 3%, and all spell damage taken by 3%.|r"
    }
},

{
    id = "spellCriticalMass",
    name = "buttonSpellCriticalMass",
    icon = "Interface/icons/spell_nature_wispheal",
    position = {1100, -75},
    handler = "spellcriticalmass",
    tooltips = {
        frFR = "|cffffffffMasse critique|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 6% vos chances d'infliger un coup critique avec vos sorts de Feu.|r",
        enUS = "|cffffffffCritical Mass|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases your chance to score a critical strike with your Fire spells by 6%.|r"
    }
},
{
    id = "spellBlastWave",
    name = "buttonSpellBlastWave",
    icon = "Interface/icons/spell_holy_excorcism_02",
    position = {718, -130},
    handler = "spellblastwave",
    tooltips = {
        frFR = "|cffffffffVague explosive|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Une vague de flammes rayonne autour du lanceur et inflige à tous les ennemis pris dans l'explosion 185 à 223 points de dégâts de Feu,\nen plus de les faire tomber à la renverse et de les hébéter pendant 6 secondes.|r",
        enUS = "|cffffffffBlast Wave|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100A wave of flames radiates from the caster, dealing 185 to 223 Fire damage to all enemies in the blast radius, knocking them down and dazing them for 6 seconds.|r"
    }
},

{
    id = "spellBlazingSpeed",
    name = "buttonSpellBlazingSpeed",
    icon = "Interface/icons/spell_fire_burningspeed",
    position = {825, -130},
    handler = "spellblazingspeed",
    tooltips = {
        frFR = "|cffffffffVitesse flamboyante|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Vous confère 10% de chances, lorsque vous êtes touché par une attaque en mêlée ou à distance, de voir votre vitesse de déplacement augmenter de 50% et de dissiper tous les effets affectant le mouvement.\nCet effet dure 8 secondes.|r",
        enUS = "|cffffffffBlazing Speed|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Gives you a 10% chance, when hit by a melee or ranged attack, to increase your movement speed by 50% and dispel all movement impairing effects. This effect lasts for 8 seconds.|r"
    }
},

{
    id = "spellFirePower",
    name = "buttonSpellFirePower",
    icon = "Interface/icons/spell_fire_immolation",
    position = {935, -130},
    handler = "spellfirepower",
    tooltips = {
        frFR = "|cffffffffPuissance du feu|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 10% les dégâts infligés par vos sorts de Feu.|r",
        enUS = "|cffffffffFire Power|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases the damage of your Fire spells by 10%.|r"
    }
},

{
    id = "spellPyromaniac",
    name = "buttonSpellPyromaniac",
    icon = "Interface/icons/spell_fire_burnout",
    position = {1045, -130},
    handler = "spellyromaniac",
    tooltips = {
        frFR = "|cffffffffPyromane|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente les chances de réussir un coup critique de 3% et permet à 50% de votre régénération de mana de se poursuivre pendant les incantations.|r",
        enUS = "|cffffffffPyromaniac|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases your critical strike chance by 3% and allows 50% of your mana regeneration to continue while casting.|r"
    }
},

{
    id = "spellCombustion",
    name = "buttonSpellCombustion",
    icon = "Interface/icons/spell_fire_sealoffire",
    position = {663, -184},
    handler = "spellcombustion",
    tooltips = {
        frFR = "|cffffffffCombustion|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Lorsqu'il est activé, ce sort augmente votre bonus aux dégâts des coups critiques avec les sorts de dégâts de Feu de 50%,\net chaque fois que vous touchez avec un sort de ce type vous augmentez vos chances de coup critique avec les sorts de dégâts de Feu de 10%.\nCet effet dure jusqu'à ce que vous ayez infligé 3 coups critiques non périodiques avec des sorts de Feu.|r",
        enUS = "|cffffffffCombustion|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100When activated, this spell increases your critical strike damage bonus for Fire damage spells by 50%. Each time you land a hit with a Fire damage spell, your critical strike chance with Fire damage spells is increased by 10%. This effect lasts until you score 3 non-periodic critical strikes with Fire spells.|r"
    }
},
{
    id = "spellMoltenFury",
    name = "buttonSpellMoltenFury",
    icon = "Interface/icons/spell_fire_moltenblood",
    position = {770, -184},
    handler = "spellmoltenfury",
    tooltips = {
        frFR = "|cffffffffFureur de lave|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente les dégâts de tous les sorts contre les cibles disposant de moins de 35% de leurs points de vie de 12%.|r",
        enUS = "|cffffffffMolten Fury|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases the damage of all your spells against targets with less than 35% health by 12%.|r"
    }
},

{
    id = "spellFieryPayback",
    name = "buttonSpellFieryPayback",
    icon = "Interface/icons/ability_mage_fierypayback",
    position = {880, -184},
    handler = "spellfierypayback",
    tooltips = {
        frFR = "|cffffffffRevanche ardente|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Lorsque vous avez moins de 35% de vie, tous les dégâts subis sont réduits de 20%, le temps d'incantation de votre sort Explosion pyrotechnique est réduit de 3.5 sec.\net son temps de recharge est augmenté de 5 sec.\nDe plus, les attaques en mêlée et à distance contre vous ont 10% de chances de faire tomber l'arme en main droite et les armes à distance de l'attaquant.|r",
        enUS = "|cffffffffFiery Payback|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100When below 35% health, all damage taken is reduced by 20%, the casting time of your Pyroblast is reduced by 3.5 sec, and its cooldown is increased by 5 sec.\nAdditionally, melee and ranged attacks against you have a 10% chance to disarm the attacker.|r"
    }
},

{
    id = "spellEmpoweredFire",
    name = "buttonSpellEmpoweredFire",
    icon = "Interface/icons/spell_fire_flamebolt",
    position = {990, -184},
    handler = "spellempoweredfire",
    tooltips = {
        frFR = "|cffffffffFeu surpuissant|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente les dégâts de vos sorts Boule de feu, Eclair de givrefeu et Explosion pyrotechnique d'un montant égal à 15% de votre puissance des sorts.\nDe plus, chaque fois que votre talent Enflammer inflige des dégâts, vous avez 100% de chances de récupérer 2% de votre mana de base.|r",
        enUS = "|cffffffffEmpowered Fire|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases the damage of your Fireball, Frostfire Bolt, and Pyroblast by 15% of your spell power.\nAdditionally, each time your Ignite talent deals damage, you have a 100% chance to recover 2% of your base mana.|r"
    }
},

{
    id = "spellFirestarter",
    name = "buttonSpellFirestarter",
    icon = "Interface/icons/ability_mage_firestarter",
    position = {1100, -184},
    handler = "spellfirestarter",
    tooltips = {
        frFR = "|cffffffffBoute-flammes|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Lorsqu'ils infligent des dégâts, vos sorts Vague explosive et Souffle du dragon ont 100% de chances de rendre l'incantation de votre prochain sort Choc de flammes instantanée et sans coût en mana.\nDure 10 secondes.|r",
        enUS = "|cffffffffFirestarter|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100When dealing damage, your Blast Wave and Dragon's Breath spells have a 100% chance to make your next Flamestrike instant and cost no mana.\nLasts 10 seconds.|r"
    }
},


-- CreateSpellButton("buttonSpellImprovedScorch", "Interface/icons/spell_fire_soulburn", "|cffffffffBrûlure améliorée|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente vos chances de coup critique avec Brûlure, Boule de feu et Eclair de givrefeu de 3% supplémentaires\net vos sorts de Brûlure infligeant des dégâts ont 100% de chances de rendre votre cible vulnérable aux dégâts de sorts.\nCette vulnérabilité augmente les chances de coup critique avec les sorts contre cette cible de 5% et dure 30 seconds.|r", "spellimprovedscorch", 663, -75)
-- CreateSpellButton("buttonSpellMolteShields", "Interface/icons/spell_fire_firearmor", "|cffffffffBoucliers de la fournaise|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Confère à vos sorts Gardien de feu et Gardien de givre 30% de chances de renvoyer les sorts tant qu'ils sont actifs.\nDe plus, votre Armure de la fournaise a 100% de chances d'affecter les attaques à distance et les sorts.|r", "spellmoltenshields", 770, -75)
-- CreateSpellButton("buttonSpellMasterofElements", "Interface/icons/spell_fire_masterofelements", "|cffffffffMaître des éléments|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Les coups critiques obtenus avec les sorts vous rendront 30% de leur coût en mana de base.|r", "spellmasterofelements", 880, -75)
-- CreateSpellButton("buttonSpellPlayingwithFire", "Interface/icons/spell_fire_playingwithfire", "|cffffffffJouer avec le feu|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente tous les dégâts des sorts causés de 3% et tous les dégâts des sorts subis de 3%.|r", "spellplayingwithfire", 990, -75)
-- CreateSpellButton("buttonSpellCriticalMass", "Interface/icons/spell_nature_wispheal", "|cffffffffMasse critique|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 6% vos chances d'infliger un coup critique avec vos sorts de Feu.|r", "spellcriticalmass", 1100, -75)
-- CreateSpellButton("buttonSpellBlastWave", "Interface/icons/spell_holy_excorcism_02", "|cffffffffVague explosive|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Une vague de flammes rayonne autour du lanceur et inflige à tous les ennemis pris dans l'explosion 185 à 223 points de dégâts de Feu,\nen plus de les faire tomber à la renverse et de les hébéter pendant 6 seconds.|r", "spellblastwave", 718, -130)
-- CreateSpellButton("buttonSpellBlazingSpeed", "Interface/icons/spell_fire_burningspeed", "|cffffffffVitesse flamboyante|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Vous confère 10% de chances, lorsque vous êtes touché par une attaque en mêlée ou à distance, de voir votre vitesse de déplacement augmenter de 50% et de dissiper tous les effets affectant le mouvement.\nCet effet dure 8 seconds.|r", "spellblazingspeed", 825, -130)
-- CreateSpellButton("buttonSpellFirePower", "Interface/icons/spell_fire_immolation", "|cffffffffPuissance du feu|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 10% les dégâts infligés par vos sorts de Feu.|r", "spellfirepower", 935, -130)
-- CreateSpellButton("buttonSpellPyromaniac", "Interface/icons/spell_fire_burnout", "|cffffffffPyromane|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente les chances de réussir un coup critique de 3% et permet à 50% de votre régénération de mana de se poursuivre pendant les incantations.|r", "spellyromaniac", 1045, -130)
-- CreateSpellButton("buttonSpellCombustion", "Interface/icons/spell_fire_sealoffire", "|cffffffffCombustion|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Lorsqu'il est activé, ce sort augmente votre bonus aux dégâts des coups critiques avec les sorts de dégâts de Feu de 50%,\net chaque fois que vous touchez avec un sort de ce type vous augmentez vos chances de coup critique avec les sorts de dégâts de Feu de 10%.\nCet effet dure jusqu'à ce que vous ayez infligé 3 coups critiques non périodiques avec des sorts de Feu.|r", "spellcombustion", 663, -184)
-- CreateSpellButton("buttonSpellMoltenFury", "Interface/icons/spell_fire_moltenblood", "|cffffffffFureur de lave|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente les dégâts de tous les sorts contre les cibles disposant de moins de 35% de leurs points de vie de 12%.|r", "spellmoltenfury", 770, -184)
-- CreateSpellButton("buttonSpellFieryPayback", "Interface/icons/ability_mage_fierypayback", "|cffffffffRevanche ardente|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Lorsque vous avez moins de 35% de vie, tous les dégâts subis sont réduits de 20%, le temps d'incantation de votre sort Explosion pyrotechnique est réduit de 3.5 sec.\net son temps de recharge est augmenté de 5 sec.\nDe plus, les attaques en mêlée et à distance contre vous ont 10% de chances de faire tomber l'arme en main droite et les armes à distance de l'attaquant.|r", "spellfierypayback", 880, -184)
-- CreateSpellButton("buttonSpellEmpoweredFire", "Interface/icons/spell_fire_flamebolt", "|cffffffffFeu surpuissant|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente les dégâts de vos sorts Boule de feu, Eclair de givrefeu et Explosion pyrotechnique d'un montant égal à 15% de votre puissance des sorts.\nDe plus, chaque fois que votre talent Enflammer inflige des dégâts, vous avez 100% de chances de récupérer 2% de votre mana de base.|r", "spellempoweredfire", 990, -184)
-- CreateSpellButton("buttonSpellFirestarter", "Interface/icons/ability_mage_firestarter", "|cffffffffBoute-flammes|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Lorsqu'ils infligent des dégâts, vos sorts Vague explosive et Souffle du dragon ont 100% de chances de rendre l'incantation de votre prochain sort Choc de flammes instantanée et sans coût en mana.\nDure 10 seconds.", "spellfirestarter", 1100, -184)


-- Givre

{
    id = "spellDragonsBreath",
    name = "buttonSpellDragonsBreath",
    icon = "Interface/icons/inv_misc_head_dragon_01",
    position = {718, -240},
    handler = "spelldragonsbreath",
    tooltips = {
        frFR = "|cffffffffSouffle du dragon|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Les cibles qui se trouvent dans une zone en forme de cône en face du lanceur de sorts subissent 420 à 487 points de dégâts de Feu et sont désorientées pendant 5 secondes.\nToute attaque directe qui inflige des dégâts réveille la cible.\nInterrompt l'attaque lors de son utilisation.|r",
        enUS = "|cffffffffDragon's Breath|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100The targets in a cone in front of the caster take 420 to 487 Fire damage and are disoriented for 5 seconds.\nAny direct attack dealing damage wakes up the target.\nInterrupts casting when used.|r"
    }
},

{
    id = "spellHotStreak",
    name = "buttonSpellHotStreak",
    icon = "Interface/icons/ability_mage_hotstreak",
    position = {825, -240},
    handler = "spellhotstreak",
    tooltips = {
        frFR = "|cffffffffChaleur continue|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Chaque fois que vous obtenez 2 coups critiques non périodiques de suite avec Boule de feu, Trait de feu, Brûlure, Bombe vivante ou Eclair de givrefeu,\nvous avez 100% de chances que votre prochain sort Explosion pyrotechnique lancé dans les 10 secondes soit instantané.|r",
        enUS = "|cffffffffHot Streak|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Each time you score 2 consecutive non-periodic critical hits with Fireball, Fire Blast, Scorch, Living Bomb, or Frostfire Bolt,\nyou have a 100% chance to make your next Pyroblast spell cast within 10 seconds instant.|r"
    }
},

{
    id = "spellBurnout",
    name = "buttonSpellBurnout",
    icon = "Interface/icons/ability_mage_burnout",
    position = {935, -240},
    handler = "spellburnout",
    tooltips = {
        frFR = "|cffffffffArdeur épuisante|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 50% votre bonus de dégâts des critiques réussis avec tous les sorts, mais vos critiques non périodiques avec les sorts coûtent 5% du coût du sort en plus.|r",
        enUS = "|cffffffffBurnout|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases your critical damage bonus with all spells by 50%, but your non-periodic critical hits with spells cost 5% more mana.|r"
    }
},

{
    id = "spellLivingBomb",
    name = "buttonSpellLivingBomb",
    icon = "Interface/icons/ability_mage_livingbomb",
    position = {1045, -240},
    handler = "spelllivingbomb",
    tooltips = {
        frFR = "|cffffffffBombe vivante|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100La cible devient une bombe vivante qui inflige 672 à 676 points de dégâts de Feu en 12 secondes.\nAu bout de 12 sec. ou quand le sort est dissipé, la cible explose en infligeant 336 à 337 points de dégâts de Feu à tous les ennemis se trouvant à moins de 10 mètres.|r",
        enUS = "|cffffffffLiving Bomb|r\n|cffffffffTalent|r |cffff8000Fire|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100The target becomes a living bomb, dealing 672 to 676 Fire damage over 12 seconds.\nAfter 12 seconds or when dispelled, the target explodes, dealing 336 to 337 Fire damage to all enemies within 10 yards.|r"
    }
},

{
    id = "spellFrostbite",
    name = "buttonSpellFrostbite",
    icon = "Interface/icons/spell_frost_frostarmor",
    position = {663, -293},
    handler = "spellfrostbite",
    tooltips = {
        frFR = "|cffffffffMorsure de givre|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Donne à vos effets d'engourdissement 15% de chances de geler la cible pendant 5 secondes.|r",
        enUS = "|cffffffffFrostbite|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Gives your freezing effects a 15% chance to freeze the target for 5 seconds.|r"
    }
},
{
    id = "spellImprovedFrostbolt",
    name = "buttonSpellImprovedFrostbolt",
    icon = "Interface/icons/spell_frost_frostbolt02",
    position = {770, -293},
    handler = "spellimprovedfrostbolt",
    tooltips = {
        frFR = "|cffffffffEclair de givre amélioré|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit le temps d'incantation de votre sort Eclair de givre de 0.5 sec.|r",
        enUS = "|cffffffffImproved Frostbolt|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Reduces the cast time of your Frostbolt spell by 0.5 sec.|r"
    }
},

{
    id = "spellIceFloes",
    name = "buttonSpellIceFloes",
    icon = "Interface/icons/spell_frost_icefloes",
    position = {990, -293},
    handler = "spellicefloes",
    tooltips = {
        frFR = "|cffffffffIceberg|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit de 20% le temps de recharge de vos sorts Nova de givre, Cône de froid, Bloc de glace et Veines glaciales.|r",
        enUS = "|cffffffffIce Floes|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Reduces the cooldown of your Frost Nova, Cone of Cold, Ice Block, and Ice Veins by 20%.|r"
    }
},

{
    id = "spellIceShards",
    name = "buttonSpellIceShards",
    icon = "Interface/icons/spell_frost_iceshard",
    position = {1100, -293},
    handler = "spelliceshards",
    tooltips = {
        frFR = "|cffffffffEclats de glace|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 100% les points de dégâts supplémentaires infligés par les coups critiques de vos sorts de Givre.|r",
        enUS = "|cffffffffIce Shards|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases the bonus damage dealt by critical strikes from your Frost spells by 100%.|r"
    }
},

{
    id = "spellFrostWarding",
    name = "buttonSpellFrostWarding",
    icon = "Interface/icons/spell_frost_frostward",
    position = {718, -348},
    handler = "spellfrostwarding",
    tooltips = {
        frFR = "|cffffffffProtection contre le Givre|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 50% l'armure et les résistances octroyées par vos sorts Armure de givre et Armure de glace.\nDe plus, donne à vos sorts Gardien de givre et Gardien de feu 30% de chances d'absorber les dégâts des sorts et de rendre un montant de mana égal aux dégâts absorbés.|r",
        enUS = "|cffffffffFrost Warding|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases the armor and resistance provided by your Frost Armor and Ice Armor spells by 50%. Additionally, gives your Frost Ward and Fire Ward spells a 30% chance to absorb spell damage and return an amount of mana equal to the absorbed damage.|r"
    }
},

{
    id = "spellPrecision",
    name = "buttonSpellPrecision",
    icon = "Interface/icons/spell_ice_magicdamage",
    position = {825, -348},
    handler = "spellprecision",
    tooltips = {
        frFR = "|cffffffffPrécision|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit le coût en mana et augmente vos chances de toucher avec les sorts de 3%.|r",
        enUS = "|cffffffffPrecision|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Reduces the mana cost and increases your spell hit chance by 3%.|r"
    }
},
{
    id = "spellPermafrost",
    name = "buttonSpellPermafrost",
    icon = "Interface/icons/spell_frost_wisp",
    position = {935, -348},
    handler = "spellpermafrost",
    tooltips = {
        frFR = "|cffffffffGel prolongé|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente la durée de vos effets d'engourdissement de 3 secondes, réduit la vitesse de la cible de 10% supplémentaires et réduit les soins qu'elle reçoit de 20%.|r",
        enUS = "|cffffffffPermafrost|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases the duration of your freezing effects by 3 seconds, reduces the target's movement speed by an additional 10%, and reduces the healing they receive by 20%.|r"
    }
},

{
    id = "spellPiercingIce",
    name = "buttonSpellPiercingIce",
    icon = "Interface/icons/spell_frost_frostbolt",
    position = {1045, -348},
    handler = "spellpiercingice",
    tooltips = {
        frFR = "|cffffffffGlace perçante|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente les points de dégâts infligés par vos sorts de Givre de 6%.|r",
        enUS = "|cffffffffPiercing Ice|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases the damage dealt by your Frost spells by 6%.|r"
    }
},

{
    id = "spellIcyVeins",
    name = "buttonSpellIcyVeins",
    icon = "Interface/icons/spell_frost_coldhearted",
    position = {663, -402},
    handler = "spellicyveins",
    tooltips = {
        frFR = "|cffffffffVeines glaciales|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Accélère vos lancers de sorts en augmentant la vitesse d'incantation des sorts de 20% et réduit de 100% les interruptions causées par les attaques infligeant des dégâts pendant les incantations.\nDure 20 seconds.|r",
        enUS = "|cffffffffIcy Veins|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases your spell casting speed by 20% and prevents all spell casting interruptions caused by damage during casting.\nLasts 20 seconds.|r"
    }
},

{
    id = "spellImprovedBlizzard",
    name = "buttonSpellImprovedBlizzard",
    icon = "Interface/icons/spell_frost_icestorm",
    position = {770, -402},
    handler = "spellimprovedblizzard",
    tooltips = {
        frFR = "|cffffffffBlizzard amélioré|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Ajoute un effet d'engourdissement à votre sort Blizzard.\nIl réduit la vitesse de déplacement de la cible de 70%.\nDure 4.5 seconds.|r",
        enUS = "|cffffffffImproved Blizzard|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Adds a freezing effect to your Blizzard spell.\nReduces the target's movement speed by 70%.\nLasts for 4.5 seconds.|r"
    }
},

{
    id = "spellArcticReach",
    name = "buttonSpellArcticReach",
    icon = "Interface/icons/spell_shadow_darkritual",
    position = {880, -402},
    handler = "spellarcticreach",
    tooltips = {
        frFR = "|cffffffffAllonge arctique|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente la portée de vos sorts Eclair de givre, Javelot de glace, Congélation et Blizzard et les rayons d'effet de vos sorts Nova de givre et Cône de froid de 20%.|r",
        enUS = "|cffffffffArctic Reach|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases the range of your Frostbolt, Ice Lance, Frost Nova, and Blizzard spells, as well as the radius of your Frost Nova and Cone of Cold effects by 20%.|r"
    }
},
{
    id = "spellFrostChanneling",
    name = "buttonSpellFrostChanneling",
    icon = "Interface/icons/spell_frost_stun",
    position = {990, -402},
    handler = "spellfrostchanneling",
    tooltips = {
        frFR = "|cffffffffCanalisation du givre|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit de 10% le coût en mana de tous vos sorts et réduit de 10% la menace que génèrent vos sorts de Givre.|r",
        enUS = "|cffffffffFrost Channeling|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Reduces the mana cost of all your spells by 10% and reduces the threat generated by your Frost spells by 10%.|r"
    }
},

{
    id = "spellShatter",
    name = "buttonSpellShatter",
    icon = "Interface/icons/spell_frost_frostshock",
    position = {1100, -402},
    handler = "spellshatter",
    tooltips = {
        frFR = "|cffffffffFracasser|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 50% vos chances d'infliger un coup critique avec tous les sorts lorsque vous attaquez des cibles gelées.|r",
        enUS = "|cffffffffShatter|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases your chance to deal a critical strike with all spells by 50% when attacking frozen targets.|r"
    }
},

{
    id = "spellColdSnap",
    name = "buttonSpellColdSnap",
    icon = "Interface/icons/spell_frost_wizardmark",
    position = {718, -456},
    handler = "spellcoldsnap",
    tooltips = {
        frFR = "|cffffffffMorsure du froid|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Lorsqu'il est activé, ce sort met fin à tous les temps de recharge des sorts de Givre que vous avez lancés récemment.|r",
        enUS = "|cffffffffCold Snap|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100When activated, this spell resets the cooldowns of all Frost spells you have recently cast.|r"
    }
},

{
    id = "spellImprovedConeofCold",
    name = "buttonSpellImprovedConeofCold",
    icon = "Interface/icons/spell_frost_glacier",
    position = {825, -456},
    handler = "spellimprovedconeofcold",
    tooltips = {
        frFR = "|cffffffffCône de froid amélioré|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 35% les points de dégâts infligés par votre sort Cône de froid.|r",
        enUS = "|cffffffffImproved Cone of Cold|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases the damage dealt by your Cone of Cold spell by 35%.|r"
    }
},

{
    id = "spellFrozenCore",
    name = "buttonSpellFrozenCore",
    icon = "Interface/icons/spell_frost_frozencore",
    position = {935, -456},
    handler = "spellfrozencore",
    tooltips = {
        frFR = "|cffffffffCoeur de gel|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit les dégâts que vous infligent tous les sorts de 6%.|r",
        enUS = "|cffffffffFrozen Core|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Reduces the damage you take from all spells by 6%.|r"
    }
},
{
    id = "spellColdAsIce",
    name = "buttonSpellColdAsIce",
    icon = "Interface/icons/ability_mage_coldasice",
    position = {1045, -456},
    handler = "spellcoldasice",
    tooltips = {
        frFR = "|cffffffffFroid comme la glace|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit de 20% le temps de recharge de vos sorts Morsure du froid, Barrière de glace et Invocation d'un élémentaire d'eau.|r",
        enUS = "|cffffffffCold as Ice|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Reduces the cooldown of your Cold Snap, Ice Barrier, and Summon Water Elemental by 20%.|r"
    }
},

{
    id = "spellWintersChill",
    name = "buttonSpellWintersChill",
    icon = "Interface/icons/spell_frost_chillingblast",
    position = {663, -510},
    handler = "spellwinterschill",
    tooltips = {
        frFR = "|cffffffffFroid hivernal|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 3% vos chances de réussir un coup critique avec Eclair de givre\net vos sorts de Givre infligeant des dégâts ont 100% de chances de déclencher l’effet de Froid hivernal,\nqui augmente les chances de critique des sorts de 1% pendant 15 seconds.\nCumulable jusqu’à 5 fois.|r",
        enUS = "|cffffffffWinter's Chill|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases your chance to critically strike with Frostbolt by 3%, and your Frost damage spells have a 100% chance to trigger Winter's Chill,\nwhich increases your spell critical strike chance by 1% for 15 seconds.\nCan stack up to 5 times.|r"
    }
},

{
    id = "spellShatteredBarrier",
    name = "buttonSpellShatteredBarrier",
    icon = "Interface/icons/ability_mage_shattershield",
    position = {770, -510},
    handler = "spellshatteredbarrier",
    tooltips = {
        frFR = "|cffffffffBarrière brisée|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Confère à votre sort Barrière de glace 100% de chances de geler tous les ennemis se trouvant à moins de 10 mètres pendant 8 seconds quand la barrière est détruite.|r",
        enUS = "|cffffffffShattered Barrier|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Causes your Ice Barrier spell to have a 100% chance to freeze all enemies within 10 yards for 8 seconds when the barrier is destroyed.|r"
    }
},

{
    id = "spellIceBarrier",
    name = "buttonSpellIceBarrier",
    icon = "Interface/icons/spell_ice_lament",
    position = {880, -510},
    handler = "spellicebarrier",
    tooltips = {
        frFR = "|cffffffffBarrière de glace|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Vous protège instantanément en absorbant 454 points de dégâts.\nDure 1 min.\n Tant que le bouclier tient, l'incantation de sorts n'est pas retardée par les dégâts.|r",
        enUS = "|cffffffffIce Barrier|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Instantly protects you by absorbing 454 damage.\nLasts for 1 minute.\nAs long as the shield holds, spellcasting is not delayed by damage.|r"
    }
},

{
    id = "spellArcticWinds",
    name = "buttonSpellArcticWinds",
    icon = "Interface/icons/spell_frost_arcticwinds",
    position = {990, -510},
    handler = "spellarcticwinds",
    tooltips = {
        frFR = "|cffffffffVents arctiques|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente tous les dégâts de Givre que vous causez de 5% et réduit la probabilité que les attaques en mêlée et à distance vous touchent de 5%.|r",
        enUS = "|cffffffffArctic Winds|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases all Frost damage you deal by 5% and reduces the chance for melee and ranged attacks to hit you by 5%.|r"
    }
},
{
    id = "spellEmpoweredFrostbolt",
    name = "buttonSpellEmpoweredFrostbolt",
    icon = "Interface/icons/spell_frost_frostbolt02",
    position = {1100, -510},
    handler = "spellempoweredfrostboltt",
    tooltips = {
        frFR = "|cffffffffEclair de givre surpuissant|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente les dégâts de votre sort Eclair de givre d'un montant égal à 10% de votre puissance des sorts et réduit son temps d'incantation de 0.2 sec.|r",
        enUS = "|cffffffffEmpowered Frostbolt|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases the damage of your Frostbolt by 10% of your spell power and reduces its casting time by 0.2 seconds.|r"
    }
},

{
    id = "spellFingersOfFrost",
    name = "buttonSpellFingersOfFrost",
    icon = "Interface/icons/ability_mage_wintersgrasp",
    position = {880, -293},
    handler = "spellfingersoffrost",
    tooltips = {
        frFR = "|cffffffffDoigts de givre|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Donne à vos effets d'engourdissement 15% de chances de déclencher l’effet Doigts de givre, qui permet à vos 2 prochains sorts d'agir comme si la cible était Gelée.\nDure 15 sec.|r",
        enUS = "|cffffffffFingers of Frost|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Gives your Frost effects a 15% chance to trigger Fingers of Frost, making your next 2 spells act as if the target were Frozen.\nLasts 15 sec.|r"
    }
},

{
    id = "spellBrainFreeze",
    name = "buttonSpellBrainFreeze",
    icon = "Interface/icons/ability_mage_brainfreeze",
    position = {609, -564},
    handler = "spellbrainfreeze",
    tooltips = {
        frFR = "|cffffffffGel mental|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Vos sorts de Givre infligeant des dégâts et pouvant transir ont 15% de chances de supprimer le temps d'incantation et le coût en mana de votre prochain sort Boule de feu ou Eclair de givrefeu.|r",
        enUS = "|cffffffffBrain Freeze|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Your Frost damage-dealing spells that can chill have a 15% chance to remove the casting time and mana cost of your next Fireball or Frostfire Bolt spell.|r"
    }
},

{
    id = "spellSummonWaterElemental",
    name = "buttonSpellSummonWaterElemental",
    icon = "Interface/icons/spell_frost_summonwaterelemental_2",
    position = {716, -564},
    handler = "spellsummonwaterelemental",
    tooltips = {
        frFR = "|cffffffffInvocation d'un élémentaire d'eau|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Invoque un élémentaire d'eau qui se bat pour le lanceur de sorts pendant 1 min.|r",
        enUS = "|cffffffffSummon Water Elemental|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Summons a Water Elemental to fight for the caster for 1 minute.|r"
    }
},

{
    id = "spellEnduringWinter",
    name = "buttonSpellEnduringWinter",
    icon = "Interface/icons/spell_frost_summonwaterelemental_2",
    position = {824, -564},
    handler = "spellenduringwinter",
    tooltips = {
        frFR = "|cffffffffHiver persistant|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente la durée de votre sort Invocation d'un élémentaire d'eau de 15 sec.\net votre sort Eclair de givre a 100% de chances de conférer l'effet de Requinquage à un maximum de 10 membres du groupe ou raid\navec une régénération de mana égale à 1% de leur maximum de mana toutes les 5 secondes pendant 15 sec.\nCet effet ne peut se produire plus d'une fois toutes les 6 sec.|r",
        enUS = "|cffffffffEnduring Winter|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases the duration of your Summon Water Elemental by 15 sec.\nand your Frostbolt has a 100% chance to grant Rejuvenation to up to 10 group or raid members\nwith mana regeneration equal to 1% of their maximum mana every 5 seconds for 15 sec.\nThis effect cannot occur more than once every 6 sec.|r"
    }
},
{
    id = "spellChilledtotheBone",
    name = "buttonSpellChilledtotheBone",
    icon = "Interface/icons/ability_mage_chilledtothebone",
    position = {934, -564},
    handler = "spellchilledtothebone",
    tooltips = {
        frFR = "|cffffffffTransi jusqu'aux os|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente les points de dégâts infligés par vos sorts Eclair de givre, Eclair de givrefeu et Javelot de glace de 5% et réduit la vitesse de déplacement de toutes les cibles transies de 10% supplémentaires.|r",
        enUS = "|cffffffffChilled to the Bone|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Increases the damage of your Frostbolt, Frostfire Bolt, and Ice Lance by 5%, and reduces the movement speed of all Chilled targets by an additional 10%.|r"
    }
},

{
    id = "spellDeepFreeze",
    name = "buttonSpellDeepFreeze",
    icon = "Interface/icons/ability_mage_deepfreeze",
    position = {1045, -564},
    handler = "spelldeepfreeze",
    tooltips = {
        frFR = "|cffffffffCongélation|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Etourdit la cible pendant 5 secondes. Utilisable uniquement sur les cibles gelées.\nInflige de 3138 à 3440 points de dégâts aux cibles insensibles de manière permanente aux étourdissements.|r",
        enUS = "|cffffffffDeep Freeze|r\n|cffffffffTalent|r |cff2492ffFrost|r\n|cffffffffRequires|r |cff40c7ebMage|r\n|cffffd100Stuns the target for 5 seconds. Usable only on Frozen targets.\nDeals 3138 to 3440 damage to targets permanently immune to stuns.|r"
		}
	}
}

-- CreateSpellButton("buttonSpellDragonsBreath", "Interface/icons/inv_misc_head_dragon_01", "|cffffffffSouffle du dragon|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Les cibles qui se trouvent dans une zone en forme de cône en face du lanceur de sorts subissent 420 à 487 points de dégâts de Feu et sont désorientées pendant 5 seconds.\nToute attaque directe qui inflige des dégâts réveille la cible.\nInterrompt l'attaque lors de son utilisation.|r", "spelldragonsbreath", 718, -240)
-- CreateSpellButton("buttonSpellHotStreak", "Interface/icons/ability_mage_hotstreak", "|cffffffffChaleur continue|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Chaque fois que vous obtenez 2 coups critiques non périodiques de suite avec Boule de feu, Trait de feu, Brûlure, Bombe vivante ou Eclair de givrefeu,\nvous avez 100% de chances que votre prochain sort Explosion pyrotechnique lancé dans les 10 seconds soit instantané.|r", "spellhotstreak", 825, -240)
-- CreateSpellButton("buttonSpellBurnout", "Interface/icons/ability_mage_burnout", "|cffffffffArdeur épuisante|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 50% votre bonus de dégâts des critiques réussis avec tous les sorts, mais vos critiques non périodiques avec les sorts coûtent 5% du coût du sort en plus.|r", "spellburnout", 935, -240)
-- CreateSpellButton("buttonSpellLivingBomb", "Interface/icons/ability_mage_livingbomb", "|cffffffffBombe vivante|r\n|cffffffffTalent|r |cffff8000Feu|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100La cible devient une bombe vivante qui inflige 672 à 676 points de dégâts de Feu en 12 seconds.\nAu bout de 12 sec. ou quand le sort est dissipé, la cible explose en infligeant 336 à 337 points de dégâts de Feu à tous les ennemis se trouvant à moins de 10 mètres.", "spelllivingbomb", 1045, -240)
-- CreateSpellButton("buttonSpellFrostbite", "Interface/icons/spell_frost_frostarmor", "|cffffffffMorsure de givre|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Donne à vos effets d'engourdissement 15% de chances de geler la cible pendant 5 seconds.|r", "spellfrostbite", 663, -293)
-- CreateSpellButton("buttonSpellImprovedFrostbolt", "Interface/icons/spell_frost_frostbolt02", "|cffffffffEclair de givre amélioré|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit le temps d'incantation de votre sort Eclair de givre de 0.5 sec.|r", "spellimprovedfrostbolt", 770, -293)
-- CreateSpellButton("buttonSpellIceFloes", "Interface/icons/spell_frost_icefloes", "|cffffffffIceberg|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit de 20% le temps de recharge de vos sorts Nova de givre, Cône de froid, Bloc de glace et Veines glaciales.|r", "spellicefloes", 990, -293)
-- CreateSpellButton("buttonSpellIceShards", "Interface/icons/spell_frost_iceshard", "|cffffffffEclats de glace|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 100% les points de dégâts supplémentaires infligés par les coups critiques de vos sorts de Givre.|r", "spelliceshards", 1100, -293)
-- CreateSpellButton("buttonSpellFrostWarding", "Interface/icons/spell_frost_frostward", "|cffffffffProtection contre le Givre|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 50% l'armure et les résistances octroyées par vos sorts Armure de givre et Armure de glace.\nDe plus, donne à vos sorts Gardien de givre et Gardien de feu 30% de chances d'absorber les dégâts des sorts et de rendre un montant de mana égal aux dégâts absorbés.|r", "spellfrostwarding", 718, -348)
-- CreateSpellButton("buttonSpellPrecision", "Interface/icons/spell_ice_magicdamage", "|cffffffffPrécision|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit le coût en mana et augmente vos chances de toucher avec les sorts de 3%.|r", "spellprecision", 825, -348)
-- CreateSpellButton("buttonSpellPermafrost", "Interface/icons/spell_frost_wisp", "|cffffffffGel prolongé|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente la durée de vos effets d'engourdissement de 3 secondes, réduit la vitesse de la cible de 10% supplémentaires et réduit les soins qu'elle reçoit de 20%.|r", "spellpermafrost", 935, -348)
-- CreateSpellButton("buttonSpellPiercingIce", "Interface/icons/spell_frost_frostbolt", "|cffffffffGlace perçante|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente les points de dégâts infligés par vos sorts de Givre de 6%.|r", "spellpiercingice", 1045, -348)
-- CreateSpellButton("buttonSpellIcyVeins", "Interface/icons/spell_frost_coldhearted", "|cffffffffVeines glaciales|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Accélère vos lancers de sorts en augmentant la vitesse d'incantation des sorts de 20% et réduit de 100% les interruptions causées par les attaques infligeant des dégâts pendant les incantations.\nDure 20 seconds.|r", "spellicyveins", 663, -402)
-- CreateSpellButton("buttonSpellImprovedBlizzard", "Interface/icons/spell_frost_icestorm", "|cffffffffBlizzard amélioré|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Ajoute un effet d'engourdissement à votre sort Blizzard.\nIl réduit la vitesse de déplacement de la cible de 70%.\nDure 4.5 seconds.|r", "spellimprovedblizzard", 770, -402)
-- CreateSpellButton("buttonSpellArcticReach", "Interface/icons/spell_shadow_darkritual", "|cffffffffAllonge arctique|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente la portée de vos sorts Eclair de givre, Javelot de glace, Congélation et Blizzard et les rayons d'effet de vos sorts Nova de givre et Cône de froid de 20%.|r", "spellarcticreach", 880, -402)
-- CreateSpellButton("buttonSpellFrostChanneling", "Interface/icons/spell_frost_stun", "|cffffffffCanalisation du givre|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit de 10% le coût en mana de tous vos sorts et réduit de 10% la menace que génèrent vos sorts de Givre.|r", "spellfrostchanneling", 990, -402)
-- CreateSpellButton("buttonSpellShatter", "Interface/icons/spell_frost_frostshock", "|cffffffffFracasser|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 50% vos chances d'infliger un coup critique avec tous les sorts lorsque vous attaquez des cibles gelées.|r", "spellshatter", 1100, -402)
-- CreateSpellButton("buttonSpellColdSnap", "Interface/icons/spell_frost_wizardmark", "|cffffffffMorsure du froid|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Lorsqu'il est activé, ce sort met fin à tous les temps de recharge des sorts de Givre que vous avez lancés récemment.|r", "spellcoldsnap", 718, -456)
-- CreateSpellButton("buttonSpellImprovedConeofCold", "Interface/icons/spell_frost_glacier", "|cffffffffCône de froid amélioré|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 35% les points de dégâts infligés par votre sort Cône de froid.|r", "spellimprovedconeofcold", 825, -456)
-- CreateSpellButton("buttonSpellFrozenCore", "Interface/icons/spell_frost_frozencore", "|cffffffffCoeur de gel|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit les dégâts que vous infligent tous les sorts de 6%.|r", "spellfrozencore", 935, -456)
-- CreateSpellButton("buttonSpellColdasIce", "Interface/icons/ability_mage_coldasice", "|cffffffffFroid comme la glace|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Réduit de 20% le temps de recharge de vos sorts Morsure du froid, Barrière de glace et Invocation d'un élémentaire d'eau.|r", "spellcoldasice", 1045, -456)
-- CreateSpellButton("buttonSpellWintersChill", "Interface/icons/spell_frost_chillingblast", "|cffffffffFroid hivernal|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente de 3% vos chances de réussir un coup critique avec Eclair de givre\net vos sorts de Givre infligeant des dégâts ont 100% de chances de déclencher l’effet de Froid hivernal,\nqui augmente les chances de critique des sorts de 1% pendant 15 seconds.\nCumulable jusqu’à 5 fois.|r", "spellwinterschill", 663, -510)
-- CreateSpellButton("buttonSpellShatteredBarrier", "Interface/icons/ability_mage_shattershield", "|cffffffffBarrière brisée|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Confère à votre sort Barrière de glace 100% de chances de geler tous les ennemis se trouvant à moins de 10 mètres pendant 8 seconds quand la barrière est détruite.|r", "spellshatteredbarrier", 770, -510)
-- CreateSpellButton("buttonSpellIceBarrier", "Interface/icons/spell_ice_lament", "|cffffffffBarrière de glace|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Vous protège instantanément en absorbant 454 points de dégâts.\nDure 1 min.\n Tant que le bouclier tient, l'incantation de sorts n'est pas retardée par les dégâts.|r", "spellicebarrier", 880, -510)
-- CreateSpellButton("buttonSpellArcticWinds", "Interface/icons/spell_frost_arcticwinds", "|cffffffffVents arctiques|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente tous les dégâts de Givre que vous causez de 5% et réduit la probabilité que les attaques en mêlée et à distance vous touchent de 5%.|r", "spellarcticwinds", 990, -510)
-- CreateSpellButton("buttonSpellEmpoweredFrostbolt", "Interface/icons/spell_frost_frostbolt02", "|cffffffffEclair de givre surpuissant|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente les dégâts de votre sort Eclair de givre d'un montant égal à 10% de votre puissance des sorts et réduit son temps d'incantation de 0.2 sec.|r", "spellempoweredfrostboltt", 1100, -510)
-- CreateSpellButton("buttonSpellFingersofFrost", "Interface/icons/ability_mage_wintersgrasp", "|cffffffffDoigts de givre|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Donne à vos effets d'engourdissement 15% de chances de déclencher l’effet Doigts de givre, qui permet à vos 2 prochains sorts d'agir comme si la cible était Gelée.\nDure 15 sec.|r", "spellfingersoffrost", 880, -293)
-- CreateSpellButton("buttonSpellBrainFreeze", "Interface/icons/ability_mage_brainfreeze", "|cffffffffGel mental|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Vos sorts de Givre infligeant des dégâts et pouvant transir ont 15% de chances de supprimer le temps d'incantation et le coût en mana de votre prochain sort Boule de feu ou Eclair de givrefeu.|r", "spellbrainfreeze", 609, -564)
-- CreateSpellButton("buttonSpellSummonWaterElemental", "Interface/icons/spell_frost_summonwaterelemental_2", "|cffffffffInvocation d'un élémentaire d'eau|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Invoque un élémentaire d'eau qui se bat pour le lanceur de sorts pendant 1 min.|r", "spellsummonwaterelemental", 716, -564)
-- CreateSpellButton("buttonSpellEnduringWinter", "Interface/icons/spell_frost_summonwaterelemental_2", "|cffffffffHiver persistant|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente la durée de votre sort Invocation d'un élémentaire d'eau de 15 sec.\net votre sort Eclair de givre a 100% de chances de conférer l'effet de Requinquage à un maximum de 10 membres du groupe ou raid\navec une régénération de mana égale à 1% de leur maximum de mana toutes les 5 secondes pendant 15 sec.\nCet effet ne peut se produire plus d'une fois toutes les 6 sec.|r", "spellenduringwinter", 824, -564)
-- CreateSpellButton("buttonSpellChilledtotheBone", "Interface/icons/ability_mage_chilledtothebone", "|cffffffffTransi jusqu'aux os|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Augmente les points de dégâts infligés par vos sorts Eclair de givre, Eclair de givrefeu et Javelot de glace de 5% et réduit la vitesse de déplacement de toutes les cibles transies de 10% supplémentaires.|r", "spellchilledtothebone", 934, -564)
-- CreateSpellButton("buttonSpellDeepFreeze", "Interface/icons/ability_mage_deepfreeze", "|cffffffffCongélation|r\n|cffffffffTalent|r |cff2492ffGivre|r\n|cffffffffRequiert|r |cff40c7ebMage|r\n|cffffd100Etourdit la cible pendant 5 seconds. Utilisable uniquement sur les cibles gelées.\nInflige de 3138 à 3440 points de dégâts aux cibles insensibles de manière permanente aux étourdissements.|r", "spelldeepfreeze", 1045, -564)

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

-- Créez le bouton Save à l'intérieur de la fenêtre frameTalentMage
local saveButton = CreateFrame("Button", "saveButton", frameTalentMage, "UIPanelButtonTemplate")
saveButton:SetSize(85, 25)
saveButton:SetPoint("BOTTOMRIGHT", buttonTalentMageClose, "BOTTOMLEFT", -185, 5) -- Place le bouton Save à gauche du bouton Close
saveButton:SetText(saveButtonText)

-- Fonction qui prend un screenshot quand le bouton est cliqué
saveButton:SetScript("OnClick", function()
    Screenshot()  -- Prendre un screenshot et l'enregistrer dans le dossier Screenshots du jeu
    print(screenshotMessage)  -- Affiche un message de confirmation en fonction de la locale
end)

-- Affiche l'UI des talents
--frameTalentMage:Show()

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

-- Créez le bouton Reset à l'intérieur de la fenêtre frameTalentMage
local buttonReset = CreateFrame("Button", "buttonReset", frameTalentMage, "UIPanelButtonTemplate")
buttonReset:SetSize(85, 25)
buttonReset:SetPoint("BOTTOMRIGHT", buttonTalentMageClose, "BOTTOMLEFT", -95, 5) -- Place le bouton Reset à gauche du bouton Reload
buttonReset:SetText(buttonResetText)

local function ResetTalents()
    -- Ajoutez ici la logique pour réinitialiser les talents du joueur
    AIO.Handle("TalentMagespell", "ResetTalents")
    resetButtonClicked = true -- Marquez le bouton Réinitialiser comme cliqué
end

buttonReset:SetScript("OnClick", ResetTalents)

-- Créez le bouton Reload à l'intérieur de la fenêtre frameTalentMage
local buttonReload = CreateFrame("Button", "buttonReload", frameTalentMage, "UIPanelButtonTemplate")
buttonReload:SetSize(85, 25)
buttonReload:SetPoint("BOTTOMRIGHT", buttonTalentMageClose, "BOTTOMLEFT", -5, 5) -- Place le bouton Reload à gauche du bouton Close
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
        frameTalentMage:Hide()
        buttonReload:Hide()
        PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
    else
        frameTalentMage:Show()
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
        frFR = "|cffffffffTalents|r |cff40c7eb(Mage)|r\n\nL'éventail des talents disponibles\npour améliorer et spécialiser\nvotre personnage.",
        enUS = "|cffffffffTalents|r |cff40c7eb(Mage)|r\n\nThe range of available talents\nfor enhancing and specializing\nyour character."
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

-- Vérifier si le joueur est un Mage avant de créer le bouton
local playerClass = select(2, UnitClass("player")) -- Obtenir la classe du joueur
if playerClass == "MAGE" then
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
MageHandlers.UpdateTalentCount = function(player, talentsAppris)
    if fontTalentMageFrameText then
        fontTalentMageFrameText:SetText(talentsAppris .. " / " .. MAX_TALENTS)
    end
end

-- Mise à jour des points de talent utilisés avec texte localisé
MageHandlers.UpdateTalentPointsUsed = function(player, pointsUsed, pointsBeforeReset)
    -- Utilisation du texte localisé pour les points avant réinitialisation
    print(string.format(GetLocalizedPointsBeforeResetText(), pointsBeforeReset))
end

-- Affichage des talents restants (items 338404 dans le sac)
MageHandlers.UpdateTalentItemCount = function(player, count)
    if fontTalentPointsRemainingText then
        fontTalentPointsRemainingText:SetText("|cFF40C7EBTalents restants : " .. count .. "|r")
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
        fontTalentPointsRemainingText:SetText("|cFF40C7EBTalents restants : " .. (count or 0) .. "|r")
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
if playerClass == "MAGE" then
    -- Surcharge OnHide pour synchroniser talentsWindowOpen quand Échap est pressé
    local _originalOnHide = frameTalentMage:GetScript("OnHide")
    frameTalentMage:SetScript("OnHide", function(self)
        talentsWindowOpen = false
        if _originalOnHide then _originalOnHide(self) end
    end)
    -- WoW appelle automatiquement Hide() sur les frames listées ici quand Échap est pressé
    tinsert(UISpecialFrames, "frameTalentMage")
end