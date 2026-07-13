local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local WarriorHandlers = AIO.AddHandlers("TalentWarriorspell", {})

function WarriorHandlers.ShowTalentWarrior(player)
    frameTalentWarrior:Show()
    -- Redemande au serveur l’état visuel au cas où
    AIO.Handle("TalentWarriorspell", "RequestLearnedTalents")
	-- Redemande le nombre de talents restants
    AIO.Handle("TalentWarriorspell", "GetTalentItemCount")
end

local MAX_TALENTS = 60 -- Définition du nombre maximal de talents que le joueur peut apprendre

local OPEN_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_final_trait_unlocked.ogg"
local CLOSE_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_72_artifact_forge_trait_refund_end.ogg"
local SPELL_TALENT_WINDOW_SOUND = "Sound\\TalentsSystem\\ui_80_azeritearmor_rotationends_02.ogg"

-- Attribute window
local frameTalentWarrior = CreateFrame("Frame", "frameTalentWarrior", UIParent)
frameTalentWarrior:SetSize(1200, 650)
frameTalentWarrior:SetMovable(true)
frameTalentWarrior:EnableMouse(true)
frameTalentWarrior:RegisterForDrag("LeftButton")
frameTalentWarrior:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 50, -50) -- Adjust the X and Y coordinates
frameTalentWarrior:SetBackdrop(
{
    -- bgFile = "interface/TalentFrame/talentsclassbackgroundWarrior", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    bgFile = "interface/TalentFrame/Template/Class/Warrior/talentsclassbackgroundwarrior", --Interface/AchievementFrame/UI-Achievement-Parchment-Horizontal
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedwarrior", --Interface/DialogFrame/UI-DialogBox-Border
    edgeSize = 20,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})

-- Ajoutez la texture de l'icône du Guerrier
local warriorIcon = frameTalentWarrior:CreateTexture("WarriorIcon", "OVERLAY")
warriorIcon:SetTexture("Interface\\TalentFrame\\Template\\Class\\Warrior\\IconeWarrior.blp")
warriorIcon:SetSize(60, 60)
warriorIcon:SetPoint("TOPLEFT", frameTalentWarrior, "TOPLEFT", -10, 10)

-- Template Talent Frame

-- Ajoute une textureone pour l'image BLP
local textureone = frameTalentWarrior:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
textureone:SetTexture("Interface\\TalentFrame\\Template\\Class\\Warrior\\TalentFrameTemplate.blp")
textureone:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
textureone:SetPoint("TOPLEFT", frameTalentWarrior, "TOPLEFT", -170, 140) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentWarrior:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Ajoute une texturetwo pour l'image BLP
local texturetwo = frameTalentWarrior:CreateTexture("TemplateTalentFrame", "OVERLAY") -- Utilisez "OVERLAY" pour être au-dessus des autres éléments
texturetwo:SetTexture("Interface\\TalentFrame\\Template\\Class\\Warrior\\TalentFrameTemplateOriginal.blp")
texturetwo:SetSize(928, 928) -- Remplacez width et height par les dimensions souhaitées
texturetwo:SetPoint("TOPRIGHT", frameTalentWarrior, "TOPRIGHT", 170, 140) -- Adjust the X and Y coordinates

-- Ajuste l'ordre des calques pour être devant les autres éléments
frameTalentWarrior:SetFrameLevel(100) -- Utilisez une valeur supérieure à celle des autres éléments

-- Drag & Drop
frameTalentWarrior:SetScript("OnDragStart", frameTalentWarrior.StartMoving)
frameTalentWarrior:SetScript("OnHide", frameTalentWarrior.StopMovingOrSizing)
frameTalentWarrior:SetScript("OnDragStop", frameTalentWarrior.StopMovingOrSizing)
frameTalentWarrior:Hide()

-- Nouveau template d'arête
frameTalentWarrior:SetBackdropBorderColor(199, 156, 110) -- Couleur marron

-- Close button
local buttonTalentWarriorClose = CreateFrame("Button", "buttonTalentWarriorClose", frameTalentWarrior, "UIPanelCloseButton")
buttonTalentWarriorClose:SetPoint("TOPRIGHT", -12, -12)
buttonTalentWarriorClose:EnableMouse(true)
buttonTalentWarriorClose:SetSize(32, 32)

local function CloseTalentWindow()
    frameTalentWarrior:Hide()
    PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
end

-- Associez la fonction de fermeture au bouton de fermeture
buttonTalentWarriorClose:SetScript("OnClick", CloseTalentWindow)

-- Title bar
local frameTalentWarriorTitleBar = CreateFrame("Frame", "frameTalentWarriorTitleBar", frameTalentWarrior, nil)
frameTalentWarriorTitleBar:SetSize(135, 25)
frameTalentWarriorTitleBar:SetBackdrop(
{
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedwarrior",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentWarriorTitleBar:SetPoint("TOP", 0, 20)

local fontTalentWarriorTitleText = frameTalentWarriorTitleBar:CreateFontString("fontTalentWarriorTitleText")
fontTalentWarriorTitleText:SetFont("Fonts\\FRIZQT__.TTF", 13)
fontTalentWarriorTitleText:SetSize(190, 5)
fontTalentWarriorTitleText:SetPoint("CENTER", 0, 0)
fontTalentWarriorTitleText:SetText("|cffFFC125Talents|r")

-- Détecte la langue du client
local locale = GetLocale() -- Retourne "enUS", "frFR", etc.

-- Table des traductions
local localizedTexts = {
    enUS = "|cffFFC125Warrior|r",
    frFR = "|cffFFC125Guerrier|r",
}

-- Récupère le texte correspondant à la langue actuelle ou par défaut en anglais
local textToDisplay = localizedTexts[locale] or localizedTexts["enUS"]

local fontTalentWarriorFrameText = frameTalentWarriorTitleBar:CreateFontString("fontTalentWarriorFrameText")
fontTalentWarriorFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentWarriorFrameText:SetSize(200, 5)
fontTalentWarriorFrameText:SetPoint("TOPLEFT", frameTalentWarriorTitleBar, "BOTTOMLEFT", -30, -35) -- Adjust the Y offset as needed
fontTalentWarriorFrameText:SetText(textToDisplay)

-- Remplacez votre ligne existante pour la création du texte par celle-ci
local fontTalentWarriorFrameText = frameTalentWarriorTitleBar:CreateFontString("fontTalentWarriorFrameText")
fontTalentWarriorFrameText:SetFont("Fonts\\FRIZQT__.TTF", 18)
fontTalentWarriorFrameText:SetSize(200, 5)
fontTalentWarriorFrameText:SetPoint("TOPLEFT", frameTalentWarriorTitleBar, "BOTTOMLEFT", -30, -60) -- Adjust the Y offset as needed
fontTalentWarriorFrameText:SetText("0 / " .. MAX_TALENTS) -- Initialisez le texte avec 0 talents appris

-------------------------------------------------------------
-- Affichage "Talents restants" (item 338404 dans le sac)
-------------------------------------------------------------

local frameTalentPointsRemaining = CreateFrame("Frame", "frameTalentPointsRemaining", frameTalentWarrior, nil)
frameTalentPointsRemaining:SetSize(220, 30)
frameTalentPointsRemaining:SetBackdrop({
    bgFile = "interface/corrupteditems/corruptedtooltipbackground",
    edgeFile = "interface/tooltips/ui-tooltip-border-corruptedwarrior",
    tile = true,
    edgeSize = 16,
    tileSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
frameTalentPointsRemaining:SetPoint("BOTTOMRIGHT", frameTalentWarrior, "BOTTOMRIGHT", -960, 10)

local fontTalentPointsRemainingText = frameTalentPointsRemaining:CreateFontString("fontTalentPointsRemainingText")
fontTalentPointsRemainingText:SetFont("Fonts\\FRIZQT__.TTF", 14)
fontTalentPointsRemainingText:SetSize(210, 20)
fontTalentPointsRemainingText:SetPoint("CENTER", 0, 0)
fontTalentPointsRemainingText:SetText("|cFFC79C6ETalents restants : 0|r")
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
WarriorHandlers.UpdateLearnedTalents = function(player, learnedSpells)
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

    local button = CreateFrame("Button", name, frameTalentWarrior, nil)
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
                AIO.Handle("TalentWarriorspell", talentHandler, 1)
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

-- Armes

-- Table des sorts
local spells = {
{
    id = "spellImprovedHeroicStrike",
    name = "buttonSpellImprovedHeroicStrike",
    icon = "Interface/icons/spell_magic_magearmor",
    position = {100, -80},
    handler = "spellimprovedheroicstrike",
    tooltips = {
        frFR = "|cffffffffFrappe héroïque améliorée|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit le coût en rage de votre technique Frappe héroïque de 3 points.|r",
        enUS = "|cffffffffImproved Heroic Strike|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Reduces the rage cost of your Heroic Strike ability by 3 points.|r"
    }
},
{
    id = "spellDeflection",
    name = "buttonSpellDeflection",
    icon = "Interface/icons/ability_parry",
    position = {205, -75},
    handler = "spelldeflection",
    tooltips = {
        frFR = "|cffffffffDéviation|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente vos chances de Parer de 5%.|r",
        enUS = "|cffffffffDeflection|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases your chance to Parry by 5%.|r"
    }
},
{
    id = "spellImprovedRend",
    name = "buttonSpellImprovedRend",
    icon = "Interface/icons/ability_gouge",
    position = {315, -75},
    handler = "spellimprovedrend",
    tooltips = {
        frFR = "|cffffffffPourfendre amélioré|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente de 20% les dégâts de saignement infligés par votre technique Pourfendre.|r",
        enUS = "|cffffffffImproved Rend|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases the bleed damage dealt by your Rend ability by 20%.|r"
    }
},
{
    id = "spellImprovedCharge",
    name = "buttonSpellImprovedCharge",
    icon = "Interface/icons/ability_warrior_charge",
    position = {418, -80},
    handler = "spellimprovedcharge",
    tooltips = {
        frFR = "|cffffffffCharge améliorée|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente la quantité de Rage générée par votre technique Charge de 10.|r",
        enUS = "|cffffffffImproved Charge|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases the amount of Rage generated by your Charge ability by 10.|r"
    }
},
{
    id = "spellIronWill",
    name = "buttonSpellIronWill",
    icon = "Interface/icons/spell_magic_magearmor",
    position = {45, -130},
    handler = "spellironwill",
    tooltips = {
        frFR = "|cffffffffVolonté de fer|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit de 20% la durée de tous les effets d'étourdissement et de charme utilisés contre vous.|r",
        enUS = "|cffffffffIron Will|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Reduces the duration of all Stun and Charm effects used against you by 20%.|r"
    }
},
{
    id = "spellTacticalMastery",
    name = "buttonSpellTacticalMastery",
    icon = "Interface/icons/spell_nature_enchantarmor",
    position = {150, -130},
    handler = "spelltacticalmastery",
    tooltips = {
        frFR = "|cffffffffMaîtrise tactique|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vous conservez jusqu'à 15 points de rage supplémentaires lorsque vous changez de posture.\nAugmente aussi considérablement la menace générée par vos techniques Sanguinaire et Frappe mortelle quand vous êtes en posture défensive (Plus efficace que le Rang 2).|r",
        enUS = "|cffffffffTactical Mastery|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100You retain up to 15 additional rage points when switching stances.\nAlso significantly increases the threat generated by your Bloodthirst and Mortal Strike abilities when in Defensive Stance (More effective than Rank 2).|r"
    }
},
{
    id = "spellImprovedOverpower",
    name = "buttonSpellImprovedOverpower",
    icon = "Interface/icons/inv_sword_05",
    position = {260, -130},
    handler = "spellimprovedoverpower",
    tooltips = {
        frFR = "|cffffffffFulgurance améliorée|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente de 50% vos chances d'infliger un coup critique avec la technique Fulgurance.|r",
        enUS = "|cffffffffImproved Overpower|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases your critical strike chance with the Overpower ability by 50%.|r"
    }
},
{
    id = "spellAngerManagement",
    name = "buttonSpellAngerManagement",
    icon = "Interface/icons/spell_holy_blessingofstamina",
    position = {370, -130},
    handler = "spellangermanagement",
    tooltips = {
        frFR = "|cffffffffMaîtrise de la Rage|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Génère 1 point de rage toutes les 3 secondes.|r",
        enUS = "|cffffffffAnger Management|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Generates 1 rage point every 3 seconds.|r"
    }
},
{
    id = "spellImpale",
    name = "buttonSpellImpale",
    icon = "Interface/icons/ability_searingarrow",
    position = {475, -133},
    handler = "spellimpale",
    tooltips = {
        frFR = "|cffffffffEmpaler|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente de 20% le bonus aux dégâts des coups critiques réussis avec vos techniques.|r",
        enUS = "|cffffffffImpale|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases the critical strike damage bonus of your abilities by 20%.|r"
    }
},
{
    id = "spellDeepWounds",
    name = "buttonSpellDeepWounds",
    icon = "Interface/icons/ability_backstab",
    position = {96, -185},
    handler = "spelldeepwounds",
    tooltips = {
        frFR = "|cffffffffBlessures profondes|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vos coups critiques font saigner l'adversaire et lui infligent 48% des points de dégâts moyens de votre arme de mêlée en 6 secondes.|r",
        enUS = "|cffffffffDeep Wounds|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Your critical strikes cause the opponent to bleed, dealing 48% of your melee weapon's average damage over 6 seconds.|r"
    }
},
{
    id = "spellTwoHandedWeaponSpecialization",
    name = "buttonSpellTwoHandedWeaponSpecialization",
    icon = "Interface/icons/inv_axe_09",
    position = {205, -185},
    handler = "spelltwohandedweaponspecialization",
    tooltips = {
        frFR = "|cffffffffSpécialisation Arme 2M|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente les points de dégâts que vous infligez avec les armes de mêlée à deux mains de 6%.|r",
        enUS = "|cffffffffTwo-Handed Weapon Specialization|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases the damage you deal with two-handed melee weapons by 6%.|r"
    }
},
{
    id = "spellTasteforBlood",
    name = "buttonSpellTasteforBlood",
    icon = "Interface/icons/ability_rogue_hungerforblood",
    position = {315, -185},
    handler = "spelltasteforblood",
    tooltips = {
        frFR = "|cffffffffGoût du sang|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Chaque fois que votre technique Pourfendre inflige des dégâts, vous avez 100% de chances de permettre l'utilisation de votre technique Fulgurance pendant 9 secondes.\n1 charge.\nCet effet ne peut se produire plus d'une fois toutes les 6 sec.|r",
        enUS = "|cffffffffTaste for Blood|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Each time your Rend ability deals damage, you have a 100% chance to enable the use of your Overpower ability for 9 seconds.\n1 charge.\nThis effect cannot occur more than once every 6 seconds.|r"
    }
},
{
    id = "spellPoleaxeSpecialization",
    name = "buttonSpellPoleaxeSpecialization",
    icon = "Interface/icons/inv_axe_06",
    position = {422, -185},
    handler = "spellpoleaxespecialization",
    tooltips = {
        frFR = "|cffffffffSpécialisation Hache d'hast|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente de 5% vos chances d'infliger un coup critique avec les haches et les armes d'hast ainsi que les dégâts de ces critiques.|r",
        enUS = "|cffffffffPoleaxe Specialization|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases your critical strike chance with axes and polearms by 5% and the damage of those critical strikes.|r"
    }
},
{
    id = "spellSweepingStrikes",
    name = "buttonSpellSweepingStrikes",
    icon = "Interface/icons/ability_rogue_slicedice",
    position = {527, -190},
    handler = "spellsweepingstrikes",
    tooltips = {
        frFR = "|cffffffffAttaques circulaires|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vos 5 prochaines attaques de mêlée frappent un adversaire proche supplémentaire.|r",
        enUS = "|cffffffffSweeping Strikes|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Your next 5 melee attacks strike an additional nearby opponent.|r"
    }
},
{
    id = "spellMaceSpecialization",
    name = "buttonSpellMaceSpecialization",
    icon = "Interface/icons/inv_mace_01",
    position = {43, -240},
    handler = "spellmacespecialization",
    tooltips = {
        frFR = "|cffffffffSpécialisation Masse|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vos attaques avec les masses ignorent jusqu'à 15% de l'armure de votre adversaire.|r",
        enUS = "|cffffffffMace Specialization|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Your attacks with maces ignore up to 15% of your opponent's armor.|r"
    }
},
{
    id = "spellSwordSpecialization",
    name = "buttonSpellSwordSpecialization",
    icon = "Interface/icons/inv_sword_27",
    position = {150, -240},
    handler = "spellswordspecialization",
    tooltips = {
        frFR = "|cffffffffSpécialisation Epée|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vous confère 10% de chances de bénéficier d'une attaque supplémentaire sur la même cible après avoir infligé des dégâts avec votre épée.\nCet effet ne survient pas plus d'une fois toutes les 6 secondes.|r",
        enUS = "|cffffffffSword Specialization|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Grants a 10% chance of an extra attack on the same target after dealing damage with your sword.\nThis effect cannot occur more than once every 6 seconds.|r"
    }
},
{
    id = "spellWeaponMastery",
    name = "buttonSpellWeaponMastery",
    icon = "Interface/icons/ability_warrior_weaponmastery",
    position = {368, -240},
    handler = "spellweaponmastery",
    tooltips = {
        frFR = "|cffffffffMaîtrise des armes|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit la probabilité que vos attaques soient esquivées de 2% et réduit la durée de tous les effets de désarmement utilisés contre vous de 50%.\nNon cumulable avec les autres effets qui réduisent la durée du désarmement.|r",
        enUS = "|cffffffffWeapon Mastery|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Reduces the chance your attacks are dodged by 2% and reduces the duration of all disarm effects used against you by 50%.\nDoes not stack with other disarm duration reduction effects.|r"
    }
},
{
    id = "spellImprovedHamstring",
    name = "buttonSpellImprovedHamstring",
    icon = "Interface/icons/ability_shockwave",
    position = {478, -240},
    handler = "spellimprovedhamstring",
    tooltips = {
        frFR = "|cffffffffBrise-genou amélioré|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Confère à votre technique Brise-genou 15% de chances d'immobiliser votre cible pendant 5 secondes.|r",
        enUS = "|cffffffffImproved Hamstring|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Gives your Hamstring ability a 15% chance to immobilize the target for 5 seconds.|r"
    }
},
{
    id = "spellTrauma",
    name = "buttonSpellTrauma",
    icon = "Interface/icons/ability_warrior_bloodnova",
    position = {98, -293},
    handler = "spelltrauma",
    tooltips = {
        frFR = "|cffffffffTraumatisme|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vos coups critiques normaux en mêlée augmentent l'efficacité des effets de saignement sur la cible de 30% pendant 1 mn.|r",
        enUS = "|cffffffffTrauma|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Your normal melee critical strikes increase the effectiveness of bleed effects on the target by 30% for 1 minute.|r"
    }
},
{
    id = "spellSecondWind",
    name = "buttonSpellSecondWind",
    icon = "Interface/icons/ability_hunter_harass",
    position = {205, -293},
    handler = "spellsecondwind",
    tooltips = {
        frFR = "|cffffffffSecond souffle|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Chaque fois que vous êtes atteint par un effet d'étourdissement ou d'immobilisation, vous gagnez 20 points de rage et 10% de votre total de points de vie en 10 secondes.|r",
        enUS = "|cffffffffSecond Wind|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Whenever you are struck by a stun or immobilize effect, you gain 20 rage and 10% of your total health over 10 seconds.|r"
    }
},
{
    id = "spellMortalStrike",
    name = "buttonSpellMortalStrike",
    icon = "Interface/icons/ability_warrior_savageblow",
    position = {315, -293},
    handler = "spellmortalstrike",
    tooltips = {
        frFR = "|cffffffffFrappe mortelle|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Une attaque vicieuse qui inflige les dégâts de l'arme plus 85 et blesse la cible.\nL'effet des sorts de soins dont elle est la cible est réduit de 50% pendant 10 secondes.|r",
        enUS = "|cffffffffMortal Strike|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100A vicious strike that deals weapon damage plus 85 and wounds the target.\nReduces the effectiveness of healing spells on the target by 50% for 10 seconds.|r"
    }
},
{
    id = "spellStrengthofArms",
    name = "buttonSpellStrengthofArms",
    icon = "Interface/icons/ability_warrior_offensivestance",
    position = {422, -293},
    handler = "spellstrengthofarms",
    tooltips = {
        frFR = "|cffffffffForce des armes|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente votre total de Force et d'Endurance de 4% et votre expertise de 4.|r",
        enUS = "|cffffffffStrength of Arms|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases your total Strength and Stamina by 4% and your Expertise by 4.|r"
    }
},
{
    id = "spellImprovedSlam",
    name = "buttonSpellImprovedSlam",
    icon = "Interface/icons/ability_warrior_decisivestrike",
    position = {527, -295},
    handler = "spellimprovedslam",
    tooltips = {
        frFR = "|cffffffffHeurtoir amélioré|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit le temps de frappe de votre technique Heurtoir de 1 sec.|r",
        enUS = "|cffffffffImproved Slam|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Reduces the cast time of your Slam ability by 1 sec.|r"
    }
},
{
    id = "spellJuggernaut",
    name = "buttonSpellJuggernaut",
    icon = "Interface/icons/ability_warrior_bullrush",
    position = {43, -350},
    handler = "spellunrelentingassault",
    tooltips = {
        frFR = "|cffffffffMastodonte|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Votre technique Charge est à présent utilisable en combat, mais son temps de recharge est augmenté de 5 sec.\nAprès une Charge, votre prochaine technique Heurtoir ou Frappe mortelle bénéficie de 25% de chances supplémentaires d'être critique si elle est utilisée dans les 10 secondes.|r",
        enUS = "|cffffffffJuggernaut|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Your Charge ability is now usable in combat, but its cooldown is increased by 5 sec.\nAfter a Charge, your next Slam or Mortal Strike has a 25% increased chance to critically strike if used within 10 seconds.|r"
    }
},
{
    id = "spellImprovedMortalStrike",
    name = "buttonSpellImprovedMortalStrike",
    icon = "Interface/icons/ability_warrior_savageblow",
    position = {150, -350},
    handler = "spellimprovedmortalstrike",
    tooltips = {
        frFR = "|cffffffffFrappe mortelle améliorée|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente les dégâts infligés par votre technique Frappe mortelle de 10% et réduit le temps de recharge de 1 sec.|r",
        enUS = "|cffffffffImproved Mortal Strike|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases the damage of your Mortal Strike ability by 10% and reduces its cooldown by 1 sec.|r"
    }
},
{
    id = "spellUnrelentingAssault",
    name = "buttonSpellUnrelentingAssault",
    icon = "Interface/icons/ability_warrior_unrelentingassault",
    position = {260, -350},
    handler = "spellgrace",
    tooltips = {
        frFR = "|cffffffffAssaut continuel|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit le temps de recharge de vos techniques Fulgurance et Vengeance de 4 secondes et augmente les dégâts infligés par ces deux techniques de 20%.\nDe plus, si vous frappez un personnage-joueur avec Fulgurance alors qu'il est en train d'incanter un sort, ses dégâts et soins magiques sont réduits de 50% pendant 6 secondes.|r",
        enUS = "|cffffffffUnrelenting Assault|r\n|cffffffffTalent|r |cffc0c0c0Arms|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Reduces the cooldown of your Overpower and Revenge abilities by 4 seconds and increases the damage of both abilities by 20%.\nAdditionally, if you hit a player character with Overpower while they are casting a spell, their magical damage and healing is reduced by 50% for 6 seconds.|r"
    }
},
{
    id = "spellSuddenDeath",
    name = "buttonSpellSuddenDeath",
    icon = "Interface/icons/ability_warrior_improveddisciplines",
    position = {368, -350},
    handler = "spellsuddendeath",
    tooltips = {
        frFR = "|cffffffffMort soudaine|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vos coups en mêlée ont 9% de chances de permettre l'utilisation d'Exécution quel que soit le montant de points de vie restant à la cible.\nDe plus, vous conservez 10 points de rage après avoir utilisé Exécution.|r",
        enUS = "|cffffffffSudden Death|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Your melee attacks have a 9% chance to allow the use of Execute regardless of the target's remaining health.\nAdditionally, you retain 10 rage after using Execute.|r"
    }
},
{
    id = "spellEndlessRage",
    name = "buttonSpellEndlessRage",
    icon = "Interface/icons/ability_warrior_endlessrage",
    position = {478, -350},
    handler = "spellendlessrage",
    tooltips = {
        frFR = "|cffffffffRage infinie|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vous générez 25% de rage supplémentaires lorsque vous infligez des dégâts.|r",
        enUS = "|cffffffffEndless Rage|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100You generate 25% more rage when dealing damage.|r"
    }
},

-- CreateSpellButton("buttonSpellImprovedHeroicStrike", "Interface/icons/spell_magic_magearmor", "|cffffffffFrappe héroïque améliorée|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit le coût en rage de votre technique Frappe héroïque de 3 points.|r", "spellimprovedheroicstrike", 100, -80)
-- CreateSpellButton("buttonSpellDeflection", "Interface/icons/ability_parry", "|cffffffffDéviation|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente vos chances de Parer de 5%.|r", "spelldeflection", 205, -75)
-- CreateSpellButton("buttonSpellImprovedRend", "Interface/icons/ability_gouge", "|cffffffffPourfendre amélioré|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente de 20% les dégâts de saignement infligés par votre technique Pourfendre.|r", "spellimprovedrend", 315, -75)
-- CreateSpellButton("buttonSpellImprovedCharge", "Interface/icons/ability_warrior_charge", "|cffffffffCharge améliorée|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente la quantité de Rage générée par votre technique Charge de 10.|r", "spellimprovedcharge", 418, -80)
-- CreateSpellButton("buttonSpellIronWill", "Interface/icons/spell_magic_magearmor", "|cffffffffVolonté de fer|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit de 20% la durée de tous les effets d'étourdissement et de charme utilisés contre vous.|r", "spellironwill", 45, -130)
-- CreateSpellButton("buttonSpellTacticalMastery", "Interface/icons/spell_nature_enchantarmor", "|cffffffffMaîtrise tactique|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vous conservez jusqu'à 15 points de rage supplémentaires lorsque vous changez de posture.\nAugmente aussi considérablement la menace générée par vos techniques Sanguinaire et Frappe mortelle quand vous êtes en posture défensive (Plus efficace que le Rang 2).|r", "spelltacticalmastery", 150, -130)
-- CreateSpellButton("buttonSpellImprovedOverpower", "Interface/icons/inv_sword_05", "|cffffffffFulgurance améliorée|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente de 50% vos chances d'infliger un coup critique avec la technique Fulgurance.|r", "spellimprovedoverpower", 260, -130)
-- CreateSpellButton("buttonSpellAngerManagement", "Interface/icons/spell_holy_blessingofstamina", "|cffffffffMaîtrise de la Rage|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Génère 1 point de rage toutes les 3 secondes.|r", "spellangermanagement", 370, -130)
-- CreateSpellButton("buttonSpellImpale", "Interface/icons/ability_searingarrow", "|cffffffffEmpaler|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente de 20% le bonus aux dégâts des coups critiques réussis avec vos techniques.|r", "spellimpale", 475, -133)
-- CreateSpellButton("buttonSpellDeepWounds", "Interface/icons/ability_backstab", "|cffffffffBlessures profondes|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vos coups critiques font saigner l'adversaire et lui infligent 48% des points de dégâts moyens de votre arme de mêlée en 6 secondes.|r", "spelldeepwounds", 96, -185)
-- CreateSpellButton("buttonSpellTwoHandedWeaponSpecialization", "Interface/icons/inv_axe_09", "|cffffffffSpécialisation Arme 2M|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente les points de dégâts que vous infligez avec les armes de mêlée à deux mains de 6%.|r", "spelltwohandedweaponspecialization", 205, -185)
-- CreateSpellButton("buttonSpellTasteforBlood", "Interface/icons/ability_rogue_hungerforblood", "|cffffffffGoût du sang|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Chaque fois que votre technique Pourfendre inflige des dégâts, vous avez 100% de chances de permettre l'utilisation de votre technique Fulgurance pendant 9 secondes.\n1 charge.\nCet effet ne peut se produire plus d'une fois toutes les 6 sec.|r", "spelltasteforblood", 315, -185)
-- CreateSpellButton("buttonSpellPoleaxeSpecialization", "Interface/icons/inv_axe_06", "|cffffffffSpécialisation Hache d'hast|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente de 5% vos chances d'infliger un coup critique avec les haches et les armes d'hast ainsi que les dégâts de ces critiques.|r", "spellpoleaxespecialization", 422, -185)
-- CreateSpellButton("buttonSpellSweepingStrikes", "Interface/icons/ability_rogue_slicedice", "|cffffffffAttaques circulaires|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vos 5 prochaines attaques de mêlée frappent un adversaire proche supplémentaire.|r", "spellsweepingstrikes", 527, -190)
-- CreateSpellButton("buttonSpellMaceSpecialization", "Interface/icons/inv_mace_01", "|cffffffffSpécialisation Masse|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vos attaques avec les masses ignorent jusqu'à 15% de l'armure de votre adversaire.", "spellmacespecialization", 43, -240)
-- CreateSpellButton("buttonSpellSwordSpecialization", "Interface/icons/inv_sword_27", "|cffffffffSpécialisation Epée|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vous confère 10% de chances de bénéficier d'une attaque supplémentaire sur la même cible après avoir infligé des dégâts avec votre épée.\nCet effet ne survient pas plus d'une fois toutes les 6 secondes.|r", "spellswordspecialization", 150, -240)
-- CreateSpellButton("buttonSpellWeaponMastery", "Interface/icons/ability_warrior_weaponmastery", "|cffffffffMaîtrise des armes|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit la probabilité que vos attaques soient esquivées de 2% et réduit la durée de tous les effets de désarmement utilisés contre vous de 50%.\nNon cumulable avec les autres effets qui réduisent la durée du désarmement.|r", "spellweaponmastery", 368, -240)
-- CreateSpellButton("buttonSpellImprovedHamstring", "Interface/icons/ability_shockwave", "|cffffffffBrise-genou amélioré|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Confère à votre technique Brise-genou 15% de chances d'immobiliser votre cible pendant 5 secondes.|r", "spellimprovedhamstring", 478, -240)
-- CreateSpellButton("buttonSpellTrauma", "Interface/icons/ability_warrior_bloodnova", "|cffffffffTraumatisme|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vos coups critiques normaux en mêlée augmentent l'efficacité des effets de saignement sur la cible de 30% pendant 1 mn.|r", "spelltrauma", 98, -293)
-- CreateSpellButton("buttonSpellSecondWind", "Interface/icons/ability_hunter_harass", "|cffffffffSecond souffle|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Chaque fois que vous êtes atteint par un effet d'étourdissement ou d'immobilisation, vous gagnez 20 points de rage et 10% de votre total de points de vie en 10 secondes.|r", "spellsecondwind", 205, -293)
-- CreateSpellButton("buttonSpellMortalStrike", "Interface/icons/ability_warrior_savageblow", "|cffffffffFrappe mortelle|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Une attaque vicieuse qui inflige les dégâts de l'arme plus 85 et blesse la cible.\nL'effet des sorts de soins dont elle est la cible est réduit de 50% pendant 10 secondes.|r", "spellmortalstrike", 315, -293)
-- CreateSpellButton("buttonSpellStrengthofArms", "Interface/icons/ability_warrior_offensivestance", "|cffffffffForce des armes|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente votre total de Force et d'Endurance de 4% et votre expertise de 4.|r", "spellstrengthofarms", 422, -293)
-- CreateSpellButton("buttonSpellImprovedSlam", "Interface/icons/ability_warrior_decisivestrike", "|cffffffffHeurtoir amélioré|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit le temps de frappe de votre technique Heurtoir de 1 sec.|r", "spellimprovedslam", 527, -295)
-- CreateSpellButton("buttonSpellJuggernaut", "Interface/icons/ability_warrior_bullrush", "|cffffffffMastodonte|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Votre technique Charge est à présent utilisable en combat, mais son temps de recharge est augmenté de 5 sec.\nAprès une Charge, votre prochaine technique Heurtoir ou Frappe mortelle bénéficie de 25% de chances supplémentaires d'être critique si elle est utilisée dans les 10 secondes.|r", "spellunrelentingassault", 43, -350)
-- CreateSpellButton("buttonSpellImprovedMortalStrike", "Interface/icons/ability_warrior_savageblow", "|cffffffffFrappe mortelle améliorée|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente les dégâts infligés par votre technique Frappe mortelle de 10% et réduit le temps de recharge de 1 sec.|r", "spellimprovedmortalstrike", 150, -350)
-- CreateSpellButton("buttonSpellUnrelentingAssault|r", "Interface/icons/ability_warrior_unrelentingassault", "|cffffffffAssaut continuel|r\n|cffffffffTalent|r |cffc0c0c0Armes|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit le temps de recharge de vos techniques Fulgurance et Vengeance de 4 secondes et augmente les dégâts infligés par ces deux techniques de 20%.\nDe plus, si vous frappez un personnage-joueur avec Fulgurance alors qu'il est en train d'incanter un sort, ses dégâts et soins magiques sont réduits de 50% pendant 6 secondes.|r", "spellgrace", 260, -350)
-- CreateSpellButton("buttonSpellSuddenDeath", "Interface/icons/ability_warrior_improveddisciplines", "|cffffffffMort soudaine|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vos coups en mêlée ont 9% de chances de permettre l'utilisation d'Exécution quel que soit le montant de points de vie restant à la cible.\nDe plus, vous conservez 10 points de rage après avoir utilisé Exécution.|r", "spellsuddendeath", 368, -350)
-- CreateSpellButton("buttonSpellEndlessRage", "Interface/icons/ability_warrior_endlessrage", "|cffffffffRage infinie|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vous générez 25% de rage supplémentaires lorsque vous infligez des dégâts.|r", "spellendlessrage", 478, -350)

-- Fureur

{
    id = "spellBloodFrenzy",
    name = "buttonSpellBloodFrenzy",
    icon = "Interface/icons/ability_warrior_bloodfrenzy",
    position = {98, -405},
    handler = "spellbloodfrenzy",
    tooltips = {
        frFR = "|cffffffffFrénésie sanglante|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente votre vitesse d'attaque en mêlée de 10%.\nDe plus, vos techniques Pourfendre et Blessures profondes augmentent aussi tous les dégâts physiques infligés à cette cible de 4%.|r",
        enUS = "|cffffffffBlood Frenzy|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases your melee attack speed by 10%.\nAdditionally, your Rend and Deep Wounds abilities also increase all physical damage done to the target by 4%.|r"
    }
},
{
    id = "spellWreckingCrew",
    name = "buttonSpellWreckingCrew",
    icon = "Interface/icons/ability_warrior_trauma",
    position = {205, -405},
    handler = "spellwreckingcrew",
    tooltips = {
        frFR = "|cffffffffDémolisseurs|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vos coups critiques en mêlée vous font Enrager, ce qui augmente tous les dégâts infligés de 10% pendant 12 secondes.\nCet effet ne se cumule pas avec Enrager.|r",
        enUS = "|cffffffffWrecking Crew|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Your melee critical hits enrage you, increasing all damage dealt by 10% for 12 seconds.\nThis effect does not stack with Enrage.|r"
    }
},
{
    id = "spellBladestorm",
    name = "buttonSpellBladestorm",
    icon = "Interface/icons/ability_warrior_bladestorm",
    position = {315, -405},
    handler = "spellbladestorm",
    tooltips = {
        frFR = "|cffffffffTempête de lames|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Exécute instantanément une attaque Tourbillon sur un maximum de 4 cibles et pendant les prochaines 6 secondes, vous exécuterez une attaque Tourbillon toutes les 1 sec.\nTant que vous êtes sous l'effet de Tempête de lames, vous pouvez vous déplacer mais vous ne pouvez pas exécuter d'autres techniques.\nCependant, vous ne ressentez ni pitié, ni remords, ni peur et vous ne pouvez être arrêté à moins d'être tué.|r",
        enUS = "|cffffffffBladestorm|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Instantly performs a Whirlwind attack on up to 4 targets, and for the next 6 seconds, you will perform a Whirlwind attack every 1 sec.\nWhile under the effect of Bladestorm, you can move but cannot perform other abilities.\nHowever, you feel no pity, remorse, or fear, and cannot be stopped unless killed.|r"
    }
},
{
    id = "spellArmoredtotheTeeth",
    name = "buttonSpellArmoredtotheTeeth",
    icon = "Interface/icons/inv_shoulder_22",
    position = {422, -405},
    handler = "spellarmoredtotheteeth",
    tooltips = {
        frFR = "|cffffffffArmé jusqu'aux dents|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente votre puissance d'attaque de 3 pour chaque tranche de 108 points de votre valeur d'armure.|r",
        enUS = "|cffffffffArmored to the Teeth|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases your attack power by 3 for every 108 points of your armor value.|r"
    }
},
{
    id = "spellBoomingVoice",
    name = "buttonSpellBoomingVoice",
    icon = "Interface/icons/spell_nature_purge",
    position = {43, -458},
    handler = "spellboomingvoice",
    tooltips = {
        frFR = "|cffffffffVoix tonitruante|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente de 50% la zone d'effet et la durée de vos techniques Cri de guerre, Cri démoralisant et Cri de commandement.|r",
        enUS = "|cffffffffBooming Voice|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases the area of effect and duration of your Battle Shout, Demoralizing Shout, and Commanding Shout abilities by 50%.|r"
    }
},
{
    id = "spellCruelty",
    name = "buttonSpellCruelty",
    icon = "Interface/icons/ability_rogue_eviscerate",
    position = {150, -458},
    handler = "spellcruelty",
    tooltips = {
        frFR = "|cffffffffCruauté|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente vos chances d'infliger un coup critique avec les armes de mêlée de 5%.|r",
        enUS = "|cffffffffCruelty|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases your chance to score a critical hit with melee weapons by 5%.|r"
    }
},
{
    id = "spellImprovedDemoralizingShout",
    name = "buttonSpellImprovedDemoralizingShout",
    icon = "Interface/icons/ability_warrior_warcry",
    position = {260, -458},
    handler = "spellimproveddemoralizingshout",
    tooltips = {
        frFR = "|cffffffffCri démoralisant amélioré|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente la réduction de puissance d'attaque en mêlée de votre Cri démoralisant de 40%.|r",
        enUS = "|cffffffffImproved Demoralizing Shout|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases the melee attack power reduction of your Demoralizing Shout by 40%.|r"
    }
},
{
    id = "spellUnbridledWrath",
    name = "buttonSpellUnbridledWrath",
    icon = "Interface/icons/spell_nature_stoneclawtotem",
    position = {368, -458},
    handler = "spellunbridledwrath",
    tooltips = {
        frFR = "|cffffffffColère déchaînée|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vous confère une chance de gagner un point de rage supplémentaire quand vous infligez des dégâts en mêlée avec une arme.\nL'effet se produit plus souvent qu'avec Colère déchaînée (Rang 4).|r",
        enUS = "|cffffffffUnbridled Wrath|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Gives you a chance to gain an additional rage point when you deal melee damage with a weapon.\nThis effect occurs more frequently than with Unbridled Wrath (Rank 4).|r"
    }
},
{
    id = "spellImprovedCleave",
    name = "buttonSpellImprovedCleave",
    icon = "Interface/icons/ability_warrior_cleave",
    position = {478, -458},
    handler = "spellimprovedcleave",
    tooltips = {
        frFR = "|cffffffffEnchaînement amélioré|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente le bonus de dégâts infligé par votre technique Enchaînement de 120%.|r",
        enUS = "|cffffffffImproved Cleave|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases the damage bonus of your Cleave ability by 120%.|r"
    }
},
{
    id = "spellPiercingHowl",
    name = "buttonSpellPiercingHowl",
    icon = "Interface/icons/spell_holy_heal02",
    position = {98, -510},
    handler = "spellpiercinghowl",
    tooltips = {
        frFR = "|cffffffffHurlement perçant|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Tous les ennemis se trouvant à moins de 10 mètres du guerrier sont hébétés, et leur vitesse de déplacement est réduite de 50% pendant 6 secondes.|r",
        enUS = "|cffffffffPiercing Howl|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100All enemies within 10 yards of the warrior are dazed, and their movement speed is reduced by 50% for 6 seconds.|r"
    }
},
{
    id = "spellBloodCraze",
    name = "buttonSpellBloodCraze",
    icon = "Interface/icons/spell_shadow_summonimp",
    position = {205, -510},
    handler = "spellbloodcraze",
    tooltips = {
        frFR = "|cffffffffFolie sanguinaire|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Régénère 6% de votre nombre total de points de vie sur 6 secondes après avoir reçu un coup critique.|r",
        enUS = "|cffffffffBlood Craze|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Restores 6% of your total health over 6 seconds after receiving a critical strike.|r"
    }
},
{
    id = "spellCommandingPresence",
    name = "buttonSpellCommandingPresence",
    icon = "Interface/icons/spell_nature_focusedmind",
    position = {315, -510},
    handler = "spellcommandingpresence",
    tooltips = {
        frFR = "|cffffffffPrésence impérieuse|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente de 25% le bonus à la puissance d'attaque en mêlée de votre Cri de guerre et le bonus aux points de vie de votre Cri de commandement.|r",
        enUS = "|cffffffffCommanding Presence|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases the melee attack power bonus of your Battle Shout and the health bonus of your Commanding Shout by 25%.|r"
    }
},
{
    id = "spellDualWieldSpecialization",
    name = "buttonSpellDualWieldSpecialization",
    icon = "Interface/icons/ability_dualwield",
    position = {422, -510},
    handler = "spelldualwieldspecialization",
    tooltips = {
        frFR = "|cffffffffSpécialisation Ambidextrie|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente de 25% les points de dégâts infligés par l'arme que vous utilisez en main gauche.|r",
        enUS = "|cffffffffDual Wield Specialization|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases the damage dealt by your off-hand weapon by 25%.|r"
    }
},

-- CreateSpellButton("buttonSpellBloodFrenzy", "Interface/icons/ability_warrior_bloodfrenzy", "|cffffffffFrénésie sanglante|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente votre vitesse d'attaque en mêlée de 10%.\nDe plus, vos techniques Pourfendre et Blessures profondes augmentent aussi tous les dégâts physiques infligés à cette cible de 4%.|r", "spellbloodfrenzy", 98, -405)
-- CreateSpellButton("buttonSpellWreckingCrew", "Interface/icons/ability_warrior_trauma", "|cffffffffDémolisseurs|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vos coups critiques en mêlée vous font Enrager, ce qui augmente tous les dégâts infligés de 10% pendant 12 secondes.\nCet effet ne se cumule pas avec Enrager.|r", "spellwreckingcrew", 205, -405)
-- CreateSpellButton("buttonSpellBladestorm", "Interface/icons/ability_warrior_bladestorm", "|cffffffffTempête de lames|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Exécute instantanément une attaque Tourbillon sur un maximum de 4 cibles et pendant les prochaines 6 seconds, vous exécuterez une attaque Tourbillon toutes les 1 sec.\nTant que vous êtes sous l'effet de Tempête de lames, vous pouvez vous déplacer mais vous ne pouvez pas exécuter d'autres techniques.\nCependant, vous ne ressentez ni pitié, ni remords, ni peur et vous ne pouvez être arrêté à moins d'être tué.|r", "spellbladestorm", 315, -405)
-- CreateSpellButton("buttonSpellArmoredtotheTeeth", "Interface/icons/inv_shoulder_22", "|cffffffffArmé jusqu'aux dents|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente votre puissance d'attaque de 3 pour chaque tranche de 108 points de votre valeur d'armure.|r", "spellarmoredtotheteeth", 422, -405)
-- CreateSpellButton("buttonSpellBoomingVoice", "Interface/icons/spell_nature_purge", "|cffffffffVoix tonitruante|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente de 50% la zone d'effet et la durée de vos techniques Cri de guerre, Cri démoralisant et Cri de commandement.|r", "spellboomingvoice", 43, -458)
-- CreateSpellButton("buttonSpellCruelty", "Interface/icons/ability_rogue_eviscerate", "|cffffffffCruauté|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente vos chances d'infliger un coup critique avec les armes de mêlée de 5%.|r", "spellcruelty", 150, -458)
-- CreateSpellButton("buttonSpellImprovedDemoralizingShout", "Interface/icons/ability_warrior_warcry", "|cffffffffCri démoralisant amélioré|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente la réduction de puissance d'attaque en mêlée de votre Cri démoralisant de 40%.|r", "spellimproveddemoralizingshout", 260, -458)
-- CreateSpellButton("buttonSpellUnbridledWrath", "Interface/icons/spell_nature_stoneclawtotem", "|cffffffffColère déchaînée|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vous confère une chance de gagner un point de rage supplémentaire quand vous infligez des dégâts en mêlée avec une arme.\nL'effet se produit plus souvent qu'avec Colère déchaînée (Rang 4).|r", "spellunbridledwrath", 368, -458)
-- CreateSpellButton("buttonSpellImprovedCleave", "Interface/icons/ability_warrior_cleave", "|cffffffffEnchaînement amélioré|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente le bonus de dégâts infligé par votre technique Enchaînement de 120%.|r", "spellimprovedcleave", 478, -458)
-- CreateSpellButton("buttonSpellPiercingHowl", "Interface/icons/spell_holy_heal02", "|cffffffffHurlement perçant|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Tous les ennemis se trouvant à moins de 10 mètres du guerrier sont hébétés, et leur vitesse de déplacement est réduite de 50% pendant 6 secondes.|r", "spellpiercinghowl", 98, -510)
-- CreateSpellButton("buttonSpellBloodCraze", "Interface/icons/spell_shadow_summonimp", "|cffffffffFolie sanguinaire|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Régénère 6% de votre nombre total de points de vie sur 6 secondes après avoir reçu un coup critique.|r", "spellbloodcraze", 205, -510)
-- CreateSpellButton("buttonSpellCommandingPresence", "Interface/icons/spell_nature_focusedmind", "|cffffffffPrésence impérieuse|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente de 25% le bonus à la puissance d'attaque en mêlée de votre Cri de guerre et le bonus aux points de vie de votre Cri de commandement.|r", "spellcommandingpresence", 315, -510)
-- CreateSpellButton("buttonSpellDualWieldSpecialization", "Interface/icons/ability_dualwield", "|cffffffffSpécialisation Ambidextrie|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente de 25% les points de dégâts infligés par l'arme que vous utilisez en main gauche.|r", "spelldualwieldspecialization", 422, -510)

-- Template 2

{
    id = "spellImprovedExecute",
    name = "buttonSpellImprovedExecute",
    icon = "Interface/icons/inv_sword_48",
    position = {663, -75},
    handler = "spellimprovedexecute",
    tooltips = {
        frFR = "|cffffffffExécution améliorée|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit le coût en rage de votre technique Exécution de 5.|r",
        enUS = "|cffffffffImproved Execute|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Reduces the rage cost of your Execute ability by 5.|r"
    }
},
{
    id = "spellEnrage",
    name = "buttonSpellEnrage",
    icon = "Interface/icons/spell_holy_surgeoflight",
    position = {770, -75},
    handler = "spellenrage",
    tooltips = {
        frFR = "|cffffffffEnrager|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vous confère 30% de chances de bénéficier d'un bonus aux dégâts en mêlée de 10% pendant 12 secondes lorsque vous êtes victime d'une attaque qui vous inflige des dégâts.\nCet effet ne se cumule pas avec Démolisseurs.|r",
        enUS = "|cffffffffEnrage|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Gives you a 30% chance to gain a 10% melee damage bonus for 12 seconds when you take damage from an attack.\nThis effect does not stack with Wrecking Crew.|r"
    }
},
{
    id = "spellPrecision",
    name = "buttonSpellPrecision",
    icon = "Interface/icons/ability_marksmanship",
    position = {880, -75},
    handler = "spellprecision",
    tooltips = {
        frFR = "|cffffffffPrécision|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente vos chances de toucher l'ennemi avec vos armes de mêlée de 3%.|r",
        enUS = "|cffffffffPrecision|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases your chance to hit with melee weapons by 3%.|r"
    }
},
{
    id = "spellDeathWish",
    name = "buttonSpellDeathWish",
    icon = "Interface/icons/spell_shadow_deathpact",
    position = {990, -75},
    handler = "spelldeathwish",
    tooltips = {
        frFR = "|cffffffffSouhait mortel|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Lorsque cette technique est activée, vous enragez et vos dégâts physiques sont augmentés de 20%, mais tous les dégâts subis sont augmentés de 5%.\nDure 30 secondes.|r",
        enUS = "|cffffffffDeath Wish|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Activating this ability enrages you, increasing your physical damage by 20%, but all damage taken is increased by 5%.\nLasts 30 seconds.|r"
    }
},
{
    id = "spellImprovedIntercept",
    name = "buttonSpellImprovedIntercept",
    icon = "Interface/icons/ability_rogue_sprint",
    position = {1100, -75},
    handler = "spellimprovedintercept",
    tooltips = {
        frFR = "|cffffffffInterception améliorée|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit le temps de recharge de votre technique Interception de 10 sec.|r",
        enUS = "|cffffffffImproved Intercept|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Reduces the cooldown of your Intercept ability by 10 seconds.|r"
    }
},
{
    id = "spellImprovedBerserkerRage",
    name = "buttonSpellImprovedBerserkerRage",
    icon = "Interface/icons/spell_nature_ancestralguardian",
    position = {718, -130},
    handler = "spellimprovedberserkerrage",
    tooltips = {
        frFR = "|cffffffffRage berserker améliorée|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100La technique Rage berserker génère 20 points de rage quand elle est utilisée.|r",
        enUS = "|cffffffffImproved Berserker Rage|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100The Berserker Rage ability generates 20 rage when used.|r"
    }
},
{
    id = "spellFlurry",
    name = "buttonSpellFlurry",
    icon = "Interface/icons/ability_ghoulfrenzy",
    position = {825, -130},
    handler = "spellflurry",
    tooltips = {
        frFR = "|cffffffffRafale|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Lorsque vous infligez un coup critique en mêlée, augmente votre vitesse d'attaque de 25% pour les 3 prochains coups.|r",
        enUS = "|cffffffffFlurry|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100When you score a melee critical hit, increases your attack speed by 25% for the next 3 attacks.|r"
    }
},
{
    id = "spellIntensifyRage",
    name = "buttonSpellIntensifyRage",
    icon = "Interface/icons/ability_warrior_endlessrage",
    position = {935, -130},
    handler = "spellintensifyrage",
    tooltips = {
        frFR = "|cffffffffIntensifier la rage|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit le temps de recharge de vos techniques Rage sanguinaire, Rage berserker, Témérité et Souhait mortel de 33%.|r",
        enUS = "|cffffffffIntensify Rage|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Reduces the cooldown of your Bloodrage, Berserker Rage, Recklessness, and Death Wish abilities by 33%.|r"
    }
},
{
    id = "spellBloodthirst",
    name = "buttonSpellBloodthirst",
    icon = "Interface/icons/spell_nature_bloodlust",
    position = {1045, -130},
    handler = "spellbloodthirst",
    tooltips = {
        frFR = "|cffffffffSanguinaire|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Attaque instantanément la cible et lui inflige 577 points de dégâts.\nDe plus, les 3 prochaines attaques de mêlée réussies rendent 1% du maximum de points de vie.\nCet effet dure 8 secondes.\nLes dégâts sont proportionnels à votre puissance d'attaque.|r",
        enUS = "|cffffffffBloodthirst|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Instantly attacks the target and deals 577 damage.\nAdditionally, the next 3 successful melee attacks restore 1% of maximum health.\nThis effect lasts 8 seconds.\nDamage is based on your attack power.|r"
    }
},
{
    id = "spellImprovedWhirlwind",
    name = "buttonSpellImprovedWhirlwind",
    icon = "Interface/icons/ability_whirlwind",
    position = {663, -184},
    handler = "spellimprovedwhirlwind",
    tooltips = {
        frFR = "|cffffffffTourbillon amélioré|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente les dégâts de votre technique Tourbillon de 20%.|r",
        enUS = "|cffffffffImproved Whirlwind|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases the damage of your Whirlwind ability by 20%.|r"
    }
},
{
    id = "spellFuriousAttacks",
    name = "buttonSpellFuriousAttacks",
    icon = "Interface/icons/ability_warrior_furiousresolve",
    position = {770, -184},
    handler = "spellfuriousattacks",
    tooltips = {
        frFR = "|cffffffffAttaques furieuses|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vos attaques de mêlée normales ont une chance de réduire tous les soins prodigués à la cible de 25% pendant 10 secondes.\nCet effet est cumulable jusqu'à 2 fois.\nSe produit plus souvent qu'Attaques furieuses (Rang 1).|r",
        enUS = "|cffffffffFurious Attacks|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Your normal melee attacks have a chance to reduce all healing done to the target by 25% for 10 seconds.\nThis effect is stackable up to 2 times.\nOccurs more frequently than Furious Attacks (Rank 1).|r"
    }
},
{
    id = "spellImprovedBerserkerStance",
    name = "buttonSpellImprovedBerserkerStance",
    icon = "Interface/icons/ability_racial_avatar",
    position = {880, -184},
    handler = "spellimprovedberserkerstance",
    tooltips = {
        frFR = "|cffffffffPosture berserker améliorée|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente la Force de 20% et réduit la menace générée de 10% lorsque vous êtes en posture berserker.|r",
        enUS = "|cffffffffImproved Berserker Stance|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases Strength by 20% and reduces threat generated by 10% when in Berserker Stance.|r"
    }
},
{
    id = "spellHeroicFury",
    name = "buttonSpellHeroicFury",
    icon = "Interface/icons/ability_heroicleap",
    position = {990, -184},
    handler = "spellheroicfury",
    tooltips = {
        frFR = "|cffffffffFureur héroïque|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Dissipe tous les effets d'immobilisation et met fin au temps de recharge de votre technique Interception.|r",
        enUS = "|cffffffffHeroic Fury|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Dispels all movement impairing effects and resets the cooldown of your Intercept ability.|r"
    }
},
{
    id = "spellRampage",
    name = "buttonSpellRampage",
    icon = "Interface/icons/ability_warrior_rampage",
    position = {1100, -184},
    handler = "spellrampage",
    tooltips = {
        frFR = "|cffffffffSaccager|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente de 5% les chances de coup critique en mêlée et à distance de tous les membres du groupe ou raid se trouvant à moins de 100 mètres.|r",
        enUS = "|cffffffffRampage|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases melee and ranged critical strike chance by 5% for all party or raid members within 100 yards.|r"
    }
},

-- CreateSpellButton("buttonSpellImprovedExecute", "Interface/icons/inv_sword_48", "|cffffffffExécution améliorée|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit le coût en rage de votre technique Exécution de 5.|r", "spellimprovedexecute", 663, -75)
-- CreateSpellButton("buttonSpellEnrage", "Interface/icons/spell_holy_surgeoflight", "|cffffffffEnrager|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vous confère 30% de chances de bénéficier d'un bonus aux dégâts en mêlée de 10% pendant 12 secondes lorsque vous êtes victime d'une attaque qui vous inflige des dégâts.\nCet effet ne se cumule pas avec Démolisseurs.|r", "spellenrage", 770, -75)
-- CreateSpellButton("buttonSpellPrecision", "Interface/icons/ability_marksmanship", "|cffffffffPrécision|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente vos chances de toucher l'ennemi avec vos armes de mêlée de 3%.|r", "spellprecision", 880, -75)
-- CreateSpellButton("buttonSpellDeathWish", "Interface/icons/spell_shadow_deathpact", "|cffffffffSouhait mortel|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Lorsque cette technique est activée, vous enragez et vos dégâts physiques sont augmentés de 20%, mais tous les dégâts subis sont augmentés de 5%.\nDure 30 secondes.|r", "spelldeathwish", 990, -75)
-- CreateSpellButton("buttonSpellImprovedIntercept", "Interface/icons/ability_rogue_sprint", "|cffffffffInterception améliorée|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit le temps de recharge de votre technique Interception de 10 sec.|r", "spellimprovedintercept", 1100, -75)
-- CreateSpellButton("buttonSpellImprovedBerserkerRage", "Interface/icons/spell_nature_ancestralguardian", "|cffffffffRage berserker améliorée|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100La technique Rage berserker génère 20 points de rage quand elle est utilisée.|r", "spellimprovedberserkerrage", 718, -130)
-- CreateSpellButton("buttonSpellFlurry", "Interface/icons/ability_ghoulfrenzy", "|cffffffffRafale|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Lorsque vous infligez un coup critique en mêlée, augmente votre vitesse d'attaque de 25% pour les 3 prochains coups.|r", "spellflurry", 825, -130)
-- CreateSpellButton("buttonSpellIntensifyRage", "Interface/icons/ability_warrior_endlessrage", "|cffffffffIntensifier la rage|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit le temps de recharge de vos techniques Rage sanguinaire, Rage berserker, Témérité et Souhait mortel de 33%.|r", "spellintensifyrage", 935, -130)
-- CreateSpellButton("buttonSpellBloodthirst", "Interface/icons/spell_nature_bloodlust", "|cffffffffSanguinaire|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Attaque instantanément la cible et lui inflige 577 points de dégâts.\nDe plus, les 3 prochaines attaques de mêlée réussies rendent 1% du maximum de points de vie.\nCet effet dure 8 seconds.\nLes dégâts sont proportionnels à votre puissance d'attaque.|r", "spellbloodthirst", 1045, -130)
-- CreateSpellButton("buttonSpellImprovedWhirlwind", "Interface/icons/ability_whirlwind", "|cffffffffTourbillon amélioré|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente les dégâts de votre technique Tourbillon de 20%.|r", "spellimprovedwhirlwind", 663, -184)
-- CreateSpellButton("buttonSpellFuriousAttacks", "Interface/icons/ability_warrior_furiousresolve", "|cffffffffAttaques furieuses|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vos attaques de mêlée normales ont une chance de réduire tous les soins prodigués à la cible de 25% pendant 10 secondes.\nCet effet est cumulable jusqu'à 2 fois.\nSe produit plus souvent qu'Attaques furieuses (Rang 1).|r", "spellfuriousattacks", 770, -184)
-- CreateSpellButton("buttonSpellImprovedBerserkerStance", "Interface/icons/ability_racial_avatar", "|cffffffffPosture berserker améliorée|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente la Force de 20% et réduit la menace générée de 10% lorsque vous êtes en posture berserker.|r", "spellimprovedberserkerstance", 880, -184)
-- CreateSpellButton("buttonSpellHeroicFury", "Interface/icons/ability_heroicleap", "|cffffffffFureur héroïque|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Dissipe tous les effets d'immobilisation et met fin au temps de recharge de votre technique Interception.|r", "spellheroicfury", 990, -184)
-- CreateSpellButton("buttonSpellRampage", "Interface/icons/ability_warrior_rampage", "|cffffffffSaccager|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente de 5% les chances de coup critique en mêlée et à distance de tous les membres du groupe ou raid se trouvant à moins de 100 mètres.", "spellrampage", 1100, -184)


-- Protection

{
    id = "spellBloodsurge",
    name = "buttonSpellBloodsurge",
    icon = "Interface/icons/ability_warrior_bloodsurge",
    position = {718, -240},
    handler = "spellbloodsurge",
    tooltips = {
        frFR = "|cffffffffAfflux sanguin|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vos coups réussis avec Frappe héroïque, Sanguinaire et Tourbillon ont 20% de chances de rendre votre prochain Heurtoir instantané pendant 5 secondes.|r",
        enUS = "|cffffffffBloodsurge|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Successful hits with Heroic Strike, Bloodthirst, and Whirlwind have a 20% chance to make your next Slam instant for 5 seconds.|r"
    }
},
{
    id = "spellUnendingFury",
    name = "buttonSpellUnendingFury",
    icon = "Interface/icons/ability_warrior_intensifyrage",
    position = {825, -240},
    handler = "spellunendingfury",
    tooltips = {
        frFR = "|cffffffffFureur sans fin|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente les dégâts infligés par vos techniques Heurtoir, Tourbillon et Sanguinaire de 10%.|r",
        enUS = "|cffffffffUnending Fury|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases the damage of your Slam, Whirlwind, and Bloodthirst abilities by 10%.|r"
    }
},
{
    id = "spellTitansGrip",
    name = "buttonSpellTitansGrip",
    icon = "Interface/icons/ability_warrior_titansgrip",
    position = {935, -240},
    handler = "spelltitansgrip",
    tooltips = {
        frFR = "|cffffffffPoigne du titan|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vous permet de manier les haches, les masses et les épées à deux mains d’une seule main.\nLorsque vous portez une arme à deux mains d'une seule main, les dégâts physiques que vous infligez sont réduits de 10%.|r",
        enUS = "|cffffffffTitan's Grip|r\n|cffffffffTalent|r |cff9e604eFury|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Allows you to wield two-handed axes, maces, and swords in one hand.\nWhen wielding a two-handed weapon in one hand, your physical damage dealt is reduced by 10%.|r"
    }
},
{
    id = "spellImprovedBloodrage",
    name = "buttonSpellImprovedBloodrage",
    icon = "Interface/icons/ability_racial_bloodrage",
    position = {1045, -240},
    handler = "spellimprovedbloodrage",
    tooltips = {
        frFR = "|cffffffffRage sanguinaire améliorée|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente la rage instantanée générée par votre technique Rage sanguinaire de 50%.|r",
        enUS = "|cffffffffImproved Bloodrage|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases the instant rage generated by your Bloodrage ability by 50%.|r"
    }
},
{
    id = "spellShieldSpecialization",
    name = "buttonSpellShieldSpecialization",
    icon = "Interface/icons/inv_shield_06",
    position = {663, -293},
    handler = "spellshieldspecialization",
    tooltips = {
        frFR = "|cffffffffSpécialisation Bouclier|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente de 5% vos chances de bloquer les attaques avec un bouclier, avec 100% de chances de générer 5 points de Rage quand vous bloquez, esquivez ou parez.|r",
        enUS = "|cffffffffShield Specialization|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases your chance to block attacks with a shield by 5%, with a 100% chance to generate 5 rage when you block, dodge, or parry.|r"
    }
},
{
    id = "spellImprovedThunderClap",
    name = "buttonSpellImprovedThunderClap",
    icon = "Interface/icons/ability_thunderclap",
    position = {770, -293},
    handler = "spellimprovedthunderclap",
    tooltips = {
        frFR = "|cffffffffCoup de tonnerre amélioré|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit le coût de votre technique Coup de tonnerre de 4 points de rage et augmente les dégâts de 30% et l'effet de ralentissement de 10% supplémentaires.|r",
        enUS = "|cffffffffImproved Thunderclap|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Reduces the rage cost of your Thunder Clap ability by 4 and increases the damage by 30% and the slow effect by an additional 10%.|r"
    }
},
{
    id = "spellIncite",
    name = "buttonSpellIncite",
    icon = "Interface/icons/ability_warrior_incite",
    position = {990, -293},
    handler = "spellincite",
    tooltips = {
        frFR = "|cffffffffEmulation|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente de 15% vos chances de réaliser un coup critique avec les techniques Frappe héroïque, Coup de tonnerre et Enchaînement.|r",
        enUS = "|cffffffffIncite|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases your chance to score a critical hit with Heroic Strike, Thunder Clap, and Revenge by 15%.|r"
    }
},
{
    id = "spellAnticipation",
    name = "buttonSpellAnticipation",
    icon = "Interface/icons/spell_nature_mirrorimage",
    position = {1100, -293},
    handler = "spellanticipation",
    tooltips = {
        frFR = "|cffffffffAnticipation|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente vos chances d'esquiver une attaque de 5%.|r",
        enUS = "|cffffffffAnticipation|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases your chance to dodge an attack by 5%.|r"
    }
},
{
    id = "spellLastStand",
    name = "buttonSpellLastStand",
    icon = "Interface/icons/spell_holy_ashestoashes",
    position = {718, -348},
    handler = "spelllaststand",
    tooltips = {
        frFR = "|cffffffffDernier rempart|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Activée, cette technique vous confère temporairement 30% de votre maximum de points de vie en plus pendant 20 secondes.\nLorsque l'effet expire, les points de vie sont perdus.|r",
        enUS = "|cffffffffLast Stand|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100When activated, this ability temporarily increases your maximum health by 30% for 20 seconds.\nOnce the effect expires, the health is lost.|r"
    }
},
{
    id = "spellImprovedRevenge",
    name = "buttonSpellImprovedRevenge",
    icon = "Interface/icons/ability_warrior_revenge",
    position = {825, -348},
    handler = "spellimprovedrevenge",
    tooltips = {
        frFR = "|cffffffffVengeance améliorée|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente les dégâts de votre technique Vengeance de 60% et permet à Vengeance de frapper une cible supplémentaire.|r",
        enUS = "|cffffffffImproved Revenge|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases the damage of your Revenge ability by 60% and allows Revenge to strike an additional target.|r"
    }
},
{
    id = "spellShieldMastery",
    name = "buttonSpellShieldMastery",
    icon = "Interface/icons/ability_warrior_shieldmastery",
    position = {935, -348},
    handler = "spellshieldmastery",
    tooltips = {
        frFR = "|cffffffffMaîtrise du bouclier|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente de 30% votre valeur de blocage et réduit de 20 sec.\nle temps de recharge de votre technique Maîtrise du blocage.|r",
        enUS = "|cffffffffShield Mastery|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases your block value by 30% and reduces the cooldown of your Shield Block ability by 20 seconds.|r"
    }
},
{
    id = "spellToughness",
    name = "buttonSpellToughness",
    icon = "Interface/icons/spell_holy_devotion",
    position = {1045, -348},
    handler = "spelltoughness",
    tooltips = {
        frFR = "|cffffffffRésistance|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente la valeur d'armure des objets de 10% et réduit la durée de tous les effets affectant le déplacement de 30%.|r",
        enUS = "|cffffffffToughness|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases your armor value by 10% and reduces the duration of all movement impairing effects by 30%.|r"
    }
},
{
    id = "spellImprovedSpellReflection",
    name = "buttonSpellImprovedSpellReflection",
    icon = "Interface/icons/ability_warrior_shieldreflection",
    position = {663, -402},
    handler = "spellimprovedspellreflection",
    tooltips = {
        frFR = "|cffffffffRenvoi de sort amélioré|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit la probabilité que vous soyez touché par les sorts de 4%,\net quand la technique est utilisée, elle renvoie le premier sort lancé contre les 4 membres du groupe les plus proches se trouvant à moins de 20 mètres.|r",
        enUS = "|cffffffffImproved Spell Reflection|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Reduces the chance to be hit by spells by 4%, and when used, reflects the first spell cast against the 4 nearest group members within 20 yards.|r"
    }
},
{
    id = "spellImprovedDisarm",
    name = "buttonSpellImprovedDisarm",
    icon = "Interface/icons/ability_warrior_disarm",
    position = {770, -402},
    handler = "spellimproveddisarm",
    tooltips = {
        frFR = "|cffffffffDésarmement amélioré|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit le temps de recharge de votre technique Désarmement de 20 secondes et fait subir à la cible 10% de dégâts supplémentaires quand elle est désarmée.|r",
        enUS = "|cffffffffImproved Disarm|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Reduces the cooldown of your Disarm ability by 20 seconds and causes the target to take 10% additional damage while disarmed.|r"
    }
},
{
    id = "spellPuncture",
    name = "buttonSpellPuncture",
    icon = "Interface/icons/ability_warrior_sunder",
    position = {880, -402},
    handler = "spellpuncture",
    tooltips = {
        frFR = "|cffffffffPercer|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit le coût en rage de vos techniques Fracasser armure et Dévaster de 3.|r",
        enUS = "|cffffffffPuncture|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Reduces the rage cost of your Sunder Armor and Devastate abilities by 3.|r"
    }
},
{
    id = "spellImprovedDisciplines",
    name = "buttonSpellImprovedDisciplines",
    icon = "Interface/icons/ability_warrior_shieldwall",
    position = {990, -402},
    handler = "spellimproveddisciplines",
    tooltips = {
        frFR = "|cffffffffDisciplines améliorées|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit le temps de recharge de vos techniques Mur protecteur, Représailles et Témérité de 60 sec.|r",
        enUS = "|cffffffffImproved Disciplines|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Reduces the cooldown of your Shield Wall, Retaliation, and Recklessness abilities by 60 seconds.|r"
    }
},
{
    id = "spellConcussionBlow",
    name = "buttonSpellConcussionBlow",
    icon = "Interface/icons/ability_thunderbolt",
    position = {1100, -402},
    handler = "spellconcussionblow",
    tooltips = {
        frFR = "|cffffffffCoup traumatisant|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Etourdit l'adversaire pendant 5 seconds et lui inflige 435 points de dégâts (en fonction de la puissance d'attaque).|r",
        enUS = "|cffffffffConcussion Blow|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Stuns the target for 5 seconds and deals 435 damage (based on attack power).|r"
    }
},
{
    id = "spellGagOrder",
    name = "buttonSpellGagOrder",
    icon = "Interface/icons/ability_warrior_shieldbash",
    position = {718, -456},
    handler = "spellgagorder",
    tooltips = {
        frFR = "|cffffffffImposition du silence|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Confère à vos techniques Coup de bouclier et Lancer héroïque 100% de chances de réduire la cible au silence pendant 3 seconds et augmente les dégâts de votre technique Heurt de bouclier de 10%.|r",
        enUS = "|cffffffffGag Order|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Grants your Shield Bash and Heroic Throw abilities a 100% chance to silence the target for 3 seconds, and increases the damage of your Shield Slam by 10%.|r"
    }
},
{
    id = "spellFear",
    name = "buttonSpellFear",
    icon = "Interface/icons/spell_shadow_possession",
    position = {825, -456},
    handler = "spellfear",
    tooltips = {
        frFR = "|cffffffffPeur|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Effraie un ennemi et l'oblige à fuir pendant 4 seconds.\nVous ne pouvez effrayer qu'une seule cible à la fois.|r",
        enUS = "|cffffffffFear|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Fears an enemy, causing them to flee for 4 seconds. You can only fear one target at a time.|r"
    }
},
{
    id = "spellImprovedDefensiveStance",
    name = "buttonSpellImprovedDefensiveStance",
    icon = "Interface/icons/ability_warrior_defensivestance",
    position = {935, -456},
    handler = "spellimproveddefensivestance",
    tooltips = {
        frFR = "|cffffffffPosture défensive améliorée|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Lorsque vous êtes en posture défensive, tous les dégâts des sorts sont réduits de 6% et lorsque vous parez, bloquez ou esquivez une attaque,\nvous avez 100% de chances d'enrager, ce qui augmente les dégâts physiques infligés de 10% pendant 12 secondes.|r",
        enUS = "|cffffffffImproved Defensive Stance|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100While in Defensive Stance, reduces all spell damage taken by 6%, and when you parry, block, or dodge an attack, you have a 100% chance to enrage, increasing physical damage dealt by 10% for 12 seconds.|r"
    }
},
{
    id = "spellVigilance",
    name = "buttonSpellVigilance",
    icon = "Interface/icons/ability_warrior_vigilance",
    position = {1045, -456},
    handler = "spellvigilance",
    tooltips = {
        frFR = "|cffffffffVigilance|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Focalise votre regard protecteur sur une cible appartenant au groupe ou raid, ce qui réduit les dégâts qu'elle subit de 3% et vous transfère -10% de la menace qu'elle génère.\nDe plus, chaque fois qu'elle est touchée par une attaque, le temps de recharge de votre Provocation prend fin.\nDure 30 mn.\nUne seule cible à la fois peut bénéficier de cet effet.|r",
        enUS = "|cffffffffVigilance|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Focuses your protective gaze on a target in your group or raid, reducing the damage they take by 3% and transferring -10% of the threat they generate to you.\nAdditionally, each time they are hit by an attack, your Taunt's cooldown will reset.\nLasts 30 minutes.\nOnly one target can benefit from this effect at a time.|r"
    }
},
{
    id = "spellFocusedRage",
    name = "buttonSpellFocusedRage",
    icon = "Interface/icons/ability_warrior_focusedrage",
    position = {663, -510},
    handler = "spellfocusedrage",
    tooltips = {
        frFR = "|cffffffffRage focalisée|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit le coût en rage de vos techniques offensives de 3.|r",
        enUS = "|cffffffffFocused Rage|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Reduces the rage cost of your offensive abilities by 3.|r"
    }
},
{
    id = "spellVitality",
    name = "buttonSpellVitality",
    icon = "Interface/icons/inv_helmet_21",
    position = {770, -510},
    handler = "spellvitality",
    tooltips = {
        frFR = "|cffffffffVitalité|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente votre total de Force de 6%, d'Endurance de 9% et votre expertise de 6.|r",
        enUS = "|cffffffffVitality|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases your Strength by 6%, Stamina by 9%, and Expertise by 6.|r"
    }
},
{
    id = "spellSafeguard",
    name = "buttonSpellSafeguard",
    icon = "Interface/icons/ability_warrior_safeguard",
    position = {880, -510},
    handler = "spellsafeguard",
    tooltips = {
        frFR = "|cffffffffProtéger|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit les dégâts subis par la cible de votre technique Intervention de 30% pendant 6 seconds.|r",
        enUS = "|cffffffffSafeguard|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Reduces the damage taken by the target of your Intervention ability by 30% for 6 seconds.|r"
    }
},
{
    id = "spellWarbringer",
    name = "buttonSpellWarbringer",
    icon = "Interface/icons/ability_warrior_warbringer",
    position = {990, -510},
    handler = "spellwarbringer",
    tooltips = {
        frFR = "|cffffffffPorteguerre|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vos techniques Charge, Interception et Intervention sont à présent utilisables en combat et avec n'importe quelle posture.\nDe plus, Intervention dissipe tous les effets affectant le déplacement.|r",
        enUS = "|cffffffffWarbringer|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Your Charge, Intercept, and Intervention abilities can now be used in combat and in any stance.\nAdditionally, Intervention will dispel all movement-impairing effects.|r"
    }
},
{
    id = "spellDevastate",
    name = "buttonSpellDevastate",
    icon = "Interface/icons/inv_sword_11",
    position = {1100, -510},
    handler = "spelldevastate",
    tooltips = {
        frFR = "|cffffffffDévaster|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Fracasse l'armure de la cible, provoquant l'effet Fracasser armure.\nDe plus, inflige 120% des dégâts de l'arme plus 58 pour chaque Fracasser armure sur la cible.\nL'effet de fracassement d'armure peut être cumulé jusqu'à 5 fois.|r",
        enUS = "|cffffffffDevastate|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Sunder the target's armor, applying the Sunder Armor effect.\nAdditionally, deals 120% of weapon damage plus 58 for each Sunder Armor on the target.\nThe Sunder Armor effect can stack up to 5 times.|r"
    }
},
{
    id = "spellCriticalBlock",
    name = "buttonSpellCriticalBlock",
    icon = "Interface/icons/ability_warrior_criticalblock",
    position = {716, -564},
    handler = "spellcriticalblock",
    tooltips = {
        frFR = "|cffffffffBlocage critique|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vos blocages réussis ont 60% de chances de bloquer le double du montant normal.\nAugmente vos chances d'infliger un coup critique avec votre technique Heurt de bouclier de 15% supplémentaires.|r",
        enUS = "|cffffffffCritical Block|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Successful blocks have a 60% chance to block double the normal amount.\nIncreases your chance to critically strike with your Shield Slam ability by an additional 15%.|r"
    }
},
{
    id = "spellSwordandBoard",
    name = "buttonSpellSwordandBoard",
    icon = "Interface/icons/ability_warrior_swordandboard",
    position = {824, -564},
    handler = "spellswordandboard",
    tooltips = {
        frFR = "|cffffffffEpée et bouclier|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente les chances de coup critique de votre technique Dévaster de 15%, et quand votre technique Dévaster ou Vengeance inflige des dégâts,\nelle a 30% de chances de mettre fin au temps de recharge de votre technique Heurt de bouclier et de réduire son coût de 100% pendant 5 secondes.|r",
        enUS = "|cffffffffSword and Board|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Increases your chance to critically strike with Devastate by 15%, and when your Devastate or Revenge deals damage,\nit has a 30% chance to reset the cooldown of your Shield Slam and reduce its cost by 100% for 5 seconds.|r"
    }
},
{
    id = "spellDamageShield",
    name = "buttonSpellDamageShield",
    icon = "Interface/icons/inv_shield_31",
    position = {934, -564},
    handler = "spelldamageshield",
    tooltips = {
        frFR = "|cffffffffBouclier de dégâts|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Chaque fois qu'une attaque en mêlée vous inflige des dégâts ou que vous la bloquez, vous infligez un montant de dégâts égal à 20% de votre valeur de blocage.|r",
        enUS = "|cffffffffDamage Shield|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Whenever a melee attack hits you or you block it, you deal damage equal to 20% of your block value.|r"
    }
},
{
    id = "spellShockwave",
    name = "buttonSpellShockwave",
    icon = "Interface/icons/ability_warrior_shockwave",
    position = {1045, -564},
    handler = "spellshockwave",
    tooltips = {
        frFR = "|cffffffffOnde de choc|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Projette une onde de force devant le guerrier, qui inflige 879 points de dégâts (en fonction de la puissance d'attaque)\net étourdit toutes les cibles ennemies se trouvant à moins de 10 mètres dans un cône devant lui pendant 4 secondes.|r",
        enUS = "|cffffffffShockwave|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequires|r |cffc79c6eWarrior|r\n|cffffd100Sends a wave of force in front of the warrior, dealing 879 damage (based on attack power)\nand stunning all enemies within 10 yards in front of the warrior for 4 seconds.|r"
		}
	}
}

-- CreateSpellButton("buttonSpellBloodsurge", "Interface/icons/ability_warrior_bloodsurge", "|cffffffffAfflux sanguin|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vos coups réussis avec Frappe héroïque, Sanguinaire et Tourbillon ont 20% de chances de rendre votre prochain Heurtoir instantané pendant 5 secondes.|r", "spellbloodsurge", 718, -240)
-- CreateSpellButton("buttonSpellUnendingFury", "Interface/icons/ability_warrior_intensifyrage", "|cffffffffFureur sans fin|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente les dégâts infligés par vos techniques Heurtoir, Tourbillon et Sanguinaire de 10%.|r", "spellunendingfury", 825, -240)
-- CreateSpellButton("buttonSpellTitansGrip", "Interface/icons/ability_warrior_titansgrip", "|cffffffffPoigne du titan|r\n|cffffffffTalent|r |cff9e604eFureur|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vous permet de manier les haches, les masses et les épées à deux mains d’une seule main.\nLorsque vous portez une arme à deux mains d'une seule main, les dégâts physiques que vous infligez sont réduits de 10%.|r", "spelltitansgrip", 935, -240)
-- CreateSpellButton("buttonSpellImprovedBloodrage", "Interface/icons/ability_racial_bloodrage", "|cffffffffRage sanguinaire améliorée|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente la rage instantanée générée par votre technique Rage sanguinaire de 50%.|r", "spellimprovedbloodrage", 1045, -240)
-- CreateSpellButton("buttonSpellShieldSpecialization", "Interface/icons/inv_shield_06", "|cffffffffSpécialisation Bouclier|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente de 5% vos chances de bloquer les attaques avec un bouclier, avec 100% de chances de générer 5 points de Rage quand vous bloquez, esquivez ou parez.|r", "spellshieldspecialization", 663, -293)
-- CreateSpellButton("buttonSpellImprovedThunderClap", "Interface/icons/ability_thunderclap", "|cffffffffCoup de tonnerre amélioré|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit le coût de votre technique Coup de tonnerre de 4 points de rage et augmente les dégâts de 30% et l'effet de ralentissement de 10% supplémentaires.|r", "spellimprovedthunderclap", 770, -293)
-- CreateSpellButton("buttonSpellIncite", "Interface/icons/ability_warrior_incite", "|cffffffffEmulation|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente de 15% vos chances de réaliser un coup critique avec les techniques Frappe héroïque, Coup de tonnerre et Enchaînement.|r", "spellincite", 990, -293)
-- CreateSpellButton("buttonSpellAnticipation", "Interface/icons/spell_nature_mirrorimage", "|cffffffffAnticipation|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente vos chances d'esquiver une attaque de 5%.|r", "spellanticipation", 1100, -293)
-- CreateSpellButton("buttonSpellLastStand", "Interface/icons/spell_holy_ashestoashes", "|cffffffffDernier rempart|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Activée, cette technique vous confère temporairement 30% de votre maximum de points de vie en plus pendant 20 secondes.\nLorsque l'effet expire, les points de vie sont perdus.|r", "spelllaststand", 718, -348)
-- CreateSpellButton("buttonSpellImprovedRevenge", "Interface/icons/ability_warrior_revenge", "|cffffffffVengeance améliorée|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente les dégâts de votre technique Vengeance de 60% et permet à Vengeance de frapper une cible supplémentaire.|r", "spellimprovedrevenge", 825, -348)
-- CreateSpellButton("buttonSpellShieldMastery", "Interface/icons/ability_warrior_shieldmastery", "|cffffffffMaîtrise du bouclier|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente de 30% votre valeur de blocage et réduit de 20 sec.\nle temps de recharge de votre technique Maîtrise du blocage.|r", "spellshieldmastery", 935, -348)
-- CreateSpellButton("buttonSpellToughness", "Interface/icons/spell_holy_devotion", "|cffffffffRésistance|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente la valeur d'armure des objets de 10% et réduit la durée de tous les effets affectant le déplacement de 30%.|r", "spelltoughness", 1045, -348)
-- CreateSpellButton("buttonSpellImprovedSpellReflection", "Interface/icons/ability_warrior_shieldreflection", "|cffffffffRenvoi de sort amélioré|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit la probabilité que vous soyez touché par les sorts de 4%,\net quand la technique est utilisée, elle renvoie le premier sort lancé contre les 4 membres du groupe les plus proches se trouvant à moins de 20 mètres.|r", "spellimprovedspellreflection", 663, -402)
-- CreateSpellButton("buttonSpellImprovedDisarm", "Interface/icons/ability_warrior_disarm", "|cffffffffDésarmement amélioré|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit le temps de recharge de votre technique Désarmement de 20 secondes et fait subir à la cible 10% de dégâts supplémentaires quand elle est désarmée.|r", "spellimproveddisarm", 770, -402)
-- CreateSpellButton("buttonSpellPuncture", "Interface/icons/ability_warrior_sunder", "|cffffffffPercer|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit le coût en rage de vos techniques Fracasser armure et Dévaster de 3.|r", "spellpuncture", 880, -402)
-- CreateSpellButton("buttonSpellImprovedDisciplines", "Interface/icons/ability_warrior_shieldwall", "|cffffffffDisciplines améliorées|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit le temps de recharge de vos techniques Mur protecteur, Représailles et Témérité de 60 sec.|r", "spellimproveddisciplines", 990, -402)
-- CreateSpellButton("buttonSpellConcussionBlow", "Interface/icons/ability_thunderbolt", "|cffffffffCoup traumatisant|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Etourdit l'adversaire pendant 5 seconds et lui inflige 435 points de dégâts (en fonction de la puissance d'attaque).|r", "spellconcussionblow", 1100, -402)
-- CreateSpellButton("buttonSpellGagOrder", "Interface/icons/ability_warrior_shieldbash", "|cffffffffImposition du silence|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Confère à vos techniques Coup de bouclier et Lancer héroïque 100% de chances de réduire la cible au silence pendant 3 seconds et augmente les dégâts de votre technique Heurt de bouclier de 10%.|r", "spellgagorder", 718, -456)
-- CreateSpellButton("buttonSpellFear", "Interface/icons/spell_shadow_possession", "|cffffffffPeur|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Effraie un ennemi et l'oblige à fuir pendant 4 seconds.\nVous ne pouvez effrayer qu'une seule cible à la fois.|r", "spellfear", 825, -456)
-- CreateSpellButton("buttonSpellImprovedDefensiveStance", "Interface/icons/ability_warrior_defensivestance", "|cffffffffPosture défensive améliorée|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Lorsque vous êtes en posture défensive, tous les dégâts des sorts sont réduits de 6% et lorsque vous parez, bloquez ou esquivez une attaque,\nvous avez 100% de chances d'enrager, ce qui augmente les dégâts physiques infligés de 10% pendant 12 secondes.|r", "spellimproveddefensivestance", 935, -456)
-- CreateSpellButton("buttonSpellVigilance", "Interface/icons/ability_warrior_vigilance", "|cffffffffVigilance|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Focalise votre regard protecteur sur une cible appartenant au groupe ou raid, ce qui réduit les dégâts qu'elle subit de 3% et vous transfère -10% de la menace qu'elle génère.\nDe plus, chaque fois qu'elle est touchée par une attaque, le temps de recharge de votre Provocation prend fin.\nDure 30 mn.\nUne seule cible à la fois peut bénéficier de cet effet.|r", "spellvigilance", 1045, -456)
-- CreateSpellButton("buttonSpellFocusedRage", "Interface/icons/ability_warrior_focusedrage", "|cffffffffRage focalisée|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit le coût en rage de vos techniques offensives de 3.|r", "spellfocusedrage", 663, -510)
-- CreateSpellButton("buttonSpellVitality", "Interface/icons/inv_helmet_21", "|cffffffffVitalité|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente votre total de Force de 6%, d'Endurance de 9% et votre expertise de 6.|r", "spellvitality", 770, -510)
-- CreateSpellButton("buttonSpellSafeguard", "Interface/icons/ability_warrior_safeguard", "|cffffffffProtéger|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Réduit les dégâts subis par la cible de votre technique Intervention de 30% pendant 6 seconds.|r", "spellsafeguard", 880, -510)
-- CreateSpellButton("buttonSpellWarbringer", "Interface/icons/ability_warrior_warbringer", "|cffffffffPorteguerre|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vos techniques Charge, Interception et Intervention sont à présent utilisables en combat et avec n'importe quelle posture.\nDe plus, Intervention dissipe tous les effets affectant le déplacement.|r", "spellwarbringer", 990, -510)
-- CreateSpellButton("buttonSpellDevastate", "Interface/icons/inv_sword_11", "|cffffffffDévaster|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Fracasse l'armure de la cible, provoquant l'effet Fracasser armure.\nDe plus, inflige 120% des dégâts de l'arme plus 58 pour chaque Fracasser armure sur la cible.\nL'effet de fracassement d'armure peut être cumulé jusqu'à 5 fois.|r", "spelldevastate", 1100, -510)
-- CreateSpellButton("buttonSpellCriticalBlock", "Interface/icons/ability_warrior_criticalblock", "|cffffffffBlocage critique|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Vos blocages réussis ont 60% de chances de bloquer le double du montant normal.\nAugmente vos chances d'infliger un coup critique avec votre technique Heurt de bouclier de 15% supplémentaires.|r", "spellcriticalblock", 716, -564)
-- CreateSpellButton("buttonSpellSwordandBoard", "Interface/icons/ability_warrior_swordandboard", "|cffffffffEpée et bouclier|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Augmente les chances de coup critique de votre technique Dévaster de 15%, et quand votre technique Dévaster ou Vengeance inflige des dégâts,\nelle a 30% de chances de mettre fin au temps de recharge de votre technique Heurt de bouclier et de réduire son coût de 100% pendant 5 secondes.|r", "spellswordandboard", 824, -564)
-- CreateSpellButton("buttonSpellDamageShield", "Interface/icons/inv_shield_31", "|cffffffffBouclier de dégâts|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Chaque fois qu'une attaque en mêlée vous inflige des dégâts ou que vous la bloquez, vous infligez un montant de dégâts égal à 20% de votre valeur de blocage.|r", "spelldamageshield", 934, -564)
-- CreateSpellButton("buttonSpellShockwave", "Interface/icons/ability_warrior_shockwave", "|cffffffffOnde de choc|r\n|cffffffffTalent|r |cff03c0cfProtection|r\n|cffffffffRequiert|r |cffc79c6eGuerrier|r\n|cffffd100Projette une onde de force devant le guerrier, qui inflige 879 points de dégâts (en fonction de la puissance d'attaque)\net étourdit toutes les cibles ennemies se trouvant à moins de 10 mètres dans un cône devant lui pendant 4 secondes.|r", "spellshockwave", 1045, -564)

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

-- Créez le bouton Save à l'intérieur de la fenêtre frameTalentWarrior
local saveButton = CreateFrame("Button", "saveButton", frameTalentWarrior, "UIPanelButtonTemplate")
saveButton:SetSize(85, 25)
saveButton:SetPoint("BOTTOMRIGHT", buttonTalentWarriorClose, "BOTTOMLEFT", -185, 5) -- Place le bouton Save à gauche du bouton Close
saveButton:SetText(saveButtonText)

-- Fonction qui prend un screenshot quand le bouton est cliqué
saveButton:SetScript("OnClick", function()
    Screenshot()  -- Prendre un screenshot et l'enregistrer dans le dossier Screenshots du jeu
    print(screenshotMessage)  -- Affiche un message de confirmation en fonction de la locale
end)

-- Affiche l'UI des talents
--frameTalentWarrior:Show()

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

-- Créez le bouton Reset à l'intérieur de la fenêtre frameTalentWarrior
local buttonReset = CreateFrame("Button", "buttonReset", frameTalentWarrior, "UIPanelButtonTemplate")
buttonReset:SetSize(85, 25)
buttonReset:SetPoint("BOTTOMRIGHT", buttonTalentWarriorClose, "BOTTOMLEFT", -95, 5) -- Place le bouton Reset à gauche du bouton Reload
buttonReset:SetText(buttonResetText)

local function ResetTalents()
    -- Ajoutez ici la logique pour réinitialiser les talents du joueur
    AIO.Handle("TalentWarriorspell", "ResetTalents")
    resetButtonClicked = true -- Marquez le bouton Réinitialiser comme cliqué
end

buttonReset:SetScript("OnClick", ResetTalents)

-- Créez le bouton Reload à l'intérieur de la fenêtre frameTalentWarrior
local buttonReload = CreateFrame("Button", "buttonReload", frameTalentWarrior, "UIPanelButtonTemplate")
buttonReload:SetSize(85, 25)
buttonReload:SetPoint("BOTTOMRIGHT", buttonTalentWarriorClose, "BOTTOMLEFT", -5, 5) -- Place le bouton Reload à gauche du bouton Close
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
        frameTalentWarrior:Hide()
        buttonReload:Hide()
        PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
    else
        frameTalentWarrior:Show()
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
        frFR = "|cffffffffTalents|r |cffc79c6e(Guerrier)|r\n\nL'éventail des talents disponibles\npour améliorer et spécialiser\nvotre personnage.",
        enUS = "|cffffffffTalents|r |cffc79c6e(Warrior)|r\n\nThe range of available talents\nfor enhancing and specializing\nyour character."
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

-- Vérifier si le joueur est un Warrior avant de créer le bouton
local playerClass = select(2, UnitClass("player")) -- Obtenir la classe du joueur
if playerClass == "WARRIOR" then
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
WarriorHandlers.UpdateTalentCount = function(player, talentsAppris)
    if fontTalentWarriorFrameText then
        fontTalentWarriorFrameText:SetText(talentsAppris .. " / " .. MAX_TALENTS)
    end
end

-- Mise à jour des points de talent utilisés avec texte localisé
WarriorHandlers.UpdateTalentPointsUsed = function(player, pointsUsed, pointsBeforeReset)
    -- Utilisation du texte localisé pour les points avant réinitialisation
    print(string.format(GetLocalizedPointsBeforeResetText(), pointsBeforeReset))
end

-- Affichage des talents restants (items 338404 dans le sac)
WarriorHandlers.UpdateTalentItemCount = function(player, count)
    if fontTalentPointsRemainingText then
        fontTalentPointsRemainingText:SetText("|cFFC79C6ETalents restants : " .. count .. "|r")
    end
end

-------------------------------------------------------------
--  CORRECTION : mise à jour automatique quand le sac change
-- BAG_UPDATE se déclenche à chaque ajout/retrait d'item dans l'inventaire
-- On utilise GetItemCount() côté client directement, sans aller/retour serveur
-------------------------------------------------------------
local TALENT_ITEM_ID = 338404

local function UpdateTalentCountFromBag()
    local count = GetItemCount(TALENT_ITEM_ID, false, true)
    if fontTalentPointsRemainingText then
        fontTalentPointsRemainingText:SetText("|cFFC79C6ETalents restants : " .. (count or 0) .. "|r")
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
if playerClass == "WARRIOR" then
    -- Surcharge OnHide pour synchroniser talentsWindowOpen quand Échap est pressé
    local _originalOnHide = frameTalentWarrior:GetScript("OnHide")
    frameTalentWarrior:SetScript("OnHide", function(self)
        talentsWindowOpen = false
        if _originalOnHide then _originalOnHide(self) end
    end)
    -- WoW appelle automatiquement Hide() sur les frames listées ici quand Échap est pressé
    tinsert(UISpecialFrames, "frameTalentWarrior")
end