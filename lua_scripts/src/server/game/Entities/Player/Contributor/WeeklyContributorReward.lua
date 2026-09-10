-- ============================================================================
-- Config
-- ============================================================================

local GOLD_REWARD_GOLD = 1000
local GOLD_REWARD_COPPER = GOLD_REWARD_GOLD * 10000

local REWARD_INTERVAL_SECONDS = 7 * 24 * 3600 -- 1 week
local SWEEP_INTERVAL_MS = 3600 * 1000         -- Hourly verification

local GOLD_TO_ALL_CHARACTERS = true

local BRELOQUE_ITEM_ID = 7000655
local BRELOQUE_AMOUNT = 850
local MAX_MAIL_ITEM_SLOTS = 12

local Locales = {
    frFR = {
        MAIL_SUBJECT = "Recompense hebdomadaire - Contributeur",
        MAIL_BODY_WITH_GOLD =
            "Merci pour votre soutien continu a Azeroth Universe !\n\n" ..
            "Voici votre lot hebdomadaire de contributeur : un objet epique surprise, 850 Breloques superieures, " ..
            "une monture surprise, un objet exclusif de la gamme AzerothUniverse, et %d pieces d'or.\n\n" ..
            "A la semaine prochaine !\n\nL'equipe Azeroth Universe",
        MAIL_BODY_ITEM_ONLY =
            "Merci pour votre soutien continu a Azeroth Universe !\n\n" ..
            "Voici votre lot hebdomadaire de contributeur : un objet epique surprise, une monture surprise, " ..
            "et un objet exclusif de la gamme AzerothUniverse.\n\n" ..
            "A la semaine prochaine !\n\nL'equipe Azeroth Universe",
    },
    enUS = {
        MAIL_SUBJECT = "Weekly Reward - Contributor",
        MAIL_BODY_WITH_GOLD =
            "Thank you for your continued support of Azeroth Universe!\n\n" ..
            "Here is your weekly contributor bundle: a surprise epic item, 850 superior trinkets, a surprise " ..
            "mount, an exclusive AzerothUniverse item, and %d gold.\n\n" ..
            "See you next week!\n\nThe Azeroth Universe team",
        MAIL_BODY_ITEM_ONLY =
            "Thank you for your continued support of Azeroth Universe!\n\n" ..
            "Here is your weekly contributor bundle: a surprise epic item, a surprise mount, and an exclusive " ..
            "AzerothUniverse item.\n\n" ..
            "See you next week!\n\nThe Azeroth Universe team",
    },
}

local MAIL_STATIONERY_GM = 61

local function GetAccountLocale(accountId)
    local ok, result = pcall(function()
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

-- ============================================================================
-- Preparation table
-- ============================================================================

CharDBExecute([[
    CREATE TABLE IF NOT EXISTS auc_eluna.contributor_weekly_reward (
        accountID INT UNSIGNED NOT NULL PRIMARY KEY,
        last_reward_at INT UNSIGNED NOT NULL DEFAULT 0
    ) ENGINE=InnoDB
]])

-- ============================================================================
-- Selection de l'objet epique
-- ============================================================================

local function GetClassMask(classId)
    return 2 ^ (classId - 1)
end

local function PickRandomEpicItemEntry(classMask)
    local query = WorldDBQuery(string.format([[
        SELECT entry FROM item_template
        WHERE Quality = 4
          AND class IN (2, 4)
          AND InventoryType <> 0
          AND entry < 1000000
          AND ItemLevel BETWEEN 150 AND 300
          AND RequiredLevel >= 60
          AND startquest = 0
          AND name NOT REGEXP '(TEST|DEBUG|QA|DND|DEPRECATED|OLD|UNUSED|NPC|placeholder)'
          AND name NOT LIKE '%%|c%%'
          AND name NOT LIKE '%%[%%'
          AND (AllowableClass = -1 OR (AllowableClass & %d) <> 0)
        ORDER BY RAND()
        LIMIT 1
    ]], classMask))

    if not query then
        return nil
    end
    return query:GetUInt32(0)
end

-- ============================================================================
-- Selection de la monture
-- ============================================================================

local function PickRandomMountEntry()
    local query = WorldDBQuery([[
        SELECT entry FROM item_template
        WHERE class = 15
          AND subclass = 5
          AND Quality >= 3
          AND AllowableRace = -1
          AND startquest = 0
          AND name NOT LIKE '%NPC%'
        ORDER BY RAND()
        LIMIT 1
    ]])

    if not query then
        return nil
    end
    return query:GetUInt32(0)
end

-- ============================================================================
-- Selection de l'objet AzerothUniverse
-- ============================================================================

local function PickRandomAzerothUniverseItem()
    local query = WorldDBQuery([[
        SELECT entry FROM item_template
        WHERE description LIKE '%AzerothUniverse%'
          AND Quality >= 4
        ORDER BY RAND()
        LIMIT 1
    ]])

    if not query then
        return nil
    end
    return query:GetUInt32(0)
end

-- ============================================================================
-- Repartition des Breloques en piles
-- ============================================================================

local BRELOQUE_MAX_STACK = nil
local function GetBreloqueMaxStack()
    if BRELOQUE_MAX_STACK then
        return BRELOQUE_MAX_STACK
    end

    local stack = BRELOQUE_AMOUNT
    local query = WorldDBQuery(string.format(
        "SELECT stackable FROM item_template WHERE entry = %d", BRELOQUE_ITEM_ID))
    if query then
        local s = query:GetInt32(0)
        if s and s > 0 then
            stack = s
        end
    end

    BRELOQUE_MAX_STACK = stack
    return stack
end

-- ============================================================================
-- Envoi de la recompense
-- ============================================================================

local function SendWeeklyMail(guidLow, includeGold, includeBreloques, epicItemEntry, mountEntry, azerothItemEntry, L)
    local gold = includeGold and GOLD_REWARD_COPPER or 0
    local subject = L.MAIL_SUBJECT
    local body = includeGold and string.format(L.MAIL_BODY_WITH_GOLD, GOLD_REWARD_GOLD) or L.MAIL_BODY_ITEM_ONLY

    local itemPairs = {}
    local function AddItemPair(entry, amount)
        if entry and amount and amount > 0 and (#itemPairs / 2) < MAX_MAIL_ITEM_SLOTS then
            table.insert(itemPairs, entry)
            table.insert(itemPairs, amount)
        end
    end

    AddItemPair(epicItemEntry, 1)
    AddItemPair(mountEntry, 1)
    AddItemPair(azerothItemEntry, 1)

    if includeBreloques then
        local maxStack = GetBreloqueMaxStack()
        local remaining = BRELOQUE_AMOUNT
        while remaining > 0 and (#itemPairs / 2) < MAX_MAIL_ITEM_SLOTS do
            local stackAmount = math.min(remaining, maxStack)
            AddItemPair(BRELOQUE_ITEM_ID, stackAmount)
            remaining = remaining - stackAmount
        end
    end

    local ok, err = pcall(SendMail, subject, body, guidLow, 0, MAIL_STATIONERY_GM, 0, gold, 0, unpack(itemPairs))

    if not ok then
        print(string.format("[WeeklyContributorReward] Echec d'envoi du courrier au personnage %d : %s", guidLow, tostring(err)))
    end
end

local function ProcessContributorAccount(accountId, now)
    local lastQuery = CharDBQuery(string.format(
        "SELECT last_reward_at FROM auc_eluna.contributor_weekly_reward WHERE accountID = %d", accountId))
    local lastRewardAt = lastQuery and lastQuery:GetUInt32(0) or 0

    if (now - lastRewardAt) < REWARD_INTERVAL_SECONDS then
        return
    end

    local charsQuery = CharDBQuery(string.format(
        "SELECT guid, class FROM auc_chars.characters WHERE account = %d AND deleteDate IS NULL ORDER BY logout_time DESC",
        accountId))

    if not charsQuery then
        return
    end

    local L = Locales[GetAccountLocale(accountId)] or Locales.frFR

    local isFirstCharacter = true
    repeat
        local guidLow = charsQuery:GetUInt32(0)
        local classId = charsQuery:GetUInt32(1)
        local epicItemEntry = PickRandomEpicItemEntry(GetClassMask(classId))
        local mountEntry = PickRandomMountEntry()
        local azerothItemEntry = PickRandomAzerothUniverseItem()
        local includeGold = GOLD_TO_ALL_CHARACTERS or isFirstCharacter
        local includeBreloques = includeGold

        SendWeeklyMail(guidLow, includeGold, includeBreloques, epicItemEntry, mountEntry, azerothItemEntry, L)

        isFirstCharacter = false
    until not charsQuery:NextRow()

    CharDBExecute(string.format(
        "INSERT INTO auc_eluna.contributor_weekly_reward (accountID, last_reward_at) VALUES (%d, %d) " ..
        "ON DUPLICATE KEY UPDATE last_reward_at = VALUES(last_reward_at)",
        accountId, now))
end

-- ============================================================================
-- Balayage periodique
-- ============================================================================

local function SweepWeeklyContributorRewards()
    local ok, err = pcall(function()
        local now = os.time()
        local accQuery = CharDBQuery("SELECT accountID FROM auc_eluna.mod_account_rank WHERE `rank` = 1")
        if not accQuery then
            return
        end

        repeat
            local accountId = accQuery:GetUInt32(0)
            ProcessContributorAccount(accountId, now)
        until not accQuery:NextRow()
    end)

    if not ok then
        print("[WeeklyContributorReward] Erreur pendant le balayage hebdomadaire : " .. tostring(err))
    end
end

SweepWeeklyContributorRewards()
CreateLuaEvent(SweepWeeklyContributorRewards, SWEEP_INTERVAL_MS, 0)
