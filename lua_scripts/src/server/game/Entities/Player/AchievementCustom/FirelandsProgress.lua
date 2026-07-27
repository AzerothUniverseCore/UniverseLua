--[[
    Firelands - Suivi de progression du Haut Fait "Terres de Feu" (ID 5019)
    -----------------------------------------------------------------------
    - Suit la progression de chaque joueur sur les 14 boss des Terres de Feu
    - Annonce la progression à chaque boss vaincu via un message broadcast serveur
    - Octroie automatiquement le Haut Fait 5019 une fois les 14 boss vaincus
    - Progression persistante (survit aux déconnexions/redémarrages) via une table
      dédiée dans la base de données characters
]]

local FIRELANDS_ACHIEVEMENT_ID = 5019
local FIRELANDS_REQUIRED_COUNT = 14

-- Entry créature -> Nom (EN / FR), utilisé pour les messages de broadcast
local FIRELANDS_BOSSES = {
    [8000100] = { en = "Skeelta",                   fr = "Skeelta" },
    [8000102] = { en = "Slag Elemental",             fr = "Slag Elemental" },
    [8000103] = { en = "Lord Rhyolith",              fr = "Seigneur Rhyolith" },
    [8000108] = { en = "Tak'rog",                    fr = "Tak'rog" },
    [8000109] = { en = "Zeykha",                     fr = "Zeykha" },
    [8000110] = { en = "Skault",                     fr = "Skault" },
    [8000111] = { en = "Baron Geddon",               fr = "Baron Geddon" },
    [8000112] = { en = "Zelyo",                      fr = "Zelyo" },
    [8000113] = { en = "Cyberos",                    fr = "Cyberos" },
    [8000129] = { en = "Ragnaros",                   fr = "Ragnaros" },
    [8000130] = { en = "Ghylion",                    fr = "Ghylion" },
    [8000131] = { en = "Hyterun",                    fr = "Hyterun" },
    [8000139] = { en = "Golemagg the Incinerator",   fr = "Golemagg l'Incinérateur" },
    [8000143] = { en = "Minoleuse",                  fr = "Minoléuse" },
}

-- Cache mémoire : [guidLow] = { [entry] = true, ... }
local FirelandsProgress = {}

local function EnsureTable()
    CharDBExecute([[
        CREATE TABLE IF NOT EXISTS `character_firelands_progress` (
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
    if FirelandsProgress[guidLow] then
        return FirelandsProgress[guidLow]
    end

    local progress = {}
    local result = CharDBQuery("SELECT `entry` FROM `character_firelands_progress` WHERE `guid` = " .. guidLow)
    if result then
        repeat
            progress[result:GetUInt32(0)] = true
        until not result:NextRow()
    end

    FirelandsProgress[guidLow] = progress
    return progress
end

local function SaveKill(guidLow, entry)
    CharDBExecute("INSERT IGNORE INTO `character_firelands_progress` (`guid`, `entry`) VALUES (" .. guidLow .. ", " .. entry .. ")")
end

local function BroadcastProgress(player, boss, current, total)
    SendWorldMessage("|cffff4500[Firelands]|r " .. player:GetName() .. " a vaincu " .. boss.fr .. " ! (" .. current .. "/" .. total .. ")")
    SendWorldMessage("|cffff4500[Firelands]|r " .. player:GetName() .. " has defeated " .. boss.en .. "! (" .. current .. "/" .. total .. ")")
end

local function BroadcastCompletion(player)
    SendWorldMessage("|cffffd700[Firelands]|r " .. player:GetName() .. " a vaincu tous les boss des Terres de Feu et obtient le Haut Fait « Terres de Feu » !")
    SendWorldMessage("|cffffd700[Firelands]|r " .. player:GetName() .. " has defeated every boss in Firelands and earned the achievement \"Firelands\"!")
end

local function CheckAndGrantAchievement(player, progress)
    if CountProgress(progress) < FIRELANDS_REQUIRED_COUNT then
        return
    end
    if player:HasAchieved(FIRELANDS_ACHIEVEMENT_ID) then
        return
    end
    player:SetAchievement(FIRELANDS_ACHIEVEMENT_ID)
    BroadcastCompletion(player)
end

local function OnKillCreature(event, killer, victim)
    if not killer or not victim then return end

    local entry = victim:GetEntry()
    local boss = FIRELANDS_BOSSES[entry]
    if not boss then return end

    local guidLow = killer:GetGUIDLow()
    local progress = LoadProgress(guidLow)

    if progress[entry] then
        return -- déjà comptabilisé pour ce joueur
    end

    progress[entry] = true
    SaveKill(guidLow, entry)

    local current = CountProgress(progress)
    BroadcastProgress(killer, boss, current, FIRELANDS_REQUIRED_COUNT)

    CheckAndGrantAchievement(killer, progress)
end

local function OnLogin(event, player)
    LoadProgress(player:GetGUIDLow())
end

local function OnLogout(event, player)
    FirelandsProgress[player:GetGUIDLow()] = nil
end

EnsureTable()

RegisterPlayerEvent(7, OnKillCreature) -- PLAYER_EVENT_ON_KILL_CREATURE
RegisterPlayerEvent(3, OnLogin)        -- PLAYER_EVENT_ON_LOGIN
RegisterPlayerEvent(4, OnLogout)       -- PLAYER_EVENT_ON_LOGOUT
