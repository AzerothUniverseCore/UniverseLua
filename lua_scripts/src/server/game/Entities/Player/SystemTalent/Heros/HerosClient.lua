local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local HerosHandlers = AIO.AddHandlers("TalentHerosspell", {})

function HerosHandlers.ShowTalentHeros(player)
    frameTalentHeros:Show()
    -- Redemande au serveur l’état visuel au cas où
    AIO.Handle("TalentHerosspell", "RequestLearnedTalents")
	-- Redemande le nombre de talents restants
    AIO.Handle("TalentHerosspell", "GetTalentItemCount")
end

local MAX_TALENTS = 8 -- Définition du nombre maximal de talents que le joueur peut apprendre

local OPEN_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_final_trait_unlocked.ogg"
local CLOSE_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_trait_refund_end.ogg"
local SPELL_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_80_azeritearmor_rotationends_02.ogg"

-- Attribute window
local frameTalentHeros = CreateFrame("Frame", "frameTalentHeros", UIParent)
frameTalentHeros:SetSize(1200, 650)
frameTalentHeros:SetMovable(true)
frameTalentHeros:EnableMouse(true)
frameTalentHeros:RegisterForDrag("LeftButton")
frameTalentHeros:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, -50) -- Adjust the X and Y coordinates
frameTalentHeros:SetBackdrop(
{
    -- bgFile = "interface/TalentFrame/talentsclassbackgroundhero", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    bgFile = "interface/TalentFrame/Template/Class/Heros/talentsclassbackgroundheros2", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedheros", --Interface/DialogFrame/UI-DialogBox-Border
    edgeSize = 20,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})

-- Ajoutez la texture de l'icône du Héros
local heroIcon = frameTalentHeros:CreateTexture("HerosIcon", "OVERLAY")
heroIcon:SetTexture("Interface\\TalentFrame\\Template\\Class\\Heros\\IconeHeros.blp")
heroIcon:SetSize(60, 60)
heroIcon:SetPoint("TOPLEFT", frameTalentHeros, "TOPLEFT", -10, 10)

-- Template Talent Frame

-- Ajoute une textureone pour l'image BLP
local textureone = frameTalentHeros:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
textureone:SetTexture("Interface\\TalentFrame\\Template\\Class\\Heros\\TalentFrameTemplate.blp")
textureone:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
textureone:SetPoint("TOPLEFT", frameTalentHeros, "TOPLEFT", -150, 220) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentHeros:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Ajoute une texturetwo pour l'image BLP
local texturetwo = frameTalentHeros:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
texturetwo:SetTexture("Interface\\TalentFrame\\Template\\Class\\Heros\\TalentFrameTemplateOriginal.blp")
texturetwo:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
texturetwo:SetPoint("TOPRIGHT", frameTalentHeros, "TOPRIGHT", 150, 110) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentHeros:SetBackdropBorderColor(253, 197, 184) -- Couleur Rose

-- Drag & Drop
frameTalentHeros:SetScript("OnDragStart", frameTalentHeros.StartMoving)
frameTalentHeros:SetScript("OnHide", frameTalentHeros.StopMovingOrSizing)
frameTalentHeros:SetScript("OnDragStop", frameTalentHeros.StopMovingOrSizing)
frameTalentHeros:Hide()

-- Nouveau template d'arête
frameTalentHeros:SetBackdropBorderColor(135, 135, 237) -- Couleur pourpre

-- Close button
local buttonTalentHerosClose = CreateFrame("Button", "buttonTalentHerosClose", frameTalentHeros, "UIPanelCloseButton")
buttonTalentHerosClose:SetPoint("TOPRIGHT", -12, -12)
buttonTalentHerosClose:EnableMouse(true)
buttonTalentHerosClose:SetSize(32, 32)

local function CloseTalentWindow()
    frameTalentHeros:Hide()
    PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
end

-- Associez la fonction de fermeture au bouton de fermeture
buttonTalentHerosClose:SetScript("OnClick", CloseTalentWindow)

-- Title bar
local frameTalentHerosTitleBar = CreateFrame("Frame", "frameTalentHerosTitleBar", frameTalentHeros, nil)
frameTalentHerosTitleBar:SetSize(135, 25)
frameTalentHerosTitleBar:SetBackdrop(
{
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedheros",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentHerosTitleBar:SetPoint("TOP", 0, 20)

local fontTalentHerosTitleText = frameTalentHerosTitleBar:CreateFontString("fontTalentHerosTitleText")
fontTalentHerosTitleText:SetFont("Fonts\\FRIZQT__.TTF", 13)
fontTalentHerosTitleText:SetSize(190, 5)
fontTalentHerosTitleText:SetPoint("CENTER", 0, 0)
fontTalentHerosTitleText:SetText("|cffFFC125Talents|r")

-- Détecte la langue du client
local locale = GetLocale() -- Retourne "enUS", "frFR", etc.

-- Table des traductions
local localizedTexts = {
    enUS = "|cffFFC125Hero|r",
    frFR = "|cffFFC125Héros|r",
}

-- Récupère le texte correspondant à la langue actuelle ou par défaut en anglais
local textToDisplay = localizedTexts[locale] or localizedTexts["enUS"]

-- Création de l'élément de texte
local fontTalentHerosFrameText = frameTalentHerosTitleBar:CreateFontString("fontTalentHerosFrameText")
fontTalentHerosFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentHerosFrameText:SetSize(200, 5)
fontTalentHerosFrameText:SetPoint("TOPLEFT", frameTalentHerosTitleBar, "BOTTOMLEFT", -30, -35) -- Ajustez l'offset si nécessaire
fontTalentHerosFrameText:SetText(textToDisplay)

-- Remplacez votre ligne existante pour la création du texte par celle-ci
local fontTalentHerosFrameText = frameTalentHerosTitleBar:CreateFontString("fontTalentHerosFrameText")
fontTalentHerosFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentHerosFrameText:SetSize(200, 5)
fontTalentHerosFrameText:SetPoint("TOPLEFT", frameTalentHerosTitleBar, "BOTTOMLEFT", -30, -60) -- Adjust the Y offset as needed
fontTalentHerosFrameText:SetText("0 / " .. MAX_TALENTS) -- Initialisez le texte avec 0 talents appris

-------------------------------------------------------------
-- Affichage "Talents restants" (item 338404 dans le sac)
-------------------------------------------------------------

local frameTalentPointsRemaining = CreateFrame("Frame", "frameTalentPointsRemaining", frameTalentHeros, nil)
frameTalentPointsRemaining:SetSize(220, 30)
frameTalentPointsRemaining:SetBackdrop({
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedheros",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentPointsRemaining:SetPoint("BOTTOMRIGHT", frameTalentHeros, "BOTTOMRIGHT", -960, 10)

local fontTalentPointsRemainingText = frameTalentPointsRemaining:CreateFontString("fontTalentPointsRemainingText")
fontTalentPointsRemainingText:SetFont("Fonts\\FRIZQT__.TTF", 14)
fontTalentPointsRemainingText:SetSize(210, 20)
fontTalentPointsRemainingText:SetPoint("CENTER", 0, 0)
fontTalentPointsRemainingText:SetText("|cFFFF6EBFTalents restants : 0|r")
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
HerosHandlers.UpdateLearnedTalents = function(player, learnedSpells)
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

    local button = CreateFrame("Button", name, frameTalentHeros, nil)
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
                AIO.Handle("TalentHerosspell", talentHandler, 1)
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
local spells = {
{
    id = "spellBeserker",
    name = "buttonSpellBeserker",
    icon = "Interface/icons/ability_warrior_intensifyrage",
    position = {170, -270},
    handler = "spellbeserker",
    tooltips = {
        frFR = "|cffffffffBerserker|r\n|cffffffffTalent|r |cffe26a5dForce|r\n|cffffffffRequiert|r |cfffdc5b8Héros|r\n|cffffff00Augmente tous les dégâts infligés de 25%\n|cffffff00et tous les dégâts subis de 10%.|r",
        enUS = "|cffffffffBerserker|r\n|cffffffffTalent|r |cffe26a5dStrength|r\n|cffffffffRequires|r |cfffdc5b8Hero|r\n|cffffff00Increases all damage dealt by 25%\n|cffffff00and all damage taken by 10%.|r"
    }
},
{
    id = "spellRallyingCry",
    name = "buttonSpellRallyingCry",
    icon = "Interface/icons/Ability_Warrior_RallyingCry",
    position = {280, -270},
    handler = "spellrallyingcry",
    tooltips = {
        frFR = "|cffffffffCri de ralliement|r\n|cffffffffTalent|r |cffe26a5dForce|r\n|cffffffffRequiert|r |cfffdc5b8Héros|r\n|cffffff00Le héros crie et augmente de 130 la puissance d'attaque de tous les membres du groupe\n|cffffff00et du raid dans un rayon de 30 mètres. Dure 2 min.|r",
        enUS = "|cffffffffRallying Cry|r\n|cffffffffTalent|r |cffe26a5dStrength|r\n|cffffffffRequires|r |cfffdc5b8Hero|r\n|cffffff00The hero shouts, increasing attack power by 130 for all group\n|cffffff00and raid members within 30 yards. Lasts 2 min.|r"
    }
},
{
    id = "spellSpeed",
    name = "buttonSpellSpeed",
    icon = "Interface/icons/warrior_talent_icon_blitz",
    position = {390, -270},
    handler = "spellspeed",
    tooltips = {
        frFR = "|cffffffffVitesse|r\n|cffffffffTalent|r |cffe7e384Adresse|r\n|cffffffffRequiert|r |cfffdc5b8Héros|r\n|cffffff00Augmente la vitesse de déplacement du héros de 40% pendant 15 secondes.\n|cffffff00N'interrompt pas le camouflage.|r",
        enUS = "|cffffffffSpeed|r\n|cffffffffTalent|r |cffe7e384Agility|r\n|cffffffffRequires|r |cfffdc5b8Hero|r\n|cffffff00Increases the hero's movement speed by 40% for 15 seconds.\n|cffffff00Does not break stealth.|r"
    }
},
{
    id = "spellRuse",
    name = "buttonSpellRuse",
    icon = "Interface/icons/ability_rogue_vigor",
    position = {225, -323},
    handler = "spellruse",
    tooltips = {
        frFR = "|cffffffffRuse|r\n|cffffffffTalent|r |cffe7e384Adresse|r\n|cffffffffRequiert|r |cfffdc5b8Héros|r\n|cffffff00Camouflé pendant 15 secondes.|r",
        enUS = "|cffffffffRuse|r\n|cffffffffTalent|r |cffe7e384Agility|r\n|cffffffffRequires|r |cfffdc5b8Hero|r\n|cffffff00Stealthed for 15 seconds.|r"
    }
},
{
    id = "spellDisengage",
    name = "buttonSpellDisengage",
    icon = "Interface/icons/ability_racial_rocketjump",
    position = {335, -323},
    handler = "spelldisengage",
    tooltips = {
        frFR = "|cffffffffDésengagement|r\n|cffffffffTalent|r |cffe7e384Adresse|r\n|cffffffffRequiert|r |cfffdc5b8Héros|r\n|cffffff00Retirez tous les pièges et partez en voûte.\n|cffffff00Les ennemis proches subissent 13.13% de la puissance d'attaque de dégâts physiques\n|cffffff00et voient leur vitesse de déplacement réduite de 70% pendant 3 sec.|r",
        enUS = "|cffffffffDisengage|r\n|cffffffffTalent|r |cffe7e384Agility|r\n|cffffffffRequires|r |cfffdc5b8Hero|r\n|cffffff00Removes all traps and vaults away.\n|cffffff00Nearby enemies take 13.13% of attack power as physical damage\n|cffffff00and have their movement speed reduced by 70% for 3 sec.|r"
    }
},


-- CreateSpellButton("buttonSpellBerserker", "Interface/icons/ability_warrior_intensifyrage", "|cffffffffBerserker\n|cffffffffTalent |cffe26a5dForce\n|cffffffffRequiert |cfffdc5b8Heros\n|cffffff00Augmente tous les dégâts infligés de 25%\n|cffffff00et tous les dégâts subis de 10%.", "spellbeserker", 170, -270)
-- CreateSpellButton("buttonSpellRallyingCry", "Interface/icons/Ability_Warrior_RallyingCry", "|cffffffffCri de ralliement\n|cffffffffTalent |cffe26a5dForce\n|cffffffffRequiert |cfffdc5b8Heros\n|cffffff00Le héros crie et augmente de 130 la puissance d'attaque de tous les membres du groupe\n|cffffff00et du raid dans un rayon de 30 mètres. Dure 2 min.", "spellrallyingcry", 280, -270)
-- CreateSpellButton("buttonSpellSpeed", "Interface/icons/warrior_talent_icon_blitz", "|cffffffffVitesse\n|cffffffffTalent |cffe7e384Adresse\n|cffffffffRequiert |cfffdc5b8Heros\n|cffffff00Augmente la vitesse de déplacement du héros de 40% pendant 15 secondes.\n|cffffff00N'interrompt pas le camouflage.", "spellspeed", 390, -270)
-- CreateSpellButton("buttonSpellRuse", "Interface/icons/ability_rogue_vigor", "|cffffffffRuse\n|cffffffffTalent |cffe7e384Adresse\n|cffffffffRequiert |cfffdc5b8Heros\n|cffffff00Camouflé pendant 15 secondes.", "spellruse", 225, -323)
-- CreateSpellButton("buttonSpellDisengage", "Interface/icons/ability_racial_rocketjump", "|cffffffffDésengagement\n|cffffffffTalent |cffe7e384Adresse\n|cffffffffRequiert |cfffdc5b8Heros\n|cffffff00Retirez tous les pièges et partez en voûte.\n|cffffff00Les ennemis proches subissent 13.13% de la puissance d'attaque de dégâts physiques\n|cffffff00et voient leur vitesse de déplacement réduite de 70% pendant 3 sec.", "spelldisengage", 335, -323)

-- Template 2

{
    id = "spellLightningStrike",
    name = "buttonSpellLightningStrike",
    icon = "Interface/icons/ability_thunderking_lightningwhip",
    position = {805, -268},
    handler = "spelllightningstrike",
    tooltips = {
        frFR = "|cffffffffFoudre|r\n|cffffffffTalent|r |cff00bfffVolonté|r\n|cffffffffRequiert|r |cfffdc5b8Héros|r\n|cffffff00Inflige 6657 points de dégâts et rebondit jusqu'à 10 cibles.|r",
        enUS = "|cffffffffLightning Strike|r\n|cffffffffTalent|r |cff00bfffWillpower|r\n|cffffffffRequires|r |cfffdc5b8Hero|r\n|cffffff00Deals 6657 damage and jumps to up to 10 targets.|r"
    }
},
{
    id = "spellFireball",
    name = "buttonSpellFireball",
    icon = "Interface/icons/Spell_Fire_FireBolt",
    position = {915, -268},
    handler = "spellfireball",
    tooltips = {
        frFR = "|cffffffffBoule de feu|r\n|cffffffffTalent|r |cff00bfffVolonté|r\n|cffffffffRequiert|r |cfffdc5b8Héros|r\n|cffffff00Projette une boule ardente qui inflige 6657 à 6791 points de dégâts de Feu et 60 points de dégâts de Feu supplémentaires en 8 seconds.|r",
        enUS = "|cffffffffFireball|r\n|cffffffffTalent|r |cff00bfffWillpower|r\n|cffffffffRequires|r |cfffdc5b8Hero|r\n|cffffff00Hurls a fiery ball that deals 6657 to 6791 Fire damage and an additional 60 Fire damage over 8 seconds.|r"
    }
},
{
    id = "spellFrostball",
    name = "buttonSpellFrostball",
    icon = "Interface/icons/Spell_Fire_BlueFlameBolt",
    position = {750, -323},
    handler = "spellfrostball",
    tooltips = {
        frFR = "|cffffffffBoule de givre|r\n|cffffffffTalent|r |cff00bfffVolonté|r\n|cffffffffRequiert|r |cfffdc5b8Héros|r\n|cffffff00Lance un boule de givre sur l'ennemi, lui inflige de 6889 à 6923 points de dégâts de Givre et réduit sa vitesse de déplacement de 40% pendant 9 seconds.|r",
        enUS = "|cffffffffFrostball|r\n|cffffffffTalent|r |cff00bfffWillpower|r\n|cffffffffRequires|r |cfffdc5b8Hero|r\n|cffffff00Launches a frost ball at the enemy, dealing 6889 to 6923 Frost damage and reducing its movement speed by 40% for 9 seconds.|r"
    }
},
{
    id = "spellDivineFury",
    name = "buttonSpellDivineFury",
    icon = "Interface/icons/Spell_DeathKnight_IceBoundFortitude",
    position = {860, -323},
    handler = "spelldivinefury",
    tooltips = {
        frFR = "|cffffffffFureur divine|r\n|cffffffffTalent|r |cff00bfffVolonté|r\n|cffffffffRequiert|r |cfffdc5b8Héros|r\n|cffffff00Des éclats de givre s'abattent sur la zone ciblée et infligent 3792 points de dégâts de Givre en 8 seconds.|r",
        enUS = "|cffffffffDivine Fury|r\n|cffffffffTalent|r |cff00bfffWillpower|r\n|cffffffffRequires|r |cfffdc5b8Hero|r\n|cffffff00Shards of frost rain down on the targeted area, dealing 3792 Frost damage over 8 seconds.|r"
    }
},
{
    id = "spellIgnition",
    name = "buttonSpellIgnition",
    icon = "Interface/icons/Ability_Mage_FireStarter",
    position = {970, -323},
    handler = "spellignition",
    tooltips = {
        frFR = "|cffffffffEmbrasement|r\n|cffffffffTalent|r |cff00bfffVolonté|r\n|cffffffffRequiert|r |cfffdc5b8Héros|r\n|cffffff00Projette la cible de 100m et inflige 3985 points de dégâts de Feu toutes les 3 sec.|r",
        enUS = "|cffffffffIgnition|r\n|cffffffffTalent|r |cff00bfffWillpower|r\n|cffffffffRequires|r |cfffdc5b8Hero|r\n|cffffff00Launches the target 100m and deals 3985 Fire damage every 3 sec.|r"
		}
	}
}


-- CreateSpellButton("buttonSpellLightningStrike", "Interface/icons/ability_thunderking_lightningwhip", "|cffffffffFoudre\n|cffffffffTalent |cff00bfffVolonté\n|cffffffffRequiert |cfffdc5b8Heros\n|cffffff00Inflige 6657 points de dégâts et rebondit jusqu'à 10 cibles.", "spelllightningstrike", 805, -268)
-- CreateSpellButton("buttonSpellFireball", "Interface/icons/Spell_Fire_FireBolt", "|cffffffffBoule de feu\n|cffffffffTalent |cff00bfffVolonté\n|cffffffffRequiert |cfffdc5b8Heros\n|cffffff00Projette une boule ardente qui inflige 6657 à 6791 points de dégâts de Feu et 60 points de dégâts de Feu supplémentaires en 8 seconds.", "spellfireball", 915, -268)
-- CreateSpellButton("buttonSpellFrostball", "Interface/icons/Spell_Fire_BlueFlameBolt", "|cffffffffBoule de givre\n|cffffffffTalent |cff00bfffVolonté\n|cffffffffRequiert |cfffdc5b8Heros\n|cffffff00Lance un boule de givre sur l'ennemi, lui inflige de 6889 à 6923 points de dégâts de Givre et réduit sa vitesse de déplacement de 40% pendant 9 seconds.", "spellfrostball", 750, -323)
-- CreateSpellButton("buttonSpellDivinefury", "Interface/icons/Spell_DeathKnight_IceBoundFortitude", "|cffffffffFureur divine\n|cffffffffTalent |cff00bfffVolonté\n|cffffffffRequiert |cfffdc5b8Heros\n|cffffff00Des éclats de givre s'abattent sur la zone ciblée et infligent 3792 points de dégâts de Givre en 8 seconds.", "spelldivinefury", 860, -323)
-- CreateSpellButton("buttonSpellIgnition", "Interface/icons/Ability_Mage_FireStarter", "|cffffffffEmbrasement\n|cffffffffTalent |cff00bfffVolonté\n|cffffffffRequiert |cfffdc5b8Heros\n|cffffff00Projette la cible de 100m et inflige 3985 points de dégâts de Feu toutes les 3 sec.", "spellignition", 970, -323)

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

-- Créez le bouton Save à l'intérieur de la fenêtre frameTalentHeros
local saveButton = CreateFrame("Button", "saveButton", frameTalentHeros, "UIPanelButtonTemplate")
saveButton:SetSize(85, 25)
saveButton:SetPoint("BOTTOMRIGHT", buttonTalentHerosClose, "BOTTOMLEFT", -185, 5) -- Place le bouton Save à gauche du bouton Close
saveButton:SetText(saveButtonText)

-- Fonction qui prend un screenshot quand le bouton est cliqué
saveButton:SetScript("OnClick", function()
    Screenshot()  -- Prendre un screenshot et l'enregistrer dans le dossier Screenshots du jeu
    print(screenshotMessage)  -- Affiche un message de confirmation en fonction de la locale
end)

-- Affiche l'UI des talents
--frameTalentHeros:Show()

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

-- Créez le bouton Reset à l'intérieur de la fenêtre frameTalentHeros
local buttonReset = CreateFrame("Button", "buttonReset", frameTalentHeros, "UIPanelButtonTemplate")
buttonReset:SetSize(85, 25)
buttonReset:SetPoint("BOTTOMRIGHT", buttonTalentHerosClose, "BOTTOMLEFT", -95, 5) -- Place le bouton Reset à gauche du bouton Reload
buttonReset:SetText(buttonResetText)

local function ResetTalents()
    -- Ajoutez ici la logique pour réinitialiser les talents du joueur
    AIO.Handle("TalentHerosspell", "ResetTalents")
    resetButtonClicked = true -- Marquez le bouton Réinitialiser comme cliqué
end

buttonReset:SetScript("OnClick", ResetTalents)

-- Créez le bouton Reload à l'intérieur de la fenêtre frameTalentHeros
local buttonReload = CreateFrame("Button", "buttonReload", frameTalentHeros, "UIPanelButtonTemplate")
buttonReload:SetSize(85, 25)
buttonReload:SetPoint("BOTTOMRIGHT", buttonTalentHerosClose, "BOTTOMLEFT", -5, 5) -- Place le bouton Reload à gauche du bouton Close
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
        frameTalentHeros:Hide()
        buttonReload:Hide()
        PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
    else
        frameTalentHeros:Show()
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
        frFR = "|cffffffffTalents|r |cfffdc5b8(Héros)|r\n\nL'éventail des talents disponibles\npour améliorer et spécialiser\nvotre personnage.",
        enUS = "|cffffffffTalents|r |cfffdc5b8(Hero)|r\n\nThe range of available talents\nfor enhancing and specializing\nyour character."
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

-- Vérifier si le joueur est un Heros avant de créer le bouton
local playerClass = select(2, UnitClass("player")) -- Obtenir la classe du joueur
if playerClass == "HERO" then
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
HerosHandlers.UpdateTalentCount = function(player, talentsAppris)
    if fontTalentHerosFrameText then
        fontTalentHerosFrameText:SetText(talentsAppris .. " / " .. MAX_TALENTS)
    end
end

-- Mise à jour des points de talent utilisés avec texte localisé
HerosHandlers.UpdateTalentPointsUsed = function(player, pointsUsed, pointsBeforeReset)
    -- Utilisation du texte localisé pour les points avant réinitialisation
    print(string.format(GetLocalizedPointsBeforeResetText(), pointsBeforeReset))
end

-- Affichage des talents restants (items 338404 dans le sac)
HerosHandlers.UpdateTalentItemCount = function(player, count)
    if fontTalentPointsRemainingText then
        fontTalentPointsRemainingText:SetText("|cFFFF6EBFTalents restants : " .. count .. "|r")
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
        fontTalentPointsRemainingText:SetText("|cFFFF6EBFTalents restants : " .. (count or 0) .. "|r")
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
if playerClass == "HERO" then
    -- Surcharge OnHide pour synchroniser talentsWindowOpen quand Échap est pressé
    local _originalOnHide = frameTalentHeros:GetScript("OnHide")
    frameTalentHeros:SetScript("OnHide", function(self)
        talentsWindowOpen = false
        if _originalOnHide then _originalOnHide(self) end
    end)
    -- WoW appelle automatiquement Hide() sur les frames listées ici quand Échap est pressé
    tinsert(UISpecialFrames, "frameTalentHeros")
end