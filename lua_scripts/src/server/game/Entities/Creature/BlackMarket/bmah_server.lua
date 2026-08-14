-- ────────────────────────────────────────────────────────────────────────────────
-- ────────────────────────────────────────────────────────────────────────────────
-- BLACK MARKET AUCTION HOUSE 3.3.5 BACKPORT 
-- ────────────────────────────────────────────────────────────────────────────────
-- ────────────────────────────────────────────────────────────────────────────────

-- ─── Vendor NPC Configuration ───────────────────────────────────────────────
-- List the NPC IDs that will serve as Black Market Auction House vendors.
-- Interacting with any of these IDs will open the BMAH UI for players.
-- Add or remove IDs here as your server requires.

-- IMPORTANT: only creature entries listed here trigger the Black Market
-- gossip/open flow (OnBMAHVendorGossip below). If you are interacting with
-- your server's normal Auctioneer NPCs and NOT one of the entries listed
-- here, the "OPEN" addon message is never sent and none of this system
-- runs for that NPC -- add every Auctioneer entry you want to act as a BMAH
-- vendor to this list. 228404 ("Test Subject") is a placeholder/example.
local BMAH_VENDOR_NPCs = {
  228404, --Test Subject
  --#######, --Add More Here
}
-- ─────────────────────────────────────────────────────────────────────────────
-- ─── Fill-rarity configuration ───────────────────────────────────────────────────
-- Tweak these three values to adjust your loot rarity probabilities.
-- They represent the *cumulative* thresholds for a random roll r = math.random():
--
--   0.00 ≤ r < FillRateCommon   → pick from commonItems
--   FillRateCommon ≤ r < FillRateRare     → pick from rareItems
--   FillRateRare ≤ r ≤ FillRateUltra      → pick from ultraRareItems
--
-- Requirements:
--  1) 0.0  ≤ FillRateCommon
--  2) FillRateCommon ≤ FillRateRare
--  3) FillRateRare   ≤ FillRateUltra
--  4) FillRateUltra ≤ 1.0
--
-- Example distributions:
--   FillRateCommon = 0.70   → 70% common
--   FillRateRare   = 0.90   → 20% rare  (0.90 - 0.70)
--   FillRateUltra  = 1.00   → 10% ultra (1.00 - 0.90)
--
-- Implementation note:
--   local r = math.random()  -- returns a float 0 <= r < 1 (or ≤1 depending on build)
--   if r < FillRateCommon then
--       -- common
--   elseif r < FillRateRare then
--       -- rare
--   else
--       -- ultra
--   end
--
local FillRateCommon   = 0.85   -- e.g. 85% chance for commonItems
local FillRateRare     = 0.95   -- next 10% (95% - 85%) for rareItems
local FillRateUltra    = 1.00   -- final 5%  (100% - 95%) for ultraRareItems
-- ──────────────────────────────────────────────────────────────────────────────

-- ─── Fill-count configuration ─────────────────────────────────────────────────
-- Every time the Black Market gets (re)filled, it inserts a random number of
-- rows between MinFillCount and MaxFillCount (inclusive). Adjust these two
-- values to change how many auctions are available at once.
local MinFillCount = 6
local MaxFillCount = 8
-- ───────────────────────────────────────────────────────────────────────────────

-- ─── Bidding rules ────────────────────────────────────────────────────────────
local MinBidIncrementG   = 10       -- how many gold above last_bid is required
-- ──────────────────────────────────────────────────────────────────────────────
-- ─── General timing & chance ──────────────────────────────────────────────────
local AutoFillChance     = 0.50        -- chance to auto-fill when table is empty
local PotentialDurations = {720, 1440} -- possible “time left” values (in minutes)
-- ───────────────────────────────────────────────────────────────────────────────
-- ─── Refund‐mail configuration ─────────────────────────────────────────────────
local RefundMailSender     = 0         
local RefundStationery     = 41     
-- Subject/body are now localized per-recipient -- see SERVER_LOCALES below
-- (REFUND_SUBJECT/REFUND_BODY), replacing the old fixed English-only locals.
-- ────────────────────────────────────────────────────────────────────────────────

-- ─── Flush‐notify configuration ────────────────────────────────────────────────
local FlushMailSender      = 0  
local FlushMailStationery  = 62 
-- Subject/body are now localized per-recipient -- see SERVER_LOCALES below
-- (WIN_SUBJECT/WIN_BODY), replacing the old fixed English-only locals.
-- ───────────────────────────────────────────────────────────────────────────────

----------------------------------------------------------------------------
-- Localization (frFR / enUS)
----------------------------------------------------------------------------
-- This Eluna build has no verified, reliable way to read a player's client
-- locale directly from the server (guessing an API here risks another crash
-- like the tpl:GetIcon() one). Instead the CLIENT sends its own GetLocale()
-- along with every BMAH_REQ whisper (see BlackMarketUI.lua and the REQ
-- handler below); we remember it here per player GUID and use it for every
-- message sent back to that player. Falls back to enUS if unknown (e.g. a
-- mail recipient who never opened the Black Market window this session).
local PlayerLocale = {}

local SERVER_LOCALES = {
  frFR = {
    NO_PERM_FLUSH   = "Vous n'avez pas la permission de vider la table BlackMarketAH.",
    FLUSHED         = "BlackMarketAH a ete videe. Tous les objets gagnes ont ete envoyes par courrier !",
    NO_PERM_FILL    = "Vous n'avez pas la permission de remplir la table BlackMarketAH.",
    ALREADY_FILLED  = "BlackMarketAH a deja des encheres actives. Videz-la d'abord.",
    FILLED          = "BlackMarketAH a ete remplie avec %d ligne(s).",
    INVALID_BID     = "Format d'enchere invalide.",
    NOT_FOUND       = "Enchere introuvable.",
    ALREADY_HIGHEST = "Vous detenez deja la meilleure enchere sur cet objet.",
    NOT_ENOUGH_GOLD = "Vous n'avez pas assez d'or pour cette enchere.",
    BID_TOO_LOW     = "Votre enchere doit etre d'au moins %dg.",
    BID_ACCEPTED    = "Votre enchere de %dg a ete acceptee !",
    REFUND_SUBJECT  = "[BMAH] Remboursement (surenchere)",
    REFUND_BODY     = "Vous avez ete surencheri sur l'Hotel des ventes du marche noir. Votre enchere de %dg vous a ete remboursee.",
    WIN_SUBJECT     = "[BMAH] Vous avez remporte votre enchere !",
    WIN_BODY        = "Felicitations ! Vous avez remporte un objet sur l'Hotel des ventes du marche noir.\nApres avoir depense %dg, « %s » est maintenant a vous ! Profitez-en.\n\n- L'Hotel des ventes du marche noir",
    TIME_SHORT      = "Courte",
    TIME_MEDIUM     = "Moyenne",
    TIME_LONG       = "Longue",
    TIME_VERY_LONG  = "Tres longue",
  },
  enUS = {
    NO_PERM_FLUSH   = "You do not have permission to flush the BlackMarketAH table.",
    FLUSHED         = "BlackMarketAH has been flushed. All won items have been mailed out!",
    NO_PERM_FILL    = "You do not have permission to refill the BlackMarketAH table.",
    ALREADY_FILLED  = "BlackMarketAH already has active auctions. Please flush first.",
    FILLED          = "Filled BlackMarketAH with %d rows.",
    INVALID_BID     = "Invalid bid format.",
    NOT_FOUND       = "Auction entry not found.",
    ALREADY_HIGHEST = "You already hold the highest bid on that auction.",
    NOT_ENOUGH_GOLD = "You lack the funds for that bid.",
    BID_TOO_LOW     = "Your bid must be at least %dg.",
    BID_ACCEPTED    = "Your bid of %dg has been accepted!",
    REFUND_SUBJECT  = "[BMAH] Outbid Refund",
    REFUND_BODY     = "You were outbid on the Black Market Auction House. Your bid of %dg has been returned.",
    WIN_SUBJECT     = "[BMAH] You've won your auction!",
    WIN_BODY        = "Congratulations! You have successfully won an item off the Black Market Auction House.\nAfter spending %dg, \"%s\" is now yours! Enjoy.\n\n- The Black Market AH",
    TIME_SHORT      = "Short",
    TIME_MEDIUM     = "Medium",
    TIME_LONG       = "Long",
    TIME_VERY_LONG  = "Very Long",
  },
}

-- Locale table for a given player GUID (falls back to enUS if unknown).
local function BMAH_LocaleFor(guidLow)
  return SERVER_LOCALES[PlayerLocale[guidLow]] or SERVER_LOCALES.enUS
end

-- Formats a localized message for `player` (uses player's own remembered
-- locale). Pass extra args to string.format into the localized string.
local function BMAH_Msg(player, key, ...)
  local str = BMAH_LocaleFor(player:GetGUIDLow())[key] or key
  if select("#", ...) > 0 then
    return str:format(...)
  end
  return str
end
----------------------------------------------------------------------------

-- ─── Item Pricing Configuration ──────────────────────────────────────────────
-- Define the gold cost for each item category and rarity tier.
--   common_*_price   → cost for common items
--   rare_*_price     → cost for rare items
--   ultraRare_*_price → cost for ultra-rare items
-- Adjust these values to fit your server’s economy.

local common_pets_price     = 100
local rare_pets_price       = 400
local ultraRare_pets_price  = 1000

local common_mount_price    = 5000
local rare_mount_price      = 10000
local ultraRare_mount_price = 20000

local common_tcg_price      = 1000
local rare_tcg_price        = 2000
local ultraRare_tcg_price   = 5000

local common_misc_price     = 500
local rare_misc_price       = 600

local battered_hilt_price   = 10000

local common_gear_price     = 500
local rare_gear_price       = 1800
local ultraRare_gear_price  = 5000

local rare_instrument_price = 25000
-- ─────────────────────────────────────────────────────────────────────────────

local commonItems = {
  { itemId = 8485,   seller = "Breanni",         cost = common_pets_price  },
  { itemId = 8490,   seller = "Breanni",         cost = common_pets_price  },
  { itemId = 8491,   seller = "Breanni",         cost = common_pets_price  },
  { itemId = 8492,   seller = "Breanni",         cost = common_pets_price  },
  { itemId = 20768,  seller = "Yuppl",           cost = common_pets_price  },
  { itemId = 20769,  seller = "Breanni",         cost = common_pets_price  },
  { itemId = 22799,  seller = "Zunji the Knife", cost = common_gear_price  },
  { itemId = 29960,  seller = "Breanni",         cost = common_pets_price  },
  { itemId = 34499,  seller = "Landro Longshot", cost = common_tcg_price   },
  { itemId = 34535,  seller = "Breanni",         cost = common_pets_price  },
  { itemId = 38309,  seller = "Landro Longshot", cost = common_tcg_price   },
  { itemId = 38310,  seller = "Landro Longshot", cost = common_tcg_price   },
  { itemId = 38313,  seller = "Landro Longshot", cost = common_tcg_price   },
  { itemId = 38578,  seller = "Landro Longshot", cost = common_tcg_price   },
  { itemId = 39883,  seller = "Yuppl",           cost = common_pets_price  },
  { itemId = 43698,  seller = "Breanni",         cost = common_pets_price  },
  { itemId = 44178,  seller = "Mei Francis",     cost = common_mount_price },
  { itemId = 44707,  seller = "Mei Francis",     cost = common_mount_price },
  { itemId = 44721,  seller = "Breanni",         cost = common_pets_price  },
  { itemId = 44751,  seller = "Yuppl",           cost = common_pets_price  },
  { itemId = 44965,  seller = "Breanni",         cost = common_pets_price  },
  { itemId = 44970,  seller = "Breanni",         cost = common_pets_price  },
  { itemId = 44971,  seller = "Breanni",         cost = common_pets_price  },
  { itemId = 44973,  seller = "Breanni",         cost = common_pets_price  },
  { itemId = 44974,  seller = "Breanni",         cost = common_pets_price  },
  { itemId = 44980,  seller = "Breanni",         cost = common_pets_price  },
  { itemId = 44982,  seller = "Breanni",         cost = common_pets_price  },
  { itemId = 45002,  seller = "Breanni",         cost = common_pets_price  },
  { itemId = 45606,  seller = "Breanni",         cost = common_pets_price  },
  { itemId = 46780,  seller = "Landro Longshot", cost = common_tcg_price   },
  { itemId = 48112,  seller = "Breanni",         cost = common_pets_price  },
  { itemId = 48114,  seller = "Breanni",         cost = common_pets_price  },
  { itemId = 48116,  seller = "Breanni",         cost = common_pets_price  },
  { itemId = 48118,  seller = "Breanni",         cost = common_pets_price  },
  { itemId = 48124,  seller = "Breanni",         cost = common_pets_price  },
  { itemId = 48126,  seller = "Breanni",         cost = common_pets_price  },
}

local rareItems = {
  { itemId = 8494,   seller = "Breanni",             cost = rare_pets_price     },
  { itemId = 8498,   seller = "Breanni",             cost = rare_pets_price     },
  { itemId = 8499,   seller = "Breanni",             cost = rare_pets_price     },
  { itemId = 10822,  seller = "Breanni",             cost = rare_pets_price     },
  { itemId = 13335,  seller = "Mei Francis",         cost = rare_mount_price    },
  { itemId = 14617,  seller = "Yuppl",               cost = rare_misc_price     },
  { itemId = 23705,  seller = "Landro Longshot",     cost = rare_tcg_price      },
  { itemId = 23709,  seller = "Landro Longshot",     cost = rare_tcg_price      },
  { itemId = 23713,  seller = "Landro Longshot",     cost = rare_tcg_price      },
  { itemId = 23720,  seller = "Mei Francis",         cost = rare_mount_price    },
  { itemId = 29271,  seller = "Zunji the Knife",     cost = rare_gear_price     },
  { itemId = 30380,  seller = "Caladis Brightspear", cost = battered_hilt_price },
  { itemId = 32542,  seller = "Landro Longshot",     cost = rare_tcg_price      },
  { itemId = 32566,  seller = "Landro Longshot",     cost = rare_tcg_price      },
  { itemId = 32588,  seller = "Landro Longshot",     cost = rare_tcg_price      },
  { itemId = 33219,  seller = "Landro Longshot",     cost = rare_tcg_price      },
  { itemId = 33223,  seller = "Landro Longshot",     cost = rare_tcg_price      },
  { itemId = 34492,  seller = "Landro Longshot",     cost = rare_tcg_price      },
  { itemId = 35504,  seller = "Breanni",             cost = rare_pets_price     },
  { itemId = 35513,  seller = "Mei Francis",         cost = rare_mount_price    },
  { itemId = 38050,  seller = "Landro Longshot",     cost = rare_tcg_price      },
  { itemId = 38311,  seller = "Landro Longshot",     cost = rare_tcg_price      },
  { itemId = 39769,  seller = "Bergrisst",           cost = rare_instrument_price },
  { itemId = 43952,  seller = "Mei Francis",         cost = rare_mount_price    },
  { itemId = 43953,  seller = "Mei Francis",         cost = rare_mount_price    },
  { itemId = 44151,  seller = "Mei Francis",         cost = rare_mount_price    },
  { itemId = 44924,  seller = "Bergrisst",           cost = rare_instrument_price },
  { itemId = 45037,  seller = "Yuppl",               cost = rare_misc_price     },
  { itemId = 45063,  seller = "Landro Longshot",     cost = rare_tcg_price      },
  { itemId = 50379,  seller = "Caladis Brightspear", cost = battered_hilt_price },
}

local ultraRareItems = {
  { itemId = 19872,  seller = "Mei Francis",       cost = ultraRare_mount_price },
  { itemId = 19902,  seller = "Mei Francis",       cost = ultraRare_mount_price },
  { itemId = 30480,  seller = "Mei Francis",       cost = ultraRare_mount_price },
  { itemId = 32458,  seller = "Mei Francis",       cost = ultraRare_mount_price },
  { itemId = 34493,  seller = "Landro Longshot",   cost = ultraRare_tcg_price   },
  { itemId = 35227,  seller = "Landro Longshot",   cost = ultraRare_tcg_price   },
  { itemId = 38312,  seller = "Landro Longshot",   cost = ultraRare_tcg_price   },
  { itemId = 38314,  seller = "Landro Longshot",   cost = ultraRare_tcg_price   },
  { itemId = 40491,  seller = "Zunji the Knife",   cost = ultraRare_tcg_price   },
  { itemId = 44083,  seller = "Mei Francis",       cost = ultraRare_mount_price },
  { itemId = 44175,  seller = "Mei Francis",       cost = ultraRare_mount_price },
  { itemId = 45693,  seller = "Mei Francis",       cost = ultraRare_mount_price },
  { itemId = 45802,  seller = "Mei Francis",       cost = ultraRare_mount_price },
  { itemId = 49286,  seller = "Mei Francis",       cost = ultraRare_mount_price },
  { itemId = 49287,  seller = "Breanni",           cost = ultraRare_pets_price  },
  { itemId = 49343,  seller = "Breanni",           cost = ultraRare_pets_price  },
  { itemId = 49636,  seller = "Mei Francis",       cost = ultraRare_mount_price },
  { itemId = 50046,  seller = "Zunji the Knife",   cost = ultraRare_gear_price  },
  { itemId = 50047,  seller = "Zunji the Knife",   cost = ultraRare_gear_price  },
  { itemId = 50048,  seller = "Zunji the Knife",   cost = ultraRare_gear_price  },
  { itemId = 50049,  seller = "Zunji the Knife",   cost = ultraRare_gear_price  },
  { itemId = 50050,  seller = "Zunji the Knife",   cost = ultraRare_gear_price  },
  { itemId = 50051,  seller = "Zunji the Knife",   cost = ultraRare_gear_price  },
  { itemId = 50052,  seller = "Zunji the Knife",   cost = ultraRare_gear_price  },
  { itemId = 50818,  seller = "Mei Francis",       cost = ultraRare_mount_price },
  { itemId = 54068,  seller = "Mei Francis",       cost = ultraRare_mount_price },
}
--Set the Table
CharDBExecute([[
CREATE TABLE IF NOT EXISTS `blackmarketauctionhouse` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `item_id` INT UNSIGNED NOT NULL DEFAULT 0,
  `item_owner` VARCHAR(32) NOT NULL DEFAULT '',
  `time` INT NOT NULL DEFAULT 0,
  `last_bid` INT UNSIGNED NOT NULL DEFAULT 0,
  `start_bid` INT UNSIGNED NOT NULL DEFAULT 0,
  `buyer_id` INT UNSIGNED NOT NULL DEFAULT 0,
  `total_bids` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]])



local function OnBMAHVendorGossip(event, player, creature)
    -- prefix “BMAHUI” / message “OPEN” is arbitrary but must match client
    player:SendAddonMessage("BMAHUI", "OPEN", 0, player)
    player:GossipComplete()    -- close the gossip window
end

for _, entry in ipairs(BMAH_VENDOR_NPCs) do
    RegisterCreatureGossipEvent(entry, 1, OnBMAHVendorGossip)
end

local REQ  = "BMAH_REQ"
local DATA = "BMAH_DATA"
local DONE = "BMAH_DONE"
local COPPER_PER_SILVER = 100
local SILVER_PER_GOLD   = 100
math.randomseed(os.time())

local SUBCLASS = {
    ["0_0"]="Consumable",["0_1"]="Potion",["0_2"]="Elixir",["0_3"]="Flask",["0_4"]="Scroll",["0_5"]="Food & Drink",["0_6"]="Item Enhancement",["0_7"]="Bandage",["0_8"]="Other",
    ["1_0"]="Bag",["1_1"]="Soul Bag",["1_2"]="Herb Bag",["1_3"]="Enchanting Bag",["1_4"]="Engineering Bag",["1_5"]="Gem Bag",["1_6"]="Mining Bag",["1_7"]="Leatherworking Bag",["1_8"]="Inscription Bag",
    ["2_0"]="One-Handed Axe",["2_1"]="Two-Handed Axe",["2_2"]="Bow",["2_3"]="Gun",["2_4"]="One-Handed Mace",["2_5"]="Two-Handed Mace",["2_6"]="Polearm",["2_7"]="One-Handed Sword",["2_8"]=" Two-Handed Sword",["2_9"]="Obsolete",["2_10"]="Staff",["2_11"]="Exotic",["2_12"]="Exotic",["2_13"]="Fist Weapon",["2_14"]="Miscellaneous",["2_15"]="Dagger",["2_16"]="Thrown",["2_17"]="Spear",["2_18"]="Crossbow",["2_19"]="Wand",["2_20"]="Fishing Pole",
    ["3_0"]="Red",["3_1"]="Blue",["3_2"]="Yellow",["3_3"]="Purple",["3_4"]="Green",["3_5"]="Orange",["3_6"]="Meta",["3_7"]="Simple",["3_8"]="Prismatic",
    ["4_0"]="Miscellaneous",["4_1"]="Cloth",["4_2"]="Leather",["4_3"]="Mail",["4_4"]="Plate",["4_5"]="Buckler",["4_6"]="Shield",["4_7"]="Libram",["4_8"]="Idol",["4_9"]="Totem",["4_10"]="Sigil",
    ["5_0"]="Reagent",
    ["6_0"]="Wand",["6_1"]="Bolt",["6_2"]="Arrow",["6_3"]="Bullet",["6_4"]="Thrown",
    ["7_0"]="Trade Goods",["7_1"]="Parts",["7_2"]="Explosives",["7_3"]="Devices",["7_4"]="Jewelcrafting",["7_5"]="Cloth",["7_6"]="Leather",["7_7"]="Metal & Stone",["7_8"]="Meat",["7_9"]="Herb",["7_10"]="Elemental",["7_11"]="Other",["7_12"]="Enchanting",["7_13"]="Materials",["7_14"]="Armor Enchantment",["7_15"]="Weapon Enchantment",
    ["8_0"]="Generic",
    ["9_0"]="Book",["9_1"]="Leatherworking",["9_2"]="Tailoring",["9_3"]="Engineering",["9_4"]="Blacksmithing",["9_5"]="Cooking",["9_6"]="Alchemy",["9_7"]="First Aid",["9_8"]="Enchanting",["9_9"]="Fishing",["9_10"]="Jewelcrafting",
    ["10_0"]="Money",
    ["11_0"]="Quiver",["11_1"]="Quiver",["11_2"]="Quiver",["11_3"]="Ammo Pouch",
    ["12_0"]="Quest",
    ["13_0"]="Key",["13_1"]="Lockpick",
    ["14_0"]="Permanent",
    ["15_0"]="Junk",["15_1"]="Reagent",["15_2"]="Pet",["15_3"]="Holiday",["15_4"]="Other",["15_5"]="Mount",
    ["16_1"]="Warrior",["16_2"]="Paladin",["16_3"]="Hunter",["16_4"]="Rogue",["16_5"]="Priest",["16_6"]="Death Knight",["16_7"]="Shaman",["16_8"]="Mage",["16_9"]="Warlock",["16_11"]="Druid",
}

-- French mirror of SUBCLASS above, same keys (class_subclass id → label).
-- Hand-translated -- close to Blizzard's own French wording but not
-- guaranteed to match it entry-for-entry.
local SUBCLASS_frFR = {
    ["0_0"]="Consommable",["0_1"]="Potion",["0_2"]="Elixir",["0_3"]="Fiole",["0_4"]="Parchemin",["0_5"]="Nourriture et boisson",["0_6"]="Amelioration d'objet",["0_7"]="Bandage",["0_8"]="Autre",
    ["1_0"]="Sac",["1_1"]="Sac d'ames",["1_2"]="Sac a herbes",["1_3"]="Sac d'enchantement",["1_4"]="Sac d'ingenierie",["1_5"]="Sac a gemmes",["1_6"]="Sac de minage",["1_7"]="Sac de travail du cuir",["1_8"]="Sac d'inscription",
    ["2_0"]="Hache a une main",["2_1"]="Hache a deux mains",["2_2"]="Arc",["2_3"]="Arme a feu",["2_4"]="Masse a une main",["2_5"]="Masse a deux mains",["2_6"]="Arme d'hast",["2_7"]="Epee a une main",["2_8"]=" Epee a deux mains",["2_9"]="Obsolete",["2_10"]="Baton",["2_11"]="Exotique",["2_12"]="Exotique",["2_13"]="Arme de pugilat",["2_14"]="Divers",["2_15"]="Dague",["2_16"]="Arme de jet",["2_17"]="Lance",["2_18"]="Arbalete",["2_19"]="Baguette",["2_20"]="Canne a peche",
    ["3_0"]="Rouge",["3_1"]="Bleu",["3_2"]="Jaune",["3_3"]="Violet",["3_4"]="Vert",["3_5"]="Orange",["3_6"]="Meta",["3_7"]="Simple",["3_8"]="Prismatique",
    ["4_0"]="Divers",["4_1"]="Tissu",["4_2"]="Cuir",["4_3"]="Mailles",["4_4"]="Plaques",["4_5"]="Bouclier leger",["4_6"]="Bouclier",["4_7"]="Manuscrit",["4_8"]="Idole",["4_9"]="Totem",["4_10"]="Sceau",
    ["5_0"]="Reactif",
    ["6_0"]="Baguette",["6_1"]="Carreau",["6_2"]="Fleche",["6_3"]="Balle",["6_4"]="Arme de jet",
    ["7_0"]="Marchandise",["7_1"]="Pieces",["7_2"]="Explosifs",["7_3"]="Dispositifs",["7_4"]="Joaillerie",["7_5"]="Tissu",["7_6"]="Cuir",["7_7"]="Metal et pierre",["7_8"]="Viande",["7_9"]="Herbe",["7_10"]="Elementaire",["7_11"]="Autre",["7_12"]="Enchantement",["7_13"]="Materiaux",["7_14"]="Amelioration d'armure",["7_15"]="Amelioration d'arme",
    ["8_0"]="Generique",
    ["9_0"]="Livre",["9_1"]="Travail du cuir",["9_2"]="Couture",["9_3"]="Ingenierie",["9_4"]="Forge",["9_5"]="Cuisine",["9_6"]="Alchimie",["9_7"]="Premiers soins",["9_8"]="Enchantement",["9_9"]="Peche",["9_10"]="Joaillerie",
    ["10_0"]="Argent",
    ["11_0"]="Carquois",["11_1"]="Carquois",["11_2"]="Carquois",["11_3"]="Sac a munitions",
    ["12_0"]="Quete",
    ["13_0"]="Cle",["13_1"]="Crochet",
    ["14_0"]="Permanent",
    ["15_0"]="Rebut",["15_1"]="Reactif",["15_2"]="Familier",["15_3"]="Fete",["15_4"]="Autre",["15_5"]="Monture",
    ["16_1"]="Guerrier",["16_2"]="Paladin",["16_3"]="Chasseur",["16_4"]="Voleur",["16_5"]="Pretre",["16_6"]="Chevalier de la mort",["16_7"]="Chaman",["16_8"]="Mage",["16_9"]="Demoniste",["16_11"]="Druide",
}

-- Picks the right SUBCLASS table for a player's remembered locale.
local function SubclassLabel(key, guidLow)
    local tbl = (PlayerLocale[guidLow] == "frFR") and SUBCLASS_frFR or SUBCLASS
    return tbl[key] or SUBCLASS[key] or ""
end

-- helper: bucket minutes into a localized word (uses the requesting player's
-- remembered locale via BMAH_LocaleFor -- falls back to enUS like everything
-- else in SERVER_LOCALES).
local function ClassifyTime(mins, loc)
    loc = loc or SERVER_LOCALES.enUS
    if mins < 30 then
        return loc.TIME_SHORT
    elseif mins < 120 then
        return loc.TIME_MEDIUM
    elseif mins < 720 then
        return loc.TIME_LONG
    else
        return loc.TIME_VERY_LONG
    end
end

RegisterPlayerEvent(19, function(_, player, msg, _, _, receiver)
    -- The client now appends its locale to the request, e.g. "BMAH_REQ;frFR"
    -- (see BlackMarketUI.lua). Remembered per player GUID and used for every
    -- localized message we send this player from then on.
    local cmd, loc = msg:match("^(BMAH_REQ);?(%a*)$")
    if cmd ~= REQ then
        return
    end
    if loc and loc ~= "" then
        PlayerLocale[player:GetGUIDLow()] = loc
    end
    local target = receiver or player

    -- ◼ 0) find row with the most total_bids
    local maxQ = CharDBQuery([[
        SELECT id
        FROM blackmarketauctionhouse
        ORDER BY total_bids DESC
        LIMIT 1
    ]])
    local maxRowId = maxQ and maxQ:GetUInt32(0) or 0

    -- 1) Fetch all blackmarket rows from CharDB
    local rowsQ = CharDBQuery([[
        SELECT id, item_id, time, item_owner, last_bid
        FROM blackmarketauctionhouse
        ORDER BY id ASC
    ]])
    if not rowsQ then
        player:SendAddonMessage(DONE, "0", 0, target)
        return
    end

    local sent = 0
    repeat
        -- pull from CharDB
        -- FIX: the row's own DB id (column 0) was selected but never read.
        -- The client needs it to reliably find "the hot row" in its list
        -- (see rowId below and the payload format change).
        local rowId    = rowsQ:GetUInt32(0)
        local itemId   = rowsQ:GetUInt32(1)
        local minsLeft = rowsQ:GetUInt32(2)
        local owner    = rowsQ:GetString(3)
        local lastBid  = rowsQ:GetUInt32(4)

        -- lookup name, level, class, subclass in WorldDB
        local tplQ = WorldDBQuery(string.format([[
            SELECT name, RequiredLevel, class, subclass
            FROM item_template
            WHERE entry = %d
        ]], itemId))

        local itemName, reqLevel, classId, subClassId
        if tplQ then
            itemName   = tplQ:GetString(0)
            reqLevel   = tplQ:GetUInt32(1)
            classId    = tplQ:GetUInt32(2)
            subClassId = tplQ:GetUInt32(3)
        else
            itemName   = "Item#" .. itemId
            reqLevel   = 0
            classId    = 0
            subClassId = 0
        end

        -- map class_subclass → text via SUBCLASS/SUBCLASS_frFR, localized
        -- for the player who requested this list
        local key      = classId .."_".. subClassId
        local itemType = SubclassLabel(key, player:GetGUIDLow())

        -- bucket minutes into Short/Medium/Long/Very Long, localized for
        -- the player who requested this list
        local timeWord = ClassifyTime(minsLeft, BMAH_LocaleFor(player:GetGUIDLow()))

        -- FIX: tpl:GetIcon() does not exist on this core's ItemTemplate binding
        -- (crashed with "attempt to call method 'GetIcon' (a nil value)" on
        -- every single request, right after "Server received your request").
        -- Icon resolution is moved to the client instead, via the real client
        -- API GetItemIcon(itemId) -- itemId is already sent as the last field
        -- of the payload below, so nothing else needs to change server-side.
        local iconName = ""

        -- FIX: added rowId (this row's real blackmarketauctionhouse.id) as a
        -- 10th field. The client used to have no way to know which of its
        -- rows corresponds to maxRowId other than assuming array position ==
        -- database id, which breaks the moment rows get flushed/refilled and
        -- ids stop lining up 1..N with insertion order.
        -- build exactly 10 fields: name;level;type;time;owner;bid;icon;maxRowId;itemId;rowId
        local payload = string.format(
            "%s;%d;%s;%s;%s;%d;%s;%d;%d;%d",
            itemName:gsub(";", ""),
            reqLevel,
            itemType,
            timeWord,
            owner:gsub(";", ""),
            lastBid,
            iconName,
            maxRowId,
            itemId,
            rowId
        )

        player:SendAddonMessage(DATA, payload, 0, target)
        sent = sent + 1
    until not rowsQ:NextRow()

    player:SendAddonMessage(DONE, tostring(sent), 0, target)
end)

RegisterPlayerEvent(19, function(_, player, msg, _, _, _)
    if msg:lower() ~= "bmah_flush" then
        return
    end

    if not player:IsGM() then
        player:SendBroadcastMessage("|cffff0000[BMAH]|r "..BMAH_Msg(player, "NO_PERM_FLUSH"))
        return false
    end

    -- 1) query every sold row
    local q = CharDBQuery([[
        SELECT id, item_id, buyer_id, last_bid
        FROM blackmarketauctionhouse
        WHERE buyer_id <> 0
    ]])

    if q then
        repeat
            local rowId       = q:GetUInt32(0)
            local itemEntry   = q:GetUInt32(1)
            local receiver    = q:GetUInt32(2)
            local bidCopper   = q:GetUInt32(3)
            -- fetch item name from world DB
            local wq = WorldDBQuery(string.format(
                "SELECT name FROM item_template WHERE entry = %d", itemEntry
            ))
            local itemName = wq and wq:GetString(0) or ("Item#"..itemEntry)
            -- compute gold spent
            local bidGold = math.floor(bidCopper / (COPPER_PER_SILVER * SILVER_PER_GOLD))

            -- localized per-recipient (falls back to enUS if this player never
            -- opened the Black Market window this session, e.g. offline winner)
            local winL = BMAH_LocaleFor(receiver)
            local body = string.format(winL.WIN_BODY, bidGold, itemName)

            -- send the mail: no money, no COD, attach exactly one of the item
            SendMail(
                winL.WIN_SUBJECT,
                body,
                receiver,
                FlushMailSender,
                FlushMailStationery,
                0,        -- immediate delivery
                0,        -- money attached
                0,        -- COD
                itemEntry,
                1         -- quantity
            )
        until not q:NextRow()
    end

    -- 2) now wipe the auction table
    CharDBExecute([[TRUNCATE TABLE blackmarketauctionhouse]])

    -- 3) feedback
    player:SendBroadcastMessage("|cff69ccf0[BMAH]|r "..BMAH_Msg(player, "FLUSHED"))
    return false
end)

RegisterPlayerEvent(19, function(_, player, msg, _, _, _)
    if msg:lower() ~= "bmah_fill" then
        return
    end

    if not player:IsGM() then
        player:SendBroadcastMessage("|cffff0000[BMAH]|r "..BMAH_Msg(player, "NO_PERM_FILL"))
        return false
    end

    -- ── do not fill if any auctions still exist ───────────
    local countQ = CharDBQuery("SELECT COUNT(*) FROM blackmarketauctionhouse")
    local count  = countQ and countQ:GetUInt32(0) or 0
    if count > 0 then
        player:SendBroadcastMessage("|cffff0000[BMAH]|r "..BMAH_Msg(player, "ALREADY_FILLED"))
        return false
    end

    -- now safe to truncate & refill
    CharDBExecute([[TRUNCATE TABLE blackmarketauctionhouse]])

    -- roll how many rows to insert
    local count = math.random(MinFillCount, MaxFillCount)

    -- helper to pick a random entry from a table
    local function pick(t)
        return t[ math.random(1, #t) ]
    end

    -- now loop and insert
    for i = 1, count do
        -- roll rarity
        local r = math.random()
        local entry
        if r < FillRateCommon then
            entry = pick(commonItems)
        elseif r < FillRateRare then
            entry = pick(rareItems)
        else
            entry = pick(ultraRareItems)
        end

        -- sanitize owner name
        local owner = entry.seller:gsub("'", "''")
        -- cost is multiplied by 10000
        local bid = entry.cost * 10000
        -- timeLeft (in minutes) — adjust as you like
        local durations = PotentialDurations
        local timeLeft  = durations[ math.random(#durations) ]

        -- insert into DB
        CharDBExecute(string.format([[
            INSERT INTO blackmarketauctionhouse
              (item_id, time, item_owner, start_bid, last_bid)
            VALUES
              (%d, %d, '%s', %d, %d)
        ]],
            entry.itemId,
            timeLeft,
            owner,
            bid,
            bid
        ))
    end

    player:SendBroadcastMessage("|cff69ccf0[BMAH]|r "..BMAH_Msg(player, "FILLED", count))
    return false
end)

-- client will whisper: "BMAH_BID;<itemId>;<goldAmount>"
local BID_REQ    = "BMAH_BID"
-- same for hot-item if you want a different command
local HOTBID_REQ = "BMAH_HOTBID"

RegisterPlayerEvent(19, function(_, player, msg, _, _, _)
    -- only handle our bid commands
    local cmd, payload = msg:match("^([A-Z_]+);(.+)$")
    if cmd ~= BID_REQ and cmd ~= HOTBID_REQ then
        return
    end

    -- parse params
    local idStr, bidG = payload:match("^(%d+);(%d+)$")
    local id     = tonumber(idStr)
    local bidAmt = tonumber(bidG)
    if not id or not bidAmt then
        player:SendBroadcastMessage("|cffff0000[BMAH]|r "..BMAH_Msg(player, "INVALID_BID"))
        return false
    end

    -- look up the auction row (now also fetch buyer_id)
    local q = CharDBQuery(string.format(
        "SELECT id, last_bid, buyer_id FROM blackmarketauctionhouse WHERE %s = %d",
        (cmd == HOTBID_REQ) and "id" or "item_id",
        id
    ))
    if not q then
        player:SendBroadcastMessage("|cffff0000[BMAH]|r "..BMAH_Msg(player, "NOT_FOUND"))
        return false
    end

    local rowId          = q:GetUInt32(0)
    local lastBid        = q:GetUInt32(1)
    local currentBidder  = q:GetUInt32(2)
    -- convert to copper
    local bidCopper      = bidAmt * COPPER_PER_SILVER * SILVER_PER_GOLD
    local minRequired    = lastBid + (MinBidIncrementG * COPPER_PER_SILVER * SILVER_PER_GOLD)
    local playerCopper   = player:GetCoinage()

    -- 0) If they’re already the highest bidder, bail out
    if currentBidder == player:GetGUIDLow() then
        player:SendBroadcastMessage("|cffff0000[BMAH]|r "..BMAH_Msg(player, "ALREADY_HIGHEST"))
        return false
    end

    if playerCopper < bidCopper then
        player:SendBroadcastMessage("|cffff0000[BMAH]|r "..BMAH_Msg(player, "NOT_ENOUGH_GOLD"))
    elseif bidCopper < minRequired then
        local requiredG = minRequired / (COPPER_PER_SILVER * SILVER_PER_GOLD)
        player:SendBroadcastMessage("|cffff0000[BMAH]|r "..BMAH_Msg(player, "BID_TOO_LOW", requiredG))
    else
        -- deduct
        player:ModifyMoney(-bidCopper)
        -- refund setup (as before)
        local refundCopper = lastBid
        local refundGold   = math.floor(refundCopper / (COPPER_PER_SILVER * SILVER_PER_GOLD))
        if currentBidder ~= 0 then
            -- localized for the outbid player, not the current bidder
            local refundL = BMAH_LocaleFor(currentBidder)
            local body = string.format(refundL.REFUND_BODY, refundGold)

            SendMail(
                refundL.REFUND_SUBJECT,
                body,
                currentBidder,
                RefundMailSender,
                RefundStationery,
                0,               -- no delay
                refundCopper     -- refund amount in copper
            )
        end
        -- update DB
        CharDBExecute(string.format([[
            UPDATE blackmarketauctionhouse
               SET last_bid   = %d,
                   buyer_id   = %d,
                   total_bids = total_bids + 1
             WHERE id = %d
        ]], bidCopper, player:GetGUIDLow(), rowId))
        player:SendBroadcastMessage("|cff69ccf0[BMAH]|r "..BMAH_Msg(player, "BID_ACCEPTED", bidAmt))
        -- FIX: the client used to detect a successful bid by pattern-matching
        -- this exact English broadcast string, which would silently stop
        -- working the moment it's localized to French. Send a dedicated,
        -- locale-independent addon message instead so the client can refresh
        -- its list reliably regardless of language.
        player:SendAddonMessage("BMAH_BIDOK", "1", 0, player)
    end

    return false    -- swallow the whisper so it doesn’t spam the client
end)

-- 1) Define two helper functions using your existing code

local function BMAH_FlushLogic()
    -- 1) grab every expired auction
    local q = CharDBQuery([[
        SELECT id, item_id, buyer_id, last_bid
        FROM blackmarketauctionhouse
        WHERE time <= 0
    ]])
    if q then
        local expiredIds = {}
        repeat
            local rowId     = q:GetUInt32(0)
            local itemEntry = q:GetUInt32(1)
            local buyerId   = q:GetUInt32(2)
            local bidCopper = q:GetUInt32(3)

            -- mail only if someone actually bid
            if buyerId ~= 0 then
                local wq = WorldDBQuery(string.format(
                    "SELECT name FROM item_template WHERE entry = %d",
                    itemEntry
                ))
                local itemName = wq and wq:GetString(0) or ("Item#"..itemEntry)
                local bidGold  = math.floor(bidCopper / (COPPER_PER_SILVER * SILVER_PER_GOLD))

                -- FIX: FlushMailSubject/FlushMailBody were never declared
                -- anywhere in this file (leftover from before mail text was
                -- localized) - string.format(FlushMailBody, ...) always
                -- received nil as its format string, crashing with "bad
                -- argument #1 to 'format' (string expected, got nil)" every
                -- time an expired auction with a winning bidder got flushed.
                -- Reuses the same per-recipient WIN_SUBJECT/WIN_BODY locale
                -- strings as the manual flush handler above (same event:
                -- notifying the winner of an expired auction).
                local winL = BMAH_LocaleFor(buyerId)
                local body = string.format(winL.WIN_BODY, bidGold, itemName)

                SendMail(
                    winL.WIN_SUBJECT,
                    body,
                    buyerId,
                    FlushMailSender,
                    FlushMailStationery,
                    0, 0, 0,
                    itemEntry,
                    1
                )
            end

            table.insert(expiredIds, rowId)
        until not q:NextRow()

        -- 2) delete only those expired rows
        CharDBExecute(( "DELETE FROM blackmarketauctionhouse WHERE id IN (%s)" )
            :format(table.concat(expiredIds, ",")))
    end
end

local function BMAH_FillLogic()
    -- copy exactly the body of your fill handler, minus the GM‐check and player:SendBroadcastMessage
    CharDBExecute("TRUNCATE TABLE blackmarketauctionhouse")

    local count = math.random(MinFillCount, MaxFillCount)

    local function pick(t) return t[ math.random(1, #t) ] end
    for i = 1, count do
        local r = math.random()
        local entry
        if r < 0.85 then entry = pick(commonItems)
        elseif r < 0.95 then entry = pick(rareItems)
        else entry = pick(ultraRareItems) end

        local owner    = entry.seller:gsub("'", "''")
        local bid      = entry.cost * 10000
        local durations = {720, 1440}
        local timeLeft = durations[ math.random(#durations) ]

        CharDBExecute(string.format([[
            INSERT INTO blackmarketauctionhouse
              (item_id, time, item_owner, start_bid, last_bid)
            VALUES (%d, %d, '%s', %d, %d)
        ]],
            entry.itemId,
            timeLeft,
            owner,
            bid,
            bid
        ))
    end
end

-- track seconds since last 5-minute tick
local tick_position = 0

-- Every 5 minutes: age, flush expired, maybe fill
CreateLuaEvent(function()
    -- 1) count how many auctions we have right now
    local totalQ = CharDBQuery("SELECT COUNT(*) FROM blackmarketauctionhouse")
    local total  = totalQ and totalQ:GetUInt32(0) or 0

    if total > 0 then
        -- 2) decrement time on all rows
        CharDBExecute("UPDATE blackmarketauctionhouse SET time = time - 5")

        -- 3) check for expired only if we had rows
        local expQ = CharDBQuery("SELECT COUNT(*) FROM blackmarketauctionhouse WHERE time <= 0")
        if expQ and expQ:GetUInt32(0) > 0 then
            BMAH_FlushLogic()
        end
    end

    -- 4) after potential flush, see if the table is now empty
    local remQ = CharDBQuery("SELECT COUNT(*) FROM blackmarketauctionhouse")
    local rem  = remQ and remQ:GetUInt32(0) or 0
    if rem == 0 then
        if math.random() < AutoFillChance then
            BMAH_FillLogic()
        end
    end
end, 300000, 0)
