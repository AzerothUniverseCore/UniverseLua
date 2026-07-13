local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local MonkHandlers = AIO.AddHandlers("TalentMonkspell", {})

function MonkHandlers.ShowTalentMonk(player)
    frameTalentMonk:Show()
    -- Redemande au serveur l’état visuel au cas où
    AIO.Handle("TalentMonkspell", "RequestLearnedTalents")
	-- Redemande le nombre de talents restants
    AIO.Handle("TalentMonkspell", "GetTalentItemCount")
end

local MAX_TALENTS = 60 -- Définition du nombre maximal de talents que le joueur peut apprendre

local OPEN_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_final_trait_unlocked.ogg"
local CLOSE_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_trait_refund_end.ogg"
local SPELL_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_80_azeritearmor_rotationends_02.ogg"

-- Attribute window
local frameTalentMonk = CreateFrame("Frame", "frameTalentMonk", UIParent)
frameTalentMonk:SetSize(1200, 650)
frameTalentMonk:SetMovable(true)
frameTalentMonk:EnableMouse(true)
frameTalentMonk:RegisterForDrag("LeftButton")
frameTalentMonk:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, -50) -- Adjust the X and Y coordinates
frameTalentMonk:SetBackdrop(
{
    -- bgFile = "interface/TalentFrame/talentsclassbackgroundmonk", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    bgFile = "interface/TalentFrame/Template/Class/Monk/talentsclassbackgroundmonk2", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedmonk", --Interface/DialogFrame/UI-DialogBox-Border
    edgeSize = 20,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})

-- Ajoutez la texture de l'icône du moine
local monkIcon = frameTalentMonk:CreateTexture("MonkIcon", "OVERLAY")
monkIcon:SetTexture("Interface\\TalentFrame\\Template\\Class\\Monk\\IconeMonk.blp")
monkIcon:SetSize(60, 60)
monkIcon:SetPoint("TOPLEFT", frameTalentMonk, "TOPLEFT", -10, 10)

-- Template Talent Frame

-- Ajoute une textureone pour l'image BLP
local textureone = frameTalentMonk:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
textureone:SetTexture("Interface\\TalentFrame\\Template\\Class\\Monk\\TalentFrameTemplate.blp")
textureone:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
textureone:SetPoint("TOPLEFT", frameTalentMonk, "TOPLEFT", -150, 130) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentMonk:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Ajoute une texturetwo pour l'image BLP
local texturetwo = frameTalentMonk:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
texturetwo:SetTexture("Interface\\TalentFrame\\Template\\Class\\Monk\\TalentFrameTemplateOriginal.blp")
texturetwo:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
texturetwo:SetPoint("TOPRIGHT", frameTalentMonk, "TOPRIGHT", 150, 130) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentMonk:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Drag & Drop
frameTalentMonk:SetScript("OnDragStart", frameTalentMonk.StartMoving)
frameTalentMonk:SetScript("OnHide", frameTalentMonk.StopMovingOrSizing)
frameTalentMonk:SetScript("OnDragStop", frameTalentMonk.StopMovingOrSizing)
frameTalentMonk:Hide()

-- Nouveau template d'arête
frameTalentMonk:SetBackdropBorderColor(0, 255, 150) -- Vert Jade

-- Close button
local buttonTalentMonkClose = CreateFrame("Button", "buttonTalentMonkClose", frameTalentMonk, "UIPanelCloseButton")
buttonTalentMonkClose:SetPoint("TOPRIGHT", -12, -12)
buttonTalentMonkClose:EnableMouse(true)
buttonTalentMonkClose:SetSize(32, 32)

local function CloseTalentWindow()
    frameTalentMonk:Hide()
    PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
end

-- Associez la fonction de fermeture au bouton de fermeture
buttonTalentMonkClose:SetScript("OnClick", CloseTalentWindow)

-- Title bar
local frameTalentMonkTitleBar = CreateFrame("Frame", "frameTalentMonkTitleBar", frameTalentMonk, nil)
frameTalentMonkTitleBar:SetSize(135, 25)
frameTalentMonkTitleBar:SetBackdrop(
{
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedmonk",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentMonkTitleBar:SetPoint("TOP", 0, 20)

local fontTalentMonkTitleText = frameTalentMonkTitleBar:CreateFontString("fontTalentMonkTitleText")
fontTalentMonkTitleText:SetFont("Fonts\\FRIZQT__.TTF", 13)
fontTalentMonkTitleText:SetSize(190, 5)
fontTalentMonkTitleText:SetPoint("CENTER", 0, 0)
fontTalentMonkTitleText:SetText("|cffFFC125Talents|r")

-- Détecte la langue du client
local locale = GetLocale() -- Retourne "enUS", "frFR", etc.

-- Table des traductions
local localizedTexts = {
    enUS = "|cffFFC125Monk|r",
    frFR = "|cffFFC125Moine|r",
}

-- Récupère le texte correspondant à la langue actuelle ou par défaut en anglais
local textToDisplay = localizedTexts[locale] or localizedTexts["enUS"]

local fontTalentMonkFrameText = frameTalentMonkTitleBar:CreateFontString("fontTalentMonkFrameText")
fontTalentMonkFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentMonkFrameText:SetSize(200, 5)
fontTalentMonkFrameText:SetPoint("TOPLEFT", frameTalentMonkTitleBar, "BOTTOMLEFT", -30, -35) -- Adjust the Y offset as needed
fontTalentMonkFrameText:SetText(textToDisplay)

-- Remplacez votre ligne existante pour la création du texte par celle-ci
local fontTalentMonkFrameText = frameTalentMonkTitleBar:CreateFontString("fontTalentMonkFrameText")
fontTalentMonkFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentMonkFrameText:SetSize(200, 5)
fontTalentMonkFrameText:SetPoint("TOPLEFT", frameTalentMonkTitleBar, "BOTTOMLEFT", -30, -60) -- Adjust the Y offset as needed
fontTalentMonkFrameText:SetText("0 / " .. MAX_TALENTS) -- Initialisez le texte avec 0 talents appris

-------------------------------------------------------------
-- Affichage "Talents restants" (item 338404 dans le sac)
-------------------------------------------------------------

local frameTalentPointsRemaining = CreateFrame("Frame", "frameTalentPointsRemaining", frameTalentMonk, nil)
frameTalentPointsRemaining:SetSize(220, 30)
frameTalentPointsRemaining:SetBackdrop({
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedmonk",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentPointsRemaining:SetPoint("BOTTOMRIGHT", frameTalentMonk, "BOTTOMRIGHT", -960, 10)

local fontTalentPointsRemainingText = frameTalentPointsRemaining:CreateFontString("fontTalentPointsRemainingText")
fontTalentPointsRemainingText:SetFont("Fonts\\FRIZQT__.TTF", 14)
fontTalentPointsRemainingText:SetSize(210, 20)
fontTalentPointsRemainingText:SetPoint("CENTER", 0, 0)
fontTalentPointsRemainingText:SetText("|cff00ff96Talents restants : 0|r")
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
MonkHandlers.UpdateLearnedTalents = function(player, learnedSpells)
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

    local button = CreateFrame("Button", name, frameTalentMonk, nil)
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
                AIO.Handle("TalentMonkspell", talentHandler, 1)
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

-- Table des sorts
local spells = {
{
    id = "spellPurifyingBrew",
    name = "buttonSpellPurifyingBrew",
    icon = "Interface/icons/inv_misc_beer_06",
    position = {225, -85},
    handler = "spellpurifyingbrew",
    tooltips = {
        frFR = "|cffffffffInfusion purificatrice|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Purifie instantanément tous les dégâts reportés.|r",
        enUS = "|cffffffffPurifying Brew|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Instantly purifies all damage over time effects.|r"
    }
},
{
    id = "spellKegSmash",
    name = "buttonSpellKegSmash",
    icon = "Interface/icons/achievement_brewery_2",
    position = {335, -85},
    handler = "spellkegsmash",
    tooltips = {
        frFR = "|cffffffffFracasse-tonneau|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous frappez la cible avec un tonneau de bière, infligeant entre 389 à 763 points de dégâts à tous les ennemis se trouvant à moins de 8 mètres.|r",
        enUS = "|cffffffffKeg Smash|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Strike the target with a keg of beer, dealing between 389 and 763 damage to all enemies within 8 yards.|r"
    }
},
{
    id = "spellAscension",
    name = "buttonSpellAscension",
    icon = "Interface/icons/ability_monk_ascension",
    position = {280, -140},
    handler = "spellascension",
    tooltips = {
        frFR = "|cffffffffAscension|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Augmente votre maximum de régénération d’énergie de 30%.|r",
        enUS = "|cffffffffAscension|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Increases your energy regeneration maximum by 30%.|r"
    }
},
{
    id = "spellGiftOx",
    name = "buttonSpellGiftOx",
    icon = "Interface/icons/ability_druid_giftoftheearthmother",
    position = {170, -140},
    handler = "spellgiftox",
    tooltips = {
        frFR = "|cffffffffDon du buffle|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Lorsque vous infligez des dégâts de mêlée, vous avez une chance d’invoquer à vos côtés une Sphère de soins visible de vous seul.\n\nQuand vous traversez cette Sphère de soins invoquée grâce au Don du buffle, vous récupérez 2581 à 7740 points de vie.|r",
        enUS = "|cffffffffGift of the Ox|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100When you deal melee damage, you have a chance to summon a healing sphere visible only to you.\n\nWhen you walk through this summoned healing sphere, you restore between 2581 and 7740 health.|r"
    }
},
{
    id = "spellPhysicsSphere",
    name = "buttonSpellPhysicsSphere",
    icon = "Interface/icons/ability_monk_healthsphere",
    position = {389, -140},
    handler = "spellphysicssphere",
    tooltips = {
        frFR = "|cffffffffSphère de dégâts|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous façonnez une sphère de dégâts à l'emplacement cible pendant 60 secondes.\nSi des ennemis sont proches de la sphère, ils l'absorbent et inflige 355 à 1112 points de dégâts.|r",
        enUS = "|cffffffffDamage Sphere|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100You create a damage sphere at the target location for 60 seconds.\nIf enemies are near the sphere, they absorb it, dealing 355 to 1112 damage.|r"
    }
},
{
    id = "spellFlyingMonk",
    name = "buttonSpellFlyingMonk",
    icon = "Interface/icons/ability_monk_roll",
    position = {115, -195},
    handler = "spellflyingmonk",
    tooltips = {
        frFR = "|cffffffffRoulade|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Effectuez une roulade sur une courte distance.|r",
        enUS = "|cffffffffFlying Monk|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Performs a roll over a short distance.|r"
    }
},
{
    id = "spellTigerHits",
    name = "buttonSpellTigerHits",
    icon = "Interface/icons/ability_monk_tigerpalm",
    position = {225, -195},
    handler = "spelltigerhits",
    tooltips = {
        frFR = "|cffffffffCoup du tigre|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Une attaque avec la paume de la main qui inflige de 100% points de dégâts.\nVous confère aussi Puissance du tigre, qui permet à vos attaques d’ignorer 30% de l’armure des ennemis pendant 20 seconds.|r",
        enUS = "|cffffffffTiger Palm|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100A palm strike dealing 100% weapon damage.\nAlso grants Tiger Power, allowing your attacks to ignore 30% of enemy armor for 20 seconds.|r"
    }
},
{
    id = "spellDampenHarm",
    name = "buttonSpellDampenHarm",
    icon = "Interface/icons/ability_monk_dampenharm",
    position = {335, -195},
    handler = "spelldampenharm",
    tooltips = {
        frFR = "|cffffffffAtténuation du mal|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous atténuez les dégâts des attaques les plus violentes contre vous.\nLes dégâts infligés par les 3 prochaines attaques dans les 45 secondes d’un montant égal ou supérieur à 20% de votre total de points de vie sont réduits de moitié.\n\nAtténuation du mal peut être lancé alors que vous êtes étourdi.|r",
        enUS = "|cffffffffDampen Harm|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100You mitigate damage from the most dangerous attacks against you.\nThe damage from the next 3 attacks within 45 seconds that deal 20% or more of your health is reduced by 50%.\n\nDampen Harm can be activated while stunned.|r"
    }
},
{
    id = "spellDizzyingHaze",
    name = "buttonSpellDizzyingHaze",
    icon = "Interface/icons/ability_monk_drunkenhaze",
    position = {442, -195},
    handler = "spelldizzyinghaze",
    tooltips = {
        frFR = "|cffffffffBrume vertigineuse|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous jetez un tonneau de votre meilleure bière, réduisant la vitesse de déplacement de tous les ennemis se trouvant à moins de 8 mètres de 50% pendant 15 seconds.\nGénère un haut niveau de menace.\n\nLes cibles affectées ont 3% de chances de voir leurs attaques en mêlée rater complètement et les toucher elles-mêmes en infligeant 1367 points de dégâts.|r",
        enUS = "|cffffffffDizzying Haze|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100You throw a barrel of your finest beer, reducing the movement speed of all enemies within 8 yards by 50% for 15 seconds.\nGenerates a high level of threat.\n\nAffected targets have a 3% chance to miss their melee attacks and hit themselves for 1367 damage.|r"
    }
},
{
    id = "spellFortifyingBrew",
    name = "buttonSpellFortifyingBrew",
    icon = "Interface/icons/ability_monk_fortifyingale_new",
    position = {388, -248},
    handler = "spellfortifyingbrew",
    tooltips = {
        frFR = "|cffffffffBoisson fortifiante|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Rend votre peau dure comme la pierre, ce qui augmente vos points de vie de 20% et réduit les dégâts que vous subissez de 20%.\nDure 20 secondes.|r",
        enUS = "|cffffffffFortifying Brew|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Makes your skin as tough as stone, increasing your health by 20% and reducing damage taken by 20%.\nLasts 20 seconds.|r"
    }
},
{
    id = "spellLegSweep",
    name = "buttonSpellLegSweep",
    icon = "Interface/icons/ability_monk_legsweep",
    position = {497, -250},
    handler = "spelllegsweep",
    tooltips = {
        frFR = "|cffffffffBalayement de jambe|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Renverse tous les ennemis à moins de 6 mètres et les étourdit pendant 5 secondes.|r",
        enUS = "|cffffffffLeg Sweep|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Knocks down all enemies within 6 yards and stuns them for 5 seconds.|r"
    }
},
{
    id = "spellGuard",
    name = "buttonSpellGuard",
    icon = "Interface/icons/ability_monk_guard",
    position = {280, -250},
    handler = "spellguard",
    tooltips = {
        frFR = "|cffffffffGarde|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous êtes en garde contre les prochaines attaques.\nAbsorbe 15180 points de dégâts pendant 30 secondes.\n\nLes soins que vous vous prodiguez sont augmentés de 30%.|r",
        enUS = "|cffffffffGuard|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100You are on guard for the next attacks.\nAbsorbs 15180 damage for 30 seconds.\n\nHealing you do is increased by 30%.|r"
    }
},
{
    id = "spellLegacyEmperor",
    name = "buttonSpellLegacyEmperor",
    icon = "Interface/icons/ability_monk_legacyoftheemperor",
    position = {170, -250},
    handler = "spelllegacyemperor",
    tooltips = {
        frFR = "|cffffffffHéritage de l'empereur|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous scandez les mots du dernier empereur, ce qui augmente la Force, l’Agilité et l’Intelligence de 5%.\n\nSi la cible est dans votre groupe ou raid, tous les membres du groupe ou raid sont affectés.|r",
        enUS = "|cffffffffLegacy of the Emperor|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100You chant the words of the last emperor, increasing Strength, Agility, and Intellect by 5%.\n\nIf the target is in your group or raid, all group or raid members are affected.|r"
    }
},
{
    id = "spellDetox",
    name = "buttonSpellDetox",
    icon = "Interface/icons/ability_rogue_imrovedrecuperate",
    position = {60, -250},
    handler = "spelldetox",
    tooltips = {
        frFR = "|cffffffffDétoxification|r\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Dissipe les maladies sur la cible alliée et supprime tous les effets néfastes de magie, de poison et de maladie.|r",
        enUS = "|cffffffffDetox|r\n|cffffffffTalent |cff70f37dMistweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Dispels diseases on the target and removes all harmful magic, poison, and disease effects.|r"
    }
},
{
    id = "spellProvoke",
    name = "buttonSpellProvoke",
    icon = "Interface/icons/ability_monk_provoke",
    position = {115, -305},
    handler = "spellprovoke",
    tooltips = {
        frFR = "|cffffffffPersiflage|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous raillez la cible, qui se précipite alors vers vous à une vitesse de déplacement augmentée de 50%.\n\nSi vous ciblez votre statue du buffle noir, ce sont tous les ennemis qui s’en trouvent à moins de 8 mètres qui sont persiflés.|r",
        enUS = "|cffffffffProvoke|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100You taunt the target, causing it to rush toward you at 50% increased movement speed.\n\nIf you target your Black Ox Statue, all enemies within 8 yards are taunted.|r"
    }
},
{
    id = "spellSummonBlackOxStatue",
    name = "buttonSpellSummonBlackOxStatue",
    icon = "Interface/icons/monk_ability_summonoxstatue",
    position = {225, -305},
    handler = "spellsummonblackoxstatue",
    tooltips = {
        frFR = "|cffffffffInvocation d’une statue du Buffle noir|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Invoque une statue du Buffle noir à l'emplacement ciblé.\nDure 15 minutes.\nUne seule statue peut être invoquée à la fois.|r",
        enUS = "|cffffffffSummon Black Ox Statue|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Summons a Black Ox Statue at the targeted location.\nLasts 15 minutes.\nOnly one statue can be summoned at a time.|r"
    }
},
{
    id = "spellEvilPrevention",
    name = "buttonSpellEvilPrevention",
    icon = "Interface/icons/monk_ability_avertharm",
    position = {335, -305},
    handler = "spellevilprevention",
    tooltips = {
        frFR = "|cffffffffPrévention du mal|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous redirigez vers vous 20% de tous les dégâts subis par les membres du groupe ou raid à moins de 10 mètres. Dure 6 secondes.\n\nLes dégâts que vous subissez ainsi peuvent être échelonnés.\nPrévention du mal est annulé si vos points de vie descendent à 10% ou moins.|r",
        enUS = "|cffffffffEvil Prevention|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Redirect 20% of all damage taken by party or raid members within 10 yards to you. Lasts 6 seconds.\n\nThe damage you take can be distributed.\nEvil Prevention is canceled if your health falls below 10%.|r"
    }
},
{
    id = "spellBreathFire",
    name = "buttonSpellBreathFire",
    icon = "Interface/icons/ability_monk_breathoffire",
    position = {442, -305},
    handler = "spellbreathfire",
    tooltips = {
        frFR = "|cffffffffSouffle de feu|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Souffle du feu et inflige 1784 points de dégâts à toutes les cibles devant vous à moins de 8 mètres.|r",
        enUS = "|cffffffffBreath of Fire|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Breath fire and deal 1784 damage to all targets in front of you within 8 yards.|r"
    }
},
{
    id = "spellParry",
    name = "buttonSpellParry",
    icon = "Interface/icons/ability_parry",
    position = {60, -358},
    handler = "spellparry",
    tooltips = {
        frFR = "|cffffffffParade|r\n|cffffffffTalent Général|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Donne une chance de parer les attaques de mêlée des ennemis.|r",
        enUS = "|cffffffffParry|r\n|cffffffffGeneral Talent|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Grants a chance to parry melee attacks from enemies.|r"
    }
},
{
    id = "spellThunderFocusTea",
    name = "buttonSpellThunderFocusTea",
    icon = "Interface/icons/ability_monk_thunderfocustea",
    position = {170, -358},
    handler = "spellthunderfocustea",
    tooltips = {
        frFR = "|cffffffffThé de concentration foudroyante|r\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous recevez une décharge d’énergie qui double les soins prodigués par votre prochaine Déferlante de brume\nou qui fait que votre prochaine Elévation réinitialise la durée de Brumes de rénovation sur toutes les cibles.\nDure 30 secondes.|r",
        enUS = "|cffffffffThunder Focus Tea|r\n|cffffffffTalent |cff70f37dMistweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100You receive a surge of energy that doubles the healing of your next Revival or causes your next Rise to reset the duration of Renewing Mists on all targets.\nLasts 30 seconds.|r"
    }
},
{
    id = "spellStealWeapon",
    name = "buttonSpellStealWeapon",
    icon = "Interface/icons/ability_warrior_disarm",
    position = {280, -358},
    handler = "spellstealweapon",
    tooltips = {
        frFR = "|cffffffffVol d'arme|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous projetez une lance à corde et récupérez les armes et le bouclier de la cible pendant 8 secondes.|r",
        enUS = "|cffffffffSteal Weapon|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Throw a rope spear to disarm the target, stealing their weapon and shield for 8 seconds.|r"
    }
},
{
    id = "spellFermentationElusiveInfusion",
    name = "buttonSpellFermentationElusiveInfusion",
    icon = "Interface/icons/ability_monk_elusiveale",
    position = {388, -358},
    handler = "spellfermentationelusiveinfusion",
    tooltips = {
        frFR = "|cffffffffFermentation : Infusion insaisissable|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Les coups critiques des attaques automatiques vous permettent d'accumuler jusqu'à 3 charges Décoction d'insaisissabilité.\nLe nombre de charges dépend de la vitesse de l'arme.\nL'effet s'empile jusqu'à 15 fois pour épuiser les charges.|r",
        enUS = "|cffffffffFermentation: Elusive Infusion|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Critical hits from auto attacks grant up to 3 charges of Elusive Brew.\nThe number of charges depends on weapon speed.\nStacks up to 15 times before depleting the charges.|r"
    }
},
{
    id = "spellIronskinBrew",
    name = "buttonSpellIronskinBrew",
    icon = "Interface/icons/ability_monk_ironskinbrew",
    position = {495, -358},
    handler = "spellironskinbrew",
    tooltips = {
        frFR = "|cffffffffInfusion peau-de-fer|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Augmente vos chances d’esquiver les attaques en mêlée et à distance de 30% pendant 1 seconde\npar charge d’Infusion insaisissable active, en annulant toutes les charges.|r",
        enUS = "|cffffffffIronskin Brew|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Increases your chance to dodge melee and ranged attacks by 30% per charge of active Elusive Brew for 1 second, consuming all charges.|r"
    }
},
{
    id = "spellClash",
    name = "buttonSpellClash",
    icon = "Interface/icons/ability_monk_clashingoxcharge",
    position = {115, -413},
    handler = "spellclash",
    tooltips = {
        frFR = "|cffffffffFracas|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Votre cible et vous-même vous précipitez l’un vers l’autre,\nvous heurtant à mi-chemin en étourdissant toutes les cibles à moins de 6 mètres pendant 4 secondes.|r",
        enUS = "|cffffffffClash|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Charge towards the target, colliding at the halfway point and stunning all enemies within 6 yards for 4 seconds.|r"
    }
},
{
    id = "spellMasterBrewerTraining",
    name = "buttonSpellMasterBrewerTraining",
    icon = "Interface/icons/spell_monk_brewmastertraining",
    position = {225, -413},
    handler = "spellmasterbrewertraining",
    tooltips = {
        frFR = "|cffffffffFormation de maître brasseur|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous devenez un maître brasseur accompli, ce qui amplifie trois de vos techniques.|r",
        enUS = "|cffffffffMaster Brewer Training|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100You become a master brewer, enhancing three of your abilities.|r"
    }
},
{
    id = "spellMasteryElusiveBrawler",
    name = "buttonSpellMasteryElusiveBrawler",
    icon = "Interface/icons/INV_Drink_05",
    position = {335, -413},
    handler = "spellmasteryelusivebrawler",
    tooltips = {
        frFR = "|cffffffffMaîtrise : Combattant insaisissable|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Augmente le montant de votre Report de 5% supplémentaires.|r",
        enUS = "|cffffffffMastery: Elusive Brawler|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Increases the amount of your Dodge by an additional 5%.|r"
    }
},
{
    id = "spellSwiftReflexes",
    name = "buttonSpellSwiftReflexes",
    icon = "Interface/icons/Ability_Hunter_Displacement",
    position = {442, -413},
    handler = "spellswiftreflexes",
    tooltips = {
        frFR = "|cffffffffRéflexes fulgurants|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Augmente vos chances de parer de 5%.|r",
        enUS = "|cffffffffSwift Reflexes|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Increases your chance to Parry by 5%.|r"
    }
},
{
    id = "spellDesperateMeasures",
    name = "buttonSpellDesperateMeasures",
    icon = "Interface/icons/Spell_Nature_ShamanRage",
    position = {60, -465},
    handler = "spelldesperatemeasures",
    tooltips = {
        frFR = "|cffffffffMesures désespérées|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Quand vous disposez de 35% de vos points de vie ou moins, votre Extraction du mal n’a pas de temps de recharge.|r",
        enUS = "|cffffffffDesperate Measures|r\n|cffffffffTalent |cfff49a01Master Brewmaster|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100When you are at 35% or less health, your Malady Extraction has no cooldown.|r"
    }
},
{
    id = "spellStandOff",
    name = "buttonSpellStandOff",
    icon = "Interface/icons/ability_monk_sparring",
    position = {170, -465},
    handler = "spellstandoff",
    tooltips = {
        frFR = "|cffffffffAffrontement|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Quand vous êtes attaqué en mêlée par un ennemi qui vous fait face,\nvous vous mettez à repousser ses attaques,\nce qui augmente vos chances de parer de 5% pendant 10 secondes.\nCet effet a un temps de recharge de 30 secondes.|r",
        enUS = "|cffffffffStand Off|r\n|cffffffffTalent |cff80fbfcWindwalker|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100When you are attacked in melee by an enemy facing you,\nyou begin to deflect their attacks,\nincreasing your chance to Parry by 5% for 10 seconds.\nThis effect has a 30 second cooldown.|r"
    }
},
{
    id = "spellMasteryComboStrikes",
    name = "buttonSpellMasteryComboStrikes",
    icon = "Interface/icons/trade_alchemy_potionb3",
    position = {280, -465},
    handler = "spellmasterycombostrikes",
    tooltips = {
        frFR = "|cffffffffMaîtrise : Fureur en bouteille|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Quand vous générez des charges d’Infusion Œil-du-tigre,\nvous avez 20% de chances de générer une charge supplémentaire.|r",
        enUS = "|cffffffffMastery: Bottle Fury|r\n|cffffffffTalent |cff80fbfcWindwalker|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100When you generate Tiger's Eye Brew charges,\nyou have a 20% chance to generate an additional charge.|r"
    }
},
{
    id = "spellMuscleMemory",
    name = "buttonSpellMuscleMemory",
    icon = "Interface/icons/Spell_Arcane_MindMastery",
    position = {388, -465},
    handler = "spellmusclememory",
    tooltips = {
        frFR = "|cffffffffMémoire musculaire|r\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Lorsque vous réussissez un Coup direct ou que vous infligez des dégâts à au moins 3 ennemis avec Coup tournoyant de la grue,\nvous bénéficiez de Mémoire musculaire, qui augmente les dégâts de votre prochaine Paume du tigre ou Frappe du voile noir de 4% et vous rend 150% de votre mana.|r",
        enUS = "|cffffffffMuscle Memory|r\n|cffffffffTalent |cff70f37dMistweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100When you score a Critical Hit or deal damage to at least 3 enemies with Rising Sun Kick,\nyou gain Muscle Memory, which increases the damage of your next Tiger Palm or Blackout Kick by 4% and restores 150% of your mana.|r"
    }
},
{
    id = "spellInternalMedicine",
    name = "buttonSpellInternalMedicine",
    icon = "Interface/icons/inv_emberweavebandage2",
    position = {495, -465},
    handler = "spellinternalmedicine",
    tooltips = {
        frFR = "|cffffffffMédecine interne|r\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Votre sort Détoxification dissipe aussi tous les effets magiques lors de son utilisation.|r",
        enUS = "|cffffffffInternal Medicine|r\n|cffffffffTalent |cff70f37dMistweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Your Detoxify spell also dispels all magical effects when used.|r"
    }
},
{
    id = "spellManaMeditation",
    name = "buttonSpellManaMeditation",
    icon = "Interface/icons/Spell_Nature_Sleep",
    position = {115, -520},
    handler = "spellmanameditation",
    tooltips = {
        frFR = "|cffffffffMéditation de mana|r\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Permet à 50% de votre régénération de mana due à l'Esprit de se poursuivre pendant le combat.|r",
        enUS = "|cffffffffMana Meditation|r\n|cffffffffTalent |cff70f37dMistweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Allows 50% of your Spirit-based mana regeneration to continue while in combat.|r"
    }
},
{
    id = "spellManaTea",
    name = "buttonSpellManaTea",
    icon = "Interface/icons/monk_ability_cherrymanatea",
    position = {225, -520},
    handler = "spellmanatea",
    tooltips = {
        frFR = "|cffffffffThé de mana|r\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Rend 4% de votre maximum de mana par cumul de thé de mana actif.\nLe thé de mana doit être canalisé, et dure 0.5 s par cumul.\nAnnuler la canalisation n’annule pas les cumuls.|r",
        enUS = "|cffffffffMana Tea|r\n|cffffffffTalent |cff70f37dMistweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Restores 4% of your maximum mana per active stack of Mana Tea.\nMana Tea must be channeled, and lasts for 0.5 seconds per stack.\nInterrupting the channel does not remove the stacks.|r"
    }
},
{
    id = "spellTeachingsMonastery",
    name = "buttonSpellTeachingsMonastery",
    icon = "Interface/icons/passive_monk_teachingsofmonastery",
    position = {335, -520},
    handler = "spellteachingsmonastery",
    tooltips = {
        frFR = "|cffffffffEnseignements du monastère|r\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100La voie du tisse-brume n’a plus de secrets pour vous, ce qui amplifie quatre de vos techniques.|r",
        enUS = "|cffffffffTeachings of the Monastery|r\n|cffffffffTalent |cff70f37dMistweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100The Way of the Mistweaver has no secrets for you, amplifying four of your techniques.|r"
    }
},
{
    id = "spellMasteryGiftSerpent",
    name = "buttonSpellMasteryGiftSerpent",
    icon = "Interface/icons/tradeskill_inscription_jadeserpent",
    position = {442, -520},
    handler = "spellmasterygiftserpent",
    tooltips = {
        frFR = "|cffffffffMaîtrise : Don du serpent|r\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Lorsque vous prodiguez des soins, vous avez 10% de chances d’invoquer une Sphère de soins près d’un allié blessé pendant 30 s.\nLes alliés qui traversent la sphère reçoivent 10103 points de vie.|r",
        enUS = "|cffffffffMastery: Gift of the Serpent|r\n|cffffffffTalent |cff70f37dMistweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100When you heal, you have a 10% chance to summon a Healing Sphere near a wounded ally for 30 seconds.\nAllies who pass through the sphere are healed for 10103 health.|r"
    }
},


-- Template 1

-- CreateSpellButton("buttonSpellPurifyingBrew", "Interface/icons/inv_misc_beer_06", "|cffffffffInfusion purificatrice|r\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Purifie instantanément tous les dégâts reportés.|r", "spellpurifyingbrew", 225, -85)
-- CreateSpellButton("buttonSpellKegSmash", "Interface/icons/achievement_brewery_2", "|cffffffffFracasse-tonneau\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous frappez la cible avec un tonneau de bière, infligeant entre 389 à 763 points de dégâts à tous les ennemis se trouvant à moins de 8 mètres.|r", "spellkegsmash", 335, -85)
-- CreateSpellButton("buttonSpellAscension", "Interface/icons/ability_monk_ascension", "|cffffffffAscension\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Augmente votre maximum de votre régénération d’énergie de 30%.|r", "spellascension", 280, -140)
-- CreateSpellButton("buttonSpellGiftOx", "Interface/icons/ability_druid_giftoftheearthmother", "|cffffffffDon du buffle\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Lorsque vous infligez des dégâts de mêlée,\nvous avez une chance d’invoquer à vos côtés une Sphère de soins visible de vous seul.\n\nQuand vous traversez cette Sphère de soins invoquée grâce au Don du buffle,\nvous récupérez 2581 à 7740 points de vie.|r", "spellgiftox", 170, -140)
-- CreateSpellButton("buttonSpellPhysicsSphere", "Interface/icons/ability_monk_healthsphere", "|cffffffffSphère de dégâts\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous façonnez une sphère de dégâts à l'emplacement cible pendant 60 seconds.\nSi des ennemis sont proche de la sphère, ils l'absorbent et inflige 355 à 1112 point de dégâts.|r", "spellphysicssphere", 389, -140)
-- CreateSpellButton("buttonSpellFlyingMonk", "Interface/icons/ability_monk_roll", "|cffffffffRoulade\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Effectuez une roulade sur une courte distance.|r", "spellflyingmonk", 115, -195)
-- CreateSpellButton("buttonSpellTigerHits", "Interface/icons/ability_monk_tigerpalm", "|cffffffffCoup du tigre\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Une attaque avec la paume de la main qui inflige de 100% points de dégâts.\nVous confère aussi Puissance du tigre, qui permet à vos attaques d’ignorer 30% de l’armure des ennemis pendant 20 seconds.|r", "spelltigerhits", 225, -195)
-- CreateSpellButton("buttonSpellDampenHarm", "Interface/icons/ability_monk_dampenharm", "|cffffffffAtténuation du mal\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous atténuez les dégâts des attaques les plus violentes contre vous.\nLes dégâts infligés par les 3 prochaines attaques dans les 45 seconds d’un montant égal ou supérieur à 20% de votre total de points de vie sont réduits de moitié.\n\nAtténuation du mal peut être lancé alors que vous êtes étourdi.|r", "spelldampenharm", 335, -195)
-- CreateSpellButton("buttonSpellDizzyingHaze", "Interface/icons/ability_monk_drunkenhaze", "|cffffffffBrume vertigineuse\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous jetez un tonneau de votre meilleure bière, réduisant la vitesse de déplacement de tous les ennemis se trouvant à moins de 8 mètres de 50% pendant 15 seconds.\nGénère un haut niveau de menace.\n\nLes cibles affectées ont 3% de chances de voir leurs attaques en mêlée rater complètement et les toucher elles-mêmes en infligeant 1367 points de dégâts.|r", "spelldizzyinghaze", 442, -195)
-- CreateSpellButton("buttonSpellFortifyingBrew", "Interface/icons/ability_monk_fortifyingale_new", "|cffffffffBoisson fortifiante\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Rend votre peau dure comme la pierre,\nce qui augmente vos points de vie de 20% et réduit les dégâts que vous subissez de 20%.\nDure 20 seconds.|r", "spellfortifyingbrew", 388, -248)
-- CreateSpellButton("buttonSpellLegSweep", "Interface/icons/ability_monk_legsweep", "|cffffffffBalayement de jambe\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Renverse tous les ennemis à moins de 6 mètres et les étourdit pendant 5 seconds.|r", "spelllegsweep", 495, -250)
-- CreateSpellButton("buttonSpellGuard", "Interface/icons/ability_monk_guard", "|cffffffffGarde\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous êtes en garde contre les prochaines attaques.\nAbsorbe 15180 points de dégâts pendant 30 seconds.\n\nLes soins que vous vous prodiguez sont augmentés de 30%.|r", "spellguard", 280, -250)
-- CreateSpellButton("buttonSpellLegacyEmperor", "Interface/icons/ability_monk_legacyoftheemperor", "|cffffffffHéritage de l'empereur\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous scandez les mots du dernier empereur, ce qui augmente la Force, l’Agilité et l’Intelligence de 5%.\n\nSi la cible est dans votre groupe ou raid, tous les membres du groupe ou raid sont affectés.|r", "spelllegacyemperor", 170, -250)
-- CreateSpellButton("buttonSpellDetox", "Interface/icons/ability_rogue_imrovedrecuperate", "|cffffffffDétoxification\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Dissipe les maladies sur la cible alliée et supprime tous les effets néfastes de magie, de poison et de maladie.|r", "spelldetox", 60, -250)
-- CreateSpellButton("buttonSpellProvoke", "Interface/icons/ability_monk_provoke", "|cffffffffPersiflage\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous raillez la cible,\nqui se précipite alors vers vous à une vitesse de déplacement augmentée de 50%.\n\nSi vous ciblez votre statue du buffle noir,\nce sont tous les ennemis qui s’en trouvent à moins de 8 mètres qui sont persiflés.|r", "spellprovoke", 115, -305)
-- CreateSpellButton("buttonSpellSummonBlackOxStatue", "Interface/icons/monk_ability_summonoxstatue", "|cffffffffInvocation d’une statue du Buffle noir\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Invoque une statue du Buffle noir à l'emplacement ciblé.\nDure 15 min.\nUne seule statue peut être invoquée à la fois.|r", "spellsummonblackoxstatue", 225, -305)
-- CreateSpellButton("buttonSpellEvilPrevention", "Interface/icons/monk_ability_avertharm", "|cffffffffPrévention du mal\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous redirigez vers vous 20% de tous les dégâts subis par les membres du groupe ou raid à moins de 10 mètres. Dure 6 seconds.\n\nLes dégâts que vous subissez ainsi peuvent être échelonnés.\nPrévention du mal est annulé si vos points de vie descendent à 10% ou moins.|r", "spellevilprevention", 335, -305)
-- CreateSpellButton("buttonSpellBreathFire", "Interface/icons/ability_monk_breathoffire", "|cffffffffSouffle de feu\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Souffle du feu et inflige 1784 points de dégâts à toutes les cibles devant vous à moins de 8 mètres.|r", "spellbreathfire", 442, -305)
-- CreateSpellButton("buttonSpellParry", "Interface/icons/ability_parry", "|cffffffffParade\n|cffffffffTalent Général|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Donne une chance de parer les attaques de mêlée des ennemis.|r", "spellparry", 60, -358)
-- CreateSpellButton("buttonSpellThunderFocusTea", "Interface/icons/ability_monk_thunderfocustea", "|cffffffffThé de concentration foudroyante\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous recevez une décharge d’énergie qui double les soins prodigués par votre prochaine Déferlante de brume\nou qui fait que votre prochaine Elévation réinitialise la durée de Brumes de rénovation sur toutes les cibles.\nDure 30 seconds.|r", "spellthunderfocustea", 170, -358)
-- CreateSpellButton("buttonSpellStealWeapon", "Interface/icons/ability_warrior_disarm", "|cffffffffVol d'arme\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous projetez une lance à corde et récupérez les armes et le bouclier de la cible pendant 8 seconds.|r", "spellstealweapon", 280, -358)
-- CreateSpellButton("buttonSpellFermentationElusiveInfusion", "Interface/icons/ability_monk_elusiveale", "|cffffffffFermentation : Infusion insaisissable\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Les coups critiques des attaques automatiques vous permettent d'accumuler jusqu'à 3 charges Décoction d'insaisissabilité.\nLe nombre de charges dépend de la vitesse de l'arme.\nL'effet s'empile jusqu'à 15 fois pour épuiser les charges.|r", "spellfermentationelusiveinfusion", 388, -358)
-- CreateSpellButton("buttonSpellIronskinBrew", "Interface/icons/ability_monk_ironskinbrew", "|cffffffffInfusion peau-de-fer\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Augmente vos chances d’esquiver les attaques en mêlée et à distance de 30% pendant 1 seconds\npar charge d’Infusion insaisissable active, en annulant toutes les charges.|r", "spellironskinbrew", 495, -358)
-- CreateSpellButton("buttonSpellClash", "Interface/icons/ability_monk_clashingoxcharge", "|cffffffffFracas\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Votre cible et vous-même vous précipitez l’un vers l’autre,\nvous heurtant à mi-chemin en étourdissant toutes les cibles à moins de 6 mètres pendant 4 seconds.|r", "spellclash", 115, -413)
-- CreateSpellButton("buttonSpellMasterBrewerTraining", "Interface/icons/spell_monk_brewmastertraining", "|cffffffffFormation de maître brasseur\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous devenez un maître brasseur accompli, ce qui amplifie trois de vos techniques.|r", "spellmasterbrewertraining", 225, -413)
-- CreateSpellButton("buttonSpellMasteryElusiveBrawler", "Interface/icons/INV_Drink_05", "|cffffffffMaîtrise : Combattant insaisissable\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Augmente le montant de votre Report de 5% supplémentaires.|r", "spellmasteryelusivebrawler", 335, -413)
-- CreateSpellButton("buttonSpellSwiftReflexes", "Interface/icons/Ability_Hunter_Displacement", "|cffffffffRéflexes fulgurants\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Augmente vos chances de parer de 5%.|r", "spellswiftreflexes", 442, -413)
-- CreateSpellButton("buttonSpellDesperateMeasures", "Interface/icons/Spell_Nature_ShamanRage", "|cffffffffMesures désespérées\n|cffffffffTalent |cfff49a01Maître brasseur|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Quand vous disposez de 35% de vos points de vie ou moins, votre Extraction du mal n’a pas de temps de recharge.|r", "spelldesperatemeasures", 60, -465)
-- CreateSpellButton("buttonSpellStandOff", "Interface/icons/ability_monk_sparring", "|cffffffffAffrontement\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Quand vous êtes attaqué en mêlée par un ennemi qui vous fait face,\nvous vous mettez à repousser ses attaques,\nce qui augmente vos chances de parer de 5% pendant 10 seconds.\nCet effet a un temps de recharge de 30 seconds.|r", "spellstandoff", 170, -465)
-- CreateSpellButton("buttonSpellMasteryComboStrikes", "Interface/icons/trade_alchemy_potionb3", "|cffffffffMaîtrise : Fureur en bouteille\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Quand vous générez des charges d’Infusion Œil-du-tigre,\nvous avez 20% de chances de générer une charge supplémentaire.|r", "spellmasterycombostrikes", 280, -465)
-- CreateSpellButton("buttonSpellMuscleMemory", "Interface/icons/Spell_Arcane_MindMastery", "|cffffffffMémoire musculaire\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Lorsque vous réussissez un Coup direct ou que vous infligez des dégâts à au moins 3 ennemis avec Coup tournoyant de la grue,\nvous bénéficiez de Mémoire musculaire, qui augmente les dégâts de votre prochaine Paume du tigre ou Frappe du voile noir de 4% et vous rend 150% de votre mana.|r", "spellmusclememory", 388, -465)
-- CreateSpellButton("buttonSpellInternalMedicine", "Interface/icons/inv_emberweavebandage2", "|cffffffffMédecine interne\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Votre sort Détoxification dissipe aussi tous les effets magiques lors de son utilisation.|r", "spellinternalmedicine", 495, -465)
-- CreateSpellButton("buttonSpellManaMeditation", "Interface/icons/Spell_Nature_Sleep", "|cffffffffMéditation de mana\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Permet à 50% de votre régénération de mana due à l'Esprit de se poursuivre pendant le combat.|r", "spellmanameditation", 115, -520)
-- CreateSpellButton("buttonSpellManaTea", "Interface/icons/monk_ability_cherrymanatea", "|cffffffffThé de mana\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Rend 4% de votre maximum de mana par cumul de thé de mana actif.\nLe thé de mana doit être canalisé, et dure 0.5 s par cumul.\nAnnuler la canalisation n’annule pas les cumuls.|r", "spellmanatea", 225, -520)
-- CreateSpellButton("buttonSpellTeachingsMonastery", "Interface/icons/passive_monk_teachingsofmonastery", "|cffffffffEnseignements du monastère\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100La voie du tisse-brume n’a plus de secrets pour vous, ce qui amplifie quatre de vos techniques.|r", "spellteachingsmonastery", 335, -520)
-- CreateSpellButton("buttonSpellMasteryGiftSerpent", "Interface/icons/tradeskill_inscription_jadeserpent", "|cffffffffMaîtrise : Don du serpent\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Lorsque vous prodiguez des soins, vous avez 10% de chances d’invoquer une Sphère de soins près d’un allié blessé pendant 30 s.\nLes alliés qui traversent la sphère reçoivent 10103 points de vie.|r", "spellmasterygiftserpent", 442, -520)


{
    id = "spellAdaptation",
    name = "buttonSpellAdaptation",
    icon = "Interface/icons/Ability_Rogue_CheatDeath",
    position = {645, -85},
    handler = "spelladaptation",
    tooltips = {
        frFR = "|cffffffffAdaptation|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Quand vous êtes désarmé, vos chances d’esquiver sont augmentées de 25% pendant 5 secondes.|r",
        enUS = "|cffffffffAdaptation|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100When disarmed, your dodge chance is increased by 25% for 5 seconds.|r"
    }
},
{
    id = "spellChiBarrage",
    name = "buttonSpellChiBarrage",
    icon = "Interface/icons/ability_monk_forcesphere",
    position = {750, -85},
    handler = "spellchibarrage",
    tooltips = {
        frFR = "|cffffffffBarrage de chi|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Déchaîne contre l’ennemi un barrage de chi qui inflige 1165 à 3436 points de dégâts de\nNature aux ennemis se trouvant à moins de 3 mètres de l’impact.|r",
        enUS = "|cffffffffChi Barrage|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Unleashes a barrage of chi at the enemy, dealing 1165 to 3436 Nature damage to enemies within 3 yards of the impact.|r"
    }
},
{
    id = "spellMonksLeap",
    name = "buttonSpellMonksLeap",
    icon = "Interface/icons/ability_monk_dpsstance",
    position = {860, -85},
    handler = "spellmonksleap",
    tooltips = {
        frFR = "|cffffffffBond du moine|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Bondit pour attaquer la cible ennemie.|r",
        enUS = "|cffffffffMonk's Leap|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Leaps to attack the enemy target.|r"
    }
},
{
    id = "spellNimbleBrew",
    name = "buttonSpellNimbleBrew",
    icon = "Interface/icons/spell_monk_nimblebrew",
    position = {970, -85},
    handler = "spellnimblebrew",
    tooltips = {
        frFR = "|cffffffffBreuvage de vivacité|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous débarrasse de tous les effets d’immobilisation,\nd’étourdissement, de peur et d'horreur et réduit la durée de futurs effets de ce type sur vous de 60% pendant 6 secondes.|r",
        enUS = "|cffffffffNimble Brew|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Removes all movement impairing, stun, fear, and horror effects and reduces the duration of future effects of this type by 60% for 6 seconds.|r"
    }
},
{
    id = "spellPunch",
    name = "buttonSpellPunch",
    icon = "Interface/icons/ability_monk_jab",
    position = {1077, -85},
    handler = "spellpunch",
    tooltips = {
        frFR = "|cffffffffCoup de poing|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous frappez la cible d’un coup direct et lui infligez 155 à 416 points de dégâts.|r",
        enUS = "|cffffffffPunch|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Strikes the target with a direct punch, dealing 155 to 416 damage.|r"
    }
},
{
    id = "spellBlackoutKick",
    name = "buttonSpellBlackoutKick",
    icon = "Interface/icons/ability_monk_roundhousekick",
    position = {1023, -140},
    handler = "spellblackoutkick",
    tooltips = {
        frFR = "|cffffffffFrappe du voile noir|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Assène un coup de pied chargé d'énergie sha infligeant 246 à 511 points de dégâts physiques à une cible ennemie.|r",
        enUS = "|cffffffffBlackout Kick|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Deliver a kick charged with Sha energy, dealing 246 to 511 physical damage to an enemy target.|r"
    }
},
{
    id = "spellRisingSunKick",
    name = "buttonSpellRisingSunKick",
    icon = "Interface/icons/ability_monk_risingsunkick",
    position = {915, -140},
    handler = "spellrisingsunkick",
    tooltips = {
        frFR = "|cffffffffCoup de pied du soleil levant|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous lancez un coup de pied vers le haut, ce qui inflige 1440 à 2917 points de dégâts à la cible et lui applique Blessures mortelles.|r",
        enUS = "|cffffffffRising Sun Kick|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Unleashes a rising kick that deals 1440 to 2917 damage to the target and applies Mortal Wounds.|r"
    }
},
{
    id = "spellExpelHarm",
    name = "buttonSpellExpelHarm",
    icon = "Interface/icons/ability_monk_expelharm",
    position = {805, -140},
    handler = "spellexpelharm",
    tooltips = {
        frFR = "|cffffffffExtraction du mal|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous rend instantanément de 297 à 609 points de vie et inflige instantanément\n des dégâts de Nature égaux à 50% de ce montant à un ennemi se trouvant à moins de 10 mètres.|r",
        enUS = "|cffffffffExpel Harm|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Instantly restores 297 to 609 health and deals Nature damage equal to 50% of that amount to an enemy within 10 yards.|r"
    }
},
{
    id = "spellCracklingJadeThunderstorm",
    name = "buttonSpellCracklingJadeThunderstorm",
    icon = "Interface/icons/ability_monk_cracklingjadelightning",
    position = {697, -140},
    handler = "spellcracklingjadethunderstorm",
    tooltips = {
        frFR = "|cffffffffOrage de jade crépitant|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Canalise un orage de jade pendant 5 secondes, envoyant des éclairs sur les ennemis toutes les 0.2 secondes.|r",
        enUS = "|cffffffffCrackling Jade Thunderstorm|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Channels a jade storm for 5 seconds, sending lightning strikes at enemies every 0.2 seconds.|r"
    }
},
{
    id = "spellDisable",
    name = "buttonSpellDisable",
    icon = "Interface/icons/ability_shockwave",
    position = {645, -195},
    handler = "spelldisable",
    tooltips = {
        frFR = "|cffffffffHandicap|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous entravez la cible, ce qui réduit sa vitesse de déplacement de 50%.\nLa durée de Handicap est réinitialisée si la cible reste à moins de 10 mètres du moine.\n\nL’utilisation de Handicap sur une cible déjà ralentie l’immobilise pendant 8 secondes.|r",
        enUS = "|cffffffffDisable|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Entraps the target, reducing their movement speed by 50%. The duration of Disable is reset if the target stays within 10 yards of the monk.\n\nUsing Disable on an already slowed target stuns them for 8 seconds.|r"
    }
},
{
    id = "spellRingPeace",
    name = "buttonSpellRingPeace",
    icon = "Interface/icons/spell_monk_ringofpeace",
    position = {750, -195},
    handler = "spellringpeace",
    tooltips = {
        frFR = "|cffffffffAnneau de paix|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Forme un sanctuaire autour d’une cible alliée, réduisant au silence et désarmant instantanément tous les ennemis pendant 4 secondes.\nDe plus, les ennemis qui attaquent ou lancent des sorts néfastes sur des alliés dans l’anneau de paix sont désarmés et réduits au silence pendant 4 secondes de plus.\nAnneau de paix dure 8 secondes.|r",
        enUS = "|cffffffffRing of Peace|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Creates a sanctuary around an allied target, silencing and disarming all enemies within for 4 seconds.\nAdditionally, enemies who attack or cast harmful spells on allies inside the Ring of Peace are disarmed and silenced for an additional 4 seconds.\nRing of Peace lasts 8 seconds.|r"
    }
},
{
    id = "spellLifeCocoon",
    name = "buttonSpellLifeCocoon",
    icon = "Interface/icons/ability_monk_chicocoon",
    position = {860, -195},
    handler = "spelllifecocoon",
    tooltips = {
        frFR = "|cffffffffCocon de vie|r\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Enveloppe la cible dans un cocon d’énergie chi, qui absorbe 81742 des dégâts\net augmente tous les soins périodiques reçus de 50%.\nDure 12 secondes.\nUtilisable quand vous êtes étourdi.|r",
        enUS = "|cffffffffLife Cocoon|r\n|cffffffffTalent |cff70f37dMistweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Wraps the target in a Chi energy cocoon, absorbing 81742 damage\nand increasing all periodic healing received by 50%.\nLasts 12 seconds.\nCan be used when stunned.|r"
    }
},
{
    id = "spellSpinningCraneKick",
    name = "buttonSpellSpinningCraneKick",
    icon = "Interface/icons/ability_monk_cranekick_new",
    position = {970, -195},
    handler = "spellspinningcranekick",
    tooltips = {
        frFR = "|cffffffffCoup tournoyant de la grue|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Tournoie rapidement, inflige des dégâts physiques autour de soi et\ndevient insensible aux enracinements et ralentissements pendant 5 secondes.|r",
        enUS = "|cffffffffSpinning Crane Kick|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Quickly spins around, dealing physical damage to enemies nearby and\nbecoming immune to roots and slows for 5 seconds.|r"
    }
},
{
    id = "spellWhiteTigerLegacy",
    name = "buttonSpellWhiteTigerLegacy",
    icon = "Interface/icons/ability_monk_prideofthetiger",
    position = {1077, -195},
    handler = "spellwhitetigerlegacy",
    tooltips = {
        frFR = "|cffffffffHéritage du tigre blanc|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous honorez l’héritage du Tigre blanc, ce qui augmente vos chances de coup critique de 5%.\n\nSi la cible est dans votre groupe ou raid, tous les membres du groupe ou raid sont affectés.|r",
        enUS = "|cffffffffWhite Tiger Legacy|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Honors the legacy of the White Tiger, increasing your critical strike chance by 5%.\n\nIf the target is in your group or raid, all members of the group or raid are affected.|r"
    }
},
{
    id = "spellSpearHandStrike",
    name = "buttonSpellSpearHandStrike",
    icon = "Interface/icons/ability_monk_spearhand",
    position = {697, -248},
    handler = "spellspearhandstrike",
    tooltips = {
        frFR = "|cffffffffPique de main|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous frappez la cible d’un coup direct à la gorge,\nce qui interrompt son incantation de sort et l’empêche de lancer un sort de la même école pendant 4 secondes.\n\nSi l’ennemi vous fait face, il est aussi réduit au silence pendant 2 secondes.|r",
        enUS = "|cffffffffSpear Hand Strike|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Strikes the target directly in the throat,\ninterrupting their spellcasting and preventing them from casting a spell of the same school for 4 seconds.\n\nIf the enemy is facing you, they are also silenced for 2 seconds.|r"
    }
},
{
    id = "spellDiffuseMagic",
    name = "buttonSpellDiffuseMagic",
    icon = "Interface/icons/spell_monk_diffusemagic",
    position = {805, -248},
    handler = "spelldiffusemagic",
    tooltips = {
        frFR = "|cffffffffDiffusion de la magie|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Réduit tous les dégâts des sorts subis de 90% et\nsupprime les effets magiques qui vous affectent en les renvoyant\nsi possible à leur auteur s’il se trouve dans un rayon de 40 mètres.\nDure 6 secondes.|r",
        enUS = "|cffffffffDiffuse Magic|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Reduces all magic damage taken by 90% and removes magical debuffs affecting you, returning them to their caster if they are within 40 yards.\nLasts 6 seconds.|r"
    }
},
{
    id = "spellFlyingSerpentKick",
    name = "buttonSpellFlyingSerpentKick",
    icon = "Interface/icons/ability_monk_flyingdragonkick",
    position = {915, -248},
    handler = "spellflyingserpentkick",
    tooltips = {
        frFR = "|cffffffffCoup du serpent volant|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous effectuez un Coup du serpent volant sur une courte distance.|r",
        enUS = "|cffffffffFlying Serpent Kick|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Performs a Flying Serpent Kick over a short distance.|r"
    }
},
{
    id = "spellZenMeditation",
    name = "buttonSpellZenMeditation",
    icon = "Interface/icons/ability_monk_zenmeditation",
    position = {1023, -248},
    handler = "spellzenmeditation",
    tooltips = {
        frFR = "|cffffffffMéditation zen|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Réduit tous les dégâts subis de 90% et redirige vers vous un maximum de 5 sorts de dégâts\nlancés contre des membres de votre groupe ou raid se trouvant à moins de 30 mètres.\nDure 8 secondes.\n\nSi vous êtes victime d’une attaque de mêlée,\nvotre méditation sera rompue et l'effet annulé.|r",
        enUS = "|cffffffffZen Meditation|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Reduces all damage taken by 90% and redirects up to 5 damaging spells cast on your group or raid members within 30 yards to you.\nLasts 8 seconds.\n\nIf you are hit by a melee attack,\nthe meditation will be interrupted and the effect cancelled.|r"
    }
},
{
    id = "spellSoothingMist",
    name = "buttonSpellSoothingMist",
    icon = "Interface/icons/ability_monk_soothingmists",
    position = {643, -302},
    handler = "spellsoothingmist",
    tooltips = {
        frFR = "|cffffffffBrume apaisante|r\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Rend à la cible 25752 points de vie en 8 secondes.|r",
        enUS = "|cffffffffSoothing Mist|r\n|cffffffffTalent |cff70f37dMistweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Restores 25752 health to the target over 8 seconds.|r"
    }
},
{
    id = "spellEnvelopingMist",
    name = "buttonSpellEnvelopingMist",
    icon = "Interface/icons/spell_monk_envelopingmist",
    position = {750, -302},
    handler = "spellenvelopingmist",
    tooltips = {
        frFR = "|cffffffffBrume enveloppante|r\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Rend 44898 points de vie à la cible en 6 secondes et\naugmente les soins de Brume apaisante reçus par la cible de 30%.|r",
        enUS = "|cffffffffEnveloping Mist|r\n|cffffffffTalent |cff70f37dMistweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Restores 44898 health to the target over 6 seconds and\nincreases the healing from Soothing Mist received by the target by 30%.|r"
    }
},
{
    id = "spellRenewingMist",
    name = "buttonSpellRenewingMist",
    icon = "Interface/icons/ability_monk_renewingmists",
    position = {860, -302},
    handler = "spellrenewingmist",
    tooltips = {
        frFR = "|cffffffffBrume de rénovation|r\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100La cible est enveloppée de brumes qui la soignent.\nLes brumes rendent 2739 points de vie toutes les 2 secondes pendant 18 secondes.|r",
        enUS = "|cffffffffRenewing Mist|r\n|cffffffffTalent |cff70f37dMistweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100The target is enveloped in mist, healing them.\nThe mist heals for 2739 health every 2 seconds for 18 seconds.|r"
    }
},
{
    id = "spellSurgingMist",
    name = "buttonSpellSurgingMist",
    icon = "Interface/icons/ability_monk_surgingmist",
    position = {970, -302},
    handler = "spellsurgingmist",
    tooltips = {
        frFR = "|cffffffffDéferlante de brume|r\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Canalise et rend 17540 points de vie à la cible.|r",
        enUS = "|cffffffffSurging Mist|r\n|cffffffffTalent |cff70f37dMistweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Channels and restores 17540 health to the target.|r"
    }
},
{
    id = "spellChiWave",
    name = "buttonSpellChiWave",
    icon = "Interface/icons/ability_monk_chiwave",
    position = {1077, -302},
    handler = "spellchiwave",
    tooltips = {
        frFR = "|cffffffffOnde de chi|r\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous émettez une Onde de chi qui se propage à travers vos alliés comme vos ennemis\net qui inflige 672 points de dégâts de Nature ou rend 4739 points de vie.\nL’onde rebondit jusqu’à 7 fois vers les cibles proches à moins de 25 mètres.|r",
        enUS = "|cffffffffChi Wave|r\n|cffffffffTalent |cff70f37dMistweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100You release a Chi Wave that travels through your allies and enemies,\ndealing 672 Nature damage or healing 4739 health.\nThe wave bounces up to 7 times to nearby targets within 25 yards.|r"
    }
},
{
    id = "spellSpinningFireBlossom",
    name = "buttonSpellSpinningFireBlossom",
    icon = "Interface/icons/ability_monk_explodingjadeblossom",
    position = {697, -358},
    handler = "spellspinningfireblossom",
    tooltips = {
        frFR = "|cffffffffFloraison de feu tournoyante|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Inflige de 153 à 310 points de dégâts de Feu\nà la première cible ennemie devant vous et à moins de 50 mètres.|r",
        enUS = "|cffffffffSpinning Fire Blossom|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Deals 153 to 310 Fire damage to the first enemy target in front of you and within 50 yards.|r"
    }
},
{
    id = "spellUplift",
    name = "buttonSpellUplift",
    icon = "Interface/icons/ability_monk_uplift",
    position = {805, -358},
    handler = "spelluplift",
    tooltips = {
        frFR = "|cffffffffElévation|r\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Rend 7907 points de vie à toutes les cibles sur lesquelles votre Brume de rénovation est active.|r",
        enUS = "|cffffffffUplift|r\n|cffffffffTalent |cff70f37dMistweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Restores 7907 health to all targets with your Renewing Mist active.|r"
    }
},
{
    id = "spellSummonJadeSerpentStatue",
    name = "buttonSpellSummonJadeSerpentStatue",
    icon = "Interface/icons/ability_monk_summonserpentstatue",
    position = {915, -358},
    handler = "spellsummonjadeserpentstatue",
    tooltips = {
        frFR = "|cffffffffInvocation d’une statue du Serpent de jade|r\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Invoque une statue du Serpent de jade à l'emplacement ciblé.\nDure 15 min.\nUne seule statue peut être invoquée à la fois.|r",
        enUS = "|cffffffffSummon Jade Serpent Statue|r\n|cffffffffTalent |cff70f37dMistweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Summons a Jade Serpent Statue at the targeted location.\nLasts 15 min.\nOnly one statue can be summoned at a time.|r"
    }
},

{
    id = "spellTouchKarma",
    name = "buttonSpellTouchKarma",
    icon = "Interface/icons/ability_monk_touchofkarma",
    position = {1023, -358},
    handler = "spelltouchkarma",
    tooltips = {
        frFR = "|cffffffffToucher du karma|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Tous les dégâts contre vous sont redirigés à la place vers la cible ennemie sous forme de dégâts de Nature en 6 secondes.\nLe montant redirigé ne peut pas dépasser votre total de points de vie. Dure 10 secondes.|r",
        enUS = "|cffffffffTouch of Karma|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100All damage taken is instead redirected to the enemy target as Nature damage over 6 seconds.\nThe redirected damage cannot exceed your total health. Lasts 10 seconds.|r"
    }
},

{
    id = "spellTouchDeath",
    name = "buttonSpellTouchDeath",
    icon = "Interface/icons/ability_monk_touchofdeath",
    position = {643, -410},
    handler = "spelltouchdeath",
    tooltips = {
        frFR = "|cffffffffToucher mortel|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous exploitez le point faible de la cible ennemie, ce qui la tue instantanément.|r",
        enUS = "|cffffffffTouch of Death|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100You exploit the enemy's weak point, instantly killing them.|r"
    }
},

{
    id = "spellTranscendance",
    name = "buttonSpellTranscendance",
    icon = "Interface/icons/monk_ability_transcendence",
    position = {750, -410},
    handler = "spelltranscendance",
    tooltips = {
        frFR = "|cffffffffTranscendance|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffffffRequiert|r |cffff0000Transcendance : Transfert|r\n|cffffd100Vous séparez votre corps et votre esprit, et vous abandonnez ce dernier pendant 15min.|r",
        enUS = "|cffffffffTranscendence|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffffffRequires|r |cffff0000Transcendence: Transfer|r\n|cffffd100You separate your body and spirit, abandoning the latter for 15 minutes.|r"
    }
},

{
    id = "spellTranscendanceBack",
    name = "buttonSpellTranscendanceBack",
    icon = "Interface/icons/spell_shaman_spectraltransformation",
    position = {860, -410},
    handler = "spelltranscendanceback",
    tooltips = {
        frFR = "|cffffffffTranscendance : Transfert|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffffffRequiert|r |cffff0000Transcendance|r\n|cffffd100Votre corps et votre esprit échangent de place.|r",
        enUS = "|cffffffffTranscendence: Transfer|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffffffRequires|r |cffff0000Transcendence|r\n|cffffd100Your body and spirit exchange places.|r"
    }
},
{
    id = "spellHealingSphere",
    name = "buttonSpellHealingSphere",
    icon = "Interface/icons/ability_monk_healthsphere",
    position = {970, -410},
    handler = "spellhealingsphere",
    tooltips = {
        frFR = "|cffffffffSphère de soins|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous façonnez une sphère de soins à partir de brumes guérisseuses à l’emplacement ciblé pendant 60 secondes.\nSi des alliés la traversent, ils l’absorbent et regagnent 1355 à 5122 points de vie.|r",
        enUS = "|cffffffffHealing Sphere|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100You shape a healing sphere from healing mists at the targeted location for 60 seconds.\nAllies that pass through it absorb it and heal for 1355 to 5122 health.|r"
    }
},

{
    id = "spellResuscitate",
    name = "buttonSpellResuscitate",
    icon = "Interface/icons/ability_druid_lunarguidance",
    position = {1077, -410},
    handler = "spellresuscitate",
    tooltips = {
        frFR = "|cffffffffRanimer|r\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Renvoie l'esprit du personnage ciblé dans son corps et le rappelle à la vie avec 65% de son maximum de points de vie et de mana.\nCe sort ne peut être lancé lorsque vous êtes en combat.|r",
        enUS = "|cffffffffResuscitate|r\n|cffffffffTalent |cff70f37dMistweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Returns the spirit of the targeted player to their body, reviving them with 65% of their maximum health and mana.\nThis spell cannot be cast while in combat.|r"
    }
},

{
    id = "spellParalysis",
    name = "buttonSpellParalysis",
    icon = "Interface/icons/ability_monk_paralysis",
    position = {697, -465},
    handler = "spellparalysis",
    tooltips = {
        frFR = "|cffffffffParalysie|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous faites se tétaniser les muscles de la cible, ce qui la stupéfie pendant 40 secondes.\nSi l’attaque est portée de derrière la cible, la durée augmente de 50%.\nSeule une cible à la fois peut être victime de Paralysie.\n\nTout dégât reçu annule l’effet.|r",
        enUS = "|cffffffffParalysis|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100You paralyze the target’s muscles, stunning them for 40 seconds.\nIf the attack is from behind the target, the duration is increased by 50%.\nOnly one target can be affected by Paralysis at a time.\n\nAny damage received will break the effect.|r"
    }
},

{
    id = "spellZenPilgrimage",
    name = "buttonSpellZenPilgrimage",
    icon = "Interface/icons/spell_monk_zenpilgrimage",
    position = {805, -465},
    handler = "spellzenpilgrimage",
    tooltips = {
        frFR = "|cffffffffPèlerinage zen|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Votre esprit abandonne votre corps et voyage jusqu’au pic de la Sérénité en Pandarie.|r",
        enUS = "|cffffffffZen Pilgrimage|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Your spirit travels to the Peak of Serenity in Pandaria, leaving your body behind.|r"
    }
},

{
    id = "spellFistsFury",
    name = "buttonSpellFistsFury",
    icon = "Interface/icons/monk_ability_fistoffury",
    position = {915, -465},
    handler = "spellfistsfury",
    tooltips = {
        frFR = "|cffffffffPoings de fureur|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Donne de violents coups de poing à la cible ennemie,\nlui infligeant des dégâts physiques toutes les 1 seconde pendant 4 secondes.|r",
        enUS = "|cffffffffFists of Fury|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Unleash a series of powerful punches on the enemy target, dealing physical damage every second for 4 seconds.|r"
    }
},
{
    id = "spellEnergizingElixir",
    name = "buttonSpellEnergizingElixir",
    icon = "Interface/icons/ability_monk_energizingwine",
    position = {1023, -465},
    handler = "spellenergizingelixir",
    tooltips = {
        frFR = "|cffffffffInfusion énergisante|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Régénère 60 points d’énergie en 6 secondes.\n\nNe peut être utilisé qu’en combat.|r",
        enUS = "|cffffffffEnergizing Elixir|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Restores 60 Energy over 6 seconds.\n\nCan only be used in combat.|r"
    }
},

{
    id = "spellTigersLust",
    name = "buttonSpellTigersLust",
    icon = "Interface/icons/ability_monk_tigerslust",
    position = {643, -520},
    handler = "spelltigerslust",
    tooltips = {
        frFR = "|cffffffffSoif du tigre|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Augmente la vitesse de déplacement d’une cible alliée de 70% pendant 6 sec et annule les effets de ralentissement et d’immobilisation subis.|r",
        enUS = "|cffffffffTiger's Lust|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Increases the movement speed of a friendly target by 70% for 6 seconds and removes movement impairing and immobilizing effects.|r"
    }
},

{
    id = "spellInvokeXuenWhiteTiger",
    name = "buttonSpellInvokeXuenWhiteTiger",
    icon = "Interface/icons/ability_monk_summontigerstatue",
    position = {750, -520},
    handler = "spellinvokexuenwhitetiger",
    tooltips = {
        frFR = "|cffffffffInvocation de Xuen, le Tigre blanc|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Invoque Xuen, le Tigre blanc auprès de vous.|r",
        enUS = "|cffffffffInvoke Xuen, the White Tiger|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Summons Xuen, the White Tiger to your location.|r"
    }
},

{
    id = "spellTigereyeBrew",
    name = "buttonSpellTigereyeBrew",
    icon = "Interface/icons/ability_monk_tigereyebrandy",
    position = {860, -520},
    handler = "spelltigereyebrew",
    tooltips = {
        frFR = "|cffffffffInfusion œil-du-tigre|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Augmente les dégâts infligés et les soins prodigués de 6% par charge d’Infusion œil-du-tigre active, en consommant jusqu’à 10 charges.\nDure 15 secondes.|r",
        enUS = "|cffffffffTiger's Eye Brew|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Increases damage dealt and healing done by 6% per active Tiger's Eye Brew charge, consuming up to 10 charges.\nLasts 15 seconds.|r"
    }
},

{
    id = "spellCombatConditioning",
    name = "buttonSpellCombatConditioning",
    icon = "Interface/icons/spell_misc_hellifrepvpcombatmorale",
    position = {970, -520},
    handler = "spellcombatconditioning",
    tooltips = {
        frFR = "|cffffffffConditionnement au combat|r\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Votre Frappe du voile noir inflige 20% de points de dégâts supplémentaires en 4 secondes si vous vous trouvez derrière la cible,\nou elle vous rend un montant de points de vie égal à 20% des dégâts infligés si vous êtes devant la cible.|r",
        enUS = "|cffffffffCombat Conditioning|r\n|cffffffffTalent |cff80fbfcWindsweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Your Blackout Strike deals 20% additional damage for 4 seconds if you are behind the target, or heals you for 20% of the damage dealt if you are in front of the target.|r"
    }
},
{
    id = "spellRevival",
    name = "buttonSpellRevival",
    icon = "Interface/icons/spell_shaman_blessingofeternals",
    position = {1077, -520},
    handler = "spellrevival",
    tooltips = {
        frFR = "|cffffffffRegain|r\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Rend instantanément 1355 à 5122 points de vie à tous les membres du groupe ou du raid\nse trouvant à moins de 100 mètres et les purifie de tout effet néfaste de magie, de poison, ou de maladie.|r",
        enUS = "|cffffffffRevival|r\n|cffffffffTalent |cff70f37dMistweaver|r\n|cffffffffRequires|r |cff00ff96Monk|r\n|cffffd100Instantly restores 1355 to 5122 health to all party or raid members within 100 yards and cleanses them of all harmful magic, poison, and disease effects.|r"
		}
	}
}



-- Template 2
-- CreateSpellButton("buttonSpellAdaptation", "Interface/icons/Ability_Rogue_CheatDeath", "|cffffffffAdaptation\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Quand vous êtes désarmé, vos chances d’esquiver sont augmentées de 25% pendant 5 seconds.|r", "spelladaptation", 645, -85)
-- CreateSpellButton("buttonSpellChiBarrage", "Interface/icons/ability_monk_forcesphere", "|cffffffffBarrage de chi\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Déchaîne contre l’ennemi un barrage de chi qui inflige 1165 à 3436 points de dégâts de\nNature aux ennemis se trouvant à moins de 3 mètres de l’impact.|r", "spellchibarrage", 750, -85)
-- CreateSpellButton("buttonSpellMonksLeap", "Interface/icons/ability_monk_dpsstance", "|cffffffffBond du moine\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Bondit pour attaquer la cible ennemie.|r", "spellmonksleap", 860, -85)
-- CreateSpellButton("buttonSpellNimbleBrew", "Interface/icons/spell_monk_nimblebrew", "|cffffffffBreuvage de vivacité\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous débarrasse de tous les effets d’immobilisation,\nd’étourdissement, de peur et d'horreur et réduit la durée de futurs effets de ce type sur vous de 60% pendant 6 seconds.|r", "spellnimblebrew", 970, -85)
-- CreateSpellButton("buttonSpellPunch", "Interface/icons/ability_monk_jab", "|cffffffffCoup de poing\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous frappez la cible d’un coup direct et lui infligez 155 à 416 points de dégâts.|r", "spellpunch", 1077, -85)
-- CreateSpellButton("buttonSpellBlackoutKick", "Interface/icons/ability_monk_roundhousekick", "|cffffffffFrappe du voile noir\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Assène un coup de pied chargé d'énergie sha infligeant 246 à 511 points de dégâts physiques à une cible ennemie.|r", "spellblackoutkick", 1023, -140)
-- CreateSpellButton("buttonSpellRisingSunKick", "Interface/icons/ability_monk_risingsunkick", "|cffffffffCoup de pied du soleil levant\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous lancez un coup de pied vers le haut, ce qui inflige 1440 à 2917 points de dégâts à la cible et lui applique Blessures mortelles.|r", "spellrisingsunkick", 915, -140)
-- CreateSpellButton("buttonSpellExpelHarm", "Interface/icons/ability_monk_expelharm", "|cffffffffExtraction du mal\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous rend instantanément de 297 à 609 points de vie et inflige instantanément\ndes dégâts de Nature égaux à 50% de ce montant à un ennemi se trouvant à moins de 10 mètres.|r", "spellexpelharm", 805, -140)
-- CreateSpellButton("buttonSpellCracklingJadeThunderstorm", "Interface/icons/ability_monk_cracklingjadelightning", "|cffffffffOrage de jade crépitant\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Canalise un orage de jade pendant 5 seconds, envoyant des éclairs sur les ennemis toutes les 0.2 s.|r", "spellcracklingjadethunderstorm", 697, -140)
-- CreateSpellButton("buttonSpellDisable", "Interface/icons/ability_shockwave", "|cffffffffHandicap\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous entravez la cible, ce qui réduit sa vitesse de déplacement de 50%.\nLa durée de Handicap est réinitialisée si la cible reste à moins de 10 mètres du moine.\n\nL’utilisation de Handicap sur une cible déjà ralentie l’immobilise pendant 8 seconds.|r", "spelldisable", 645, -195)
-- CreateSpellButton("buttonSpellRingPeace", "Interface/icons/spell_monk_ringofpeace", "|cffffffffAnneau de paix\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Forme un sanctuaire autour d’une cible alliée, réduisant au silence et désarmant instantanément tous les ennemis pendant 4 seconds.\nDe plus, les ennemis qui attaquent ou lancent des sorts néfastes sur des alliés dans l’anneau de paix sont désarmés et réduits au silence pendant 4 seconds de plus.\nAnneau de paix dure 8 seconds.|r", "spellringpeace", 750, -195)
-- CreateSpellButton("buttonSpellLifeCocoon", "Interface/icons/ability_monk_chicocoon", "|cffffffffCocon de vie\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Enveloppe la cible dans un cocon d’énergie chi, qui absorbe 81742 des dégâts\net augmente tous les soins périodiques reçus de 50%.\nDure 12 seconds.\nUtilisable quand vous êtes étourdi.|r", "spelllifecocoon", 860, -195)
-- CreateSpellButton("buttonSpellSpinningCraneKick", "Interface/icons/ability_monk_cranekick_new", "|cffffffffCoup tournoyant de la grue\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Tournoie rapidement, inflige des dégâts physiques autour de soi et\ndevient insensible aux enracinements et ralentissements pendant 5 seconds.|r", "spellspinningcranekick", 970, -195)
-- CreateSpellButton("buttonSpellWhiteTigerLegacy", "Interface/icons/ability_monk_prideofthetiger", "|cffffffffHéritage du tigre blanc\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous honorez l’héritage du Tigre blanc, ce qui augmente vos chances de coup critique de 5%.\n\nSi la cible est dans votre groupe ou raid, tous les membres du groupe ou raid sont affectés.|r", "spellwhitetigerlegacy", 1077, -195)
-- CreateSpellButton("buttonSpellSpearHandStrike", "Interface/icons/ability_monk_spearhand", "|cffffffffPique de main\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous frappez la cible d’un coup direct à la gorge,\nce qui interrompt son incantation de sort et l’empêche de lancer un sort de la même école pendant 4 seconds.\n\nSi l’ennemi vous fait face, il est aussi réduit au silence pendant 2 seconds.|r", "spellspearhandstrike", 697, -248)
-- CreateSpellButton("buttonSpellDiffuseMagic", "Interface/icons/spell_monk_diffusemagic", "|cffffffffDiffusion de la magie\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Réduit tous les dégâts des sorts subis de 90% et\nsupprime les effets magiques qui vous affectent en les renvoyant\nsi possible à leur auteur s’il se trouve dans un rayon de 40 mètres.\nDure 6 seconds.|r", "spelldiffusemagic", 805, -248)
-- CreateSpellButton("buttonSpellFlyingSerpentKick", "Interface/icons/ability_monk_flyingdragonkick", "|cffffffffCoup du serpent volant\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous effectuez un Coup du serpent volant sur une courte distance.|r", "spellflyingserpentkick", 915, -248)
-- CreateSpellButton("buttonSpellZenMeditation", "Interface/icons/ability_monk_zenmeditation", "|cffffffffMéditation zen\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Réduit tous les dégâts subis de 90% et redirige vers vous un maximum de 5 sorts de dégâts\nlancés contre des membres de votre groupe ou raid se trouvant à moins de 30 mètres.\nDure 8 seconds.\n\nSi vous êtes victime d’une attaque de mêlée,\nvotre méditation sera rompue et l'effet annulé.", "spellzenmeditation", 1023, -248)
-- CreateSpellButton("buttonSpellSoothingMist", "Interface/icons/ability_monk_soothingmists", "|cffffffffBrume apaisante\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Rend à la cible 25752 points de vie en 8 seconds.", "spellsoothingmist", 643, -302)
-- CreateSpellButton("buttonSpellEnvelopingMist", "Interface/icons/spell_monk_envelopingmist", "|cffffffffBrume enveloppante\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Rend 44898 points de vie à la cible en 6 seconds et\naugmente les soins de Brume apaisante reçus par la cible de 30%.", "spellenvelopingmist", 750, -302)
-- CreateSpellButton("buttonSpellRenewingMist", "Interface/icons/ability_monk_renewingmists", "|cffffffffBrume de rénovation\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100La cible est enveloppée de brumes qui la soignent.\nLes brumes rendent 2739 points de vie toutes les 2 s pendant 18 seconds.", "spellrenewingmist", 860, -302)
-- CreateSpellButton("buttonSpellSurgingMist", "Interface/icons/ability_monk_surgingmist", "|cffffffffDéferlante de brume\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Canalise et rend 17540 points de vie à la cible.", "spellsurgingmist", 970, -302)
-- CreateSpellButton("buttonSpellChiWave", "Interface/icons/ability_monk_chiwave", "|cffffffffOnde de chi\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous émettez une Onde de chi qui se propage à travers vos alliés comme vos ennemis\net qui inflige 672 points de dégâts de Nature ou rend 4739 points de vie.\nL’onde rebondit jusqu’à 7 fois vers les cibles proches à moins de 25 mètres.", "spellchiwave", 1077, -302)
-- CreateSpellButton("buttonSpellSpinningFireBlossom", "Interface/icons/ability_monk_explodingjadeblossom", "|cffffffffFloraison de feu tournoyante\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Inflige de 153 à 310 points de dégâts de Feu\nà la première cible ennemie devant vous et à moins de 50 mètres.", "spellspinningfireblossom", 697, -358)
-- CreateSpellButton("buttonSpellUplift", "Interface/icons/ability_monk_uplift", "|cffffffffElévation\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Rend 7907 points de vie à toutes les cibles sur lesquelles votre Brume de rénovation est active.", "spelluplift", 805, -358)
-- CreateSpellButton("buttonSpellSummonJadeSerpentStatue", "Interface/icons/ability_monk_summonserpentstatue", "|cffffffffInvocation d’une statue du Serpent de jade\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Invoque une statue du Serpent de jade à l'emplacement ciblé.\nDure 15 min.\nUne seule statue peut être invoquée à la fois.", "spellsummonjadeserpentstatue", 915, -358)
-- CreateSpellButton("buttonSpellTouchKarma", "Interface/icons/ability_monk_touchofkarma", "|cffffffffToucher du karma\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Tous les dégâts contre vous sont redirigés à la place vers la cible ennemie sous forme de dégâts de Nature en 6 seconds.\nLe montant redirigé ne peut pas dépasser votre total de points de vie. Dure 10 seconds.", "spelltouchkarma", 1023, -358)
-- CreateSpellButton("buttonSpellTouchDeath", "Interface/icons/ability_monk_touchofdeath", "|cffffffffToucher mortel\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous exploitez le point faible de la cible ennemie, ce qui la tue instantanément.", "spelltouchdeath", 643, -410)
-- CreateSpellButton("buttonSpellTranscendance", "Interface/icons/monk_ability_transcendence", "|cffffffffTranscendance\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffffffRequiert|r |cffff0000Transcendance : Transfert|r\n|cffffd100Vous séparez votre corps et votre esprit, et vous abandonnez ce dernier pendant 15min.", "spelltranscendance", 750, -410)
-- CreateSpellButton("buttonSpellTranscendanceBack", "Interface/icons/spell_shaman_spectraltransformation", "|cffffffffTranscendance : Transfert\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffffffRequiert|r |cffff0000Transcendance|r\n|cffffd100Votre corps et votre esprit échangent de place.", "spelltranscendanceback", 860, -410)
-- CreateSpellButton("buttonSpellHealingSphere", "Interface/icons/ability_monk_healthsphere", "|cffffffffSphère de soins\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous façonnez une sphère de soins à partir de brumes guérisseuses à l’emplacement ciblé pendant 60 seconds.\nSi des alliés la traversent, ils l’absorbent et regagnent 1355 à 5122 points de vie.", "spellhealingsphere", 970, -410)
-- CreateSpellButton("buttonSpellResuscitate", "Interface/icons/ability_druid_lunarguidance", "|cffffffffRanimer\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Renvoie l'esprit du personnage ciblé dans son corps et le rappelle à la vie avec 65% de son maximum de points de vie et de mana.\nCe sort ne peut être lancé lorsque vous êtes en combat.", "spellresuscitate", 1077, -410)
-- CreateSpellButton("buttonSpellParalysis", "Interface/icons/ability_monk_paralysis", "|cffffffffParalysie\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Vous faites se tétaniser les muscles de la cible, ce qui la stupéfie pendant 40 seconds.\nSi l’attaque est portée de derrière la cible, la durée augmente de 50%.\nSeule une cible à la fois peut être victime de Paralysie.\n\nTout dégât reçu annule l’effet.", "spellparalysis", 697, -465)
-- CreateSpellButton("buttonSpellZenPilgrimage", "Interface/icons/spell_monk_zenpilgrimage", "|cffffffffPèlerinage zen\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Votre esprit abandonne votre corps et voyage jusqu'au continent de Azeroth Universe.", "spellzenpilgrimage", 805, -465)
-- CreateSpellButton("buttonSpellFistsFury", "Interface/icons/monk_ability_fistoffury", "|cffffffffPoings de fureur\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Donne de violents coups de poing à la cible ennemie,\nlui infligeant des dégâts physiques toutes les 1 pendant 4 seconds.", "spellfistsfury", 915, -465)
-- CreateSpellButton("buttonSpellEnergizingElixir", "Interface/icons/ability_monk_energizingwine", "|cffffffffInfusion énergisante\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Régénère 60 points d’énergie en 6 seconds.\n\nNe peut être utilisé qu’en combat.", "spellenergizingelixir", 1023, -465)
-- CreateSpellButton("buttonSpellTigersLust", "Interface/icons/ability_monk_tigerslust", "|cffffffffSoif du tigre\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Augmente la vitesse de déplacement d’une cible alliée de 70% pendant 6 sec et annule les effets de ralentissement et d’immobilisation subis.", "spelltigerslust", 643, -520)
-- CreateSpellButton("buttonSpellInvokeXuenWhiteTiger", "Interface/icons/ability_monk_summontigerstatue", "|cffffffffInvocation de Xuen, le Tigre blanc\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Invoque Xuen, le Tigre blanc auprès de vous.", "spellinvokexuenwhitetiger", 750, -520)
-- CreateSpellButton("buttonSpellTigereyeBrew", "Interface/icons/ability_monk_tigereyebrandy", "|cffffffffInfusion œil-du-tigre\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Augmente les dégâts infligés et les soins prodigués de 6% par charge d’Infusion œil-du-tigre active, en consommant jusqu’à 10 charges.\nDure 15 seconds.", "spelltigereyebrew", 860, -520)
-- CreateSpellButton("buttonSpellCombatConditioning", "Interface/icons/spell_misc_hellifrepvpcombatmorale", "|cffffffffConditionnement au combat\n|cffffffffTalent |cff80fbfcMarche-vent|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Votre Frappe du voile noir inflige 20% de points de dégâts supplémentaires en 4 seconds si vous vous trouvez derrière la cible,\nou elle vous rend un montant de points de vie égal à 20% des dégâts infligés si vous êtes devant la cible.", "spellcombatconditioning", 970, -520)
-- CreateSpellButton("buttonSpellRevival", "Interface/icons/spell_shaman_blessingofeternals", "|cffffffffRegain\n|cffffffffTalent |cff70f37dTisse-brume|r\n|cffffffffRequiert|r |cff00ff96Moine|r\n|cffffd100Rend instantanément 1355 à 5122 points de vie à tous les membres du groupe ou du raid\nse trouvant à moins de 100 mètres et les purifie de tout effet néfaste de magie, de poison, ou de maladie.", "spellrevival", 1077, -520)


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

-- Créez le bouton Save à l'intérieur de la fenêtre frameTalentMonk
local saveButton = CreateFrame("Button", "saveButton", frameTalentMonk, "UIPanelButtonTemplate")
saveButton:SetSize(85, 25)
saveButton:SetPoint("BOTTOMRIGHT", buttonTalentMonkClose, "BOTTOMLEFT", -185, 5) -- Place le bouton Save à gauche du bouton Close
saveButton:SetText(saveButtonText)

-- Fonction qui prend un screenshot quand le bouton est cliqué
saveButton:SetScript("OnClick", function()
    Screenshot()  -- Prendre un screenshot et l'enregistrer dans le dossier Screenshots du jeu
    print(screenshotMessage)  -- Affiche un message de confirmation en fonction de la locale
end)

-- Affiche l'UI des talents
--frameTalentMonk:Show()

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

-- Créez le bouton Reset à l'intérieur de la fenêtre frameTalentMonk
local buttonReset = CreateFrame("Button", "buttonReset", frameTalentMonk, "UIPanelButtonTemplate")
buttonReset:SetSize(85, 25)
buttonReset:SetPoint("BOTTOMRIGHT", buttonTalentMonkClose, "BOTTOMLEFT", -95, 5) -- Place le bouton Reset à gauche du bouton Reload
buttonReset:SetText(buttonResetText)

local function ResetTalents()
    -- Ajoutez ici la logique pour réinitialiser les talents du joueur
    AIO.Handle("TalentMonkspell", "ResetTalents")
    resetButtonClicked = true -- Marquez le bouton Réinitialiser comme cliqué
end

buttonReset:SetScript("OnClick", ResetTalents)

-- Créez le bouton Reload à l'intérieur de la fenêtre frameTalentMonk
local buttonReload = CreateFrame("Button", "buttonReload", frameTalentMonk, "UIPanelButtonTemplate")
buttonReload:SetSize(85, 25)
buttonReload:SetPoint("BOTTOMRIGHT", buttonTalentMonkClose, "BOTTOMLEFT", -5, 5) -- Place le bouton Reload à gauche du bouton Close
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
        frameTalentMonk:Hide()
        buttonReload:Hide()
        PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
    else
        frameTalentMonk:Show()
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
        frFR = "|cffffffffTalents|r |cff00ff96(Moine)|r\n\nL'éventail des talents disponibles\npour améliorer et spécialiser\nvotre personnage.",
        enUS = "|cffffffffTalents|r |cff00ff96(Monk)|r\n\nThe range of available talents\nfor enhancing and specializing\nyour character."
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

-- Vérifier si le joueur est un Monk avant de créer le bouton
local playerClass = select(2, UnitClass("player")) -- Obtenir la classe du joueur
if playerClass == "MONK" then
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
MonkHandlers.UpdateTalentCount = function(player, talentsAppris)
    if fontTalentMonkFrameText then
        fontTalentMonkFrameText:SetText(talentsAppris .. " / " .. MAX_TALENTS)
    end
end

-- Mise à jour des points de talent utilisés avec texte localisé
MonkHandlers.UpdateTalentPointsUsed = function(player, pointsUsed, pointsBeforeReset)
    -- Utilisation du texte localisé pour les points avant réinitialisation
    print(string.format(GetLocalizedPointsBeforeResetText(), pointsBeforeReset))
end

-- Affichage des talents restants (items 338404 dans le sac)
MonkHandlers.UpdateTalentItemCount = function(player, count)
    if fontTalentPointsRemainingText then
        fontTalentPointsRemainingText:SetText("|cff00ff96Talents restants : " .. count .. "|r")
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
        fontTalentPointsRemainingText:SetText("|cff00ff96Talents restants : " .. (count or 0) .. "|r")
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
if playerClass == "MONK" then
    -- Surcharge OnHide pour synchroniser talentsWindowOpen quand Échap est pressé
    local _originalOnHide = frameTalentMonk:GetScript("OnHide")
    frameTalentMonk:SetScript("OnHide", function(self)
        talentsWindowOpen = false
        if _originalOnHide then _originalOnHide(self) end
    end)
    -- WoW appelle automatiquement Hide() sur les frames listées ici quand Échap est pressé
    tinsert(UISpecialFrames, "frameTalentMonk")
end