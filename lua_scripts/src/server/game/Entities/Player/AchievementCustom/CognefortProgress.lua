--[[
    Cognefort - Suivi de progression du Haut Fait "Cognefort" (ID 5014)
    -----------------------------------------------------------------------------
    - Suit la progression de chaque joueur sur les boss de Cognefort
    - Annonce la progression à chaque boss vaincu via un message broadcast serveur
    - Octroie automatiquement le Haut Fait 5014 une fois tous les boss vaincus
    - Progression persistante (survit aux déconnexions/redémarrages) via une table
      dédiée dans la base de données characters

    IMPORTANT : le fichier achievement.sql fourni déclare `count = 19` pour ce Haut
    Fait, mais achievement_criteria.sql ne contient que 12 critères de type
    "Défaite créature" (IDs 15037-15044, 15051, 15053-15055 ; il manque 15045-15050
    et 15052). Conformément à ta demande, le seuil est fixé à 12 (les boss
    effectivement fournis). Si tu retrouves les 7 critères manquants, renvoie-les
    et j'ajusterai le script.
]]

local COGNEFORT_ACHIEVEMENT_ID = 5014
local COGNEFORT_REQUIRED_COUNT = 12

-- Entry créature -> Nom (EN / FR), utilisé pour les messages de broadcast
local COGNEFORT_BOSSES = {
    [650014]   = { en = "Dreadlord",         fr = "Dreadlord" },
    [5100124]  = { en = "Margt'har",         fr = "Margt'har" },
    [5100125]  = { en = "Norjh",             fr = "Norjh" },
    [5100126]  = { en = "Emissary Khaaz",    fr = "Emissary Khaaz" },
    [5100127]  = { en = "Firelord Rak",      fr = "Firelord Rak" },
    [5100128]  = { en = "Notrazius",         fr = "Notrazius" },
    [5100129]  = { en = "Echo of Maulgar",   fr = "Echo of Maulgar" },
    [5100148]  = { en = "Firelord Purp",     fr = "Firelord Purp" },
    [9000359]  = { en = "Thokk",             fr = "Thokk" },
    [9000371]  = { en = "Gnarsh",            fr = "Gnarsh" },
    [9000384]  = { en = "Karash",            fr = "Karash" },
    [9000386]  = { en = "Sai'kkal",          fr = "Sai'kkal" },
}

-- Cache mémoire : [guidLow] = { [entry] = true, ... }
local CognefortProgress = {}

local function EnsureTable()
    CharDBExecute([[
        CREATE TABLE IF NOT EXISTS `character_cognefort_progress` (
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
    if CognefortProgress[guidLow] then
        return CognefortProgress[guidLow]
    end

    local progress = {}
    local result = CharDBQuery("SELECT `entry` FROM `character_cognefort_progress` WHERE `guid` = " .. guidLow)
    if result then
        repeat
            progress[result:GetUInt32(0)] = true
        until not result:NextRow()
    end

    CognefortProgress[guidLow] = progress
    return progress
end

local function SaveKill(guidLow, entry)
    CharDBExecute("INSERT IGNORE INTO `character_cognefort_progress` (`guid`, `entry`) VALUES (" .. guidLow .. ", " .. entry .. ")")
end

local function BroadcastProgress(player, boss, current, total)
    SendWorldMessage("|cff8b4513[Cognefort]|r " .. player:GetName() .. " a vaincu " .. boss.fr .. " ! (" .. current .. "/" .. total .. ")")
    SendWorldMessage("|cff8b4513[Cognefort]|r " .. player:GetName() .. " has defeated " .. boss.en .. "! (" .. current .. "/" .. total .. ")")
end

local function BroadcastCompletion(player)
    SendWorldMessage("|cffffd700[Cognefort]|r " .. player:GetName() .. " a vaincu tous les boss de Cognefort et obtient le Haut Fait « Cognefort » !")
    SendWorldMessage("|cffffd700[Cognefort]|r " .. player:GetName() .. " has defeated every boss of Cognefort and earned the achievement \"Cognefort\"!")
end

local function CheckAndGrantAchievement(player, progress)
    if CountProgress(progress) < COGNEFORT_REQUIRED_COUNT then
        return
    end
    if player:HasAchieved(COGNEFORT_ACHIEVEMENT_ID) then
        return
    end
    player:SetAchievement(COGNEFORT_ACHIEVEMENT_ID)
    BroadcastCompletion(player)
end

local function OnKillCreature(event, killer, victim)
    if not killer or not victim then return end

    local entry = victim:GetEntry()
    local boss = COGNEFORT_BOSSES[entry]
    if not boss then return end

    local guidLow = killer:GetGUIDLow()
    local progress = LoadProgress(guidLow)

    if progress[entry] then
        return -- déjà comptabilisé pour ce joueur
    end

    progress[entry] = true
    SaveKill(guidLow, entry)

    local current = CountProgress(progress)
    BroadcastProgress(killer, boss, current, COGNEFORT_REQUIRED_COUNT)

    CheckAndGrantAchievement(killer, progress)
end

local function OnLogin(event, player)
    LoadProgress(player:GetGUIDLow())
end

local function OnLogout(event, player)
    CognefortProgress[player:GetGUIDLow()] = nil
end

EnsureTable()

RegisterPlayerEvent(7, OnKillCreature) -- PLAYER_EVENT_ON_KILL_CREATURE
RegisterPlayerEvent(3, OnLogin)        -- PLAYER_EVENT_ON_LOGIN
RegisterPlayerEvent(4, OnLogout)       -- PLAYER_EVENT_ON_LOGOUT
