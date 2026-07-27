--[[
    Black Rook Hold - Suivi de progression du Haut Fait
    "Bastion du Freux" (ID 5036)
    ------------------------------------------------------------------------------------
    - Suit la progression de chaque joueur sur les 3 boss du Bastion du Freux
    - Annonce la progression à chaque boss vaincu via un message broadcast serveur
    - Octroie automatiquement le Haut Fait 5036 une fois les 3 boss vaincus
    - Progression persistante (survit aux déconnexions/redémarrages) via une table
      dédiée dans la base de données characters
]]

local BASTIONFREUX_ACHIEVEMENT_ID = 5036
local BASTIONFREUX_REQUIRED_COUNT = 3

-- Entry créature -> Nom (EN / FR), utilisé pour les messages de broadcast
local BASTIONFREUX_BOSSES = {
    [9940667] = { en = "Dravena",           fr = "Dravena" },
    [9940668] = { en = "Nursery Guardian",  fr = "Gardien de la nurserie" },
    [9940671] = { en = "Nursery Guard",     fr = "Garde Nurserie" },
}

-- Cache mémoire : [guidLow] = { [entry] = true, ... }
local BastionFreuxProgress = {}

local function EnsureTable()
    CharDBExecute([[
        CREATE TABLE IF NOT EXISTS `character_bastionfreux_progress` (
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
    if BastionFreuxProgress[guidLow] then
        return BastionFreuxProgress[guidLow]
    end

    local progress = {}
    local result = CharDBQuery("SELECT `entry` FROM `character_bastionfreux_progress` WHERE `guid` = " .. guidLow)
    if result then
        repeat
            progress[result:GetUInt32(0)] = true
        until not result:NextRow()
    end

    BastionFreuxProgress[guidLow] = progress
    return progress
end

local function SaveKill(guidLow, entry)
    CharDBExecute("INSERT IGNORE INTO `character_bastionfreux_progress` (`guid`, `entry`) VALUES (" .. guidLow .. ", " .. entry .. ")")
end

local function BroadcastProgress(player, boss, current, total)
    SendWorldMessage("|cff556b2f[Bastion du Freux]|r " .. player:GetName() .. " a vaincu " .. boss.fr .. " ! (" .. current .. "/" .. total .. ")")
    SendWorldMessage("|cff556b2f[Black Rook Hold]|r " .. player:GetName() .. " has defeated " .. boss.en .. "! (" .. current .. "/" .. total .. ")")
end

local function BroadcastCompletion(player)
    SendWorldMessage("|cffffd700[Bastion du Freux]|r " .. player:GetName() .. " a vaincu tous les boss du Bastion du Freux et obtient le Haut Fait « Bastion du Freux » !")
    SendWorldMessage("|cffffd700[Black Rook Hold]|r " .. player:GetName() .. " has defeated every boss in Black Rook Hold and earned the achievement \"Black Rook Hold\"!")
end

local function CheckAndGrantAchievement(player, progress)
    if CountProgress(progress) < BASTIONFREUX_REQUIRED_COUNT then
        return
    end
    if player:HasAchieved(BASTIONFREUX_ACHIEVEMENT_ID) then
        return
    end
    player:SetAchievement(BASTIONFREUX_ACHIEVEMENT_ID)
    BroadcastCompletion(player)
end

local function OnKillCreature(event, killer, victim)
    if not killer or not victim then return end

    local entry = victim:GetEntry()
    local boss = BASTIONFREUX_BOSSES[entry]
    if not boss then return end

    local guidLow = killer:GetGUIDLow()
    local progress = LoadProgress(guidLow)

    if progress[entry] then
        return -- déjà comptabilisé pour ce joueur
    end

    progress[entry] = true
    SaveKill(guidLow, entry)

    local current = CountProgress(progress)
    BroadcastProgress(killer, boss, current, BASTIONFREUX_REQUIRED_COUNT)

    CheckAndGrantAchievement(killer, progress)
end

local function OnLogin(event, player)
    LoadProgress(player:GetGUIDLow())
end

local function OnLogout(event, player)
    BastionFreuxProgress[player:GetGUIDLow()] = nil
end

EnsureTable()

RegisterPlayerEvent(7, OnKillCreature) -- PLAYER_EVENT_ON_KILL_CREATURE
RegisterPlayerEvent(3, OnLogin)        -- PLAYER_EVENT_ON_LOGIN
RegisterPlayerEvent(4, OnLogout)       -- PLAYER_EVENT_ON_LOGOUT
