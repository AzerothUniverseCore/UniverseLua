local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local DemonhunterHandlers = AIO.AddHandlers("TalentDemonhunterspell", {})

function DemonhunterHandlers.ShowTalentDemonhunter(player)
    frameTalentDemonhunter:Show()
    -- Redemande au serveur l’état visuel au cas où
    AIO.Handle("TalentDemonhunterspell", "RequestLearnedTalents")
	-- Redemande le nombre de talents restants
    AIO.Handle("TalentDemonhunterspell", "GetTalentItemCount")
end

local MAX_TALENTS = 28 -- Définition du nombre maximal de talents que le joueur peut apprendre

local OPEN_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_final_trait_unlocked.ogg"
local CLOSE_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_trait_refund_end.ogg"
local SPELL_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_80_azeritearmor_rotationends_02.ogg"

-- Attribute window
local frameTalentDemonhunter = CreateFrame("Frame", "frameTalentDemonhunter", UIParent)
frameTalentDemonhunter:SetSize(1200, 650)
frameTalentDemonhunter:SetMovable(true)
frameTalentDemonhunter:EnableMouse(true)
frameTalentDemonhunter:RegisterForDrag("LeftButton")
frameTalentDemonhunter:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, -50) -- Adjust the X and Y coordinates
frameTalentDemonhunter:SetBackdrop(
{
    -- bgFile = "interface/TalentFrame/talentsclassbackgroundDemonhunter", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    bgFile = "interface/TalentFrame/Template/Class/DemonHunter/talentsclassbackgrounddemonhunter2", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedwarlock", --Interface/DialogFrame/UI-DialogBox-Border
    edgeSize = 20,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})

-- Ajoutez la texture de l'icône du Chasseur de démons
local demonhunterIcon = frameTalentDemonhunter:CreateTexture("DemonhunterIcon", "OVERLAY")
demonhunterIcon:SetTexture("Interface\\TalentFrame\\Template\\Class\\DemonHunter\\IconeDemonHunter.blp")
demonhunterIcon:SetSize(60, 60)
demonhunterIcon:SetPoint("TOPLEFT", frameTalentDemonhunter, "TOPLEFT", -10, 10)

-- Template Talent Frame

-- Ajoute une textureone pour l'image BLP
local textureone = frameTalentDemonhunter:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
textureone:SetTexture("Interface\\TalentFrame\\Template\\Class\\Demonhunter\\TalentFrameTemplate.blp")
textureone:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
textureone:SetPoint("TOPLEFT", frameTalentDemonhunter, "TOPLEFT", -150, 90) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentDemonhunter:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Ajoute une texturetwo pour l'image BLP
local texturetwo = frameTalentDemonhunter:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
texturetwo:SetTexture("Interface\\TalentFrame\\Template\\Class\\Demonhunter\\TalentFrameTemplateOriginal.blp")
texturetwo:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
texturetwo:SetPoint("TOPRIGHT", frameTalentDemonhunter, "TOPRIGHT", 150, 35) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentDemonhunter:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Drag & Drop
frameTalentDemonhunter:SetScript("OnDragStart", frameTalentDemonhunter.StartMoving)
frameTalentDemonhunter:SetScript("OnHide", frameTalentDemonhunter.StopMovingOrSizing)
frameTalentDemonhunter:SetScript("OnDragStop", frameTalentDemonhunter.StopMovingOrSizing)
frameTalentDemonhunter:Hide()

-- Nouveau template d'arête
frameTalentDemonhunter:SetBackdropBorderColor(135, 135, 237) -- Couleur pourpre

-- Close button
local buttonTalentDemonhunterClose = CreateFrame("Button", "buttonTalentDemonhunterClose", frameTalentDemonhunter, "UIPanelCloseButton")
buttonTalentDemonhunterClose:SetPoint("TOPRIGHT", -12, -12)
buttonTalentDemonhunterClose:EnableMouse(true)
buttonTalentDemonhunterClose:SetSize(32, 32)

local function CloseTalentWindow()
    frameTalentDemonhunter:Hide()
    PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
end

-- Associez la fonction de fermeture au bouton de fermeture
buttonTalentDemonhunterClose:SetScript("OnClick", CloseTalentWindow)

-- Title bar
local frameTalentDemonhunterTitleBar = CreateFrame("Frame", "frameTalentDemonhunterTitleBar", frameTalentDemonhunter, nil)
frameTalentDemonhunterTitleBar:SetSize(135, 25)
frameTalentDemonhunterTitleBar:SetBackdrop(
{
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedwarlock",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentDemonhunterTitleBar:SetPoint("TOP", 0, 20)

local fontTalentDemonhunterTitleText = frameTalentDemonhunterTitleBar:CreateFontString("fontTalentDemonhunterTitleText")
fontTalentDemonhunterTitleText:SetFont("Fonts\\FRIZQT__.TTF", 13)
fontTalentDemonhunterTitleText:SetSize(190, 5)
fontTalentDemonhunterTitleText:SetPoint("CENTER", 0, 0)
fontTalentDemonhunterTitleText:SetText("|cffFFC125Talents|r")

-- Détecte la langue du client
local locale = GetLocale() -- Retourne "enUS", "frFR", etc.

-- Table des traductions
local localizedTexts = {
    enUS = "|cffFFC125Demon Hunter|r",
    frFR = "|cffFFC125Chasseur de démons|r",
}

-- Récupère le texte correspondant à la langue actuelle ou par défaut en anglais
local textToDisplay = localizedTexts[locale] or localizedTexts["enUS"]

local fontTalentDemonhunterFrameText = frameTalentDemonhunterTitleBar:CreateFontString("fontTalentDemonhunterFrameText")
fontTalentDemonhunterFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentDemonhunterFrameText:SetSize(200, 5)
fontTalentDemonhunterFrameText:SetPoint("TOPLEFT", frameTalentDemonhunterTitleBar, "BOTTOMLEFT", -30, -35) -- Adjust the Y offset as needed
fontTalentDemonhunterFrameText:SetText(textToDisplay)

-- Remplacez votre ligne existante pour la création du texte par celle-ci
local fontTalentDemonhunterFrameText = frameTalentDemonhunterTitleBar:CreateFontString("fontTalentDemonhunterFrameText")
fontTalentDemonhunterFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentDemonhunterFrameText:SetSize(200, 5)
fontTalentDemonhunterFrameText:SetPoint("TOPLEFT", frameTalentDemonhunterTitleBar, "BOTTOMLEFT", -30, -60) -- Adjust the Y offset as needed
fontTalentDemonhunterFrameText:SetText("0 / " .. MAX_TALENTS) -- Initialisez le texte avec 0 talents appris

-------------------------------------------------------------
-- Affichage "Talents restants" (item 338404 dans le sac)
-------------------------------------------------------------

local frameTalentPointsRemaining = CreateFrame("Frame", "frameTalentPointsRemaining", frameTalentDemonhunter, nil)
frameTalentPointsRemaining:SetSize(220, 30)
frameTalentPointsRemaining:SetBackdrop({
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedwarlock",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentPointsRemaining:SetPoint("BOTTOMRIGHT", frameTalentDemonhunter, "BOTTOMRIGHT", -960, 10)

local fontTalentPointsRemainingText = frameTalentPointsRemaining:CreateFontString("fontTalentPointsRemainingText")
fontTalentPointsRemainingText:SetFont("Fonts\\FRIZQT__.TTF", 14)
fontTalentPointsRemainingText:SetSize(210, 20)
fontTalentPointsRemainingText:SetPoint("CENTER", 0, 0)
fontTalentPointsRemainingText:SetText("|cFFA330C9Talents restants : 0|r")
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
DemonhunterHandlers.UpdateLearnedTalents = function(player, learnedSpells)
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

    local button = CreateFrame("Button", name, frameTalentDemonhunter, nil)
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
                AIO.Handle("TalentDemonhunterspell", talentHandler, 1)
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

-- Dévastation

-- Table des sorts
local spells = {
{
    id = "spellWarglaivesChaos",
    name = "buttonSpellWarglaivesChaos",
    icon = "Interface/icons/inv_glaive_1h_artifactazgalor_d_03",
    position = {170, -180},
    handler = "spellwarglaiveschaos",
    tooltips = {
        frFR = "|cffffffffGlaives de guerre du chaos|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Augmente les dégâts des coups critiques infligés par Frappe du chaos de 21%.|r",
        enUS = "|cffffffffWarglaives of Chaos|r\n|cffffffffTalent|r |cff00bb00Devastation|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Increases the critical strike damage of Chaos Strike by 21%.|r"
    }
},
{
    id = "spellDemonSpeed",
    name = "buttonSpellDemonSpeed",
    icon = "Interface/icons/ability_demonhunter_doublejump",
    position = {280, -180},
    handler = "spelldemonspeed",
    tooltips = {
        frFR = "|cffffffffVitesse démoniaque|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Voile corrompu octroie maintenant un bonus de 30% à la vitesse de déplacement.|r",
        enUS = "|cffffffffDemonic Speed|r\n|cffffffffTalent|r |cff00bb00Devastation|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Corrupted Veil now grants a 30% movement speed bonus.|r"
    }
},
{
    id = "spellUnboundChaos",
    name = "buttonSpellUnboundChaos",
    icon = "Interface/icons/artifactability_vengeancedemonhunter_painbringer",
    position = {390, -180},
    handler = "spellunboundchaos",
    tooltips = {
        frFR = "|cffffffffChaos délié|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100L'activation d'Aura d'immolation augmente les dégâts de votre prochaine Ruée vers le félin de 80%. Dure 20 sec.|r",
        enUS = "|cffffffffUnbound Chaos|r\n|cffffffffTalent|r |cff00bb00Devastation|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Activating Immolation Aura increases the damage of your next Fel Rush by 80%. Lasts for 20 sec.|r"
    }
},
{
    id = "spellChaosVision",
    name = "buttonSpellChaosVision",
    icon = "Interface/icons/ability_demonhunter_eyebeam",
    position = {445, -235},
    handler = "spellchaosvision",
    tooltips = {
        frFR = "|cffffffffVision du chaos|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Augmente les dégâts de Rayon accablant de 15%.|r",
        enUS = "|cffffffffChaos Vision|r\n|cffffffffTalent|r |cff00bb00Devastation|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Increases the damage of Fel Beam by 15%.|r"
    }
},
{
    id = "spellDevastatingChaos",
    name = "buttonSpellDevastatingChaos",
    icon = "Interface/icons/ability_demonhunter_demonictrample",
    position = {335, -235},
    handler = "spelldevastatingchaos",
    tooltips = {
        frFR = "|cffffffffDévastateur du Chaos|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Réduit le temps de recharge de votre capacité Rayon accablant de 10 secondes.|r",
        enUS = "|cffffffffDevastating Chaos|r\n|cffffffffTalent|r |cff00bb00Devastation|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Reduces the cooldown of your Fel Beam ability by 10 seconds.|r"
    }
},
{
    id = "spellDesperateInstincts",
    name = "buttonSpellDesperateInstincts",
    icon = "Interface/icons/Spell_Shadow_ManaFeed",
    position = {225, -235},
    handler = "spelldesperateinstincts",
    tooltips = {
        frFR = "|cffffffffInstinct désespéré|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Voile corrompu réduit désormais les dégâts subis de 10% supplémentaires.|r",
        enUS = "|cffffffffDesperate Instincts|r\n|cffffffffTalent|r |cff00bb00Devastation|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Corrupted Veil now reduces damage taken by an additional 10%.|r"
    }
},
{
    id = "spellImprovedDemonsBite",
    name = "buttonSpellImprovedDemonsBite",
    icon = "Interface/icons/INV_Weapon_Glave_01",
    position = {115, -235},
    handler = "spellimproveddemonsbite",
    tooltips = {
        frFR = "|cffffffffMorsure du démon Amélioré|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Augmente de 10% les dégâts des coups critiques infligés par la morsure des démons\net augmente de 50% les chances de remboursement de la furie.|r",
        enUS = "|cffffffffImproved Demon's Bite|r\n|cffffffffTalent|r |cff00bb00Devastation|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Increases critical strike damage of Demon’s Bite by 10% and increases Fury refund chances by 50%.|r"
    }
},
{
    id = "spellNetherwalk",
    name = "buttonSpellNetherwalk",
    icon = "Interface/icons/spell_warlock_demonsoul",
    position = {170, -290},
    handler = "spellnetherwalk",
    tooltips = {
        frFR = "|cffffffffMarche du Néant|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Glissez-vous dans le néant, augmentant votre vitesse de déplacement de 100%, supprimant tous les effets qui entravent le mouvement\net devenant immunisé aux dégâts, mais incapable d'attaquer. Dure 5 secondes.|r",
        enUS = "|cffffffffNetherwalk|r\n|cffffffffTalent|r |cff00bb00Devastation|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Slip into the Nether, increasing your movement speed by 100%, removing all movement-impairing effects, and becoming immune to damage but unable to attack. Lasts 5 seconds.|r"
    }
},
{
    id = "spellAnguishDeceiver",
    name = "buttonSpellAnguishDeceiver",
    icon = "Interface/icons/artifactability_havocdemonhunter_anguishofthedeceiver",
    position = {280, -290},
    handler = "spellanguishdeceiver",
    tooltips = {
        frFR = "|cffffffffAngoisse du Trompeur|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Chaque fois que le rayon des yeux inflige des dégâts à une cible, il applique également Angoisse.\nLorsque Angoisse expire, il inflige [ 85% de la puissance d'attaque ] de dégâts de Chaos à la victime par application.|r",
        enUS = "|cffffffffAnguish of the Deceiver|r\n|cffffffffTalent|r |cff00bb00Devastation|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Each time Eye Beam deals damage to a target, it also applies Anguish.\nWhen Anguish expires, it deals [85% of attack power] Chaos damage to the target per application.|r"
    }
},
{
    id = "spellChaoticOnslaught",
    name = "buttonSpellChaoticOnslaught",
    icon = "Interface/icons/ability_demonhunter_chaosstrike",
    position = {60, -290},
    handler = "spellchaoticonslaught",
    tooltips = {
        frFR = "|cffffffffAssaut chaotique|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Frappe du chaos a 15% de chances de trancher une fois de plus.|r",
        enUS = "|cffffffffChaotic Onslaught|r\n|cffffffffTalent|r |cff00bb00Devastation|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Chaos Strike has a 15% chance to strike once more.|r"
    }
},
{
    id = "spellIllidariKnowledge",
    name = "buttonSpellIllidariKnowledge",
    icon = "Interface/icons/spell_mage_overpowered",
    position = {390, -290},
    handler = "spellillidariknowledge",
    tooltips = {
        frFR = "|cffffffffConnaissance illidari|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Réduit les dégâts magiques que vous subissez de 8%.|r",
        enUS = "|cffffffffIllidari Knowledge|r\n|cffffffffTalent|r |cff00bb00Devastation|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Reduces magic damage taken by 8%.|r"
    }
},
{
    id = "spellUnleashedPower",
    name = "buttonSpellUnleashedPower",
    icon = "Interface/icons/ability_demonhunter_chaosnova",
    position = {495, -290},
    handler = "spellunleashedpower",
    tooltips = {
        frFR = "|cffffffffPuissance déchaînée|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Supprime le coût en furie de Chaos Nova et réduit son temps de recharge de 33%.|r",
        enUS = "|cffffffffUnleashed Power|r\n|cffffffffTalent|r |cff00bb00Devastation|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Removes the Fury cost of Chaos Nova and reduces its cooldown by 33%.|r"
    }
},
{
    id = "spellChaosBlade",
    name = "buttonSpellChaosBlade",
    icon = "Interface/icons/inv_glaive_1h_artifactaldrochi_d_03dual",
    position = {115, -345},
    handler = "spellchaosblade",
    tooltips = {
        frFR = "|cffffffffLame du Chaos|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Les dégâts infligés ont augmenté de 30%.\nAugmentation de la vitesse d'attaque automatique de 15%.|r",
        enUS = "|cffffffffChaos Blade|r\n|cffffffffTalent|r |cff00bb00Devastation|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Increases damage dealt by 30%.\nIncreases automatic attack speed by 15%.|r"
    }
},
{
    id = "spellImprovedMetamorphosis",
    name = "buttonSpellImprovedMetamorphosis",
    icon = "Interface/icons/ability_demonhunter_metamorphasistank",
    position = {225, -345},
    handler = "spellimprovedmetamorphosis",
    tooltips = {
        frFR = "|cffffffffMétamorphose améliorée|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Augmente les dégâts de l'explosion féline de Métamorphose de 20% et augmente sa durée à 45 sec.|r",
        enUS = "|cffffffffImproved Metamorphosis|r\n|cffffffffTalent|r |cff00bb00Devastation|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Increases the damage of Metamorphosis' Feline Explosion by 20% and increases its duration to 45 seconds.|r"
    }
},
{
    id = "spellUnleashedDemons",
    name = "buttonSpellUnleashedDemons",
    icon = "Interface/icons/ability_demonhunter_metamorphasistank",
    position = {280, -398},
    handler = "spellunleasheddemons",
    tooltips = {
        frFR = "|cffffffffDémons déchaînés|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Réduit le temps de recharge de Métamorphose de 30 secondes.|r",
        enUS = "|cffffffffUnleashed Demons|r\n|cffffffffTalent|r |cff00bb00Devastation|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Reduces the cooldown of Metamorphosis by 30 seconds.|r"
    }
},
{
    id = "spellBalancedBlades",
    name = "buttonSpellBalancedBlades",
    icon = "Interface/icons/ability_demonhunter_bladedance",
    position = {445, -345},
    handler = "spellbalancedblades",
    tooltips = {
        frFR = "|cffffffffLames équilibrées|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Augmente les dégâts infligés par Danse des lames de 45%.|r",
        enUS = "|cffffffffBalanced Blades|r\n|cffffffffTalent|r |cff00bb00Devastation|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Increases the damage dealt by Blade Dance by 45%.|r"
    }
},
{
    id = "spellDemonic",
    name = "buttonSpellDemonic",
    icon = "Interface/icons/Spell_Shadow_DemonForm",
    position = {335, -345},
    handler = "spelldemonic",
    tooltips = {
        frFR = "|cffffffffDémoniaque|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Rayon accablant vous transforme en démon pendant 8 s après qu’il a fini d’infliger des dégâts.|r",
        enUS = "|cffffffffDemonic|r\n|cffffffffTalent|r |cff00bb00Devastation|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Eye Beam transforms you into a demon for 8 seconds after it finishes dealing damage.|r"
    }
},
{
    id = "spellFelWounds",
    name = "buttonSpellFelWounds",
    icon = "Interface/icons/Spell_Fire_FelHellfire",
    position = {495, -398},
    handler = "spellfelwounds",
    tooltips = {
        frFR = "|cffffffffBlessures gangrenées|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100La Danse des lames fait saigner tous les ennemis à 8 mètres de distance pour 150% des dégâts infligés sur 10 sec.|r",
        enUS = "|cffffffffFel Wounds|r\n|cffffffffTalent|r |cff00bb00Devastation|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Blade Dance causes all enemies within 8 yards to bleed for 150% of the damage dealt over 10 seconds.|r"
    }
},
{
    id = "spellFelBarrage",
    name = "buttonSpellFelBarrage",
    icon = "Interface/icons/inv_felbarrage",
    position = {60, -398},
    handler = "spellfelbarrage",
    tooltips = {
        frFR = "|cffffffffBarrage gangrené|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Lance un torrent d'énergie Fel sur 3 sec, infligeant [ 314,6% de la puissance d'attaque ] des dégâts de feu à tous les ennemis dans un rayon de 8 m.|r",
        enUS = "|cffffffffFel Barrage|r\n|cffffffffTalent|r |cff00bb00Devastation|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Fires a torrent of Fel energy for 3 seconds, dealing [314.6% of Attack Power] Fire damage to all enemies within 8 yards.|r"
    }
},


-- CreateSpellButton("buttonSpellWarglaivesChaos", "Interface/icons/inv_glaive_1h_artifactazgalor_d_03", "|cffffffffGlaives de guerre du chaos|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Augmente les dégâts des coups critiques infligés par Frappe du chaos de 21%.|r", "spellwarglaiveschaos", 170, -180)
-- CreateSpellButton("buttonSpellDemonSpeed", "Interface/icons/ability_demonhunter_doublejump", "|cffffffffVitesse démoniaque|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Voile corrompu octroie maintenant un bonus de 30% à la vitesse de déplacement.|r", "spelldemonspeed", 280, -180)
-- CreateSpellButton("buttonSpellUnboundChaos", "Interface/icons/artifactability_vengeancedemonhunter_painbringer", "|cffffffffChaos délié|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100L'activation d'Aura d'immolation augmente les dégâts de votre prochaine Ruée vers le félin de 80%. Dure 20 sec.|r", "spellunboundchaos", 390, -180)
-- CreateSpellButton("buttonSpellChaosVision", "Interface/icons/ability_demonhunter_eyebeam", "|cffffffffVision du chaos|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Augmente les dégâts de Rayon accablant de 15%.|r", "spellchaosvision", 445, -235)
-- CreateSpellButton("buttonSpellDevastatingChaos", "Interface/icons/ability_demonhunter_demonictrample", "|cffffffffDévastateur du Chaos|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Réduit le temps de recharge de votre capacité Rayon accablant de 10 secondes.|r", "spelldevastatingchaos", 335, -235)
-- CreateSpellButton("buttonSpellDesperateInstincts", "Interface/icons/Spell_Shadow_ManaFeed", "|cffffffffInstinct désespéré|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Voile corrompu réduit désormais les dégâts subis de 10% supplémentaires.|r", "spelldesperateinstincts", 225, -235)
-- CreateSpellButton("buttonSpellImprovedDemonsBite", "Interface/icons/INV_Weapon_Glave_01", "|cffffffffMorsure du démon Amélioré|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Augmente de 10% les dégâts des coups critiques infligés par la morsure des démons\net augmente de 50% les chances de remboursement de la furie.|r", "spellimproveddemonsbite", 115, -235)
-- CreateSpellButton("buttonSpellNetherwalk", "Interface/icons/spell_warlock_demonsoul", "|cffffffffMarche du Néant|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Glissez-vous dans le néant, augmentant votre vitesse de déplacement de 100%, supprimant tous les effets qui entravent le mouvement\net devenant immunisé aux dégâts, mais incapable d'attaquer. Dure 5 secondes.|r", "spellnetherwalk", 170, -290)
-- CreateSpellButton("buttonSpellAnguishDeceiver", "Interface/icons/artifactability_havocdemonhunter_anguishofthedeceiver", "|cffffffffAngoisse du Trompeur|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Chaque fois que le rayon des yeux inflige des dégâts à une cible, il applique également Angoisse.\nLorsque Angoisse expire, il inflige [ 85% de la puissance d'attaque ] de dégâts de Chaos à la victime par application.|r", "spellanguishdeceiver", 280, -290)
-- CreateSpellButton("buttonSpellChaoticOnslaught", "Interface/icons/ability_demonhunter_chaosstrike", "|cffffffffAssaut chaotique|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Frappe du chaos a 15% de chances de trancher une fois de plus.|r", "spellchaoticonslaught", 60, -290)
-- CreateSpellButton("buttonSpellIllidariKnowledge", "Interface/icons/spell_mage_overpowered", "|cffffffffConnaissance illidari|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Réduit les dégâts magiques que vous subissez de 8%.|r", "spellillidariknowledge", 390, -290)
-- CreateSpellButton("buttonSpellUnleashedPower", "Interface/icons/ability_demonhunter_chaosnova", "|cffffffffPuissance déchaînée|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Supprime le coût en furie de Chaos Nova et réduit son temps de recharge de 33%.|r", "spellunleashedpower", 495, -290)
-- CreateSpellButton("buttonSpellChaosBlade", "Interface/icons/inv_glaive_1h_artifactaldrochi_d_03dual", "|cffffffffLame du Chaos|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Les dégâts infligés ont augmenté de 30%.\nAugmentation de la vitesse d'attaque automatique de 15%.|r", "spellchaosblade", 115, -345)
-- CreateSpellButton("buttonSpellImprovedMetamorphosis", "Interface/icons/ability_demonhunter_metamorphasistank", "|cffffffffMétamorphose améliorée|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Augmente les dégâts de l'explosion féline de Métamorphose de 20% et augmente sa durée à 45 sec.|r", "spellimprovedmetamorphosis", 225, -345)
-- CreateSpellButton("buttonSpellUnleashedDemons", "Interface/icons/ability_demonhunter_metamorphasistank", "|cffffffffDémons déchaînés|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Réduit le temps de recharge de Métamorphose de 30 secondes.|r", "spellunleasheddemons", 280, -398)
-- CreateSpellButton("buttonSpellBalancedBlades", "Interface/icons/ability_demonhunter_bladedance", "|cffffffffLames équilibrées|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Augmente les dégâts infligés par Danse des lames de 45%.|r", "spellbalancedblades", 445, -345)
-- CreateSpellButton("buttonSpellDemonic", "Interface/icons/Spell_Shadow_DemonForm", "|cffffffffDémoniaque|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Rayon accablant vous transforme en démon pendant 8 s après qu’il a fini d’infliger des dégâts.|r", "spelldemonic", 335, -345)
-- CreateSpellButton("buttonSpellFelWounds", "Interface/icons/Spell_Fire_FelHellfire", "|cffffffffBlessures gangrenées|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100La Danse des lames fait saigner tous les ennemis à 8 mètres de distance pour 150% des dégâts infligés sur 10 sec.|r", "spellfelwounds", 495, -398)
-- CreateSpellButton("buttonSpellFelBarrage", "Interface/icons/inv_felbarrage", "|cffffffffBarrage gangrené|r\n|cffffffffTalent|r |cff00bb00Dévastation|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Lance un torrent d'énergie Fel sur 3 sec, infligeant [ 314,6% de la puissance d'attaque ] des dégâts de feu à tous les ennemis dans un rayon de 8 m.|r", "spellfelbarrage", 60, -398)

-- Template 2

-- Vengeance

{
    id = "spellThickSkin",
    name = "buttonSpellThickSkin",
    icon = "Interface/icons/sha_spell_warlock_demonsoul",
    position = {645, -290},
    handler = "spellthickskin",
    tooltips = {
        frFR = "|cffffffffPeau dure|r\n|cffffffffTalent|r |cff0000d5Vengeance|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Une énergie gangrenée épaissit votre peau dans des proportions démoniaques,\nce qui augmente votre Endurance de 65% et votre Armure de 130%.|r",
        enUS = "|cffffffffThick Skin|r\n|cffffffffTalent|r |cff0000d5Vengeance|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Fel energy thickens your skin in demonic proportions, increasing your Stamina by 65% and your Armor by 130%.|r"
    }
},
{
    id = "spellDemonicWards",
    name = "buttonSpellDemonicWards",
    icon = "Interface/icons/inv_belt_leather_demonhunter_a_01",
    position = {1075, -290},
    handler = "spelldemonicwards",
    tooltips = {
        frFR = "|cffffffffProtections démoniaques|r\n|cffffffffTalent|r |cff0000d5Vengeance|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Vos tatouages réduisent les dégâts subis de 10%.\n(10% de dégâts magiques et physiques)|r",
        enUS = "|cffffffffDemonic Wards|r\n|cffffffffTalent|r |cff0000d5Vengeance|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Your tattoos reduce all damage taken by 10%, including 10% reduction to magical and physical damage.|r"
    }
},


-- CreateSpellButton("buttonSpellThickSkin", "Interface/icons/sha_spell_warlock_demonsoul", "|cffffffffPeau dure|r\n|cffffffffTalent|r |cff0000d5Vengeance|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Une énergie gangrenée épaissit votre peau dans des proportions démoniaques, ce qui augmente votre Endurance de 65% et votre Armure de 130%.|r", "spellthickskin", 645, -290)
-- CreateSpellButton("buttonSpellDemonicWards", "Interface/icons/inv_belt_leather_demonhunter_a_01", "|cffffffffProtections démoniaques|r\n|cffffffffTalent|r |cff0000d5Vengeance|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Vos tatouages réduisent [les dégâts magiques subis de 10% et les dégâts physiques subis de 10%.][les dégâts subis de 10%.]|r", "spelldemonicwards", 1075, -290)

-- Maître du glaive

{
    id = "spellSharpenedGlaives",
    name = "buttonSpellSharpenedGlaives",
    icon = "Interface/icons/ability_demonhunter_throwglaive",
    position = {805, -235},
    handler = "spellsharpenedglaives",
    tooltips = {
        frFR = "|cffffffffGlaives aiguisées|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Augmente les dégâts de Lancer de glaive de 50%.|r",
        enUS = "|cffffffffSharpened Glaives|r\n|cffffffffTalent|r |cffc7690cMaster of Glaive|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Increases the damage of Throw Glaive by 50%.|r"
    }
},
{
    id = "spellDisorientGlaives",
    name = "buttonSpellDisorientGlaives",
    icon = "Interface/icons/inv_glaive_1h_demonhunter_a_01",
    position = {860, -180},
    handler = "spelldisorientglaives",
    tooltips = {
        frFR = "|cffffffffGlaives désorientées|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Lancer de glaive piège tous les ennemis touchés de 30% pendant 5 sec.|r",
        enUS = "|cffffffffDisoriented Glaives|r\n|cffffffffTalent|r |cffc7690cMaster of Glaive|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Throw Glaive traps all enemies hit, reducing their movement speed by 30% for 5 seconds.|r"
    }
},
{
    id = "spellFireGlaives",
    name = "buttonSpellFireGlaives",
    icon = "Interface/icons/inv_glaive_1h_artifactazgalor_d_04",
    position = {915, -235},
    handler = "spellfireglaives",
    tooltips = {
        frFR = "|cffffffffGlaive de feu|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Lancer de glaive provoque une brûlure dans vos cibles, infligeant des dégâts de feu sur 5 sec.|r",
        enUS = "|cffffffffFire Glaive|r\n|cffffffffTalent|r |cffc7690cMaster of Glaive|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Throw Glaive causes a burn in your targets, dealing Fire damage over 5 seconds.|r"
    }
},
{
    id = "spellMasterGlaive",
    name = "buttonSpellMasterGlaive",
    icon = "Interface/icons/inv_glaive_1h_npc_c_02",
    position = {750, -290},
    handler = "spellmasterglaive",
    tooltips = {
        frFR = "|cffffffffMaître du Glaive|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Réduit le temps de recharge de Glaive de jet de 3 secondes.|r",
        enUS = "|cffffffffMaster of Glaive|r\n|cffffffffTalent|r |cffc7690cMaster of Glaive|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Reduces the cooldown of Throw Glaive by 3 seconds.|r"
    }
},
{
    id = "spellMasterySpeed",
    name = "buttonSpellMasterySpeed",
    icon = "Interface/icons/ability_demonhunter_doublejump",
    position = {700, -345},
    handler = "spellmasteryspeed",
    tooltips = {
        frFR = "|cffffffffMaîtrise de la vitesse|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Lancer de glaive augmente votre vitesse de déplacement de 5%\nen s'empilant 3 fois, dure 4 secondes.|r",
        enUS = "|cffffffffMastery Speed|r\n|cffffffffTalent|r |cffc7690cMaster of Glaive|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Throw Glaive increases your movement speed by 5%, stacking up to 3 times, lasting for 4 seconds.|r"
    }
},
{
    id = "spellImprovedFireGlaives",
    name = "buttonSpellImprovedFireGlaives",
    icon = "Interface/icons/inv_glaive_1h_artifactazgalor_d_04dual",
    position = {860, -290},
    handler = "spellimprovedfireglaives",
    tooltips = {
        frFR = "|cffffffffGlaives de feu améliorées|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Augmente l'efficacité de Burning, en augmentant ses dégâts de 12% et en augmentant sa durée de 55%.|r",
        enUS = "|cffffffffImproved Fire Glaives|r\n|cffffffffTalent|r |cffc7690cMaster of Glaive|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Increases the effectiveness of Burning, increasing its damage by 12% and its duration by 55%.|r"
    }
},
{
    id = "spellCauterize",
    name = "buttonSpellCauterize",
    icon = "Interface/icons/spell_burningbladeshaman_blazing_radiance",
    position = {915, -345},
    handler = "spellcauterize",
    tooltips = {
        frFR = "|cffffffffCautérisation|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Lancer de glaive réduit la résistance au feu de vos ennemis de 10000 pendant 10 sec.|r",
        enUS = "|cffffffffCauterize|r\n|cffffffffTalent|r |cffc7690cMaster of Glaive|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Throw Glaive reduces the Fire resistance of your enemies by 10,000 for 10 seconds.|r"
    }
},
{
    id = "spellDualBladeDance",
    name = "buttonSpellDualBladeDance",
    icon = "Interface/icons/inv_glaive_1h_artifactazgalor_d_01",
    position = {970, -290},
    handler = "spelldualbladedance",
    tooltips = {
        frFR = "|cffffffffLa danse des doubles lames|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Lance 2 de vos glaives démoniaques dans un tourbillon d'énergie, causant 38% des dégâts de l'arme en dégâts de chaos sur 3 sec à tous les ennemis proches.|r",
        enUS = "|cffffffffDual Blade Dance|r\n|cffffffffTalent|r |cffc7690cMaster of Glaive|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Throws 2 of your demonic glaives in an energy whirlwind, dealing 38% weapon damage as Chaos damage over 3 seconds to all nearby enemies.|r"
    }
},
{
    id = "spellImprovedDualBlades",
    name = "buttonSpellImprovedDualBlades",
    icon = "Interface/icons/ability_demonhunter_bladedance",
    position = {1025, -345},
    handler = "spellimproveddualblades",
    tooltips = {
        frFR = "|cffffffffLames doubles améliorées|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Augmente la durée de Dual Blade Dance de 65%.|r",
        enUS = "|cffffffffImproved Dual Blades|r\n|cffffffffTalent|r |cffc7690cMaster of Glaive|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Increases the duration of Dual Blade Dance by 65%.|r"
    }
},
{
    id = "spellBloodlet",
    name = "buttonSpellBloodlet",
    icon = "Interface/icons/ability_demonhunter_bloodlet",
    position = {645, -398},
    handler = "spellbloodlet",
    tooltips = {
        frFR = "|cffffffffBloodlet|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Lancer de glaive fait saigner vos ennemis pour 30% des dégâts infligés, cumulable 3 fois sur 15 sec.|r",
        enUS = "|cffffffffBloodlet|r\n|cffffffffTalent|r |cffc7690cMaster of Glaive|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Throw Glaive causes your enemies to bleed for 30% of the damage dealt, stackable 3 times over 15 seconds.|r"
    }
},
{
    id = "spellRapidGlaives",
    name = "buttonSpellRapidGlaives",
    icon = "Interface/icons/inv_glaive_1h_npc_c_02",
    position = {805, -345},
    handler = "spellrapidglaives",
    tooltips = {
        frFR = "|cffffffffGlaives rapides|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Lance simultanément vos Glaives, infligeant des dégâts à un maximum de 3 cibles toutes les 0.5 sec, dure 3 secondes.|r",
        enUS = "|cffffffffRapid Glaives|r\n|cffffffffTalent|r |cffc7690cMaster of Glaive|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Throws your glaives simultaneously, dealing damage to up to 3 targets every 0.5 seconds for 3 seconds.|r"
    }
},
{
    id = "spellVenomlet",
    name = "buttonSpellVenomlet",
    icon = "Interface/icons/inv_glaive_1h_artifactazgalor_d_02dual",
    position = {1075, -398},
    handler = "spellvenomlet",
    tooltips = {
        frFR = "|cffffffffVenomlet|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Lancer de glaive empoisonne vos ennemis en leur infligeant 15% des dégâts infligés\net réduit leur résistance à la nature de 2000, cumulable 3 fois sur 15 sec.|r",
        enUS = "|cffffffffVenomlet|r\n|cffffffffTalent|r |cffc7690cMaster of Glaive|r\n|cffffffffRequires|r |cffa330c9Demon Hunter|r\n|cffffd100Throw Glaive poisons your enemies, dealing 15% of the damage dealt and reducing their Nature resistance by 2,000, stackable 3 times over 15 seconds.|r"
		}
	}
}


-- CreateSpellButton("buttonSpellSharpenedGlaives", "Interface/icons/ability_demonhunter_throwglaive", "|cffffffffGlaives aiguisées|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Augmente les dégâts de Lancer de glaive de 50%.|r", "spellsharpenedglaives", 805, -235)
-- CreateSpellButton("buttonSpellDisorientGlaives", "Interface/icons/inv_glaive_1h_demonhunter_a_01", "|cffffffffGlaives désorientées|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Lancer de glaive piège tous les ennemis touchés de 30% pendant 5 sec.|r", "spelldisorientglaives", 860, -180)
-- CreateSpellButton("buttonSpellFireGlaives", "Interface/icons/inv_glaive_1h_artifactazgalor_d_04", "|cffffffffGlaive de feu|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Lancer de glaive provoque une brûlure dans vos cibles, infligeant des dégâts de feu sur 5 sec.|r", "spellfireglaives", 915, -235)
-- CreateSpellButton("buttonSpellMasterGlaive", "Interface/icons/inv_glaive_1h_npc_c_02", "|cffffffffMaître du Glaive|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Réduit le temps de recharge de Glaive de jet de 3 secondes.|r", "spellmasterglaive", 750, -290)
-- CreateSpellButton("buttonSpellMasterySpeed", "Interface/icons/ability_demonhunter_doublejump", "|cffffffffMaîtrise de la vitesse|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Lancer de glaive augmente votre vitesse de déplacement de 5% en s'empilant 3 fois, dure 4 secondes.|r", "spellmasteryspeed", 700, -345)
-- CreateSpellButton("buttonSpellImprovedFireGlaives", "Interface/icons/inv_glaive_1h_artifactazgalor_d_04dual", "|cffffffffGlaives de feu améliorées|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Augmente l'efficacité de Burning, en augmentant ses dégâts de 12% et en augmentant sa durée de 55%.|r", "spellimprovedfireglaives", 860, -290)
-- CreateSpellButton("buttonSpellCauterize", "Interface/icons/spell_burningbladeshaman_blazing_radiance", "|cffffffffCautérisation|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Lancer de glaive réduit la résistance au feu de vos ennemis de 10000 pendant 10 sec.|r", "spellcauterize", 915, -345)
-- CreateSpellButton("buttonSpellDualBladeDance", "Interface/icons/inv_glaive_1h_artifactazgalor_d_01", "|cffffffffLa danse des doubles lames|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Lance 2 de vos glaives démoniaques dans un tourbillon d'énergie,\ncausant 38% des dégâts de l'arme en dégâts de chaos sur 3 sec à tous les ennemis proches.|r", "spelldualbladedance", 970, -290)
-- CreateSpellButton("buttonSpellImprovedDualBlades", "Interface/icons/ability_demonhunter_bladedance", "|cffffffffLames doubles améliorées|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Augmente la durée de Dual Blade Dance de 65%.|r", "spellimproveddualblades", 1025, -345)
-- CreateSpellButton("buttonSpellBloodlet", "Interface/icons/ability_demonhunter_bloodlet", "|cffffffffBloodlet|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Lancer de glaive fait saigner vos ennemis pour 30% des dégâts infligés, cumulable 3 fois sur 15 sec.|r", "spellbloodlet", 645, -398)
-- CreateSpellButton("buttonSpellRapidGlaives", "Interface/icons/inv_glaive_1h_npc_c_02", "|cffffffffGlaives rapides|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Lance simultanément vos Glaives, infligeant des dégâts à un maximum de 3 cibles toutes les 0.5 sec, dure 3 seconds.|r", "spellrapidglaives", 805, -345)
-- CreateSpellButton("buttonSpellVenomlet", "Interface/icons/inv_glaive_1h_artifactazgalor_d_02dual", "|cffffffffVenomlet|r\n|cffffffffTalent|r |cffc7690cMaître du glaive|r\n|cffffffffRequiert|r |cffa330c9Chasseur de démons|r\n|cffffd100Lancer de glaive empoisonne vos ennemis en leur infligeant 15% des dégâts infligés\net réduit leur résistance à la nature de 2000, cumulable 3 fois sur 15 sec.|r", "spellvenomlet", 1075, -398)


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

-- Créez le bouton Save à l'intérieur de la fenêtre frameTalentDemonhunter
local saveButton = CreateFrame("Button", "saveButton", frameTalentDemonhunter, "UIPanelButtonTemplate")
saveButton:SetSize(85, 25)
saveButton:SetPoint("BOTTOMRIGHT", buttonTalentDemonhunterClose, "BOTTOMLEFT", -185, 5) -- Place le bouton Save à gauche du bouton Close
saveButton:SetText(saveButtonText)

-- Fonction qui prend un screenshot quand le bouton est cliqué
saveButton:SetScript("OnClick", function()
    Screenshot()  -- Prendre un screenshot et l'enregistrer dans le dossier Screenshots du jeu
    print(screenshotMessage)  -- Affiche un message de confirmation en fonction de la locale
end)

-- Affiche l'UI des talents
--frameTalentDemonhunter:Show()

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

-- Créez le bouton Reset à l'intérieur de la fenêtre frameTalentDemonhunter
local buttonReset = CreateFrame("Button", "buttonReset", frameTalentDemonhunter, "UIPanelButtonTemplate")
buttonReset:SetSize(85, 25)
buttonReset:SetPoint("BOTTOMRIGHT", buttonTalentDemonhunterClose, "BOTTOMLEFT", -95, 5) -- Place le bouton Reset à gauche du bouton Reload
buttonReset:SetText(buttonResetText)

local function ResetTalents()
    -- Ajoutez ici la logique pour réinitialiser les talents du joueur
    AIO.Handle("TalentDemonhunterspell", "ResetTalents")
    resetButtonClicked = true -- Marquez le bouton Réinitialiser comme cliqué
end

buttonReset:SetScript("OnClick", ResetTalents)

-- Créez le bouton Reload à l'intérieur de la fenêtre frameTalentDemonhunter
local buttonReload = CreateFrame("Button", "buttonReload", frameTalentDemonhunter, "UIPanelButtonTemplate")
buttonReload:SetSize(85, 25)
buttonReload:SetPoint("BOTTOMRIGHT", buttonTalentDemonhunterClose, "BOTTOMLEFT", -5, 5) -- Place le bouton Reload à gauche du bouton Close
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
        frameTalentDemonhunter:Hide()
        buttonReload:Hide()
        PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
    else
        frameTalentDemonhunter:Show()
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
        frFR = "|cffffffffTalents|r |cffa330c9(Chasseur de démons)|r\n\nL'éventail des talents disponibles\npour améliorer et spécialiser\nvotre personnage.",
        enUS = "|cffffffffTalents|r |cffa330c9(Demon Hunter)|r\n\nThe range of available talents\nfor enhancing and specializing\nyour character."
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

-- Vérifier si le joueur est un Demonhunter avant de créer le bouton
local playerClass = select(2, UnitClass("player")) -- Obtenir la classe du joueur
if playerClass == "DEMONHUNTER" then
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
DemonhunterHandlers.UpdateTalentCount = function(player, talentsAppris)
    if fontTalentDemonhunterFrameText then
        fontTalentDemonhunterFrameText:SetText(talentsAppris .. " / " .. MAX_TALENTS)
    end
end

-- Mise à jour des points de talent utilisés avec texte localisé
DemonhunterHandlers.UpdateTalentPointsUsed = function(player, pointsUsed, pointsBeforeReset)
    -- Utilisation du texte localisé pour les points avant réinitialisation
    print(string.format(GetLocalizedPointsBeforeResetText(), pointsBeforeReset))
end

-- Affichage des talents restants (items 338404 dans le sac)
DemonhunterHandlers.UpdateTalentItemCount = function(player, count)
    if fontTalentPointsRemainingText then
        fontTalentPointsRemainingText:SetText("|cFFA330C9Talents restants : " .. count .. "|r")
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
        fontTalentPointsRemainingText:SetText("|cFFA330C9Talents restants : " .. (count or 0) .. "|r")
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
if playerClass == "DEMONHUNTER" then
    -- Surcharge OnHide pour synchroniser talentsWindowOpen quand Échap est pressé
    local _originalOnHide = frameTalentDemonhunter:GetScript("OnHide")
    frameTalentDemonhunter:SetScript("OnHide", function(self)
        talentsWindowOpen = false
        if _originalOnHide then _originalOnHide(self) end
    end)
    -- WoW appelle automatiquement Hide() sur les frames listées ici quand Échap est pressé
    tinsert(UISpecialFrames, "frameTalentDemonhunter")
end