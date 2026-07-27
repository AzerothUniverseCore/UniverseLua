--[[
    Baradin Hold - Suivi de progression du Haut Fait
    "Bastion de Baradin" (ID 5035)
    ------------------------------------------------------------------------------------
    - Suit la progression de chaque joueur sur les 3 boss du Bastion de Baradin
    - Annonce la progression à chaque boss vaincu via un message broadcast serveur
    - Octroie automatiquement le Haut Fait 5035 une fois les 3 boss vaincus
    - Progression persistante (survit aux déconnexions/redémarrages) via une table
      dédiée dans la base de données characters
]]

local BASTIONBARADIN_ACHIEVEMENT_ID = 5035
local BASTIONBARADIN_REQUIRED_COUNT = 3

-- Entry créature -> Nom (EN / FR), utilisé pour les messages de broadcast
local BASTIONBARADIN_BOSSES = {
    [9940663] = { en = "Vashandra the Fallen",      fr = "Vashandra la Déchue" },
    [9940672] = { en = "Vorgoth the Slaughterer",   fr = "Vorgoth le massacreur" },
    [9940673] = { en = "Kurzok the Soul Devourer",  fr = "Kurzok le dêvoreur d'âmes" },
}

-- Cache mémoire : [guidLow] = { [entry] = true, ... }
local BastionBaradinProgress = {}

local function EnsureTable()
    CharDBExecute([[
        CREATE TABLE IF NOT EXISTS `character_bastionbaradin_progress` (
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
    if BastionBaradinProgress[guidLow] then
        return BastionBaradinProgress[guidLow]
    end

    local progress = {}
    local result = CharDBQuery("SELECT `entry` FROM `character_bastionbaradin_progress` WHERE `guid` = " .. guidLow)
    if result then
        repeat
            progress[result:GetUInt32(0)] = true
        until not result:NextRow()
    end

    BastionBaradinProgress[guidLow] = progress
    return progress
end

local function SaveKill(guidLow, entry)
    CharDBExecute("INSERT IGNORE INTO `character_bastionbaradin_progress` (`guid`, `entry`) VALUES (" .. guidLow .. ", " .. entry .. ")")
end

local function BroadcastProgress(player, boss, current, total)
    SendWorldMessage("|cffcc3333[Bastion de Baradin]|r " .. player:GetName() .. " a vaincu " .. boss.fr .. " ! (" .. current .. "/" .. total .. ")")
    SendWorldMessage("|cffcc3333[Baradin Hold]|r " .. player:GetName() .. " has defeated " .. boss.en .. "! (" .. current .. "/" .. total .. ")")
end

local function BroadcastCompletion(player)
    SendWorldMessage("|cffffd700[Bastion de Baradin]|r " .. player:GetName() .. " a vaincu tous les boss du Bastion de Baradin et obtient le Haut Fait « Bastion de Baradin » !")
    SendWorldMessage("|cffffd700[Baradin Hold]|r " .. player:GetName() .. " has defeated every boss in Baradin Hold and earned the achievement \"Baradin Hold\"!")
end

local function CheckAndGrantAchievement(player, progress)
    if CountProgress(progress) < BASTIONBARADIN_REQUIRED_COUNT then
        return
    end
    if player:HasAchieved(BASTIONBARADIN_ACHIEVEMENT_ID) then
        return
    end
    player:SetAchievement(BASTIONBARADIN_ACHIEVEMENT_ID)
    BroadcastCompletion(player)
end

local function OnKillCreature(event, killer, victim)
    if not killer or not victim then return end

    local entry = victim:GetEntry()
    local boss = BASTIONBARADIN_BOSSES[entry]
    if not boss then return end

    local guidLow = killer:GetGUIDLow()
    local progress = LoadProgress(guidLow)

    if progress[entry] then
        return -- déjà comptabilisé pour ce joueur
    end

    progress[entry] = true
    SaveKill(guidLow, entry)

    local current = CountProgress(progress)
    BroadcastProgress(killer, boss, current, BASTIONBARADIN_REQUIRED_COUNT)

    CheckAndGrantAchievement(killer, progress)
end

local function OnLogin(event, player)
    LoadProgress(player:GetGUIDLow())
end

local function OnLogout(event, player)
    BastionBaradinProgress[player:GetGUIDLow()] = nil
end

EnsureTable()

RegisterPlayerEvent(7, OnKillCreature) -- PLAYER_EVENT_ON_KILL_CREATURE
RegisterPlayerEvent(3, OnLogin)        -- PLAYER_EVENT_ON_LOGIN
RegisterPlayerEvent(4, OnLogout)       -- PLAYER_EVENT_ON_LOGOUT
