--- Rebirth System Constants
-- Adapted from the Paragon system (see ParagonSystemToRebirthSystem.zip).
-- Defines database configuration, SQL queries and default settings for the
-- Rebirth progression system (kill creatures -> gain Rebirth XP -> level up
-- Rebirth, cap 30, no stat investment -- unlocks the Pierre de Rebirth
-- options instead, at the same level thresholds as before: 1 and 10).
-- @module rebirth_constant

return {
    --- Database name used for Rebirth system tables (characters DB, same as Paragon)
    DB_NAME = "auc_chars",

    --- Legacy database/table kept in sync so the existing Pierre_Rebirth.lua and
    --- Preuve_du_Rebirth.lua gossip/item scripts keep working UNCHANGED : they
    --- read Rebirth level from auc_eluna.rebirth_accounts.RebirthLevel.
    LEGACY_DB_NAME = "auc_eluna",
    LEGACY_TABLE   = "rebirth_accounts",

    QUERY = {
        -- Database creation
        CR_DB = "CREATE DATABASE IF NOT EXISTS `%s`;",

        --- General Configuration Table (key/value pairs)
        CR_TABLE_CONFIG = [[
            CREATE TABLE IF NOT EXISTS `%s`.`rebirth_config` (
                `field` VARCHAR(255) NOT NULL,
                `value` VARCHAR(255) NOT NULL,

                PRIMARY KEY (`field`)
            );
        ]],

        SEL_CONFIG = "SELECT `field`, `value` FROM `%s`.`rebirth_config`;",

        --- Account Rebirth Table (Rebirth is always account-wide, matching the
        --- original system where RebirthLevel was tied to the account, not a
        --- single character)
        CR_TABLE_REBIRTH_ACCOUNT = [[
            CREATE TABLE IF NOT EXISTS `%s`.`account_rebirth` (
                `account_id` INT(11) NOT NULL,
                `level` INT(11) NOT NULL DEFAULT 1,
                `experience` INT(11) NOT NULL DEFAULT 0,

                PRIMARY KEY (`account_id`)
            );
        ]],

        SEL_REBIRTH_ACCOUNT = "SELECT level, experience FROM `%s`.`account_rebirth` WHERE account_id = %d;",

        INS_REBIRTH_ACCOUNT = "INSERT INTO `%s`.`account_rebirth` (account_id, level, experience) VALUES (%d, %d, %d) ON DUPLICATE KEY UPDATE level = VALUES(level), experience = VALUES(experience);",

        DEL_REBIRTH_ACCOUNT = "DELETE FROM `%s`.`account_rebirth` WHERE account_id = %d;",

        --- Character Rebirth Table (Character-Linked) : used instead of
        --- account_rebirth when the LEVEL_LINKED_TO_ACCOUNT config field is
        --- set to '0' -- each character then keeps its own independent
        --- Rebirth level/experience, mirroring Paragon's character_paragon
        --- table exactly.
        CR_TABLE_REBIRTH_CHARACTER = [[
            CREATE TABLE IF NOT EXISTS `%s`.`character_rebirth` (
                `guid` INT(11) NOT NULL,
                `level` INT(11) NOT NULL DEFAULT 1,
                `experience` INT(11) NOT NULL DEFAULT 0,

                PRIMARY KEY (`guid`)
            );
        ]],

        SEL_REBIRTH_CHARACTER = "SELECT level, experience FROM `%s`.`character_rebirth` WHERE guid = %d;",

        INS_REBIRTH_CHARACTER = "INSERT INTO `%s`.`character_rebirth` (guid, level, experience) VALUES (%d, %d, %d) ON DUPLICATE KEY UPDATE level = VALUES(level), experience = VALUES(experience);",

        DEL_REBIRTH_CHARACTER = "DELETE FROM `%s`.`character_rebirth` WHERE guid = %d;",

        --- One-time claim tracking for Heritage/Reward items (category
        --- HERITAGE / RECOMPENSES) : prevents an account from clicking the
        --- same unlocked item row over and over to farm infinite copies of
        --- heirlooms or +XP scrolls. Not used by PIERRE (buffs, meant to be
        --- reusable) or PIERRE_PREUVE (teleports, no item granted).
        --- account_rebirth_claims.claim_count : a COUNTER rather than a
        --- one-time flag, so a claim limit can be a number > 1 (Recompenses,
        --- default 100 -- see rebirth_config_reward_items) rather than a
        --- hard one-shot lock. Heritage entries never check this counter at
        --- all (unlimited, freely re-claimable once unlocked).
        CR_TABLE_CLAIMS = [[
            CREATE TABLE IF NOT EXISTS `%s`.`account_rebirth_claims` (
                `account_id` INT(11) NOT NULL,
                `item_id` INT(11) NOT NULL,
                `claim_count` INT(11) NOT NULL DEFAULT 0,

                PRIMARY KEY (`account_id`, `item_id`)
            );
        ]],

        --- Migration for installs upgraded from before claim_count existed :
        --- checked via information_schema (not "ADD COLUMN IF NOT EXISTS",
        --- unsupported on older MySQL/MariaDB builds) in
        --- Repository:VerifyDatabaseSchema before this ALTER ever runs.
        SEL_CLAIMS_HAS_COUNT_COLUMN = "SELECT 1 FROM information_schema.columns WHERE table_schema = '%s' AND table_name = 'account_rebirth_claims' AND column_name = 'claim_count' LIMIT 1;",

        ALTER_CLAIMS_ADD_COUNT = "ALTER TABLE `%s`.`account_rebirth_claims` ADD COLUMN `claim_count` INT(11) NOT NULL DEFAULT 1;",

        SEL_CLAIM_COUNT = "SELECT claim_count FROM `%s`.`account_rebirth_claims` WHERE account_id = %d AND item_id = %d;",

        INS_CLAIM_INCREMENT = "INSERT INTO `%s`.`account_rebirth_claims` (account_id, item_id, claim_count) VALUES (%d, %d, 1) ON DUPLICATE KEY UPDATE claim_count = claim_count + 1;",

        SEL_CLAIMS_COUNTS_FOR_ACCOUNT = "SELECT item_id, claim_count FROM `%s`.`account_rebirth_claims` WHERE account_id = %d;",

        --- Experience Reward Configuration Tables (per-entry overrides)
        CR_TABLE_CONFIG_EXP_CREATURE = [[
            CREATE TABLE IF NOT EXISTS `%s`.`rebirth_config_experience_creature` (
                `id` INT(11) NOT NULL,
                `experience` INT(11) NOT NULL DEFAULT 1,

                PRIMARY KEY (`id`)
            );
        ]],

        CR_TABLE_CONFIG_EXP_ACHIEVEMENT = [[
            CREATE TABLE IF NOT EXISTS `%s`.`rebirth_config_experience_achievement` (
                `id` INT(11) NOT NULL,
                `experience` INT(11) NOT NULL DEFAULT 0,

                PRIMARY KEY (`id`)
            );
        ]],

        CR_TABLE_CONFIG_EXP_SKILL = [[
            CREATE TABLE IF NOT EXISTS `%s`.`rebirth_config_experience_skill` (
                `id` INT(11) NOT NULL,
                `experience` INT(11) NOT NULL DEFAULT 0,

                PRIMARY KEY (`id`)
            );
        ]],

        CR_TABLE_CONFIG_EXP_QUEST = [[
            CREATE TABLE IF NOT EXISTS `%s`.`rebirth_config_experience_quest` (
                `id` INT(11) NOT NULL,
                `experience` INT(11) NOT NULL DEFAULT 0,

                PRIMARY KEY (`id`)
            );
        ]],

        SEL_CONFIG_EXP_CREATURE    = "SELECT id, experience FROM `%s`.`rebirth_config_experience_creature`;",
        SEL_CONFIG_EXP_ACHIEVEMENT = "SELECT id, experience FROM `%s`.`rebirth_config_experience_achievement`;",
        SEL_CONFIG_EXP_SKILL       = "SELECT id, experience FROM `%s`.`rebirth_config_experience_skill`;",
        SEL_CONFIG_EXP_QUEST       = "SELECT id, experience FROM `%s`.`rebirth_config_experience_quest`;",

        --- ====================================================================
        --- EDITABLE-IN-DATABASE CONTENT TABLES (Pierre / Pierre Preuve /
        --- Heritage / Recompenses) -- an admin can add, remove or re-level
        --- any entry directly via SQL without touching Lua code. Seeded
        --- once from the values below (same content this system already
        --- shipped with) via INSERT IGNORE, so existing installs upgrading
        --- to this version keep their exact current behaviour on first boot.
        --- Loaded once at startup by rebirth_config.lua (Config:GetPierreOptions()
        --- / GetProofTeleports() / GetHeritageItems() / GetRewardItems()) ;
        --- restart the server (or re-run the migration) to pick up DB edits.
        --- ====================================================================

        CR_TABLE_CONFIG_PIERRE_OPTIONS = [[
            CREATE TABLE IF NOT EXISTS `%s`.`rebirth_config_pierre_options` (
                `option_id` INT(11) NOT NULL,
                `required_level` INT(11) NOT NULL DEFAULT 1,
                `name` VARCHAR(128) NULL DEFAULT NULL,
                `icon` VARCHAR(128) NULL DEFAULT NULL,

                PRIMARY KEY (`option_id`)
            );
        ]],

        SEL_CONFIG_PIERRE_OPTIONS = "SELECT option_id, required_level, name, icon FROM `%s`.`rebirth_config_pierre_options`;",

        --- Migration for installs created before name/icon existed on this
        --- table (checked via information_schema, see the claim_count
        --- migration above for the same pattern).
        SEL_PIERRE_OPTIONS_HAS_NAME_COL = "SELECT 1 FROM information_schema.columns WHERE table_schema = '%s' AND table_name = 'rebirth_config_pierre_options' AND column_name = 'name' LIMIT 1;",

        ALTER_PIERRE_OPTIONS_ADD_NAME_ICON = "ALTER TABLE `%s`.`rebirth_config_pierre_options` ADD COLUMN `name` VARCHAR(128) NULL DEFAULT NULL, ADD COLUMN `icon` VARCHAR(128) NULL DEFAULT NULL;",

        --- option_id values match Constant.OPTIONS (Pierre_Rebirth.lua's
        --- legacy intids) : the buff/effect LOGIC for each id stays in Lua
        --- (TriggerPierreOption in rebirth_hook.lua), only the required
        --- Rebirth level AND the display name/icon are DB-editable here.
        --- name/icon seeded from Rebirth_Locales.lua's OPTIONS_INFO (same
        --- wording/icons already shown client-side) so an admin sees
        --- meaningful values immediately instead of blank columns, and can
        --- override them without touching any Lua file.
        INS_DEFAULT_PIERRE_OPTIONS = [[
            INSERT IGNORE INTO `%s`.`rebirth_config_pierre_options` (option_id, required_level, name, icon) VALUES
            (1, 1, 'Amélioration d\'état', 'Interface\\Icons\\Spell_Holy_DivineIllumination'),
            (2, 1, 'Soin', 'Interface\\Icons\\Spell_Holy_Heal'),
            (3, 1, 'Retirer le mal de résurrection', 'Interface\\Icons\\Spell_Nature_Reincarnation'),
            (7, 1, 'Réparer l\'équipement', 'Interface\\Icons\\Trade_BlackSmithing'),
            (9, 10, 'Réinitialiser les talents', 'Interface\\Icons\\INV_Misc_Book_11'),
            (13, 10, 'Réinitialiser le temps des sorts', 'Interface\\Icons\\Spell_Nature_TimeStop'),
            (14, 10, 'Retirer le déserteur', 'Interface\\Icons\\Ability_Vanish'),
            (20, 10, 'Réinitialiser les instances', 'Interface\\Icons\\INV_Misc_Map_01');
        ]],

        CR_TABLE_CONFIG_PROOF_TELEPORTS = [[
            CREATE TABLE IF NOT EXISTS `%s`.`rebirth_config_proof_teleports` (
                `id` INT(11) NOT NULL,
                `required_level` INT(11) NOT NULL,
                `map` INT(11) NOT NULL,
                `x` FLOAT NOT NULL,
                `y` FLOAT NOT NULL,
                `z` FLOAT NOT NULL,
                `o` FLOAT NOT NULL,
                `name` VARCHAR(128) NULL DEFAULT NULL,
                `icon` VARCHAR(128) NULL DEFAULT NULL,

                PRIMARY KEY (`id`)
            );
        ]],

        SEL_CONFIG_PROOF_TELEPORTS = "SELECT id, required_level, map, x, y, z, o, name, icon FROM `%s`.`rebirth_config_proof_teleports` ORDER BY id;",

        SEL_PROOF_TELEPORTS_HAS_NAME_COL = "SELECT 1 FROM information_schema.columns WHERE table_schema = '%s' AND table_name = 'rebirth_config_proof_teleports' AND column_name = 'name' LIMIT 1;",

        ALTER_PROOF_TELEPORTS_ADD_NAME_ICON = "ALTER TABLE `%s`.`rebirth_config_proof_teleports` ADD COLUMN `name` VARCHAR(128) NULL DEFAULT NULL, ADD COLUMN `icon` VARCHAR(128) NULL DEFAULT NULL;",

        --- name/icon seeded with the same generic "Preuve du Rebirth N" /
        --- INV_Misc_Rune_01 pattern already used client-side (Rebirth_Locales.lua
        --- PROOF_INFO), so an admin can rename individual teleports in DB
        --- without touching Lua.
        INS_DEFAULT_PROOF_TELEPORTS = [[
            INSERT IGNORE INTO `%s`.`rebirth_config_proof_teleports` (id, required_level, map, x, y, z, o, name, icon) VALUES
            (1, 1, 790, 1769.7, 1956.42, 171.919, 1.64839, 'Preuve du Rebirth 1', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (2, 2, 790, 1943.65, 1878.12, 172.419, 5.15801, 'Preuve du Rebirth 2', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (3, 3, 790, 1796.24, 1930, 219.407, 4.91501, 'Preuve du Rebirth 3', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (4, 4, 789, -1038.06, 986.274, 39.8764, 0.134207, 'Preuve du Rebirth 4', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (5, 5, 787, 1326.85, 3951.82, 146.721, 0.526314, 'Preuve du Rebirth 5', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (6, 6, 787, 1050.13, 3452.75, 22.9212, 4.13536, 'Preuve du Rebirth 6', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (7, 7, 787, 1202.98, 4021.83, 17.8164, 2.35377, 'Preuve du Rebirth 7', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (8, 8, 787, 778.766, 4108, 10.7071, 4.71718, 'Preuve du Rebirth 8', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (9, 9, 787, 794.676, 3964.91, 15.1994, 1.46751, 'Preuve du Rebirth 9', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (10, 10, 787, 831.401, 4040.64, 11.4455, 4.5403, 'Preuve du Rebirth 10', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (11, 11, 787, 770.165, 3961.95, 16.2116, 3.66332, 'Preuve du Rebirth 11', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (12, 12, 787, 344.784, 3930.99, 11.7014, 1.0129, 'Preuve du Rebirth 12', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (13, 13, 787, 366.739, 4002.49, 8.22053, 4.03824, 'Preuve du Rebirth 13', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (14, 14, 787, 427.101, 3935.04, 10.8254, 2.20355, 'Preuve du Rebirth 14', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (15, 15, 805, 769.36, 3962.35, 16.2566, 0.178442, 'Preuve du Rebirth 15', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (16, 16, 805, 794.549, 3965.46, 15.1994, 1.48086, 'Preuve du Rebirth 16', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (17, 17, 805, 831.177, 4039.4, 11.4804, 1.60206, 'Preuve du Rebirth 17', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (18, 18, 805, 622.997, 4021.16, 2.26248, 5.14433, 'Preuve du Rebirth 18', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (19, 19, 805, 671.665, 4088.43, 11.0523, 1.58553, 'Preuve du Rebirth 19', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (20, 20, 806, 4979.15, -4072.42, 39.1177, 0.37697, 'Preuve du Rebirth 20', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (21, 21, 806, 4758.56, -4079.27, 7.38757, 1.93283, 'Preuve du Rebirth 21', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (22, 22, 806, 3689.28, -3996.02, 29.9337, 4.05044, 'Preuve du Rebirth 22', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (23, 23, 806, 3574.12, -3930.26, 22.7411, 4.84368, 'Preuve du Rebirth 23', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (25, 25, 806, -621.186, -1504.62, -23.0804, 3.99204, 'Preuve du Rebirth 25', 'Interface\\Icons\\INV_Misc_Rune_01'),
            (30, 30, 806, -146.922, -1931.93, 81.5285, 4.80995, 'Preuve du Rebirth 30', 'Interface\\Icons\\INV_Misc_Rune_01');
        ]],

        CR_TABLE_CONFIG_HERITAGE_ITEMS = [[
            CREATE TABLE IF NOT EXISTS `%s`.`rebirth_config_heritage_items` (
                `item_id` INT(11) NOT NULL,
                `required_level` INT(11) NOT NULL,
                `name` VARCHAR(128) NULL DEFAULT NULL,
                `icon` VARCHAR(128) NULL DEFAULT NULL,

                PRIMARY KEY (`item_id`)
            );
        ]],

        SEL_CONFIG_HERITAGE_ITEMS = "SELECT item_id, required_level, name, icon FROM `%s`.`rebirth_config_heritage_items` ORDER BY required_level, item_id;",

        --- Migration for installs created before name/icon existed. No known
        --- real name/icon data exists for these custom items anywhere in
        --- this project (see this round's investigation), so they stay
        --- NULL by default -- BuildHeritageEntries only sends name/icon to
        --- the client when an admin has explicitly set them in DB, and the
        --- client keeps falling back to GetItemInfo()/the "?" placeholder
        --- exactly as before otherwise. Setting an explicit icon here is
        --- what permanently eliminates the "?" sync issue for a given item.
        SEL_HERITAGE_ITEMS_HAS_NAME_COL = "SELECT 1 FROM information_schema.columns WHERE table_schema = '%s' AND table_name = 'rebirth_config_heritage_items' AND column_name = 'name' LIMIT 1;",

        ALTER_HERITAGE_ITEMS_ADD_NAME_ICON = "ALTER TABLE `%s`.`rebirth_config_heritage_items` ADD COLUMN `name` VARCHAR(128) NULL DEFAULT NULL, ADD COLUMN `icon` VARCHAR(128) NULL DEFAULT NULL;",

        --- Heritage has NO claim limit at all (see BuildHeritageEntries /
        --- TriggerHeritageClaim in rebirth_hook.lua) -- unlocked items stay
        --- freely re-claimable forever, exactly like Pierre/Pierre Preuve.
        INS_DEFAULT_HERITAGE_ITEMS = [[
            INSERT IGNORE INTO `%s`.`rebirth_config_heritage_items` (item_id, required_level) VALUES
            (42943, 1),
            (42944, 1),
            (42945, 2),
            (42946, 2),
            (42947, 3),
            (42948, 3),
            (42991, 4),
            (42992, 4),
            (44091, 4),
            (44092, 5),
            (44093, 5),
            (44094, 6),
            (44095, 6),
            (44096, 7),
            (44097, 7),
            (44098, 8),
            (48716, 8),
            (48718, 8),
            (50255, 9),
            (5000100, 9),
            (5000101, 10),
            (5000102, 10),
            (5000103, 11),
            (5000104, 11),
            (5000105, 12),
            (5000106, 12),
            (5000107, 12),
            (5000110, 13),
            (5000111, 13),
            (5000112, 14),
            (5000113, 14),
            (5000114, 15),
            (5000115, 15),
            (5000116, 15),
            (5000117, 16),
            (5000120, 16),
            (5000121, 17),
            (5000122, 17),
            (5000123, 18),
            (5000124, 18),
            (5000125, 19),
            (5000126, 19),
            (5000127, 19),
            (5000130, 20),
            (5000131, 20),
            (5000132, 21),
            (5000133, 21),
            (5000134, 22),
            (5000135, 22),
            (5000136, 23),
            (5000137, 23),
            (5000140, 23),
            (5000141, 24),
            (5000142, 24),
            (5000143, 25),
            (5000144, 25),
            (5000145, 26),
            (5000146, 26),
            (5000147, 27),
            (5000150, 27),
            (5000151, 27),
            (5000152, 28),
            (5000153, 28),
            (5000154, 29),
            (5000155, 29),
            (5000156, 30),
            (5000157, 30),
            (5000160, 30);
        ]],

        CR_TABLE_CONFIG_REWARD_ITEMS = [[
            CREATE TABLE IF NOT EXISTS `%s`.`rebirth_config_reward_items` (
                `item_id` INT(11) NOT NULL,
                `required_level` INT(11) NOT NULL,
                `max_claims` INT(11) NOT NULL DEFAULT 100,
                `name` VARCHAR(128) NULL DEFAULT NULL,
                `icon` VARCHAR(128) NULL DEFAULT NULL,

                PRIMARY KEY (`item_id`)
            );
        ]],

        SEL_CONFIG_REWARD_ITEMS = "SELECT item_id, required_level, max_claims, name, icon FROM `%s`.`rebirth_config_reward_items` ORDER BY required_level, item_id;",

        --- Migration for installs created before name/icon existed (see
        --- Heritage's identical comment above -- same NULL-by-default /
        --- admin-can-set-explicit-icon reasoning applies here).
        SEL_REWARD_ITEMS_HAS_NAME_COL = "SELECT 1 FROM information_schema.columns WHERE table_schema = '%s' AND table_name = 'rebirth_config_reward_items' AND column_name = 'name' LIMIT 1;",

        ALTER_REWARD_ITEMS_ADD_NAME_ICON = "ALTER TABLE `%s`.`rebirth_config_reward_items` ADD COLUMN `name` VARCHAR(128) NULL DEFAULT NULL, ADD COLUMN `icon` VARCHAR(128) NULL DEFAULT NULL;",

        --- max_claims = 0 means unlimited (same behaviour as Heritage), any
        --- positive value caps the number of times that item can be claimed
        --- per account. Defaults to 100 as requested.
        INS_DEFAULT_REWARD_ITEMS = [[
            INSERT IGNORE INTO `%s`.`rebirth_config_reward_items` (item_id, required_level, max_claims) VALUES
            (90006, 15, 100),
            (90008, 30, 100);
        ]],

        --- Default configuration values, inserted once at first server start.
        --- BASE_MAX_EXPERIENCE=50 + UNIVERSAL_CREATURE_EXPERIENCE=1 reproduces
        --- exactly the curve requested : level N -> N+1 costs 50*N kills
        --- (50, 100, 150 ... 1450 for level 29 -> 30), capped at level 30.
        INS_DEFAULT_CONFIG = [[
            INSERT IGNORE INTO `%s`.`rebirth_config` (field, value) VALUES
            -- System Control
            ('ENABLE_REBIRTH_SYSTEM', '1'),
            ('MINIMUM_LEVEL_FOR_REBIRTH_XP', '0'),
            ('REBIRTH_LEVEL_CAP', '30'),
            ('LEVEL_LINKED_TO_ACCOUNT', '1'),

            -- Progression Settings
            ('BASE_MAX_EXPERIENCE', '50'),
            ('REBIRTH_STARTING_LEVEL', '1'),
            ('REBIRTH_STARTING_EXPERIENCE', '0'),

            -- Experience Rewards (Universal Defaults) : uniquement les kills de
            -- creatures comptent par defaut (comme demande), les autres sources
            -- sont presentes mais desactivees (0) pour rester configurables.
            ('UNIVERSAL_CREATURE_EXPERIENCE', '1'),
            ('UNIVERSAL_ACHIEVEVEMENT_EXPERIENCE', '0'),
            ('UNIVERSAL_SKILL_EXPERIENCE', '0'),
            ('UNIVERSAL_QUEST_EXPERIENCE', '0'),

            -- Level-up visual (spell instantly cast + removed after 3s)
            ('LEVEL_UP_ANIMATION', '64785');
        ]]
    },

    --- Option identifiers used by the Pierre de Rebirth panel (replaces the
    --- old gossip menu intids from Pierre_Rebirth.lua -- SAME numbering kept
    --- for traceability with the legacy file).
    OPTIONS = {
        BUFF_AMELIORATION_ETAT   = 1,
        SOIN                     = 2,
        RETRAIT_MAL_RESURRECTION = 3,
        REPARATION               = 7,
        RESET_TALENTS            = 9,
        RESET_SORTS              = 13,
        RETRAIT_DESERTEUR        = 14,
        RESET_INSTANCES          = 20,
    },

    --- Rebirth level required to unlock each tier of options (identical
    --- thresholds to the original Pierre_Rebirth.lua gossip menu).
    OPTIONS_TIER_1_LEVEL = 1,  -- Amelioration d'etat / Soin / Retrait mal resurrection / Reparation
    OPTIONS_TIER_2_LEVEL = 10, -- Reset talents / Reset sorts / Retrait deserteur / Reset instances,

-- ============================================================================
-- CATEGORIES (UI layout : 4 category rows, Paragon-style, replacing stats)
-- ============================================================================

--- Category identifiers used by both server (rebirth_hook.lua) and client
--- (Rebirth_Interface.lua) to know which click-behaviour applies to a row's
--- entries : PIERRE triggers a buff/effect, PIERRE_PREUVE teleports, and
--- HERITAGE/RECOMPENSES both grant an item straight to the player's bag.
CATEGORIES = {
    PIERRE = 1,
    PIERRE_PREUVE = 2,
    HERITAGE = 3,
    RECOMPENSES = 4,
},

--- Pierre Preuve de Rebirth (item 80001) teleport milestones. Ported
--- verbatim from [System] Preuve_du_Rebirth.lua's OnSelect coordinates ;
--- required level == the "Preuve du Rebirth N" gossip label number (same
--- gating the legacy gossip menu already used : level >= N).
PROOF_TELEPORTS = {
        { id = 1, level = 1, map = 790, x = 1769.7, y = 1956.42, z = 171.919, o = 1.64839 },
        { id = 2, level = 2, map = 790, x = 1943.65, y = 1878.12, z = 172.419, o = 5.15801 },
        { id = 3, level = 3, map = 790, x = 1796.24, y = 1930, z = 219.407, o = 4.91501 },
        { id = 4, level = 4, map = 789, x = -1038.06, y = 986.274, z = 39.8764, o = 0.134207 },
        { id = 5, level = 5, map = 787, x = 1326.85, y = 3951.82, z = 146.721, o = 0.526314 },
        { id = 6, level = 6, map = 787, x = 1050.13, y = 3452.75, z = 22.9212, o = 4.13536 },
        { id = 7, level = 7, map = 787, x = 1202.98, y = 4021.83, z = 17.8164, o = 2.35377 },
        { id = 8, level = 8, map = 787, x = 778.766, y = 4108, z = 10.7071, o = 4.71718 },
        { id = 9, level = 9, map = 787, x = 794.676, y = 3964.91, z = 15.1994, o = 1.46751 },
        { id = 10, level = 10, map = 787, x = 831.401, y = 4040.64, z = 11.4455, o = 4.5403 },
        { id = 11, level = 11, map = 787, x = 770.165, y = 3961.95, z = 16.2116, o = 3.66332 },
        { id = 12, level = 12, map = 787, x = 344.784, y = 3930.99, z = 11.7014, o = 1.0129 },
        { id = 13, level = 13, map = 787, x = 366.739, y = 4002.49, z = 8.22053, o = 4.03824 },
        { id = 14, level = 14, map = 787, x = 427.101, y = 3935.04, z = 10.8254, o = 2.20355 },
        { id = 15, level = 15, map = 805, x = 769.36, y = 3962.35, z = 16.2566, o = 0.178442 },
        { id = 16, level = 16, map = 805, x = 794.549, y = 3965.46, z = 15.1994, o = 1.48086 },
        { id = 17, level = 17, map = 805, x = 831.177, y = 4039.4, z = 11.4804, o = 1.60206 },
        { id = 18, level = 18, map = 805, x = 622.997, y = 4021.16, z = 2.26248, o = 5.14433 },
        { id = 19, level = 19, map = 805, x = 671.665, y = 4088.43, z = 11.0523, o = 1.58553 },
        { id = 20, level = 20, map = 806, x = 4979.15, y = -4072.42, z = 39.1177, o = 0.37697 },
        { id = 21, level = 21, map = 806, x = 4758.56, y = -4079.27, z = 7.38757, o = 1.93283 },
        { id = 22, level = 22, map = 806, x = 3689.28, y = -3996.02, z = 29.9337, o = 4.05044 },
        { id = 23, level = 23, map = 806, x = 3574.12, y = -3930.26, z = 22.7411, o = 4.84368 },
        { id = 25, level = 25, map = 806, x = -621.186, y = -1504.62, z = -23.0804, o = 3.99204 },
        { id = 30, level = 30, map = 806, x = -146.922, y = -1931.93, z = 81.5285, o = 4.80995 },
    },

--- Heritage items (see ListHeirloom.txt, 68 entries) : unlocked
--- progressively across the 30 Rebirth levels (roughly 2 items per level).
--- Clicking a row entry grants the item directly to the player's bag.
HERITAGE_ITEMS = {
        { item = 42943, level = 1 },
        { item = 42944, level = 1 },
        { item = 42945, level = 2 },
        { item = 42946, level = 2 },
        { item = 42947, level = 3 },
        { item = 42948, level = 3 },
        { item = 42991, level = 4 },
        { item = 42992, level = 4 },
        { item = 44091, level = 4 },
        { item = 44092, level = 5 },
        { item = 44093, level = 5 },
        { item = 44094, level = 6 },
        { item = 44095, level = 6 },
        { item = 44096, level = 7 },
        { item = 44097, level = 7 },
        { item = 44098, level = 8 },
        { item = 48716, level = 8 },
        { item = 48718, level = 8 },
        { item = 50255, level = 9 },
        { item = 5000100, level = 9 },
        { item = 5000101, level = 10 },
        { item = 5000102, level = 10 },
        { item = 5000103, level = 11 },
        { item = 5000104, level = 11 },
        { item = 5000105, level = 12 },
        { item = 5000106, level = 12 },
        { item = 5000107, level = 12 },
        { item = 5000110, level = 13 },
        { item = 5000111, level = 13 },
        { item = 5000112, level = 14 },
        { item = 5000113, level = 14 },
        { item = 5000114, level = 15 },
        { item = 5000115, level = 15 },
        { item = 5000116, level = 15 },
        { item = 5000117, level = 16 },
        { item = 5000120, level = 16 },
        { item = 5000121, level = 17 },
        { item = 5000122, level = 17 },
        { item = 5000123, level = 18 },
        { item = 5000124, level = 18 },
        { item = 5000125, level = 19 },
        { item = 5000126, level = 19 },
        { item = 5000127, level = 19 },
        { item = 5000130, level = 20 },
        { item = 5000131, level = 20 },
        { item = 5000132, level = 21 },
        { item = 5000133, level = 21 },
        { item = 5000134, level = 22 },
        { item = 5000135, level = 22 },
        { item = 5000136, level = 23 },
        { item = 5000137, level = 23 },
        { item = 5000140, level = 23 },
        { item = 5000141, level = 24 },
        { item = 5000142, level = 24 },
        { item = 5000143, level = 25 },
        { item = 5000144, level = 25 },
        { item = 5000145, level = 26 },
        { item = 5000146, level = 26 },
        { item = 5000147, level = 27 },
        { item = 5000150, level = 27 },
        { item = 5000151, level = 27 },
        { item = 5000152, level = 28 },
        { item = 5000153, level = 28 },
        { item = 5000154, level = 29 },
        { item = 5000155, level = 29 },
        { item = 5000156, level = 30 },
        { item = 5000157, level = 30 },
        { item = 5000160, level = 30 },
    },

--- Reward items : 90006 (scroll, +100 XP) and 90008 (scroll, +250 XP).
--- Clicking grants the item to the bag ; the existing (unmodified)
--- [System] RebirthExpItem.lua / RebirthExpItem2.lua scripts already
--- handle the XP grant when the player uses the item from their bag.
REWARD_ITEMS = {
        { item = 90006, level = 15 },
        { item = 90008, level = 30 },
    },
}
