--[[
    Rebirth Hook System

    Manages all server-side event hooks and client-server communication for
    the Rebirth system. Adapted from paragon_hook.lua with two structural
    differences dictated by Rebirth's design:

    1. ACCOUNT-LINKED OR CHARACTER-LINKED (configurable) — like Paragon,
       Rebirth progression can be linked to the ACCOUNT (every character
       shares the same level/XP, matching the legacy auc_eluna.rebirth_accounts
       table this system replaces) or to the CHARACTER (each has its own
       independent level/XP), toggled via the LEVEL_LINKED_TO_ACCOUNT config
       field. The cache (_G.RebirthCache) is always keyed by guid_low (exactly
       like paragon_hook.lua), regardless of link mode — this gives every
       character its own cached Rebirth object, whose Load/Save simply target
       the account_rebirth or character_rebirth table depending on config, so
       account-linked mode still makes every character on the account read
       and write the same underlying row.

    2. NO STATISTICS/POINTS — Rebirth levels do not grant stat points to
       spend. Instead, the UI shows 4 Paragon-style category rows : Pierre
       (the legacy Pierre_Rebirth.lua buffs), Pierre Preuve (the 25 teleport
       milestones from Preuve_du_Rebirth.lua), Héritage (68 heirloom items)
       and Récompenses (items 90006/90008). OnRebirthClientTriggerEntry
       replaces OnParagonClientSendStatistics : it does not batch anything,
       it dispatches by categoryId and applies the clicked entry's effect
       immediately — Pierre re-uses Pierre_Rebirth.lua's OnSelect logic
       verbatim (same spell IDs, same nested level-tier chains, same 60s
       cooldown for "Réinitialiser le temps des sorts"), Pierre Preuve
       teleports exactly like Preuve_du_Rebirth.lua, and Héritage/Récompenses
       grant the item directly to the bag (once per account, tracked via
       account_rebirth_claims to prevent farming).

    Pierre_Rebirth.lua and Preuve_du_Rebirth.lua are kept completely
    unmodified alongside this system : rebirth_anniversary.lua mirrors every
    level-up into auc_eluna.rebirth_accounts.RebirthLevel (see
    Repository:SyncLegacyRebirthAccount), so both legacy scripts keep reading
    a correct, up-to-date level with zero changes on their side. The gossip
    menu they provide (including the Hyjal XP zones and the Nerozias
    shop teleport, which are NOT part of the "options" ported here) keeps
    working as a redundant, optional access path.

    Fixes carried over from paragon_hook.lua (still applicable under Eluna
    TrinityWotlk regardless of account-vs-character linking):
    - Event 5 does not exist for kill-creature; the correct id is 7.
    - Event 62 (skill update) does not exist in Eluna TrinityWotlk — omitted.
    - GetPlayersInWorld() is unavailable in per-map Lua states — no-op
      SERVER_EVENT_ON_LUA_STATE_OPEN/CLOSE hooks are simply not registered.
    - creature:GetEntry() is wrapped in pcall — the creature's C++ pointer
      can be invalidated (despawn) before the kill hook runs.
    - Player C++ pointers can be invalidated at logout; every GetAccountId()
      call that matters for the cache is wrapped in pcall via CacheGet/Set.
    - The DB is always re-read as the single source of truth before applying
      an experience gain (UpdatePlayerExperience never trusts the cache),
      because Eluna gives each map its own Lua state and _G tables are the
      only thing shared between them — a plain local cache table would not
      be visible across maps.

    Deliberately NOT ported from paragon_hook.lua:
    - Hook.OnCharacterDelete — Paragon deletes character-linked data when a
      character is deleted. Rebirth data belongs to the ACCOUNT: deleting
      one alt must never wipe the account's Rebirth progress shared by every
      other character on it. No character-delete hook is registered.
    - UpdatePlayerStatistics / UpdateParagonPoints and everything stat/point
      related — Rebirth has nothing to apply or remove on login/logout.
    - The PendingExperience queue — it existed to cover a login race that no
      longer exists once login always resolves synchronously (LoadRebirthSync
      exactly like Paragon's own LoadParagonSync); Paragon's own
      Hook.OnPlayerStatLoad ended up disabled for the same reason.
    - Hook.OnPlayerCommand ("test") — was a stat-debug helper, not applicable.

    @module rebirth_hook
    @author iThorgrim (Paragon) / adapted for Rebirth
    @license AGL v3
]]

local Rebirth = require("rebirth_class")
local Config = require("rebirth_config")
local Repository = require("rebirth_repository")
local Constant = require("rebirth_constant")

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

local Hook = {
    Addon = {
        Prefix = "RebirthStone",
        Functions = {
            [1] = "OnRebirthClientLoadRequest",
            [2] = "OnRebirthClientTriggerEntry"
            -- [6] is added by rebirth_target_level.lua at module load time.
        }
    }
}

-- Experience source type enumeration (kept identical to Paragon's, only
-- CREATURE is enabled by default via UNIVERSAL_CREATURE_EXPERIENCE=1, but the
-- other sources stay wired for parity / future admin configuration).
local EXPERIENCE_SOURCE = {
    CREATURE = 1,
    ACHIEVEMENT = 2,
    SKILL = 3,
    QUEST = 4
}

-- ============================================================================
-- REBIRTH CACHE — table _G GLOBALE partagée entre tous les Lua states
--
-- Même problème racine que paragon_hook.lua : Eluna crée un état Lua par
-- map-thread, une table `local` n'existe que dans l'état qui l'a créée.
-- _G.RebirthCache est indexé par account_id (PAS guid_low) puisque le
-- Rebirth est toujours lié au compte, jamais au personnage : deux
-- personnages du même compte doivent voir exactement la même progression.
-- ============================================================================

_G.RebirthCache = _G.RebirthCache or {}

---
--- @param player The player object (its GetGUIDLow() is used as cache key,
---   exactly like paragon_hook.lua -- one cached Rebirth object per
---   character, even in account-linked mode)
--- @param rebirth The Rebirth instance to store
---
local function CacheSet(player, rebirth)
    local ok, guid_low = pcall(function() return player:GetGUIDLow() end)
    if not ok or not guid_low then
        return
    end
    _G.RebirthCache[guid_low] = rebirth
end

---
--- @param player The player object (its GetGUIDLow() is used as cache key)
--- @return The cached Rebirth instance, or nil
---
local function CacheGet(player)
    -- player peut être un pointeur C++ invalidé (objet détruit au logout).
    local ok, guid_low = pcall(function() return player:GetGUIDLow() end)
    if not ok or not guid_low then
        return nil
    end
    return _G.RebirthCache[guid_low]
end

local function CacheClear(guid_low)
    _G.RebirthCache[guid_low] = nil
end

-- ============================================================================
-- LOCALISATION (frFR / enUS) -- server-side notification messages + DB name
-- selection, no client round-trip needed.
--
-- This is a pure server package (rebirth.zip has no client Lua/XML files),
-- so unlike Mod_Me_Panel/Mod_Me_Convert (which get the client's own
-- GetLocale() over AIO), the locale has to be detected from something the
-- server already knows on its own : TrinityCore's `account` table (auth
-- database) stores a numeric `locale` column, set by the client itself at
-- login, using the exact same LocaleConstant ordering as the DBC-derived
-- Name1/Name3 columns used elsewhere in this project (0 = enUS, 2 = frFR).
-- Wrapped end-to-end in pcall : if AuthDBQuery/the account table/column
-- aren't reachable for any reason on this setup, this silently falls back
-- to frFR (this system's original, always-safe default) instead of ever
-- erroring out of a hook.
-- ============================================================================

local LOCALE_ENUS_ID = 0

local function GetPlayerLocale(player)
    local ok, result = pcall(function()
        if not player then
            return nil
        end
        local account_id = player:GetAccountId()
        if not account_id then
            return nil
        end
        return AuthDBQuery("SELECT locale FROM account WHERE id = " .. account_id .. ";")
    end)

    if ok and result then
        local ok2, locale_id = pcall(function() return result:GetUInt8(0) end)
        if ok2 and locale_id == LOCALE_ENUS_ID then
            return "enUS"
        end
    end

    return "frFR"
end

--- Picks the DB-editable display name for the requesting player's locale
--- (rebirth_config_pierre_options / rebirth_config_proof_teleports' `name`
--- = frFR, `name_en` = enUS). Returns nil -- not the other locale's text --
--- when the column for THIS locale is unset, so an enUS client never sees
--- leftover French text (or vice versa) : nil means "let the client fall
--- back to its own OPTIONS_INFO/PROOF_INFO", exactly like before this
--- system supported more than one language.
local function PickLocalizedName(entry, locale)
    local value = (locale == "enUS") and entry.name_en or entry.name
    if value and value ~= "" then
        return value
    end
    return nil
end

--- Notification message templates, keyed by locale then by message id.
--- Dynamic values (required level, seconds remaining, etc.) are injected
--- via string.format -- see Notify() below.
local NOTICES = {
    frFR = {
        OPTION_LOCKED = "|CFF00A2FFCette option est verrouillée. Niveau de Rebirth %d requis.|r",
        ALL_BUFFS = "|CFF00A2FFVous bénéficiez de toutes les améliorations d'état possible !|r",
        HEAL = "|CFF00A2FFVous revoila en bonne santé !|r",
        REMOVE_SICKNESS = "|CFF00A2FFVous revoila prêt aux combats !|r",
        REPAIR = "|CFF00A2FFVotre équipement est réparé !|r",
        RESET_TALENTS = "|CFF00A2FFVos talents ont été réinitialisés|r",
        SPELLS_COOLDOWN_WAIT = "|cff00f0f0Encore|r |cffffff00%d secondes|r |cff00f0f0avant la réinitialisation des sorts.|r",
        RESET_SPELLS = "|CFF00A2FFVos temps de recharge de vos sorts ont été réinitialisés|r",
        REMOVE_DESERTER = "|CFF00A2FFVous revoila prêt pour un nouveau champs de bataille !|r",
        RESET_INSTANCES = "|CFF00A2FFVos instances ont été réinitalisées.|r",
        TELEPORT_LOCKED = "|CFF00A2FFCette destination est verrouillée. Niveau de Rebirth %d requis.|r",
        TELEPORT_SUCCESS = "Tuer Preuve du rebirth %d pour être récompenser !",
        HERITAGE_LOCKED = "|CFF00A2FFCet objet Héritage est verrouillé. Niveau de Rebirth %d requis.|r",
        HERITAGE_GRANTED = "|CFF00A2FFObjet Héritage ajouté à votre inventaire !|r",
        REWARD_LOCKED = "|CFF00A2FFCette récompense est verrouillée. Niveau de Rebirth %d requis.|r",
        REWARD_LIMIT = "|CFF00A2FFVous avez atteint la limite de réclamation pour cette récompense (%d).|r",
        REWARD_GRANTED = "|CFF00A2FFRécompense ajoutée à votre inventaire !|r",
        NOT_IN_BG_ARENA = "|CFF00A2FFVous ne pouvez pas utiliser votre Pierre de Rebirth depuis un champ de bataille ou une arène.|r",
        NOT_IN_COMBAT = "|CFF00A2FFRetentez une fois votre combat fini!|r",
    },
    enUS = {
        OPTION_LOCKED = "|CFF00A2FFThis option is locked. Rebirth level %d required.|r",
        ALL_BUFFS = "|CFF00A2FFYou now have every possible state improvement!|r",
        HEAL = "|CFF00A2FFYou're back in good health!|r",
        REMOVE_SICKNESS = "|CFF00A2FFYou're ready for battle again!|r",
        REPAIR = "|CFF00A2FFYour equipment has been repaired!|r",
        RESET_TALENTS = "|CFF00A2FFYour talents have been reset|r",
        SPELLS_COOLDOWN_WAIT = "|cff00f0f0Still|r |cffffff00%d seconds|r |cff00f0f0before spell cooldowns can be reset again.|r",
        RESET_SPELLS = "|CFF00A2FFYour spell cooldowns have been reset|r",
        REMOVE_DESERTER = "|CFF00A2FFYou're ready for a new battleground!|r",
        RESET_INSTANCES = "|CFF00A2FFYour instances have been reset.|r",
        TELEPORT_LOCKED = "|CFF00A2FFThis destination is locked. Rebirth level %d required.|r",
        TELEPORT_SUCCESS = "Kill Proof of Rebirth %d to be rewarded!",
        HERITAGE_LOCKED = "|CFF00A2FFThis Heritage item is locked. Rebirth level %d required.|r",
        HERITAGE_GRANTED = "|CFF00A2FFHeritage item added to your inventory!|r",
        REWARD_LOCKED = "|CFF00A2FFThis reward is locked. Rebirth level %d required.|r",
        REWARD_LIMIT = "|CFF00A2FFYou have reached the claim limit for this reward (%d).|r",
        REWARD_GRANTED = "|CFF00A2FFReward added to your inventory!|r",
        NOT_IN_BG_ARENA = "|CFF00A2FFYou cannot use your Pierre de Rebirth from a battleground or arena.|r",
        NOT_IN_COMBAT = "|CFF00A2FFTry again once you're out of combat!|r",
    },
}

--- Sends a SendNotification to `player`, in their own locale, looking up
--- `key` in NOTICES and formatting any extra varargs into it via
--- string.format (only when varargs are actually passed, so plain
--- messages with literal "%" characters -- none currently, but just in
--- case -- are never mistakenly run through string.format).
local function Notify(player, key, ...)
    local locale = GetPlayerLocale(player)
    local template = (NOTICES[locale] or NOTICES.frFR)[key]
    if not template then
        return
    end

    if select("#", ...) > 0 then
        player:SendNotification(string.format(template, ...))
    else
        player:SendNotification(template)
    end
end

---
--- Reads a Rebirth level/experience row synchronously, routing to
--- account_rebirth or character_rebirth depending on LEVEL_LINKED_TO_ACCOUNT.
--- Centralizes the routing logic so every call site in this file (login,
--- logout, kill/achievement/quest experience gain, entry trigger) stays in
--- sync with a single config read.
---
--- @param guid_low The character's low GUID
--- @param account_id The account id
--- @return table|nil { level, current_experience } or nil
---
local function GetRebirthDataSync(guid_low, account_id)
    if Config:GetByField("LEVEL_LINKED_TO_ACCOUNT") == "1" then
        return Repository:GetRebirthByAccountIdSync(account_id)
    else
        return Repository:GetRebirthByCharacterSync(guid_low)
    end
end

-- ============================================================================
-- OPTION COOLDOWNS — 60s cooldown for "Réinitialiser le temps des sorts",
-- ported verbatim from Pierre_Rebirth.lua's Cooldowns table. Global (_G) for
-- the same cross-map reason as RebirthCache, keyed by account_id.
-- ============================================================================

_G.RebirthOptionCooldowns = _G.RebirthOptionCooldowns or {}

local RESET_SORTS_COOLDOWN = 60

-- ============================================================================
-- PRIVATE FUNCTIONS — LOADING
-- ============================================================================

---
--- Synchronously loads a Rebirth instance for a player's account. Returns the
--- cached instance immediately if present (never re-reads the DB in that
--- case, otherwise a level gained on another map/session could be
--- overwritten by a stale DB read — same fix as Paragon's LoadParagonSync).
---
--- @param player The player object
--- @return The loaded Rebirth instance, or nil on failure
---
local function LoadRebirthSync(player)
    local ok, account_id = pcall(function() return player:GetAccountId() end)
    if not ok or not account_id then
        return nil
    end

    local ok2, guid_low = pcall(function() return player:GetGUIDLow() end)
    if not ok2 or not guid_low then
        return nil
    end

    if _G.RebirthCache[guid_low] then
        return _G.RebirthCache[guid_low]
    end

    local rebirth = Rebirth(guid_low, account_id)

    local data = GetRebirthDataSync(guid_low, account_id)
    if data and data.level then
        rebirth.level = data.level
        rebirth.exp.current = data.current_experience or 0
        local base_max_exp = tonumber(Config:GetByField("BASE_MAX_EXPERIENCE")) or 50
        rebirth.exp.max = base_max_exp * rebirth.level
    end

    CacheSet(player, rebirth)

    return rebirth
end

---
--- Loads a Rebirth instance DIRECTLY from the database, bypassing the cache.
--- Used at logout for the same reason as Paragon's LoadParagonFromDB : the
--- cache in this Lua state could be stale if kills happened on another map.
---
--- @param player The player object
--- @return The loaded Rebirth instance, or nil on failure
---
local function LoadRebirthFromDB(player)
    local ok, account_id = pcall(function() return player:GetAccountId() end)
    if not ok or not account_id then
        return nil
    end

    local ok2, guid_low = pcall(function() return player:GetGUIDLow() end)
    if not ok2 or not guid_low then
        return nil
    end

    local rebirth = Rebirth(guid_low, account_id)

    local data = GetRebirthDataSync(guid_low, account_id)
    if data and data.level then
        rebirth.level = data.level
        rebirth.exp.current = data.current_experience or 0
        local base_max_exp = tonumber(Config:GetByField("BASE_MAX_EXPERIENCE")) or 50
        rebirth.exp.max = base_max_exp * rebirth.level
    end

    return rebirth
end

-- ============================================================================
-- PLAYER EXPERIENCE MANAGEMENT
-- ============================================================================

---
--- Updates the account's Rebirth experience based on activity source.
--- Always reloads fresh from the DB first (cross-map safety, see module
--- header), applies the gain through the Mediator pipeline (which is where
--- rebirth_anniversary.lua performs the actual level-up cascade), then pushes
--- the new level/experience to the client and saves synchronously.
---
--- @param player The player object
--- @param rebirth Unused — always reloaded fresh from the DB (kept in the
---   signature only for call-site symmetry with paragon_hook.lua)
--- @param source_type The source type (EXPERIENCE_SOURCE enum)
--- @param entry The source entry ID
--- @return boolean True if experience was awarded, false otherwise
---
-- Forward declaration : BuildCategoriesPayload is only DEFINED further down
-- this file (see "CATEGORIES PAYLOAD" section), but UpdatePlayerExperience
-- needs to call it (response id 3) so a level-up unlocks Pierre/Pierre
-- Preuve/Recompenses entries immediately, without the client having to
-- relog. The actual function body is assigned to this same local further
-- down (`BuildCategoriesPayload = function(...)`), Lua closures resolve the
-- upvalue at call time so this works regardless of definition order.
local BuildCategoriesPayload

local function UpdatePlayerExperience(player, rebirth, source_type, entry)
    if not player or not source_type or not entry then
        return false
    end

    local min_level = tonumber(Config:GetByField("MINIMUM_LEVEL_FOR_REBIRTH_XP")) or 0
    if player:GetLevel() < min_level then
        return false
    end

    local ok, account_id = pcall(function() return player:GetAccountId() end)
    if not ok or not account_id then
        return false
    end

    local ok2, guid_low = pcall(function() return player:GetGUIDLow() end)
    if not ok2 or not guid_low then
        return false
    end

    -- Reload fresh from DB (source of truth shared across every Lua state).
    local fresh_rebirth = Rebirth(guid_low, account_id)
    local data = GetRebirthDataSync(guid_low, account_id)
    if data and data.level then
        fresh_rebirth.level = data.level
        fresh_rebirth.exp.current = data.current_experience or 0
        local base_max_exp = tonumber(Config:GetByField("BASE_MAX_EXPERIENCE")) or 50
        fresh_rebirth.exp.max = base_max_exp * fresh_rebirth.level
    end

    rebirth = fresh_rebirth

    -- Inject player reference so rebirth_class.lua:SetLevel can fire
    -- OnRebirthLevelChanged with a valid player argument.
    rebirth._player = player

    rebirth, source_type, entry = Mediator.On("OnBeforeUpdatePlayerExperience", {
        arguments = { player, rebirth, source_type, entry },
        defaults = { rebirth, source_type, entry },
    })

    if rebirth:IsMaxLevel() then
        -- Deja niveau plafond (30) : rien a gagner, on ne fait aucun appel DB
        -- inutile. rebirth_anniversary.lua applique deja ce meme court-circuit
        -- pour l'XP en file, mais on evite ici meme le SendServerResponse.
        return false
    end

    local source_config_map = {
        [EXPERIENCE_SOURCE.CREATURE] = "UNIVERSAL_CREATURE_EXPERIENCE",
        [EXPERIENCE_SOURCE.ACHIEVEMENT] = "UNIVERSAL_ACHIEVEVEMENT_EXPERIENCE",
        [EXPERIENCE_SOURCE.SKILL] = "UNIVERSAL_SKILL_EXPERIENCE",
        [EXPERIENCE_SOURCE.QUEST] = "UNIVERSAL_QUEST_EXPERIENCE"
    }

    local config_key = source_config_map[source_type] or "UNIVERSAL_CREATURE_EXPERIENCE"
    local universal_value = tonumber(Config:GetByField(config_key)) or 0

    if universal_value <= 0 then
        return false
    end

    local source_experience_map = {
        ["UNIVERSAL_CREATURE_EXPERIENCE"] = Config:GetCreatureExperience(entry),
        ["UNIVERSAL_ACHIEVEVEMENT_EXPERIENCE"] = Config:GetAchievementExperience(entry),
        ["UNIVERSAL_SKILL_EXPERIENCE"] = Config:GetSkillExperience(entry),
        ["UNIVERSAL_QUEST_EXPERIENCE"] = Config:GetQuestExperience(entry)
    }

    local specific_experience = source_experience_map[config_key] or universal_value

    if not specific_experience or specific_experience <= 0 then
        return false
    end

    specific_experience = Mediator.On("OnExperienceCalculated", {
        arguments = { player, rebirth, source_type, specific_experience },
        defaults = { specific_experience },
    })

    rebirth = Mediator.On("OnUpdatePlayerExperience", {
        arguments = { player, rebirth, specific_experience },
        defaults = { rebirth }
    })

    Mediator.On("OnRebirthStateSync", {
        arguments = { player, rebirth },
    })

    -- Update client with new Rebirth state (no points/statistics to send).
    player:SendServerResponse(Hook.Addon.Prefix, 1, rebirth:GetLevel())
    player:SendServerResponse(Hook.Addon.Prefix, 2, rebirth:GetExperience(), rebirth:GetExperienceForNextLevel())

    -- Resend the 4-category payload (response id 3) so a level-up unlocks
    -- Pierre / Pierre Preuve / Recompenses entries right away, client-side,
    -- without requiring a disconnect/reconnect (previously only ids 1 and 2
    -- were sent here, so the categories list stayed stale until relog).
    if BuildCategoriesPayload then
        player:SendServerResponse(Hook.Addon.Prefix, 3, BuildCategoriesPayload(rebirth:GetLevel(), account_id))
    end

    CacheSet(player, rebirth)

    -- SAVE IMMEDIAT (CharDBQuery synchrone) : garantit que la DB est a jour
    -- avant le prochain appel a UpdatePlayerExperience (qui relit la DB), et
    -- avant que rebirth_anniversary.lua ne mirroire le niveau dans la table
    -- legacy auc_eluna.rebirth_accounts.
    rebirth:SaveSync()

    Mediator.On("OnAfterUpdatePlayerExperience", {
        arguments = { player, rebirth },
    })

    return true
end

-- Expose via Hook for other modules (rebirth_target_level.lua, etc.)
Hook._UpdatePlayerExperience = UpdatePlayerExperience
Hook.CacheGet = CacheGet
Hook.CacheSet = CacheSet
-- Exposed for the standalone modules (rebirth_anniversary.lua,
-- rebirth_experience_item_explosion.lua / _infusion.lua) so their own
-- SendNotification calls can be localized too, without duplicating the
-- account.locale lookup logic in every file.
Hook.GetPlayerLocale = GetPlayerLocale

-- ============================================================================
-- CATEGORIES PAYLOAD (Paragon-style : 4 category rows, replacing stats)
-- ============================================================================

---
--- Generic lookup helper : finds the first entry in `list` whose field
--- `key_field` equals `id`.
---
local function FindEntryById(list, key_field, id)
    for _, entry in ipairs(list) do
        if entry[key_field] == id then
            return entry
        end
    end
    return nil
end

---
--- Builds the "Pierre" category entries (the 8 Pierre de Rebirth options).
--- Required levels now come from Config:GetPierreOptions() (database-
--- editable, see rebirth_config_pierre_options) instead of the old
--- hardcoded OPTIONS_TIER_1_LEVEL/OPTIONS_TIER_2_LEVEL + TIER_2_OPTIONS set.
--- The buff/effect LOGIC per option id stays in Lua (TriggerPierreOption).
---
local function BuildPierreEntries(rebirth_level, locale)
    local entries = {}
    for _, opt in ipairs(Config:GetPierreOptions()) do
        table.insert(entries, {
            id = opt.id,
            requiredLevel = opt.level,
            unlocked = rebirth_level >= opt.level,
            -- DB-editable display fields (rebirth_config_pierre_options.name
            -- / name_en / icon) : nil/empty means "not set for this
            -- locale", client falls back to Rebirth_Locales.lua's
            -- OPTIONS_INFO exactly as before. PickLocalizedName picks
            -- `name` (frFR) or `name_en` (enUS) per the requesting player.
            name = PickLocalizedName(opt, locale),
            icon = opt.icon,
        })
    end

    table.sort(entries, function(a, b) return a.id < b.id end)

    return entries
end

---
--- Builds the "Pierre Preuve" category entries (teleport milestones), fully
--- database-editable via Config:GetProofTeleports() (rebirth_config_proof_teleports).
---
local function BuildProofEntries(rebirth_level, locale)
    local entries = {}
    for _, t in ipairs(Config:GetProofTeleports()) do
        table.insert(entries, {
            id = t.id,
            requiredLevel = t.level,
            unlocked = rebirth_level >= t.level,
            name = PickLocalizedName(t, locale),
            icon = t.icon,
        })
    end
    return entries
end

---
--- Builds the "Heritage" category entries, database-editable via
--- Config:GetHeritageItems() (rebirth_config_heritage_items). Heritage has
--- NO claim limit at all : `claimed` is always false, exactly like
--- Pierre/Pierre Preuve, freely re-claimable once unlocked.
---
local function BuildHeritageEntries(rebirth_level, locale)
    local entries = {}
    for _, t in ipairs(Config:GetHeritageItems()) do
        table.insert(entries, {
            id = t.item,
            requiredLevel = t.level,
            unlocked = rebirth_level >= t.level,
            claimed = false,
            -- DB-editable name/icon (rebirth_config_heritage_items.name /
            -- name_en / icon). PickLocalizedName picks `name` (frFR) or
            -- `name_en` (enUS) per the requesting player, same as
            -- Pierre/Pierre Preuve above ; nil falls back to
            -- GetItemInfo()/"?" client-side exactly as before.
            name = PickLocalizedName(t, locale),
            icon = t.icon,
        })
    end
    return entries
end

---
--- Builds the "Recompenses" category entries, database-editable via
--- Config:GetRewardItems() (rebirth_config_reward_items). Each item has a
--- configurable max_claims (0 = unlimited) ; `claimed` is set once the
--- account has reached that cap, so the client shows the same
--- greyed-out/checkmark state it already did for a one-shot claim.
---
--- @param rebirth_level The account's current Rebirth level
--- @param claim_counts Map of item_id -> claim_count (Repository:GetClaimCounts)
---
local function BuildRewardEntries(rebirth_level, claim_counts, locale)
    local entries = {}
    for _, t in ipairs(Config:GetRewardItems()) do
        local count = claim_counts[t.item] or 0
        local maxed = (t.max_claims and t.max_claims > 0) and (count >= t.max_claims)
        table.insert(entries, {
            id = t.item,
            requiredLevel = t.level,
            unlocked = rebirth_level >= t.level,
            claimed = maxed or false,
            claimCount = count,
            maxClaims = t.max_claims or 0,
            -- DB-editable name/icon (rebirth_config_reward_items), same
            -- locale-aware reasoning as Heritage above.
            name = PickLocalizedName(t, locale),
            icon = t.icon,
        })
    end
    return entries
end

---
--- Builds the full 4-category payload sent to the client (response id 3),
--- replacing Paragon's stat categories entirely.
---
--- @param rebirth_level The account's current Rebirth level
--- @param account_id The account id (needed for the Recompenses claim counters)
--- @return table Array of { categoryId, entries }
---
-- Assigned to the local forward-declared above UpdatePlayerExperience (see
-- that function's comment) so it can call this even though it is defined
-- earlier in the file.
BuildCategoriesPayload = function(rebirth_level, account_id, locale)
    local claim_counts = Repository:GetClaimCounts(account_id)

    return {
        { categoryId = Constant.CATEGORIES.PIERRE, entries = BuildPierreEntries(rebirth_level, locale) },
        { categoryId = Constant.CATEGORIES.PIERRE_PREUVE, entries = BuildProofEntries(rebirth_level, locale) },
        { categoryId = Constant.CATEGORIES.HERITAGE, entries = BuildHeritageEntries(rebirth_level, locale) },
        { categoryId = Constant.CATEGORIES.RECOMPENSES, entries = BuildRewardEntries(rebirth_level, claim_counts, locale) },
    }
end

-- ============================================================================
-- ADDON COMMUNICATION
-- ============================================================================

---
--- Handles client request to load and display all Rebirth data (level, XP,
--- 4 categories) — equivalent of OnParagonClientLoadRequest.
---
--- @param player The player object making the request
--- @param _ Unused parameter
---
function OnRebirthClientLoadRequest(player, _)
    if not player then
        return false
    end

    local ok, account_id = pcall(function() return player:GetAccountId() end)
    if not ok or not account_id then
        return false
    end

    local rebirth = CacheGet(player)
    if not rebirth then
        rebirth = LoadRebirthSync(player)
        if not rebirth then return false end
    end

    rebirth = Mediator.On("OnBeforeClientLoadRequest", {
        arguments = { player, rebirth },
        defaults = { rebirth },
    })

    local categories = BuildCategoriesPayload(rebirth:GetLevel(), account_id, GetPlayerLocale(player))

    categories = Mediator.On("OnAfterClientLoadRequest", {
        arguments = { player, rebirth, categories },
        defaults = { categories },
    })

    player:SendServerResponse(Hook.Addon.Prefix, 1, rebirth:GetLevel())
    player:SendServerResponse(Hook.Addon.Prefix, 2, rebirth:GetExperience(), rebirth:GetExperienceForNextLevel())
    player:SendServerResponse(Hook.Addon.Prefix, 3, categories)

    return true
end

---
--- Applies a Pierre de Rebirth option's effect. Ported VERBATIM from
--- Pierre_Rebirth.lua's OnSelect (intid == 1 for the 4 buff-tier chains,
--- plus every other intid), including the exact level thresholds, spell
--- ids and the 60s cooldown for "Réinitialiser le temps des sorts".
---
--- @param player The player object
--- @param level The account's current Rebirth level
--- @param account_id The account id (used for the RESET_SORTS cooldown key)
--- @param option_id One of Constant.OPTIONS
--- @return boolean True if the option was applied, false otherwise
---
local function TriggerPierreOption(player, level, account_id, option_id)
    local O = Constant.OPTIONS

    -- Required level now comes from Config:GetPierreOptions() (database-
    -- editable, see rebirth_config_pierre_options), matching what
    -- BuildPierreEntries already sends to the client -- falls back to tier 1
    -- (level 1) if an option id somehow has no DB row.
    local option_entry = FindEntryById(Config:GetPierreOptions(), "id", option_id)
    local required_level = (option_entry and option_entry.level) or Constant.OPTIONS_TIER_1_LEVEL

    if level < required_level then
        Notify(player, "OPTION_LOCKED", required_level)
        return false
    end

    -- ------------------------------------------------------------------
    -- Amélioration d'état : les 4 chaines de sorts par palier.
    -- ------------------------------------------------------------------
    if option_id == O.BUFF_AMELIORATION_ETAT then
        if level >= 1 then -- Renaissance Croissante
            if level >= 5 then
                if level >= 9 then
                    if level >= 11 then
                        if level >= 15 then
                            if level >= 19 then
                                if level >= 21 then
                                    if level >= 25 then
                                        if level >= 29 then
                                            player:CastSpell(player, 150408, true)
                                        else
                                            player:CastSpell(player, 150407, true)
                                        end
                                    else
                                        player:CastSpell(player, 150406, true)
                                    end
                                else
                                    player:CastSpell(player, 150405, true)
                                end
                            else
                                player:CastSpell(player, 150404, true)
                            end
                        else
                            player:CastSpell(player, 150403, true)
                        end
                    else
                        player:CastSpell(player, 150402, true)
                    end
                else
                    player:CastSpell(player, 150401, true)
                end
            else
                player:CastSpell(player, 150400, true)
            end
        end

        if level >= 2 then -- Renaissance Féroce
            if level >= 7 then
                if level >= 10 then
                    if level >= 12 then
                        if level >= 17 then
                            if level >= 20 then
                                if level >= 22 then
                                    if level >= 27 then
                                        if level >= 30 then
                                            player:CastSpell(player, 150418, true)
                                        else
                                            player:CastSpell(player, 150417, true)
                                        end
                                    else
                                        player:CastSpell(player, 150416, true)
                                    end
                                else
                                    player:CastSpell(player, 150415, true)
                                end
                            else
                                player:CastSpell(player, 150414, true)
                            end
                        else
                            player:CastSpell(player, 150413, true)
                        end
                    else
                        player:CastSpell(player, 150412, true)
                    end
                else
                    player:CastSpell(player, 150411, true)
                end
            else
                player:CastSpell(player, 150410, true)
            end
        end

        if level >= 3 then -- Renaissance Persistante
            if level >= 13 then
                if level >= 23 then
                    player:CastSpell(player, 150432, true)
                else
                    player:CastSpell(player, 150431, true)
                end
            else
                player:CastSpell(player, 150430, true)
            end
        end

        if level >= 4 then -- Renaissance Robuste
            if level >= 6 then
                if level >= 8 then
                    if level >= 14 then
                        if level >= 16 then
                            if level >= 18 then
                                if level >= 24 then
                                    if level >= 26 then
                                        if level >= 28 then
                                            player:CastSpell(player, 150428, true)
                                        else
                                            player:CastSpell(player, 150427, true)
                                        end
                                    else
                                        player:CastSpell(player, 150426, true)
                                    end
                                else
                                    player:CastSpell(player, 150425, true)
                                end
                            else
                                player:CastSpell(player, 150424, true)
                            end
                        else
                            player:CastSpell(player, 150423, true)
                        end
                    else
                        player:CastSpell(player, 150422, true)
                    end
                else
                    player:CastSpell(player, 150421, true)
                end
            else
                player:CastSpell(player, 150420, true)
            end
        end

        player:CastSpell(player, 31726, true)
        Notify(player, "ALL_BUFFS")

    elseif option_id == O.SOIN then
        player:SetHealth(player:GetMaxHealth())
        player:SetPower(player:GetMaxPower())
        player:CastSpell(player, 31726, true)
        Notify(player, "HEAL")

    elseif option_id == O.RETRAIT_MAL_RESURRECTION then
        player:RemoveAura(15007)
        player:CastSpell(player, 31726, true)
        Notify(player, "REMOVE_SICKNESS")

    elseif option_id == O.REPARATION then
        player:DurabilityRepairAll(false)
        player:CastSpell(player, 31726, true)
        Notify(player, "REPAIR")

    elseif option_id == O.RESET_TALENTS then
        player:ResetTalents(true)
        player:CastSpell(player, 31726, true)
        Notify(player, "RESET_TALENTS")

    elseif option_id == O.RESET_SORTS then
        local current_time = os.time()
        local last_use = _G.RebirthOptionCooldowns[account_id]

        if last_use and (current_time - last_use < RESET_SORTS_COOLDOWN) then
            local remaining = RESET_SORTS_COOLDOWN - (current_time - last_use)
            Notify(player, "SPELLS_COOLDOWN_WAIT", remaining)
            return false
        end

        _G.RebirthOptionCooldowns[account_id] = current_time
        player:ResetAllCooldowns()
        player:CastSpell(player, 31726, true)
        Notify(player, "RESET_SPELLS")

    elseif option_id == O.RETRAIT_DESERTEUR then
        player:RemoveAura(26013)
        player:CastSpell(player, 31726, true)
        Notify(player, "REMOVE_DESERTER")

    elseif option_id == O.RESET_INSTANCES then
        player:UnbindAllInstances()
        player:CastSpell(player, 31726, true)
        Notify(player, "RESET_INSTANCES")

    else
        return false
    end

    return true
end

---
--- Teleports the player to a "Pierre Preuve de Rebirth" milestone zone.
--- Ported verbatim from Preuve_du_Rebirth.lua's OnSelect coordinates and
--- notification message.
---
--- @param player The player object
--- @param level The account's current Rebirth level
--- @param proof_id The milestone number (1-23, 25 or 30)
--- @return boolean True if the teleport was applied, false otherwise
---
local function TriggerProofTeleport(player, level, proof_id)
    local entry = FindEntryById(Config:GetProofTeleports(), "id", proof_id)
    if not entry then
        return false
    end

    if level < entry.level then
        Notify(player, "TELEPORT_LOCKED", entry.level)
        return false
    end

    player:Teleport(entry.map, entry.x, entry.y, entry.z, entry.o)
    Notify(player, "TELEPORT_SUCCESS", proof_id)

    return true
end

---
--- Grants a Heritage item directly to the player's bag. UNLIMITED : no
--- claim counter is checked or incremented at all, exactly like Pierre /
--- Pierre Preuve -- freely re-claimable every time it's clicked, as long
--- as the required Rebirth level is met.
---
--- @param player The player object
--- @param account_id The account id (unused, kept for call-site symmetry)
--- @param level The account's current Rebirth level
--- @param item_id The item id to grant
--- @return boolean True if the item was granted, false otherwise
---
local function TriggerHeritageClaim(player, account_id, level, item_id)
    local entry = FindEntryById(Config:GetHeritageItems(), "item", item_id)
    if not entry then
        return false
    end

    if level < entry.level then
        Notify(player, "HERITAGE_LOCKED", entry.level)
        return false
    end

    player:AddItem(item_id, 1)
    Notify(player, "HERITAGE_GRANTED")

    return true
end

---
--- Grants a Reward item directly to the player's bag, up to its configured
--- max_claims per account (rebirth_config_reward_items, 0 = unlimited).
--- Tracked via a per-account, per-item COUNTER (Repository:GetClaimCount /
--- IncrementClaimCount), not a one-shot flag, so the limit can be any
--- number (default 100) instead of a hard single use.
---
--- @param player The player object
--- @param account_id The account id (claim counter key)
--- @param level The account's current Rebirth level
--- @param item_id The item id to grant
--- @return boolean True if the item was granted, false otherwise
---
local function TriggerRewardClaim(player, account_id, level, item_id)
    local entry = FindEntryById(Config:GetRewardItems(), "item", item_id)
    if not entry then
        return false
    end

    if level < entry.level then
        Notify(player, "REWARD_LOCKED", entry.level)
        return false
    end

    local max_claims = entry.max_claims or 0
    if max_claims > 0 then
        local count = Repository:GetClaimCount(account_id, item_id)
        if count >= max_claims then
            Notify(player, "REWARD_LIMIT", max_claims)
            return false
        end
    end

    player:AddItem(item_id, 1)
    Repository:IncrementClaimCount(account_id, item_id)
    Notify(player, "REWARD_GRANTED")

    return true
end

---
--- Handles a client click on a row entry in any of the 4 Rebirth categories.
--- Replaces OnRebirthClientTriggerOption (Pierre-only) : dispatches by
--- category id to the appropriate handler above.
---
--- @param player The player object making the request
--- @param arg_table Table : { categoryId, entryId }
--- @return boolean True if the entry's action was applied, false otherwise
---
function OnRebirthClientTriggerEntry(player, arg_table)
    if not player or not arg_table then
        return false
    end

    local category_id = arg_table[1]
    local entry_id = arg_table[2]
    if not category_id or not entry_id then
        return false
    end

    if player:GetMap():IsBattleground() or player:GetMap():IsArena() then
        Notify(player, "NOT_IN_BG_ARENA")
        return false
    end

    if player:IsInCombat() then
        Notify(player, "NOT_IN_COMBAT")
        return false
    end

    -- FIX SYNC : recharge toujours depuis la DB, comme UpdatePlayerExperience —
    -- le cache peut etre stale dans Eluna multi-state (cross-map).
    local ok, account_id = pcall(function() return player:GetAccountId() end)
    if not ok or not account_id then
        return false
    end

    local ok2, guid_low = pcall(function() return player:GetGUIDLow() end)
    if not ok2 or not guid_low then
        return false
    end

    local rebirth = Rebirth(guid_low, account_id)
    local data = GetRebirthDataSync(guid_low, account_id)
    if data and data.level then
        rebirth.level = data.level
        rebirth.exp.current = data.current_experience or 0
        local base_max_exp = tonumber(Config:GetByField("BASE_MAX_EXPERIENCE")) or 50
        rebirth.exp.max = base_max_exp * rebirth.level
    end

    CacheSet(player, rebirth)

    local level = rebirth:GetLevel()
    local C = Constant.CATEGORIES
    local applied = false

    if category_id == C.PIERRE then
        applied = TriggerPierreOption(player, level, account_id, entry_id)
    elseif category_id == C.PIERRE_PREUVE then
        applied = TriggerProofTeleport(player, level, entry_id)
    elseif category_id == C.HERITAGE then
        applied = TriggerHeritageClaim(player, account_id, level, entry_id)
    elseif category_id == C.RECOMPENSES then
        applied = TriggerRewardClaim(player, account_id, level, entry_id)
    end

    -- Refresh the client's categories after a successful item claim, so the
    -- clicked row immediately shows "already claimed" instead of staying on
    -- the stale "click to claim" state.
    if applied and (category_id == C.HERITAGE or category_id == C.RECOMPENSES) then
        local categories = BuildCategoriesPayload(level, account_id, GetPlayerLocale(player))
        player:SendServerResponse(Hook.Addon.Prefix, 3, categories)
    end

    return applied
end

-- ============================================================================
-- PLAYER LIFECYCLE MANAGEMENT
-- ============================================================================

---
--- Handles player login event (3 = PLAYER_EVENT_ON_LOGIN).
---
function Hook.OnPlayerLogin(event, player)
    if not player then
        return
    end

    local system_enabled = tonumber(Config:GetByField("ENABLE_REBIRTH_SYSTEM")) or 1
    if system_enabled == 0 then
        return
    end

    local ok, account_id = pcall(function() return player:GetAccountId() end)
    if not ok or not account_id then
        return
    end

    local ok2, guid_low = pcall(function() return player:GetGUIDLow() end)
    if not ok2 or not guid_low then
        return
    end

    -- Au login, on vide toujours le cache pour forcer un rechargement DB
    -- propre (meme raison que Paragon : eviter des donnees perimees dans
    -- _G.RebirthCache apres un reload Eluna).
    CacheClear(guid_low)

    local rebirth = LoadRebirthSync(player)
    if not rebirth then
        return
    end

    Mediator.On("OnPlayerRebirthLoad", {
        arguments = { player, rebirth },
        defaults = { rebirth }
    })

    OnRebirthClientLoadRequest(player)

    Mediator.On("OnAfterPlayerRebirthLoad", {
        arguments = { player, rebirth },
    })
end

---
--- Handles player logout event (4 = PLAYER_EVENT_ON_LOGOUT).
---
--- Unlike Paragon, there is nothing to un-apply (no stat bonuses), and the
--- DB is already guaranteed current (every XP gain calls SaveSync
--- immediately). This hook only clears the cache so a subsequent login —
--- possibly on a different character of the same account, on a different
--- map/Lua state — starts from a guaranteed-fresh DB read instead of a
--- cache entry that could be stale in that state.
---
function Hook.OnPlayerLogout(event, player)
    if not player then
        return
    end

    local ok, account_id = pcall(function() return player:GetAccountId() end)
    if not ok or not account_id then
        return
    end

    local ok2, guid_low = pcall(function() return player:GetGUIDLow() end)
    if not ok2 or not guid_low then
        return
    end

    Mediator.On("OnBeforePlayerRebirthLogout", {
        arguments = { player, account_id },
    })

    CacheClear(guid_low)
end

---
--- Handles player save event (26 = PLAYER_EVENT_ON_SAVE). TrinityCore fires
--- this periodically during the session and just before logout, guaranteeing
--- a regular save independent of a clean logout.
---
function Hook.OnPlayerSave(event, player)
    if not player then
        return
    end

    local rebirth = CacheGet(player)
    if not rebirth then
        return
    end

    rebirth:SaveSync()
end

-- ============================================================================
-- PLAYER EXPERIENCE EVENTS
-- ============================================================================

---
--- Handles creature kill event (7 = PLAYER_EVENT_ON_KILL_CREATURE).
---
function Hook.OnPlayerKillCreature(event, player, creature)
    if not player or not creature then
        return
    end

    -- FIX POINTER INVALIDATION : le pointeur C++ de la creature peut etre
    -- detruit avant l'execution de ce hook (despawn immediat). On protege
    -- GetEntry() avec pcall, comme paragon_hook.lua.
    local ok, creature_entry = pcall(function() return creature:GetEntry() end)
    if not ok or not creature_entry then
        return
    end

    local rebirth_for_mediator = CacheGet(player)
    if not rebirth_for_mediator then
        rebirth_for_mediator = LoadRebirthSync(player)
    end

    if rebirth_for_mediator then
        Mediator.On("OnBeforeCreatureExperience", {
            arguments = { player, creature, rebirth_for_mediator },
            defaults = { rebirth_for_mediator },
        })
    end

    -- UpdatePlayerExperience recharge toujours depuis la DB — le rebirth
    -- passe ici n'est utilise que pour la coherence d'appel, il est ignore.
    UpdatePlayerExperience(player, nil, EXPERIENCE_SOURCE.CREATURE, creature_entry)
end

---
--- Handles achievement complete event (45 = PLAYER_EVENT_ON_ACHIEVEMENT_COMPLETE).
---
function Hook.OnPlayerAchievementComplete(event, player, achievement)
    if not player or not achievement then
        return
    end

    local achievement_id = (type(achievement) == "number") and achievement or achievement:GetId()

    local rebirth_for_mediator = CacheGet(player)
    if not rebirth_for_mediator then
        rebirth_for_mediator = LoadRebirthSync(player)
    end

    if rebirth_for_mediator then
        Mediator.On("OnBeforeAchievementExperience", {
            arguments = { player, achievement, rebirth_for_mediator },
            defaults = { rebirth_for_mediator },
        })
    end

    UpdatePlayerExperience(player, nil, EXPERIENCE_SOURCE.ACHIEVEMENT, achievement_id)
end

---
--- Handles quest status changed event (54 = on_quest_status_changed). Fires
--- on every status change (accept, abandon, completion...) — guarded so
--- Rebirth XP is only granted on true completion, same status value
--- paragon_hook.lua verified works correctly under this Eluna build.
---
function Hook.OnPlayerQuestComplete(event, player, quest, status)
    if not player or not quest then
        return
    end

    if status ~= 6 then
        return
    end

    local quest_id = (type(quest) == "number") and quest or quest:GetId()

    local rebirth_for_mediator = CacheGet(player)
    if not rebirth_for_mediator then
        rebirth_for_mediator = LoadRebirthSync(player)
    end

    if rebirth_for_mediator then
        Mediator.On("OnBeforeQuestExperience", {
            arguments = { player, quest_id, rebirth_for_mediator },
            defaults = { rebirth_for_mediator },
        })
    end

    UpdatePlayerExperience(player, nil, EXPERIENCE_SOURCE.QUEST, quest_id)
end

-- ============================================================================
-- EVENT REGISTRATION
-- ============================================================================

-- Player Events
RegisterPlayerEvent(3, Hook.OnPlayerLogin)
RegisterPlayerEvent(4, Hook.OnPlayerLogout)
RegisterPlayerEvent(7, Hook.OnPlayerKillCreature)
RegisterPlayerEvent(26, Hook.OnPlayerSave)  -- on_save : sauvegarde periodique + pre-logout
RegisterPlayerEvent(45, Hook.OnPlayerAchievementComplete)
RegisterPlayerEvent(54, Hook.OnPlayerQuestComplete)  -- on_quest_status_changed : filtre sur status == 6

-- Addon Communication Events
RegisterClientRequests(Hook.Addon)

return Hook
