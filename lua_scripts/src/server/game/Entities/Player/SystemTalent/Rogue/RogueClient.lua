local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local RogueHandlers = AIO.AddHandlers("TalentRoguespell", {})

function RogueHandlers.ShowTalentRogue(player)
    frameTalentRogue:Show()
    -- Redemande au serveur l’état visuel au cas où
    AIO.Handle("TalentRoguespell", "RequestLearnedTalents")
	-- Redemande le nombre de talents restants
    AIO.Handle("TalentRoguespell", "GetTalentItemCount")
end

local MAX_TALENTS = 70 -- Définition du nombre maximal de talents que le joueur peut apprendre

local OPEN_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_final_trait_unlocked.ogg"
local CLOSE_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_trait_refund_end.ogg"
local SPELL_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_80_azeritearmor_rotationends_02.ogg"

-- Attribute window
local frameTalentRogue = CreateFrame("Frame", "frameTalentRogue", UIParent)
frameTalentRogue:SetSize(1200, 650)
frameTalentRogue:SetMovable(true)
frameTalentRogue:EnableMouse(true)
frameTalentRogue:RegisterForDrag("LeftButton")
frameTalentRogue:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, -50) -- Adjust the X and Y coordinates
frameTalentRogue:SetBackdrop(
{
    -- bgFile = "interface/TalentFrame/talentsclassbackgroundRogue", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    bgFile = "interface/TalentFrame/Template/Class/Rogue/talentsclassbackgroundrogue2", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedrogue", --Interface/DialogFrame/UI-DialogBox-Border
    edgeSize = 20,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})

-- Ajoutez la texture de l'icône du Voleur
local rogueIcon = frameTalentRogue:CreateTexture("RogueIcon", "OVERLAY")
rogueIcon:SetTexture("Interface\\TalentFrame\\Template\\Class\\Rogue\\IconeRogue.blp")
rogueIcon:SetSize(60, 60)
rogueIcon:SetPoint("TOPLEFT", frameTalentRogue, "TOPLEFT", -10, 10)

-- Template Talent Frame

-- Ajoute une textureone pour l'image BLP
local textureone = frameTalentRogue:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
textureone:SetTexture("Interface\\TalentFrame\\Template\\Class\\Rogue\\TalentFrameTemplate.blp")
textureone:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
textureone:SetPoint("TOPLEFT", frameTalentRogue, "TOPLEFT", -170, 140) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentRogue:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Ajoute une texturetwo pour l'image BLP
local texturetwo = frameTalentRogue:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
texturetwo:SetTexture("Interface\\TalentFrame\\Template\\Class\\Rogue\\TalentFrameTemplateOriginal.blp")
texturetwo:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
texturetwo:SetPoint("TOPRIGHT", frameTalentRogue, "TOPRIGHT", 170, 140) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentRogue:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Drag & Drop
frameTalentRogue:SetScript("OnDragStart", frameTalentRogue.StartMoving)
frameTalentRogue:SetScript("OnHide", frameTalentRogue.StopMovingOrSizing)
frameTalentRogue:SetScript("OnDragStop", frameTalentRogue.StopMovingOrSizing)
frameTalentRogue:Hide()

-- Nouveau template d'arête
frameTalentRogue:SetBackdropBorderColor(1, 1, 0.5) -- Couleur Jaune

-- Close button
local buttonTalentRogueClose = CreateFrame("Button", "buttonTalentRogueClose", frameTalentRogue, "UIPanelCloseButton")
buttonTalentRogueClose:SetPoint("TOPRIGHT", -12, -12)
buttonTalentRogueClose:EnableMouse(true)
buttonTalentRogueClose:SetSize(32, 32)

local function CloseTalentWindow()
    frameTalentRogue:Hide()
    PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
end

-- Associez la fonction de fermeture au bouton de fermeture
buttonTalentRogueClose:SetScript("OnClick", CloseTalentWindow)

-- Title bar
local frameTalentRogueTitleBar = CreateFrame("Frame", "frameTalentRogueTitleBar", frameTalentRogue, nil)
frameTalentRogueTitleBar:SetSize(135, 25)
frameTalentRogueTitleBar:SetBackdrop(
{
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedrogue",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentRogueTitleBar:SetPoint("TOP", 0, 20)

local fontTalentRogueTitleText = frameTalentRogueTitleBar:CreateFontString("fontTalentRogueTitleText")
fontTalentRogueTitleText:SetFont("Fonts\\FRIZQT__.TTF", 13)
fontTalentRogueTitleText:SetSize(190, 5)
fontTalentRogueTitleText:SetPoint("CENTER", 0, 0)
fontTalentRogueTitleText:SetText("|cffFFC125Talents|r")

-- Détecte la langue du client
local locale = GetLocale() -- Retourne "enUS", "frFR", etc.

-- Table des traductions
local localizedTexts = {
    enUS = "|cffFFC125Rogue|r",
    frFR = "|cffFFC125Voleur|r",
}

-- Récupère le texte correspondant à la langue actuelle ou par défaut en anglais
local textToDisplay = localizedTexts[locale] or localizedTexts["enUS"]

local fontTalentRogueFrameText = frameTalentRogueTitleBar:CreateFontString("fontTalentRogueFrameText")
fontTalentRogueFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentRogueFrameText:SetSize(200, 5)
fontTalentRogueFrameText:SetPoint("TOPLEFT", frameTalentRogueTitleBar, "BOTTOMLEFT", -30, -35) -- Adjust the Y offset as needed
fontTalentRogueFrameText:SetText(textToDisplay)

-- Remplacez votre ligne existante pour la création du texte par celle-ci
local fontTalentRogueFrameText = frameTalentRogueTitleBar:CreateFontString("fontTalentRogueFrameText")
fontTalentRogueFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentRogueFrameText:SetSize(200, 5)
fontTalentRogueFrameText:SetPoint("TOPLEFT", frameTalentRogueTitleBar, "BOTTOMLEFT", -30, -60) -- Adjust the Y offset as needed
fontTalentRogueFrameText:SetText("0 / " .. MAX_TALENTS) -- Initialisez le texte avec 0 talents appris

-------------------------------------------------------------
-- Affichage "Talents restants" (item 338404 dans le sac)
-------------------------------------------------------------

local frameTalentPointsRemaining = CreateFrame("Frame", "frameTalentPointsRemaining", frameTalentRogue, nil)
frameTalentPointsRemaining:SetSize(220, 30)
frameTalentPointsRemaining:SetBackdrop({
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedrogue",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentPointsRemaining:SetPoint("BOTTOMRIGHT", frameTalentRogue, "BOTTOMRIGHT", -960, 10)

local fontTalentPointsRemainingText = frameTalentPointsRemaining:CreateFontString("fontTalentPointsRemainingText")
fontTalentPointsRemainingText:SetFont("Fonts\\FRIZQT__.TTF", 14)
fontTalentPointsRemainingText:SetSize(210, 20)
fontTalentPointsRemainingText:SetPoint("CENTER", 0, 0)
fontTalentPointsRemainingText:SetText("|cFFFFF569Talents restants : 0|r")
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
RogueHandlers.UpdateLearnedTalents = function(player, learnedSpells)
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

    local button = CreateFrame("Button", name, frameTalentRogue, nil)
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
                AIO.Handle("TalentRoguespell", talentHandler, 1)
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

-- Assassinat

-- Table des sorts
local spells = {
{
    id = "spellImprovedEviscerate",
    name = "buttonSpellImprovedEviscerate",
    icon = "Interface/icons/ability_rogue_eviscerate",
    position = {100, -80},
    handler = "spellimprovedeviscerate",
    tooltips = {
        frFR = "|cffffffffEviscération améliorée|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente les dégâts infligés par votre technique Eviscération de 20%.|r",
        enUS = "|cffffffffImproved Eviscerate|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases the damage done by your Eviscerate ability by 20%.|r"
    }
},
{
    id = "spellRemorselessAttacks",
    name = "buttonSpellRemorselessAttacks",
    icon = "Interface/icons/ability_fiegndead",
    position = {205, -75},
    handler = "spellremorselessattacks",
    tooltips = {
        frFR = "|cffffffffAttaques impitoyables|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Lorsque vous tuez un adversaire qui vous fait gagner de l'expérience ou de l'honneur,\nvous avez 40% de chances d'infliger un coup critique lors de votre prochaine attaque avec\nAttaque pernicieuse, Hémorragie, Attaque sournoise, Estropier, Embuscade ou Frappe fantomatique.\nDure 20 seconds.|r",
        enUS = "|cffffffffRemorseless Attacks|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100After killing an opponent that yields experience or honor,\nyou have a 40% chance to inflict a critical strike with your next Sinister Strike, Hemorrhage, Backstab, Mutilate, Ambush, or Ghostly Strike.\nLasts 20 seconds.|r"
    }
},
{
    id = "spellMalice",
    name = "buttonSpellMalice",
    icon = "Interface/icons/ability_racial_bloodrage",
    position = {315, -75},
    handler = "spellmalice",
    tooltips = {
        frFR = "|cffffffffMalice|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente vos chances d'infliger un coup critique de 5%.|r",
        enUS = "|cffffffffMalice|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases your chance to score a critical strike by 5%.|r"
    }
},
{
    id = "spellRuthlessness",
    name = "buttonSpellRuthlessness",
    icon = "Interface/icons/ability_druid_disembowel",
    position = {418, -80},
    handler = "spellruthlessness",
    tooltips = {
        frFR = "|cffffffffNémésis|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Confère à vos coups de grâce en mêlée 60% de chances d'ajouter un point de combo à votre cible.|r",
        enUS = "|cffffffffRuthlessness|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Your melee finishing moves have a 60% chance to add a combo point to your target.|r"
    }
},
{
    id = "spellBloodSpatter",
    name = "buttonSpellBloodSpatter",
    icon = "Interface/icons/ability_rogue_bloodsplatter",
    position = {45, -130},
    handler = "spellbloodspatter",
    tooltips = {
        frFR = "|cffffffffEclaboussure de sang|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente les points de dégâts infligés par vos techniques Garrot et Rupture de 30%.|r",
        enUS = "|cffffffffBlood Spatter|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases the damage dealt by your Garrote and Rupture abilities by 30%.|r"
    }
},
{
    id = "spellPuncturingWounds",
    name = "buttonSpellPuncturingWounds",
    icon = "Interface/icons/ability_backstab",
    position = {150, -130},
    handler = "spellpuncturingwounds",
    tooltips = {
        frFR = "|cffffffffBlessures transperçantes|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente vos chances d'infliger un coup critique avec la technique Attaque sournoise de 30%\net vos chances d'infliger un coup critique avec la technique Estropier de 15%.|r",
        enUS = "|cffffffffPuncturing Wounds|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases your critical strike chance with Backstab by 30%\nand with Mutilate by 15%.|r"
    }
},
{
    id = "spellVigor",
    name = "buttonSpellVigor",
    icon = "Interface/icons/spell_nature_earthbindtotem",
    position = {260, -130},
    handler = "spellvigor",
    tooltips = {
        frFR = "|cffffffffVigueur|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente votre maximum d'Energie de 10.|r",
        enUS = "|cffffffffVigor|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases your maximum Energy by 10.|r"
    }
},
{
    id = "spellImprovedExposeArmor",
    name = "buttonSpellImprovedExposeArmor",
    icon = "Interface/icons/ability_warrior_riposte",
    position = {370, -130},
    handler = "spellimprovedexposearmor",
    tooltips = {
        frFR = "|cffffffffExposer l'armure amélioré|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit le coût en énergie de votre technique Exposer l'armure de 10.|r",
        enUS = "|cffffffffImproved Expose Armor|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Reduces the Energy cost of your Expose Armor ability by 10.|r"
    }
},
{
    id = "spellLethality",
    name = "buttonSpellLethality",
    icon = "Interface/icons/ability_criticalstrike",
    position = {475, -133},
    handler = "spelllethality",
    tooltips = {
        frFR = "|cffffffffMortalité|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente de 30% le bonus aux dégâts des coups critiques de toutes\nvos techniques de combo générant des points et ne nécessitant pas d'être camouflé.|r",
        enUS = "|cffffffffLethality|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases the critical strike damage bonus of all your combo point-generating abilities\nthat do not require stealth by 30%.|r"
    }
},
{
    id = "spellVilePoisons",
    name = "buttonSpellVilePoisons",
    icon = "Interface/icons/ability_rogue_feigndeath",
    position = {96, -185},
    handler = "spellvilepoisons",
    tooltips = {
        frFR = "|cffffffffPoisons abominables|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente de 20% les points de dégâts infligés par vos poisons et votre technique Envenimer\net donne à vos poisons de dégâts sur la durée 30% de chances supplémentaires de résister aux effets de dissipation.|r",
        enUS = "|cffffffffVile Poisons|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases the damage dealt by your poisons and Envenom ability by 20%\nand gives your damage-over-time poison effects a 30% increased chance to resist dispel effects.|r"
    }
},
{
    id = "spellImprovedPoisons",
    name = "buttonSpellImprovedPoisons",
    icon = "Interface/icons/ability_poisons",
    position = {205, -185},
    handler = "spellimprovedpoisons",
    tooltips = {
        frFR = "|cffffffffPoisons améliorés|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente vos chances d'appliquer Poison mortel sur votre cible de 20%\net la fréquence à laquelle vous appliquez Poison instantané sur votre cible de 50%.|r",
        enUS = "|cffffffffImproved Poisons|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases your chance to apply Deadly Poison to your target by 20%\nand the frequency of applying Instant Poison by 50%.|r"
    }
},
{
    id = "spellFleetFooted",
    name = "buttonSpellFleetFooted",
    icon = "Interface/icons/ability_rogue_fleetfooted",
    position = {315, -185},
    handler = "spellfleetfooted",
    tooltips = {
        frFR = "|cffffffffPied léger|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit de 30% la durée de tous les effets affectant le mouvement et augmente de 15% votre vitesse de déplacement.\nNe se cumule pas avec les autres effets qui augmentent la vitesse de déplacement.|r",
        enUS = "|cffffffffFleet Footed|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Reduces the duration of all movement impairing effects by 30% and increases your movement speed by 15%.\nDoes not stack with other movement speed increases.|r"
    }
},
{
    id = "spellColdBlood",
    name = "buttonSpellColdBlood",
    icon = "Interface/icons/spell_ice_lament",
    position = {422, -185},
    handler = "spellcoldblood",
    tooltips = {
        frFR = "|cffffffffSang froid|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Lorsque vous déclenchez ce talent, vos chances d'infliger un coup critique avec votre prochaine technique offensive augmentent de 100%.|r",
        enUS = "|cffffffffCold Blood|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100When activated, increases the critical strike chance of your next offensive ability by 100%.|r"
    }
},
{
    id = "spellImprovedKidneyShot",
    name = "buttonSpellImprovedKidneyShot",
    icon = "Interface/icons/ability_rogue_kidneyshot",
    position = {527, -190},
    handler = "spellimprovedkidneyshot",
    tooltips = {
        frFR = "|cffffffffAiguillon perfide amélioré|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Lorsqu'elle est affectée par votre technique Aiguillon perfide,\nla cible subit 9% de points de dégâts supplémentaires de toutes les sources.|r",
        enUS = "|cffffffffImproved Kidney Shot|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100While under the effect of your Kidney Shot ability,\ntargets take 9% increased damage from all sources.|r"
    }
},
{
    id = "spellQuickRecovery",
    name = "buttonSpellQuickRecovery",
    icon = "Interface/icons/ability_rogue_quickrecovery",
    position = {43, -240},
    handler = "spellquickrecovery",
    tooltips = {
        frFR = "|cffffffffRétablissement rapide|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente tous les effets de soins utilisés sur vous de 20%.\nDe plus, vous êtes remboursé de 80% du coût en énergie de vos coups de grâce s’ils ne touchent pas la cible.|r",
        enUS = "|cffffffffQuick Recovery|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases the healing effects used on you by 20%.\nAlso, you regain 80% of the Energy cost of finishing moves that fail to hit their target.|r"
    }
},
{
    id = "spellSealFate",
    name = "buttonSpellSealFate",
    icon = "Interface/icons/spell_shadow_chilltouch",
    position = {150, -240},
    handler = "spellsealfate",
    tooltips = {
        frFR = "|cffffffffScelle le destin|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Les coups critiques infligés par les techniques qui ajoutent un point de combo ont 100% de chances de\nvous faire gagner un point de combo supplémentaire.|r",
        enUS = "|cffffffffSeal Fate|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Critical strikes from abilities that add combo points have a 100% chance to\nadd an additional combo point.|r"
    }
},
{
    id = "spellMurder",
    name = "buttonSpellMurder",
    icon = "Interface/icons/spell_shadow_deathscream",
    position = {260, -240},
    handler = "spellmurder",
    tooltips = {
        frFR = "|cffffffffMeurtre|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente tous les dégâts infligés de 4%.|r",
        enUS = "|cffffffffMurder|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases all damage dealt by 4%.|r"
    }
},
{
    id = "spellDeadlyBrew",
    name = "buttonSpellDeadlyBrew",
    icon = "Interface/icons/ability_rogue_deadlybrew",
    position = {368, -240},
    handler = "spelldeadlybrew",
    tooltips = {
        frFR = "|cffffffffBreuvage mortel|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Quand vous appliquez Poison instantané, douloureux ou de distraction mentale à une cible,\nvous avez 100% de chances d'appliquer Poison affaiblissant.|r",
        enUS = "|cffffffffDeadly Brew|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100When you apply Instant, Wound, or Mind-Numbing Poison to a target,\nyou have a 100% chance to apply Crippling Poison.|r"
    }
},
{
    id = "spellOverkill",
    name = "buttonSpellOverkill",
    icon = "Interface/icons/ability_hunter_rapidkilling",
    position = {478, -240},
    handler = "spelloverkill",
    tooltips = {
        frFR = "|cffffffffOutrance meurtrière|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Lorsque vous êtes camouflé et pendant 20 secondes après la fin du camouflage, vous régénérez 30% d'énergie supplémentaire.|r",
        enUS = "|cffffffffOverkill|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100While stealthed and for 20 seconds after breaking stealth, you regenerate 30% additional energy.|r"
    }
},
{
    id = "spellDeadenedNerves",
    name = "buttonSpellDeadenedNerves",
    icon = "Interface/icons/ability_rogue_deadenednerves",
    position = {98, -293},
    handler = "spelldeadenednerves",
    tooltips = {
        frFR = "|cffffffffAnesthésie nerveuse|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit tous les dégâts subis de 6%.|r",
        enUS = "|cffffffffDeadened Nerves|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Reduces all damage taken by 6%.|r"
    }
},
{
    id = "spellFocusedAttacks",
    name = "buttonSpellFocusedAttacks",
    icon = "Interface/icons/ability_rogue_focusedattacks",
    position = {205, -293},
    handler = "spellfocusedattacks",
    tooltips = {
        frFR = "|cffffffffAttaques focalisées|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vos frappes critiques en mêlée ont 100% de chances de vous donner 2 points d'énergie.|r",
        enUS = "|cffffffffFocused Attacks|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Your melee critical strikes have a 100% chance to generate 2 energy points.|r"
    }
},
{
    id = "spellFindWeakness",
    name = "buttonSpellFindWeakness",
    icon = "Interface/icons/ability_rogue_findweakness",
    position = {315, -293},
    handler = "spellfindweakness",
    tooltips = {
        frFR = "|cffffffffDécouverte des faiblesses|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Dégâts des techniques offensives augmentés de 6%.|r",
        enUS = "|cffffffffFind Weakness|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Offensive ability damage increased by 6%.|r"
    }
},
{
    id = "spellMasterPoisoner",
    name = "buttonSpellMasterPoisoner",
    icon = "Interface/icons/ability_creature_poison_06",
    position = {422, -293},
    handler = "spellmasterpoisoner",
    tooltips = {
        frFR = "|cffffffffMaître empoisonneur|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente de 3% les chances de coup critique de toutes les attaques contre une cible que vous avez empoisonnée,\nréduit de 50% la durée de tous les effets de poison appliqués sur vous et confère à Envenimer 100% de chances de ne pas consommer Poison mortel.|r",
        enUS = "|cffffffffMaster Poisoner|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases the critical strike chance of all attacks against a poisoned target by 3%,\nreduces the duration of all poison effects applied to you by 50%, and grants Envenom a 100% chance not to consume Deadly Poison.|r"
    }
},
{
    id = "spellMutilate",
    name = "buttonSpellMutilate",
    icon = "Interface/icons/ability_rogue_shadowstrikes",
    position = {527, -295},
    handler = "spellmutilate",
    tooltips = {
        frFR = "|cffffffffEstropier|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Attaque instantanément avec les deux armes et inflige 100% des dégâts des armes plus 44 points de dégâts avec chacune d'elles.\nLes dégâts sont augmentés de 20% contre les cibles empoisonnées.\nVous gagnez 2 points de combo.|r",
        enUS = "|cffffffffMutilate|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Instantly attacks with both weapons, dealing 100% weapon damage plus 44 with each.\nDamage is increased by 20% against poisoned targets.\nAwards 2 combo points.|r"
    }
},
{
    id = "spellTurntheTables",
    name = "buttonSpellTurntheTables",
    icon = "Interface/icons/ability_rogue_turnthetables",
    position = {43, -350},
    handler = "spellturnthetables",
    tooltips = {
        frFR = "|cffffffffRetour à l'envoyeur|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Chaque fois qu'un membre de votre groupe ou raid bloque, esquive ou pare une attaque,\nvos chances de critique avec les actions de combo sont augmentées de 6% pendant 8 seconds.|r",
        enUS = "|cffffffffTurn the Tables|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Whenever a party or raid member dodges, blocks, or parries an attack,\nyour critical strike chance with combo moves increases by 6% for 8 seconds.|r"
    }
},
{
    id = "spellCuttotheChase",
    name = "buttonSpellCuttotheChase",
    icon = "Interface/icons/ability_rogue_cuttothechase",
    position = {260, -350},
    handler = "spellcuttothechase",
    tooltips = {
        frFR = "|cffffffffTailler dans le vif|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vos techniques Eviscération et Envenimer ont 100% de chances de réinitialiser la durée de Débiter à son maximum de 5 points de combo.|r",
        enUS = "|cffffffffCut to the Chase|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Your Eviscerate and Envenom abilities have a 100% chance to refresh the duration of Slice and Dice to its maximum for 5 combo points.|r"
    }
},
{
    id = "spellHungerForBlood",
    name = "buttonSpellHungerForBlood",
    icon = "Interface/icons/ability_rogue_hungerforblood",
    position = {150, -350},
    handler = "spellhungerforblood",
    tooltips = {
        frFR = "|cffffffffSoif de sang|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vous fait enrager, ce qui augmente tous les dégâts causés de 5%.\nNécessite qu'un effet de saignement soit actif sur la cible.\nDure 60 seconds.|r",
        enUS = "|cffffffffHunger For Blood|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Enrages you, increasing all damage caused by 5%.\nRequires a bleed effect to be active on the target.\nLasts 60 seconds.|r"
    }
},

-- CreateSpellButton("buttonSpellImprovedEviscerate", "Interface/icons/ability_rogue_eviscerate", "|cffffffffEviscération améliorée|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente les dégâts infligés par votre technique Eviscération de 20%.|r", "spellimprovedeviscerate", 100, -80)
-- CreateSpellButton("buttonSpellRemorselessAttacks", "Interface/icons/ability_fiegndead", "|cffffffffAttaques impitoyables|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Lorsque vous tuez un adversaire qui vous fait gagner de l'expérience ou de l'honneur,\nvous avez 40% de chances d'infliger un coup critique lors de votre prochaine attaque avec\nAttaque pernicieuse, Hémorragie, Attaque sournoise, Estropier, Embuscade ou Frappe fantomatique.\nDure 20 seconds.|r", "spellremorselessattacks", 205, -75)
-- CreateSpellButton("buttonSpellMalice", "Interface/icons/ability_racial_bloodrage", "|cffffffffMalice|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente vos chances d'infliger un coup critique de 5%.|r", "spellmalice", 315, -75)
-- CreateSpellButton("buttonSpellRuthlessness", "Interface/icons/ability_druid_disembowel", "|cffffffffNémésis|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Confère à vos coups de grâce en mêlée 60% de chances d'ajouter un point de combo à votre cible.|r", "spellruthlessness", 418, -80)
-- CreateSpellButton("buttonSpellBloodSpatter", "Interface/icons/ability_rogue_bloodsplatter", "|cffffffffEclaboussure de sang|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente les points de dégâts infligés par vos techniques Garrot et Rupture de 30%.|r", "spellbloodspatter", 45, -130)
-- CreateSpellButton("buttonSpellPuncturingWounds", "Interface/icons/ability_backstab", "|cffffffffBlessures transperçantes|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente vos chances d'infliger un coup critique avec la technique Attaque sournoise de 30%\net vos chances d'infliger un coup critique avec la technique Estropier de 15%.|r", "spellpuncturingwounds", 150, -130)
-- CreateSpellButton("buttonSpellVigor", "Interface/icons/spell_nature_earthbindtotem", "|cffffffffVigueur|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente votre maximum d'Energie de 10.|r", "spellvigor", 260, -130)
-- CreateSpellButton("buttonSpellImprovedExposeArmor", "Interface/icons/ability_warrior_riposte", "|cffffffffExposer l'armure amélioré|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit le coût en énergie de votre technique Exposer l'armure de 10.|r", "spellimprovedexposearmor", 370, -130)
-- CreateSpellButton("buttonSpellLethality", "Interface/icons/ability_criticalstrike", "|cffffffffMortalité|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente de 30% le bonus aux dégâts des coups critiques de toutes\nvos techniques de combo générant des points et ne nécessitant pas d'être camouflé.|r", "spelllethality", 475, -133)
-- CreateSpellButton("buttonSpellVilePoisons", "Interface/icons/ability_rogue_feigndeath", "|cffffffffPoisons abominables|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente de 20% les points de dégâts infligés par vos poisons et votre technique Envenimer\net donne à vos poisons de dégâts sur la durée 30% de chances supplémentaires de résister aux effets de dissipation.|r", "spellvilepoisons", 96, -185)
-- CreateSpellButton("buttonSpellImprovedPoisons", "Interface/icons/ability_poisons", "|cffffffffPoisons améliorés|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente vos chances d'appliquer Poison mortel sur votre cible de 20%\net la fréquence à laquelle vous appliquez Poison instantané sur votre cible de 50%.|r", "spellimprovedpoisons", 205, -185)
-- CreateSpellButton("buttonSpellFleetFooted", "Interface/icons/ability_rogue_fleetfooted", "|cffffffffPied léger|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit de 30% la durée de tous les effets affectant le mouvement et augmente de 15% votre vitesse de déplacement.\nNe se cumule pas avec les autres effets qui augmentent la vitesse de déplacement.|r", "spellfleetfooted", 315, -185)
-- CreateSpellButton("buttonSpellColdBlood", "Interface/icons/spell_ice_lament", "|cffffffffSang froid|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Lorsque vous déclenchez ce talent, vos chances d'infliger un coup critique avec votre prochaine technique offensive augmentent de 100%.|r", "spellcoldblood", 422, -185)
-- CreateSpellButton("buttonSpellImprovedKidneyShot", "Interface/icons/ability_rogue_kidneyshot", "|cffffffffAiguillon perfide amélioré|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Lorsqu'elle est affectée par votre technique Aiguillon perfide,\nla cible subit 9% de points de dégâts supplémentaires de toutes les sources.|r", "spellimprovedkidneyshot", 527, -190)
-- CreateSpellButton("buttonSpellQuickRecovery", "Interface/icons/ability_rogue_quickrecovery", "|cffffffffRétablissement rapide|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente tous les effets de soins utilisés sur vous de 20%.\nDe plus, vous êtes remboursé de 80% du coût en énergie de vos coups de grâce s’ils ne touchent pas la cible.|r", "spellquickrecovery", 43, -240)
-- CreateSpellButton("buttonSpellSealFate", "Interface/icons/spell_shadow_chilltouch", "|cffffffffScelle le destin|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Les coups critiques infligés par les techniques qui ajoutent un point de combo ont 100% de chances de\nvous faire gagner un point de combo supplémentaire.|r", "spellsealfate", 150, -240)
-- CreateSpellButton("buttonSpellMurder", "Interface/icons/spell_shadow_deathscream", "|cffffffffMeurtre|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente tous les dégâts infligés de 4%.|r", "spellmurder", 260, -240)
-- CreateSpellButton("buttonSpellDeadlyBrew", "Interface/icons/ability_rogue_deadlybrew", "|cffffffffBreuvage mortel|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Quand vous appliquez Poison instantané, douloureux ou de distraction mentale à une cible,\nvous avez 100% de chances d'appliquer Poison affaiblissant.|r", "spelldeadlybrew", 368, -240)
-- CreateSpellButton("buttonSpellOverkill", "Interface/icons/ability_hunter_rapidkilling", "|cffffffffOutrance meurtrière|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Lorsque vous êtes camouflé et pendant 20 secondes après la fin du camouflage, vous régénérez 30% d'énergie supplémentaire.|r", "spelloverkill", 478, -240)
-- CreateSpellButton("buttonSpellDeadenedNerves", "Interface/icons/ability_rogue_deadenednerves", "|cffffffffAnesthésie nerveuse|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit tous les dégâts subis de 6%.|r", "spelldeadenednerves", 98, -293)
-- CreateSpellButton("buttonSpellFocusedAttacks", "Interface/icons/ability_rogue_focusedattacks", "|cffffffffAttaques focalisées|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vos frappes critiques en mêlée ont 100% de chances de vous donner 2 points d'énergie.|r", "spellfocusedattacks", 205, -293)
-- CreateSpellButton("buttonSpellFindWeakness", "Interface/icons/ability_rogue_findweakness", "|cffffffffDécouverte des faiblesses|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Dégâts des techniques offensives augmentés de 6%.|r", "spellfindweakness", 315, -293)
-- CreateSpellButton("buttonSpellMasterPoisoner", "Interface/icons/ability_creature_poison_06", "|cffffffffMaître empoisonneur|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente de 3% les chances de coup critique de toutes les attaques contre une cible que vous avez empoisonnée,\nréduit de 50% la durée de tous les effets de poison appliqués sur vous et confère à Envenimer 100% de chances de ne pas consommer Poison mortel.|r", "spellmasterpoisoner", 422, -293)
-- CreateSpellButton("buttonSpellMutilate", "Interface/icons/ability_rogue_shadowstrikes", "|cffffffffEstropier|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Attaque instantanément avec les deux armes et inflige 100% des dégâts des armes plus 44 points de dégâts avec chacune d'elles.\nLes dégâts sont augmentés de 20% contre les cibles empoisonnées.\nVous gagnez 2 points de combo.|r", "spellmutilate", 527, -295)
-- CreateSpellButton("buttonSpellTurntheTables", "Interface/icons/ability_rogue_turnthetables", "|cffffffffRetour à l'envoyeur|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Chaque fois qu'un membre de votre groupe ou raid bloque, esquive ou pare une attaque,\nvos chances de critique avec les actions de combo sont augmentées de 6% pendant 8 seconds.|r", "spellturnthetables", 43, -350)
-- CreateSpellButton("buttonSpellCuttotheChase", "Interface/icons/ability_rogue_cuttothechase", "|cffffffffTailler dans le vif|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vos techniques Eviscération et Envenimer ont 100% de chances de réinitialiser la durée de Débiter à son maximum de 5 points de combo.|r", "spellcuttothechase", 260, -350)
-- CreateSpellButton("buttonSpellHungerForBlood", "Interface/icons/ability_rogue_hungerforblood", "|cffffffffSoif de sang|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vous fait enrager, ce qui augmente tous les dégâts causés de 5%.\nNécessite qu'un effet de saignement soit actif sur la cible.\nDure 60 seconds.|r", "spellhungerforblood", 150, -350)

-- Combat

{
    id = "spellImprovedSinisterStrike",
    name = "buttonSpellImprovedSinisterStrike",
    icon = "Interface/icons/spell_shadow_ritualofsacrifice",
    position = {368, -350},
    handler = "spellimprovedsinisterstrike",
    tooltips = {
        frFR = "|cffffffffAttaque pernicieuse améliorée|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit de 5 le coût en énergie de votre technique Attaque pernicieuse.|r",
        enUS = "|cffffffffImproved Sinister Strike|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Reduces the energy cost of your Sinister Strike ability by 5.|r"
    }
},
{
    id = "spellDualWieldSpecialization",
    name = "buttonSpellDualWieldSpecialization",
    icon = "Interface/icons/ability_dualwield",
    position = {527, -510},
    handler = "spelldualwieldspecialization",
    tooltips = {
        frFR = "|cffffffffSpécialisation Ambidextrie|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente les points de dégâts infligés par l'arme que vous utilisez en main gauche de 50%.|r",
        enUS = "|cffffffffDual Wield Specialization|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases the damage dealt by the weapon you use in your off-hand by 50%.|r"
    }
},
{
    id = "spellCrimsonVial",
    name = "buttonSpellCrimsonVial",
    icon = "Interface/icons/ability_rogue_crimsonvial",
    position = {478, -350},
    handler = "spelldualcrimsonvial",
    tooltips = {
        frFR = "|cffffffffFiole cramoisie|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vous buvez une décoction alchimique qui vous rend 400% de votre maximum de points de vie en 4 sec.|r",
        enUS = "|cffffffffCrimson Vial|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100You drink an alchemical concoction that restores 400% of your maximum health over 4 seconds.|r"
    }
},
{
    id = "spellShroudofConcealment",
    name = "buttonSpellShroudofConcealment",
    icon = "Interface/icons/ability_rogue_shroudofconcealment",
    position = {527, -402},
    handler = "spellshroudofconcealment",
    tooltips = {
        frFR = "|cffffffffVoile de dissimulation|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Déploie une cape qui enveloppe les membres du\ngroupe ou raid à moins de 20 mètres dans les\nombres, les dissimulant aux yeux des autres\npendant 15 s au maximum.|r",
        enUS = "|cffffffffShroud of Concealment|r\n|cffffffffTalent|r |cffea0000Assassination|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Extend a cloak that wraps party and raid\nmembers within 20 yards in shadows, concealing\nthem from sight for up to 15 sec.|r"
    }
},
{
    id = "spellImprovedSliceandDice",
    name = "buttonSpellImprovedSliceandDice",
    icon = "Interface/icons/ability_rogue_slicedice",
    position = {98, -405},
    handler = "spellimprovedsliceanddice",
    tooltips = {
        frFR = "|cffffffffDébiter amélioré|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente la durée de votre technique Débiter de 50%.|r",
        enUS = "|cffffffffImproved Slice and Dice|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases the duration of your Slice and Dice ability by 50%.|r"
    }
},
{
    id = "spellDeflection",
    name = "buttonSpellDeflection",
    icon = "Interface/icons/ability_parry",
    position = {205, -405},
    handler = "spelldeflection",
    tooltips = {
        frFR = "|cffffffffDéviation|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente vos chances de Parer de 6%.|r",
        enUS = "|cffffffffDeflection|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases your chance to Parry by 6%.|r"
    }
},
{
    id = "spellPrecision",
    name = "buttonSpellPrecision",
    icon = "Interface/icons/ability_marksmanship",
    position = {315, -405},
    handler = "spellprecision",
    tooltips = {
        frFR = "|cffffffffPrécision|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente vos chances de toucher avec les armes et les attaques empoisonnées de 5%.|r",
        enUS = "|cffffffffPrecision|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases your chance to hit with weapons and poison attacks by 5%.|r"
    }
},
{
    id = "spellEndurance",
    name = "buttonSpellEndurance",
    icon = "Interface/icons/spell_shadow_shadowward",
    position = {422, -405},
    handler = "spellendurance",
    tooltips = {
        frFR = "|cffffffffEndurcissement|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit le temps de recharge de vos techniques Sprint et Evasion de 60 sec.\net augmente votre total d'Endurance de 4%.|r",
        enUS = "|cffffffffEndurance|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Reduces the cooldown of your Sprint and Evasion abilities by 60 sec.\nand increases your total Stamina by 4%.|r"
    }
},
{
    id = "spellRiposte",
    name = "buttonSpellRiposte",
    icon = "Interface/icons/ability_warrior_challange",
    position = {43, -458},
    handler = "spellriposte",
    tooltips = {
        frFR = "|cffffffffRiposte|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Une attaque disponible après avoir paré une attaque de l'adversaire.\nElle inflige 150% des dégâts de l'arme et réduit la vitesse d'attaque en mêlée de la cible de 20% pendant 30 secondes.\nVous gagnez 1 point de combo.|r",
        enUS = "|cffffffffRiposte|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100An attack available after parrying an opponent's attack.\nDeals 150% weapon damage and reduces the target's melee attack speed by 20% for 30 seconds.\nYou gain 1 combo point.|r"
    }
},
{
    id = "spellCloseQuartersCombat",
    name = "buttonSpellCloseQuartersCombat",
    icon = "Interface/icons/inv_weapon_shortblade_05",
    position = {150, -458},
    handler = "spellclosequarterscombat",
    tooltips = {
        frFR = "|cffffffffCombat rapproché|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente vos chances d'infliger un coup critique avec les Dagues et les Armes de pugilat de 5%.|r",
        enUS = "|cffffffffClose Quarters Combat|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases your chance to deal a critical strike with Daggers and Fist Weapons by 5%.|r"
    }
},
{
    id = "spellImprovedKick",
    name = "buttonSpellImprovedKick",
    icon = "Interface/icons/ability_kick",
    position = {260, -458},
    handler = "spellimprovedkick",
    tooltips = {
        frFR = "|cffffffffCoup de pied amélioré|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Confère à votre technique Coup de pied 100% de chances de rendre la cible muette pendant 2 secondes.|r",
        enUS = "|cffffffffImproved Kick|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Gives your Kick ability 100% chance to silence the target for 2 seconds.|r"
    }
},
{
    id = "spellRecuperate",
    name = "buttonSpellRecuperate",
    icon = "Interface/icons/ability_rogue_recuperate",
    position = {260, -563},
    handler = "spellrecuperate",
    tooltips = {
        frFR = "|cffffffffConversion|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Coup de grâce qui consomme les points de\ncombo sur une cible proche pour rendre [Conversion améliorée: 4] [3,5 / 3]%\ndu maximum des points de vie toutes les 3 s. La durée dépend du nombre de points de combo :\n1 point : 6 secondes\n2 points : 12 secondes\n3 points : 18 secondes\n4 points : 24 secondes\n5 points : 30 secondes|r",
        enUS = "|cffffffffRecuperate|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Finishing move that consumes combo points on\nany nearby target to restore [Improved Recuperate: 4] [3.5 / 3]%\nof maximum health every 3 sec.  Lasts longer per combo point:\n1 point : 6 seconds\n2 points : 12 seconds\n3 points : 18 seconds\n4 points : 24 seconds\n5 points : 30 seconds|r"
    }
},
{
    id = "spellImprovedSprint",
    name = "buttonSpellImprovedSprint",
    icon = "Interface/icons/ability_rogue_sprint",
    position = {368, -458},
    handler = "spellimprovedsprint",
    tooltips = {
        frFR = "|cffffffffSprint amélioré|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Confère 100% de chances d'annuler tous les effets affectant le mouvement lorsque vous activez votre technique Sprint.|r",
        enUS = "|cffffffffImproved Sprint|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Gives you 100% chance to cancel all movement impairing effects when you activate your Sprint ability.|r"
    }
},
{
    id = "spellLightningReflexes",
    name = "buttonSpellLightningReflexes",
    icon = "Interface/icons/spell_nature_invisibilty",
    position = {478, -458},
    handler = "spelllightningreflexes",
    tooltips = {
        frFR = "|cffffffffRéflexes éclairs|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente vos chances d'esquiver de 6% et vous octroie un bonus de 10 à la hâte en mêlée.|r",
        enUS = "|cffffffffLightning Reflexes|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases your dodge chance by 6% and grants you a 10 bonus to melee haste.|r"
    }
},
{
    id = "spellAggression",
    name = "buttonSpellAggression",
    icon = "Interface/icons/ability_racial_avatar",
    position = {98, -510},
    handler = "spellaggression",
    tooltips = {
        frFR = "|cffffffffAgressivité|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente de 15% les points de dégâts infligés par vos techniques Attaque pernicieuse, Attaque sournoise et Eviscération.|r",
        enUS = "|cffffffffAggression|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases the damage dealt by your Sinister Strike, Backstab, and Eviscerate abilities by 15%.|r"
    }
},
{
    id = "spellMaceSpecialization",
    name = "buttonSpellMaceSpecialization",
    icon = "Interface/icons/inv_mace_01",
    position = {205, -510},
    handler = "spellmacespecialization",
    tooltips = {
        frFR = "|cffffffffSpécialisation Masse|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vos attaques avec les masses ignorent jusqu'à 15% de l'armure de votre adversaire.|r",
        enUS = "|cffffffffMace Specialization|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Your attacks with maces ignore up to 15% of your opponent's armor.|r"
    }
},
{
    id = "spellBladeFlurry",
    name = "buttonSpellBladeFlurry",
    icon = "Interface/icons/ability_warrior_punishingblow",
    position = {315, -510},
    handler = "spellbladeflurry",
    tooltips = {
        frFR = "|cffffffffDéluge de lames|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente votre vitesse d'attaque de 20%.\nDe plus, vos attaques frappent un adversaire proche supplémentaire.\nDure 15 secondes.|r",
        enUS = "|cffffffffBlade Flurry|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases your attack speed by 20%. Additionally, your attacks strike one additional nearby enemy.\nLasts 15 seconds.|r"
    }
},
{
    id = "spellHackandSlash",
    name = "buttonSpellHackandSlash",
    icon = "Interface/icons/inv_sword_27",
    position = {422, -510},
    handler = "spellhackandslash",
    tooltips = {
        frFR = "|cffffffffTaillader et trancher|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vous confère 5% de chances de bénéficier d'une attaque supplémentaire sur la même cible après avoir frappé votre cible avec votre épée ou votre hache.|r",
        enUS = "|cffffffffHack and Slash|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Gives you a 5% chance to gain an additional attack on the same target after striking with your sword or axe.|r"
    }
},

-- CreateSpellButton("buttonSpellImprovedSinisterStrike", "Interface/icons/spell_shadow_ritualofsacrifice", "|cffffffffAttaque pernicieuse améliorée|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit de 5 le coût en énergie de votre technique Attaque pernicieuse.|r", "spellimprovedsinisterstrike", 368, -350)
-- CreateSpellButton("buttonSpellDualWieldSpecialization", "Interface/icons/ability_dualwield", "|cffffffffSpécialisation Ambidextrie|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente les points de dégâts infligés par l'arme que vous utilisez en main gauche de 50%.|r", "spelldualwieldspecialization", 527, -402)
-- CreateSpellButton("buttonSpellCrimsonVial", "Interface/icons/ability_rogue_crimsonvial", "|cffffffffFiole cramoisie|r\n|cffffffffTalent|r |cffea0000Assassinat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vous buvez une décoction alchimique qui vous rend 400% de votre maximum de points de vie en 4 sec.|r", "spelldualcrimsonvial", 478, -350)
-- CreateSpellButton("buttonSpellImprovedSliceandDice", "Interface/icons/ability_rogue_slicedice", "|cffffffffDébiter amélioré|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente la durée de votre technique Débiter de 50%.|r", "spellimprovedsliceanddice", 98, -405)
-- CreateSpellButton("buttonSpellDeflection", "Interface/icons/ability_parry", "|cffffffffDéviation|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente vos chances de Parer de 6%.|r", "spelldeflection", 205, -405)
-- CreateSpellButton("buttonSpellPrecision", "Interface/icons/ability_marksmanship", "|cffffffffPrécision|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente vos chances de toucher avec les armes et les attaques empoisonnées de 5%.|r", "spellprecision", 315, -405)
-- CreateSpellButton("buttonSpellEndurance", "Interface/icons/spell_shadow_shadowward", "|cffffffffEndurcissement|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit le temps de recharge de vos techniques Sprint et Evasion de 60 sec.\net augmente votre total d'Endurance de 4%.|r", "spellendurance", 422, -405)
-- CreateSpellButton("buttonSpellRiposte", "Interface/icons/ability_warrior_challange", "|cffffffffRiposte|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Une attaque disponible après avoir paré une attaque de l'adversaire.\nElle inflige 150% des dégâts de l'arme et réduit la vitesse d'attaque en mêlée de la cible de 20% pendant 30 seconds.\nVous gagnez 1 points de combo.|r", "spellriposte", 43, -458)
-- CreateSpellButton("buttonSpellCloseQuartersCombat", "Interface/icons/inv_weapon_shortblade_05", "|cffffffffCombat rapproché|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente vos chances d'infliger un coup critique avec les Dagues et les Armes de pugilat de 5%.|r", "spellclosequarterscombat", 150, -458)
-- CreateSpellButton("buttonSpellImprovedKick", "Interface/icons/ability_kick", "|cffffffffCoup de pied amélioré|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Confère à votre technique Coup de pied 100% de chances de rendre la cible muette pendant 2 seconds.|r", "spellimprovedkick", 260, -458)
-- CreateSpellButton("buttonSpellImprovedSprint", "Interface/icons/ability_rogue_sprint", "|cffffffffSprint amélioré|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Confère 100% de chances d'annuler tous les effets affectant le mouvement lorsque vous activez votre technique Sprint.|r", "spellimprovedsprint", 368, -458)
-- CreateSpellButton("buttonSpellLightningReflexes", "Interface/icons/spell_nature_invisibilty", "|cffffffffRéflexes éclairs|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente vos chances d'esquiver de 6% et vous octroie un bonus de 10 à la hâte en mêlée.|r", "spelllightningreflexes", 478, -458)
-- CreateSpellButton("buttonSpellAggression", "Interface/icons/ability_racial_avatar", "|cffffffffAgressivité|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente de 15% les points de dégâts infligés par vos techniques Attaque pernicieuse, Attaque sournoise et Eviscération.|r", "spellaggression", 98, -510)
-- CreateSpellButton("buttonSpellMaceSpecialization", "Interface/icons/inv_mace_01", "|cffffffffSpécialisation Masse|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vos attaques avec les masses ignorent jusqu'à 15% de l'armure de votre adversaire.|r", "spellmacespecialization", 205, -510)
-- CreateSpellButton("buttonSpellBladeFlurry", "Interface/icons/ability_warrior_punishingblow", "|cffffffffDéluge de lames|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente votre vitesse d'attaque de 20%.\nDe plus, vos attaques frappent un adversaire proche supplémentaire.\nDure 15 seconds.|r", "spellbladeflurry", 315, -510)
-- CreateSpellButton("buttonSpellHackandSlash", "Interface/icons/inv_sword_27", "|cffffffffTaillader et trancher|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vous confère 5% de chances de bénéficier d'une attaque supplémentaire sur la même cible après avoir frappé votre cible avec votre épée ou votre hache.|r", "spellhackandslash", 422, -510)

-- Template 2

{
    id = "spellWeaponExpertise",
    name = "buttonSpellWeaponExpertise",
    icon = "Interface/icons/spell_holy_blessingofstrength",
    position = {663, -75},
    handler = "spellweaponexpertise",
    tooltips = {
        frFR = "|cffffffffExpertise en armes|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente votre expertise de 10.|r",
        enUS = "|cffffffffWeapon Expertise|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases your expertise by 10.|r"
    }
},
{
    id = "spellBladeTwisting",
    name = "buttonSpellBladeTwisting",
    icon = "Interface/icons/ability_rogue_bladetwisting",
    position = {770, -75},
    handler = "spellbladetwisting",
    tooltips = {
        frFR = "|cffffffffTournoiement de lames|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente de 10% les dégâts infligés par Attaque pernicieuse et Attaque sournoise.\nDe plus, vos attaques en mêlée qui infligent des dégâts ont 10% de chances d'hébéter la cible pendant 8 secondes.|r",
        enUS = "|cffffffffBlade Twisting|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases the damage of Sinister Strike and Backstab by 10%. Additionally, your melee attacks that deal damage have a 10% chance to disorient the target for 8 seconds.|r"
    }
},
{
    id = "spellVitality",
    name = "buttonSpellVitality",
    icon = "Interface/icons/ability_warrior_revenge",
    position = {880, -75},
    handler = "spellvitality",
    tooltips = {
        frFR = "|cffffffffVitalité|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente votre taux de régénération d'énergie de 25%.|r",
        enUS = "|cffffffffVitality|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases your energy regeneration rate by 25%.|r"
    }
},
{
    id = "spellAdrenalineRush",
    name = "buttonSpellAdrenalineRush",
    icon = "Interface/icons/spell_shadow_shadowworddominate",
    position = {990, -75},
    handler = "spelladrenalinerush",
    tooltips = {
        frFR = "|cffffffffPoussée d'adrénaline|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente la vitesse de régénération de votre Énergie de 100% pendant 15 secondes.|r",
        enUS = "|cffffffffAdrenaline Rush|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases your energy regeneration rate by 100% for 15 seconds.|r"
    }
},
{
    id = "spellNervesofSteel",
    name = "buttonSpellNervesofSteel",
    icon = "Interface/icons/ability_rogue_nervesofsteel",
    position = {1100, -75},
    handler = "spellnervesofsteel",
    tooltips = {
        frFR = "|cffffffffNerfs d'acier|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit de 30% les dégâts subis lorsque vous êtes affecté par des effets d'étourdissement et de peur.|r",
        enUS = "|cffffffffNerves of Steel|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Reduces the damage taken by 30% when affected by stun and fear effects.|r"
    }
},
{
    id = "spellThrowingSpecialization",
    name = "buttonSpellThrowingSpecialization",
    icon = "Interface/icons/ability_rogue_throwingspecialization",
    position = {718, -130},
    handler = "spellthrowingspecialization",
    tooltips = {
        frFR = "|cffffffffSpécialisation Armes de jet|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente la portée de Lancer et Lancer mortel de 4 mètres et confère à votre Lancer mortel 100% de chances d'interrompre la cible pendant 3 secondes.|r",
        enUS = "|cffffffffThrowing Specialization|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases the range of Throw and Deadly Throw by 4 meters and grants Deadly Throw a 100% chance to interrupt the target for 3 seconds.|r"
    }
},
{
    id = "spellCombatPotency",
    name = "buttonSpellCombatPotency",
    icon = "Interface/icons/inv_weapon_shortblade_38",
    position = {825, -130},
    handler = "spellcombatpotency",
    tooltips = {
        frFR = "|cffffffffToute-puissance de combat|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Confère à vos attaques de mêlée avec la main gauche réussies 20% de chances de générer 15 points d'énergie.|r",
        enUS = "|cffffffffCombat Potency|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Grants your successful off-hand melee attacks a 20% chance to generate 15 energy points.|r"
    }
},
{
    id = "spellUnfairAdvantage",
    name = "buttonSpellUnfairAdvantage",
    icon = "Interface/icons/ability_rogue_unfairadvantage",
    position = {935, -130},
    handler = "spellunfairadvantage",
    tooltips = {
        frFR = "|cffffffffAvantage déloyal|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Chaque fois que vous esquivez une attaque, vous bénéficiez d'un Avantage déloyal,\nqui vous permet de contre-attaquer en infligeant 100% des dégâts de votre arme en main droite.\nCela ne peut se produire plus d'une fois par seconde.|r",
        enUS = "|cffffffffUnfair Advantage|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Each time you dodge an attack, you gain an Unfair Advantage, which allows you to counterattack dealing 100% of your off-hand weapon's damage.\nThis can only occur once per second.|r"
    }
},
{
    id = "spellSurpriseAttacks",
    name = "buttonSpellSurpriseAttacks",
    icon = "Interface/icons/ability_rogue_surpriseattack",
    position = {1045, -130},
    handler = "spellsurpriseattacks",
    tooltips = {
        frFR = "|cffffffffAttaques surprises|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vos coups de grâce ne peuvent plus être esquivés et les dégâts de vos techniques Attaque pernicieuse, Attaque sournoise,\nKriss, Hémorragie et Suriner sont augmentés de 10%.|r",
        enUS = "|cffffffffSurprise Attacks|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Your finishing moves can no longer be dodged, and the damage of your Sinister Strike, Backstab, Kris, Hemorrhage, and Garrote are increased by 10%.|r"
    }
},
{
    id = "spellImprovedGouge",
    name = "buttonSpellImprovedGouge",
    icon = "Interface/icons/ability_gouge",
    position = {663, -184},
    handler = "spellimprovedgouge",
    tooltips = {
        frFR = "|cffffffffSuriner amélioré|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente la durée de l'effet de votre technique Suriner de 1.5 sec.|r",
        enUS = "|cffffffffImproved Gouge|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases the duration of the effect of your Gouge ability by 1.5 sec.|r"
    }
},
{
    id = "spellSavageCombat",
    name = "buttonSpellSavageCombat",
    icon = "Interface/icons/ability_creature_disease_03",
    position = {770, -184},
    handler = "spellsavagecombat",
    tooltips = {
        frFR = "|cffffffffCombat sauvage|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente votre total de puissance d'attaque de 4% et tous les dégâts physiques infligés aux ennemis que vous avez empoisonnés sont augmentés de 4%.|r",
        enUS = "|cffffffffSavage Combat|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases your total attack power by 4%, and all physical damage dealt to poisoned enemies is increased by 4%.|r"
    }
},
{
    id = "spellPreyontheWeak",
    name = "buttonSpellPreyontheWeak",
    icon = "Interface/icons/ability_rogue_preyontheweak",
    position = {880, -184},
    handler = "spellpreyontheweak",
    tooltips = {
        frFR = "|cffffffffAttaquer les faibles|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Les dégâts de vos coups critiques sont augmentés de 20% quand la cible a moins de points de vie que vous (en pourcentage du total de points de vie).|r",
        enUS = "|cffffffffPrey on the Weak|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases the damage of your critical strikes by 20% when the target has fewer health points than you (in percentage of total health).|r"
    }
},
{
    id = "spellKillingSpree",
    name = "buttonSpellKillingSpree",
    icon = "Interface/icons/ability_rogue_murderspree",
    position = {990, -184},
    handler = "spellkillingspree",
    tooltips = {
        frFR = "|cffffffffSérie meurtrière|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Marche à travers les ombres d'ennemi en ennemi se trouvant à moins de 10 mètres et attaque un ennemi toutes les 0,5 sec.\navec les deux armes jusqu'à ce que 5 assauts aient été effectués.\nAugmente tous les dégâts de 20% pendant ce temps.\nPeut toucher la même cible plusieurs fois.\nNe peut pas toucher les cibles invisibles ou camouflées.|r",
        enUS = "|cffffffffKilling Spree|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Walk through enemy shadows, attacking a new enemy every 0.5 sec within 10 yards until 5 strikes are completed.\nIncreases all damage by 20% during this time.\nCan strike the same target multiple times.\nCannot hit invisible or stealthed targets.|r"
    }
},

-- CreateSpellButton("buttonSpellWeaponExpertise", "Interface/icons/spell_holy_blessingofstrength", "|cffffffffExpertise en armes|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente votre expertise de 10.|r", "spellweaponexpertise", 663, -75)
-- CreateSpellButton("buttonSpellBladeTwisting", "Interface/icons/ability_rogue_bladetwisting", "|cffffffffTournoiement de lames|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente de 10% les dégâts infligés par Attaque pernicieuse et Attaque sournoise.\nDe plus, vos attaques en mêlée qui infligent des dégâts ont 10% de chances d'hébéter la cible pendant 8 seconds.|r", "spellbladetwisting", 770, -75)
-- CreateSpellButton("buttonSpellVitality", "Interface/icons/ability_warrior_revenge", "|cffffffffVitalité|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente votre taux de régénération d'énergie de 25%.|r", "spellvitality", 880, -75)
-- CreateSpellButton("buttonSpellAdrenalineRush", "Interface/icons/spell_shadow_shadowworddominate", "|cffffffffPoussée d'adrénaline|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente la vitesse de régénération de votre Energie de 100% pendant 15 seconds.|r", "spelladrenalinerush", 990, -75)
-- CreateSpellButton("buttonSpellNervesofSteel", "Interface/icons/ability_rogue_nervesofsteel", "|cffffffffNerfs d'acier|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit de 30% les dégâts subis lorsque vous êtes affecté par des effets d'étourdissement et de peur.|r", "spellnervesofsteel", 1100, -75)
-- CreateSpellButton("buttonSpellThrowingSpecialization", "Interface/icons/ability_rogue_throwingspecialization", "|cffffffffSpécialisation Armes de jet|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente la portée de Lancer et Lancer mortel de 4 mètres et confère à votre Lancer mortel 100% de chances d'interrompre la cible pendant 3 seconds.|r", "spellthrowingspecialization", 718, -130)
-- CreateSpellButton("buttonSpellCombatPotency", "Interface/icons/inv_weapon_shortblade_38", "|cffffffffToute-puissance de combat|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Confère à vos attaques de mêlée avec la main gauche réussies 20% de chances de générer 15 points d'énergie.|r", "spellcombatpotency", 825, -130)
-- CreateSpellButton("buttonSpellUnfairAdvantage", "Interface/icons/ability_rogue_unfairadvantage", "|cffffffffAvantage déloyal|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Chaque fois que vous esquivez une attaque, vous bénéficiez d'un Avantage déloyal,\nqui vous permet de contre-attaquer en infligeant 100% des dégâts de votre arme en main droite.\nCela ne peut se produire plus d'une fois par seconde.|r", "spellunfairadvantage", 935, -130)
-- CreateSpellButton("buttonSpellSurpriseAttacks", "Interface/icons/ability_rogue_surpriseattack", "|cffffffffAttaques surprises|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vos coups de grâce ne peuvent plus être esquivés et les dégâts de vos techniques Attaque pernicieuse, Attaque sournoise,\nKriss, Hémorragie et Suriner sont augmentés de 10%.|r", "spellsurpriseattacks", 1045, -130)
-- CreateSpellButton("buttonSpellImprovedGouge", "Interface/icons/ability_gouge", "|cffffffffSuriner amélioré|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente la durée de l'effet de votre technique Suriner de 1.5 sec.|r", "spellimprovedgouge", 663, -184)
-- CreateSpellButton("buttonSpellSavageCombat", "Interface/icons/ability_creature_disease_03", "|cffffffffCombat sauvage|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente votre total de puissance d'attaque de 4% et tous les dégâts physiques infligés aux ennemis que vous avez empoisonnés sont augmentés de 4%.|r", "spellsavagecombat", 770, -184)
-- CreateSpellButton("buttonSpellPreyontheWeak", "Interface/icons/ability_rogue_preyontheweak", "|cffffffffAttaquer les faibles|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Les dégâts de vos coups critiques sont augmentés de 20% quand la cible a moins de points de vie que vous (en pourcentage du total de points de vie).|r", "spellpreyontheweak", 880, -184)
-- CreateSpellButton("buttonSpellKillingSpree", "Interface/icons/ability_rogue_murderspree", "|cffffffffSérie meurtrière|r\n|cffffffffTalent|r |cfffd7e00Combat|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Marche à travers les ombres d'ennemi en ennemi se trouvant à moins de 10 mètres et attaque un ennemi toutes les 0,5 sec.\navec les deux armes jusqu'à ce que 5 assauts aient été effectués.\nAugmente tous les dégâts de 20% pendant ce temps.\nPeut toucher la même cible plusieurs fois.\nNe peut pas toucher les cibles invisibles ou camouflées.|r", "spellkillingspree", 990, -184)


-- Finesse

{
    id = "spellRelentlessStrikes",
    name = "buttonSpellRelentlessStrikes",
    icon = "Interface/icons/ability_warrior_decisivestrike",
    position = {1100, -184},
    handler = "spellrelentlessstrikes",
    tooltips = {
        frFR = "|cffffffffFrappes implacables|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vos coups de grâce ont 20% de chances par point de combo de vous rendre 25 points d'énergie.|r",
        enUS = "|cffffffffRelentless Strikes|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Your finishing moves have a 20% chance per combo point to restore 25 energy.|r"
    }
},
{
    id = "spellMasterofDeception",
    name = "buttonSpellMasterofDeception",
    icon = "Interface/icons/spell_shadow_charm",
    position = {718, -240},
    handler = "spellmasterofdeception",
    tooltips = {
        frFR = "|cffffffffMaître des illusions|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit les chances de vos ennemis de vous détecter lorsque vous êtes en camouflage.\nPlus efficace que Maître des illusions (Rang 2).|r",
        enUS = "|cffffffffMaster of Deception|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Reduces the chances of enemies detecting you while stealthed.\nMore effective than Master of Deception (Rank 2).|r"
    }
},
{
    id = "spellOpportunity",
    name = "buttonSpellOpportunity",
    icon = "Interface/icons/ability_warrior_warcry",
    position = {825, -240},
    handler = "spellopportunity",
    tooltips = {
        frFR = "|cffffffffOpportunité|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente de 20% les dégâts infligés avec vos techniques Attaque sournoise, Estropier, Garrot et Embuscade.|r",
        enUS = "|cffffffffOpportunity|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases the damage of your Sinister Strike, Mutilate, Garrote, and Ambush by 20%.|r"
    }
},
{
    id = "spellSleightofHand",
    name = "buttonSpellSleightofHand",
    icon = "Interface/icons/ability_rogue_feint",
    position = {935, -240},
    handler = "spellsleightofhand",
    tooltips = {
        frFR = "|cffffffffPasse-passe|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit de 2% la probabilité que vous soyez touché par un coup critique infligé par une attaque en mêlée ou à distance,\net augmente la réduction du niveau de menace de votre technique Feinte de 20%.|r",
        enUS = "|cffffffffSleight of Hand|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Reduces the chance to be critically hit by melee or ranged attacks by 2%,\nand increases the threat reduction of your Feint ability by 20%.|r"
    }
},
{
    id = "spellDirtyTricks",
    name = "buttonSpellDirtyTricks",
    icon = "Interface/icons/ability_sap",
    position = {1045, -240},
    handler = "spelldirtytricks",
    tooltips = {
        frFR = "|cffffffffCoup tordu|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente la portée de vos techniques Cécité et Assommer de 5 mètres et réduit leur coût en énergie de 50%.|r",
        enUS = "|cffffffffDirty Tricks|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases the range of your Blind and Sap abilities by 5 yards and reduces their energy cost by 50%.|r"
    }
},
{
    id = "spellCamouflage",
    name = "buttonSpellCamouflage",
    icon = "Interface/icons/ability_stealth",
    position = {663, -293},
    handler = "spellcamouflage",
    tooltips = {
        frFR = "|cffffffffDissimulation|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente de 15% votre vitesse de déplacement lorsque vous êtes camouflé et réduit de 6 sec.\nLe temps de recharge de votre technique Camouflage.|r",
        enUS = "|cffffffffCamouflage|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases your movement speed by 15% while stealthed and reduces the cooldown of your Stealth ability by 6 seconds.|r"
    }
},
{
    id = "spellElusiveness",
    name = "buttonSpellElusiveness",
    icon = "Interface/icons/spell_magic_lesserinvisibilty",
    position = {770, -293},
    handler = "spellelusiveness",
    tooltips = {
        frFR = "|cffffffffInsaisissable|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit le temps de recharge de vos techniques Disparition et Cécité de 60 sec.\net de votre technique Cape d'ombre de 30 sec.|r",
        enUS = "|cffffffffElusiveness|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Reduces the cooldown of your Vanish and Blind abilities by 60 seconds, and your Cloak of Shadows ability by 30 seconds.|r"
    }
},
{
    id = "spellGhostlyStrike",
    name = "buttonSpellGhostlyStrike",
    icon = "Interface/icons/spell_shadow_curse",
    position = {880, -293},
    handler = "spellghostlystrike",
    tooltips = {
        frFR = "|cffffffffFrappe fantomatique|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Une attaque qui inflige 125% des dégâts de l'arme (1.44% si une dague est équipée) et qui augmente vos chances d'esquiver de 15% pendant 7 secondes.\nVous gagnez 1 point de combo.|r",
        enUS = "|cffffffffGhostly Strike|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100An attack that deals 125% weapon damage (1.44% if a dagger is equipped) and increases your dodge chance by 15% for 7 seconds.\nGrants 1 combo point.|r"
    }
},
{
    id = "spellSerratedBlades",
    name = "buttonSpellSerratedBlades",
    icon = "Interface/icons/inv_sword_17",
    position = {990, -293},
    handler = "spellserratedblades",
    tooltips = {
        frFR = "|cffffffffLames dentelées|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vos attaques ignorent jusqu'à 9% de l'Armure de votre cible.\nAugmente les dégâts infligés par votre technique Rupture de 30%.|r",
        enUS = "|cffffffffSerrated Blades|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Your attacks ignore up to 9% of the target's armor.\nIncreases the damage of your Rupture ability by 30%.|r"
    }
},
{
    id = "spellSetup",
    name = "buttonSpellSetup",
    icon = "Interface/icons/spell_nature_mirrorimage",
    position = {1100, -293},
    handler = "spellsetup",
    tooltips = {
        frFR = "|cffffffffPréparatifs|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vous confère 100% de chances d'ajouter un point de combo à votre cible après avoir esquivé son attaque ou entièrement résisté à un de ses sorts.\nNe peut pas se produire plus d'une fois par seconde.|r",
        enUS = "|cffffffffSetup|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Gives you a 100% chance to add a combo point to your target after dodging their attack or fully resisting one of their spells.\nCannot occur more than once per second.|r"
    }
},
{
    id = "spellInitiative",
    name = "buttonSpellInitiative",
    icon = "Interface/icons/spell_shadow_fumble",
    position = {718, -348},
    handler = "spellinitiative",
    tooltips = {
        frFR = "|cffffffffInitiative|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vous confère 100% de chances de gagner un point de combo supplémentaire lorsque vous utilisez les techniques Embuscade, Garrot et Coup bas.|r",
        enUS = "|cffffffffInitiative|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Gives you a 100% chance to gain an additional combo point when using Ambush, Garrote, and Cheap Shot.|r"
    }
},
{
    id = "spellImprovedAmbush",
    name = "buttonSpellImprovedAmbush",
    icon = "Interface/icons/ability_rogue_ambush",
    position = {825, -348},
    handler = "spellimprovedambush",
    tooltips = {
        frFR = "|cffffffffEmbuscade améliorée|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente les chances d'infliger un coup critique avec votre technique Embuscade de 50%.|r",
        enUS = "|cffffffffImproved Ambush|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases your chance to critically strike with Ambush by 50%.|r"
    }
},
{
    id = "spellHeightenedSenses",
    name = "buttonSpellHeightenedSenses",
    icon = "Interface/icons/ability_ambush",
    position = {935, -348},
    handler = "spellheightenedsenses",
    tooltips = {
        frFR = "|cffffffffSens amplifiés|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente votre détection du camouflage et réduit de 4% la probabilité que vous soyez touché par les sorts et les attaques à distance.\nPlus efficace que Sens amplifiés (Rang 1).|r",
        enUS = "|cffffffffHeightened Senses|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases your stealth detection and reduces the chance to be hit by spells and ranged attacks by 4%.\nMore effective than Heightened Senses (Rank 1).|r"
    }
},
{
    id = "spellPreparation",
    name = "buttonSpellPreparation",
    icon = "Interface/icons/spell_shadow_antishadow",
    position = {1045, -348},
    handler = "spellpreparation",
    tooltips = {
        frFR = "|cffffffffPréparation|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Lorsque vous la déclenchez, cette technique met immédiatement fin au temps de recharge de vos techniques Evasion, Sprint, Disparition, Sang froid et Pas de l'ombre.|r",
        enUS = "|cffffffffPreparation|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100When triggered, this ability instantly resets the cooldown of your Evasion, Sprint, Vanish, Cold Blood, and Shadowstep abilities.|r"
    }
},
{
    id = "spellDirtyDeeds",
    name = "buttonSpellDirtyDeeds",
    icon = "Interface/icons/spell_shadow_summonsuccubus",
    position = {663, -402},
    handler = "spelldirtydeeds",
    tooltips = {
        frFR = "|cffffffffCoups fourrés|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit de 20 le coût en énergie de vos techniques Coup bas et Garrot.\nDe plus, vos techniques spéciales infligent 20% de dégâts supplémentaires aux cibles qui possèdent moins de 35% de leurs points de vie.|r",
        enUS = "|cffffffffDirty Deeds|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Reduces the energy cost of your Cheap Shot and Garrote abilities by 20.\nAdditionally, your special abilities deal 20% more damage to targets with less than 35% health.|r"
    }
},
{
    id = "spellHemorrhage",
    name = "buttonSpellHemorrhage",
    icon = "Interface/icons/spell_shadow_lifedrain",
    position = {770, -402},
    handler = "spellhemorrhage",
    tooltips = {
        frFR = "|cffffffffHémorragie|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Une frappe instantanée qui inflige 110% des dégâts de l'arme (160% si une dague est équipée) à l'adversaire et provoque une hémorragie.\nAugmente tous les dégâts physiques infligés à la cible de 13 au maximum.\nUtilisable 10 fois ou pendant 15 secondes.\nVous gagnez 1 point de combo.|r",
        enUS = "|cffffffffHemorrhage|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100An instant strike that deals 110% of your weapon damage (160% if a dagger is equipped) and causes bleeding.\nIncreases all physical damage dealt to the target by up to 13.\nCan be used 10 times or for 15 seconds.\nYou gain 1 combo point.|r"
    }
},
{
    id = "spellMasterofSubtlety",
    name = "buttonSpellMasterofSubtlety",
    icon = "Interface/icons/ability_rogue_masterofsubtlety",
    position = {880, -402},
    handler = "spellmasterofsubtlety",
    tooltips = {
        frFR = "|cffffffffMaître de la discrétion|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Les attaques effectuées alors que vous êtes camouflé et pendant les 6 secondes suivant l'annulation du camouflage infligent 10% de dégâts supplémentaires.|r",
        enUS = "|cffffffffMaster of Subtlety|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Attacks made while stealthed and for 6 seconds after breaking stealth deal 10% additional damage.|r"
    }
},
{
    id = "spellDeadliness",
    name = "buttonSpellDeadliness",
    icon = "Interface/icons/inv_weapon_crossbow_11",
    position = {990, -402},
    handler = "spelldeadliness",
    tooltips = {
        frFR = "|cffffffffMeurtrier|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente votre puissance d'attaque de 10%.|r",
        enUS = "|cffffffffDeadliness|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases your attack power by 10%.|r"
    }
},
{
    id = "spellEnvelopingShadows",
    name = "buttonSpellEnvelopingShadows",
    icon = "Interface/icons/ability_rogue_envelopingshadows",
    position = {1100, -402},
    handler = "spellenvelopingshadows",
    tooltips = {
        frFR = "|cffffffffLinceul d'ombres|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit les dégâts que vous infligent les attaques à zone d'effet de 30%.|r",
        enUS = "|cffffffffEnveloping Shadows|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Reduces damage taken from area-of-effect attacks by 30%.|r"
    }
},
{
    id = "spellPremeditation",
    name = "buttonSpellPremeditation",
    icon = "Interface/icons/spell_shadow_possession",
    position = {718, -456},
    handler = "spellpremeditation",
    tooltips = {
        frFR = "|cffffffffPréméditation|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Lorsqu'elle est utilisée, cette technique ajoute 2 points de combo à la cible.\nVous devez ajouter à ces points de combo ou les utiliser avant 20 secondes sinon les points de combo sont perdus.|r",
        enUS = "|cffffffffPremeditation|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100When used, this ability adds 2 combo points to the target.\nYou must either add to these combo points or use them before 20 seconds, or they will be lost.|r"
    }
},
{
    id = "spellCheatDeath",
    name = "buttonSpellCheatDeath",
    icon = "Interface/icons/ability_rogue_cheatdeath",
    position = {825, -456},
    handler = "spellcheatdeath",
    tooltips = {
        frFR = "|cffffffffTrompe-la-mort|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vous avez 100% de chances qu'une attaque infligeant des dégâts qui devrait normalement vous tuer réduise à 10% votre vie maximale.\nDe plus, réduit tous les dégâts subis jusqu'à 90% pendant 3 secondes (modifié par résilience).\nCet effet ne peut se produire plus d'une fois par minute.|r",
        enUS = "|cffffffffCheat Death|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100You have a 100% chance to reduce your health to 10% when you would normally be killed by a damaging attack.\nAdditionally, reduces all damage taken by 90% for 3 seconds (modified by resilience).\nThis effect can only occur once per minute.|r"
    }
},
{
    id = "spellShadowBlades",
    name = "buttonSpellShadowBlades",
    icon = "Interface/icons/inv_knife_1h_grimbatolraid_d_03",
    position = {825, -560},
    handler = "spellshadowblades",
    tooltips = {
        frFR = "|cffffffffLames de l’ombre|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vous puisez dans les ombres environnantes pour\nrenforcer vos armes, ce qui permet à vos\nattaques d’infliger 20 % de dégâts d’ombre\nsupplémentaires. En outre, vos techniques qui\ngénèrent des points de combo remplissent vos\npoints de combo pendant 16 s.|r",
        enUS = "|cffffffffShadow Blades|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Draws upon surrounding shadows to empower\nyour weapons, causing your attacks to deal 20%\nadditional damage as Shadow and causing your\ncombo point generating abilities to generate full\ncombo points for 16 sec.|r"
    }
},
{
    id = "spellSinisterCalling",
    name = "buttonSpellSinisterCalling",
    icon = "Interface/icons/ability_rogue_sinistercalling",
    position = {935, -456},
    handler = "spellsinistercalling",
    tooltips = {
        frFR = "|cffffffffVocation pernicieuse|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente votre total d'Agilité de 15% et augmente de 10% supplémentaires le bonus aux dégâts d'Attaque sournoise et Hémorragie.|r",
        enUS = "|cffffffffSinister Calling|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Increases your total Agility by 15% and increases the bonus damage for Sinister Strike and Hemorrhage by an additional 10%.|r"
    }
},
{
    id = "spellWaylay",
    name = "buttonSpellWaylay",
    icon = "Interface/icons/ability_rogue_waylay",
    position = {1045, -456},
    handler = "spellwaylay",
    tooltips = {
        frFR = "|cffffffffAssaillir|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vos coups avec Embuscade et Attaque sournoise ont 100% de chances de déséquilibrer la cible,\nce qui augmente le temps entre ses attaques en mêlée et à distance de 20% et réduit sa vitesse de déplacement de 50% pendant 8 secondes.|r",
        enUS = "|cffffffffWaylay|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Your attacks with Ambush and Sinister Strike have a 100% chance to unbalance the target,\nwhich increases the time between their melee and ranged attacks by 20% and reduces their movement speed by 50% for 8 seconds.|r"
    }
},
{
    id = "spellHonorAmongThieves",
    name = "buttonSpellHonorAmongThieves",
    icon = "Interface/icons/ability_rogue_honoramongstthieves",
    position = {663, -510},
    handler = "spellhonoramongthieves",
    tooltips = {
        frFR = "|cffffffffHonneur des voleurs|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Chaque fois qu'un membre de votre groupe réussit un coup critique avec un sort de dégâts ou de soins ou une technique, vous avez 100% de chances de gagner un point de combo sur votre cible actuelle.\nCet effet ne peut se produire plus d'une fois toutes les secondes.|r",
        enUS = "|cffffffffHonor Among Thieves|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Each time a member of your group scores a critical hit with a damage or healing spell or ability, you have a 100% chance to gain a combo point on your current target.\nThis effect can only occur once per second.|r"
    }
},
{
    id = "spellShadowstep",
    name = "buttonSpellShadowstep",
    icon = "Interface/icons/ability_rogue_shadowstep",
    position = {770, -510},
    handler = "spellshadowstep",
    tooltips = {
        frFR = "|cffffffffPas de l'ombre|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vous tentez de marcher à travers les ombres et de réapparaître derrière votre ennemi.\nVotre vitesse de déplacement est augmentée de 70% pendant 3 secondes.\nLes dégâts de votre prochaine technique sont augmentés de 20% et la menace générée est réduite de 50%.\nDure 10 secondes.|r",
        enUS = "|cffffffffShadowstep|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100You attempt to walk through the shadows and reappear behind your enemy.\nYour movement speed is increased by 70% for 3 seconds.\nThe damage of your next ability is increased by 20% and the threat generated is reduced by 50%.\nLasts 10 seconds.|r"
    }
},
{
    id = "spellFilthyTricks",
    name = "buttonSpellFilthyTricks",
    icon = "Interface/icons/ability_rogue_wrongfullyaccused",
    position = {880, -510},
    handler = "spellfilthytricks",
    tooltips = {
        frFR = "|cffffffffTours pendables|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit le temps de recharge de 10 sec. et le coût en énergie de 10 de vos techniques Ficelles du métier,\nDistraction et Pas de l'ombre, et le temps de recharge de votre Préparation de 3 min.|r",
        enUS = "|cffffffffFilthy Tricks|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Reduces the cooldown by 10 seconds and the energy cost by 10 for your tricks like Tricks of the Trade,\nDistract, and Shadowstep, as well as reducing the cooldown of Preparation by 3 minutes.|r"
    }
},
{
    id = "spellSlaughterfromtheShadows",
    name = "buttonSpellSlaughterfromtheShadows",
    icon = "Interface/icons/ability_rogue_slaughterfromtheshadows",
    position = {990, -510},
    handler = "spellslaughterfromtheshadows",
    tooltips = {
        frFR = "|cffffffffOmbres meurtrières|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit de 20 le coût en énergie de vos techniques Attaque sournoise et Embuscade et de 5 le coût en énergie d'Hémorragie.\nAugmente tous les dégâts infligés de 5%.|r",
        enUS = "|cffffffffSlaughter from the Shadows|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Reduces the energy cost of your Sinister Strike and Ambush abilities by 20, and Hemorrhage by 5.\nIncreases all damage dealt by 5%.|r"
    }
},
{
    id = "spellShadowDance",
    name = "buttonSpellShadowDance",
    icon = "Interface/icons/ability_rogue_shadowdance",
    position = {1100, -510},
    handler = "spellshadowdance",
    tooltips = {
        frFR = "|cffffffffDanse de l'ombre|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Entame la Danse de l'ombre, qui dure 6 secondes et permet l'utilisation d'Assommer, Garrot, Embuscade, Coup bas,\nPréméditation, Vol à la tire et Désarmement de piège même sans être camouflé.|r",
        enUS = "|cffffffffShadow Dance|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequires|r |cfffff569Rogue|r\n|cffffd100Begins Shadow Dance, which lasts for 6 seconds and allows the use of abilities like Sap, Garrote, Ambush, Sinister Strike,\nPremeditation, Pickpocket, and Disarm Trap even when not stealthed.|r"
		}
	}
}

-- CreateSpellButton("buttonSpellRelentlessStrikes", "Interface/icons/ability_warrior_decisivestrike", "|cffffffffFrappes implacables|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vos coups de grâce ont 20% de chances par point de combo de vous rendre 25 points d'énergie.|r", "spellrelentlessstrikes", 1100, -184)
-- CreateSpellButton("buttonSpellMasterofDeception", "Interface/icons/spell_shadow_charm", "|cffffffffMaître des illusions|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit les chances de vos ennemis de vous détecter lorsque vous êtes en camouflage.\nPlus efficace que Maître des illusions (Rang 2).|r", "spellmasterofdeception", 718, -240)
-- CreateSpellButton("buttonSpellOpportunity", "Interface/icons/ability_warrior_warcry", "|cffffffffOpportunité|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente de 20% les dégâts infligés avec vos techniques Attaque sournoise, Estropier, Garrot et Embuscade.|r", "spellopportunity", 825, -240)
-- CreateSpellButton("buttonSpellSleightofHand", "Interface/icons/ability_rogue_feint", "|cffffffffPasse-passe|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit de 2% la probabilité que vous soyez touché par un coup critique infligé par une attaque en mêlée ou à distance,\net augmente la réduction du niveau de menace de votre technique Feinte de 20%.|r", "spellsleightofhand", 935, -240)
-- CreateSpellButton("buttonSpellDirtyTricks", "Interface/icons/ability_sap", "|cffffffffCoup tordu|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente la portée de vos techniques Cécité et Assommer de 5 mètres et réduit leur coût en énergie de 50%.|r", "spelldirtytricks", 1045, -240)
-- CreateSpellButton("buttonSpellCamouflage", "Interface/icons/ability_stealth", "|cffffffffDissimulation|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente de 15% votre vitesse de déplacement lorsque vous êtes camouflé et réduit de 6 sec.\nLe temps de recharge de votre technique Camouflage.|r", "spellcamouflage", 663, -293)
-- CreateSpellButton("buttonSpellElusiveness", "Interface/icons/spell_magic_lesserinvisibilty", "|cffffffffInsaisissable|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit le temps de recharge de vos techniques Disparition et Cécité de 60 sec.\net de votre technique Cape d'ombre de 30 sec.|r", "spellelusiveness", 770, -293)
-- CreateSpellButton("buttonSpellGhostlyStrike", "Interface/icons/spell_shadow_curse", "|cffffffffFrappe fantomatique|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Une attaque qui inflige 125% des dégâts de l'arme (1.44% si une dague est équipée) et qui augmente vos chances d'esquiver de 15% pendant 7 seconds.\nVous gagnez 1 point de combo.|r", "spellghostlystrike", 880, -293)
-- CreateSpellButton("buttonSpellSerratedBlades", "Interface/icons/inv_sword_17", "|cffffffffLames dentelées|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vos attaques ignorent jusqu'à 9% de l'Armure de votre cible.\nAugmente les dégâts infligés par votre technique Rupture de 30%.|r", "spellserratedblades", 990, -293)
-- CreateSpellButton("buttonSpellSetup", "Interface/icons/spell_nature_mirrorimage", "|cffffffffPréparatifs|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vous confère 100% de chances d'ajouter un point de combo à votre cible après avoir esquivé son attaque ou entièrement résisté à un de ses sorts.\nNe peut pas se produire plus d'une fois par seconde.|r", "spellsetup", 1100, -293)
-- CreateSpellButton("buttonSpellInitiative", "Interface/icons/spell_shadow_fumble", "|cffffffffInitiative|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vous confère 100% de chances de gagner un point de combo supplémentaire lorsque vous utilisez les techniques Embuscade, Garrot et Coup bas.|r", "spellinitiative", 718, -348)
-- CreateSpellButton("buttonSpellImprovedAmbush", "Interface/icons/ability_rogue_ambush", "|cffffffffEmbuscade améliorée|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente les chances d'infliger un coup critique avec votre technique Embuscade de 50%.|r", "spellimprovedambush", 825, -348)
-- CreateSpellButton("buttonSpellHeightenedSenses", "Interface/icons/ability_ambush", "|cffffffffSens amplifiés|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente votre détection du camouflage et réduit de 4% la probabilité que vous soyez touché par les sorts et les attaques à distance.\nPlus efficace que Sens amplifiés (Rang 1).|r", "spellheightenedsenses", 935, -348)
-- CreateSpellButton("buttonSpellPreparation", "Interface/icons/spell_shadow_antishadow", "|cffffffffPréparation|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Lorsque vous la déclenchez, cette technique met immédiatement fin au temps de recharge de vos techniques Evasion, Sprint, Disparition, Sang froid et Pas de l'ombre.|r", "spellpreparation", 1045, -348)
-- CreateSpellButton("buttonSpellDirtyDeeds", "Interface/icons/spell_shadow_summonsuccubus", "|cffffffffCoups fourrés|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit de 20 le coût en énergie de vos techniques Coup bas et Garrot.\nDe plus, vos techniques spéciales infligent 20% de dégâts supplémentaires aux cibles qui possèdent moins de 35% de leurs points de vie.|r", "spelldirtydeeds", 663, -402)
-- CreateSpellButton("buttonSpellHemorrhage", "Interface/icons/spell_shadow_lifedrain", "|cffffffffHémorragie|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Une frappe instantanée qui inflige 110% des dégâts de l'arme (160% si une dague est équipée) à l'adversaire et provoque une hémorragie.\nAugmente tous les dégâts physiques infligés à la cible de 13 au maximum.\nUtilisable 10 fois ou pendant 15 seconds.\nVous gagnez 1 point de combo.|r", "spellhemorrhage", 770, -402)
-- CreateSpellButton("buttonSpellMasterofSubtlety", "Interface/icons/ability_rogue_masterofsubtlety", "|cffffffffMaître de la discrétion|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Les attaques effectuées alors que vous êtes camouflé et pendant les 6 secondes suivant l'annulation du camouflage infligent 10% de dégâts supplémentaires.|r", "spellmasterofsubtlety", 880, -402)
-- CreateSpellButton("buttonSpellDeadliness", "Interface/icons/inv_weapon_crossbow_11", "|cffffffffMeurtrier|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente votre puissance d'attaque de 10%.|r", "spelldeadliness", 990, -402)
-- CreateSpellButton("buttonSpellEnvelopingShadows", "Interface/icons/ability_rogue_envelopingshadows", "|cffffffffLinceul d'ombres|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit les dégâts que vous infligent les attaques à zone d'effet de 30%.|r", "spellenvelopingshadows", 1100, -402)
-- CreateSpellButton("buttonSpellPremeditation", "Interface/icons/spell_shadow_possession", "|cffffffffPréméditation|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Lorsqu'elle est utilisée, cette technique ajoute 2 points de combo à la cible.\nVous devez ajouter à ces points de combo ou les utiliser avant 20 seconds sinon les points de combo sont perdus.|r", "spellpremeditation", 718, -456)
-- CreateSpellButton("buttonSpellCheatDeath", "Interface/icons/ability_rogue_cheatdeath", "|cffffffffTrompe-la-mort|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vous avez 100% de chances qu'une attaque infligeant des dégâts qui devrait normalement vous tuer réduise à 10% votre vie maximale.\nDe plus, réduit tous les dégâts subis jusqu'à 90% pendant 3 seconds (modifié par résilience).\nCet effet ne peut se produire plus d'une fois par minute.|r", "spellcheatdeath", 825, -456)
-- CreateSpellButton("buttonSpellSinisterCalling", "Interface/icons/ability_rogue_sinistercalling", "|cffffffffVocation pernicieuse|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Augmente votre total d'Agilité de 15% et augmente de 10% supplémentaires le bonus aux dégâts d'Attaque sournoise et Hémorragie.|r", "spellsinistercalling", 935, -456)
-- CreateSpellButton("buttonSpellWaylay", "Interface/icons/ability_rogue_waylay", "|cffffffffAssaillir|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vos coups avec Embuscade et Attaque sournoise ont 100% de chances de déséquilibrer la cible,\nce qui augmente le temps entre ses attaques en mêlée et à distance de 20% et réduit sa vitesse de déplacement de 50% pendant 8 seconds.|r", "spellwaylay", 1045, -456)
-- CreateSpellButton("buttonSpellHonorAmongThieves", "Interface/icons/ability_rogue_honoramongstthieves", "|cffffffffHonneur des voleurs|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Chaque fois qu'un membre de votre groupe réussit un coup critique avec un sort de dégâts ou de soins ou une technique, vous avez 100% de chances de gagner un point de combo sur votre cible actuelle.\nCet effet ne peut se produire plus d'une fois toutes les secondes.|r", "spellhonoramongthieves", 663, -510)
-- CreateSpellButton("buttonSpellShadowstep", "Interface/icons/ability_rogue_shadowstep", "|cffffffffPas de l'ombre|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Vous tentez de marcher à travers les ombres et de réapparaître derrière votre ennemi.\nVotre vitesse de déplacement est augmentée de 70% pendant 3 seconds.\nLes dégâts de votre prochaine technique sont augmentés de 20% et la menace générée est réduite de 50%.\nDure 10 seconds.|r", "spellshadowstep", 770, -510)
-- CreateSpellButton("buttonSpellFilthyTricks", "Interface/icons/ability_rogue_wrongfullyaccused", "|cffffffffTours pendables|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit le temps de recharge de 10 sec. et le coût en énergie de 10 de vos techniques Ficelles du métier,\nDistraction et Pas de l'ombre, et le temps de recharge de votre Préparation de 3 min.|r", "spellfilthytricks", 880, -510)
-- CreateSpellButton("buttonSpellSlaughterfromtheShadows", "Interface/icons/ability_rogue_slaughterfromtheshadows", "|cffffffffOmbres meurtrières|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Réduit de 20 le coût en énergie de vos techniques Attaque sournoise et Embuscade et de 5 le coût en énergie d'Hémorragie.\nAugmente tous les dégâts infligés de 5%.|r", "spellslaughterfromtheshadows", 990, -510)
-- CreateSpellButton("buttonSpellShadowDance", "Interface/icons/ability_rogue_shadowdance", "|cffffffffDanse de l'ombre|r\n|cffffffffTalent|r |cffffff00Finesse|r\n|cffffffffRequiert|r |cfffff569Voleur|r\n|cffffd100Entame la Danse de l'ombre, qui dure 6 seconds. et permet l'utilisation d'Assommer, Garrot, Embuscade, Coup bas,\nPréméditation, Vol à la tire et Désarmement de piège même sans être camouflé.|r", "spellshadowdance", 1100, -510)

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

-- Créez le bouton Save à l'intérieur de la fenêtre frameTalentRogue
local saveButton = CreateFrame("Button", "saveButton", frameTalentRogue, "UIPanelButtonTemplate")
saveButton:SetSize(85, 25)
saveButton:SetPoint("BOTTOMRIGHT", buttonTalentRogueClose, "BOTTOMLEFT", -185, 5) -- Place le bouton Save à gauche du bouton Close
saveButton:SetText(saveButtonText)

-- Fonction qui prend un screenshot quand le bouton est cliqué
saveButton:SetScript("OnClick", function()
    Screenshot()  -- Prendre un screenshot et l'enregistrer dans le dossier Screenshots du jeu
    print(screenshotMessage)  -- Affiche un message de confirmation en fonction de la locale
end)

-- Affiche l'UI des talents
--frameTalentRogue:Show()

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

-- Créez le bouton Reset à l'intérieur de la fenêtre frameTalentRogue
local buttonReset = CreateFrame("Button", "buttonReset", frameTalentRogue, "UIPanelButtonTemplate")
buttonReset:SetSize(85, 25)
buttonReset:SetPoint("BOTTOMRIGHT", buttonTalentRogueClose, "BOTTOMLEFT", -95, 5) -- Place le bouton Reset à gauche du bouton Reload
buttonReset:SetText(buttonResetText)

local function ResetTalents()
    -- Ajoutez ici la logique pour réinitialiser les talents du joueur
    AIO.Handle("TalentRoguespell", "ResetTalents")
    resetButtonClicked = true -- Marquez le bouton Réinitialiser comme cliqué
end

buttonReset:SetScript("OnClick", ResetTalents)

-- Créez le bouton Reload à l'intérieur de la fenêtre frameTalentRogue
local buttonReload = CreateFrame("Button", "buttonReload", frameTalentRogue, "UIPanelButtonTemplate")
buttonReload:SetSize(85, 25)
buttonReload:SetPoint("BOTTOMRIGHT", buttonTalentRogueClose, "BOTTOMLEFT", -5, 5) -- Place le bouton Reload à gauche du bouton Close
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
        frameTalentRogue:Hide()
        buttonReload:Hide()
        PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
    else
        frameTalentRogue:Show()
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
        frFR = "|cffffffffTalents|r |cfffff569(Voleur)|r\n\nL'éventail des talents disponibles\npour améliorer et spécialiser\nvotre personnage.",
        enUS = "|cffffffffTalents|r |cfffff569(Rogue)|r\n\nThe range of available talents\nfor enhancing and specializing\nyour character."
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

-- Vérifier si le joueur est un Rogue avant de créer le bouton
local playerClass = select(2, UnitClass("player")) -- Obtenir la classe du joueur
if playerClass == "ROGUE" then
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
RogueHandlers.UpdateTalentCount = function(player, talentsAppris)
    if fontTalentRogueFrameText then
        fontTalentRogueFrameText:SetText(talentsAppris .. " / " .. MAX_TALENTS)
    end
end

-- Mise à jour des points de talent utilisés avec texte localisé
RogueHandlers.UpdateTalentPointsUsed = function(player, pointsUsed, pointsBeforeReset)
    -- Utilisation du texte localisé pour les points avant réinitialisation
    print(string.format(GetLocalizedPointsBeforeResetText(), pointsBeforeReset))
end

-- Affichage des talents restants (items 338404 dans le sac)
RogueHandlers.UpdateTalentItemCount = function(player, count)
    if fontTalentPointsRemainingText then
        fontTalentPointsRemainingText:SetText("|cFFFFF569Talents restants : " .. count .. "|r")
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
        fontTalentPointsRemainingText:SetText("|cFFFFF569Talents restants : " .. (count or 0) .. "|r")
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
if playerClass == "ROGUE" then
    -- Surcharge OnHide pour synchroniser talentsWindowOpen quand Échap est pressé
    local _originalOnHide = frameTalentRogue:GetScript("OnHide")
    frameTalentRogue:SetScript("OnHide", function(self)
        talentsWindowOpen = false
        if _originalOnHide then _originalOnHide(self) end
    end)
    -- WoW appelle automatiquement Hide() sur les frames listées ici quand Échap est pressé
    tinsert(UISpecialFrames, "frameTalentRogue")
end