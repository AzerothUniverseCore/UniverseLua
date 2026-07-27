--[[
    Temple of the Jade Serpent - Suivi de progression du Haut Fait
    "Temple du Serpent de Jade" (ID 5021)
    ------------------------------------------------------------------------------------
    - Suit la progression de chaque joueur sur les 4 boss du Temple du Serpent de Jade
    - Annonce la progression à chaque boss vaincu via un message broadcast serveur
    - Octroie automatiquement le Haut Fait 5021 une fois les 4 boss vaincus
    - Progression persistante (survit aux déconnexions/redémarrages) via une table
      dédiée dans la base de données characters
]]

local SERPENTDEJADE_ACHIEVEMENT_ID = 5021
local SERPENTDEJADE_REQUIRED_COUNT = 4

-- Entry créature -> Nom (EN / FR), utilisé pour les messages de broadcast
local SERPENTDEJADE_BOSSES = {
    [9000022] = { en = "Kriphine",  fr = "Kriphine" },
    [9100001] = { en = "Frahin",    fr = "Frahïn" },
    [9100003] = { en = "Nar'za",    fr = "Nar'za" },
    [9100013] = { en = "Nalash'ka", fr = "Nalash'ka" },
}

-- Cache mémoire : [guidLow] = { [entry] = true, ... }
local SerpentDeJadeProgress = {}

local function EnsureTable()
    CharDBExecute([[
        CREATE TABLE IF NOT EXISTS `character_serpentdejade_progress` (
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
    if SerpentDeJadeProgress[guidLow] then
        return SerpentDeJadeProgress[guidLow]
    end

    local progress = {}
    local result = CharDBQuery("SELECT `entry` FROM `character_serpentdejade_progress` WHERE `guid` = " .. guidLow)
    if result then
        repeat
            progress[result:GetUInt32(0)] = true
        until not result:NextRow()
    end

    SerpentDeJadeProgress[guidLow] = progress
    return progress
end

local function SaveKill(guidLow, entry)
    CharDBExecute("INSERT IGNORE INTO `character_serpentdejade_progress` (`guid`, `entry`) VALUES (" .. guidLow .. ", " .. entry .. ")")
end

local function BroadcastProgress(player, boss, current, total)
    SendWorldMessage("|cff33ff99[Temple du Serpent de Jade]|r " .. player:GetName() .. " a vaincu " .. boss.fr .. " ! (" .. current .. "/" .. total .. ")")
    SendWorldMessage("|cff33ff99[Temple of the Jade Serpent]|r " .. player:GetName() .. " has defeated " .. boss.en .. "! (" .. current .. "/" .. total .. ")")
end

local function BroadcastCompletion(player)
    SendWorldMessage("|cffffd700[Temple du Serpent de Jade]|r " .. player:GetName() .. " a vaincu tous les boss du Temple du Serpent de Jade et obtient le Haut Fait « Temple du Serpent de Jade » !")
    SendWorldMessage("|cffffd700[Temple of the Jade Serpent]|r " .. player:GetName() .. " has defeated every boss in the Temple of the Jade Serpent and earned the achievement \"Temple of the Jade Serpent\"!")
end

local function CheckAndGrantAchievement(player, progress)
    if CountProgress(progress) < SERPENTDEJADE_REQUIRED_COUNT then
        return
    end
    if player:HasAchieved(SERPENTDEJADE_ACHIEVEMENT_ID) then
        return
    end
    player:SetAchievement(SERPENTDEJADE_ACHIEVEMENT_ID)
    BroadcastCompletion(player)
end

local function OnKillCreature(event, killer, victim)
    if not killer or not victim then return end

    local entry = victim:GetEntry()
    local boss = SERPENTDEJADE_BOSSES[entry]
    if not boss then return end

    local guidLow = killer:GetGUIDLow()
    local progress = LoadProgress(guidLow)

    if progress[entry] then
        return -- déjà comptabilisé pour ce joueur
    end

    progress[entry] = true
    SaveKill(guidLow, entry)

    local current = CountProgress(progress)
    BroadcastProgress(killer, boss, current, SERPENTDEJADE_REQUIRED_COUNT)

    CheckAndGrantAchievement(killer, progress)
end

local function OnLogin(event, player)
    LoadProgress(player:GetGUIDLow())
end

local function OnLogout(event, player)
    SerpentDeJadeProgress[player:GetGUIDLow()] = nil
end

EnsureTable()

RegisterPlayerEvent(7, OnKillCreature) -- PLAYER_EVENT_ON_KILL_CREATURE
RegisterPlayerEvent(3, OnLogin)        -- PLAYER_EVENT_ON_LOGIN
RegisterPlayerEvent(4, OnLogout)       -- PLAYER_EVENT_ON_LOGOUT
