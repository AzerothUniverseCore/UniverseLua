-- ItemUpgradeServer.lua - Version complète avec toutes les stats
local AIO = AIO or require("AIO")

local ItemUpgradeHandlers = AIO.AddHandlers("ItemUpgrade", {})

-- Détermine la langue du compte du joueur (0 = enUS, sinon frFR)
local function GetPlayerLocale(player)
    local ok, result = pcall(function()
        local accountId = player:GetAccountId()
        local q = AuthDBQuery("SELECT locale FROM account WHERE id = " .. accountId .. ";")
        if q then
            local localeId = q:GetUInt8(0)
            if localeId == 0 then
                return "enUS"
            end
        end
        return "frFR"
    end)
    if ok and result then
        return result
    end
    return "frFR"
end

local ItemUpgradeNotif = {
    frFR = {
        CANT_UPGRADE = "Cet objet ne peut pas être amélioré !",
        ITEM_NOT_IN_BAGS = "Objet introuvable dans votre inventaire !",
        GEAR_ONLY = "Vous ne pouvez améliorer que des équipements !",
        LOAD_ERROR = "Erreur lors du chargement des données !",
        ALREADY_MAX_TIER = "Cet objet est déjà au palier maximum !",
        ITEM_NOT_FOUND = "Objet introuvable !",
        NOT_ENOUGH_GOLD = "Vous n\226\128\153avez pas assez de pièces d\226\128\153or ! %d pièces d\226\128\153or sont requises pour passer au palier suivant.",
        ALREADY_OWN_UNIQUE = "Vous possédez déjà l\226\128\153équipement unique.",
        UPGRADE_SUCCESS = "Équipement amélioré en %s ! (Coût : %d Pièces d'or)",
    },
    enUS = {
        CANT_UPGRADE = "This item cannot be upgraded!",
        ITEM_NOT_IN_BAGS = "Item not found in your inventory!",
        GEAR_ONLY = "You can only upgrade gear!",
        LOAD_ERROR = "Error while loading data!",
        ALREADY_MAX_TIER = "This item is already at the maximum tier!",
        ITEM_NOT_FOUND = "Item not found!",
        NOT_ENOUGH_GOLD = "You don't have enough gold! %d gold is required to upgrade to the next tier.",
        ALREADY_OWN_UNIQUE = "You already own this unique piece of gear.",
        UPGRADE_SUCCESS = "Gear upgraded to %s! (Cost: %d gold)",
    },
}

local function L(player)
    return ItemUpgradeNotif[GetPlayerLocale(player)] or ItemUpgradeNotif.frFR
end

-- Configuration
local TIER_UPGRADE_COST = 5000 * 10000 -- 5000 gold pour passer au palier suivant

-- Cache pour les données d'upgrade custom
local customItemCache = {}

-- Fonction pour charger les infos d'un item custom depuis la DB
local function LoadCustomItemInfo(itemEntry)
    -- Vérifier le cache
    if customItemCache[itemEntry] then
        return customItemCache[itemEntry]
    end
    
    local query = WorldDBQuery(string.format(
        "SELECT item_id, tier, next_tier_item_id FROM item_upgrade_custom WHERE item_id = %d",
        itemEntry
    ))
    
    if not query then
        return nil
    end
    
    local itemInfo = {
        itemId = query:GetUInt32(0),
        tier = query:GetString(1),
        nextTierItemId = query:GetUInt32(2)
    }
    
    -- Mettre en cache
    customItemCache[itemEntry] = itemInfo
    
    return itemInfo
end

-- Fonction pour obtenir les stats d'un item depuis item_template
local function GetItemStatsFromTemplate(itemEntry)
    local stats = {}
    
    local query = WorldDBQuery(string.format([[
        SELECT stat_type1, stat_value1, stat_type2, stat_value2, 
               stat_type3, stat_value3, stat_type4, stat_value4,
               stat_type5, stat_value5, stat_type6, stat_value6,
               stat_type7, stat_value7, stat_type8, stat_value8,
               stat_type9, stat_value9, stat_type10, stat_value10,
               armor
        FROM item_template WHERE entry = %d
    ]], itemEntry))
    
    if not query then return stats end
    
    for i = 0, 9 do
        local statType = query:GetUInt32(i * 2)
        local statValue = query:GetInt32(i * 2 + 1)
        
        if statValue > 0 then
            -- Stats de base
            if statType == 0 then stats.mana = statValue
            elseif statType == 1 then stats.health = statValue
            elseif statType == 3 then stats.agility = statValue
            elseif statType == 4 then stats.strength = statValue
            elseif statType == 5 then stats.intellect = statValue
            elseif statType == 6 then stats.spirit = statValue
            elseif statType == 7 then stats.stamina = statValue
            
            -- Ratings de défense
            elseif statType == 12 then stats.defenseRating = statValue
            elseif statType == 13 then stats.dodgeRating = statValue
            elseif statType == 14 then stats.parryRating = statValue
            elseif statType == 15 then stats.blockRating = statValue
            
            -- Ratings de toucher (mêlée, distance, sort)
            elseif statType == 16 then stats.hitMeleeRating = statValue
            elseif statType == 17 then stats.hitRangedRating = statValue
            elseif statType == 18 then stats.hitSpellRating = statValue
            elseif statType == 31 then stats.hitRating = statValue
            
            -- Ratings de critique (mêlée, distance, sort)
            elseif statType == 19 then stats.critMeleeRating = statValue
            elseif statType == 20 then stats.critRangedRating = statValue
            elseif statType == 21 then stats.critSpellRating = statValue
            elseif statType == 32 then stats.critRating = statValue
            
            -- Ratings de toucher reçu (défense)
            elseif statType == 22 then stats.hitTakenMeleeRating = statValue
            elseif statType == 23 then stats.hitTakenRangedRating = statValue
            elseif statType == 24 then stats.hitTakenSpellRating = statValue
            elseif statType == 33 then stats.hitTakenRating = statValue
            
            -- Ratings de critique reçu (défense)
            elseif statType == 25 then stats.critTakenMeleeRating = statValue
            elseif statType == 26 then stats.critTakenRangedRating = statValue
            elseif statType == 27 then stats.critTakenSpellRating = statValue
            elseif statType == 34 then stats.critTakenRating = statValue
            
            -- Ratings de hâte (mêlée, distance, sort)
            elseif statType == 28 then stats.hasteMeleeRating = statValue
            elseif statType == 29 then stats.hasteRangedRating = statValue
            elseif statType == 30 then stats.hasteSpellRating = statValue
            elseif statType == 36 then stats.hasteRating = statValue
            
            -- Stats de combat
            elseif statType == 35 then stats.resilienceRating = statValue
            elseif statType == 37 then stats.expertiseRating = statValue
            elseif statType == 38 then stats.attackPower = statValue
            elseif statType == 39 then stats.rangedAttackPower = statValue
            
            -- Stats de sorts (deprecated mais toujours présentes)
            elseif statType == 41 then stats.spellHealing = statValue
            elseif statType == 42 then stats.spellDamage = statValue
            elseif statType == 45 then stats.spellPower = statValue
            
            -- Stats diverses
            elseif statType == 43 then stats.manaRegen = statValue
            elseif statType == 44 then stats.armorPenRating = statValue
            elseif statType == 46 then stats.healthRegen = statValue
            elseif statType == 47 then stats.spellPenetration = statValue
            elseif statType == 48 then stats.blockValue = statValue
            elseif statType == 49 then stats.masteryRating = statValue
            end
        end
    end
    
    stats.armor = query:GetUInt32(20)
    
    return stats
end

-- Handler pour ouvrir le cadre
function ItemUpgradeHandlers.OpenFrame(player)
    AIO.Handle(player, "ItemUpgrade", "ToggleFrame")
end

-- Handler pour sélectionner un item
function ItemUpgradeHandlers.SelectItem(player, itemEntry)
    local customInfo = LoadCustomItemInfo(itemEntry)
    
    if not customInfo then
        AIO.Handle(player, "ItemUpgrade", "ShowMessage", L(player).CANT_UPGRADE)
        return
    end
    
    local item = player:GetItemByEntry(itemEntry)
    
    if not item then
        AIO.Handle(player, "ItemUpgrade", "ShowMessage", L(player).ITEM_NOT_IN_BAGS)
        return
    end
    
    local itemClass = item:GetClass()
    if itemClass ~= 2 and itemClass ~= 4 then
        AIO.Handle(player, "ItemUpgrade", "ShowMessage", L(player).GEAR_ONLY)
        return
    end
    
    -- Récupérer les infos de l'item ACTUEL
    local query = WorldDBQuery(string.format(
        "SELECT name, Quality, ItemLevel FROM item_template WHERE entry = %d",
        itemEntry
    ))
    
    if not query then
        AIO.Handle(player, "ItemUpgrade", "ShowMessage", L(player).LOAD_ERROR)
        return
    end
    
    local itemName = query:GetString(0)
    local itemQuality = query:GetUInt32(1)
    local itemLevel = query:GetUInt32(2)
    
    -- Récupérer le nom traduit en français (uniquement pour les joueurs frFR :
    -- item_template contient déjà le nom anglais de base pour les joueurs enUS)
    if GetPlayerLocale(player) == "frFR" then
        local localeQuery = WorldDBQuery(string.format(
            "SELECT Name FROM item_template_locale WHERE ID = %d AND locale = 'frFR'",
            itemEntry
        ))
        
        if localeQuery then
            local localeName = localeQuery:GetString(0)
            if localeName and localeName ~= "" then
                itemName = localeName
            end
        end
    end
    
    -- Stats actuelles
    local currentStats = GetItemStatsFromTemplate(itemEntry)
    
    -- Données de l'item ACTUEL (toutes les stats)
    local currentData = {
        entry = itemEntry,
        name = itemName,
        quality = itemQuality,
        itemLevel = itemLevel,
        tier = customInfo.tier,
        
        -- Armure
        armor = currentStats.armor or 0,
        
        -- Stats de base
        mana = currentStats.mana or 0,
        health = currentStats.health or 0,
        agility = currentStats.agility or 0,
        strength = currentStats.strength or 0,
        intellect = currentStats.intellect or 0,
        spirit = currentStats.spirit or 0,
        stamina = currentStats.stamina or 0,
        
        -- Ratings de défense
        defenseRating = currentStats.defenseRating or 0,
        dodgeRating = currentStats.dodgeRating or 0,
        parryRating = currentStats.parryRating or 0,
        blockRating = currentStats.blockRating or 0,
        blockValue = currentStats.blockValue or 0,
        
        -- Ratings de toucher
        hitMeleeRating = currentStats.hitMeleeRating or 0,
        hitRangedRating = currentStats.hitRangedRating or 0,
        hitSpellRating = currentStats.hitSpellRating or 0,
        hitRating = currentStats.hitRating or 0,
        
        -- Ratings de critique
        critMeleeRating = currentStats.critMeleeRating or 0,
        critRangedRating = currentStats.critRangedRating or 0,
        critSpellRating = currentStats.critSpellRating or 0,
        critRating = currentStats.critRating or 0,
        
        -- Ratings de toucher reçu (défense)
        hitTakenMeleeRating = currentStats.hitTakenMeleeRating or 0,
        hitTakenRangedRating = currentStats.hitTakenRangedRating or 0,
        hitTakenSpellRating = currentStats.hitTakenSpellRating or 0,
        hitTakenRating = currentStats.hitTakenRating or 0,
        
        -- Ratings de critique reçu (défense)
        critTakenMeleeRating = currentStats.critTakenMeleeRating or 0,
        critTakenRangedRating = currentStats.critTakenRangedRating or 0,
        critTakenSpellRating = currentStats.critTakenSpellRating or 0,
        critTakenRating = currentStats.critTakenRating or 0,
        
        -- Ratings de hâte
        hasteMeleeRating = currentStats.hasteMeleeRating or 0,
        hasteRangedRating = currentStats.hasteRangedRating or 0,
        hasteSpellRating = currentStats.hasteSpellRating or 0,
        hasteRating = currentStats.hasteRating or 0,
        
        -- Stats de combat
        resilienceRating = currentStats.resilienceRating or 0,
        expertiseRating = currentStats.expertiseRating or 0,
        attackPower = currentStats.attackPower or 0,
        rangedAttackPower = currentStats.rangedAttackPower or 0,
        armorPenRating = currentStats.armorPenRating or 0,
        
        -- Stats de sorts
        spellPower = currentStats.spellPower or 0,
        spellHealing = currentStats.spellHealing or 0,
        spellDamage = currentStats.spellDamage or 0,
        spellPenetration = currentStats.spellPenetration or 0,
        manaRegen = currentStats.manaRegen or 0,
        
        -- Stats diverses
        healthRegen = currentStats.healthRegen or 0,
        masteryRating = currentStats.masteryRating or 0
    }
    
    -- Vérifier s'il y a un palier suivant
    local nextData = nil
    if customInfo.nextTierItemId and customInfo.nextTierItemId > 0 then
        -- Récupérer les infos du palier SUIVANT
        local nextItemInfo = LoadCustomItemInfo(customInfo.nextTierItemId)
        local nextQuery = WorldDBQuery(string.format(
            "SELECT name, Quality, ItemLevel FROM item_template WHERE entry = %d",
            customInfo.nextTierItemId
        ))
        
        if nextQuery and nextItemInfo then
            local nextItemName = nextQuery:GetString(0)
            local nextItemQuality = nextQuery:GetUInt32(1)
            local nextItemLevel = nextQuery:GetUInt32(2)
            
            -- Récupérer le nom traduit en français pour le palier suivant (idem : seulement frFR)
            if GetPlayerLocale(player) == "frFR" then
                local nextLocaleQuery = WorldDBQuery(string.format(
                    "SELECT Name FROM item_template_locale WHERE ID = %d AND locale = 'frFR'",
                    customInfo.nextTierItemId
                ))
                
                if nextLocaleQuery then
                    local nextLocaleName = nextLocaleQuery:GetString(0)
                    if nextLocaleName and nextLocaleName ~= "" then
                        nextItemName = nextLocaleName
                    end
                end
            end
            
            -- Stats du palier suivant
            local nextStats = GetItemStatsFromTemplate(customInfo.nextTierItemId)
            
            nextData = {
                entry = customInfo.nextTierItemId,
                name = nextItemName,
                quality = nextItemQuality,
                itemLevel = nextItemLevel,
                tier = nextItemInfo.tier,
                
                -- Armure
                armor = nextStats.armor or 0,
                
                -- Stats de base
                mana = nextStats.mana or 0,
                health = nextStats.health or 0,
                agility = nextStats.agility or 0,
                strength = nextStats.strength or 0,
                intellect = nextStats.intellect or 0,
                spirit = nextStats.spirit or 0,
                stamina = nextStats.stamina or 0,
                
                -- Ratings de défense
                defenseRating = nextStats.defenseRating or 0,
                dodgeRating = nextStats.dodgeRating or 0,
                parryRating = nextStats.parryRating or 0,
                blockRating = nextStats.blockRating or 0,
                blockValue = nextStats.blockValue or 0,
                
                -- Ratings de toucher
                hitMeleeRating = nextStats.hitMeleeRating or 0,
                hitRangedRating = nextStats.hitRangedRating or 0,
                hitSpellRating = nextStats.hitSpellRating or 0,
                hitRating = nextStats.hitRating or 0,
                
                -- Ratings de critique
                critMeleeRating = nextStats.critMeleeRating or 0,
                critRangedRating = nextStats.critRangedRating or 0,
                critSpellRating = nextStats.critSpellRating or 0,
                critRating = nextStats.critRating or 0,
                
                -- Ratings de toucher reçu (défense)
                hitTakenMeleeRating = nextStats.hitTakenMeleeRating or 0,
                hitTakenRangedRating = nextStats.hitTakenRangedRating or 0,
                hitTakenSpellRating = nextStats.hitTakenSpellRating or 0,
                hitTakenRating = nextStats.hitTakenRating or 0,
                
                -- Ratings de critique reçu (défense)
                critTakenMeleeRating = nextStats.critTakenMeleeRating or 0,
                critTakenRangedRating = nextStats.critTakenRangedRating or 0,
                critTakenSpellRating = nextStats.critTakenSpellRating or 0,
                critTakenRating = nextStats.critTakenRating or 0,
                
                -- Ratings de hâte
                hasteMeleeRating = nextStats.hasteMeleeRating or 0,
                hasteRangedRating = nextStats.hasteRangedRating or 0,
                hasteSpellRating = nextStats.hasteSpellRating or 0,
                hasteRating = nextStats.hasteRating or 0,
                
                -- Stats de combat
                resilienceRating = nextStats.resilienceRating or 0,
                expertiseRating = nextStats.expertiseRating or 0,
                attackPower = nextStats.attackPower or 0,
                rangedAttackPower = nextStats.rangedAttackPower or 0,
                armorPenRating = nextStats.armorPenRating or 0,
                
                -- Stats de sorts
                spellPower = nextStats.spellPower or 0,
                spellHealing = nextStats.spellHealing or 0,
                spellDamage = nextStats.spellDamage or 0,
                spellPenetration = nextStats.spellPenetration or 0,
                manaRegen = nextStats.manaRegen or 0,
                
                -- Stats diverses
                healthRegen = nextStats.healthRegen or 0,
                masteryRating = nextStats.masteryRating or 0,
                
                cost = math.floor(TIER_UPGRADE_COST / 10000) -- Coût en gold
            }
        end
    end
    
    -- Envoyer les données au client
    AIO.Handle(player, "ItemUpgrade", "ShowItemInfo", currentData, nextData)
end

-- Handler pour améliorer au palier suivant
function ItemUpgradeHandlers.UpgradeTier(player, itemEntry)
    local customInfo = LoadCustomItemInfo(itemEntry)
    
    if not customInfo then
        AIO.Handle(player, "ItemUpgrade", "ShowMessage", L(player).CANT_UPGRADE)
        return
    end
    
    -- Vérifier s'il y a un palier suivant
    if not customInfo.nextTierItemId or customInfo.nextTierItemId == 0 then
        AIO.Handle(player, "ItemUpgrade", "ShowMessage", L(player).ALREADY_MAX_TIER)
        return
    end
    
    local item = player:GetItemByEntry(itemEntry)
    if not item then
        AIO.Handle(player, "ItemUpgrade", "ShowMessage", L(player).ITEM_NOT_FOUND)
        return
    end
    
    -- Vérifier le coût
    if player:GetCoinage() < TIER_UPGRADE_COST then
        local goldNeeded = math.floor(TIER_UPGRADE_COST / 10000)
        AIO.Handle(player, "ItemUpgrade", "ShowMessage", 
            string.format(L(player).NOT_ENOUGH_GOLD, goldNeeded))
        return
    end
    
    -- Supprimer l'ancien item
    player:RemoveItem(item, 1)
    
    -- Ajouter le nouvel item du palier suivant
    local newItem = player:AddItem(customInfo.nextTierItemId, 1)
    
    if not newItem then
        AIO.Handle(player, "ItemUpgrade", "ShowMessage", L(player).ALREADY_OWN_UNIQUE)
        -- Rendre l'ancien item en cas d'erreur
        player:AddItem(itemEntry, 1)
        return
    end
    
    -- Retirer l'argent
    player:ModifyMoney(-TIER_UPGRADE_COST)
    
    local goldSpent = math.floor(TIER_UPGRADE_COST / 10000)
    local nextCustomInfo = LoadCustomItemInfo(customInfo.nextTierItemId)
    
    AIO.Handle(player, "ItemUpgrade", "ShowMessage", 
        string.format(L(player).UPGRADE_SUCCESS, nextCustomInfo.tier, goldSpent))
    
    -- IMPORTANT : Rafraîchir l'UI avec le nouvel item au lieu de fermer
    ItemUpgradeHandlers.SelectItem(player, customInfo.nextTierItemId)
end

--print("|cFF00FF00ItemUpgradeServer chargé avec succès !|r")
--print("|cFFFFFF00Système avec support complet des stats TrinityCore 3.3.5|r")