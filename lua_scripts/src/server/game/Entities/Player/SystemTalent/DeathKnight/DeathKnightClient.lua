local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local DeathknightHandlers = AIO.AddHandlers("TalentDeathknightspell", {})

function DeathknightHandlers.ShowTalentDeathknight(player)
    frameTalentDeathknight:Show()
    -- Redemande au serveur l’état visuel au cas où
    AIO.Handle("TalentDeathknightspell", "RequestLearnedTalents")
	-- Redemande le nombre de talents restants
    AIO.Handle("TalentDeathknightspell", "GetTalentItemCount")
end

local MAX_TALENTS = 60 -- Définition du nombre maximal de talents que le joueur peut apprendre

local OPEN_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_final_trait_unlocked.ogg"
local CLOSE_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_trait_refund_end.ogg"
local SPELL_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_80_azeritearmor_rotationends_02.ogg"

-- Attribute window
local frameTalentDeathknight = CreateFrame("Frame", "frameTalentDeathknight", UIParent)
frameTalentDeathknight:SetSize(1200, 650)
frameTalentDeathknight:SetMovable(true)
frameTalentDeathknight:EnableMouse(true)
frameTalentDeathknight:RegisterForDrag("LeftButton")
frameTalentDeathknight:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, -50) -- Adjust the X and Y coordinates
frameTalentDeathknight:SetBackdrop(
{
    -- bgFile = "interface/TalentFrame/talentsclassbackgroundDeathknight", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    bgFile = "interface/TalentFrame/Template/Class/Deathknight/talentsclassbackgrounddeathknight2", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    edgeFile = "interface/tooltips/ui-tooltip-border-corrupteddeathknight", --Interface/DialogFrame/UI-DialogBox-Border
    edgeSize = 20,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})

-- Ajoutez la texture de l'icône du Chevalier de la mort
local deathknightIcon = frameTalentDeathknight:CreateTexture("DeathknightIcon", "OVERLAY")
deathknightIcon:SetTexture("Interface\\TalentFrame\\Template\\Class\\Deathknight\\IconeDeathknight.blp")
deathknightIcon:SetSize(60, 60)
deathknightIcon:SetPoint("TOPLEFT", frameTalentDeathknight, "TOPLEFT", -10, 10)

-- Template Talent Frame

-- Ajoute une textureone pour l'image BLP
local textureone = frameTalentDeathknight:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
textureone:SetTexture("Interface\\TalentFrame\\Template\\Class\\Deathknight\\TalentFrameTemplate.blp")
textureone:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
textureone:SetPoint("TOPLEFT", frameTalentDeathknight, "TOPLEFT", -170, 140) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentDeathknight:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Ajoute une texturetwo pour l'image BLP
local texturetwo = frameTalentDeathknight:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
texturetwo:SetTexture("Interface\\TalentFrame\\Template\\Class\\Deathknight\\TalentFrameTemplateOriginal.blp")
texturetwo:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
texturetwo:SetPoint("TOPRIGHT", frameTalentDeathknight, "TOPRIGHT", 170, 140) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentDeathknight:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Drag & Drop
frameTalentDeathknight:SetScript("OnDragStart", frameTalentDeathknight.StartMoving)
frameTalentDeathknight:SetScript("OnHide", frameTalentDeathknight.StopMovingOrSizing)
frameTalentDeathknight:SetScript("OnDragStop", frameTalentDeathknight.StopMovingOrSizing)
frameTalentDeathknight:Hide()

-- Nouveau template d'arête
frameTalentDeathknight:SetBackdropBorderColor(197, 31, 35) -- Couleur rouge

-- Close button
local buttonTalentDeathknightClose = CreateFrame("Button", "buttonTalentDeathknightClose", frameTalentDeathknight, "UIPanelCloseButton")
buttonTalentDeathknightClose:SetPoint("TOPRIGHT", -12, -12)
buttonTalentDeathknightClose:EnableMouse(true)
buttonTalentDeathknightClose:SetSize(32, 32)

local function CloseTalentWindow()
    frameTalentDeathknight:Hide()
    PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
end

-- Associez la fonction de fermeture au bouton de fermeture
buttonTalentDeathknightClose:SetScript("OnClick", CloseTalentWindow)

-- Title bar
local frameTalentDeathknightTitleBar = CreateFrame("Frame", "frameTalentDeathknightTitleBar", frameTalentDeathknight, nil)
frameTalentDeathknightTitleBar:SetSize(135, 25)
frameTalentDeathknightTitleBar:SetBackdrop(
{
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corrupteddeathknight",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentDeathknightTitleBar:SetPoint("TOP", 0, 20)

local fontTalentDeathknightTitleText = frameTalentDeathknightTitleBar:CreateFontString("fontTalentDeathknightTitleText")
fontTalentDeathknightTitleText:SetFont("Fonts\\FRIZQT__.TTF", 13)
fontTalentDeathknightTitleText:SetSize(190, 5)
fontTalentDeathknightTitleText:SetPoint("CENTER", 0, 0)
fontTalentDeathknightTitleText:SetText("|cffFFC125Talents|r")

-- Détecte la langue du client
local locale = GetLocale() -- Retourne "enUS", "frFR", etc.

-- Table des traductions
local localizedTexts = {
    enUS = "|cffFFC125Death Knight|r",
    frFR = "|cffFFC125Chevalier de la mort|r",
}

-- Récupère le texte correspondant à la langue actuelle ou par défaut en anglais
local textToDisplay = localizedTexts[locale] or localizedTexts["enUS"]

local fontTalentDeathknightFrameText = frameTalentDeathknightTitleBar:CreateFontString("fontTalentDeathknightFrameText")
fontTalentDeathknightFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentDeathknightFrameText:SetSize(200, 5)
fontTalentDeathknightFrameText:SetPoint("TOPLEFT", frameTalentDeathknightTitleBar, "BOTTOMLEFT", -30, -35) -- Adjust the Y offset as needed
fontTalentDeathknightFrameText:SetText(textToDisplay)

-- Remplacez votre ligne existante pour la création du texte par celle-ci
local fontTalentDeathknightFrameText = frameTalentDeathknightTitleBar:CreateFontString("fontTalentDeathknightFrameText")
fontTalentDeathknightFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentDeathknightFrameText:SetSize(200, 5)
fontTalentDeathknightFrameText:SetPoint("TOPLEFT", frameTalentDeathknightTitleBar, "BOTTOMLEFT", -30, -60) -- Adjust the Y offset as needed
fontTalentDeathknightFrameText:SetText("0 / " .. MAX_TALENTS) -- Initialisez le texte avec 0 talents appris

-------------------------------------------------------------
-- Affichage "Talents restants" (item 338404 dans le sac)
-------------------------------------------------------------

local frameTalentPointsRemaining = CreateFrame("Frame", "frameTalentPointsRemaining", frameTalentDeathknight, nil)
frameTalentPointsRemaining:SetSize(220, 30)
frameTalentPointsRemaining:SetBackdrop({
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corrupteddeathknight",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentPointsRemaining:SetPoint("BOTTOMRIGHT", frameTalentDeathknight, "BOTTOMRIGHT", -960, 10)

local fontTalentPointsRemainingText = frameTalentPointsRemaining:CreateFontString("fontTalentPointsRemainingText")
fontTalentPointsRemainingText:SetFont("Fonts\\FRIZQT__.TTF", 14)
fontTalentPointsRemainingText:SetSize(210, 20)
fontTalentPointsRemainingText:SetPoint("CENTER", 0, 0)
fontTalentPointsRemainingText:SetText("|cFFC41F3BTalents restants : 0|r")
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
DeathknightHandlers.UpdateLearnedTalents = function(player, learnedSpells)
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

    local button = CreateFrame("Button", name, frameTalentDeathknight, nil)
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
                AIO.Handle("TalentDeathknightspell", talentHandler, 1)
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

-- Sang

-- Table des sorts
local spells = {
{
    id = "spellButchery",
    name = "buttonSpellButchery",
    icon = "Interface/icons/inv_axe_68",
    position = {100, -80},
    handler = "spellbutchery",
    tooltips = {
        frFR = "|cffffffffBoucherie|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Chaque fois que vous tuez un ennemi qui rapporte de l'expérience ou de l'honneur,\nvous générez jusqu'à 20 points de puissance runique.\nDe plus, vous générez 2 points de puissance runique toutes les 5 sec.\npendant que vous êtes en combat.|r",
        enUS = "|cffffffffButchery|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Each time you kill an enemy that yields experience or honor,\nyou generate up to 20 Runic Power.\nAdditionally, you generate 2 Runic Power every 5 seconds while in combat.|r"
    }
},
{
    id = "spellSubversion",
    name = "buttonSpellSubversion",
    icon = "Interface/icons/spell_deathknight_subversion",
    position = {205, -75},
    handler = "spellsubversion",
    tooltips = {
        frFR = "|cffffffffSubversion|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente les chances de coup critique de Frappe de sang, Frappe du Fléau, Frappe au cœur et Anéantissement de 9%, et réduit la menace générée lorsque vous êtes en Présence de sang ou impie de 25%.|r",
        enUS = "|cffffffffSubversion|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases the critical strike chance of Blood Strike, Scourge Strike, Heart Strike, and Obliterate by 9%, and reduces the threat generated while in Blood or Unholy Presence by 25%.|r"
    }
},
{
    id = "spellBladeBarrier",
    name = "buttonSpellBladeBarrier",
    icon = "Interface/icons/ability_upgrademoonglaive",
    position = {315, -75},
    handler = "spellbladebarrier",
    tooltips = {
        frFR = "|cffffffffBarrière de lames|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Chaque fois que vos runes de sang sont en cours de recharge, vous bénéficiez de l'effet Barrière de lames, qui réduit les dégâts subis de 5% pendant 10 seconds.|r",
        enUS = "|cffffffffBlade Barrier|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Whenever your Blood Runes are on cooldown, you gain the Blade Barrier effect, reducing damage taken by 5% for 10 seconds.|r"
    }
},
{
    id = "spellBladedArmor",
    name = "buttonSpellBladedArmor",
    icon = "Interface/icons/inv_shoulder_36",
    position = {418, -80},
    handler = "spellbladedarmor",
    tooltips = {
        frFR = "|cffffffffArmure tranchante|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente votre puissance d'attaque de 5 pour chaque tranche de 180 points de votre valeur d'armure.|r",
        enUS = "|cffffffffBladed Armor|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases your attack power by 5 for every 180 points of your armor value.|r"
    }
},
{
    id = "spellScentOfBlood",
    name = "buttonSpellScentofBlood",
    icon = "Interface/icons/ability_rogue_bloodyeye",
    position = {45, -130},
    handler = "spellscentofblood",
    tooltips = {
        frFR = "|cffffffffOdeur du sang|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vous avez 15% de chances après avoir esquivé, paré ou subi des dégâts directs de bénéficier de l'effet Odeur du sang, qui fait générer à vos 3 prochains coups en mêlée 10 points de puissance runique.|r",
        enUS = "|cffffffffScent of Blood|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100You have a 15% chance after dodging, parrying, or taking direct damage to gain the Scent of Blood effect, causing your next 3 melee hits to generate 10 Runic Power.|r"
    }
},
{
    id = "spellTwoHandedWeaponSpecialization",
    name = "buttonSpellTwoHandedWeaponSpecialization",
    icon = "Interface/icons/inv_sword_68",
    position = {150, -130},
    handler = "spelltwohandedweaponspecialization",
    tooltips = {
        frFR = "|cffffffffSpécialisation Arme 2M|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente les points de dégâts que vous infligez avec les armes de mêlée à deux mains de 4%.|r",
        enUS = "|cffffffffTwo-Handed Weapon Specialization|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases the damage you deal with two-handed melee weapons by 4%.|r"
    }
},
{
    id = "spellRuneTap",
    name = "buttonSpellRuneTap",
    icon = "Interface/icons/spell_deathknight_runetap",
    position = {260, -130},
    handler = "spellrunetap",
    tooltips = {
        frFR = "|cffffffffConnexion runique|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Convertit 1 Rune de sang en 10% de vos points de vie maximum.|r",
        enUS = "|cffffffffRune Tap|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Converts 1 Blood Rune into 10% of your maximum health.|r"
    }
},
{
    id = "spellDarkConviction",
    name = "buttonSpellDarkConviction",
    icon = "Interface/icons/spell_deathknight_darkconviction",
    position = {370, -130},
    handler = "spelldarkconviction",
    tooltips = {
        frFR = "|cffffffffSombre conviction|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente de 5% vos chances d'infliger un coup critique avec les armes, les sorts et les techniques.|r",
        enUS = "|cffffffffDark Conviction|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases your critical strike chance with weapons, spells, and abilities by 5%.|r"
    }
},
{
    id = "spellDeathRuneMastery",
    name = "buttonSpellDeathRuneMastery",
    icon = "Interface/icons/inv_sword_62",
    position = {475, -133},
    handler = "spelldeathrunemastery",
    tooltips = {
        frFR = "|cffffffffMaîtrise des runes de la mort|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Chaque fois que vous touchez avec Frappe de mort ou Anéantissement, il y a 100% de chances que les runes de givre et impie deviennent des runes de la mort lors de leur activation.\nLes runes de la mort comptent comme une rune de sang, de givre ou impie.|r",
        enUS = "|cffffffffDeath Rune Mastery|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Each time you hit with Death Strike or Obliterate, there is a 100% chance that your Frost and Unholy Runes will become Death Runes when activated.\nDeath Runes count as Blood, Frost, or Unholy Runes.|r"
    }
},
{
    id = "spellImprovedRuneTap",
    name = "buttonSpellImprovedRuneTap",
    icon = "Interface/icons/spell_deathknight_runetap",
    position = {96, -185},
    handler = "spellimprovedrunetap",
    tooltips = {
        frFR = "|cffffffffConnexion runique améliorée|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente de 100% les points de vie prodigués par Connexion runique et réduit son temps de recharge de 30 sec.|r",
        enUS = "|cffffffffImproved Rune Tap|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases the health provided by Rune Tap by 100% and reduces its cooldown by 30 seconds.|r"
    }
},
{
    id = "spellSpellDeflection",
    name = "buttonSpellSpellDeflection",
    icon = "Interface/icons/spell_deathknight_spelldeflection",
    position = {205, -185},
    handler = "spellspelldeflection",
    tooltips = {
        frFR = "|cffffffffDéviation de sort|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vous avez une chance égale à votre chance de parer que les sorts de dégâts directs vous infligent 45% de dégâts en moins.|r",
        enUS = "|cffffffffSpell Deflection|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100You have a chance equal to your parry chance to reduce the damage of direct damage spells by 45%.|r"
    }
},
{
    id = "spellVendetta",
    name = "buttonSpellVendetta",
    icon = "Interface/icons/spell_deathknight_vendetta",
    position = {315, -185},
    handler = "spellvendetta",
    tooltips = {
        frFR = "|cffffffffVendetta|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Chaque fois que vous tuez une cible qui rapporte de l'expérience ou de l'honneur, vous êtes soigné pour un montant égal à 6% au plus de votre maximum de points de vie.|r",
        enUS = "|cffffffffVendetta|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Each time you kill a target that yields experience or honor, you heal for up to 6% of your maximum health.|r"
    }
},
{
    id = "spellBloodyStrikes",
    name = "buttonSpellBloodyStrikes",
    icon = "Interface/icons/spell_deathknight_deathstrike",
    position = {422, -185},
    handler = "spellbloodystrikes",
    tooltips = {
        frFR = "|cffffffffFrappes sanglantes|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente les dégâts de Frappe de sang de 15% et de Frappe au coeur de 45%, en plus d'augmenter les dégâts de Furoncle sanglant de 30%.|r",
        enUS = "|cffffffffBloody Strikes|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases the damage of Blood Strike by 15%, Heart Strike by 45%, and Blood Boil by 30%.|r"
    }
},
{
    id = "spellVeteranOfTheThirdWar",
    name = "buttonSpellVeteranOfTheThirdWar",
    icon = "Interface/icons/spell_misc_warsongfocus",
    position = {527, -190},
    handler = "spellveteranofthethirdwar",
    tooltips = {
        frFR = "|cffffffffVétéran de la Troisième guerre|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente votre total de Force de 6%, votre Endurance de 3% et votre expertise de 6.|r",
        enUS = "|cffffffffVeteran of the Third War|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases your total Strength by 6%, Stamina by 3%, and expertise by 6.|r"
    }
},
{
    id = "spellMarkOfBlood",
    name = "buttonSpellMarkOfBlood",
    icon = "Interface/icons/ability_hunter_rapidkilling",
    position = {43, -240},
    handler = "spellmarkofblood",
    tooltips = {
        frFR = "|cffffffffMarque de sang|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Place une Marque de sang sur un ennemi.\nChaque fois que l'ennemi marqué inflige des dégâts à une cible, cette cible reçoit 4% de ses points de vie maximum.\nDure 20 seconds ou jusqu'à 20 coups.|r",
        enUS = "|cffffffffMark of Blood|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Places a Mark of Blood on an enemy.\nEach time the marked enemy deals damage to a target, that target is healed for 4% of its maximum health.\nLasts 20 seconds or up to 20 hits.|r"
    }
},
{
    id = "spellBloodyVengeance",
    name = "buttonSpellBloodyVengeance",
    icon = "Interface/icons/ability_backstab",
    position = {150, -240},
    handler = "spellbloodyvengeance",
    tooltips = {
        frFR = "|cffffffffVengeance sanglante|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Confère un bonus de 3% aux dégâts physiques que vous infligez pendant 30 seconds après avoir réussi un coup critique avec une arme, un sort ou une technique.\nL'effet est cumulable jusqu'à 3 fois.|r",
        enUS = "|cffffffffBloody Vengeance|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Grants a 3% bonus to physical damage you deal for 30 seconds after you land a critical strike with a weapon, spell, or ability.\nThis effect stacks up to 3 times.|r"
    }
},
{
    id = "spellAbominationsMight",
    name = "buttonSpellAbominationsMight",
    icon = "Interface/icons/ability_warrior_intensifyrage",
    position = {260, -240},
    handler = "spellabominationsmight",
    tooltips = {
        frFR = "|cffffffffPuissance de l'abomination|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente de 10% la puissance d'attaque des membres du groupe ou du raid se trouvant à moins de 100 mètres.\nAugmente également votre total de Force de 2%.|r",
        enUS = "|cffffffffAbomination's Might|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases the attack power of party and raid members within 100 yards by 10%.\nAlso increases your total Strength by 2%.|r"
    }
},
{
    id = "spellBloodWorms",
    name = "buttonSpellBloodWorms",
    icon = "Interface/icons/spell_shadow_soulleech",
    position = {368, -240},
    handler = "spellbloodworms",
    tooltips = {
        frFR = "|cffffffffVers de sang|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos coups portés avec des armes ont 9% de chances de faire produire à la cible de 2 à 4 vers de sang.\nLes vers de sang attaquent vos ennemis et vous rendent un montant de points de vie égal aux dégâts qu'ils infligent pendant 20 sec.\nou jusqu'à ce qu'ils soient tués.|r",
        enUS = "|cffffffffBlood Worms|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Your weapon hits have a 9% chance to spawn 2 to 4 blood worms near the target.\nThe blood worms attack your enemies and heal you for an amount equal to the damage they deal over 20 sec.\nor until killed.|r"
    }
},
{
    id = "spellUnholyFrenzy",
    name = "buttonSpellUnholyFrenzy",
    icon = "Interface/icons/spell_deathknight_bladedarmor",
    position = {478, -240},
    handler = "spellunholyfrenzy",
    tooltips = {
        frFR = "|cffffffffHystérie|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Plonge une unité alliée dans une frénésie meurtrière pendant 30 seconds.\nLa cible est enragée, ce qui augmente les dégâts physiques qu'elle inflige de 20%, mais elle subit aussi toutes les secondes un montant de dégâts égal à 1% de ses points de vie maximum.|r",
        enUS = "|cffffffffUnholy Frenzy|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Induces a friendly unit into a killing frenzy for 30 seconds.\nThe target is Enraged, increasing their physical damage dealt by 20%, but they take damage equal to 1% of their maximum health every second.|r"
    }
},
{
    id = "spellImprovedBloodPresence",
    name = "buttonSpellImprovedBloodPresence",
    icon = "Interface/icons/spell_deathknight_bloodpresence",
    position = {98, -293},
    handler = "spellimprovedbloodpresence",
    tooltips = {
        frFR = "|cffffffffPrésence de sang améliorée|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Quand vous êtes en Présence de givre ou impie, vous conservez 4% des soins de Présence de sang, et les soins qui vous sont prodigués sont augmentés de 10% en Présence de sang.|r",
        enUS = "|cffffffffImproved Blood Presence|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100While in Frost Presence or Unholy Presence, you retain 4% healing from Blood Presence, and healing received is increased by 10% while in Blood Presence.|r"
    }
},
{
    id = "spellImprovedDeathStrike",
    name = "buttonSpellImprovedDeathStrike",
    icon = "Interface/icons/spell_deathknight_butcher2",
    position = {205, -293},
    handler = "spellimproveddeathstrike",
    tooltips = {
        frFR = "|cffffffffFrappe de mort améliorée|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente de 30% les dégâts de votre Frappe de mort, de 6% ses chances de coup critique et de 50% les soins prodigués.|r",
        enUS = "|cffffffffImproved Death Strike|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases the damage of your Death Strike by 30%, its critical strike chance by 6%, and the healing it provides by 50%.|r"
    }
},
{
    id = "spellSuddenDoom",
    name = "buttonSpellSuddenDoom",
    icon = "Interface/icons/spell_shadow_painspike",
    position = {315, -293},
    handler = "spellsuddendoom",
    tooltips = {
        frFR = "|cffffffffMalédiction soudaine|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos Frappes de sang et Frappes au coeur ont 15% de chances de lancer un Voile mortel gratuit sur votre cible.|r",
        enUS = "|cffffffffSudden Doom|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Your Blood Strikes and Heart Strikes have a 15% chance to cast a free Death Coil at your target.|r"
    }
},
{
    id = "spellVampiricBlood",
    name = "buttonSpellVampiricBlood",
    icon = "Interface/icons/spell_shadow_lifedrain",
    position = {422, -293},
    handler = "spellvampiricblood",
    tooltips = {
        frFR = "|cffffffffSang vampirique|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Confère temporairement au chevalier de la mort 15% de son maximum de points de vie et augmente le montant de points de vie généré par les sorts et effets de 35% pendant 10 seconds.\nQuand l'effet se termine, ces points de vie sont perdus.|r",
        enUS = "|cffffffffVampiric Blood|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Temporarily grants the Death Knight 15% of their maximum health and increases healing generated by spells and effects by 35% for 10 seconds.\nWhen the effect ends, these health points are lost.|r"
    }
},
{
    id = "spellWillOfTheNecropolis",
    name = "buttonSpellWillOfTheNecropolis",
    icon = "Interface/icons/ability_creature_cursed_02",
    position = {527, -295},
    handler = "spellwillofthenecropolis",
    tooltips = {
        frFR = "|cffffffffVolonté de la nécropole|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Les dégâts qui vous feraient descendre à moins de 35% de vos points de vie ou que vous subissez alors que vous ne disposez que de 35% de vos points de vie sont réduits de 15%.|r",
        enUS = "|cffffffffWill of the Necropolis|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Damage that would reduce you below 35% of your health or that you take while at 35% health is reduced by 15%.|r"
    }
},
{
    id = "spellHeartStrike",
    name = "buttonSpellHeartStrike",
    icon = "Interface/icons/inv_weapon_shortblade_40",
    position = {43, -350},
    handler = "spellheartstriks",
    tooltips = {
        frFR = "|cffffffffFrappe au coeur|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Frappe instantanément la cible et son allié le plus proche, infligeant 72% des dégâts de l'arme plus 247 à la cible principale et 36% des dégâts de l'arme plus 123 à la cible secondaire.\nChaque cible subit 10% de dégâts supplémentaires pour chacune de vos maladies actives sur elle, et la vitesse de déplacement est réduite de 50% pendant 10 seconds.|r",
        enUS = "|cffffffffHeart Strike|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Instantly strikes the target and its nearest ally, dealing 72% weapon damage plus 247 to the primary target and 36% weapon damage plus 123 to the secondary target.\nEach target takes 10% additional damage for each of your active diseases on them, and their movement speed is reduced by 50% for 10 seconds.|r"
    }
},
{
    id = "spellMightOfMograine",
    name = "buttonSpellMightofMograine",
    icon = "Interface/icons/spell_deathknight_classicon",
    position = {260, -350},
    handler = "spellmightofmograine",
    tooltips = {
        frFR = "|cffffffffPuissance de Mograine|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente de 45% le bonus aux dégâts des coups critiques infligés avec vos techniques Furoncle sanglant, Frappe de sang, Frappe de mort et Frappe au cœur.|r",
        enUS = "|cffffffffMight of Mograine|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases the critical strike damage bonus of your Blood Boil, Blood Strike, Death Strike, and Heart Strike abilities by 45%.|r"
    }
},
{
    id = "spellBloodGorged",
    name = "buttonSpellBloodGorged",
    icon = "Interface/icons/spell_nature_reincarnation",
    position = {150, -350},
    handler = "spellbloodgorged",
    tooltips = {
        frFR = "|cffffffffGorgé de sang|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Quand vous disposez de plus de 75% de vos points de vie, vous infligez 10% de dégâts supplémentaires.\nDe plus, vos attaques ignorent jusqu'à 10% de l'armure de votre adversaire à tout moment.|r",
        enUS = "|cffffffffBlood Gorged|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100When you have more than 75% of your health, you deal 10% additional damage.\nAdditionally, your attacks ignore up to 10% of your opponent's armor at all times.|r"
    }
},
{
    id = "spellDancingRuneWeapon",
    name = "buttonSpellDancingRuneWeapon",
    icon = "Interface/icons/inv_sword_07",
    position = {368, -350},
    handler = "spelldancingruneweapon",
    tooltips = {
        frFR = "|cffffffffArme runique dansante|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Invoque une seconde arme runique qui combat toute seule pendant 12 seconds, en effectuant les mêmes attaques que le chevalier de la mort mais en infligeant 50% de dégâts de moins que lui.|r",
        enUS = "|cffffffffDancing Rune Weapon|r\n|cffffffffTalent|r |cffd20000Blood|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Summons a second rune weapon that fights on its own for 12 seconds, performing the same attacks as the Death Knight but dealing 50% less damage.|r"
    }
},


-- CreateSpellButton("buttonSpellButchery", "Interface/icons/inv_axe_68", "|cffffffffBoucherie|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Chaque fois que vous tuez un ennemi qui rapporte de l'expérience ou de l'honneur,\nvous générez jusqu'à 20 points de puissance runique.\nDe plus, vous générez 2 points de puissance runique toutes les 5 sec.\npendant que vous êtes en combat.|r", "spellbutchery", 100, -80)
-- CreateSpellButton("buttonSpellSubversion", "Interface/icons/spell_deathknight_subversion", "|cffffffffSubversion|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente les chances de coup critique de Frappe de sang, Frappe du Fléau, Frappe au coeur et Anéantissement de 9%, et réduit la menace générée lorsque vous êtes en Présence de sang ou impie de 25%.|r", "spellbubversion", 205, -75)
-- CreateSpellButton("buttonSpellBladeBarrier", "Interface/icons/ability_upgrademoonglaive", "|cffffffffBarrière de lames|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Chaque fois que vos runes de sang sont en cours de recharge, vous bénéficiez de l'effet Barrière de lames, qui réduit les dégâts subis de 5% pendant 10 seconds.|r", "spellbladebarrier", 315, -75)
-- CreateSpellButton("buttonSpellBladedArmor", "Interface/icons/inv_shoulder_36", "|cffffffffArmure tranchante|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente votre puissance d'attaque de 5 pour chaque tranche de 180 points de votre valeur d'armure.|r", "spellbladedarmor", 418, -80)
-- CreateSpellButton("buttonSpellScentofBlood", "Interface/icons/ability_rogue_bloodyeye", "|cffffffffOdeur du sang|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vous avez 15% de chances après avoir esquivé, paré ou subi des dégâts directs de bénéficier de l'effet Odeur du sang, qui fait générer à vos 3 prochains coups en mêlée 10 points de puissance runique.|r", "spellscentofblood", 45, -130)
-- CreateSpellButton("buttonSpellTwoHandedWeaponSpecialization", "Interface/icons/inv_sword_68", "|cffffffffSpécialisation Arme 2M|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente les points de dégâts que vous infligez avec les armes de mêlée à deux mains de 4%.|r", "spelltwohandedweaponspecialization", 150, -130)
-- CreateSpellButton("buttonSpellRuneTap", "Interface/icons/spell_deathknight_runetap", "|cffffffffConnexion runique|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Convertit 1 Rune de sang en 10% de vos points de vie maximum.|r", "spellrunetap", 260, -130)
-- CreateSpellButton("buttonSpellDarkConviction", "Interface/icons/spell_deathknight_darkconviction", "|cffffffffSombre conviction|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente de 5% vos chances d'infliger un coup critique avec les armes, les sorts et les techniques.|r", "spelldarkconviction", 370, -130)
-- CreateSpellButton("buttonSpellDeathRuneMastery", "Interface/icons/inv_sword_62", "|cffffffffMaîtrise des runes de la mort|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Chaque fois que vous touchez avec Frappe de mort ou Anéantissement, il y a 100% de chances que les runes de givre et impie deviennent des runes de la mort lors de leur activation.\nLes runes de la mort comptent comme une rune de sang, de givre ou impie.|r", "spelldeathrunemastery", 475, -133)
-- CreateSpellButton("buttonSpellImprovedRuneTap", "Interface/icons/spell_deathknight_runetap", "|cffffffffConnexion runique améliorée|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente de 100% les points de vie prodigués par Connexion runique et réduit son temps de recharge de 30 sec.|r", "spellimprovedrunetap", 96, -185)
-- CreateSpellButton("buttonSpellSpellDeflection", "Interface/icons/spell_deathknight_spelldeflection", "|cffffffffDéviation de sort|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vous avez une chance égale à votre chance de parer que les sorts de dégâts directs vous infligent 45% de dégâts en moins.|r", "spellspelldeflection", 205, -185)
-- CreateSpellButton("buttonSpellVendetta", "Interface/icons/spell_deathknight_vendetta", "|cffffffffVendetta|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Chaque fois que vous tuez une cible qui rapporte de l'expérience ou de l'honneur, vous êtes soigné pour un montant égal à 6% au plus de votre maximum de points de vie.|r", "spellvendetta", 315, -185)
-- CreateSpellButton("buttonSpellBloodyStrikes", "Interface/icons/spell_deathknight_deathstrike", "|cffffffffFrappes sanglantes|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente les dégâts de Frappe de sang de 15% et de Frappe au coeur de 45%, en plus d'augmenter les dégâts de Furoncle sanglant de 30%.|r", "spellbloodystrikes", 422, -185)
-- CreateSpellButton("buttonSpellVeteran of the Third War", "Interface/icons/spell_misc_warsongfocus", "|cffffffffVétéran de la Troisième guerre|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente votre total de Force de 6%, votre Endurance de 3% et votre expertise de 6.|r", "spellveteranofthethirdwar", 527, -190)
-- CreateSpellButton("buttonSpellMarkofBlood", "Interface/icons/ability_hunter_rapidkilling", "|cffffffffMarque de sang|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Place une Marque de sang sur un ennemi.\nChaque fois que l'ennemi marqué inflige des dégâts à une cible, cette cible reçoit 4% de ses points de vie maximum.\nDure 20 seconds ou jusqu'à 20 coups.|r", "spellmarkofblood", 43, -240)
-- CreateSpellButton("buttonSpellBloodyVengeance", "Interface/icons/ability_backstab", "|cffffffffVengeance sanglante|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Confère un bonus de 3% aux dégâts physiques que vous infligez pendant 30 seconds après avoir réussi un coup critique avec une arme, un sort ou une technique.\nL'effet est cumulable jusqu'à 3 fois.|r", "spellbloodyvengeance", 150, -240)
-- CreateSpellButton("buttonSpellAbominationsMight", "Interface/icons/ability_warrior_intensifyrage", "|cffffffffPuissance de l'abomination|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente de 10% la puissance d'attaque des membres du groupe ou du raid se trouvant à moins de 100 mètres.\nAugmente également votre total de Force de 2%.|r", "spellabominationsmight", 260, -240)
-- CreateSpellButton("buttonSpellBloodworms", "Interface/icons/spell_shadow_soulleech", "|cffffffffVers de sang|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos coups portés avec des armes ont 9% de chances de faire produire à la cible de 2 à 4 vers de sang.\nLes vers de sang attaquent vos ennemis et vous rendent un montant de points de vie égal aux dégâts qu'ils infligent pendant 20 sec.\nou jusqu'à ce qu'ils soient tués.|r", "spellbloodworms", 368, -240)
-- CreateSpellButton("buttonSpellUnholyFrenzy", "Interface/icons/spell_deathknight_bladedarmor", "|cffffffffHystérie|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Plonge une unité alliée dans une frénésie meurtrière pendant 30 seconds.\nLa cible est enragée, ce qui augmente les dégâts physiques qu'elle inflige de 20%, mais elle subit aussi toutes les secondes un montant de dégâts égal à 1% de ses points de vie maximum.|r", "spellunholyfrenzy", 478, -240)
-- CreateSpellButton("buttonSpellImprovedBloodPresence", "Interface/icons/spell_deathknight_bloodpresence", "|cffffffffPrésence de sang améliorée|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Quand vous êtes en Présence de givre ou impie, vous conservez 4% des soins de Présence de sang, et les soins qui vous sont prodigués sont augmentés de 10% en Présence de sang.|r", "spellimprovedbloodpresence", 98, -293)
-- CreateSpellButton("buttonSpellImprovedDeathStrike", "Interface/icons/spell_deathknight_butcher2", "|cffffffffFrappe de mort améliorée|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente de 30% les dégâts de votre Frappe de mort, de 6% ses chances de coup critique et de 50% les soins prodigués.|r", "spellimproveddeathstrike", 205, -293)
-- CreateSpellButton("buttonSpellSuddenDoom", "Interface/icons/spell_shadow_painspike", "|cffffffffMalédiction soudaine|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos Frappes de sang et Frappes au coeur ont 15% de chances de lancer un Voile mortel gratuit sur votre cible.|r", "spellsuddendoom", 315, -293)
-- CreateSpellButton("buttonSpellVampiricBlood", "Interface/icons/spell_shadow_lifedrain", "|cffffffffSang vampirique|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Confère temporairement au chevalier de la mort 15% de son maximum de points de vie et augmente le montant de points de vie généré par les sorts et effets de 35% pendant 10 seconds.\nQuand l'effet se termine, ces points de vie sont perdus.|r", "spellvampiricblood", 422, -293)
-- CreateSpellButton("buttonSpellWilloftheNecropolis", "Interface/icons/ability_creature_cursed_02", "|cffffffffVolonté de la nécropole|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Les dégâts qui vous feraient descendre à moins de 35% de vos points de vie ou que vous subissez alors que vous ne disposez que de 35% de vos points de vie sont réduits de 15%.|r", "spellwillofthenecropolis", 527, -295)
-- CreateSpellButton("buttonSpellHeartStrike", "Interface/icons/inv_weapon_shortblade_40", "|cffffffffFrappe au coeur|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Frappe instantanément la cible et son allié le plus proche, infligeant 72% des dégâts de l'arme plus 247 à la cible principale et 36% des dégâts de l'arme plus 123 à la cible secondaire.\nChaque cible subit 10% de dégâts supplémentaires pour chacune de vos maladies actives sur elle, et la vitesse de déplacement est réduite de 50% pendant 10 seconds.|r", "spellheartstriks", 43, -350)
-- CreateSpellButton("buttonSpellMightofMograine", "Interface/icons/spell_deathknight_classicon", "|cffffffffPuissance de Mograine|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente de 45% le bonus aux dégâts des coups critiques infligés avec vos techniques Furoncle sanglant, Frappe de sang, Frappe de mort et Frappe au cœur.|r", "spellmightofmograine", 260, -350)
-- CreateSpellButton("buttonSpellBloodGorged", "Interface/icons/spell_nature_reincarnation", "|cffffffffGorgé de sang|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Quand vous disposez de plus de 75% de vos points de vie, vous infligez 10% de dégâts supplémentaires.\nDe plus, vos attaques ignorent jusqu'à 10% de l'armure de votre adversaire à tout moment.|r", "spellbloodgorged", 150, -350)
-- CreateSpellButton("buttonSpellDancingRuneWeapon", "Interface/icons/inv_sword_07", "|cffffffffArme runique dansante|r\n|cffffffffTalent|r |cffd20000Sang|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Invoque une seconde arme runique qui combat toute seule pendant 12 seconds., en effectuant les mêmes attaques que le chevalier de la mort mais en infligeant 50% de dégâts de moins que lui.|r", "spelldancingruneweapon", 368, -350)

-- Givre

{
    id = "spellImprovedIcyTouch",
    name = "buttonSpellImprovedIcyTouch",
    icon = "Interface/icons/spell_deathknight_icetouch",
    position = {527, -402},
    handler = "spellimprovedicytouch",
    tooltips = {
        frFR = "|cffffffffToucher de glace amélioré|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Votre Toucher de glace inflige 15% de dégâts supplémentaires, et votre Fièvre de givre réduit les vitesses d'attaque en mêlée et à distance de 6% supplémentaires.|r",
        enUS = "|cffffffffImproved Icy Touch|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Your Icy Touch deals 15% additional damage, and your Frost Fever reduces melee and ranged attack speeds by an additional 6%.|r"
    }
},
{
    id = "spellRunicPowerMastery",
    name = "buttonSpellRunicPowerMastery",
    icon = "Interface/icons/spell_arcane_arcane01",
    position = {478, -350},
    handler = "spellrunicpowermastery",
    tooltips = {
        frFR = "|cffffffffMaîtrise de la puissance runique|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente votre puissance runique maximale de 30.|r",
        enUS = "|cffffffffRunic Power Mastery|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases your maximum Runic Power by 30.|r"
    }
},
{
    id = "spellToughness",
    name = "buttonSpellToughness",
    icon = "Interface/icons/spell_holy_devotion",
    position = {98, -405},
    handler = "spelltoughness",
    tooltips = {
        frFR = "|cffffffffRésistance|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente la valeur d'armure des objets de 10% et réduit la durée de tous les effets affectant le déplacement de 30%.|r",
        enUS = "|cffffffffToughness|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases the armor value of items by 10% and reduces the duration of all movement-impairing effects by 30%.|r"
    }
},
{
    id = "spellIcyReach",
    name = "buttonSpellIcyReach",
    icon = "Interface/icons/spell_frost_manarecharge",
    position = {205, -405},
    handler = "spellicyreach",
    tooltips = {
        frFR = "|cffffffffAllonge glaciale|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente la portée de vos sorts Toucher de glace, Chaînes de glace et Rafale hurlante de 10 mètres.|r",
        enUS = "|cffffffffIcy Reach|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases the range of your Icy Touch, Chains of Ice, and Howling Blast spells by 10 meters.|r"
    }
},
{
    id = "spellBlackIce",
    name = "buttonSpellBlackIce",
    icon = "Interface/icons/spell_shadow_darkritual",
    position = {315, -405},
    handler = "spellblackice",
    tooltips = {
        frFR = "|cffffffffGlace noire|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente vos dégâts de Givre et d'Ombre de 10%.|r",
        enUS = "|cffffffffBlack Ice|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases your Frost and Shadow damage by 10%.|r"
    }
},
{
    id = "spellNervesofColdSteel",
    name = "buttonSpellNervesofColdSteel",
    icon = "Interface/icons/ability_dualwield",
    position = {422, -405},
    handler = "spellnervesofcoldsteel",
    tooltips = {
        frFR = "|cffffffffNerfs d'acier glacé|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente de 3% vos chances de toucher avec les armes de mêlée à une main, et augmente de 25% les dégâts infligés par l'arme que vous utilisez en main gauche.\net augmente votre total d'Endurance de 4%.|r",
        enUS = "|cffffffffNerves of Cold Steel|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases your chance to hit with one-handed melee weapons by 3% and increases the damage dealt by your off-hand weapon by 25%. Additionally, increases your total Stamina by 4%.|r"
    }
},
{
    id = "spellIcyTalons",
    name = "buttonSpellIcyTalons",
    icon = "Interface/icons/spell_deathknight_icytalons",
    position = {43, -458},
    handler = "spellicytalons",
    tooltips = {
        frFR = "|cffffffffSerres de glace|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vous volez la chaleur des victimes de votre Fièvre de givre, de sorte que lorsque leur vitesse d'attaque en mêlée est réduite, la vôtre augmente de 20% pendant les 20 prochaines sec.|r",
        enUS = "|cffffffffIcy Talons|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Steal the heat from your Frost Fever victims, causing your melee attack speed to increase by 20% for the next 20 seconds whenever their melee attack speed is reduced.|r"
    }
},
{
    id = "spellLichborne",
    name = "buttonSpellLichborne",
    icon = "Interface/icons/spell_shadow_raisedead",
    position = {150, -458},
    handler = "spelllichborne",
    tooltips = {
        frFR = "|cffffffffChangeliche|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Utilise de l'énergie impie pour devenir mort-vivant pendant 10 seconds.\nTant que vous êtes mort-vivant, vous êtes insensible aux effets de charme, de peur et de sommeil.|r",
        enUS = "|cffffffffLichborne|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Draw upon unholy energy to become undead for 10 seconds. While undead, you are immune to charm, fear, and sleep effects.|r"
    }
},
{
    id = "spellAnnihilation",
    name = "buttonSpellAnnihilation",
    icon = "Interface/icons/inv_weapon_hand_18",
    position = {260, -458},
    handler = "spellannihilation",
    tooltips = {
        frFR = "|cffffffffAnnihilation|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente vos chances de réaliser un coup critique avec vos techniques spéciales de mêlée de 3%.\nDe plus, il y a 100% de chances que votre Anéantissement inflige ses dégâts sans consommer de maladie.|r",
        enUS = "|cffffffffAnnihilation|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases your chance to critically hit with melee special abilities by 3%. Additionally, your Obliterate has a 100% chance to deal its damage without consuming diseases.|r"
    }
},
{
    id = "spellKillingMachine",
    name = "buttonSpellKillingMachine",
    icon = "Interface/icons/inv_sword_122",
    position = {368, -458},
    handler = "spellkillingmachine",
    tooltips = {
        frFR = "|cffffffffMachine à tuer|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos attaques en mêlée ont une chance de conférer un coup critique à votre prochain sort Toucher de glace, Rafale hurlante, ou Frappe de givre.|r",
        enUS = "|cffffffffKilling Machine|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Your melee attacks have a chance to grant a critical strike to your next Icy Touch, Howling Blast, or Frost Strike spell.|r"
    }
},
{
    id = "spellChilloftheGrave",
    name = "buttonSpellChilloftheGrave",
    icon = "Interface/icons/spell_frost_frostshock",
    position = {478, -458},
    handler = "spellchillofthegrave",
    tooltips = {
        frFR = "|cffffffffFroid de la tombe|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos sorts Chaînes de glace, Rafale hurlante, Toucher de glace et Anéantissement génèrent 5 points de puissance runique supplémentaires.|r",
        enUS = "|cffffffffChill of the Grave|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Your Chains of Ice, Howling Blast, Icy Touch, and Obliterate generate 5 additional Runic Power.|r"
    }
},
{
    id = "spellEndlessWinter",
    name = "buttonSpellEndlessWinter",
    icon = "Interface/icons/spell_shadow_twilight",
    position = {98, -510},
    handler = "spellendlesswinter",
    tooltips = {
        frFR = "|cffffffffHiver sans fin|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Votre Force est augmentée de 4% et votre Gel de l'esprit ne coûte plus de puissance runique.|r",
        enUS = "|cffffffffEndless Winter|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Your Strength is increased by 4%, and your Mind Freeze no longer costs Runic Power.|r"
    }
},
{
    id = "spellFrigidDreadplate",
    name = "buttonSpellFrigidDreadplate",
    icon = "Interface/icons/inv_chest_mail_04",
    position = {205, -510},
    handler = "spellfrigiddreadplate",
    tooltips = {
        frFR = "|cffffffffPlaques d'effroi algides|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Réduit les chances de vous toucher en mêlée de 3%.|r",
        enUS = "|cffffffffFrigid Dreadplate|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Reduces the chance you will be hit by melee attacks by 3%.|r"
    }
},
{
    id = "spellGlacierRot",
    name = "buttonSpellGlacierRot",
    icon = "Interface/icons/spell_nature_removedisease",
    position = {315, -510},
    handler = "spellglacierrot",
    tooltips = {
        frFR = "|cffffffffPourriture des glaciers|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos sorts Toucher de glace, Rafale hurlante et Frappe de givre infligent 20% de dégâts supplémentaires aux cibles malades.\nDure 15 seconds.|r",
        enUS = "|cffffffffGlacier Rot|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Your Icy Touch, Howling Blast, and Frost Strike deal 20% additional damage to diseased targets. Lasts 15 seconds.|r"
    }
},
{
    id = "spellDeathchill",
    name = "buttonSpellDeathchill",
    icon = "Interface/icons/spell_shadow_soulleech_2",
    position = {422, -510},
    handler = "spelldeathchill",
    tooltips = {
        frFR = "|cffffffffFroid de la mort|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Quand il est activé, il fait de votre prochain sort Toucher de glace, Rafale hurlante, Frappe de givre ou Anéantissement un coup critique si utilisé en 30 seconds maximum.|r",
        enUS = "|cffffffffDeathchill|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100When activated, makes your next Icy Touch, Howling Blast, Frost Strike, or Obliterate a critical strike if used within 30 seconds.|r"
    }
},


-- CreateSpellButton("buttonSpellImprovedIcyTouch", "Interface/icons/spell_deathknight_icetouch", "|cffffffffToucher de glace amélioré|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Votre Toucher de glace inflige 15% de dégâts supplémentaires, et votre Fièvre de givre réduit les vitesses d'attaque en mêlée et à distance de 6% supplémentaires.|r", "spellimprovedicytouch", 527, -402)
-- CreateSpellButton("buttonSpellRunicPowerMastery", "Interface/icons/spell_arcane_arcane01", "|cffffffffMaîtrise de la puissance runique|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente votre puissance runique maximale de 30.|r", "spellrunicpowermastery", 478, -350)
-- CreateSpellButton("buttonSpellToughness", "Interface/icons/spell_holy_devotion", "|cffffffffRésistance|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente la valeur d'armure des objets de 10% et réduit la durée de tous les effets affectant le déplacement de 30%.|r", "spelltoughness", 98, -405)
-- CreateSpellButton("buttonSpellIcyReach", "Interface/icons/spell_frost_manarecharge", "|cffffffffAllonge glaciale|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente la portée de vos sorts Toucher de glace, Chaînes de glace et Rafale hurlante de 10 mètres.|r", "spellicyreach", 205, -405)
-- CreateSpellButton("buttonSpellBlackIce", "Interface/icons/spell_shadow_darkritual", "|cffffffffGlace noire|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente vos dégâts de Givre et d'Ombre de 10%.|r", "spellblackice", 315, -405)
-- CreateSpellButton("buttonSpellNervesofColdSteel", "Interface/icons/ability_dualwield", "|cffffffffNerfs d'acier glacé|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente de 3% vos chances de toucher avec les armes de mêlée à une main, et augmente de 25% les dégâts infligés par l'arme que vous utilisez en main gauche.\net augmente votre total d'Endurance de 4%.|r", "spellnervesofcoldsteel", 422, -405)
-- CreateSpellButton("buttonSpellIcyTalons", "Interface/icons/spell_deathknight_icytalons", "|cffffffffSerres de glace|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vous volez la chaleur des victimes de votre Fièvre de givre, de sorte que lorsque leur vitesse d'attaque en mêlée est réduite, la vôtre augmente de 20% pendant les 20 prochaines sec.|r", "spellicytalons", 43, -458)
-- CreateSpellButton("buttonSpellLichborne", "Interface/icons/spell_shadow_raisedead", "|cffffffffChangeliche|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Utilise de l'énergie impie pour devenir mort-vivant pendant 10 seconds.\nTant que vous êtes mort-vivant, vous êtes insensible aux effets de charme, de peur et de sommeil.|r", "spelllichborne", 150, -458)
-- CreateSpellButton("buttonSpellAnnihilation", "Interface/icons/inv_weapon_hand_18", "|cffffffffAnnihilation|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente vos chances de réaliser un coup critique avec vos techniques spéciales de mêlée de 3%.\nDe plus, il y a 100% de chances que votre Anéantissement inflige ses dégâts sans consommer de maladie.|r", "spellannihilation", 260, -458)
-- CreateSpellButton("buttonSpellKillingMachine", "Interface/icons/inv_sword_122", "|cffffffffMachine à tuer|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos attaques en mêlée ont une chance de conférer un coup critique à votre prochain sort Toucher de glace, Rafale hurlante, ou Frappe de givre.|r", "spellkillingmachine", 368, -458)
-- CreateSpellButton("buttonSpellChilloftheGrave", "Interface/icons/spell_frost_frostshock", "|cffffffffFroid de la tombe|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos sorts Chaînes de glace, Rafale hurlante, Toucher de glace et Anéantissement génèrent 5 points de puissance runique supplémentaires.|r", "spellchillofthegrave", 478, -458)
-- CreateSpellButton("buttonSpellEndlessWinter", "Interface/icons/spell_shadow_twilight", "|cffffffffHiver sans fin|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Votre Force est augmentée de 4% et votre Gel de l'esprit ne coûte plus de puissance runique.|r", "spellendlesswinter", 98, -510)
-- CreateSpellButton("buttonSpellFrigid Dreadplate", "Interface/icons/inv_chest_mail_04", "|cffffffffPlaques d'effroi algides|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Réduit les chances de vous toucher en mêlée de 3%.|r", "spellfrigiddreadplate", 205, -510)
-- CreateSpellButton("buttonSpellGlacierRot", "Interface/icons/spell_nature_removedisease", "|cffffffffPourriture des glaciers|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos sorts Toucher de glace, Rafale hurlante et Frappe de givre infligent 20% de dégâts supplémentaires aux cibles malades.\nDure 15 seconds.|r", "spellglacierrot", 315, -510)
-- CreateSpellButton("buttonSpellDeathchill", "Interface/icons/spell_shadow_soulleech_2", "|cffffffffFroid de la mort|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Quand il est activé, il fait de votre prochain sort Toucher de glace, Rafale hurlante, Frappe de givre ou Anéantissement un coup critique si utilisé en 30 seconds maximum.|r", "spelldeathchill", 422, -510)

-- Template 2

{
    id = "spellImprovedIcyTalons",
    name = "buttonSpellImprovedIcyTalons",
    icon = "Interface/icons/spell_deathknight_icytalons",
    position = {663, -75},
    handler = "spellimprovedicytalons",
    tooltips = {
        frFR = "|cffffffffSerres de glace améliorées|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente la hâte en mêlée de tous les membres de votre groupe ou raid à moins de 100 mètres de 20% et votre hâte de 5% supplémentaires.|r",
        enUS = "|cffffffffImproved Icy Talons|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases melee haste by 20% for all party or raid members within 100 yards, and your haste by an additional 5%.|r"
    }
},

{
    id = "spellMercilessCombat",
    name = "buttonSpellMercilessCombat",
    icon = "Interface/icons/inv_sword_112",
    position = {770, -75},
    handler = "spellmercilesscombat",
    tooltips = {
        frFR = "|cffffffffCombat impitoyable|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Toucher de glace, Rafale hurlante, Anéantissement et Frappe de givre infligent 12% de dégâts supplémentaires aux cibles qui disposent de moins de 35% de leurs points de vie.|r",
        enUS = "|cffffffffMerciless Combat|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Icy Touch, Howling Blast, Annihilation, and Frost Strike deal 12% more damage to targets with less than 35% health.|r"
    }
},

{
    id = "spellRime",
    name = "buttonSpellRime",
    icon = "Interface/icons/spell_frost_freezingbreath",
    position = {880, -75},
    handler = "spellrime",
    tooltips = {
        frFR = "|cffffffffFrimas|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente les chances de coup critique de vos sorts Toucher de glace\net Anéantissement de 15% et l'incantation d'Anéantissement a 15% de chances de réinitialiser le temps de recharge de Rafale hurlante\nen plus de permettre à votre prochaine Rafale hurlante de ne pas consommer de runes.|r",
        enUS = "|cffffffffRime|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases critical strike chance for your Icy Touch and Annihilation by 15%, and Annihilation has a 15% chance to reset the cooldown of Howling Blast and cause your next Howling Blast to cost no runes.|r"
    }
},

{
    id = "spellChilblains",
    name = "buttonSpellChilblains",
    icon = "Interface/icons/spell_frost_wisp",
    position = {990, -75},
    handler = "spellchilblains",
    tooltips = {
        frFR = "|cffffffffEngelures|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Les victimes de votre Fièvre de givre sont transies, ce qui réduit leur vitesse de déplacement de 50% pendant 10 seconds.|r",
        enUS = "|cffffffffChilblains|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Victims of your Frost Fever are chilled, reducing their movement speed by 50% for 10 seconds.|r"
    }
},

{
    id = "spellHungeringCold",
    name = "buttonSpellHungeringCold",
    icon = "Interface/icons/inv_staff_15",
    position = {1100, -75},
    handler = "spellhungeringcold",
    tooltips = {
        frFR = "|cffffffffFroid dévorant|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Eradique toute chaleur de la terre autour du chevalier de la mort.\nLes ennemis se trouvant à moins de 10 mètres sont pris dans la glace, ce qui les empêche de réaliser toute action pendant 10 seconds et leur fait contracter la Fièvre de givre.\nLes ennemis sont considérés comme gelés, mais tous les dégâts autres que les maladies brisent la glace.|r",
        enUS = "|cffffffffHungering Cold|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Eradicates all warmth from the land around the Death Knight. Enemies within 10 yards are encased in ice, preventing them from acting for 10 seconds and causing them to contract Frost Fever. Enemies are considered frozen, but all damage other than disease breaks the ice.|r"
    }
},
{
    id = "spellImprovedFrostPresence",
    name = "buttonSpellImprovedFrostPresence",
    icon = "Interface/icons/spell_deathknight_frostpresence",
    position = {718, -130},
    handler = "spellimprovedfrostpresence",
    tooltips = {
        frFR = "|cffffffffPrésence de givre améliorée|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Quand vous êtes en Présence de sang ou impie, vous conservez 8% de l'Endurance de Présence de givre, et les dégâts qui vous sont infligés sont réduits de 2% supplémentaires en Présence de givre.|r",
        enUS = "|cffffffffImproved Frost Presence|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100When you are in Blood or Unholy Presence, you retain 8% of the Endurance from Frost Presence, and damage taken is reduced by an additional 2% while in Frost Presence.|r"
    }
},

{
    id = "spellThreatofThassarian",
    name = "buttonSpellThreatofThassarian",
    icon = "Interface/icons/ability_dualwieldspecialization",
    position = {825, -130},
    handler = "spellthreatofthassarian",
    tooltips = {
        frFR = "|cffffffffMenace de Thassarian|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Lorsque vous utilisez deux armes en même temps, vos Frappes de mort,\nAnéantissements, Frappes de peste, Frappes runiques, Frappes de sang et Frappes de givre\nont 100% de chances d'également infliger des dégâts avec votre arme tenue en main gauche.|r",
        enUS = "|cffffffffThreat of Thassarian|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100When dual-wielding, your Death Strikes, Annihilations, Pestilence Strikes, Rune Strikes, Blood Strikes, and Frost Strikes have a 100% chance to also deal damage with your off-hand weapon.|r"
    }
},

{
    id = "spellBloodoftheNorth",
    name = "buttonSpellBloodoftheNorth",
    icon = "Interface/icons/inv_weapon_shortblade_79",
    position = {935, -130},
    handler = "spellbloodofthenorth",
    tooltips = {
        frFR = "|cffffffffSang du Nord|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente les dégâts de Frappe de sang et Frappe de givre de 10%.\nDe plus, chaque fois que vous touchez avec Frappe de sang ou Pestilence, il y a 100% de chances que la rune de sang devienne une rune de la mort à son activation.\nLes runes de la mort comptent comme une rune de sang, de givre ou impie.|r",
        enUS = "|cffffffffBlood of the North|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases the damage of Blood Strike and Frost Strike by 10%. Additionally, each time you hit with Blood Strike or Pestilence, there is a 100% chance that your Blood rune will become a Death rune upon activation. Death runes count as Blood, Frost, or Unholy runes.|r"
    }
},

{
    id = "spellUnbreakableArmor",
    name = "buttonSpellUnbreakableArmor",
    icon = "Interface/icons/inv_armor_helm_plate_naxxramas_raidwarrior_c_01",
    position = {1045, -130},
    handler = "spellunbreakablearmor",
    tooltips = {
        frFR = "|cffffffffArmure incassable|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Renforce votre armure d'une épaisse couche de glace qui augmente votre armure de 25% et votre Force de 20% pendant 20 seconds.|r",
        enUS = "|cffffffffUnbreakable Armor|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Fortifies your armor with a thick layer of ice, increasing your armor by 25% and your Strength by 20% for 20 seconds.|r"
    }
},

{
    id = "spellAcclimation",
    name = "buttonSpellAcclimation",
    icon = "Interface/icons/spell_fire_elementaldevastation",
    position = {663, -184},
    handler = "spellacclimation",
    tooltips = {
        frFR = "|cffffffffAcclimatation|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Quand vous êtes touché par un sort, vous avez 30% de chances d'améliorer votre résistance à ce type de magie pendant 18 sec.\nCumulable jusqu'à 3 fois.|r",
        enUS = "|cffffffffAcclimation|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100When you are hit by a spell, you have a 30% chance to increase your resistance to that school of magic for 18 seconds. Stacks up to 3 times.|r"
    }
},
{
    id = "spellFrostStrike",
    name = "buttonSpellFrostStrike",
    icon = "Interface/icons/spell_deathknight_empowerruneblade2",
    position = {770, -184},
    handler = "spellfroststrike",
    tooltips = {
        frFR = "|cffffffffFrappe de givre|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Frappe instantanément l'ennemi et lui inflige 60 à 61% des dégâts de l'arme plus 57 sous forme de dégâts de Givre.|r",
        enUS = "|cffffffffFrost Strike|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Instantly strikes the enemy, dealing 60 to 61% of weapon damage plus 57 as Frost damage.|r"
    }
},

{
    id = "spellGuileofGorefiend",
    name = "buttonSpellGuileofGorefiend",
    icon = "Interface/icons/inv-sword_53",
    position = {880, -184},
    handler = "spellguileofgorefiend",
    tooltips = {
        frFR = "|cffffffffRuse de Fielsang|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente de 45% le bonus aux dégâts des coups critiques réussis avec vos techniques Frappe de sang, Frappe de givre, Rafale hurlante et Anéantissement en plus d'augmenter de 6 sec.\nla durée de votre Robustesse glaciale.|r",
        enUS = "|cffffffffGuile of Gorefiend|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases the bonus damage from critical hits by 45% for your Blood Strike, Frost Strike, Howling Blast, and Annihilation abilities, and also increases the duration of your Frost Aura by 6 seconds.|r"
    }
},

{
    id = "spellTundraStalker",
    name = "buttonSpellTundraStalker",
    icon = "Interface/icons/spell_nature_tranquility",
    position = {990, -184},
    handler = "spelltundrastalker",
    tooltips = {
        frFR = "|cffffffffTraqueur de la toundra|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos sorts et techniques infligent 15% de dégâts supplémentaires aux cibles souffrant de la Fièvre de givre.\nAugmente également votre expertise de 5.|r",
        enUS = "|cffffffffTundra Stalker|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Your spells and abilities deal 15% more damage to targets suffering from Frost Fever. Also increases your Expertise by 5.|r"
    }
},

{
    id = "spellHowlingBlast",
    name = "buttonSpellHowlingBlast",
    icon = "Interface/icons/spell_frost_arcticwinds",
    position = {1100, -184},
    handler = "spellhowlingblast",
    tooltips = {
        frFR = "|cffffffffRafale hurlante|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Un vent glacial frappe la cible et inflige 198 à 214 points de dégâts de Givre à tous les ennemis se trouvant à moins de 10 mètres.|r",
        enUS = "|cffffffffHowling Blast|r\n|cffffffffTalent|r |cff00acffFrost|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100A frigid wind strikes the target, dealing 198 to 214 Frost damage to all enemies within 10 yards.|r"
    }
},


-- CreateSpellButton("buttonSpellImprovedIcyTalons", "Interface/icons/spell_deathknight_icytalons", "|cffffffffSerres de glace améliorées|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente la hâte en mêlée de tous les membres de votre groupe ou raid à moins de 100 mètres de 20% et votre hâte de 5% supplémentaires.|r", "spellimprovedicytalons", 663, -75)
-- CreateSpellButton("buttonSpellMercilessCombat", "Interface/icons/inv_sword_112", "|cffffffffCombat impitoyable|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Toucher de glace, Rafale hurlante, Anéantissement et Frappe de givre infligent 12% de dégâts supplémentaires aux cibles qui disposent de moins de 35% de leurs points de vie.|r", "spellmercilesscombat", 770, -75)
-- CreateSpellButton("buttonSpellRime", "Interface/icons/spell_frost_freezingbreath", "|cffffffffFrimas|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente les chances de coup critique de vos sorts Toucher de glace\net Anéantissement de 15% et l'incantation d'Anéantissement a 15% de chances de réinitialiser le temps de recharge de Rafale hurlante\nen plus de permettre à votre prochaine Rafale hurlante de ne pas consommer de runes.|r", "spellrime", 880, -75)
-- CreateSpellButton("buttonSpellChilblains", "Interface/icons/spell_frost_wisp", "|cffffffffEngelures|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Les victimes de votre Fièvre de givre sont transies, ce qui réduit leur vitesse de déplacement de 50% pendant 10 seconds.|r", "spellchilblains", 990, -75)
-- CreateSpellButton("buttonSpellHungeringCold", "Interface/icons/inv_staff_15", "|cffffffffFroid dévorant|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Eradique toute chaleur de la terre autour du chevalier de la mort.\nLes ennemis se trouvant à moins de 10 mètres sont pris dans la glace, ce qui les empêche de réaliser toute action pendant 10 seconds et leur fait contracter la Fièvre de givre.\nLes ennemis sont considérés comme gelés, mais tous les dégâts autres que les maladies brisent la glace.|r", "spellhungeringcold", 1100, -75)
-- CreateSpellButton("buttonSpellImprovedFrostPresence", "Interface/icons/spell_deathknight_frostpresence", "|cffffffffPrésence de givre améliorée|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Quand vous êtes en Présence de sang ou impie, vous conservez 8% de l'Endurance de Présence de givre, et les dégâts qui vous sont infligés sont réduits de 2% supplémentaires en Présence de givre.|r", "spellimprovedfrostpresence", 718, -130)
-- CreateSpellButton("buttonSpellThreatofThassarian", "Interface/icons/ability_dualwieldspecialization", "|cffffffffMenace de Thassarian|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Lorsque vous utilisez deux armes en même temps, vos Frappes de mort,\nAnéantissements, Frappes de peste, Frappes runiques, Frappes de sang et Frappes de givre\nont 100% de chances d'également infliger des dégâts avec votre arme tenue en main gauche.|r", "spellthreatofthassarian", 825, -130)
-- CreateSpellButton("buttonSpellBloodoftheNorth", "Interface/icons/inv_weapon_shortblade_79", "|cffffffffSang du Nord|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente les dégâts de Frappe de sang et Frappe de givre de 10%.\nDe plus, chaque fois que vous touchez avec Frappe de sang ou Pestilence, il y a 100% de chances que la rune de sang devienne une rune de la mort à son activation.\nLes runes de la mort comptent comme une rune de sang, de givre ou impie.|r", "spellbloodofthenorth", 935, -130)
-- CreateSpellButton("buttonSpellUnbreakableArmor", "Interface/icons/inv_armor_helm_plate_naxxramas_raidwarrior_c_01", "|cffffffffArmure incassable|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Renforce votre armure d'une épaisse couche de glace qui augmente votre armure de 25% et votre Force de 20% pendant 20 seconds.|r", "spellunbreakablearmor", 1045, -130)
-- CreateSpellButton("buttonSpellAcclimation", "Interface/icons/spell_fire_elementaldevastation", "|cffffffffAcclimatation|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Quand vous êtes touché par un sort, vous avez 30% de chances d'améliorer votre résistance à ce type de magie pendant 18 sec.\nCumulable jusqu'à 3 fois.|r", "spellacclimation", 663, -184)
-- CreateSpellButton("buttonSpellFrostStrike", "Interface/icons/spell_deathknight_empowerruneblade2", "|cffffffffFrappe de givre|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Frappe instantanément l'ennemi et lui inflige 60 à 61% des dégâts de l'arme plus 57 sous forme de dégâts de Givre.|r", "spellfroststrike", 770, -184)
-- CreateSpellButton("buttonSpellGuileofGorefiend", "Interface/icons/inv-sword_53", "|cffffffffRuse de Fielsang|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente de 45% le bonus aux dégâts des coups critiques réussis avec vos techniques Frappe de sang, Frappe de givre, Rafale hurlante et Anéantissement en plus d'augmenter de 6 sec.\nla durée de votre Robustesse glaciale.|r", "spellguileofgorefiend", 880, -184)
-- CreateSpellButton("buttonSpellTundraStalker", "Interface/icons/spell_nature_tranquility", "|cffffffffTraqueur de la toundra|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos sorts et techniques infligent 15% de dégâts supplémentaires aux cibles souffrant de la Fièvre de givre.\nAugmente également votre expertise de 5.|r", "spelltundrastalker", 990, -184)
-- CreateSpellButton("buttonSpellHowlingBlast", "Interface/icons/spell_frost_arcticwinds", "|cffffffffRafale hurlante|r\n|cffffffffTalent|r |cff00acffGivre|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Un vent glacial frappe la cible et inflige 198 à 214 points de dégâts de Givre à tous les ennemis se trouvant à moins de 10 mètres.|r", "spellhowlingblast", 1100, -184)


-- Impie

{
    id = "spellViciousStrikes",
    name = "buttonSpellViciousStrikes",
    icon = "Interface/icons/spell_deathknight_plaguestrike",
    position = {718, -240},
    handler = "spellviciousstrikes",
    tooltips = {
        frFR = "|cffffffffAttaques vicieuses|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente de 6% les chances de coup critique et de 30% le bonus de dégâts des coups critiques de vos sorts Frappe de peste et Frappe du Fléau.|r",
        enUS = "|cffffffffVicious Strikes|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases your critical strike chance by 6% and your critical strike damage bonus by 30% for your Plague Strike and Scourge Strike abilities.|r"
    }
},

{
    id = "spellVirulence",
    name = "buttonSpellVirulence",
    icon = "Interface/icons/spell_shadow_burningspirit",
    position = {825, -240},
    handler = "spellvirulence",
    tooltips = {
        frFR = "|cffffffffVirulence|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente vos chances de toucher avec vos sorts de 3% et réduit de 30% la probabilité que vos maladies de dégâts sur la durée puissent être soignées.|r",
        enUS = "|cffffffffVirulence|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases your spell hit chance by 3% and reduces the chance that your damage-over-time diseases can be dispelled by 30%.|r"
    }
},

{
    id = "spellAnticipation",
    name = "buttonSpellAnticipation",
    icon = "Interface/icons/spell_nature_mirrorimage",
    position = {935, -240},
    handler = "spellanticipation",
    tooltips = {
        frFR = "|cffffffffAnticipation|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente vos chances d'esquiver une attaque de 5%.|r",
        enUS = "|cffffffffAnticipation|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases your chance to dodge attacks by 5%.|r"
    }
},

{
    id = "spellEpidemic",
    name = "buttonSpellEpidemic",
    icon = "Interface/icons/spell_shadow_shadowwordpain",
    position = {1045, -240},
    handler = "spellepidemic",
    tooltips = {
        frFR = "|cffffffffEpidémie|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente la durée de Peste de sang et Fièvre de givre de 6 sec.|r",
        enUS = "|cffffffffEpidemic|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases the duration of Blood Plague and Frost Fever by 6 seconds.|r"
    }
},

{
    id = "spellMorbidity",
    name = "buttonSpellMorbidity",
    icon = "Interface/icons/spell_shadow_deathanddecay",
    position = {663, -293},
    handler = "spellmorbidity",
    tooltips = {
        frFR = "|cffffffffMorbidité|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente de 15% les dégâts et les soins de votre sort Voile mortel et réduit le temps de recharge de votre sort Mort et décomposition de 15 sec.|r",
        enUS = "|cffffffffMorbidity|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases the damage and healing of your Death Coil by 15% and reduces the cooldown of your Death and Decay ability by 15 seconds.|r"
    }
},
{
    id = "spellUnholyCommand",
    name = "buttonSpellUnholyCommand",
    icon = "Interface/icons/spell_deathknight_strangulate",
    position = {770, -293},
    handler = "spellunholycommand",
    tooltips = {
        frFR = "|cffffffffAutorité impie|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Réduit le temps de recharge de votre technique Poigne de la mort de 10 sec.|r",
        enUS = "|cffffffffUnholy Command|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Reduces the cooldown of your Death Grip ability by 10 seconds.|r"
    }
},

{
    id = "spellRavenousDead",
    name = "buttonSpellRavenousDead",
    icon = "Interface/icons/spell_deathknight_gnaw_ghoul",
    position = {880, -293},
    handler = "spellravenousdead",
    tooltips = {
        frFR = "|cffffffffMorts voraces|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente votre total de Force de 3% et la part de votre Force et de votre Endurance que reçoivent vos goules de 60%.|r",
        enUS = "|cffffffffRavenous Dead|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases your total Strength by 3% and the amount of Strength and Stamina your ghouls receive by 60%.|r"
    }
},

{
    id = "spellOutbreak",
    name = "buttonSpellOutbreak",
    icon = "Interface/icons/spell_shadow_plaguecloud",
    position = {990, -293},
    handler = "spelloutbreak",
    tooltips = {
        frFR = "|cffffffffPoussée de fièvre|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente les dégâts de Frappe de peste de 30% et de Frappe du Fléau de 20%.|r",
        enUS = "|cffffffffOutbreak|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Increases the damage of Plague Strike by 30% and Scourge Strike by 20%.|r"
    }
},

{
    id = "spellNecrosis",
    name = "buttonSpellNecrosis",
    icon = "Interface/icons/inv_weapon_shortblade_60",
    position = {1100, -293},
    handler = "spellnecrosis",
    tooltips = {
        frFR = "|cffffffffNécrose|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos attaques automatiques infligent 20% de dégâts d'Ombre supplémentaires.|r",
        enUS = "|cffffffffNecrosis|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Your autoattacks deal 20% additional Shadow damage.|r"
    }
},

{
    id = "spellCorpseExplosion",
    name = "buttonSpellCorpseExplosion",
    icon = "Interface/icons/ability_creature_disease_02",
    position = {718, -348},
    handler = "spellcorpseexplosion",
    tooltips = {
        frFR = "|cffffffffExplosion morbide|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Fait exploser un cadavre et inflige 166 points de dégâts d'Ombre à tous les ennemis se trouvant à moins de 10 mètres.\nUtilise un cadavre proche si la cible n'en est pas un.\nN'affecte pas les cadavres mécaniques ou d'élémentaires.|r",
        enUS = "|cffffffffCorpse Explosion|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Causes a corpse to explode, dealing 166 Shadow damage to all enemies within 10 yards. Will use a nearby corpse if the target is not a corpse.\nDoes not affect mechanical or elemental corpses.|r"
    }
},
{
    id = "spellOnaPaleHorse",
    name = "buttonSpellOnaPaleHorse",
    icon = "Interface/icons/spell_deathknight_summondeathcharger",
    position = {825, -348},
    handler = "spellonapalehorse",
    tooltips = {
        frFR = "|cffffffffSur un cheval pâle|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vous devenez aussi difficile à arrêter que la mort elle-même.\nLa durée de tous les effets d'étourdissement et de peur contre vous est réduite de 20%, et la vitesse de votre monture est augmentée de 20%.\nNe s'additionne pas avec les autres effets qui augmentent la vitesse de déplacement.|r",
        enUS = "|cffffffffOn a Pale Horse|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100You become as hard to stop as death itself.\nReduces the duration of all stuns and fear effects against you by 20%, and increases your mount's speed by 20%.\nDoes not stack with other movement speed increasing effects.|r"
    }
},

{
    id = "spellBloodCakedBlade",
    name = "buttonSpellBloodCakedBlade",
    icon = "Interface/icons/ability_criticalstrike",
    position = {935, -348},
    handler = "spellbloodcakedblade",
    tooltips = {
        frFR = "|cffffffffLame incrustée de sang|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos attaques automatiques ont 30% de chances de causer une Frappe incrustée de sang, qui inflige 25% des dégâts de l'arme plus 12.5% pour chacune de vos maladies sur la cible.|r",
        enUS = "|cffffffffBlood-Caked Blade|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Your autoattacks have a 30% chance to cause a Blood-Caked Strike, dealing 25% of weapon damage plus 12.5% for each of your diseases on the target.|r"
    }
},

{
    id = "spellNightoftheDead",
    name = "buttonSpellNightoftheDead",
    icon = "Interface/icons/spell_deathknight_armyofthedead",
    position = {1045, -348},
    handler = "spellnightofthedead",
    tooltips = {
        frFR = "|cffffffffNuit des morts|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Réduit le temps de recharge de Réanimation morbide de 90 sec.\net celui d'Armée des morts de 4 min.\nRéduit également les dégâts infligés à votre familier par les attaques à zone d'effet des créatures de 90%.|r",
        enUS = "|cffffffffNight of the Dead|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Reduces the cooldown of Ghoul Resurrection by 90 sec.\nand Army of the Dead by 4 min.\nAlso reduces damage taken by your ghoul from area of effect attacks by 90%.|r"
    }
},

{
    id = "spellMasterofGhouls",
    name = "buttonSpellMasterofGhouls",
    icon = "Interface/icons/spell_shadow_animatedead",
    position = {663, -402},
    handler = "spellmasterofghouls",
    tooltips = {
        frFR = "|cffffffffMaître des goules|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Réduit le temps de recharge de Réanimation morbide de 60 sec.\net la goule invoquée par votre sort Réanimation morbide est considérée comme un familier sous votre contrôle.\nContrairement aux goules normales de chevalier de la mort, votre familier n'a pas de durée limitée.|r",
        enUS = "|cffffffffMaster of Ghouls|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Reduces the cooldown of Ghoul Resurrection by 60 sec.\nand the ghoul summoned by your Ghoul Resurrection is considered a pet under your control.\nUnlike normal Death Knight ghouls, your pet has no time limit.|r"
    }
},

{
    id = "spellGhoulFrenzy",
    name = "buttonSpellGhoulFrenzy",
    icon = "Interface/icons/ability_ghoulfrenzy",
    position = {770, -402},
    handler = "spellghoulfrenzy",
    tooltips = {
        frFR = "|cffffffffFrénésie de la goule|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Confère à votre familier un bonus de 25% à la hâte pendant 30 secondes et lui rend 60% de ses points de vie pendant la durée de l'effet.|r",
        enUS = "|cffffffffGhoul Frenzy|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Grants your pet a 25% haste bonus for 30 seconds and restores 60% of its health over the duration of the effect.|r"
    }
},
{
    id = "spellUnholyBlight",
    name = "buttonSpellUnholyBlight",
    icon = "Interface/icons/spell_shadow_contagion",
    position = {880, -402},
    handler = "spellunholyblight",
    tooltips = {
        frFR = "|cffffffffChancre impie|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Un essaim infect d'insectes impies s'abat sur les victimes de votre Voile mortel\net leur inflige un montant de dégâts égal à 10% des dégâts infligés par Voile mortel en 10 secondes,\nen plus d'empêcher toutes les maladies présentes sur ces victimes d'être dissipées.|r",
        enUS = "|cffffffffUnholy Blight|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100An infected swarm of unholy insects descends on the victims of your Death Coil\nand deals damage equal to 10% of the damage done by Death Coil over 10 seconds,\nwhile preventing any diseases on those victims from being dispelled.|r"
    }
},

{
    id = "spellImpurity",
    name = "buttonSpellImpurity",
    icon = "Interface/icons/spell_shadow_shadowandflame",
    position = {990, -402},
    handler = "spellimpurity",
    tooltips = {
        frFR = "|cffffffffImpureté|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos sorts reçoivent un bénéfice supplémentaire de 20% de votre puissance d'attaque.|r",
        enUS = "|cffffffffImpurity|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Your spells receive an additional 20% of your attack power as bonus.|r"
    }
},

{
    id = "spellDirge",
    name = "buttonSpellDirge",
    icon = "Interface/icons/spell_shadow_shadesofdarkness",
    position = {1100, -402},
    handler = "spelldirge",
    tooltips = {
        frFR = "|cffffffffComplainte|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos sorts Frappe de mort, Frappe de peste et Frappe du Fléau génèrent 5 points de puissance runique supplémentaires.|r",
        enUS = "|cffffffffDirge|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Your Death Strike, Plague Strike, and Scourge Strike generate 5 additional runic power.|r"
    }
},

{
    id = "spellDesecration",
    name = "buttonSpellDesecration",
    icon = "Interface/icons/spell_shadow_shadowfiend",
    position = {718, -456},
    handler = "spelldesecration",
    tooltips = {
        frFR = "|cffffffffViolation|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos Frappes de peste et Frappes du Fléau provoquent l'effet Terre profanée.\nLes cibles dans la zone sont ralenties de 50% par les bras avides des morts tant que vous restez sur la terre impie.\nDure 20 secondes.|r",
        enUS = "|cffffffffDesecration|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Your Plague Strikes and Scourge Strikes trigger Desecrated Ground.\nEnemies within the area are slowed by 50% by the grasping hands of the dead as long as you remain on the desecrated earth.\nLasts 20 seconds.|r"
    }
},

{
    id = "spellMagicSuppression",
    name = "buttonSpellMagicSuppression",
    icon = "Interface/icons/spell_shadow_antimagicshell",
    position = {825, -456},
    handler = "spellmagicsuppression",
    tooltips = {
        frFR = "|cffffffffSuppression de la magie|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Toutes les formes de magie vous infligent 6% de dégâts en moins.\nDe plus, votre Carapace anti-magie absorbe 25% de dégâts des sorts supplémentaires.|r",
        enUS = "|cffffffffMagic Suppression|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100All forms of magic deal 6% less damage to you.\nAdditionally, your Anti-Magic Shell absorbs 25% more magic damage.|r"
    }
},
{
    id = "spellAntiMagicZone",
    name = "buttonSpellAntiMagicZone",
    icon = "Interface/icons/spell_deathknight_antimagiczone",
    position = {935, -456},
    handler = "spellantimagiczone",
    tooltips = {
        frFR = "|cffffffffZone anti-magie|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Place une grande Zone anti-magie stationnaire qui réduit de 75% les dégâts des sorts infligés aux membres du groupe ou du raid se trouvant à l'intérieur.\nLa Zone anti-magie dure 10 secondes.\nou jusqu'à ce que 12768 points de dégâts des sorts aient été absorbés.|r",
        enUS = "|cffffffffAnti-Magic Zone|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Places a large stationary Anti-Magic Zone that reduces spell damage taken by party or raid members within it by 75%.\nThe zone lasts for 10 seconds or until 12768 points of spell damage have been absorbed.|r"
    }
},

{
    id = "spellReaping",
    name = "buttonSpellReaping",
    icon = "Interface/icons/spell_shadow_shadetruesight",
    position = {1045, -456},
    handler = "spellreaping",
    tooltips = {
        frFR = "|cffffffffMoisson|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Chaque fois que vous touchez avec Frappe de sang ou Pestilence, il y a 100% de chances que la rune de sang devienne une rune de la mort lors de son activation.\nLes runes de la mort comptent comme une rune de sang, de givre ou impie.|r",
        enUS = "|cffffffffReaping|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Each time you hit with Blood Strike or Pestilence, there is a 100% chance that the blood rune becomes a death rune when activated.\nDeath runes count as blood, frost, or unholy runes.|r"
    }
},

{
    id = "spellDesolation",
    name = "buttonSpellDesolation",
    icon = "Interface/icons/spell_shadow_unholyfrenzy",
    position = {663, -510},
    handler = "spelldesolation",
    tooltips = {
        frFR = "|cffffffffDésolation|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos Frappes de sang vous font infliger 5% de dégâts supplémentaires avec toutes les attaques pendant 20 secondes.|r",
        enUS = "|cffffffffDesolation|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Your Blood Strikes cause you to deal 5% additional damage with all attacks for 20 seconds.|r"
    }
},

{
    id = "spellImprovedUnholyPresence",
    name = "buttonSpellImprovedUnholyPresence",
    icon = "Interface/icons/spell_deathknight_unholypresence",
    position = {770, -510},
    handler = "spellimprovedunholypresence",
    tooltips = {
        frFR = "|cffffffffPrésence impie améliorée|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Quand vous êtes en Présence de sang ou de givre, vous conservez l'augmentation de la vitesse de déplacement de 15% de Présence impie,\net le temps de recharge de vos runes est 10% plus rapide en Présence impie.|r",
        enUS = "|cffffffffImproved Unholy Presence|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100When in Blood or Frost Presence, you retain the 15% movement speed increase from Unholy Presence,\nand your rune cooldowns are 10% faster while in Unholy Presence.|r"
    }
},

{
    id = "spellCryptFever",
    name = "buttonSpellCryptFever",
    icon = "Interface/icons/spell_nature_nullifydisease",
    position = {880, -510},
    handler = "spellcryptfever",
    tooltips = {
        frFR = "|cffffffffFièvre de la crypte|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos maladies entraînent également la Fièvre de la crypte, qui augmente de 30% les dégâts infligés par les maladies à la cible.|r",
        enUS = "|cffffffffCrypt Fever|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Your diseases also cause Crypt Fever, which increases disease damage to the target by 30%.|r"
    }
},
{
    id = "spellBoneShield",
    name = "buttonSpellBoneShield",
    icon = "Interface/icons/inv_chest_leather_13",
    position = {990, -510},
    handler = "spellboneshield",
    tooltips = {
        frFR = "|cffffffffBouclier d'os|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Le chevalier de la mort est entouré de 3 os tourbillonnants.\nTant qu'il reste au moins un os, toutes les attaques contre le chevalier infligent 20% de dégâts en moins et les attaques, techniques et sorts du chevalier infligent 2% de dégâts en plus.\nChaque attaque infligeant des dégâts consomme un os.\nDure 5 min.|r",
        enUS = "|cffffffffBone Shield|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100The Death Knight is surrounded by 3 swirling bones.\nAs long as at least one bone remains, all attacks against the Death Knight deal 20% less damage, and the Death Knight's attacks, abilities, and spells deal 2% more damage.\nEach damaging attack consumes one bone.\nLasts for 5 min.|r"
    }
},

{
    id = "spellWanderingPlague",
    name = "buttonSpellWanderingPlague",
    icon = "Interface/icons/spell_shadow_callofbone",
    position = {1100, -510},
    handler = "spellwanderingplague",
    tooltips = {
        frFR = "|cffffffffPeste galopante|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Quand vos maladies infligent des dégâts à un ennemi,\nvous avez une chance égale à vos chances de coup critique en mêlée qu'elles infligent 100% de dégâts supplémentaires à la cible et à tous les ennemis se trouvant à moins de 8 mètres.\nIgnore les cibles porteuses d'un effet de sort annulé lorsque des dégâts sont subis.|r",
        enUS = "|cffffffffWandering Plague|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100When your diseases deal damage to an enemy,\nyou have a chance equal to your melee critical strike chance to deal 100% additional damage to the target and all enemies within 8 yards.\nIgnores targets affected by a canceled debuff when taking damage.|r"
    }
},

{
    id = "spellEbonPlaguebringer",
    name = "buttonSpellEbonPlaguebringer",
    icon = "Interface/icons/ability_creature_cursed_03",
    position = {716, -564},
    handler = "spellebonplaguebringer",
    tooltips = {
        frFR = "|cffffffffPorte-peste d'ébène|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Votre Fièvre de la crypte devient une Peste d'ébène, qui augmente les dégâts magiques subis de 13% en plus d'augmenter les dégâts infligés par les maladies.\nAugmente en permanence vos chances de coup critique avec les armes et les sorts de 3%.|r",
        enUS = "|cffffffffEbon Plaguebringer|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Your Crypt Fever becomes Ebon Plague, increasing magical damage taken by 13% and boosting the damage done by diseases.\nAlso permanently increases your critical strike chance with weapons and spells by 3%.|r"
    }
},

{
    id = "spellScourgeStrike",
    name = "buttonSpellScourgeStrike",
    icon = "Interface/icons/spell_deathknight_scourgestrike",
    position = {824, -564},
    handler = "spellscourgestrike",
    tooltips = {
        frFR = "|cffffffffFrappe du Fléau|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Une frappe impie qui inflige 84% des dégâts de l'arme sous forme de dégâts physiques plus 343.\nDe plus, pour chacune de vos maladies sur la cible, vous infligez un montant supplémentaire de dégâts d'Ombre égal à 12% des dégâts physiques infligés.|r",
        enUS = "|cffffffffScourge Strike|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100An unholy strike that deals 84% weapon damage as physical damage plus 343.\nAdditionally, for each of your diseases on the target, you deal additional Shadow damage equal to 12% of the physical damage dealt.|r"
    }
},

{
    id = "spellRageofRivendare",
    name = "buttonSpellRageofRivendare",
    icon = "Interface/icons/inv_weapon_halberd14",
    position = {934, -564},
    handler = "spellrageofrivendare",
    tooltips = {
        frFR = "|cffffffffRage de Vaillefendre|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos sorts et techniques infligent 10% de dégâts supplémentaires aux cibles atteintes de la Peste de sang.\nAugmente également votre expertise de 5.|r",
        enUS = "|cffffffffRage of Rivendare|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100Your spells and abilities deal 10% more damage to targets afflicted by Blood Plague.\nAlso increases your expertise by 5.|r"
    }
},
{
    id = "spellSummonGargoyle",
    name = "buttonSpellSummonGargoyle",
    icon = "Interface/icons/ability_hunter_pet_bat",
    position = {1045, -564},
    handler = "spellsummongargoyle",
    tooltips = {
        frFR = "|cffffffffInvocation d'une gargouille|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Une gargouille bombarde la cible et lui inflige des dégâts de Nature modifiés par la puissance d'attaque du chevalier de la mort.\nPersiste pendant 30 secondes.|r",
        enUS = "|cffffffffSummon Gargoyle|r\n|cffffffffTalent|r |cff00b700Unholy|r\n|cffffffffRequires|r |cffc51f23Death Knight|r\n|cffffd100A gargoyle bombards the target, dealing Nature damage modified by the Death Knight's attack power.\nLasts for 30 seconds.|r"
		}
	}
}


-- CreateSpellButton("buttonSpellViciousStrikes", "Interface/icons/spell_deathknight_plaguestrike", "|cffffffffAttaques vicieuses|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente de 6% les chances de coup critique et de 30% le bonus de dégâts des coups critiques de vos sorts Frappe de peste et Frappe du Fléau.|r", "spellviciousstrikes", 718, -240)
-- CreateSpellButton("buttonSpellVirulence", "Interface/icons/spell_shadow_burningspirit", "|cffffffffVirulence|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente vos chances de toucher avec vos sorts de 3% et réduit de 30% la probabilité que vos maladies de dégâts sur la durée puissent être soignées.|r", "spellvirulence", 825, -240)
-- CreateSpellButton("buttonSpellAnticipation", "Interface/icons/spell_nature_mirrorimage", "|cffffffffAnticipation|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente vos chances d'esquiver une attaque de 5%.|r", "spellanticipation", 935, -240)
-- CreateSpellButton("buttonSpellEpidemic", "Interface/icons/spell_shadow_shadowwordpain", "|cffffffffEpidémie|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente la durée de Peste de sang et Fièvre de givre de 6 sec.|r", "spellepidemic", 1045, -240)
-- CreateSpellButton("buttonSpellMorbidity", "Interface/icons/spell_shadow_deathanddecay", "|cffffffffMorbidité|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente de 15% les dégâts et les soins de votre sort Voile mortel et réduit le temps de recharge de votre sort Mort et décomposition de 15 sec.|r", "spellmorbidity", 663, -293)
-- CreateSpellButton("buttonSpellUnholyCommand", "Interface/icons/spell_deathknight_strangulate", "|cffffffffAutorité impie|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Réduit le temps de recharge de votre technique Poigne de la mort de 10 sec.|r", "spellunholycommand", 770, -293)
-- CreateSpellButton("buttonSpellRavenousDead", "Interface/icons/spell_deathknight_gnaw_ghoul", "|cffffffffMorts voraces|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente votre total de Force de 3% et la part de votre Force et de votre Endurance que reçoivent vos goules de 60%.|r", "spellravenousdead", 880, -293)
-- CreateSpellButton("buttonSpellOutbreak", "Interface/icons/spell_shadow_plaguecloud", "|cffffffffPoussée de fièvre|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Augmente les dégâts de Frappe de peste de 30% et de Frappe du Fléau de 20%.|r", "spelloutbreak", 990, -293)
-- CreateSpellButton("buttonSpellNecrosis", "Interface/icons/inv_weapon_shortblade_60", "|cffffffffNécrose|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos attaques automatiques infligent 20% de dégâts d'Ombre supplémentaires.|r", "spellnecrosis", 1100, -293)
-- CreateSpellButton("buttonSpellCorpseExplosion", "Interface/icons/ability_creature_disease_02", "|cffffffffExplosion morbide|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Fait exploser un cadavre et inflige 166 points de dégâts d'Ombre à tous les ennemis se trouvant à moins de 10 mètres.\nUtilise un cadavre proche si la cible n'en est pas un.\nN'affecte pas les cadavres mécaniques ou d'élémentaires.|r", "spellcorpseexplosion", 718, -348)
-- CreateSpellButton("buttonSpellOnaPaleHorse", "Interface/icons/spell_deathknight_summondeathcharger", "|cffffffffSur un cheval pâle|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vous devenez aussi difficile à arrêter que la mort elle-même.\nLa durée de tous les effets d'étourdissement et de peur contre vous est réduite de 20%, et la vitesse de votre monture est augmentée de 20%.\nNe s'additionne pas avec les autres effets qui augmentent la vitesse de déplacement.|r", "spellonapalehorse", 825, -348)
-- CreateSpellButton("buttonSpellBloodCakedBlade", "Interface/icons/ability_criticalstrike", "|cffffffffLame incrustée de sang|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos attaques automatiques ont 30% de chances de causer une Frappe incrustée de sang, qui inflige 25% des dégâts de l'arme plus 12.5% pour chacune de vos maladies sur la cible.|r", "spellbloodcakedblade", 935, -348)
-- CreateSpellButton("buttonSpellNightoftheDead", "Interface/icons/spell_deathknight_armyofthedead", "|cffffffffNuit des morts|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Réduit le temps de recharge de Réanimation morbide de 90 sec.\net celui d'Armée des morts de 4 min.\nRéduit également les dégâts infligés à votre familier par les attaques à zone d'effet des créatures de 90%.|r", "spellnightofthedead", 1045, -348)
-- CreateSpellButton("buttonSpellMasterofGhouls", "Interface/icons/spell_shadow_animatedead", "|cffffffffMaître des goules|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Réduit le temps de recharge de Réanimation morbide de 60 sec.\net la goule invoquée par votre sort Réanimation morbide est considérée comme un familier sous votre contrôle.\nContrairement aux goules normales de chevalier de la mort, votre familier n'a pas de durée limitée.|r", "spellmasterofghouls", 663, -402)
-- CreateSpellButton("buttonSpellGhoulFrenzy", "Interface/icons/ability_ghoulfrenzy", "|cffffffffFrénésie de la goule|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Confère à votre familier un bonus de 25% à la hâte pendant 30 seconds et lui rend 60% de ses points de vie pendant la durée de l'effet.|r", "spellghoulfrenzy", 770, -402)
-- CreateSpellButton("buttonSpellUnholyBlight", "Interface/icons/spell_shadow_contagion", "|cffffffffChancre impie|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Un essaim infect d'insectes impies s'abat sur les victimes de votre Voile mortel\net leur inflige un montant de dégâts égal à 10% des dégâts infligés par Voile mortel en 10 seconds,\nen plus d'empêcher toutes les maladies présentes sur ces victimes d'être dissipées.|r", "spellunholyblight", 880, -402)
-- CreateSpellButton("buttonSpellImpurity", "Interface/icons/spell_shadow_shadowandflame", "|cffffffffImpureté|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos sorts reçoivent un bénéfice supplémentaire de 20% de votre puissance d'attaque.|r", "spellimpurity", 990, -402)
-- CreateSpellButton("buttonSpellDirge", "Interface/icons/spell_shadow_shadesofdarkness", "|cffffffffComplainte|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos sorts Frappe de mort, Frappe de peste et Frappe du Fléau génèrent 5 points de puissance runique supplémentaires.|r", "spelldirge", 1100, -402)
-- CreateSpellButton("buttonSpellDesecration", "Interface/icons/spell_shadow_shadowfiend", "|cffffffffViolation|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos Frappes de peste et Frappes du Fléau provoquent l'effet Terre profanée.\nLes cibles dans la zone sont ralenties de 50% par les bras avides des morts tant que vous restez sur la terre impie.\nDure 20 seconds.|r", "spelldesecration", 718, -456)
-- CreateSpellButton("buttonSpellMagicSuppression", "Interface/icons/spell_shadow_antimagicshell", "|cffffffffSuppression de la magie|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Toutes les formes de magie vous infligent 6% de dégâts en moins.\nDe plus, votre Carapace anti-magie absorbe 25% de dégâts des sorts supplémentaires.|r", "spellmagicsuppression", 825, -456)
-- CreateSpellButton("buttonSpellAntiMagicZone", "Interface/icons/spell_deathknight_antimagiczone", "|cffffffffZone anti-magie|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Place une grande Zone anti-magie stationnaire qui réduit de 75% les dégâts des sorts infligés aux membres du groupe ou du raid se trouvant à l'intérieur.\nLa Zone anti-magie dure 10 seconds.\nou jusqu'à ce que 12768 points de dégâts des sorts aient été absorbés.|r", "spellantimagiczone", 935, -456)
-- CreateSpellButton("buttonSpellReaping", "Interface/icons/spell_shadow_shadetruesight", "|cffffffffMoisson|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Chaque fois que vous touchez avec Frappe de sang ou Pestilence, il y a 100% de chances que la rune de sang devienne une rune de la mort lors de son activation.\nLes runes de la mort comptent comme une rune de sang, de givre ou impie.|r", "spellreaping", 1045, -456)
-- CreateSpellButton("buttonSpellDesolation", "Interface/icons/spell_shadow_unholyfrenzy", "|cffffffffDésolation|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos Frappes de sang vous font infliger 5% de dégâts supplémentaires avec toutes les attaques pendant 20 seconds.|r", "spelldesolation", 663, -510)
-- CreateSpellButton("buttonSpellImprovedUnholyPresence", "Interface/icons/spell_deathknight_unholypresence", "|cffffffffPrésence impie améliorée|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Quand vous êtes en Présence de sang ou de givre, vous conservez l'augmentation de la vitesse de déplacement de 15% de Présence impie,\net le temps de recharge de vos runes est 10% plus rapide en Présence impie.|r", "spellimprovedunholypresence", 770, -510)
-- CreateSpellButton("buttonSpellCryptFever", "Interface/icons/spell_nature_nullifydisease", "|cffffffffFièvre de la crypte|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos maladies entraînent également la Fièvre de la crypte, qui augmente de 30% les dégâts infligés par les maladies à la cible.|r", "spellcryptfever", 880, -510)
-- CreateSpellButton("buttonSpellBoneShield", "Interface/icons/inv_chest_leather_13", "|cffffffffBouclier d'os|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Le chevalier de la mort est entouré de 3 os tourbillonnants.\nTant qu'il reste au moins un os, toutes les attaques contre le chevalier infligent 20% de dégâts en moins et les attaques, techniques et sorts du chevalier infligent 2% de dégâts en plus.\nChaque attaque infligeant des dégâts consomme un os.\nDure 5 min.|r", "spellboneshield", 990, -510)
-- CreateSpellButton("buttonSpellWanderingPlague", "Interface/icons/spell_shadow_callofbone", "|cffffffffPeste galopante|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Quand vos maladies infligent des dégâts à un ennemi,\nvous avez une chance égale à vos chances de coup critique en mêlée qu'elles infligent 100% de dégâts supplémentaires à la cible et à tous les ennemis se trouvant à moins de 8 mètres.\nIgnore les cibles porteuses d'un effet de sort annulé lorsque des dégâts sont subis.|r", "spellwanderingplague", 1100, -510)
-- CreateSpellButton("buttonSpellEbonPlaguebringer", "Interface/icons/ability_creature_cursed_03", "|cffffffffPorte-peste d'ébène|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Votre Fièvre de la crypte devient une Peste d'ébène, qui augmente les dégâts magiques subis de 13% en plus d'augmenter les dégâts infligés par les maladies.\nAugmente en permanence vos chances de coup critique avec les armes et les sorts de 3%.|r", "spellebonplaguebringer", 716, -564)
-- CreateSpellButton("buttonSpellScourgeStrike", "Interface/icons/spell_deathknight_scourgestrike", "|cffffffffFrappe du Fléau|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Une frappe impie qui inflige 84% des dégâts de l'arme sous forme de dégâts physiques plus 343.\nDe plus, pour chacune de vos maladies sur la cible, vous infligez un montant supplémentaire de dégâts d'Ombre égal à 12% des dégâts physiques infligés.|r", "spellscourgestrike", 824, -564)
-- CreateSpellButton("buttonSpellRageofRivendare", "Interface/icons/inv_weapon_halberd14", "|cffffffffRage de Vaillefendre|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Vos sorts et techniques infligent 10% de dégâts supplémentaires aux cibles atteintes de la Peste de sang.\nAugmente également votre expertise de 5.|r", "spellrageofrivendare", 934, -564)
-- CreateSpellButton("buttonSpellSummonGargoyle", "Interface/icons/ability_hunter_pet_bat", "|cffffffffInvocation d'une gargouille|r\n|cffffffffTalent|r |cff00b700Impie|r\n|cffffffffRequiert|r |cffc51f23Chevalier de la mort|r\n|cffffd100Une gargouille bombarde la cible et lui inflige des dégâts de Nature modifiés par la puissance d'attaque du chevalier de la mort.\nPersiste pendant 30 seconds.|r", "spellsummongargoyle", 1045, -564)

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

-- Créez le bouton Save à l'intérieur de la fenêtre frameTalentDeathknight
local saveButton = CreateFrame("Button", "saveButton", frameTalentDeathknight, "UIPanelButtonTemplate")
saveButton:SetSize(85, 25)
saveButton:SetPoint("BOTTOMRIGHT", buttonTalentDeathknightClose, "BOTTOMLEFT", -185, 5) -- Place le bouton Save à gauche du bouton Close
saveButton:SetText(saveButtonText)

-- Fonction qui prend un screenshot quand le bouton est cliqué
saveButton:SetScript("OnClick", function()
    Screenshot()  -- Prendre un screenshot et l'enregistrer dans le dossier Screenshots du jeu
    print(screenshotMessage)  -- Affiche un message de confirmation en fonction de la locale
end)

-- Affiche l'UI des talents
--frameTalentDeathknight:Show()

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

-- Créez le bouton Reset à l'intérieur de la fenêtre frameTalentDeathknight
local buttonReset = CreateFrame("Button", "buttonReset", frameTalentDeathknight, "UIPanelButtonTemplate")
buttonReset:SetSize(85, 25)
buttonReset:SetPoint("BOTTOMRIGHT", buttonTalentDeathknightClose, "BOTTOMLEFT", -95, 5) -- Place le bouton Reset à gauche du bouton Reload
buttonReset:SetText(buttonResetText)

local function ResetTalents()
    -- Ajoutez ici la logique pour réinitialiser les talents du joueur
    AIO.Handle("TalentDeathknightspell", "ResetTalents")
    resetButtonClicked = true -- Marquez le bouton Réinitialiser comme cliqué
end

buttonReset:SetScript("OnClick", ResetTalents)

-- Créez le bouton Reload à l'intérieur de la fenêtre frameTalentDeathknight
local buttonReload = CreateFrame("Button", "buttonReload", frameTalentDeathknight, "UIPanelButtonTemplate")
buttonReload:SetSize(85, 25)
buttonReload:SetPoint("BOTTOMRIGHT", buttonTalentDeathknightClose, "BOTTOMLEFT", -5, 5) -- Place le bouton Reload à gauche du bouton Close
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
        frameTalentDeathknight:Hide()
        buttonReload:Hide()
        PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
    else
        frameTalentDeathknight:Show()
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
        frFR = "|cffffffffTalents|r |cffc51f23(Chevalier de la mort)|r\n\nL'éventail des talents disponibles\npour améliorer et spécialiser\nvotre personnage.",
        enUS = "|cffffffffTalents|r |cffc51f23(Death Knight)|r\n\nThe range of available talents\nfor enhancing and specializing\nyour character."
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

-- Vérifier si le joueur est un Deathknight avant de créer le bouton
local playerClass = select(2, UnitClass("player")) -- Obtenir la classe du joueur
if playerClass == "DEATHKNIGHT" then
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
DeathknightHandlers.UpdateTalentCount = function(player, talentsAppris)
    if fontTalentDeathknightFrameText then
        fontTalentDeathknightFrameText:SetText(talentsAppris .. " / " .. MAX_TALENTS)
    end
end

-- Mise à jour des points de talent utilisés avec texte localisé
DeathknightHandlers.UpdateTalentPointsUsed = function(player, pointsUsed, pointsBeforeReset)
    -- Utilisation du texte localisé pour les points avant réinitialisation
    print(string.format(GetLocalizedPointsBeforeResetText(), pointsBeforeReset))
end

-- Affichage des talents restants (items 338404 dans le sac)
DeathknightHandlers.UpdateTalentItemCount = function(player, count)
    if fontTalentPointsRemainingText then
        fontTalentPointsRemainingText:SetText("|cFFC41F3BTalents restants : " .. count .. "|r")
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
        fontTalentPointsRemainingText:SetText("|cFFC41F3BTalents restants : " .. (count or 0) .. "|r")
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
if playerClass == "DEATHKNIGHT" then
    -- Surcharge OnHide pour synchroniser talentsWindowOpen quand Échap est pressé
    local _originalOnHide = frameTalentDeathknight:GetScript("OnHide")
    frameTalentDeathknight:SetScript("OnHide", function(self)
        talentsWindowOpen = false
        if _originalOnHide then _originalOnHide(self) end
    end)
    -- WoW appelle automatiquement Hide() sur les frames listées ici quand Échap est pressé
    tinsert(UISpecialFrames, "frameTalentDeathknight")
end