--[[
    Shado-Pan Monastery - Suivi de progression du Haut Fait
    "Monastère des Pandashan" (ID 5022)
    ------------------------------------------------------------------------------------
    - Suit la progression de chaque joueur sur les 4 objectifs du Monastère des Pandashan
    - Annonce la progression à chaque objectif accompli via un message broadcast serveur
    - Octroie automatiquement le Haut Fait 5022 une fois les 4 objectifs accomplis
    - Progression persistante (survit aux déconnexions/redémarrages) via une table
      dédiée dans la base de données characters

    Note : les entries 190039, 190043 et 190048 partagent le même nom "Gu Cloudthunder"
    / "Gu Foudre des Nuages" dans le fichier SQL fourni (probablement plusieurs entries
    liées au même boss, ex. phases/formes distinctes). Les noms ont été repris tels
    quels depuis achievement_criteria.sql.
]]

local MONASTEREPANDASHAN_ACHIEVEMENT_ID = 5022
local MONASTEREPANDASHAN_REQUIRED_COUNT = 4

-- Entry créature -> Nom (EN / FR), utilisé pour les messages de broadcast
local MONASTEREPANDASHAN_BOSSES = {
    [190039] = { en = "Gu Cloudthunder", fr = "Gu Foudre des Nuages" },
    [190043] = { en = "Gu Cloudthunder", fr = "Gu Foudre des Nuages" },
    [190044] = { en = "Sha of Anger",    fr = "Sha de la colère" },
    [190048] = { en = "Gu Cloudthunder", fr = "Gu Foudre des Nuages" },
}

-- Cache mémoire : [guidLow] = { [entry] = true, ... }
local MonasterePandashanProgress = {}

local function EnsureTable()
    CharDBExecute([[
        CREATE TABLE IF NOT EXISTS `character_monasterepandashan_progress` (
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
    if MonasterePandashanProgress[guidLow] then
        return MonasterePandashanProgress[guidLow]
    end

    local progress = {}
    local result = CharDBQuery("SELECT `entry` FROM `character_monasterepandashan_progress` WHERE `guid` = " .. guidLow)
    if result then
        repeat
            progress[result:GetUInt32(0)] = true
        until not result:NextRow()
    end

    MonasterePandashanProgress[guidLow] = progress
    return progress
end

local function SaveKill(guidLow, entry)
    CharDBExecute("INSERT IGNORE INTO `character_monasterepandashan_progress` (`guid`, `entry`) VALUES (" .. guidLow .. ", " .. entry .. ")")
end

local function BroadcastProgress(player, boss, current, total)
    SendWorldMessage("|cffff66cc[Monastère des Pandashan]|r " .. player:GetName() .. " a vaincu " .. boss.fr .. " ! (" .. current .. "/" .. total .. ")")
    SendWorldMessage("|cffff66cc[Shado-Pan Monastery]|r " .. player:GetName() .. " has defeated " .. boss.en .. "! (" .. current .. "/" .. total .. ")")
end

local function BroadcastCompletion(player)
    SendWorldMessage("|cffffd700[Monastère des Pandashan]|r " .. player:GetName() .. " a vaincu tous les boss du Monastère des Pandashan et obtient le Haut Fait « Monastère des Pandashan » !")
    SendWorldMessage("|cffffd700[Shado-Pan Monastery]|r " .. player:GetName() .. " has defeated every boss in Shado-Pan Monastery and earned the achievement \"Shado-Pan Monastery\"!")
end

local function CheckAndGrantAchievement(player, progress)
    if CountProgress(progress) < MONASTEREPANDASHAN_REQUIRED_COUNT then
        return
    end
    if player:HasAchieved(MONASTEREPANDASHAN_ACHIEVEMENT_ID) then
        return
    end
    player:SetAchievement(MONASTEREPANDASHAN_ACHIEVEMENT_ID)
    BroadcastCompletion(player)
end

local function OnKillCreature(event, killer, victim)
    if not killer or not victim then return end

    local entry = victim:GetEntry()
    local boss = MONASTEREPANDASHAN_BOSSES[entry]
    if not boss then return end

    local guidLow = killer:GetGUIDLow()
    local progress = LoadProgress(guidLow)

    if progress[entry] then
        return -- déjà comptabilisé pour ce joueur
    end

    progress[entry] = true
    SaveKill(guidLow, entry)

    local current = CountProgress(progress)
    BroadcastProgress(killer, boss, current, MONASTEREPANDASHAN_REQUIRED_COUNT)

    CheckAndGrantAchievement(killer, progress)
end

local function OnLogin(event, player)
    LoadProgress(player:GetGUIDLow())
end

local function OnLogout(event, player)
    MonasterePandashanProgress[player:GetGUIDLow()] = nil
end

EnsureTable()

RegisterPlayerEvent(7, OnKillCreature) -- PLAYER_EVENT_ON_KILL_CREATURE
RegisterPlayerEvent(3, OnLogin)        -- PLAYER_EVENT_ON_LOGIN
RegisterPlayerEvent(4, OnLogout)       -- PLAYER_EVENT_ON_LOGOUT
