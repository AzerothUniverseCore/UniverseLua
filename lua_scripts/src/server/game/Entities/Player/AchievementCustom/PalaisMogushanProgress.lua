--[[
    Mogu'shan Palace - Suivi de progression du Haut Fait "Palais Mogu'Shan" (ID 5020)
    ------------------------------------------------------------------------------------
    - Suit la progression de chaque joueur sur les 10 boss du Palais Mogu'Shan
    - Annonce la progression à chaque boss vaincu via un message broadcast serveur
    - Octroie automatiquement le Haut Fait 5020 une fois les 10 boss vaincus
    - Progression persistante (survit aux déconnexions/redémarrages) via une table
      dédiée dans la base de données characters
]]

local PALAISMOGUSHAN_ACHIEVEMENT_ID = 5020
local PALAISMOGUSHAN_REQUIRED_COUNT = 10

-- Entry créature -> Nom (EN / FR), utilisé pour les messages de broadcast
local PALAISMOGUSHAN_BOSSES = {
    [9100014] = { en = "Temple Guardian",           fr = "Gardien du temple" },
    [9100016] = { en = "Daughter of the Nightmare", fr = "La Fille du cauchemar" },
    [9100017] = { en = "Ilizh",                     fr = "Ilizh" },
    [9100018] = { en = "Reth'erh",                  fr = "Reth'erh" },
    [9100020] = { en = "The Gaze of Reth'erh",      fr = "Le regard de Reth'erh" },
    [9100024] = { en = "Captain Nahilia",           fr = "Capitaine Nahilia" },
    [9100029] = { en = "Mage Lehan",                fr = "Mage Lehan" },
    [9100030] = { en = "Priest Ryh",                fr = "Prêtre Ryh" },
    [9100033] = { en = "Khalyha",                   fr = "Khalyha" },
    [9100034] = { en = "Kerhyna",                   fr = "Kerhyna" },
}

-- Cache mémoire : [guidLow] = { [entry] = true, ... }
local PalaisMogushanProgress = {}

local function EnsureTable()
    CharDBExecute([[
        CREATE TABLE IF NOT EXISTS `character_palaismogushan_progress` (
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
    if PalaisMogushanProgress[guidLow] then
        return PalaisMogushanProgress[guidLow]
    end

    local progress = {}
    local result = CharDBQuery("SELECT `entry` FROM `character_palaismogushan_progress` WHERE `guid` = " .. guidLow)
    if result then
        repeat
            progress[result:GetUInt32(0)] = true
        until not result:NextRow()
    end

    PalaisMogushanProgress[guidLow] = progress
    return progress
end

local function SaveKill(guidLow, entry)
    CharDBExecute("INSERT IGNORE INTO `character_palaismogushan_progress` (`guid`, `entry`) VALUES (" .. guidLow .. ", " .. entry .. ")")
end

local function BroadcastProgress(player, boss, current, total)
    SendWorldMessage("|cff9933ff[Palais Mogu'Shan]|r " .. player:GetName() .. " a vaincu " .. boss.fr .. " ! (" .. current .. "/" .. total .. ")")
    SendWorldMessage("|cff9933ff[Mogu'shan Palace]|r " .. player:GetName() .. " has defeated " .. boss.en .. "! (" .. current .. "/" .. total .. ")")
end

local function BroadcastCompletion(player)
    SendWorldMessage("|cffffd700[Palais Mogu'Shan]|r " .. player:GetName() .. " a vaincu tous les boss du Palais Mogu'Shan et obtient le Haut Fait « Palais Mogu'Shan » !")
    SendWorldMessage("|cffffd700[Mogu'shan Palace]|r " .. player:GetName() .. " has defeated every boss in Mogu'shan Palace and earned the achievement \"Mogu'shan Palace\"!")
end

local function CheckAndGrantAchievement(player, progress)
    if CountProgress(progress) < PALAISMOGUSHAN_REQUIRED_COUNT then
        return
    end
    if player:HasAchieved(PALAISMOGUSHAN_ACHIEVEMENT_ID) then
        return
    end
    player:SetAchievement(PALAISMOGUSHAN_ACHIEVEMENT_ID)
    BroadcastCompletion(player)
end

local function OnKillCreature(event, killer, victim)
    if not killer or not victim then return end

    local entry = victim:GetEntry()
    local boss = PALAISMOGUSHAN_BOSSES[entry]
    if not boss then return end

    local guidLow = killer:GetGUIDLow()
    local progress = LoadProgress(guidLow)

    if progress[entry] then
        return -- déjà comptabilisé pour ce joueur
    end

    progress[entry] = true
    SaveKill(guidLow, entry)

    local current = CountProgress(progress)
    BroadcastProgress(killer, boss, current, PALAISMOGUSHAN_REQUIRED_COUNT)

    CheckAndGrantAchievement(killer, progress)
end

local function OnLogin(event, player)
    LoadProgress(player:GetGUIDLow())
end

local function OnLogout(event, player)
    PalaisMogushanProgress[player:GetGUIDLow()] = nil
end

EnsureTable()

RegisterPlayerEvent(7, OnKillCreature) -- PLAYER_EVENT_ON_KILL_CREATURE
RegisterPlayerEvent(3, OnLogin)        -- PLAYER_EVENT_ON_LOGIN
RegisterPlayerEvent(4, OnLogout)       -- PLAYER_EVENT_ON_LOGOUT
