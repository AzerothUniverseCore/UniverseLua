--[[
    Fyralands - Suivi de progression du Haut Fait "Les terres de Fyra" (ID 5010)
    -----------------------------------------------------------------------------
    - Suit la progression de chaque joueur sur les 14 boss des terres de Fyra
    - Annonce la progression à chaque boss vaincu via un message broadcast serveur
    - Octroie automatiquement le Haut Fait 5010 une fois les 14 boss vaincus
    - Progression persistante (survit aux déconnexions/redémarrages) via une table
      dédiée dans la base de données characters
]]

local FYRALANDS_ACHIEVEMENT_ID = 5010
local FYRALANDS_REQUIRED_COUNT = 14

-- Entry créature -> Nom (EN / FR), utilisé pour les messages de broadcast
local FYRALANDS_BOSSES = {
    [7000100] = { en = "Skeelta",           fr = "Skeelta" },
    [7000102] = { en = "Rhyolith",          fr = "Rhyolith" },
    [7000103] = { en = "Phelo",             fr = "Phélo" },
    [7000108] = { en = "Tak'rog",           fr = "Tak'rog" },
    [7000109] = { en = "Zeykha",            fr = "Zeykha" },
    [7000110] = { en = "Skault",            fr = "Skault" },
    [7000111] = { en = "Gilwart",           fr = "Gilwart" },
    [7000112] = { en = "Primordial Damned", fr = "Damné primordial" },
    [7000113] = { en = "Cyberos",           fr = "Cybéros" },
    [7000129] = { en = "Fyra",              fr = "Fyra" },
    [7000130] = { en = "Ghylion",           fr = "Ghylion" },
    [7000131] = { en = "Hyterun",           fr = "Hyterun" },
    [7000139] = { en = "Wilgart",           fr = "Wilgart" },
    [7000143] = { en = "Minoleuse",         fr = "Minoléuse" },
}

-- Cache mémoire : [guidLow] = { [entry] = true, ... }
local FyralandsProgress = {}

local function EnsureTable()
    CharDBExecute([[
        CREATE TABLE IF NOT EXISTS `character_fyralands_progress` (
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
    if FyralandsProgress[guidLow] then
        return FyralandsProgress[guidLow]
    end

    local progress = {}
    local result = CharDBQuery("SELECT `entry` FROM `character_fyralands_progress` WHERE `guid` = " .. guidLow)
    if result then
        repeat
            progress[result:GetUInt32(0)] = true
        until not result:NextRow()
    end

    FyralandsProgress[guidLow] = progress
    return progress
end

local function SaveKill(guidLow, entry)
    CharDBExecute("INSERT IGNORE INTO `character_fyralands_progress` (`guid`, `entry`) VALUES (" .. guidLow .. ", " .. entry .. ")")
end

local function BroadcastProgress(player, boss, current, total)
    SendWorldMessage("|cffff8000[Fyralands]|r " .. player:GetName() .. " a vaincu " .. boss.fr .. " ! (" .. current .. "/" .. total .. ")")
    SendWorldMessage("|cffff8000[Fyralands]|r " .. player:GetName() .. " has defeated " .. boss.en .. "! (" .. current .. "/" .. total .. ")")
end

local function BroadcastCompletion(player)
    SendWorldMessage("|cffffd700[Fyralands]|r " .. player:GetName() .. " a vaincu tous les boss des terres de Fyra et obtient le Haut Fait « Les terres de Fyra » !")
    SendWorldMessage("|cffffd700[Fyralands]|r " .. player:GetName() .. " has defeated every boss in the Lands of Fyra and earned the achievement \"The Lands of Fyra\"!")
end

local function CheckAndGrantAchievement(player, progress)
    if CountProgress(progress) < FYRALANDS_REQUIRED_COUNT then
        return
    end
    if player:HasAchieved(FYRALANDS_ACHIEVEMENT_ID) then
        return
    end
    player:SetAchievement(FYRALANDS_ACHIEVEMENT_ID)
    BroadcastCompletion(player)
end

local function OnKillCreature(event, killer, victim)
    if not killer or not victim then return end

    local entry = victim:GetEntry()
    local boss = FYRALANDS_BOSSES[entry]
    if not boss then return end

    local guidLow = killer:GetGUIDLow()
    local progress = LoadProgress(guidLow)

    if progress[entry] then
        return -- déjà comptabilisé pour ce joueur
    end

    progress[entry] = true
    SaveKill(guidLow, entry)

    local current = CountProgress(progress)
    BroadcastProgress(killer, boss, current, FYRALANDS_REQUIRED_COUNT)

    CheckAndGrantAchievement(killer, progress)
end

local function OnLogin(event, player)
    LoadProgress(player:GetGUIDLow())
end

local function OnLogout(event, player)
    FyralandsProgress[player:GetGUIDLow()] = nil
end

EnsureTable()

RegisterPlayerEvent(7, OnKillCreature) -- PLAYER_EVENT_ON_KILL_CREATURE
RegisterPlayerEvent(3, OnLogin)        -- PLAYER_EVENT_ON_LOGIN
RegisterPlayerEvent(4, OnLogout)       -- PLAYER_EVENT_ON_LOGOUT
