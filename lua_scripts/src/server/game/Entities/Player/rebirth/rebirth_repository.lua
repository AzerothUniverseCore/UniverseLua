--[[
    Rebirth Repository

    Database access layer for the Rebirth system. Handles all CharDBQuery /
    CharDBExecute calls, schema creation, and both sync and async accessors.

    Adapted from paragon_repository.lua : same architecture, but Rebirth data
    is ALWAYS account-linked (no per-character table), and there are no
    statistic tables at all (Rebirth has no stat investment panel).

    @class Repository
    @author iThorgrim (Paragon) / adapted for Rebirth
    @license AGL v3
]]

local Constant = require("rebirth_constant")

local Repository = Object:extend()
local Instance = nil

local sf = string.format

-- ============================================================================
-- CONSTRUCTOR / SCHEMA
-- ============================================================================

function Repository:new()
    self:VerifyDatabaseSchema()
end

---
--- Creates the database and all Rebirth tables if they do not already exist,
--- then inserts the default configuration values.
---
function Repository:VerifyDatabaseSchema()
    local db = Constant.DB_NAME
    local q = Constant.QUERY

    CharDBExecute(sf(q.CR_DB, db))
    CharDBExecute(sf(q.CR_TABLE_CONFIG, db))
    CharDBExecute(sf(q.CR_TABLE_REBIRTH_ACCOUNT, db))
    CharDBExecute(sf(q.CR_TABLE_REBIRTH_CHARACTER, db))
    CharDBExecute(sf(q.CR_TABLE_CLAIMS, db))
    CharDBExecute(sf(q.CR_TABLE_CONFIG_EXP_CREATURE, db))
    CharDBExecute(sf(q.CR_TABLE_CONFIG_EXP_ACHIEVEMENT, db))
    CharDBExecute(sf(q.CR_TABLE_CONFIG_EXP_SKILL, db))
    CharDBExecute(sf(q.CR_TABLE_CONFIG_EXP_QUEST, db))

    -- Migration : add claim_count to account_rebirth_claims for installs
    -- created before this column existed (checked via information_schema,
    -- since "ADD COLUMN IF NOT EXISTS" isn't supported on every MySQL/
    -- MariaDB version this project might run on).
    local has_count_col = CharDBQuery(sf(q.SEL_CLAIMS_HAS_COUNT_COLUMN, db))
    if not has_count_col then
        CharDBExecute(sf(q.ALTER_CLAIMS_ADD_COUNT, db))
    end

    -- Editable-in-database content tables (Pierre / Pierre Preuve /
    -- Heritage / Recompenses) : created + seeded with the current default
    -- content via INSERT IGNORE (no-op on servers that already have rows).
    CharDBExecute(sf(q.CR_TABLE_CONFIG_PIERRE_OPTIONS, db))
    CharDBExecute(sf(q.CR_TABLE_CONFIG_PROOF_TELEPORTS, db))
    CharDBExecute(sf(q.CR_TABLE_CONFIG_HERITAGE_ITEMS, db))
    CharDBExecute(sf(q.CR_TABLE_CONFIG_REWARD_ITEMS, db))

    -- Migration : add name/icon columns to the 4 config tables for installs
    -- created before this admin-friendliness feature existed (same
    -- information_schema pattern as the claim_count migration above).
    if not CharDBQuery(sf(q.SEL_PIERRE_OPTIONS_HAS_NAME_COL, db)) then
        CharDBExecute(sf(q.ALTER_PIERRE_OPTIONS_ADD_NAME_ICON, db))
    end
    if not CharDBQuery(sf(q.SEL_PROOF_TELEPORTS_HAS_NAME_COL, db)) then
        CharDBExecute(sf(q.ALTER_PROOF_TELEPORTS_ADD_NAME_ICON, db))
    end
    if not CharDBQuery(sf(q.SEL_HERITAGE_ITEMS_HAS_NAME_COL, db)) then
        CharDBExecute(sf(q.ALTER_HERITAGE_ITEMS_ADD_NAME_ICON, db))
    end
    if not CharDBQuery(sf(q.SEL_REWARD_ITEMS_HAS_NAME_COL, db)) then
        CharDBExecute(sf(q.ALTER_REWARD_ITEMS_ADD_NAME_ICON, db))
    end

    CharDBExecute(sf(q.INS_DEFAULT_PIERRE_OPTIONS, db))
    CharDBExecute(sf(q.INS_DEFAULT_PROOF_TELEPORTS, db))
    CharDBExecute(sf(q.INS_DEFAULT_HERITAGE_ITEMS, db))
    CharDBExecute(sf(q.INS_DEFAULT_REWARD_ITEMS, db))

    CharDBExecute(sf(q.INS_DEFAULT_CONFIG, db))

    -- Legacy DB/table (auc_eluna.rebirth_accounts) : created here too so the
    -- sync write always has somewhere to land, even if Pierre_Rebirth.lua /
    -- Preuve_du_Rebirth.lua happen to load in a different order.
    CharDBExecute(sf("CREATE DATABASE IF NOT EXISTS `%s` CHARACTER SET utf8mb4;", Constant.LEGACY_DB_NAME))
    CharDBExecute(sf(
        "CREATE TABLE IF NOT EXISTS `%s`.`%s` (`account_id` INT(10) NOT NULL, `RebirthLevel` INT(10) NOT NULL DEFAULT 0, PRIMARY KEY (`account_id`));",
        Constant.LEGACY_DB_NAME, Constant.LEGACY_TABLE
    ))

    if Mediator then
        Mediator.On("OnAfterMigrationExecute", { arguments = { self } })
    end
end

-- ============================================================================
-- GENERAL CONFIGURATION
-- ============================================================================

function Repository:GetConfig()
    local query = CharDBQuery(string.format(Constant.QUERY.SEL_CONFIG, Constant.DB_NAME))
    if not query then
        return {}
    end

    local config = {}
    repeat
        local field = query:GetString(0)
        local value = query:GetString(1)
        config[field] = value
    until not query:NextRow()

    return config
end

-- ============================================================================
-- EXPERIENCE OVERRIDES
-- ============================================================================

local function LoadExperienceTable(query_template)
    local query = CharDBQuery(string.format(query_template, Constant.DB_NAME))
    if not query then
        return {}
    end

    local data = {}
    repeat
        local id = query:GetUInt32(0)
        local experience = query:GetUInt32(1)
        data[id] = experience
    until not query:NextRow()

    return data
end

function Repository:GetConfigCreatureExperience()
    return LoadExperienceTable(Constant.QUERY.SEL_CONFIG_EXP_CREATURE)
end

function Repository:GetConfigAchievementExperience()
    return LoadExperienceTable(Constant.QUERY.SEL_CONFIG_EXP_ACHIEVEMENT)
end

function Repository:GetConfigSkillExperience()
    return LoadExperienceTable(Constant.QUERY.SEL_CONFIG_EXP_SKILL)
end

function Repository:GetConfigQuestExperience()
    return LoadExperienceTable(Constant.QUERY.SEL_CONFIG_EXP_QUEST)
end

-- ============================================================================
-- ACCOUNT REBIRTH DATA (async)
-- ============================================================================

function Repository:GetRebirthByAccountId(account_id, callback)
    CharDBQueryAsync(string.format(Constant.QUERY.SEL_REBIRTH_ACCOUNT, Constant.DB_NAME, account_id), function(query)
        if not query then
            if callback then callback(nil) end
            return
        end

        local data = {
            level = query:GetUInt32(0),
            current_experience = query:GetUInt32(1)
        }

        if callback then callback(data) end
    end)
end

function Repository:SaveRebirthByAccount(account_id, level, experience)
    CharDBExecute(string.format(Constant.QUERY.INS_REBIRTH_ACCOUNT, Constant.DB_NAME, account_id, level, experience))
end

-- ============================================================================
-- CHARACTER REBIRTH DATA (async) -- used when LEVEL_LINKED_TO_ACCOUNT = "0"
-- ============================================================================

function Repository:GetRebirthByCharacter(guid, callback)
    CharDBQueryAsync(string.format(Constant.QUERY.SEL_REBIRTH_CHARACTER, Constant.DB_NAME, guid), function(query)
        if not query then
            if callback then callback(nil) end
            return
        end

        local data = {
            level = query:GetUInt32(0),
            current_experience = query:GetUInt32(1)
        }

        if callback then callback(data) end
    end)
end

function Repository:SaveRebirthByCharacter(guid, level, experience)
    CharDBExecute(string.format(Constant.QUERY.INS_REBIRTH_CHARACTER, Constant.DB_NAME, guid, level, experience))
end

-- ============================================================================
-- ACCOUNT REBIRTH DATA (sync)
-- ============================================================================

function Repository:GetRebirthByAccountIdSync(account_id)
    local query = CharDBQuery(string.format(Constant.QUERY.SEL_REBIRTH_ACCOUNT, Constant.DB_NAME, account_id))
    if not query then
        return nil
    end

    return {
        level = query:GetUInt32(0),
        current_experience = query:GetUInt32(1)
    }
end

function Repository:SaveRebirthByAccountSync(account_id, level, experience)
    CharDBQuery(string.format(Constant.QUERY.INS_REBIRTH_ACCOUNT, Constant.DB_NAME, account_id, level, experience))
end

function Repository:DeleteRebirthData(account_id)
    CharDBExecute(string.format(Constant.QUERY.DEL_REBIRTH_ACCOUNT, Constant.DB_NAME, account_id))
end

-- ============================================================================
-- CHARACTER REBIRTH DATA (sync) -- used when LEVEL_LINKED_TO_ACCOUNT = "0"
-- ============================================================================

function Repository:GetRebirthByCharacterSync(guid)
    local query = CharDBQuery(string.format(Constant.QUERY.SEL_REBIRTH_CHARACTER, Constant.DB_NAME, guid))
    if not query then
        return nil
    end

    return {
        level = query:GetUInt32(0),
        current_experience = query:GetUInt32(1)
    }
end

function Repository:SaveRebirthByCharacterSync(guid, level, experience)
    CharDBQuery(string.format(Constant.QUERY.INS_REBIRTH_CHARACTER, Constant.DB_NAME, guid, level, experience))
end

function Repository:DeleteRebirthCharacterData(guid)
    CharDBExecute(string.format(Constant.QUERY.DEL_REBIRTH_CHARACTER, Constant.DB_NAME, guid))
end

-- ============================================================================
-- ONE-TIME CLAIM TRACKING (Heritage / Reward items)
-- ============================================================================

---
--- Returns how many times this account has already claimed a given
--- Heritage/Reward item. Heritage entries never consult this (unlimited) ;
--- Reward entries compare it against their configured max_claims.
---
--- @param account_id The account id
--- @param item_id The item id being checked
--- @return number The current claim count (0 if never claimed)
---
function Repository:GetClaimCount(account_id, item_id)
    local query = CharDBQuery(string.format(Constant.QUERY.SEL_CLAIM_COUNT, Constant.DB_NAME, account_id, item_id))
    if not query then
        return 0
    end
    return query:GetUInt32(0)
end

---
--- Increments (or creates at 1) the claim counter for a Heritage/Reward
--- item for this account.
---
--- @param account_id The account id
--- @param item_id The item id being claimed
---
--- Uses CharDBQuery (synchronous), NOT CharDBExecute (asynchronous, fire-
--- and-forget), for the same reason SaveRebirthByAccountSync does : the
--- caller (TriggerRewardClaim, via OnRebirthClientTriggerEntry) immediately
--- rebuilds and resends the categories payload right after this call, which
--- reads the claim count back via GetClaimCounts. With CharDBExecute the
--- write was still queued (not yet committed) when that read-back ran,
--- so the client displayed the counter one claim behind reality (e.g.
--- "499/500" immediately after the 500th, DB-confirmed claim). CharDBQuery
--- blocks until the write completes, guaranteeing the immediate read-back
--- sees the up-to-date count.
function Repository:IncrementClaimCount(account_id, item_id)
    CharDBQuery(string.format(Constant.QUERY.INS_CLAIM_INCREMENT, Constant.DB_NAME, account_id, item_id))
end

---
--- Returns every item id this account has ever claimed, mapped to its claim
--- count, for O(1) lookups while building the Heritage/Reward category
--- payloads (avoids one DB query per entry).
---
--- @param account_id The account id
--- @return table Map of item_id -> claim_count
---
function Repository:GetClaimCounts(account_id)
    local counts = {}
    local query = CharDBQuery(string.format(Constant.QUERY.SEL_CLAIMS_COUNTS_FOR_ACCOUNT, Constant.DB_NAME, account_id))
    if not query then
        return counts
    end

    repeat
        counts[query:GetUInt32(0)] = query:GetUInt32(1)
    until not query:NextRow()

    return counts
end

-- ============================================================================
-- EDITABLE-IN-DATABASE CONTENT (Pierre / Pierre Preuve / Heritage / Recompenses)
-- ============================================================================

---
--- Loads the Pierre options' required-level thresholds (option_id ->
--- required_level). The buff/effect logic per option_id stays in Lua
--- (TriggerPierreOption in rebirth_hook.lua) ; only the unlock level is
--- database-editable.
---
--- @return table Array of { id, level }
---
function Repository:GetPierreOptionsConfig()
    local data = {}
    local query = CharDBQuery(string.format(Constant.QUERY.SEL_CONFIG_PIERRE_OPTIONS, Constant.DB_NAME))
    if not query then
        return data
    end

    repeat
        table.insert(data, {
            id = query:GetUInt32(0),
            level = query:GetUInt32(1),
            name = query:GetString(2),
            icon = query:GetString(3),
        })
    until not query:NextRow()

    return data
end

---
--- Loads the Pierre Preuve teleport milestones (id, required level, and
--- destination coordinates), fully database-editable.
---
--- @return table Array of { id, level, map, x, y, z, o }
---
function Repository:GetProofTeleportsConfig()
    local data = {}
    local query = CharDBQuery(string.format(Constant.QUERY.SEL_CONFIG_PROOF_TELEPORTS, Constant.DB_NAME))
    if not query then
        return data
    end

    repeat
        table.insert(data, {
            id = query:GetUInt32(0),
            level = query:GetUInt32(1),
            map = query:GetUInt32(2),
            x = query:GetFloat(3),
            y = query:GetFloat(4),
            z = query:GetFloat(5),
            o = query:GetFloat(6),
            name = query:GetString(7),
            icon = query:GetString(8),
        })
    until not query:NextRow()

    return data
end

---
--- Loads the Heritage item list (item_id, required level), fully
--- database-editable. Heritage items have no claim limit.
---
--- @return table Array of { item, level }
---
function Repository:GetHeritageItemsConfig()
    local data = {}
    local query = CharDBQuery(string.format(Constant.QUERY.SEL_CONFIG_HERITAGE_ITEMS, Constant.DB_NAME))
    if not query then
        return data
    end

    repeat
        table.insert(data, {
            item = query:GetUInt32(0),
            level = query:GetUInt32(1),
            name = query:GetString(2),
            icon = query:GetString(3),
        })
    until not query:NextRow()

    return data
end

---
--- Loads the Reward item list (item_id, required level, max_claims per
--- account -- 0 means unlimited), fully database-editable.
---
--- @return table Array of { item, level, max_claims }
---
function Repository:GetRewardItemsConfig()
    local data = {}
    local query = CharDBQuery(string.format(Constant.QUERY.SEL_CONFIG_REWARD_ITEMS, Constant.DB_NAME))
    if not query then
        return data
    end

    repeat
        table.insert(data, {
            item = query:GetUInt32(0),
            level = query:GetUInt32(1),
            max_claims = query:GetUInt32(2),
            name = query:GetString(3),
            icon = query:GetString(4),
        })
    until not query:NextRow()

    return data
end

-- ============================================================================
-- LEGACY SYNC (auc_eluna.rebirth_accounts)
-- ============================================================================

---
--- Mirrors the current Rebirth level into the legacy auc_eluna.rebirth_accounts
--- table, so Pierre_Rebirth.lua and Preuve_du_Rebirth.lua (untouched files,
--- kept from the original RebirthSystem.zip) keep reading the correct,
--- up-to-date level with ZERO modification needed on their side.
---
function Repository:SyncLegacyRebirthAccount(account_id, level)
    CharDBExecute(string.format(
        "REPLACE INTO `%s`.`%s` (account_id, RebirthLevel) VALUES (%d, %d);",
        Constant.LEGACY_DB_NAME, Constant.LEGACY_TABLE, account_id, level
    ))
end

-- ============================================================================
-- SINGLETON
-- ============================================================================

function Repository:GetInstance()
    if not Instance then
        Instance = Repository()
    end

    return Instance
end

return Repository:GetInstance()
