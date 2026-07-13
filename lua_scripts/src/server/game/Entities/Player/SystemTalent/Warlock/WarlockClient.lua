local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local WarlockHandlers = AIO.AddHandlers("TalentWarlockspell", {})

function WarlockHandlers.ShowTalentWarlock(player)
    frameTalentWarlock:Show()
    -- Redemande au serveur l’état visuel au cas où
    AIO.Handle("TalentWarlockspell", "RequestLearnedTalents")
	-- Redemande le nombre de talents restants
    AIO.Handle("TalentWarlockspell", "GetTalentItemCount")
end

local MAX_TALENTS = 60 -- Définition du nombre maximal de talents que le joueur peut apprendre

local OPEN_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_final_trait_unlocked.ogg"
local CLOSE_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_trait_refund_end.ogg"
local SPELL_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_80_azeritearmor_rotationends_02.ogg"

-- Attribute window
local frameTalentWarlock = CreateFrame("Frame", "frameTalentWarlock", UIParent)
frameTalentWarlock:SetSize(1200, 650)
frameTalentWarlock:SetMovable(true)
frameTalentWarlock:EnableMouse(true)
frameTalentWarlock:RegisterForDrag("LeftButton")
frameTalentWarlock:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, -50) -- Adjust the X and Y coordinates
frameTalentWarlock:SetBackdrop(
{
    -- bgFile = "interface/TalentFrame/talentsclassbackgroundWarlock", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    bgFile = "interface/TalentFrame/Template/Class/Warlock/talentsclassbackgroundwarlock", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedwarlock", --Interface/DialogFrame/UI-DialogBox-Border
    edgeSize = 20,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})

-- Ajoutez la texture de l'icône du Démoniste
local warlockIcon = frameTalentWarlock:CreateTexture("WarlockIcon", "OVERLAY")
warlockIcon:SetTexture("Interface\\TalentFrame\\Template\\Class\\Warlock\\IconeWarlock.blp")
warlockIcon:SetSize(60, 60)
warlockIcon:SetPoint("TOPLEFT", frameTalentWarlock, "TOPLEFT", -10, 10)

-- Template Talent Frame

-- Ajoute une textureone pour l'image BLP
local textureone = frameTalentWarlock:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
textureone:SetTexture("Interface\\TalentFrame\\Template\\Class\\Warlock\\TalentFrameTemplate.blp")
textureone:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
textureone:SetPoint("TOPLEFT", frameTalentWarlock, "TOPLEFT", -170, 140) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentWarlock:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Ajoute une texturetwo pour l'image BLP
local texturetwo = frameTalentWarlock:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
texturetwo:SetTexture("Interface\\TalentFrame\\Template\\Class\\Warlock\\TalentFrameTemplateOriginal.blp")
texturetwo:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
texturetwo:SetPoint("TOPRIGHT", frameTalentWarlock, "TOPRIGHT", 170, 140) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentWarlock:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Drag & Drop
frameTalentWarlock:SetScript("OnDragStart", frameTalentWarlock.StartMoving)
frameTalentWarlock:SetScript("OnHide", frameTalentWarlock.StopMovingOrSizing)
frameTalentWarlock:SetScript("OnDragStop", frameTalentWarlock.StopMovingOrSizing)
frameTalentWarlock:Hide()

-- Nouveau template d'arête
frameTalentWarlock:SetBackdropBorderColor(135, 135, 237) -- Couleur pourpre

-- Close button
local buttonTalentWarlockClose = CreateFrame("Button", "buttonTalentWarlockClose", frameTalentWarlock, "UIPanelCloseButton")
buttonTalentWarlockClose:SetPoint("TOPRIGHT", -12, -12)
buttonTalentWarlockClose:EnableMouse(true)
buttonTalentWarlockClose:SetSize(32, 32)

local function CloseTalentWindow()
    frameTalentWarlock:Hide()
    PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
end

-- Associez la fonction de fermeture au bouton de fermeture
buttonTalentWarlockClose:SetScript("OnClick", CloseTalentWindow)

-- Title bar
local frameTalentWarlockTitleBar = CreateFrame("Frame", "frameTalentWarlockTitleBar", frameTalentWarlock, nil)
frameTalentWarlockTitleBar:SetSize(135, 25)
frameTalentWarlockTitleBar:SetBackdrop(
{
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedwarlock",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentWarlockTitleBar:SetPoint("TOP", 0, 20)

local fontTalentWarlockTitleText = frameTalentWarlockTitleBar:CreateFontString("fontTalentWarlockTitleText")
fontTalentWarlockTitleText:SetFont("Fonts\\FRIZQT__.TTF", 13)
fontTalentWarlockTitleText:SetSize(190, 5)
fontTalentWarlockTitleText:SetPoint("CENTER", 0, 0)
fontTalentWarlockTitleText:SetText("|cffFFC125Talents|r")

-- Détecte la langue du client
local locale = GetLocale() -- Retourne "enUS", "frFR", etc.

-- Table des traductions
local localizedTexts = {
    enUS = "|cffFFC125Warlock|r",
    frFR = "|cffFFC125Démoniste|r",
}

-- Récupère le texte correspondant à la langue actuelle ou par défaut en anglais
local textToDisplay = localizedTexts[locale] or localizedTexts["enUS"]

local fontTalentWarlockFrameText = frameTalentWarlockTitleBar:CreateFontString("fontTalentWarlockFrameText")
fontTalentWarlockFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentWarlockFrameText:SetSize(200, 5)
fontTalentWarlockFrameText:SetPoint("TOPLEFT", frameTalentWarlockTitleBar, "BOTTOMLEFT", -30, -35) -- Adjust the Y offset as needed
fontTalentWarlockFrameText:SetText(textToDisplay)

-- Remplacez votre ligne existante pour la création du texte par celle-ci
local fontTalentWarlockFrameText = frameTalentWarlockTitleBar:CreateFontString("fontTalentWarlockFrameText")
fontTalentWarlockFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentWarlockFrameText:SetSize(200, 5)
fontTalentWarlockFrameText:SetPoint("TOPLEFT", frameTalentWarlockTitleBar, "BOTTOMLEFT", -30, -60) -- Adjust the Y offset as needed
fontTalentWarlockFrameText:SetText("0 / " .. MAX_TALENTS) -- Initialisez le texte avec 0 talents appris

-------------------------------------------------------------
-- Affichage "Talents restants" (item 338404 dans le sac)
-------------------------------------------------------------

local frameTalentPointsRemaining = CreateFrame("Frame", "frameTalentPointsRemaining", frameTalentWarlock, nil)
frameTalentPointsRemaining:SetSize(220, 30)
frameTalentPointsRemaining:SetBackdrop({
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedwarlock",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentPointsRemaining:SetPoint("BOTTOMRIGHT", frameTalentWarlock, "BOTTOMRIGHT", -960, 10)

local fontTalentPointsRemainingText = frameTalentPointsRemaining:CreateFontString("fontTalentPointsRemainingText")
fontTalentPointsRemainingText:SetFont("Fonts\\FRIZQT__.TTF", 14)
fontTalentPointsRemainingText:SetSize(210, 20)
fontTalentPointsRemainingText:SetPoint("CENTER", 0, 0)
fontTalentPointsRemainingText:SetText("|cFF8787EDTalents restants : 0|r")
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
WarlockHandlers.UpdateLearnedTalents = function(player, learnedSpells)
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

    local button = CreateFrame("Button", name, frameTalentWarlock, nil)
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
                AIO.Handle("TalentWarlockspell", talentHandler, 1)
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

-- Affliction

-- Table des sorts
local spells = {
{
    id = "spellImprovedCurseOfAgony",
    name = "buttonSpellImprovedCurseOfAgony",
    icon = "Interface/icons/spell_shadow_curseofsargeras",
    position = {100, -80},
    handler = "spellimprovedcurseofagony",
    tooltips = {
        frFR = "|cffffffffMalédiction d'agonie améliorée|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les dégâts infligés par votre sort Malédiction d'agonie de 10%.|r",
        enUS = "|cffffffffImproved Curse of Agony|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the damage dealt by your Curse of Agony by 10%.|r"
    }
},

{
    id = "spellSuppression",
    name = "buttonSpellSuppression",
    icon = "Interface/icons/spell_shadow_unsummonbuilding",
    position = {205, -75},
    handler = "spellsuppression",
    tooltips = {
        frFR = "|cffffffffSuppression|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 3% vos chances de toucher avec les sorts, et réduit de 6% le coût en mana de vos sorts d'Affliction.|r",
        enUS = "|cffffffffSuppression|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases your chance to hit with spells by 3%, and reduces the mana cost of your Affliction spells by 6%.|r"
    }
},

{
    id = "spellImprovedCorruption",
    name = "buttonSpellImprovedCorruption",
    icon = "Interface/icons/spell_shadow_abominationexplosion",
    position = {315, -75},
    handler = "spellimprovedcorruption",
    tooltips = {
        frFR = "|cffffffffCorruption améliorée|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les dégâts infligés par votre Corruption de 10% et augmente les chances de coup critique de votre Graine de Corruption de 5%.|r",
        enUS = "|cffffffffImproved Corruption|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the damage dealt by your Corruption by 10% and increases the critical strike chance of your Seed of Corruption by 5%.|r"
    }
},

{
    id = "spellImprovedCurseOfWeakness",
    name = "buttonSpellImprovedCurseOfWeakness",
    icon = "Interface/icons/spell_shadow_curseofmannoroth",
    position = {418, -80},
    handler = "spellimprovedcurseofweakness",
    tooltips = {
        frFR = "|cffffffffMalédiction de faiblesse améliorée|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 20% le montant de puissance d'attaque réduit par votre Malédiction de faiblesse.|r",
        enUS = "|cffffffffImproved Curse of Weakness|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the attack power reduction from your Curse of Weakness by 20%.|r"
    }
},

{
    id = "spellImprovedDrainSoul",
    name = "buttonSpellImprovedDrainSoul",
    icon = "Interface/icons/spell_shadow_haunting",
    position = {45, -130},
    handler = "spellimproveddrainsoul",
    tooltips = {
        frFR = "|cffffffffDrain d'âme amélioré|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Vous rend 15% de votre maximum de points de mana si vous tuez la cible pendant que vous drainez son âme.\nDe plus, vos sorts d'Affliction génèrent 20% de menace en moins.|r",
        enUS = "|cffffffffImproved Drain Soul|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Restores 15% of your maximum mana if you kill the target while Drain Soul is active.\nAlso, your Affliction spells generate 20% less threat.|r"
    }
},
{
    id = "spellImprovedLifeTap",
    name = "buttonSpellImprovedLifeTap",
    icon = "Interface/icons/spell_shadow_burningspirit",
    position = {150, -130},
    handler = "spellimprovedlifetap",
    tooltips = {
        frFR = "|cffffffffConnexion améliorée|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 20% le montant de mana octroyé par votre sort Connexion.|r",
        enUS = "|cffffffffImproved Life Tap|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the amount of mana granted by your Life Tap by 20%.|r"
    }
},

{
    id = "spellSoulSiphon",
    name = "buttonSpellSoulSiphon",
    icon = "Interface/icons/spell_shadow_lifedrain02",
    position = {260, -130},
    handler = "spellsoulsiphon",
    tooltips = {
        frFR = "|cffffffffSiphon d'âme|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente le montant de points drainé par vos sorts Drain de vie et Drain d'âme de 6% supplémentaires pour chaque effet d'Affliction sur la cible, jusqu'à un maximum de 18% d'effet supplémentaire.|r",
        enUS = "|cffffffffSoul Siphon|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the amount drained by your Life Tap and Drain Soul by 6% for each Affliction effect on the target, up to a maximum of 18%.|r"
    }
},

{
    id = "spellImprovedFear",
    name = "buttonSpellImprovedFear",
    icon = "Interface/icons/spell_shadow_possession",
    position = {370, -130},
    handler = "spellimprovedfear",
    tooltips = {
        frFR = "|cffffffffPeur améliorée|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Votre sort Peur inflige un Cauchemar à la cible lorsque l'effet de peur prend fin.\nCauchemar réduit la vitesse de déplacement de la cible de 30% pendant 5 secondes.|r",
        enUS = "|cffffffffImproved Fear|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Your Fear spell causes Nightmare on the target when the fear effect ends.\nNightmare reduces the target's movement speed by 30% for 5 seconds.|r"
    }
},

{
    id = "spellFelConcentration",
    name = "buttonSpellFelConcentration",
    icon = "Interface/icons/spell_shadow_fingerofdeath",
    position = {475, -133},
    handler = "spellfelconcentration",
    tooltips = {
        frFR = "|cffffffffConcentration corrompue|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit de 70% l'interruption causée par les attaques infligeant des dégâts pendant que vous incantez Drain de vie, Drain de mana, Drain d'âme, Affliction instable et Hanter.|r",
        enUS = "|cffffffffFel Concentration|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Reduces interruption caused by damage-dealing attacks by 70% while casting Life Tap, Drain Mana, Drain Soul, Unstable Affliction, and Haunt.|r"
    }
},

{
    id = "spellAmplifyCurse",
    name = "buttonSpellAmplifyCurse",
    icon = "Interface/icons/spell_shadow_contagion",
    position = {96, -185},
    handler = "spellamplifycurse",
    tooltips = {
        frFR = "|cffffffffMalédiction amplifiée|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit le temps de recharge global de vos Malédictions de 0.5 sec.|r",
        enUS = "|cffffffffAmplify Curse|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Reduces the global cooldown of your Curses by 0.5 seconds.|r"
    }
},
{
    id = "spellGrimReach",
    name = "buttonSpellGrimReach",
    icon = "Interface/icons/spell_shadow_callofbone",
    position = {205, -185},
    handler = "spellgrimreach",
    tooltips = {
        frFR = "|cffffffffAllonge sinistre|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente la portée de vos sorts d'Affliction de 20%.|r",
        enUS = "|cffffffffGrim Reach|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the range of your Affliction spells by 20%.|r"
    }
},

{
    id = "spellNightfall",
    name = "buttonSpellNightfall",
    icon = "Interface/icons/spell_shadow_twilight",
    position = {315, -185},
    handler = "spellnightfall",
    tooltips = {
        frFR = "|cffffffffCrépuscule|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Confère à vos sorts Corruption et Drain de vie 4% de chances de vous plonger dans un état de Transe de l'ombre après avoir infligé des dégâts à un adversaire.\nCet état réduit le temps d'incantation de votre prochain sort Trait de l'ombre de 100%.|r",
        enUS = "|cffffffffNightfall|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Gives your Corruption and Drain Life spells a 4% chance to enter the Shadow Trance state after dealing damage to an enemy.\nThis state reduces the cast time of your next Shadow Bolt by 100%.|r"
    }
},

{
    id = "spellEmpoweredCorruption",
    name = "buttonSpellEmpoweredCorruption",
    icon = "Interface/icons/spell_shadow_abominationexplosion",
    position = {422, -185},
    handler = "spellempoweredcorruption",
    tooltips = {
        frFR = "|cffffffffCorruption surpuissante|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les dégâts de votre sort Corruption d'un montant égal à 36% de votre puissance des sorts.|r",
        enUS = "|cffffffffEmpowered Corruption|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the damage of your Corruption spell by an amount equal to 36% of your spell power.|r"
    }
},

{
    id = "spellShadowEmbrace",
    name = "buttonSpellShadowEmbrace",
    icon = "Interface/icons/spell_shadow_shadowembrace",
    position = {527, -190},
    handler = "spellshadowembrace",
    tooltips = {
        frFR = "|cffffffffEtreinte de l'ombre|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Vos sorts Trait de l'ombre et Hanter provoquent aussi l'effet Etreinte de l'ombre,\nqui augmente tous les dégâts d'Ombre périodiques que vous infligez à la cible de 5%,\net réduit tous les soins périodiques prodigués à la cible de 10%.\nDure 12 secondes.\nCumulable jusqu'à 3 fois.|r",
        enUS = "|cffffffffShadow Embrace|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Your Shadow Bolt and Haunt spells also apply Shadow Embrace,\nwhich increases all your periodic Shadow damage done to the target by 5%,\nand reduces all periodic healing received by the target by 10%.\nLasts 12 seconds.\nStacks up to 3 times.|r"
    }
},

{
    id = "spellSiphonLife",
    name = "buttonSpellSiphonLife",
    icon = "Interface/icons/spell_shadow_requiem",
    position = {43, -240},
    handler = "spellsiphonlife",
    tooltips = {
        frFR = "|cffffffffSiphon de vie|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Quand vous infligez des dégâts avec votre sort Corruption, vous recevez instantanément un montant de points de vie égal à 40% des dégâts infligés.\nDe plus, les dégâts infligés par les effets sur la durée de votre Corruption, votre Graine de Corruption et votre Affliction instable sont augmentés de 5%.|r",
        enUS = "|cffffffffSiphon Life|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100When you deal damage with Corruption, you instantly receive an amount of health equal to 40% of the damage dealt.\nAdditionally, the damage dealt by your Corruption, Seed of Corruption, and Unstable Affliction over time is increased by 5%.|r"
    }
},
{
    id = "spellCurseofExhaustion",
    name = "buttonSpellCurseofExhaustion",
    icon = "Interface/icons/spell_shadow_grimward",
    position = {150, -240},
    handler = "spellcurseofexhaustion",
    tooltips = {
        frFR = "|cffffffffMalédiction d'épuisement|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit la vitesse de la cible de 30% pendant 12 secondes.\nLa cible ne peut être victime que d'une malédiction par démoniste présent à la fois.|r",
        enUS = "|cffffffffCurse of Exhaustion|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Reduces the target's movement speed by 30% for 12 seconds.\nThe target can only be cursed by one warlock at a time.|r"
    }
},

{
    id = "spellImprovedFelhunter",
    name = "buttonSpellImprovedFelhunter",
    icon = "Interface/icons/spell_shadow_summonfelhunter",
    position = {368, -240},
    handler = "spellimprovedfelhunter",
    tooltips = {
        frFR = "|cffffffffChasseur corrompu amélioré|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Votre chasseur corrompu reçoit 8% de son maximum de mana chaque fois qu'il touche avec sa technique Morsure de l'ombre et le temps de recharge de cette technique est réduit de 4 secondes.\nAugmente également l'effet de l'Intelligence gangrenée de votre chasseur corrompu de 10%.|r",
        enUS = "|cffffffffImproved Felhunter|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Your Felhunter gains 8% of its maximum mana whenever it hits with its Shadow Bite, and the cooldown of this ability is reduced by 4 seconds.\nAlso increases the effect of your Fel Intelligence on your Felhunter by 10%.|r"
    }
},

{
    id = "spellShadowMastery",
    name = "buttonSpellShadowMastery",
    icon = "Interface/icons/spell_shadow_shadetruesight",
    position = {478, -240},
    handler = "spellshadowmastery",
    tooltips = {
        frFR = "|cffffffffMaîtrise de l'ombre|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 15% les points de dégâts infligés ou les points de vie drainés par vos sorts d'Ombre et la technique Morsure de l'ombre de votre chasseur corrompu.|r",
        enUS = "|cffffffffShadow Mastery|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the damage dealt or the health drained by your Shadow spells and the Shadow Bite ability of your Felhunter by 15%.|r"
    }
},

{
    id = "spellEradication",
    name = "buttonSpellEradication",
    icon = "Interface/icons/ability_warlock_eradication",
    position = {98, -293},
    handler = "spelleradication",
    tooltips = {
        frFR = "|cffffffffEradication|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Quand vous infligez des dégâts avec Corruption, vous avez 6% de chances d'augmenter votre vitesse d'incantation des sorts de 20% pendant 10 secondes.|r",
        enUS = "|cffffffffEradication|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100When you deal damage with Corruption, you have a 6% chance to increase your casting speed by 20% for 10 seconds.|r"
    }
},

{
    id = "spellContagion",
    name = "buttonSpellContagion",
    icon = "Interface/icons/spell_shadow_painfulafflictions",
    position = {205, -293},
    handler = "spellcontagion",
    tooltips = {
        frFR = "|cffffffffContagion|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les points de dégâts infligés par Malédiction d'agonie,\nCorruption et Graine de Corruption de 5% et réduit la probabilité que vos sorts d'Affliction et vos effets de dégâts sur la durée soient dissipés de 30% supplémentaires.|r",
        enUS = "|cffffffffContagion|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the damage of your Agony, Corruption, and Seed of Corruption by 5% and reduces the chance for your Affliction spells and damage-over-time effects to be dispelled by an additional 30%.|r"
    }
},
{
    id = "spellDarkPact",
    name = "buttonSpellDarkPact",
    icon = "Interface/icons/spell_shadow_darkritual",
    position = {315, -293},
    handler = "spelldarkpact",
    tooltips = {
        frFR = "|cffffffffPacte noir|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Draine 305 points de mana à votre démon invoqué et vous rend 100% du montant.|r",
        enUS = "|cffffffffDark Pact|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Drains 305 mana from your summoned demon and returns 100% of the amount to you.|r"
    }
},

{
    id = "spellImprovedHowlofTerror",
    name = "buttonSpellImprovedHowlofTerror",
    icon = "Interface/icons/spell_shadow_deathscream",
    position = {422, -293},
    handler = "spellimprovedhowlofterror",
    tooltips = {
        frFR = "|cffffffffHurlement de terreur amélioré|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit le temps d'incantation de votre sort Hurlement de terreur de 1.5 sec.|r",
        enUS = "|cffffffffImproved Howl of Terror|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Reduces the casting time of your Howl of Terror by 1.5 seconds.|r"
    }
},

{
    id = "spellMalediction",
    name = "buttonSpellMalediction",
    icon = "Interface/icons/spell_shadow_curseofachimonde",
    position = {527, -295},
    handler = "spellmalediction",
    tooltips = {
        frFR = "|cffffffffImprécation|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente vos dégâts des sorts de 3% et augmente les chances de coup critique périodique de vos sorts Corruption et Affliction instable de 9%.|r",
        enUS = "|cffffffffMalediction|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases your spell damage by 3% and increases the periodic critical strike chance of your Corruption and Unstable Affliction by 9%.|r"
    }
},

{
    id = "spellDeathsEmbrace",
    name = "buttonSpellDeathsEmbrace",
    icon = "Interface/icons/spell_shadow_deathsembrace",
    position = {43, -350},
    handler = "spelldeathsembrace",
    tooltips = {
        frFR = "|cffffffffCaresse de la mort|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente le montant de points de vie drainés par votre Drain de vie de 30% quand vous disposez de 20% ou moins de vos points de vie,\net augmente les dégâts infligés par vos sorts d'Ombre de 12% quand votre cible dispose de 35% ou moins de ses points de vie.|r",
        enUS = "|cffffffffDeath's Embrace|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the amount of health drained by your Drain Life by 30% when you are at 20% or less of your health,\nand increases the damage dealt by your Shadow spells by 12% when your target is at 35% or less of its health.|r"
    }
},

{
    id = "spellUnstableAffliction",
    name = "buttonSpellUnstableAffliction",
    icon = "Interface/icons/spell_shadow_unstableaffliction_3",
    position = {150, -350},
    handler = "spellunstableaffliction",
    tooltips = {
        frFR = "|cffffffffAffliction instable|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100L’énergie de l’Ombre détruit lentement la cible, infligeant 660 points de dégâts en 15 secondes.\nDe plus, si l'Affliction instable est dissipée, celui qui la dissipe subit 1188 points de dégâts et est réduit au silence pendant 5 secondes.\nUne cible ne peut être victime que d'une seule Affliction instable ou Immolation par démoniste.|r",
        enUS = "|cffffffffUnstable Affliction|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Shadow energy slowly destroys the target, dealing 660 damage over 15 seconds.\nAdditionally, if Unstable Affliction is dispelled, the dispeller takes 1188 damage and is silenced for 5 seconds.\nA target can only be afflicted with one Unstable Affliction or Immolation by a Warlock at a time.|r"
    }
},
{
    id = "spellPandemic",
    name = "buttonSpellPandemic",
    icon = "Interface/icons/spell_shadow_unstableaffliction_2",
    position = {260, -350},
    handler = "spellpandemic",
    tooltips = {
        frFR = "|cffffffffPandémie|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Les dégâts périodiques de vos sorts Corruption et Affliction instable peuvent être critiques et infliger 100% de dégâts supplémentaires.\nAugmente également le bonus aux dégâts des coups critiques réussis avec votre sort Hanter de 100%.|r",
        enUS = "|cffffffffPandemic|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100The periodic damage of your Corruption and Unstable Affliction spells can critically hit and deal 100% more damage.\nAlso increases the critical damage bonus for your Haunt spell by 100%.|r"
    }
},

{
    id = "spellEverlastingAffliction",
    name = "buttonSpellEverlastingAffliction",
    icon = "Interface/icons/ability_warlock_everlastingaffliction",
    position = {368, -350},
    handler = "spelleverlastingaffliction",
    tooltips = {
        frFR = "|cffffffffAffliction éternelle|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Vos sorts Corruption et Affliction instable bénéficient de 5% supplémentaires de votre bonus aux dégâts des sorts,\net vos sorts Drain de vie, Drain d'âme, Trait de l'ombre et Hanter ont 100% de chances de réinitialiser la durée de votre sort Corruption sur la cible.|r",
        enUS = "|cffffffffEverlasting Affliction|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Your Corruption and Unstable Affliction spells gain an additional 5% of your spell damage bonus,\nand your Drain Life, Drain Soul, Shadow Bolt, and Haunt spells have a 100% chance to refresh the duration of your Corruption on the target.|r"
    }
},

{
    id = "spellHaunt",
    name = "buttonSpellHaunt",
    icon = "Interface/icons/ability_warlock_haunt",
    position = {478, -350},
    handler = "spellhaunt",
    tooltips = {
        frFR = "|cffffffffHanter|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Vous envoyez une âme fantomatique à l'intérieur de la cible, ce qui lui inflige 465 à 544 points de dégâts d'Ombre\net augmente tous les dégâts infligés par vos effets de dégâts d'Ombre sur la durée de 20% pendant 12 secondes.\nQuand le sort Hanter prend fin ou est dissipé, l'âme vous revient et vous soigne pour un montant\nde points de vie égal à 100% des dégâts qu'elle a infligés à la cible.|r",
        enUS = "|cffffffffHaunt|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100You send a ghostly soul into the target, dealing 465 to 544 Shadow damage and increasing all damage dealt by your periodic Shadow effects by 20% for 12 seconds.\nWhen Haunt finishes or is dispelled, the soul returns to you and heals you for an amount equal to 100% of the damage it dealt to the target.|r"
    }
},


-- CreateSpellButton("buttonSpellImprovedCurseofAgony", "Interface/icons/spell_shadow_curseofsargeras", "|cffffffffMalédiction d'agonie améliorée|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les dégâts infligés par votre sort Malédiction d'agonie de 10%.|r", "spellimprovedcurseofagony", 100, -80)
-- CreateSpellButton("buttonSpellSuppression", "Interface/icons/spell_shadow_unsummonbuilding", "|cffffffffSuppression|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 3% vos chances de toucher avec les sorts, et réduit de 6% le coût en mana de vos sorts d'Affliction.|r", "spellsuppression", 205, -75)
-- CreateSpellButton("buttonSpellImprovedCorruption", "Interface/icons/spell_shadow_abominationexplosion", "|cffffffffCorruption améliorée|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les dégâts infligés par votre Corruption de 10% et augmente les chances de coup critique de votre Graine de Corruption de 5%.|r", "spellimprovedcorruption", 315, -75)
-- CreateSpellButton("buttonSpellImprovedCurseofWeakness", "Interface/icons/spell_shadow_curseofmannoroth", "|cffffffffMalédiction de faiblesse améliorée|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 20% le montant de puissance d'attaque réduit par votre Malédiction de faiblesse.|r", "spellimprovedcurseofweakness", 418, -80)
-- CreateSpellButton("buttonSpellImprovedDrainSoul", "Interface/icons/spell_shadow_haunting", "|cffffffffDrain d'âme amélioré|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Vous rend 15% de votre maximum de points de mana si vous tuez la cible pendant que vous drainez son âme.\nDe plus, vos sorts d'Affliction génèrent 20% de menace en moins.|r", "spellimproveddrainsoul", 45, -130)
-- CreateSpellButton("buttonSpellImprovedLifeTap", "Interface/icons/spell_shadow_burningspirit", "|cffffffffConnexion améliorée|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 20% le montant de mana octroyé par votre sort Connexion.|r", "spellimprovedlifetap", 150, -130)
-- CreateSpellButton("buttonSpellSoulSiphon", "Interface/icons/spell_shadow_lifedrain02", "|cffffffffSiphon d'âme|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente le montant de points drainé par vos sorts Drain de vie et Drain d'âme de 6% supplémentaires pour chaque effet d'Affliction sur la cible, jusqu'à un maximum de 18% d'effet supplémentaire.|r", "spellsoulsiphon", 260, -130)
-- CreateSpellButton("buttonSpellImprovedFear", "Interface/icons/spell_shadow_possession", "|cffffffffPeur améliorée|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Votre sort Peur inflige un Cauchemar à la cible lorsque l'effet de peur prend fin.\nCauchemar réduit la vitesse de déplacement de la cible de 30% pendant 5 seconds.|r", "spellimprovedfear", 370, -130)
-- CreateSpellButton("buttonSpellFelConcentration", "Interface/icons/spell_shadow_fingerofdeath", "|cffffffffConcentration corrompue|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit de 70% l'interruption causée par les attaques infligeant des dégâts pendant que vous incantez Drain de vie, Drain de mana, Drain d'âme, Affliction instable et Hanter.|r", "spelllfelconcentration", 475, -133)
-- CreateSpellButton("buttonSpellAmplifyCurse", "Interface/icons/spell_shadow_contagion", "|cffffffffMalédiction amplifiée|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit le temps de recharge global de vos Malédictions de 0.5 sec.|r", "spellamplifycurse", 96, -185)
-- CreateSpellButton("buttonSpellGrimReach", "Interface/icons/spell_shadow_callofbone", "|cffffffffAllonge sinistre|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente la portée de vos sorts d'Affliction de 20%.|r", "spellgrimreach", 205, -185)
-- CreateSpellButton("buttonSpellNightfall", "Interface/icons/spell_shadow_twilight", "|cffffffffCrépuscule|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Confère à vos sorts Corruption et Drain de vie 4% de chances de vous plonger dans un état de Transe de l'ombre après avoir infligé des dégâts à un adversaire.\nCet état réduit le temps d'incantation de votre prochain sort Trait de l'ombre de 100%.|r", "spellnightfall", 315, -185)
-- CreateSpellButton("buttonSpellEmpoweredCorruption", "Interface/icons/spell_shadow_abominationexplosion", "|cffffffffCorruption surpuissante|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les dégâts de votre sort Corruption d'un montant égal à 36% de votre puissance des sorts.|r", "spellempoweredcorruption", 422, -185)
-- CreateSpellButton("buttonSpellShadowEmbrace", "Interface/icons/spell_shadow_shadowembrace", "|cffffffffEtreinte de l'ombre|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Vos sorts Trait de l'ombre et Hanter provoquent aussi l'effet Etreinte de l'ombre,\nqui augmente tous les dégâts d'Ombre périodiques que vous infligez à la cible de 5%,\net réduit tous les soins périodiques prodigués à la cible de 10%.\nDure 12 seconds.\nCumulable jusqu'à 3 fois.|r", "spellshadowembrace", 527, -190)
-- CreateSpellButton("buttonSpellSiphonLife", "Interface/icons/spell_shadow_requiem", "|cffffffffSiphon de vie|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Quand vous infligez des dégâts avec votre sort Corruption, vous recevez instantanément un montant de points de vie égal à 40% des dégâts infligés.\nDe plus, les dégâts infligés par les effets sur la durée de votre Corruption, votre Graine de Corruption et votre Affliction instable sont augmentés de 5%.|r", "spellsiphonlife", 43, -240)
-- CreateSpellButton("buttonSpellCurseofExhaustion", "Interface/icons/spell_shadow_grimward", "|cffffffffMalédiction d'épuisement|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit la vitesse de la cible de 30% pendant 12 seconds.\nLa cible ne peut être victime que d'une malédiction par démoniste présent à la fois.|r", "spellcurseofexhaustion", 150, -240)
-- CreateSpellButton("buttonSpellImprovedFelhunter", "Interface/icons/spell_shadow_summonfelhunter", "|cffffffffChasseur corrompu amélioré|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Votre chasseur corrompu reçoit 8% de son maximum de mana chaque fois qu'il touche avec sa technique Morsure de l'ombre et le temps de recharge de cette technique est réduit de 4 sec.\nAugmente également l'effet de l'Intelligence gangrenée de votre chasseur corrompu de 10%.|r", "spellimprovedfelhunter", 368, -240)
-- CreateSpellButton("buttonSpellShadowMastery", "Interface/icons/spell_shadow_shadetruesight", "|cffffffffMaîtrise de l'ombre|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 15% les points de dégâts infligés ou les points de vie drainés par vos sorts d'Ombre et la technique Morsure de l'ombre de votre chasseur corrompu.|r", "spellshadowmastery", 478, -240)
-- CreateSpellButton("buttonSpellEradication", "Interface/icons/ability_warlock_eradication", "|cffffffffEradication|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Quand vous infligez des dégâts avec Corruption, vous avez 6% de chances d'augmenter votre vitesse d'incantation des sorts de 20% pendant 10 seconds.|r", "spelleradication", 98, -293)
-- CreateSpellButton("buttonSpellContagion", "Interface/icons/spell_shadow_painfulafflictions", "|cffffffffContagion|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les points de dégâts infligés par Malédiction d'agonie,\nCorruption et Graine de Corruption de 5% et réduit la probabilité que vos sorts d'Affliction et vos effets de dégâts sur la durée soient dissipés de 30% supplémentaires.|r", "spellcontagion", 205, -293)
-- CreateSpellButton("buttonSpellDarkPact", "Interface/icons/spell_shadow_darkritual", "|cffffffffPacte noir|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Draine 305 points de mana à votre démon invoqué et vous rend 100% du montant.|r", "spelldarkpact", 315, -293)
-- CreateSpellButton("buttonSpellImprovedHowlofTerror", "Interface/icons/spell_shadow_deathscream", "|cffffffffHurlement de terreur amélioré|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit le temps d'incantation de votre sort Hurlement de terreur de 1.5 sec.|r", "spellimprovedhowlofterror", 422, -293)
-- CreateSpellButton("buttonSpellMalediction", "Interface/icons/spell_shadow_curseofachimonde", "|cffffffffImprécation|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente vos dégâts des sorts de 3% et augmente les chances de coup critique périodique de vos sorts Corruption et Affliction instable de 9%.|r", "spellmalediction", 527, -295)
-- CreateSpellButton("buttonSpellDeathsEmbrace", "Interface/icons/spell_shadow_deathsembrace", "|cffffffffCaresse de la mort|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente le montant de points de vie drainés par votre Drain de vie de 30% quand vous disposez de 20% ou moins de vos points de vie,\net augmente les dégâts infligés par vos sorts d'Ombre de 12% quand votre cible dispose de 35% ou moins de ses points de vie.|r", "spelldeathsembrace", 43, -350)
-- CreateSpellButton("buttonSpellUnstableAffliction", "Interface/icons/spell_shadow_unstableaffliction_3", "|cffffffffAffliction instable|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100L’énergie de l’Ombre détruit lentement la cible, infligeant 660 points de dégâts en 15 seconds.\nDe plus, si l'Affliction instable est dissipée, celui qui la dissipe subit 1188 points de dégâts et est réduit au silence pendant 5 seconds.\nUne cible ne peut être victime que d'une seule Affliction instable ou Immolation par démoniste.|r", "spellunstableaffliction", 150, -350)
-- CreateSpellButton("buttonSpellPandemic", "Interface/icons/spell_shadow_unstableaffliction_2", "|cffffffffPandémie|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Les dégâts périodiques de vos sorts Corruption et Affliction instable peuvent être critiques et infliger 100% de dégâts supplémentaires.\nAugmente également le bonus aux dégâts des coups critiques réussis avec votre sort Hanter de 100%.|r", "spellpandemic", 260, -350)
-- CreateSpellButton("buttonSpellEverlastingAffliction", "Interface/icons/ability_warlock_everlastingaffliction", "|cffffffffAffliction éternelle|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Vos sorts Corruption et Affliction instable bénéficient de 5% supplémentaires de votre bonus aux dégâts des sorts,\net vos sorts Drain de vie, Drain d'âme, Trait de l'ombre et Hanter ont 100% de chances de réinitialiser la durée de votre sort Corruption sur la cible.|r", "spelleverlastingaffliction", 368, -350)
-- CreateSpellButton("buttonSpellHaunt", "Interface/icons/ability_warlock_haunt", "|cffffffffHanter|r\n|cffffffffTalent|r |cff008080Affliction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Vous envoyez une âme fantomatique à l'intérieur de la cible, ce qui lui inflige 465 à 544 points de dégâts d'Ombre\net augmente tous les dégâts infligés par vos effets de dégâts d'Ombre sur la durée de 20% pendant 12 seconds.\nQuand le sort Hanter prend fin ou est dissipé, l'âme vous revient et vous soigne pour un montant\nde points de vie égal à 100% des dégâts qu'elle a infligés à la cible.|r", "spellhaunt", 478, -350)

-- Démonologie

{
    id = "spellImprovedHealthstone",
    name = "buttonSpellImprovedHealthstone",
    icon = "Interface/icons/inv_stone_04",
    position = {98, -405},
    handler = "spellimprovedhealthstone",
    tooltips = {
        frFR = "|cffffffffPierre de soins améliorée|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente le montant de points de vie restaurés par votre Pierre de soin de 20%.|r",
        enUS = "|cffffffffImproved Healthstone|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the amount of health restored by your Healthstone by 20%.|r"
    }
},
{
    id = "spellImprovedImp",
    name = "buttonSpellImprovedImp",
    icon = "Interface/icons/spell_shadow_summonimp",
    position = {205, -405},
    handler = "spellimprovedimp",
    tooltips = {
        frFR = "|cffffffffDiablotin amélioré|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les effets des sorts Eclair de feu, Bouclier de feu et Pacte de sang de votre diablotin de 30%.|r",
        enUS = "|cffffffffImproved Imp|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the effectiveness of your Imp's Firebolt, Fire Shield, and Blood Pact by 30%.|r"
    }
},
{
    id = "spellDemonicEmbrace",
    name = "buttonSpellDemonicEmbrace",
    icon = "Interface/icons/spell_shadow_metamorphosis",
    position = {315, -405},
    handler = "spelldemonicembrace",
    tooltips = {
        frFR = "|cffffffffBaiser démoniaque|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente votre total d'Endurance de 10%.|r",
        enUS = "|cffffffffDemonic Embrace|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases your total Stamina by 10%.|r"
    }
},
{
    id = "spellFelSynergy",
    name = "buttonSpellFelSynergy",
    icon = "Interface/icons/spell_shadow_felmending",
    position = {422, -405},
    handler = "spellfelsynergy",
    tooltips = {
        frFR = "|cffffffffSynergie gangrenée|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Vous avez 100% de chances de rendre à votre familier un montant de points de vie égal à 15% du montant de dégâts que vous infligez avec des sorts.|r",
        enUS = "|cffffffffFel Synergy|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100You have a 100% chance to heal your pet for 15% of the damage you deal with spells.|r"
    }
},
{
    id = "spellImprovedHealthFunnel",
    name = "buttonSpellImprovedHealthFunnel",
    icon = "Interface/icons/spell_shadow_lifedrain",
    position = {43, -458},
    handler = "spellimprovedhealthfunnel",
    tooltips = {
        frFR = "|cffffffffCaptation de vie améliorée|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente le montant de points de vie transférés par votre sort Captation de vie de 20% et réduit le coût initial en points de vie de 20%.\nDe plus, votre démon invoqué subit 30% de dégâts en moins pendant qu'il est sous l'effet de votre Captation de vie.|r",
        enUS = "|cffffffffImproved Health Funnel|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the amount of health transferred by your Health Funnel by 20% and reduces the initial health cost by 20%. Also, your summoned pet takes 30% less damage while under the effect of your Health Funnel.|r"
    }
},
{
    id = "spellDemonicBrutality",
    name = "buttonSpellDemonicBrutality",
    icon = "Interface/icons/spell_shadow_summonvoidwalker",
    position = {150, -458},
    handler = "spelldemonicbrutality",
    tooltips = {
        frFR = "|cffffffffBrutalité démoniaque|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 30% l'efficacité des sorts Tourment, Consumer les ombres, Sacrifice et Souffrance de votre marcheur du Vide,\net augmente de 3% le bonus à la puissance d'attaque de l'effet Frénésie démoniaque de votre gangregarde.|r",
        enUS = "|cffffffffDemonic Brutality|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the effectiveness of your Voidwalker's Torment, Shadow Consume, Sacrifice, and Agony by 30%,\nand increases the bonus to the attack power of your Felguard's Demonic Frenzy effect by 3%.|r"
    }
},
{
    id = "spellFelVitality",
    name = "buttonSpellFelVitality",
    icon = "Interface/icons/spell_holy_magicalsentry",
    position = {260, -458},
    handler = "spellfelvitality",
    tooltips = {
        frFR = "|cffffffffVitalité gangrenée|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 15% l'Endurance et l'Intelligence de votre diablotin, marcheur du Vide, succube, chasseur corrompu et gangregarde et de 3% votre maximum de points de vie et de mana.|r",
        enUS = "|cffffffffFel Vitality|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the Stamina and Intellect of your Imp, Voidwalker, Succubus, Felhunter, and Felguard by 15%,\nand increases your maximum health and mana by 3%.|r"
    }
},
{
    id = "spellImprovedSayaad",
    name = "buttonSpellImprovedSayaad",
    icon = "Interface/icons/spell_shadow_summonsuccubus",
    position = {368, -458},
    handler = "spellimprovedsayaad",
    tooltips = {
        frFR = "|cffffffffSuccube améliorée|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit le temps d'incantation de la Séduction de votre succube de 66% et augmente la durée de ses sorts Séduction et Invisibilité inférieure de 30%.|r",
        enUS = "|cffffffffImproved Sayaad|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Reduces the casting time of your Succubus' Seduction by 66% and increases the duration of her Seduction and Lesser Invisibility spells by 30%.|r"
    }
},
{
    id = "spellSoulLink",
    name = "buttonSpellSoulLink",
    icon = "Interface/icons/spell_shadow_gathershadows",
    position = {478, -458},
    handler = "spellsoullink",
    tooltips = {
        frFR = "|cffffffffLien spirituel|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Une fois activé, 20% de tous les points de dégâts infligés au lanceur de sorts sont subis à sa place par son diablotin,\nson marcheur du Vide, sa succube, son chasseur corrompu, son gangregarde ou son démon asservi.\nCes dégâts ne peuvent être évités.\nDure aussi longtemps que le démon est actif et sous contrôle.|r",
        enUS = "|cffffffffSoul Link|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100When activated, 20% of all damage dealt to you is instead taken by your Imp, Voidwalker, Succubus, Felhunter, Felguard, or Felsteed.\nThese damages cannot be avoided.\nLasts as long as the demon is active and under control.|r"
    }
},
{
    id = "spellFelDomination",
    name = "buttonSpellFelDomination",
    icon = "Interface/icons/spell_nature_removecurse",
    position = {98, -510},
    handler = "spellfeldomination",
    tooltips = {
        frFR = "|cffffffffDomination corrompue|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Le temps d'incantation de votre prochain sort d'invocation de diablotin, de marcheur du Vide, de succube,\nde chasseur corrompu ou de gangregarde est réduit de S1 sec.\net son coût en mana est réduit de 50%.|r",
        enUS = "|cffffffffFel Domination|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Reduces the cast time of your next Imp, Voidwalker, Succubus, Felhunter, or Felguard summon spell by 1 sec,\nand its mana cost by 50%.|r"
    }
},
{
    id = "spellDemonicAegis",
    name = "buttonSpellDemonicAegis",
    icon = "Interface/icons/spell_shadow_ragingscream",
    position = {205, -510},
    handler = "spelldemonicaegis",
    tooltips = {
        frFR = "|cffffffffEgide démoniaque|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 30% l'efficacité de votre Armure démoniaque et de votre Gangrarmure.|r",
        enUS = "|cffffffffDemonic Aegis|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the effectiveness of your Demon Armor and Fel Armor by 30%.|r"
    }
},
{
    id = "spellUnholyPower",
    name = "buttonSpellUnholyPower",
    icon = "Interface/icons/spell_shadow_shadowworddominate",
    position = {315, -510},
    handler = "spellunholypower",
    tooltips = {
        frFR = "|cffffffffPuissance impie|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 20% les dégâts infligés par les attaques de mêlée du marcheur du Vide, de la succube,\ndu chasseur corrompu et du gangregarde et par l'Eclair de feu du diablotin.|r",
        enUS = "|cffffffffUnholy Power|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the damage of your Voidwalker's, Succubus', Felhunter's, Felguard's melee attacks,\nand your Imp's Firebolt by 20%.|r"
    }
},
{
    id = "spellMasterSummoner",
    name = "buttonSpellMasterSummoner",
    icon = "Interface/icons/spell_shadow_impphaseshift",
    position = {422, -510},
    handler = "spellmastersummoner",
    tooltips = {
        frFR = "|cffffffffMaître invocateur|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit le temps d'incantation de vos sorts d'invocations de diablotin, de succube,\nde marcheur du Vide, de chasseur corrompu et de gangregarde de 4 sec. et leur coût en mana de 40%.|r",
        enUS = "|cffffffffMaster Summoner|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Reduces the casting time of your Imp, Succubus, Voidwalker, Felhunter, and Felguard summons by 4 sec,\nand their mana cost by 40%.|r"
    }
},


-- CreateSpellButton("buttonSpellImprovedHealthstone", "Interface/icons/inv_stone_04", "|cffffffffPierre de soins améliorée|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente le montant de points de vie restaurés par votre Pierre de soin de 20%.|r", "spellimprovedhealthstone", 98, -405)
-- CreateSpellButton("buttonSpellImprovedImp", "Interface/icons/spell_shadow_summonimp", "|cffffffffDiablotin amélioré|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les effets des sorts Eclair de feu, Bouclier de feu et Pacte de sang de votre diablotin de 30%.|r", "spellimprovedimp", 205, -405)
-- CreateSpellButton("buttonSpellDemonicEmbrace", "Interface/icons/spell_shadow_metamorphosis", "|cffffffffBaiser démoniaque|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente votre total d'Endurance de 10%.|r", "spelldemonicembrace", 315, -405)
-- CreateSpellButton("buttonSpellFelSynergy", "Interface/icons/spell_shadow_felmending", "|cffffffffSynergie gangrenée|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Vous avez 100% de chances de rendre à votre familier un montant de points de vie égal à 15% du montant de dégâts que vous infligez avec des sorts.|r", "spellfelsynergy", 422, -405)
-- CreateSpellButton("buttonSpellImprovedHealthFunnel", "Interface/icons/spell_shadow_lifedrain", "|cffffffffCaptation de vie améliorée|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente le montant de points de vie transférés par votre sort Captation de vie de 20% et réduit le coût initial en points de vie de 20%.\nDe plus, votre démon invoqué subit 30% de dégâts en moins pendant qu'il est sous l'effet de votre Captation de vie.|r", "spellimprovedhealthfunnel", 43, -458)
-- CreateSpellButton("buttonSpellDemonicBrutality", "Interface/icons/spell_shadow_summonvoidwalker", "|cffffffffBrutalité démoniaque|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 30% l'efficacité des sorts Tourment, Consumer les ombres, Sacrifice et Souffrance de votre marcheur du Vide,\net augmente de 3% le bonus à la puissance d'attaque de l'effet Frénésie démoniaque de votre gangregarde.|r", "spelldemonicbrutality", 150, -458)
-- CreateSpellButton("buttonSpellFelVitality", "Interface/icons/spell_holy_magicalsentry", "|cffffffffVitalité gangrenée|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 15% l'Endurance et l'Intelligence de votre diablotin, marcheur du Vide, succube, chasseur corrompu et gangregarde et de 3% votre maximum de points de vie et de mana.|r", "spellfelvitality", 260, -458)
-- CreateSpellButton("buttonSpellImprovedSayaad", "Interface/icons/spell_shadow_summonsuccubus", "|cffffffffSuccube améliorée|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit le temps d'incantation de la Séduction de votre succube de 66% et augmente la durée de ses sorts Séduction et Invisibilité inférieure de 30%.|r", "spellimprovedsayaad", 368, -458)
-- CreateSpellButton("buttonSpellSoulLink", "Interface/icons/spell_shadow_gathershadows", "|cffffffffLien spirituel|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Une fois activé, 20% de tous les points de dégâts infligés au lanceur de sorts sont subis à sa place par son diablotin,\nson marcheur du Vide, sa succube, son chasseur corrompu, son gangregarde ou son démon asservi.\nCes dégâts ne peuvent être évités.\nDure aussi longtemps que le démon est actif et sous contrôle.|r", "spellsoullink", 478, -458)
-- CreateSpellButton("buttonSpellFelDomination", "Interface/icons/spell_nature_removecurse", "|cffffffffDomination corrompue|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Le temps d'incantation de votre prochain sort d'invocation de diablotin, de marcheur du Vide, de succube,\nde chasseur corrompu ou de gangregarde est réduit de S1 sec.\net son coût en mana est réduit de 50%.|r", "spellfeldomination", 98, -510)
-- CreateSpellButton("buttonSpellDemonicAegis", "Interface/icons/spell_shadow_ragingscream", "|cffffffffEgide démoniaque|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 30% l'efficacité de votre Armure démoniaque et de votre Gangrarmure.|r", "spelldemonicaegis", 205, -510)
-- CreateSpellButton("buttonSpellUnholyPower", "Interface/icons/spell_shadow_shadowworddominate", "|cffffffffPuissance impie|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 20% les dégâts infligés par les attaques de mêlée du marcheur du Vide, de la succube,\ndu chasseur corrompu et du gangregarde et par l'Eclair de feu du diablotin.|r", "spellunholypower", 315, -510)
-- CreateSpellButton("buttonSpellMasterSummoner", "Interface/icons/spell_shadow_impphaseshift", "|cffffffffMaître invocateur|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit le temps d'incantation de vos sorts d'invocations de diablotin, de succube,\nde marcheur du Vide, de chasseur corrompu et de gangregarde de 4 sec. et leur coût en mana de 40%.|r", "spellmastersummoner", 422, -510)

-- Template 2

{
    id = "spellManaFeed",
    name = "buttonSpellManaFeed",
    icon = "Interface/icons/spell_shadow_manafeed",
    position = {663, -75},
    handler = "spellmanafeed",
    tooltips = {
        frFR = "|cffffffffFestin de mana|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Lorsque vous recevez du mana grâce aux sorts Drain de mana ou Connexion,\nvotre démon invoqué reçoit lui aussi 100% de ce montant de mana.|r",
        enUS = "|cffffffffMana Feed|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100When you gain mana from Mana Drain or Connection spells,\nyour summoned demon also receives 100% of that mana.|r"
    }
},
{
    id = "spellMasterConjuror",
    name = "buttonSpellMasterConjuror",
    icon = "Interface/icons/inv_ammo_firetar",
    position = {770, -75},
    handler = "spellmasterconjuror",
    tooltips = {
        frFR = "|cffffffffMaître conjurateur|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 300% les scores de combat conférés par vos Pierres de feu et Pierres de sort invoquées.|r",
        enUS = "|cffffffffMaster Conjuror|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the combat ratings granted by your Fire Stones and Spellstones by 300%.|r"
    }
},
{
    id = "spellMasterDemonologist",
    name = "buttonSpellMasterDemonologist",
    icon = "Interface/icons/spell_shadow_shadowpact",
    position = {880, -75},
    handler = "spellmasterdemonologist",
    tooltips = {
        frFR = "|cffffffffMaître démonologue|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Fait bénéficier le démoniste et le démon invoqué d'un effet aussi longtemps que le démon est actif.\n\n Diablotin - Augmente vos dégâts de Feu de 5%, et augmente les chances d'effet critique de vos sorts de Feu de 5%.\n\n Marcheur du Vide - Réduit les dégâts physiques subis de 10%.\n\n Succube - Augmente vos dégâts d'Ombre de 5%, et augmente les chances d'effet critique de vos sorts d'Ombre de 5%.\n\n Chasseur corrompu - Réduit tous les dégâts des sorts subis de 10%.\n\n Gangregarde - Augmente tous les dégâts infligés de 5%, et réduit tous les dégâts subis de 5%.|r",
        enUS = "|cffffffffMaster Demonologist|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Grants both the warlock and their summoned demon an effect as long as the demon is active.\n\n Imp - Increases your Fire damage by 5%, and increases your Fire spell critical strike chance by 5%.\n\n Voidwalker - Reduces physical damage taken by 10%.\n\n Succubus - Increases your Shadow damage by 5%, and increases your Shadow spell critical strike chance by 5%.\n\n Felhunter - Reduces all spell damage taken by 10%.\n\n Felguard - Increases all damage dealt by 5%, and reduces all damage taken by 5%.|r"
    }
},
{
    id = "spellMoltenCore",
    name = "buttonSpellMoltenCore",
    icon = "Interface/icons/ability_warlock_moltencore",
    position = {990, -75},
    handler = "spellmoltencore",
    tooltips = {
        frFR = "|cffffffffCoeur de la fournaise|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente la durée de votre Immolation de 9 sec., et vous avez 12% de chances de bénéficier de l'effet Coeur de la fournaise quand votre Corruption inflige des dégâts.\nL'effet Coeur de la fournaise rend plus puissants vos 3 prochains sorts Incinérer ou Feu de l'âme lancés dans les 15 seconds.\n\n Incinérer - Augmente les dégâts infligés de 18% et réduit le temps d'incantation de 30%.\n\n Feu de l'âme - Augmente les dégâts infligés de 18% et augmente les chances de coup critique de 15%.|r",
        enUS = "|cffffffffMolten Core|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the duration of your Immolation by 9 sec, and gives you a 12% chance to activate Molten Core when your Corruption deals damage.\nMolten Core empowers your next 3 Incinerate or Soul Fire casts within 15 seconds.\n\n Incinerate - Increases damage dealt by 18% and reduces casting time by 30%.\n\n Soul Fire - Increases damage dealt by 18% and increases critical strike chance by 15%.|r"
    }
},
{
    id = "spellDemonicResilience",
    name = "buttonSpellDemonicResilience",
    icon = "Interface/icons/spell_shadow_demonicfortitude",
    position = {1100, -75},
    handler = "spelldemonicresilience",
    tooltips = {
        frFR = "|cffffffffRésilience démoniaque|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit de 3% la probabilité que vous soyez touché par un coup critique infligé en mêlée ou par un sort et réduit de 15% tous les dégâts que subit votre démon invoqué.|r",
        enUS = "|cffffffffDemonic Resilience|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Reduces the chance that you are critically hit by melee or spell attacks by 3% and reduces all damage taken by your summoned demon by 15%.|r"
    }
},
{
    id = "spellDemonicEmpowerment",
    name = "buttonSpellDemonicEmpowerment",
    icon = "Interface/icons/ability_warlock_demonicempowerment",
    position = {718, -130},
    handler = "spelldemonicempowerment",
    tooltips = {
        frFR = "|cffffffffRenforcement démoniaque|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Confère un renforcement au démon invoqué du démoniste.\n\n Diablotin - Augmente ses chances de critique avec les sorts de 20% pendant 30 secondes.\n\n Marcheur du Vide - Augmente ses points de vie de 20% et augmente la menace générée par ses sorts et attaques de 20% pendant 20 secondes.\n\n Succube - Disparition immédiate qui la fait entrer dans un état d'invisibilité améliorée. L'effet de disparition annule tous les étourdissements, ralentissements et effets affectant le déplacement sur la succube.\n\n Chasseur corrompu - Dissipe tous les effets magiques sur le chasseur corrompu.\n\n Gangregarde - Augmente sa vitesse d'attaque de 20%, annule tous les étourdissements, ralentissements et effets affectant le déplacement et rend le gangregarde insensible à ces effets pendant 15 secondes.|r",
        enUS = "|cffffffffDemonic Empowerment|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Grants a buff to the warlock’s summoned demon.\n\n Imp - Increases spell crit chance by 20% for 30 seconds.\n\n Voidwalker - Increases health by 20% and threat generated by spells and attacks by 20% for 20 seconds.\n\n Succubus - Immediate Vanish that puts her into an improved stealth state. The Vanish effect clears all stuns, slows, and movement-impairing effects.\n\n Felhunter - Dispels all magic effects on the felhunter.\n\n Felguard - Increases attack speed by 20%, clears all stuns, slows, and movement-impairing effects and makes the felguard immune to them for 15 seconds.|r"
    }
},
{
    id = "spellDemonicKnowledge",
    name = "buttonSpellDemonicKnowledge",
    icon = "Interface/icons/spell_shadow_improvedvampiricembrace",
    position = {825, -130},
    handler = "spelldemonicknowledge",
    tooltips = {
        frFR = "|cffffffffConnaissance démoniaque|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les dégâts de vos sorts d'un montant égal à 12% du total de l'Endurance plus l'Intelligence de votre démon actif.|r",
        enUS = "|cffffffffDemonic Knowledge|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases your spell damage by an amount equal to 12% of your active demon’s total Stamina plus Intellect.|r"
    }
},
{
    id = "spellDemonicTactics",
    name = "buttonSpellDemonicTactics",
    icon = "Interface/icons/spell_shadow_demonictactics",
    position = {935, -130},
    handler = "spelldemonictactics",
    tooltips = {
        frFR = "|cffffffffTactique démoniaque|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente vos chances de coup critique en mêlée et avec les sorts ainsi que celles de votre démon invoqué de 10%.|r",
        enUS = "|cffffffffDemonic Tactics|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases your melee and spell critical strike chances, as well as your summoned demon’s, by 10%.|r"
    }
},
{
    id = "spellDecimation",
    name = "buttonSpellDecimation",
    icon = "Interface/icons/spell_fire_fireball02",
    position = {1045, -130},
    handler = "spelldecimation",
    tooltips = {
        frFR = "|cffffffffDécimation|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Lorsque vous touchez avec Trait de l'ombre, Incinérer ou Feu de l'âme une cible qui dispose de 35% ou moins de ses points de vie,\nle temps d'incantation de votre sort Feu de l'âme est réduit de 40% pendant 10 secondes.\nLes Feux de l'âme lancés sous l'effet de Décimation ne coûtent pas de fragment.|r",
        enUS = "|cffffffffDecimation|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100When you hit with Shadow Bolt, Incinerate, or Soul Fire on a target with 35% or less health,\nthe cast time of your Soul Fire spell is reduced by 40% for 10 seconds.\nSoul Fires cast under Decimation do not cost a shard.|r"
    }
},
{
    id = "spellImprovedDemonicTactics",
    name = "buttonSpellImprovedDemonicTactics",
    icon = "Interface/icons/ability_warlock_improveddemonictactics",
    position = {663, -184},
    handler = "spellimproveddemonictactics",
    tooltips = {
        frFR = "|cffffffffTactique démoniaque améliorée|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les chances de coup critique de votre démon invoqué,\nles rendant égales à 30% de vos propres chances.|r",
        enUS = "|cffffffffImproved Demonic Tactics|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases your summoned demon’s critical strike chance,\nmaking it equal to 30% of your own critical strike chance.|r"
    }
},
{
    id = "spellSummonFelguard",
    name = "buttonSpellSummonFelguard",
    icon = "Interface/icons/spell_shadow_summonfelguard",
    position = {770, -184},
    handler = "spellsummonfelguard",
    tooltips = {
        frFR = "|cffffffffInvocation d'un gangregarde|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Invoque un gangregarde qui exécute les ordres du démoniste.|r",
        enUS = "|cffffffffSummon Felguard|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Summons a felguard to carry out the warlock’s commands.|r"
    }
},
{
    id = "spellNemesis",
    name = "buttonSpellNemesis",
    icon = "Interface/icons/spell_shadow_demonicempathy",
    position = {880, -184},
    handler = "spellnemesis",
    tooltips = {
        frFR = "|cffffffffInstrument de vengeance|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit le temps de recharge de vos sorts Renforcement démoniaque, Métamorphe et Domination corrompue de 30%.|r",
        enUS = "|cffffffffNemesis|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Reduces the cooldown of your Demonic Empowerment, Metamorphosis, and Corrupted Domination spells by 30%.|r"
    }
},
{
    id = "spellDemonicPact",
    name = "buttonSpellDemonicPact",
    icon = "Interface/icons/spell_shadow_demonicpact",
    position = {990, -184},
    handler = "spelldemonicpact",
    tooltips = {
        frFR = "|cffffffffPacte démoniaque|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente vos dégâts des sorts de 10%, et les critiques de votre familier appliquent l'effet Pacte démoniaque sur les membres de votre groupe ou raid.\nLe Pacte démoniaque augmente la puissance des sorts de 10% de vos dégâts des sorts pendant 45 secondes.\nCet effet a un temps de recharge de 20 secondes.\nNe fonctionne pas sur les démons asservis.|r",
        enUS = "|cffffffffDemonic Pact|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases your spell damage by 10%, and critical strikes from your pet apply the Demonic Pact effect to members of your group or raid.\nDemonic Pact increases the spell power of your spell damage by 10% for 45 seconds.\nThis effect has a 20-second cooldown.\nDoes not work on enslaved demons.|r"
    }
},
{
    id = "spellMetamorphosis",
    name = "buttonSpellMetamorphosis",
    icon = "Interface/icons/spell_shadow_demonform",
    position = {1100, -184},
    handler = "spellmetamorphosis",
    tooltips = {
        frFR = "|cffffffffMétamorphe|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Vous vous transformez en démon pendant 30 secondes.\nCette forme augmente votre armure de 600% et vos dégâts de 20%,\nréduit la probabilité que vous soyez touché par des coups critiques en mêlée de 6%\net réduit la durée des effets d'étourdissement et de ralentissement qui vous affectent de 50%.\nVous bénéficiez de techniques démoniaques spécifiques en plus de vos techniques normales.\nTemps de recharge de 3 minutes.|r",
        enUS = "|cffffffffMetamorphosis|r\n|cffffffffTalent|r |cff80ff00Demonology|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Transforms you into a demon for 30 seconds.\nThis form increases your armor by 600% and your damage by 20%,\nreduces the chance to be hit by melee critical strikes by 6%,\nand reduces the duration of stuns and slows on you by 50%.\nYou gain additional demon-specific abilities in addition to your normal abilities.\nCooldown of 3 minutes.|r"
    }
},


-- CreateSpellButton("buttonSpellManaFeed", "Interface/icons/spell_shadow_manafeed", "|cffffffffFestin de mana|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Lorsque vous recevez du mana grâce aux sorts Drain de mana ou Connexion,\nvotre démon invoqué reçoit lui aussi 100% de ce montant de mana.|r", "spellmanafeed", 663, -75)
-- CreateSpellButton("buttonSpellMasterConjuror", "Interface/icons/inv_ammo_firetar", "|cffffffffMaître conjurateur|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 300% les scores de combat conférés par vos Pierres de feu et Pierres de sort invoquées.|r", "spellmasterconjuror", 770, -75)
-- CreateSpellButton("buttonSpellMasterDemonologist", "Interface/icons/spell_shadow_shadowpact", "|cffffffffMaître démonologue|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Fait bénéficier le démoniste et le démon invoqué d'un effet aussi longtemps que le démon est actif.\n\n Diablotin - Augmente vos dégâts de Feu de 5%, et augmente les chances d'effet critique de vos sorts de Feu de 5%.\n\n Marcheur du Vide - Réduit les dégâts physiques subis de 10%.\n\n Succube - Augmente vos dégâts d'Ombre de 5%, et augmente les chances d'effet critique de vos sorts d'Ombre de 5%.\n\n Chasseur corrompu - Réduit tous les dégâts des sorts subis de 10%.\n\n Gangregarde - Augmente tous les dégâts infligés de 5%, et réduit tous les dégâts subis de 5%.|r", "spellmasterdemonologist", 880, -75)
-- CreateSpellButton("buttonSpellMoltenCore", "Interface/icons/ability_warlock_moltencore", "|cffffffffCoeur de la fournaise|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente la durée de votre Immolation de 9 sec., et vous avez 12% de chances de bénéficier de l'effet Coeur de la fournaise quand votre Corruption inflige des dégâts.\nL'effet Coeur de la fournaise rend plus puissants vos 3 prochains sorts Incinérer ou Feu de l'âme lancés dans les 15 seconds.\n\n Incinérer - Augmente les dégâts infligés de 18% et réduit le temps d'incantation de 30%.\n\n Feu de l'âme - Augmente les dégâts infligés de 18% et augmente les chances de coup critique de 15%.|r", "spellmoltencore", 990, -75)
-- CreateSpellButton("buttonSpellDemonicResilience", "Interface/icons/spell_shadow_demonicfortitude", "|cffffffffRésilience démoniaque|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit de 3% la probabilité que vous soyez touché par un coup critique infligé en mêlée ou par un sort et réduit de 15% tous les dégâts que subit votre démon invoqué.|r", "spelldemonicresilience", 1100, -75)
-- CreateSpellButton("buttonSpellDemonicEmpowerment", "Interface/icons/ability_warlock_demonicempowerment", "|cffffffffRenforcement démoniaque|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Confère un renforcement au démon invoqué du démoniste.\n\n Diablotin - Augmente ses chances de critique avec les sorts de 20% pendant 30 seconds.\n\n Marcheur du Vide - Augmente ses points de vie de 20% et augmente la menace générée par ses sorts et attaques de 20% pendant 20 seconds.\n\n Succube - Disparition immédiate qui la fait entrer dans un état d'invisibilité améliorée. L'effet de disparition annule tous les étourdissements, ralentissements et effets affectant le déplacement sur la succube.\n\n Chasseur corrompu - Dissipe tous les effets magiques sur le chasseur corrompu.\n\n Gangregarde - Augmente sa vitesse d'attaque de 20%, annule tous les étourdissements, ralentissements et effets affectant le déplacement et rend le gangregarde insensible à ces effets pendant 15 seconds.|r", "spelldemonicempowerment", 718, -130)
-- CreateSpellButton("buttonSpellDemonicKnowledge", "Interface/icons/spell_shadow_improvedvampiricembrace", "|cffffffffConnaissance démoniaque|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les dégâts de vos sorts d'un montant égal à 12% du total de l'Endurance plus l'Intelligence de votre démon actif.|r", "spelldemonicknowledge", 825, -130)
-- CreateSpellButton("buttonSpellDemonicTactics", "Interface/icons/spell_shadow_demonictactics", "|cffffffffTactique démoniaque|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente vos chances de coup critique en mêlée et avec les sorts ainsi que celles de votre démon invoqué de 10%.|r", "spelldemonictactics", 935, -130)
-- CreateSpellButton("buttonSpellDecimation", "Interface/icons/spell_fire_fireball02", "|cffffffffDécimation|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Lorsque vous touchez avec Trait de l'ombre, Incinérer ou Feu de l'âme une cible qui dispose de 35% ou moins de ses points de vie,\nle temps d'incantation de votre sort Feu de l'âme est réduit de 40% pendant 10 seconds.\nLes Feux de l'âme lancés sous l'effet de Décimation ne coûtent pas de fragment.|r", "spelldecimation", 1045, -130)
-- CreateSpellButton("buttonSpellImprovedDemonicTactics", "Interface/icons/ability_warlock_improveddemonictactics", "|cffffffffTactique démoniaque améliorée|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les chances de coup critique de votre démon invoqué,\nles rendant égales à 30% de vos propres chances.|r", "spellimproveddemonictactics", 663, -184)
-- CreateSpellButton("buttonSpellSummonFelguard", "Interface/icons/spell_shadow_summonfelguard", "|cffffffffInvocation d'un gangregarde|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Invoque un gangregarde qui exécute les ordres du démoniste.|r", "spellsummonfelguard", 770, -184)
-- CreateSpellButton("buttonSpellNemesis", "Interface/icons/spell_shadow_demonicempathy", "|cffffffffInstrument de vengeance|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit le temps de recharge de vos sorts Renforcement démoniaque, Métamorphe et Domination corrompue de 30%.|r", "spellnemesis", 880, -184)
-- CreateSpellButton("buttonSpellDemonicPact", "Interface/icons/spell_shadow_demonicpact", "|cffffffffPacte démoniaque|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente vos dégâts des sorts de 10%, et les critiques de votre familier appliquent l'effet Pacte démoniaque sur les membres de votre groupe ou raid.\nLe Pacte démoniaque augmente la puissance des sorts de 10% de vos dégâts des sorts pendant 45 seconds.\nCet effet a un temps de recharge de 20 sec.\nNe fonctionne pas sur les démons asservis.|r", "spelldemonicpact", 990, -184)
-- CreateSpellButton("buttonSpellMetamorphosis", "Interface/icons/spell_shadow_demonform", "|cffffffffMétamorphe|r\n|cffffffffTalent|r |cff80ff00Démonologie|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Vous vous transformez en démon pendant 30 seconds.\nCette forme augmente votre armure de 600% et vos dégâts de 20%,\nréduit la probabilité que vous soyez touché par des coups critiques en mêlée de 6%\net réduit la durée des effets d'étourdissement et de ralentissement qui vous affectent de 50%.\nVous bénéficiez de techniques démoniaques spécifiques en plus de vos techniques normales.\nTemps de recharge de 3 minutes.|r", "spellmetamorphosis", 1100, -184)


-- Destruction

{
    id = "spellImprovedShadowBolt",
    name = "buttonSpellImprovedShadowBolt",
    icon = "Interface/icons/spell_shadow_shadowbolt",
    position = {718, -240},
    handler = "spellimprovedshadowbolt",
    tooltips = {
        frFR = "|cffffffffTrait de l'ombre amélioré|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les dégâts infligés par votre sort Trait de l'ombre de 10%,\net votre Trait de l'ombre a également 100% de chances de rendre votre cible vulnérable aux dégâts des sorts,\nce qui augmente les chances de coup critique des sorts contre cette cible de 5%.\nL'effet dure 30 secondes.|r",
        enUS = "|cffffffffImproved Shadow Bolt|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the damage dealt by your Shadow Bolt by 10%, and your Shadow Bolt also has a 100% chance to make your target vulnerable to spell damage,\nincreasing the critical strike chance of spells against this target by 5%.\nThe effect lasts 30 seconds.|r"
    }
},
{
    id = "spellBane",
    name = "buttonSpellBane",
    icon = "Interface/icons/spell_shadow_deathpact",
    position = {825, -240},
    handler = "spellbane",
    tooltips = {
        frFR = "|cffffffffFléau|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit le temps d'incantation de vos sorts Trait de l'ombre, Trait du chaos et Immolation de 0.5 sec. et Feu de l'âme de 2 sec.|r",
        enUS = "|cffffffffBane|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Reduces the casting time of your Shadow Bolt, Chaos Bolt, and Immolate spells by 0.5 sec., and Soul Fire by 2 sec.|r"
    }
},
{
    id = "spellAftermath",
    name = "buttonSpellAftermath",
    icon = "Interface/icons/spell_fire_fire",
    position = {935, -240},
    handler = "spellaftermath",
    tooltips = {
        frFR = "|cffffffffConséquences|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les dégâts périodiques infligés par votre Immolation de 6%, et votre Conflagration a 100% de chances d'hébéter la cible pendant 5 secondes.|r",
        enUS = "|cffffffffAftermath|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the periodic damage of your Immolate by 6%, and your Conflagrate has a 100% chance to daze the target for 5 seconds.|r"
    }
},
{
    id = "spellMoltenSkin",
    name = "buttonSpellMoltenSkin",
    icon = "Interface/icons/ability_mage_moltenarmor",
    position = {1045, -240},
    handler = "spellmoltenskin",
    tooltips = {
        frFR = "|cffffffffPeau de la fournaise|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit tous les dégâts subis de 6%.|r",
        enUS = "|cffffffffMolten Skin|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Reduces all damage taken by 6%.|r"
    }
},
{
    id = "spellCataclysm",
    name = "buttonSpellCataclysm",
    icon = "Interface/icons/spell_fire_windsofwoe",
    position = {663, -293},
    handler = "spellcataclysm",
    tooltips = {
        frFR = "|cffffffffCataclysme|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit le coût en mana de vos sorts de Destruction de 10%.|r",
        enUS = "|cffffffffCataclysm|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Reduces the mana cost of your Destruction spells by 10%.|r"
    }
},
{
    id = "spellDemonicPower",
    name = "buttonSpellDemonicPower",
    icon = "Interface/icons/spell_fire_firebolt",
    position = {770, -293},
    handler = "spelldemonicpower",
    tooltips = {
        frFR = "|cffffffffPuissance démoniaque|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit le temps de recharge du sort Fouet de la douleur de votre succube de 6 sec. et le temps d'incantation du sort Eclair de feu de votre Diablotin de 0.50 sec.|r",
        enUS = "|cffffffffDemonic Power|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Reduces the cooldown of your Succubus' Whiplash by 6 sec., and the cast time of your Imp's Firebolt by 0.50 sec.|r"
    }
},
{
    id = "spellShadowburn",
    name = "buttonSpellShadowburn",
    icon = "Interface/icons/spell_shadow_scourgebuild",
    position = {990, -293},
    handler = "spellshadowburn",
    tooltips = {
        frFR = "|cffffffffBrûlure de l'ombre|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Frappe instantanément la cible et lui inflige 91 à 104 points de dégâts d'Ombre.\nSi la cible meurt dans les 5 secondes sous l'effet du sort Brûlure de l'ombre et rapporte de l'expérience ou de l'honneur,\nle lanceur gagne un Fragment d'âme.|r",
        enUS = "|cffffffffShadowburn|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Instantly strikes the target, dealing 91 to 104 Shadow damage.\nIf the target dies within 5 seconds under the effect of Shadowburn and grants experience or honor,\nthe caster gains a Soul Shard.|r"
    }
},
{
    id = "spellRuin",
    name = "buttonSpellRuin",
    icon = "Interface/icons/spell_shadow_shadowwordpain",
    position = {1100, -293},
    handler = "spellruin",
    tooltips = {
        frFR = "|cffffffffRuine|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 100% les points de dégâts supplémentaires infligés par les coups critiques de vos sorts de Destruction et le sort Eclair de feu de votre diablotin.|r",
        enUS = "|cffffffffRuin|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the additional damage dealt by critical strikes from your Destruction spells and your Imp's Firebolt by 100%.|r"
    }
},
{
    id = "spellIntensity",
    name = "buttonSpellIntensity",
    icon = "Interface/icons/spell_fire_lavaspawn",
    position = {718, -348},
    handler = "spellintensity",
    tooltips = {
        frFR = "|cffffffffIntensité|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit de 70% l'interruption causée par les attaques infligeant des dégâts pendant que vous incantez ou canalisez tout sort de Destruction.|r",
        enUS = "|cffffffffIntensity|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Reduces the interruption caused by damage-dealing attacks while casting or channeling any Destruction spell by 70%.|r"
    }
},
{
    id = "spellDestructiveReach",
    name = "buttonSpellDestructiveReach",
    icon = "Interface/icons/spell_shadow_corpseexplode",
    position = {825, -348},
    handler = "spelldestructivereach",
    tooltips = {
        frFR = "|cffffffffAllonge de destruction|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 20% la portée de vos sorts de Destruction et réduit de 20% la menace générée par les sorts de Destruction.|r",
        enUS = "|cffffffffDestructive Reach|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the range of your Destruction spells by 20%, and reduces the threat generated by Destruction spells by 20%.|r"
    }
},
{
    id = "spellImprovedSearingPain",
    name = "buttonSpellImprovedSearingPain",
    icon = "Interface/icons/spell_fire_soulburn",
    position = {935, -348},
    handler = "spellimprovedsearingpain",
    tooltips = {
        frFR = "|cffffffffDouleur brûlante améliorée|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 10% les chances d'infliger un coup critique avec votre sort Douleur brûlante.|r",
        enUS = "|cffffffffImproved Searing Pain|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases your chance to score a critical strike with your Searing Pain spell by 10%.|r"
    }
},
{
    id = "spellBacklash",
    name = "buttonSpellBacklash",
    icon = "Interface/icons/spell_fire_playingwithfire",
    position = {1045, -348},
    handler = "spellbacklash",
    tooltips = {
        frFR = "|cffffffffContrecoup|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente vos chances d'infliger un coup critique avec les sorts de 3% supplémentaires et vous confère 25%\nde chances lorsque vous êtes touché par une attaque physique de réduire le temps d'incantation de votre prochain sort Trait de l'ombre ou Incinérer de 100%.\nCet effet dure 8 secondes et ne peut se produire plus d'une fois toutes les 8 secondes.|r",
        enUS = "|cffffffffBacklash|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases your chance to critically strike with spells by an additional 3%, and grants you a 25%\nchance when hit by a physical attack to reduce the cast time of your next Shadow Bolt or Incinerate by 100%.\nThis effect lasts 8 seconds and cannot occur more than once every 8 seconds.|r"
    }
},
{
    id = "spellImprovedImmolate",
    name = "buttonSpellImprovedImmolate",
    icon = "Interface/icons/spell_fire_immolation",
    position = {663, -402},
    handler = "spellimprovedimmolate",
    tooltips = {
        frFR = "|cffffffffImmolation améliorée|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les dégâts infligés par votre sort Immolation de 30%.|r",
        enUS = "|cffffffffImproved Immolate|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the damage dealt by your Immolate spell by 30%.|r"
    }
},
{
    id = "spellDevastation",
    name = "buttonSpellDevastation",
    icon = "Interface/icons/spell_fire_flameshock",
    position = {770, -402},
    handler = "spelldevastation",
    tooltips = {
        frFR = "|cffffffffDévastation|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 5% vos chances d'infliger un coup critique avec vos sorts de Destruction.|r",
        enUS = "|cffffffffDevastation|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases your chance to critically strike with your Destruction spells by 5%.|r"
    }
},
{
    id = "spellNetherProtection",
    name = "buttonSpellNetherProtection",
    icon = "Interface/icons/spell_shadow_netherprotection",
    position = {880, -402},
    handler = "spellnetherprotection",
    tooltips = {
        frFR = "|cffffffffProtection du Néant|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Après avoir été touché par un sort, vous avez 30% de chances de recevoir la Protection du Néant, qui réduit tous les dégâts de la même école de 30% pendant 8 seconds.|r",
        enUS = "|cffffffffNether Protection|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100After being hit by a spell, you have a 30% chance to gain Nether Protection, reducing all damage from that school by 30% for 8 seconds.|r"
    }
},
{
    id = "spellEmberstorm",
    name = "buttonSpellEmberstorm",
    icon = "Interface/icons/spell_fire_selfdestruct",
    position = {990, -402},
    handler = "spellemberstorm",
    tooltips = {
        frFR = "|cffffffffTempête ardente|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les dégâts infligés par vos sorts de Feu de 15% et réduit le temps d'incantation de votre sort Incinérer de 0.25 sec.|r",
        enUS = "|cffffffffEmberstorm|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the damage of your Fire spells by 15% and reduces the cast time of your Incinerate spell by 0.25 sec.|r"
    }
},
{
    id = "spellConflagrate",
    name = "buttonSpellConflagrate",
    icon = "Interface/icons/spell_fire_fireball",
    position = {1100, -402},
    handler = "spellconflagrate",
    tooltips = {
        frFR = "|cffffffffConflagration|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Cause un effet d'Immolation ou d'Ombreflamme sur la cible ennemie pour lui infliger instantanément un montant de dégâts égal à\n69% de votre Immolation ou votre Ombreflamme et inflige 40% de dégâts supplémentaires en 6 seconds.|r",
        enUS = "|cffffffffConflagrate|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Causes an Immolate or Shadowflame effect on the enemy target, dealing instant damage equal to\n69% of your Immolate or Shadowflame damage, plus 40% additional damage over 6 seconds.|r"
    }
},
{
    id = "spellSoulLeech",
    name = "buttonSpellSoulLeech",
    icon = "Interface/icons/spell_shadow_soulleech_3",
    position = {718, -456},
    handler = "spellsoulleech",
    tooltips = {
        frFR = "|cffffffffSuceur d'âme|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Confère à vos sorts Trait de l'ombre, Brûlure de l'ombre,\nTrait du chaos, Feu de l'âme, Incinérer, Douleur brûlante et Conflagration 30% de chances de vous rendre un montant de points de vie égal à 20% des dégâts infligés.|r",
        enUS = "|cffffffffSoul Leech|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Gives your Shadow Bolt, Shadowburn, Chaos Bolt, Firebolt, Incinerate, Searing Pain, and Conflagrate spells a 30% chance to restore 20% of the damage dealt as health.|r"
    }
},
{
    id = "spellPyroclasm",
    name = "buttonSpellPyroclasm",
    icon = "Interface/icons/spell_fire_volcano",
    position = {825, -456},
    handler = "spellpyroclasm",
    tooltips = {
        frFR = "|cffffffffPyroclasme|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Quand vous réussissez un coup critique avec Douleur brûlante ou Conflagration, les dégâts de vos sorts de Feu et d'Ombre sont augmentés de 6% pendant 10 seconds.|r",
        enUS = "|cffffffffPyroclasm|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100When you score a critical strike with Searing Pain or Conflagrate, your Fire and Shadow spell damage is increased by 6% for 10 seconds.|r"
    }
},
{
    id = "spellShadowandFlame",
    name = "buttonSpellShadowandFlame",
    icon = "Interface/icons/spell_shadow_shadowandflame",
    position = {935, -456},
    handler = "spellshadowandflame",
    tooltips = {
        frFR = "|cffffffffOmbre et flammes|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Vos sorts Trait de l'ombre, Brûlure de l'ombre, Trait du chaos et Incinérer bénéficient\nde 20% supplémentaires des effets du bonus relatif aux dégâts des sorts.|r",
        enUS = "|cffffffffShadow and Flame|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Your Shadow Bolt, Shadowburn, Chaos Bolt, and Incinerate spells benefit from 20% additional effect from spell damage bonuses.|r"
    }
},
{
    id = "spellImprovedSoulLeech",
    name = "buttonSpellImprovedSoulLeech",
    icon = "Interface/icons/ability_warlock_improvedsoulleech",
    position = {1045, -456},
    handler = "spellimprovedsoulleech",
    tooltips = {
        frFR = "|cffffffffSuceur d'âme amélioré|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100L'effet de votre Suceur d'âme rend également à vous-même et à votre démon invoqué un montant de mana égal à 2% du maximum de mana,\net il a 100% de chances de faire bénéficier jusqu'à 10 membres du groupe ou raid d'une régénération\nde mana égale à 1% du maximum de mana toutes les 5 sec. Dure 15 seconds.|r",
        enUS = "|cffffffffImproved Soul Leech|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100The effect of your Soul Leech also restores mana equal to 2% of maximum mana to you and your summoned demon, and has a 100% chance to grant up to 10 party or raid members mana regeneration equal to 1% of their maximum mana every 5 sec. Lasts for 15 seconds.|r"
    }
},
{
    id = "spellBackdraft",
    name = "buttonSpellBackdraft",
    icon = "Interface/icons/ability_warlock_backdraft",
    position = {663, -510},
    handler = "spellbackdraft",
    tooltips = {
        frFR = "|cffffffffExplosion de fumées|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Quand vous lancez Conflagration, le temps d'incantation et le temps de recharge\nglobal de vos trois prochains sorts de Destruction est réduit de 30%.\nDure 15 seconds.|r",
        enUS = "|cffffffffBackdraft|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100When you cast Conflagrate, the cast time and global cooldown of your next three Destruction spells are reduced by 30%. Lasts 15 seconds.|r"
    }
},
{
    id = "spellShadowfury",
    name = "buttonSpellShadowfury",
    icon = "Interface/icons/spell_shadow_shadowfury",
    position = {770, -510},
    handler = "spellshadowfury",
    tooltips = {
        frFR = "|cffffffffFurie de l'ombre|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100La furie de l'ombre est libérée. Elle inflige 343 to 407 points de dégâts d'Ombre et étourdit tous les ennemis dans un rayon de 8 mètres pendant 3 seconds.|r",
        enUS = "|cffffffffShadowfury|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Shadowfury is unleashed, dealing 343 to 407 Shadow damage and stunning all enemies within 8 yards for 3 seconds.|r"
    }
},
{
    id = "spellEmpoweredImp",
    name = "buttonSpellEmpoweredImp",
    icon = "Interface/icons/ability_warlock_empoweredimp",
    position = {880, -510},
    handler = "spellempoweredimp",
    tooltips = {
        frFR = "|cffffffffDiablotin surpuissant|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les dégâts infligés par votre diablotin de 30%, et tous les coups critiques qu'il réussit ont 100%\nde chances d'augmenter les chances de coup critique de votre prochain sort de 100%.\nCet effet dure 8 seconds.|r",
        enUS = "|cffffffffEmpowered Imp|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the damage done by your Imp by 30%, and all critical strikes it lands have a 100%\nchance to increase your next spell's critical strike chance by 100%. Lasts for 8 seconds.|r"
    }
},
{
    id = "spellFireandBrimstone",
    name = "buttonSpellFireandBrimstone",
    icon = "Interface/icons/ability_warlock_fireandbrimstone",
    position = {990, -510},
    handler = "spellfireandbrimstone",
    tooltips = {
        frFR = "|cffffffffFeu et soufre|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les dégâts infligés par vos sorts Incinérer et Trait du chaos aux cibles affectées par votre Immolation de 10%,\net les chances de coup critique de votre sort Conflagration sont augmentées de 25%.|r",
        enUS = "|cffffffffFire and Brimstone|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Increases the damage dealt by your Incinerate and Chaos Bolt to targets affected by your Immolate by 10%, and increases the critical strike chance of your Conflagrate by 25%.|r"
    }
},
{
    id = "spellChaosBolt",
    name = "buttonSpellChaosBolt",
    icon = "Interface/icons/ability_warlock_chaosbolt",
    position = {1100, -510},
    handler = "spellchaosbolt",
    tooltips = {
        frFR = "|cffffffffTrait du chaos|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Lance un éclair de feu chaotique sur l'ennemi et lui inflige 942 à 1187 points de dégâts de Feu.\nOn ne peut pas résister à Trait du chaos, et il traverse tous les effets d'absorption.|r",
        enUS = "|cffffffffChaos Bolt|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequires|r |cff8787edWarlock|r\n|cffffd100Launches a chaotic fire bolt at the enemy, dealing 942 to 1187 Fire damage.\nChaos Bolt cannot be resisted and passes through all absorption effects.|r"
		}
	}
}


-- CreateSpellButton("buttonSpellImprovedShadowBolt", "Interface/icons/spell_shadow_shadowbolt", "|cffffffffTrait de l'ombre amélioré|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les dégâts infligés par votre sort Trait de l'ombre de 10%,\net votre Trait de l'ombre a également 100% de chances de rendre votre cible vulnérable aux dégâts des sorts,\nce qui augmente les chances de coup critique des sorts contre cette cible de 5%.\nL'effet dure 30 seconds.|r", "spellimprovedshadowbolt", 718, -240)
-- CreateSpellButton("buttonSpellBane", "Interface/icons/spell_shadow_deathpact", "|cffffffffFléau|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit le temps d'incantation de vos sorts Trait de l'ombre, Trait du chaos et Immolation de 0.5 sec. et Feu de l'âme de 2 sec.|r", "spellbane", 825, -240)
-- CreateSpellButton("buttonSpellAftermath", "Interface/icons/spell_fire_fire", "|cffffffffConséquences|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les dégâts périodiques infligés par votre Immolation de 6%, et votre Conflagration a 100% de chances d'hébéter la cible pendant 5 seconds.|r", "spellaftermath", 935, -240)
-- CreateSpellButton("buttonSpellMoltenSkin", "Interface/icons/ability_mage_moltenarmor", "|cffffffffPeau de la fournaise|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit tous les dégâts subis de 6%.|r", "spellmoltenskin", 1045, -240)
-- CreateSpellButton("buttonSpellCataclysm", "Interface/icons/spell_fire_windsofwoe", "|cffffffffCataclysme|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit le coût en mana de vos sorts de Destruction de 10%.|r", "spellcataclysm", 663, -293)
-- CreateSpellButton("buttonSpellDemonicPower", "Interface/icons/spell_fire_firebolt", "|cffffffffPuissance démoniaque|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit le temps de recharge du sort Fouet de la douleur de votre succube de 6 sec. et le temps d'incantation du sort Eclair de feu de votre Diablotin de 0.50 sec.|r", "spelldemonicpower", 770, -293)
-- CreateSpellButton("buttonSpellShadowburn", "Interface/icons/spell_shadow_scourgebuild", "|cffffffffBrûlure de l'ombre|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Frappe instantanément la cible et lui inflige 91 à 104 points de dégâts d'Ombre.\nSi la cible meurt dans les 5 seconds sous l'effet du sort Brûlure de l'ombre et rapporte de l'expérience ou de l'honneur,\nle lanceur gagne un Fragment d'âme.|r", "spellshadowburn", 990, -293)
-- CreateSpellButton("buttonSpellRuin", "Interface/icons/spell_shadow_shadowwordpain", "|cffffffffRuine|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 100% les points de dégâts supplémentaires infligés par les coups critiques de vos sorts de Destruction et le sort Eclair de feu de votre diablotin.|r", "spellruin", 1100, -293)
-- CreateSpellButton("buttonSpellIntensity", "Interface/icons/spell_fire_lavaspawn", "|cffffffffIntensité|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Réduit de 70% l'interruption causée par les attaques infligeant des dégâts pendant que vous incantez ou canalisez tout sort de Destruction.|r", "spellintensity", 718, -348)
-- CreateSpellButton("buttonSpellDestructiveReach", "Interface/icons/spell_shadow_corpseexplode", "|cffffffffAllonge de destruction|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 20% la portée de vos sorts de Destruction et réduit de 20% la menace générée par les sorts de Destruction.|r", "spelldestructivereach", 825, -348)
-- CreateSpellButton("buttonSpellImprovedSearingPain", "Interface/icons/spell_fire_soulburn", "|cffffffffDouleur brûlante améliorée|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 10% les chances d'infliger un coup critique avec votre sort Douleur brûlante.|r", "spellimprovedsearingpain", 935, -348)
-- CreateSpellButton("buttonSpellBacklash", "Interface/icons/spell_fire_playingwithfire", "|cffffffffContrecoup|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente vos chances d'infliger un coup critique avec les sorts de 3% supplémentaires et vous confère 25%\nde chances lorsque vous êtes touché par une attaque physique de réduire le temps d'incantation de votre prochain sort Trait de l'ombre ou Incinérer de 100%.\nCet effet dure 8 seconds et ne peut se produire plus d'une fois toutes les 8 secondes.|r", "spellbacklash", 1045, -348)
-- CreateSpellButton("buttonSpellImprovedImmolate", "Interface/icons/spell_fire_immolation", "|cffffffffImmolation améliorée|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les dégâts infligés par votre sort Immolation de 30%.|r", "spellimprovedimmolate", 663, -402)
-- CreateSpellButton("buttonSpellDevastation", "Interface/icons/spell_fire_flameshock", "|cffffffffDévastation|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente de 5% vos chances d'infliger un coup critique avec vos sorts de Destruction.|r", "spelldevastation", 770, -402)
-- CreateSpellButton("buttonSpellNetherProtection", "Interface/icons/spell_shadow_netherprotection", "|cffffffffProtection du Néant|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Après avoir été touché par un sort, vous avez 30% de chances de recevoir la Protection du Néant, qui réduit tous les dégâts de la même école de 30% pendant 8 seconds.|r", "spellnetherprotection", 880, -402)
-- CreateSpellButton("buttonSpellEmberstorm", "Interface/icons/spell_fire_selfdestruct", "|cffffffffTempête ardente|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les dégâts infligés par vos sorts de Feu de 15% et réduit le temps d'incantation de votre sort Incinérer de 0.25 sec.|r", "spellemberstorm", 990, -402)
-- CreateSpellButton("buttonSpellConflagrate", "Interface/icons/spell_fire_fireball", "|cffffffffConflagration|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Cause un effet d'Immolation ou d'Ombreflamme sur la cible ennemie pour lui infliger instantanément un montant de dégâts égal à\n69% de votre Immolation ou votre Ombreflamme et inflige 40% de dégâts supplémentaires en 6 seconds.|r", "spellconflagrate", 1100, -402)
-- CreateSpellButton("buttonSpellSoulLeech", "Interface/icons/spell_shadow_soulleech_3", "|cffffffffSuceur d'âme|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Confère à vos sorts Trait de l'ombre, Brûlure de l'ombre,\nTrait du chaos, Feu de l'âme, Incinérer, Douleur brûlante et Conflagration 30% de chances de vous rendre un montant de points de vie égal à 20% des dégâts infligés.|r", "spellsoulleech", 718, -456)
-- CreateSpellButton("buttonSpellPyroclasm", "Interface/icons/spell_fire_volcano", "|cffffffffPyroclasme|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Quand vous réussissez un coup critique avec Douleur brûlante ou Conflagration, les dégâts de vos sorts de Feu et d'Ombre sont augmentés de 6% pendant 10 seconds.|r", "spellpyroclasm", 825, -456)
-- CreateSpellButton("buttonSpellShadowandFlame", "Interface/icons/spell_shadow_shadowandflame", "|cffffffffOmbre et flammes|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Vos sorts Trait de l'ombre, Brûlure de l'ombre, Trait du chaos et Incinérer bénéficient\nde 20% supplémentaires des effets du bonus relatif aux dégâts des sorts.|r", "spellshadowandflame", 935, -456)
-- CreateSpellButton("buttonSpellImprovedSoulLeech", "Interface/icons/ability_warlock_improvedsoulleech", "|cffffffffSuceur d'âme amélioré|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100L'effet de votre Suceur d'âme rend également à vous-même et à votre démon invoqué un montant de mana égal à 2% du maximum de mana,\net il a 100% de chances de faire bénéficier jusqu'à 10 membres du groupe ou raid d'une régénération\nde mana égale à 1% du maximum de mana toutes les 5 sec. Dure 15 seconds.|r", "spellimprovedsoulleech", 1045, -456)
-- CreateSpellButton("buttonSpellBackdraft", "Interface/icons/ability_warlock_backdraft", "|cffffffffExplosion de fumées|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Quand vous lancez Conflagration, le temps d'incantation et le temps de recharge\nglobal de vos trois prochains sorts de Destruction est réduit de 30%.\nDure 15 seconds.|r", "spellbackdraft", 663, -510)
-- CreateSpellButton("buttonSpellShadowfury", "Interface/icons/spell_shadow_shadowfury", "|cffffffffFurie de l'ombre|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100La furie de l'ombre est libérée. Elle inflige 343 to 407 points de dégâts d'Ombre et étourdit tous les ennemis dans un rayon de 8 mètres pendant 3 seconds.|r", "spellshadowfury", 770, -510)
-- CreateSpellButton("buttonSpellEmpoweredImp", "Interface/icons/ability_warlock_empoweredimp", "|cffffffffDiablotin surpuissant|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les dégâts infligés par votre diablotin de 30%, et tous les coups critiques qu'il réussit ont 100%\nde chances d'augmenter les chances de coup critique de votre prochain sort de 100%.\nCet effet dure 8 seconds.|r", "spellempoweredimp", 880, -510)
-- CreateSpellButton("buttonSpellFireandBrimstone", "Interface/icons/ability_warlock_fireandbrimstone", "|cffffffffFeu et soufre|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Augmente les dégâts infligés par vos sorts Incinérer et Trait du chaos aux cibles affectées par votre Immolation de 10%,\net les chances de coup critique de votre sort Conflagration sont augmentées de 25%.|r", "spellfireandbrimstone", 990, -510)
-- CreateSpellButton("buttonSpellChaosBolt", "Interface/icons/ability_warlock_chaosbolt", "|cffffffffTrait du chaos|r\n|cffffffffTalent|r |cffff8000Destruction|r\n|cffffffffRequiert|r |cff8787edDémoniste|r\n|cffffd100Lance un éclair de feu chaotique sur l'ennemi et lui inflige 942 à 1187 points de dégâts de Feu.\nOn ne peut pas résister à Trait du chaos, et il traverse tous les effets d'absorption.|r", "spellchaosbolt", 1100, -510)

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

-- Créez le bouton Save à l'intérieur de la fenêtre frameTalentWarlock
local saveButton = CreateFrame("Button", "saveButton", frameTalentWarlock, "UIPanelButtonTemplate")
saveButton:SetSize(85, 25)
saveButton:SetPoint("BOTTOMRIGHT", buttonTalentWarlockClose, "BOTTOMLEFT", -185, 5) -- Place le bouton Save à gauche du bouton Close
saveButton:SetText(saveButtonText)

-- Fonction qui prend un screenshot quand le bouton est cliqué
saveButton:SetScript("OnClick", function()
    Screenshot()  -- Prendre un screenshot et l'enregistrer dans le dossier Screenshots du jeu
    print(screenshotMessage)  -- Affiche un message de confirmation en fonction de la locale
end)

-- Affiche l'UI des talents
--frameTalentWarlock:Show()

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

-- Créez le bouton Reset à l'intérieur de la fenêtre frameTalentWarlock
local buttonReset = CreateFrame("Button", "buttonReset", frameTalentWarlock, "UIPanelButtonTemplate")
buttonReset:SetSize(85, 25)
buttonReset:SetPoint("BOTTOMRIGHT", buttonTalentWarlockClose, "BOTTOMLEFT", -95, 5) -- Place le bouton Reset à gauche du bouton Reload
buttonReset:SetText(buttonResetText)

local function ResetTalents()
    -- Ajoutez ici la logique pour réinitialiser les talents du joueur
    AIO.Handle("TalentWarlockspell", "ResetTalents")
    resetButtonClicked = true -- Marquez le bouton Réinitialiser comme cliqué
end

buttonReset:SetScript("OnClick", ResetTalents)

-- Créez le bouton Reload à l'intérieur de la fenêtre frameTalentWarlock
local buttonReload = CreateFrame("Button", "buttonReload", frameTalentWarlock, "UIPanelButtonTemplate")
buttonReload:SetSize(85, 25)
buttonReload:SetPoint("BOTTOMRIGHT", buttonTalentWarlockClose, "BOTTOMLEFT", -5, 5) -- Place le bouton Reload à gauche du bouton Close
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
        frameTalentWarlock:Hide()
        buttonReload:Hide()
        PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
    else
        frameTalentWarlock:Show()
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
        frFR = "|cffffffffTalents|r |cff8787ed(Démoniste)|r\n\nL'éventail des talents disponibles\npour améliorer et spécialiser\nvotre personnage.",
        enUS = "|cffffffffTalents|r |cff8787ed(Warlock)|r\n\nThe range of available talents\nfor enhancing and specializing\nyour character."
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

-- Vérifier si le joueur est un Warlock avant de créer le bouton
local playerClass = select(2, UnitClass("player")) -- Obtenir la classe du joueur
if playerClass == "WARLOCK" then
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
WarlockHandlers.UpdateTalentCount = function(player, talentsAppris)
    if fontTalentWarlockFrameText then
        fontTalentWarlockFrameText:SetText(talentsAppris .. " / " .. MAX_TALENTS)
    end
end

-- Mise à jour des points de talent utilisés avec texte localisé
WarlockHandlers.UpdateTalentPointsUsed = function(player, pointsUsed, pointsBeforeReset)
    -- Utilisation du texte localisé pour les points avant réinitialisation
    print(string.format(GetLocalizedPointsBeforeResetText(), pointsBeforeReset))
end

-- Affichage des talents restants (items 338404 dans le sac)
WarlockHandlers.UpdateTalentItemCount = function(player, count)
    if fontTalentPointsRemainingText then
        fontTalentPointsRemainingText:SetText("|cFF8787EDTalents restants : " .. count .. "|r")
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
        fontTalentPointsRemainingText:SetText("|cFF8787EDTalents restants : " .. (count or 0) .. "|r")
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
if playerClass == "WARLOCK" then
    -- Surcharge OnHide pour synchroniser talentsWindowOpen quand Échap est pressé
    local _originalOnHide = frameTalentWarlock:GetScript("OnHide")
    frameTalentWarlock:SetScript("OnHide", function(self)
        talentsWindowOpen = false
        if _originalOnHide then _originalOnHide(self) end
    end)
    -- WoW appelle automatiquement Hide() sur les frames listées ici quand Échap est pressé
    tinsert(UISpecialFrames, "frameTalentWarlock")
end