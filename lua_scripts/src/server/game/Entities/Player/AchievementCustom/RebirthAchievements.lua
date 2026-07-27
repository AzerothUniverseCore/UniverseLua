--[[
    RebirthAchievements.lua (Eluna - cote serveur)

    Attribue automatiquement le(s) haut(s) fait(s) "Rebirth X" correspondant(s)
    lorsqu'un joueur tue la creature "Preuve" associee (les PNJ du Domaine
    Empyreen, cf. rebirth_config_proof_teleports.sql fourni dans l'archive).

    D'ou vient le mapping ci-dessous :
    - achievement_criteria.sql : chaque ligne a `requiredType = 0`, qui
      correspond a ACHIEVEMENT_CRITERIA_TYPE_KILL_CREATURE dans TrinityCore /
      AzerothCore. Pour ce type de critere, la colonne `assetType` contient
      l'ID (entry) de la creature a tuer.
    - `referredAchievement` (2e colonne) donne l'ID du haut fait a valider
      (voir achievement.sql pour le nom/la description de chaque ID).

    Une creature peut valider PLUSIEURS hauts faits (ex : la creature 7000209
    valide a la fois 5009 "Rebirth 10 Private" et 5013 "Rebirth 10 It's Over
    Nine Thousand!") : chaque entree de REBIRTH_ACHIEVEMENTS est donc une
    LISTE d'IDs, et OnKillCreature les attribue tous a la suite.

    IMPORTANT avant de mettre ce script en ligne :
    1) Importer achievement.sql, achievement_criteria.sql et
       achievement_criteria_data.sql fournis dans l'archive (base utilisee
       par votre core pour les tables d'achievement/DBC override), en
       s'assurant que le haut fait 5013 y figure bien.
    2) S'assurer que les creature_template avec les entry 7000200 a 7000230
       existent bien sur le serveur (ils ne sont pas inclus dans l'archive).
]]

local REBIRTH_ACHIEVEMENTS = {
    [7000200] = { 5000 },              -- Rebirth 1
    [7000201] = { 5001 },              -- Rebirth 2
    [7000202] = { 5002 },              -- Rebirth 3
    [7000203] = { 5003 },              -- Rebirth 4
    [7000204] = { 5004 },              -- Rebirth 5
    [7000205] = { 5005 },              -- Rebirth 6
    [7000206] = { 5006 },              -- Rebirth 7
    [7000207] = { 5007 },              -- Rebirth 8
    [7000208] = { 5008 },              -- Rebirth 9
    [7000209] = { 5009, 5013 },        -- Rebirth 10 Private / Soldat + Rebirth 10 It's Over Nine Thousand!
    [7000210] = { 5015 },              -- Rebirth 11 Quartermaster / Quartier maitre
    [7000211] = { 5016 },              -- Rebirth 12 Master / Maitre
    [7000212] = { 5017 },              -- Rebirth 13 Major
    [7000213] = { 5018 },              -- Rebirth 14 Captain / Capitaine
    [7000214] = { 5026 },              -- Rebirth 15 Commander / Commandant
    [7000215] = { 5027 },              -- Rebirth 16 Lieutenant Colonel / Lieutenant-colonel
    [7000216] = { 5028 },              -- Rebirth 17 Colonel
    [7000217] = { 5029 },              -- Rebirth 18 Vice General / Vice General
    [7000218] = { 5030 },              -- Rebirth 19 General / General
    [7000219] = { 5031 },              -- Rebirth 20 Vice Admiral / Vice Amiral
    [7000220] = { 5032 },              -- Rebirth 21 Admiral / Amiral
    [7000221] = { 5033 },              -- Rebirth 22 Constable / Connetable
    [7000222] = { 5034 },              -- Rebirth 23 Marshal / Marechal
    [7000225] = { 5038 },              -- Rebirth 25 Grand Marshal / Grand Marechal
    [7000230] = { 5039 },              -- Rebirth 30 Living Legend / Legende Vivante
}

-- Nom du haut fait par langue (repris de achievement.sql : name1 = enUS, name3 = frFR).
local REBIRTH_TITLES = {
    [5000] = { enUS = "Rebirth 1",                          frFR = "Rebirth 1" },
    [5001] = { enUS = "Rebirth 2",                          frFR = "Rebirth 2" },
    [5002] = { enUS = "Rebirth 3",                          frFR = "Rebirth 3" },
    [5003] = { enUS = "Rebirth 4",                          frFR = "Rebirth 4" },
    [5004] = { enUS = "Rebirth 5",                          frFR = "Rebirth 5" },
    [5005] = { enUS = "Rebirth 6",                          frFR = "Rebirth 6" },
    [5006] = { enUS = "Rebirth 7",                          frFR = "Rebirth 7" },
    [5007] = { enUS = "Rebirth 8",                          frFR = "Rebirth 8" },
    [5008] = { enUS = "Rebirth 9",                          frFR = "Rebirth 9" },
    [5009] = { enUS = "Rebirth 10 Private",                 frFR = "Rebirth 10 Soldat" },
    [5013] = { enUS = "Rebirth 10 It's Over Nine Thousand!", frFR = "Rebirth 10 It's Over Nine Thousand!" },
    [5015] = { enUS = "Rebirth 11 Quartermaster",           frFR = "Rebirth 11 Quartier maître" },
    [5016] = { enUS = "Rebirth 12 Master",                  frFR = "Rebirth 12 Maître" },
    [5017] = { enUS = "Rebirth 13 Major",                   frFR = "Rebirth 13 Major" },
    [5018] = { enUS = "Rebirth 14 Captain",                 frFR = "Rebirth 14 Capitaine" },
    [5026] = { enUS = "Rebirth 15 Commander",               frFR = "Rebirth 15 Commandant" },
    [5027] = { enUS = "Rebirth 16 Lieutenant Colonel",      frFR = "Rebirth 16 Lieutenant-colonel" },
    [5028] = { enUS = "Rebirth 17 Colonel",                 frFR = "Rebirth 17 Colonel" },
    [5029] = { enUS = "Rebirth 18 Vice General",            frFR = "Rebirth 18 Vice Général" },
    [5030] = { enUS = "Rebirth 19 General",                 frFR = "Rebirth 19 Général" },
    [5031] = { enUS = "Rebirth 20 Vice Admiral",            frFR = "Rebirth 20 Vice Amiral" },
    [5032] = { enUS = "Rebirth 21 Admiral",                 frFR = "Rebirth 21 Amiral" },
    [5033] = { enUS = "Rebirth 22 Constable",               frFR = "Rebirth 22 Connétable" },
    [5034] = { enUS = "Rebirth 23 Marshal",                 frFR = "Rebirth 23 Maréchal" },
    [5038] = { enUS = "Rebirth 25 Grand Marshal",           frFR = "Rebirth 25 Grand Maréchal" },
    [5039] = { enUS = "Rebirth 30 Living Legend",           frFR = "Rebirth 30 Légende Vivante" },
}

-- LocaleConstant (Eluna / TrinityCore-AzerothCore) : enUS = 0, koKR = 1, frFR = 2,
-- deDE = 3, zhCN = 4, zhTW = 5, esES = 6, esMX = 7, ruRU = 8.
local LOCALE_FRFR = 2

-- Mettre a false pour desactiver le message de confirmation dans le chat.
local ANNOUNCE_ACHIEVEMENT = true

local function AnnounceRebirthAchievement(player, achievementId)
    if not ANNOUNCE_ACHIEVEMENT then
        return
    end

    local titles = REBIRTH_TITLES[achievementId]
    local isFrench = (player:GetDbcLocale() == LOCALE_FRFR)
    local title = titles and (isFrench and titles.frFR or titles.enUS) or ("#" .. achievementId)

    if isFrench then
        player:SendBroadcastMessage("|cffc9a227[Rebirth]|r Haut fait obtenu : " .. title)
    else
        player:SendBroadcastMessage("|cffc9a227[Rebirth]|r Achievement earned: " .. title)
    end
end

local function OnKillCreature(event, killer, killed)
    if not killer or not killed then
        return
    end

    local achievementIds = REBIRTH_ACHIEVEMENTS[killed:GetEntry()]
    if not achievementIds then
        return
    end

    for _, achievementId in ipairs(achievementIds) do
        if not killer:HasAchieved(achievementId) then
            killer:SetAchievement(achievementId)
            AnnounceRebirthAchievement(killer, achievementId)
        end
    end
end

RegisterPlayerEvent(7, OnKillCreature) -- PLAYER_EVENT_ON_KILL_CREATURE
