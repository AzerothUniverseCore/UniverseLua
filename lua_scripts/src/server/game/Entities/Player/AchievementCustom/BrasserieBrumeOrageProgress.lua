--[[
    Stormstout Brewery - Suivi de progression du Haut Fait
    "Brasserie Brume d'orage" (ID 5023)
    ------------------------------------------------------------------------------------
    - Suit la progression de chaque joueur sur les 4 boss de la Brasserie Brume d'orage
    - Annonce la progression à chaque boss vaincu via un message broadcast serveur
    - Octroie automatiquement le Haut Fait 5023 une fois les 4 boss vaincus
    - Progression persistante (survit aux déconnexions/redémarrages) via une table
      dédiée dans la base de données characters
]]

local BRASSERIE_ACHIEVEMENT_ID = 5023
local BRASSERIE_REQUIRED_COUNT = 4

-- Entry créature -> Nom (EN / FR), utilisé pour les messages de broadcast
local BRASSERIE_BOSSES = {
    [150287] = { en = "Ook-Ook",                 fr = "Ouk-Ouk" },
    [150289] = { en = "Hoptallus",                fr = "Sautallus" },
    [150290] = { en = "Brown Ale Elemental",      fr = "Elémenbière brun" },
    [150295] = { en = "Yan-Zhu the Uncasked",     fr = "Yan Zhu le Déballonné" },
}

-- Cache mémoire : [guidLow] = { [entry] = true, ... }
local BrasserieProgress = {}

local function EnsureTable()
    CharDBExecute([[
        CREATE TABLE IF NOT EXISTS `character_brasseriebrumeorage_progress` (
            `guid` INT UNSIGNED NOT NULL,
            `entry` INT UNSIGNED NOT NULL,
            PRIMARY KEY (`guid`, `entry`)
        )
    ]])
end

local function CountProgress(progress)
    local count = 0
    for _ in pairs(progress) do
        count = count + 1
    end
    return count
end

local function LoadProgress(guidLow)
    if BrasserieProgress[guidLow] then
        return BrasserieProgress[guidLow]
    end

    local progress = {}
    local result = CharDBQuery("SELECT `entry` FROM `character_brasseriebrumeorage_progress` WHERE `guid` = " .. guidLow)
    if result then
        repeat
            progress[result:GetUInt32(0)] = true
        until not result:NextRow()
    end

    BrasserieProgress[guidLow] = progress
    return progress
end

local function SaveKill(guidLow, entry)
    CharDBExecute("INSERT IGNORE INTO `character_brasseriebrumeorage_progress` (`guid`, `entry`) VALUES (" .. guidLow .. ", " .. entry .. ")")
end

local function BroadcastProgress(player, boss, current, total)
    SendWorldMessage("|cffffcc00[Brasserie Brume d'orage]|r " .. player:GetName() .. " a vaincu " .. boss.fr .. " ! (" .. current .. "/" .. total .. ")")
    SendWorldMessage("|cffffcc00[Stormstout Brewery]|r " .. player:GetName() .. " has defeated " .. boss.en .. "! (" .. current .. "/" .. total .. ")")
end

local function BroadcastCompletion(player)
    SendWorldMessage("|cffffd700[Brasserie Brume d'orage]|r " .. player:GetName() .. " a vaincu tous les boss de la Brasserie Brume d'orage et obtient le Haut Fait « Brasserie Brume d'orage » !")
    SendWorldMessage("|cffffd700[Stormstout Brewery]|r " .. player:GetName() .. " has defeated every boss in Stormstout Brewery and earned the achievement \"Stormstout Brewery\"!")
end

local function CheckAndGrantAchievement(player, progress)
    if CountProgress(progress) < BRASSERIE_REQUIRED_COUNT then
        return
    end
    if player:HasAchieved(BRASSERIE_ACHIEVEMENT_ID) then
        return
    end
    player:SetAchievement(BRASSERIE_ACHIEVEMENT_ID)
    BroadcastCompletion(player)
end

local function OnKillCreature(event, killer, victim)
    if not killer or not victim then return end

    local entry = victim:GetEntry()
    local boss = BRASSERIE_BOSSES[entry]
    if not boss then return end

    local guidLow = killer:GetGUIDLow()
    local progress = LoadProgress(guidLow)

    if progress[entry] then
        return -- déjà comptabilisé pour ce joueur
    end

    progress[entry] = true
    SaveKill(guidLow, entry)

    local current = CountProgress(progress)
    BroadcastProgress(killer, boss, current, BRASSERIE_REQUIRED_COUNT)

    CheckAndGrantAchievement(killer, progress)
end

local function OnLogin(event, player)
    LoadProgress(player:GetGUIDLow())
end

local function OnLogout(event, player)
    BrasserieProgress[player:GetGUIDLow()] = nil
end

EnsureTable()

RegisterPlayerEvent(7, OnKillCreature) -- PLAYER_EVENT_ON_KILL_CREATURE
RegisterPlayerEvent(3, OnLogin)        -- PLAYER_EVENT_ON_LOGIN
RegisterPlayerEvent(4, OnLogout)       -- PLAYER_EVENT_ON_LOGOUT
