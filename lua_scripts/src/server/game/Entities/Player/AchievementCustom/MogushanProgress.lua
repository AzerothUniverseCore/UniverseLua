--[[
    Mogu'shan Vaults - Suivi de progression du Haut Fait "Caveaux Mogu'shan" (ID 5025)
    ------------------------------------------------------------------------------------
    - Suit la progression de chaque joueur sur les 9 boss des Caveaux Mogu'shan
    - Annonce la progression à chaque boss vaincu via un message broadcast serveur
    - Octroie automatiquement le Haut Fait 5025 une fois les 9 boss vaincus
    - Progression persistante (survit aux déconnexions/redémarrages) via une table
      dédiée dans la base de données characters
]]

local MOGUSHAN_ACHIEVEMENT_ID = 5025
local MOGUSHAN_REQUIRED_COUNT = 9

-- Entry créature -> Nom (EN / FR), utilisé pour les messages de broadcast
local MOGUSHAN_BOSSES = {
    [5100100] = { en = "Rock Guardian",       fr = "Rock Guardian" },
    [5100104] = { en = "Khaz'goroth",         fr = "Khaz'goroth" },
    [5100106] = { en = "Mauk'h",              fr = "Mauk'h" },
    [5100110] = { en = "Ydrizil",             fr = "Ydrizil" },
    [5100116] = { en = "Crow King",           fr = "Crow King" },
    [5100117] = { en = "Moloss Nightmare",    fr = "Moloss Nightmare" },
    [5100121] = { en = "N'ath's Tentacle",    fr = "Tentacul N'ath" },
    [5100122] = { en = "N'ath son of Horror", fr = "N'ath son of Horror" },
    [5100123] = { en = "General V'ath",       fr = "General V'ath" },
}

-- Cache mémoire : [guidLow] = { [entry] = true, ... }
local MogushanProgress = {}

local function EnsureTable()
    CharDBExecute([[
        CREATE TABLE IF NOT EXISTS `character_mogushan_progress` (
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
    if MogushanProgress[guidLow] then
        return MogushanProgress[guidLow]
    end

    local progress = {}
    local result = CharDBQuery("SELECT `entry` FROM `character_mogushan_progress` WHERE `guid` = " .. guidLow)
    if result then
        repeat
            progress[result:GetUInt32(0)] = true
        until not result:NextRow()
    end

    MogushanProgress[guidLow] = progress
    return progress
end

local function SaveKill(guidLow, entry)
    CharDBExecute("INSERT IGNORE INTO `character_mogushan_progress` (`guid`, `entry`) VALUES (" .. guidLow .. ", " .. entry .. ")")
end

local function BroadcastProgress(player, boss, current, total)
    SendWorldMessage("|cff00ccff[Mogu'shan Vaults]|r " .. player:GetName() .. " a vaincu " .. boss.fr .. " ! (" .. current .. "/" .. total .. ")")
    SendWorldMessage("|cff00ccff[Mogu'shan Vaults]|r " .. player:GetName() .. " has defeated " .. boss.en .. "! (" .. current .. "/" .. total .. ")")
end

local function BroadcastCompletion(player)
    SendWorldMessage("|cffffd700[Mogu'shan Vaults]|r " .. player:GetName() .. " a vaincu tous les boss des Caveaux Mogu'shan et obtient le Haut Fait « Caveaux Mogu'shan » !")
    SendWorldMessage("|cffffd700[Mogu'shan Vaults]|r " .. player:GetName() .. " has defeated every boss in Mogu'shan Vaults and earned the achievement \"Mogu'shan Vaults\"!")
end

local function CheckAndGrantAchievement(player, progress)
    if CountProgress(progress) < MOGUSHAN_REQUIRED_COUNT then
        return
    end
    if player:HasAchieved(MOGUSHAN_ACHIEVEMENT_ID) then
        return
    end
    player:SetAchievement(MOGUSHAN_ACHIEVEMENT_ID)
    BroadcastCompletion(player)
end

local function OnKillCreature(event, killer, victim)
    if not killer or not victim then return end

    local entry = victim:GetEntry()
    local boss = MOGUSHAN_BOSSES[entry]
    if not boss then return end

    local guidLow = killer:GetGUIDLow()
    local progress = LoadProgress(guidLow)

    if progress[entry] then
        return -- déjà comptabilisé pour ce joueur
    end

    progress[entry] = true
    SaveKill(guidLow, entry)

    local current = CountProgress(progress)
    BroadcastProgress(killer, boss, current, MOGUSHAN_REQUIRED_COUNT)

    CheckAndGrantAchievement(killer, progress)
end

local function OnLogin(event, player)
    LoadProgress(player:GetGUIDLow())
end

local function OnLogout(event, player)
    MogushanProgress[player:GetGUIDLow()] = nil
end

EnsureTable()

RegisterPlayerEvent(7, OnKillCreature) -- PLAYER_EVENT_ON_KILL_CREATURE
RegisterPlayerEvent(3, OnLogin)        -- PLAYER_EVENT_ON_LOGIN
RegisterPlayerEvent(4, OnLogout)       -- PLAYER_EVENT_ON_LOGOUT
