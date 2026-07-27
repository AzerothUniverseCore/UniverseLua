--[[
    Legion Ship - Suivi de progression du Haut Fait
    "Vaisseau de la Légion" (ID 5024)
    ------------------------------------------------------------------------------------
    - Suit la progression de chaque joueur sur les 3 boss du Vaisseau de la Légion
    - Annonce la progression à chaque boss vaincu via un message broadcast serveur
    - Octroie automatiquement le Haut Fait 5024 une fois les 3 boss vaincus
    - Progression persistante (survit aux déconnexions/redémarrages) via une table
      dédiée dans la base de données characters
]]

local VAISSEAULEGION_ACHIEVEMENT_ID = 5024
local VAISSEAULEGION_REQUIRED_COUNT = 3

-- Entry créature -> Nom (EN / FR), utilisé pour les messages de broadcast
local VAISSEAULEGION_BOSSES = {
    [229170] = { en = "Illidan Stormrage", fr = "Illidan Hurlorage" },
    [229560] = { en = "Sister of Pain",    fr = "Soeur de la douleur" },
    [229640] = { en = "Sister of Pleasure",fr = "Soeur du plaisir" },
}

-- Cache mémoire : [guidLow] = { [entry] = true, ... }
local VaisseauLegionProgress = {}

local function EnsureTable()
    CharDBExecute([[
        CREATE TABLE IF NOT EXISTS `character_vaisseaulegion_progress` (
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
    if VaisseauLegionProgress[guidLow] then
        return VaisseauLegionProgress[guidLow]
    end

    local progress = {}
    local result = CharDBQuery("SELECT `entry` FROM `character_vaisseaulegion_progress` WHERE `guid` = " .. guidLow)
    if result then
        repeat
            progress[result:GetUInt32(0)] = true
        until not result:NextRow()
    end

    VaisseauLegionProgress[guidLow] = progress
    return progress
end

local function SaveKill(guidLow, entry)
    CharDBExecute("INSERT IGNORE INTO `character_vaisseaulegion_progress` (`guid`, `entry`) VALUES (" .. guidLow .. ", " .. entry .. ")")
end

local function BroadcastProgress(player, boss, current, total)
    SendWorldMessage("|cff9370db[Vaisseau de la Légion]|r " .. player:GetName() .. " a vaincu " .. boss.fr .. " ! (" .. current .. "/" .. total .. ")")
    SendWorldMessage("|cff9370db[Legion Ship]|r " .. player:GetName() .. " has defeated " .. boss.en .. "! (" .. current .. "/" .. total .. ")")
end

local function BroadcastCompletion(player)
    SendWorldMessage("|cffffd700[Vaisseau de la Légion]|r " .. player:GetName() .. " a vaincu tous les boss du Vaisseau de la Légion et obtient le Haut Fait « Vaisseau de la Légion » !")
    SendWorldMessage("|cffffd700[Legion Ship]|r " .. player:GetName() .. " has defeated every boss aboard the Legion Ship and earned the achievement \"Legion Ship\"!")
end

local function CheckAndGrantAchievement(player, progress)
    if CountProgress(progress) < VAISSEAULEGION_REQUIRED_COUNT then
        return
    end
    if player:HasAchieved(VAISSEAULEGION_ACHIEVEMENT_ID) then
        return
    end
    player:SetAchievement(VAISSEAULEGION_ACHIEVEMENT_ID)
    BroadcastCompletion(player)
end

local function OnKillCreature(event, killer, victim)
    if not killer or not victim then return end

    local entry = victim:GetEntry()
    local boss = VAISSEAULEGION_BOSSES[entry]
    if not boss then return end

    local guidLow = killer:GetGUIDLow()
    local progress = LoadProgress(guidLow)

    if progress[entry] then
        return -- déjà comptabilisé pour ce joueur
    end

    progress[entry] = true
    SaveKill(guidLow, entry)

    local current = CountProgress(progress)
    BroadcastProgress(killer, boss, current, VAISSEAULEGION_REQUIRED_COUNT)

    CheckAndGrantAchievement(killer, progress)
end

local function OnLogin(event, player)
    LoadProgress(player:GetGUIDLow())
end

local function OnLogout(event, player)
    VaisseauLegionProgress[player:GetGUIDLow()] = nil
end

EnsureTable()

RegisterPlayerEvent(7, OnKillCreature) -- PLAYER_EVENT_ON_KILL_CREATURE
RegisterPlayerEvent(3, OnLogin)        -- PLAYER_EVENT_ON_LOGIN
RegisterPlayerEvent(4, OnLogout)       -- PLAYER_EVENT_ON_LOGOUT
