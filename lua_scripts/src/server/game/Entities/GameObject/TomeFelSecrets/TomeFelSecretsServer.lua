local AIO = AIO or require("AIO")
if AIO.IsMainState and not AIO.IsMainState() then return end

-- =====================================================================
-- CONFIG
-- =====================================================================

local LEGENDARY_GO_ENTRY = 245112

local CURRENCY_SHARD   = 128315 -- Legion Medal
local CURRENCY_CRYSTAL = 43228  -- Stone Keeper's Shard

local COST_SHARD   = 35000
local COST_CRYSTAL = 25000

-- =====================================================================
-- DATA
-- =====================================================================

local ITEMS =
{
    -- Wings
    {
        id = 200015, category = "wings",
        nameFR = "Jina-Kang, Gentillesse de Chi-Ji",
        nameEN = "Jina-Kang, Kindness of Chi-Ji",
        descFR = "Jina-Kang, Gentillesse de Chi-Ji, est une paire d'ailes dorées et délicates, imprégnées de la compassion infinie de Chi-Ji, la Grue Rouge.",
        descEN = "Jina-Kang, Kindness of Chi-Ji, is a pair of delicate golden wings, infused with the infinite compassion of Chi-Ji, the Red Crane.",
    },
    {
        id = 200016, category = "wings",
        nameFR = "Xing-Ho, Souffle de Yu'lon",
        nameEN = "Xing-Ho, Breath of Yu'lon",
        descFR = "Xing-Ho, Souffle de Yu'lon, est une paire d'ailes émeraude, imprégnées de la sagesse et de la sérénité du dragon Yu'lon.",
        descEN = "Xing-Ho, Breath of Yu'lon, is a pair of emerald wings, infused with the wisdom and serenity of the dragon Yu'lon.",
    },
    {
        id = 200017, category = "wings",
        nameFR = "Qian-Le, Courage de Niuzao",
        nameEN = "Qian-Le, Courage of Niuzao",
        descFR = "Qian-Le, Courage de Niuzao, est une robuste paire d'ailes noires, imprégnées de la force indomptable de Niuzao, le Buffle Noir.",
        descEN = "Qian-Le, Courage of Niuzao, is a sturdy pair of black wings, infused with the unyielding strength of Niuzao, the Black Ox.",
    },
    {
        id = 200018, category = "wings",
        nameFR = "Gong-Lu, Force de Xuen",
        nameEN = "Gong-Lu, Strength of Xuen",
        descFR = "Gong-Lu, Force de Xuen, est une paire d'ailes argentées, enveloppées de l'énergie féroce de Xuen, le Tigre Blanc.",
        descEN = "Gong-Lu, Strength of Xuen, is a pair of silver wings, wrapped in the fierce energy of Xuen, the White Tiger.",
    },

    -- Rings
    {
        id = 8850542, category = "rings",
        nameFR = "Anneau Légendaire de Khadgar",
        nameEN = "Legendary Ring of Khadgar",
        descFR = "Cet anneau appartenait avant au grand mage Khadgar.",
        descEN = "This ring once belonged to the great mage Khadgar.",
    },
    {
        id = 8850543, category = "rings",
        nameFR = "Anneau Légendaire de Garrosh Hurlenfer",
        nameEN = "Legendary Ring of Garrosh Hellscream",
        descFR = "Cet anneau appartenait avant au grand guerrier Garrosh Hurlenfer.",
        descEN = "This ring once belonged to the great warrior Garrosh Hellscream.",
    },
    {
        id = 8850544, category = "rings",
        nameFR = "Anneau Légendaire de Rexxar",
        nameEN = "Legendary Ring of Rexxar",
        descFR = "Cet anneau appartenait avant au grand chasseur Rexxar.",
        descEN = "This ring once belonged to the great hunter Rexxar.",
    },
    {
        id = 8850545, category = "rings",
        nameFR = "Anneau Légendaire de Tirion Fordring",
        nameEN = "Legendary Ring of Tirion Fordring",
        descFR = "Cet anneau appartenait avant au grand paladin Tirion Fordring.",
        descEN = "This ring once belonged to the great paladin Tirion Fordring.",
    },
    {
        id = 8850552, category = "rings",
        nameFR = "Anneau Légendaire de Malfurion Hurlorage",
        nameEN = "Legendary Ring of Malfurion Stormrage",
        descFR = "Cet anneau appartenait avant au grand druide Malfurion Hurlorage.",
        descEN = "This ring once belonged to the great druid Malfurion Stormrage.",
    },
}

local ITEMS_BY_ID = {}
for _, item in ipairs(ITEMS) do
    ITEMS_BY_ID[item.id] = item
end

CharDBExecute([[
    CREATE TABLE IF NOT EXISTS `custom_tomefelsecrets_obtained` (
        `guid` INT UNSIGNED NOT NULL,
        `item_entry` INT UNSIGNED NOT NULL,
        `obtained_at` INT UNSIGNED NOT NULL DEFAULT 0,
        PRIMARY KEY (`guid`, `item_entry`)
    ) ENGINE=InnoDB
]])

local function IsObtained(guid, itemId)
    local result = CharDBQuery(string.format(
        "SELECT 1 FROM `custom_tomefelsecrets_obtained` WHERE `guid` = %d AND `item_entry` = %d",
        guid, itemId))
    return result ~= nil
end

local function MarkObtained(guid, itemId)
    CharDBExecute(string.format(
        "INSERT INTO `custom_tomefelsecrets_obtained` (`guid`, `item_entry`, `obtained_at`) VALUES (%d, %d, UNIX_TIMESTAMP())",
        guid, itemId))
end

-- =====================================================================
-- HELPERS
-- =====================================================================

local function L(player, textFR, textEN)
    if player:GetDbLocaleIndex() == 2 then -- LOCALE_frFR
        return textFR
    end
    return textEN
end

local function BuildPayload(player)
    local guid = player:GetGUIDLow()

    local items = {}
    for _, item in ipairs(ITEMS) do
        table.insert(items, {
            id = item.id,
            category = item.category,
            name = L(player, item.nameFR, item.nameEN),
            desc = L(player, item.descFR, item.descEN),
            obtained = IsObtained(guid, item.id),
        })
    end

    local currency = {
        shardEntry    = CURRENCY_SHARD,
        crystalEntry  = CURRENCY_CRYSTAL,
        shardCost     = COST_SHARD,
        crystalCost   = COST_CRYSTAL,
        shardCount    = player:GetItemCount(CURRENCY_SHARD, false),
        crystalCount  = player:GetItemCount(CURRENCY_CRYSTAL, false),
    }

    return items, currency
end

-- =====================================================================
-- AIO HANDLERS
-- =====================================================================

local TomeFelSecretsHandlers = AIO.AddHandlers("TomeFelSecrets", {})

function TomeFelSecretsHandlers.RequestOpen(player)
    local items, currency = BuildPayload(player)
    AIO.Handle(player, "TomeFelSecrets", "OpenFrame", items, currency)
end

function TomeFelSecretsHandlers.RequestObtain(player, itemId)
    local target = ITEMS_BY_ID[itemId]
    if not target then
        return
    end

    local guid = player:GetGUIDLow()

    if IsObtained(guid, itemId) then
        AIO.Handle(player, "TomeFelSecrets", "ObtainResult", itemId, false, "already")
        return
    end

    local shardCount   = player:GetItemCount(CURRENCY_SHARD, false)
    local crystalCount = player:GetItemCount(CURRENCY_CRYSTAL, false)

    if shardCount < COST_SHARD or crystalCount < COST_CRYSTAL then
        AIO.Handle(player, "TomeFelSecrets", "ObtainResult", itemId, false, "cost")
        return
    end

    player:RemoveItem(CURRENCY_SHARD, COST_SHARD)
    player:RemoveItem(CURRENCY_CRYSTAL, COST_CRYSTAL)
    player:AddItem(target.id, 1)
    MarkObtained(guid, target.id)

    local msg = L(player,
        string.format("|cffff8000%s|r a été ajouté à votre inventaire !", target.nameFR),
        string.format("|cffff8000%s|r has been added to your inventory!", target.nameEN))
    player:SendBroadcastMessage(msg)

    AIO.Handle(player, "TomeFelSecrets", "ObtainResult", itemId, true, "ok")

    local items, currency = BuildPayload(player)
    AIO.Handle(player, "TomeFelSecrets", "Refresh", items, currency)
end

-- =====================================================================
-- TRIGGER
-- =====================================================================

local function OnGossipHello(event, player, object)
    local items, currency = BuildPayload(player)
    AIO.Handle(player, "TomeFelSecrets", "OpenFrame", items, currency)
end

RegisterGameObjectGossipEvent(LEGENDARY_GO_ENTRY, 1, OnGossipHello)
