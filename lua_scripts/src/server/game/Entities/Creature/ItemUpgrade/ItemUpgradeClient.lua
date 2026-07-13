-- ItemUpgradeClient.lua - Version simplifiée (palier à palier)
local AIO = AIO or require("AIO")
if AIO.AddAddon() then return end

local ItemUpgradeHandlers = AIO.AddHandlers("ItemUpgrade", {})

local OPEN_TALENT_WINDOW_SOUND = "Sound\\INTERFACE\\UI_Transmogrify_Apply.OGG"
local CLOSE_TALENT_WINDOW_SOUND = "Sound\\INTERFACE\\UI_VoidStorage_Undo.OGG"
local REFORGING_TALENT_WINDOW_SOUND = "Sound\\INTERFACE\\ui_reforging_reforge.ogg"

-- Variables globales
local mainFrame = nil
local selectedItem = nil
local itemSlot = nil
local currentData = {}
local nextData = {}

-- Fonction pour créer le cadre principal
local function CreateMainFrame()
    if mainFrame then return end
	
	-- Frame principale
    mainFrame = CreateFrame("Frame", "ItemUpgradeFrame", UIParent)
    mainFrame:SetSize(512, 512)
    mainFrame:SetPoint("CENTER", 0, 0)
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
    mainFrame:SetFrameStrata("DIALOG")
    mainFrame:Hide()

    -- Fermeture via la touche Echap
    tinsert(UISpecialFrames, "ItemUpgradeFrame")

    -- Nettoyage à chaque fermeture (bouton ET touche Echap)
    mainFrame:SetScript("OnHide", function()
        PlaySoundFile(CLOSE_TALENT_WINDOW_SOUND)
    end)
	
	-- Background texture
    local bg = mainFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(mainFrame)
    bg:SetTexture("Interface/ItemUpgrade/ItemUpgradeTemplate")
    
    -- Titre du cadre
    mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    mainFrame.title:SetPoint("TOP", mainFrame, "TOP", 12, -12)
    mainFrame.title:SetText("Amélioration d'objet")
    
    -- Slot pour l'item
    itemSlot = CreateFrame("Button", "ItemUpgradeSlot", mainFrame)
    itemSlot:SetSize(72, 72)
    itemSlot:SetPoint("TOP", mainFrame, "TOP", 0, -38)
    itemSlot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    
    -- Texture de fond (slot vide)
    itemSlot.bg = itemSlot:CreateTexture(nil, "BACKGROUND")
    itemSlot.bg:SetAllPoints()
    itemSlot.bg:SetTexture("Interface\\Buttons\\UI-EmptySlot")
    
    -- Icône de l'item par-dessus
    itemSlot.icon = itemSlot:CreateTexture(nil, "ARTWORK")
    itemSlot.icon:SetSize(42, 42)
    itemSlot.icon:SetPoint("CENTER")
    itemSlot.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    itemSlot.icon:Hide()
    
    -- Tooltip pour le slot
    itemSlot:SetScript("OnEnter", function(self)
        if selectedItem then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink("item:" .. selectedItem)
            GameTooltip:Show()
        end
    end)
    
    itemSlot:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    itemSlot:SetScript("OnReceiveDrag", function(self)
        local cursorType, itemID = GetCursorInfo()
        if cursorType == "item" then
            ClearCursor()
            AIO.Handle("ItemUpgrade", "SelectItem", itemID)
        end
    end)
    
    itemSlot:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            local cursorType, itemID = GetCursorInfo()
            if cursorType == "item" then
                ClearCursor()
                AIO.Handle("ItemUpgrade", "SelectItem", itemID)
            end
        elseif button == "RightButton" then
            selectedItem = nil
            itemSlot.icon:Hide()
            ClearItemInfo()
        end
    end)
    
    -- Nom de l'item sous le slot
    mainFrame.itemName = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    mainFrame.itemName:SetPoint("TOP", itemSlot, "BOTTOM", 0, 5)
    mainFrame.itemName:SetWidth(300)
    mainFrame.itemName:SetWordWrap(true)
    mainFrame.itemName:SetJustifyH("CENTER")
    mainFrame.itemName:SetText("")
    mainFrame.itemName:SetTextColor(1, 1, 1)
    
    -- Section Current (Gauche)
    mainFrame.currentLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    mainFrame.currentLabel:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 100, -180)
    mainFrame.currentLabel:SetText("Actuel")
    
    mainFrame.currentTier = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainFrame.currentTier:SetPoint("TOPLEFT", mainFrame.currentLabel, "BOTTOMLEFT", -50, -50)
    mainFrame.currentTier:SetTextColor(1, 0.82, 0)
    mainFrame.currentTier:SetJustifyH("LEFT")
    
    mainFrame.currentItemName = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainFrame.currentItemName:SetPoint("TOPLEFT", mainFrame.currentTier, "BOTTOMLEFT", 0, -5)
    mainFrame.currentItemName:SetWidth(200)
    mainFrame.currentItemName:SetWordWrap(true)
    mainFrame.currentItemName:SetJustifyH("LEFT")
    mainFrame.currentItemName:SetTextColor(0.5, 1, 0.5)
    
    mainFrame.currentItemLevel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainFrame.currentItemLevel:SetPoint("TOPLEFT", mainFrame.currentItemName, "BOTTOMLEFT", 0, -3)
    mainFrame.currentItemLevel:SetTextColor(1, 0.82, 0)
    
    mainFrame.currentStats = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainFrame.currentStats:SetPoint("TOPLEFT", mainFrame.currentItemLevel, "BOTTOMLEFT", 0, -10)
    mainFrame.currentStats:SetJustifyH("LEFT")
    mainFrame.currentStats:SetWidth(200)
    
    -- Section Next Upgrade (Droite)
    mainFrame.nextLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    mainFrame.nextLabel:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -80, -180)
    mainFrame.nextLabel:SetText("Améliorer")
    mainFrame.nextLabel:SetJustifyH("LEFT")
    
    mainFrame.nextTier = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainFrame.nextTier:SetPoint("TOPLEFT", mainFrame.nextLabel, "BOTTOMLEFT", -50, -50)
    mainFrame.nextTier:SetTextColor(1, 0.82, 0)
    mainFrame.nextTier:SetJustifyH("LEFT")
    
    mainFrame.nextItemName = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainFrame.nextItemName:SetPoint("TOPLEFT", mainFrame.nextTier, "BOTTOMLEFT", 0, -5)
    mainFrame.nextItemName:SetWidth(200)
    mainFrame.nextItemName:SetWordWrap(true)
    mainFrame.nextItemName:SetTextColor(0.5, 1, 0.5)
    mainFrame.nextItemName:SetJustifyH("LEFT")
    
    mainFrame.nextItemLevel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainFrame.nextItemLevel:SetPoint("TOPLEFT", mainFrame.nextItemName, "BOTTOMLEFT", 0, -3)
    mainFrame.nextItemLevel:SetTextColor(1, 0.82, 0)
    
    mainFrame.nextStats = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainFrame.nextStats:SetPoint("TOPLEFT", mainFrame.nextItemLevel, "BOTTOMLEFT", 0, -10)
    mainFrame.nextStats:SetJustifyH("LEFT")
    mainFrame.nextStats:SetWidth(200)
    
    -- Total Cost
    mainFrame.costText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    mainFrame.costText:SetPoint("BOTTOM", mainFrame, "BOTTOM", 0, 60)
	mainFrame.costText:SetText("Coût : 0 |TInterface\\MoneyFrame\\UI-GoldIcon:12:12:2:0|t")
    
    -- Bouton Améliorer
    mainFrame.upgradeButton = CreateFrame("Button", "ItemUpgradeButton", mainFrame, "GameMenuButtonTemplate")
    mainFrame.upgradeButton:SetSize(180, 35)
    mainFrame.upgradeButton:SetPoint("BOTTOM", mainFrame, "BOTTOM", 0, 20)
    mainFrame.upgradeButton:SetText("Améliorer")
    mainFrame.upgradeButton:SetNormalFontObject("GameFontNormal")
    mainFrame.upgradeButton:SetHighlightFontObject("GameFontHighlight")
    mainFrame.upgradeButton:Hide()
    
    mainFrame.upgradeButton:SetScript("OnClick", function()
        if selectedItem then
            AIO.Handle("ItemUpgrade", "UpgradeTier", selectedItem)
        end
    end)
    
    -- Bouton de fermeture
	mainFrame.closeButton = CreateFrame("Button", nil, mainFrame)
	mainFrame.closeButton:SetSize(28, 28)
	mainFrame.closeButton:SetPoint("TOPRIGHT", 3, -5)
	mainFrame.closeButton:SetFrameLevel(mainFrame:GetFrameLevel() + 10)
	mainFrame.closeButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
	mainFrame.closeButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
	mainFrame.closeButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
	mainFrame.closeButton:SetScript("OnClick", function()
		mainFrame:Hide()
	end)
end

function ClearItemInfo()
    if not mainFrame then return end
    
    mainFrame.itemName:SetText("")
    mainFrame.currentTier:SetText("")
    mainFrame.currentItemName:SetText("")
    mainFrame.currentItemLevel:SetText("")
    mainFrame.currentStats:SetText("")
    mainFrame.nextTier:SetText("")
    mainFrame.nextItemName:SetText("")
    mainFrame.nextItemLevel:SetText("")
    mainFrame.nextStats:SetText("")
    mainFrame.costText:SetText("Coût : 0 |TInterface\\MoneyFrame\\UI-GoldIcon:12:12:2:0|t")
    mainFrame.upgradeButton:Hide()
    
    -- Réinitialiser les variables
    selectedItem = nil
    currentData = {}
    nextData = {}
end

-- Fonction pour formater les stats (VERSION COMPLÈTE)
local function FormatStats(stats)
    local statsText = ""
    local statsOrder = {
        -- Armure
        {key = "armor", name = "Armure"},
        
        -- Stats de base
        {key = "strength", name = "Force"},
        {key = "agility", name = "Agilité"},
        {key = "stamina", name = "Endurance"},
        {key = "intellect", name = "Intelligence"},
        {key = "spirit", name = "Esprit"},
        {key = "mana", name = "Mana"},
        {key = "health", name = "Points de vie"},
        
        -- Défense
        {key = "defenseRating", name = "Score de défense"},
		{key = "parryRating", name = "Score de parade"},
        {key = "dodgeRating", name = "Score d'esquive"},
        {key = "blockRating", name = "Score de blocage"},
        {key = "blockValue", name = "Valeur de blocage"},
        {key = "resilienceRating", name = "Score de résilience"},
		
		-- Sorts
        {key = "spellPower", name = "Puissance des sorts"},
        {key = "spellHealing", name = "Soins"},
        {key = "spellDamage", name = "Dégâts des sorts"},
        {key = "spellPenetration", name = "Pénétration des sorts"},
        {key = "manaRegen", name = "Régén. de mana"},
		
		-- Combat physique
        {key = "attackPower", name = "Puissance d'attaque"},
        {key = "rangedAttackPower", name = "Puissance d'attaque à distance"},
		
		-- Toucher
        {key = "hitMeleeRating", name = "Score de toucher (mêlée)"},
        {key = "hitRangedRating", name = "Score de toucher (distance)"},
        {key = "hitSpellRating", name = "Score de toucher (sort)"},
		
		-- Critique
        {key = "critRating", name = "Score de coup critique"},
		{key = "expertiseRating", name = "Score d'expertise"},
		{key = "hitRating", name = "Score de toucher"},
		{key = "armorPenRating", name = "Score de pénétration d'armure"},
        {key = "critMeleeRating", name = "Score de critique (mêlée)"},
        {key = "critRangedRating", name = "Score de critique (distance)"},
        {key = "critSpellRating", name = "Score de critique (sort)"},
		
		-- Hâte
        {key = "hasteRating", name = "Score de hâte"},
        {key = "hasteMeleeRating", name = "Score de hâte (mêlée)"},
        {key = "hasteRangedRating", name = "Score de hâte (distance)"},
        {key = "hasteSpellRating", name = "Score de hâte (sort)"},
        
        -- Régénération
        {key = "healthRegen", name = "Régén. de vie"},
        
        -- Ratings de défense contre attaques
        {key = "hitTakenRating", name = "Score de toucher reçu"},
        {key = "hitTakenMeleeRating", name = "Score de toucher reçu (mêlée)"},
        {key = "hitTakenRangedRating", name = "Score de toucher reçu (distance)"},
        {key = "hitTakenSpellRating", name = "Score de toucher reçu (sort)"},
        {key = "critTakenRating", name = "Score de critique reçu"},
        {key = "critTakenMeleeRating", name = "Score de critique reçu (mêlée)"},
        {key = "critTakenRangedRating", name = "Score de critique reçu (distance)"},
        {key = "critTakenSpellRating", name = "Score de critique reçu (sort)"},
        
        -- Maîtrise (Cataclysm+)
        {key = "masteryRating", name = "Score de maîtrise"}
    }
    
    for _, stat in ipairs(statsOrder) do
        local value = stats[stat.key] or 0
        
        if value > 0 then
            statsText = statsText .. string.format("|cFFFFFFFF%d|r %s\n", value, stat.name)
        end
    end
    
    return statsText
end

-- Fonction pour formater les stats avec différence
local function FormatStatsWithDiff(currentStats, nextStats)
    local statsText = ""
    local statsOrder = {
        -- Armure
        {key = "armor", name = "Armure"},
        
        -- Stats de base
        {key = "strength", name = "Force"},
        {key = "agility", name = "Agilité"},
        {key = "stamina", name = "Endurance"},
        {key = "intellect", name = "Intelligence"},
        {key = "spirit", name = "Esprit"},
        {key = "mana", name = "Mana"},
        {key = "health", name = "Points de vie"},
        
        -- Défense
        {key = "defenseRating", name = "Score de défense"},
		{key = "parryRating", name = "Score de parade"},
        {key = "dodgeRating", name = "Score d'esquive"},
        {key = "blockRating", name = "Score de blocage"},
        {key = "blockValue", name = "Valeur de blocage"},
        {key = "resilienceRating", name = "Score de résilience"},
		
		-- Sorts
        {key = "spellPower", name = "Puissance des sorts"},
        {key = "spellHealing", name = "Soins"},
        {key = "spellDamage", name = "Dégâts des sorts"},
        {key = "spellPenetration", name = "Pénétration des sorts"},
        {key = "manaRegen", name = "Régén. de mana"},
		
		-- Combat physique
        {key = "attackPower", name = "Puissance d'attaque"},
        {key = "rangedAttackPower", name = "Puissance d'attaque à distance"},
		
		-- Toucher
        {key = "hitMeleeRating", name = "Score de toucher (mêlée)"},
        {key = "hitRangedRating", name = "Score de toucher (distance)"},
        {key = "hitSpellRating", name = "Score de toucher (sort)"},
		
		-- Critique
        {key = "critRating", name = "Score de coup critique"},
		{key = "expertiseRating", name = "Score d'expertise"},
		{key = "hitRating", name = "Score de toucher"},
		{key = "armorPenRating", name = "Score de pénétration d'armure"},
        {key = "critMeleeRating", name = "Score de critique (mêlée)"},
        {key = "critRangedRating", name = "Score de critique (distance)"},
        {key = "critSpellRating", name = "Score de critique (sort)"},
		
		-- Hâte
        {key = "hasteRating", name = "Score de hâte"},
        {key = "hasteMeleeRating", name = "Score de hâte (mêlée)"},
        {key = "hasteRangedRating", name = "Score de hâte (distance)"},
        {key = "hasteSpellRating", name = "Score de hâte (sort)"},
        
        -- Régénération
        {key = "healthRegen", name = "Régén. de vie"},
        
        -- Ratings de défense contre attaques
        {key = "hitTakenRating", name = "Score de toucher reçu"},
        {key = "hitTakenMeleeRating", name = "Score de toucher reçu (mêlée)"},
        {key = "hitTakenRangedRating", name = "Score de toucher reçu (distance)"},
        {key = "hitTakenSpellRating", name = "Score de toucher reçu (sort)"},
        {key = "critTakenRating", name = "Score de critique reçu"},
        {key = "critTakenMeleeRating", name = "Score de critique reçu (mêlée)"},
        {key = "critTakenRangedRating", name = "Score de critique reçu (distance)"},
        {key = "critTakenSpellRating", name = "Score de critique reçu (sort)"},
        
        -- Maîtrise (Cataclysm+)
        {key = "masteryRating", name = "Score de maîtrise"}
    }
    
    for _, stat in ipairs(statsOrder) do
        local currentValue = currentStats[stat.key] or 0
        local nextValue = nextStats[stat.key] or 0
        
        if currentValue > 0 or nextValue > 0 then
            -- Affichage simple comme dans "Actuel"
            if nextValue > 0 then
                statsText = statsText .. string.format("|cFFFFFFFF%d|r %s\n", nextValue, stat.name)
            end
        end
    end
    
    return statsText
end

-- Handler pour afficher les informations de l'item
function ItemUpgradeHandlers.ShowItemInfo(player, current, next)
    if not mainFrame then return end
    
    selectedItem = current.entry
    currentData = current
    nextData = next
    
    -- Afficher l'icône de l'item
    local iconTexture = GetItemIcon(current.entry)
    if iconTexture then
        itemSlot.icon:SetTexture(iconTexture)
        itemSlot.icon:Show()
    end
    
    -- Nom de l'item principal
    local quality = current.quality or 0
    local r, g, b = GetItemQualityColor(quality)
    mainFrame.itemName:SetText(current.name)
    mainFrame.itemName:SetTextColor(r, g, b)
    
    -- Section ACTUEL (gauche)
    mainFrame.currentTier:SetText("Palier : " .. (current.tier or ""))
    mainFrame.currentItemName:SetText(current.name)
    mainFrame.currentItemName:SetTextColor(r, g, b)
    mainFrame.currentItemLevel:SetText("Niveau d'objet " .. (current.itemLevel or 0))
    mainFrame.currentStats:SetText(FormatStats(current))
    
    -- Section AMÉLIORER (droite)
    if next then
        local nextQuality = next.quality or 0
        local nextR, nextG, nextB = GetItemQualityColor(nextQuality)
        
        mainFrame.nextTier:SetText("Palier : " .. (next.tier or ""))
        mainFrame.nextItemName:SetText(next.name)
        mainFrame.nextItemName:SetTextColor(nextR, nextG, nextB)
        
        -- Affichage de l'item level sans différence
        mainFrame.nextItemLevel:SetText("Niveau d'objet " .. (next.itemLevel or 0))
        
        -- Stats simples comme dans "Actuel"
        mainFrame.nextStats:SetText(FormatStats(next))
        -- Coût
        local cost = next.cost or 0
        mainFrame.costText:SetText("Coût : " .. cost .. " |TInterface\\MoneyFrame\\UI-GoldIcon:12:12:2:0|t")
        
        -- Afficher le bouton
        mainFrame.upgradeButton:Show()
		PlaySoundFile(REFORGING_TALENT_WINDOW_SOUND)
    else
        -- Pas de palier suivant
        mainFrame.nextTier:SetText("Palier maximum")
        mainFrame.nextItemName:SetText("")
        mainFrame.nextItemLevel:SetText("")
        mainFrame.nextStats:SetText("")
        mainFrame.costText:SetText("")
        mainFrame.upgradeButton:Hide()
    end
end

-- Handler pour ouvrir/fermer le cadre
function ItemUpgradeHandlers.ToggleFrame(player)
    CreateMainFrame()
    
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
		PlaySoundFile(OPEN_TALENT_WINDOW_SOUND) -- Jouer le son quand on réouvre
    end
end

-- Handler pour afficher un message
function ItemUpgradeHandlers.ShowMessage(player, message)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[Amélioration d'objet]|r " .. message)
end

-- Commande slash pour ouvrir le cadre
--SLASH_ITEMUPGRADE1 = "/itemupgrade"
--SLASH_ITEMUPGRADE2 = "/iup"
--SlashCmdList["ITEMUPGRADE"] = function(msg)
--    AIO.Handle("ItemUpgrade", "OpenFrame")
--end

--print("|cFF00FF00ItemUpgradeClient chargé ! Utilisez /itemupgrade ou /iup pour ouvrir.|r")