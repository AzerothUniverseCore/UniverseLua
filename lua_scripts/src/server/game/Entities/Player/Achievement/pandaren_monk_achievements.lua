-- ============================================================
-- Pandaren & Moine - Hauts Faits "PREM'S" au Niveau 80
-- TrinityCore 3.3.5 | Eluna (ElunaTrinityWotlk)
-- 
-- Achievement 6753 : PREMIER Pandaren du royaume à niveau 80
-- Achievement 6752 : PREMIER Moine du royaume à niveau 80
--
-- Vérification DB : character_achievement
-- Une fois attribué, impossible de le redonner à un autre
-- ============================================================

-- -------------------------------------------------------
-- Constantes
-- -------------------------------------------------------
local RACE_PANDAREN_ALLIANCE = 25
local RACE_PANDAREN_HORDE    = 26
local CLASS_MONK             = 10

local ACHIEVEMENT_PANDAREN   = 6753   -- "PREMIER Pandaren au niveau 80"
local ACHIEVEMENT_MONK       = 6752   -- "PREMIER Moine au niveau 80"

local MAX_LEVEL              = 80

-- -------------------------------------------------------
-- Fonction : Vérifier si un achievement a déjà été attribué
-- Query la DB character_achievement pour l'ID
-- -------------------------------------------------------
local function IsAchievementAlreadyEarned(achievementId)
    local query = CharDBQuery("SELECT achievement FROM character_achievement WHERE achievement = " .. achievementId .. " LIMIT 1")
    
    if query then
        return true
    end
    return false
end

-- -------------------------------------------------------
-- Fonction utilitaire : octroyer un achievement "PREM'S"
-- Vérifie d'abord si personne d'autre ne l'a encore
-- -------------------------------------------------------
local function GiveFirstAchievementIfNotEarned(player, achievementId)
    -- Si le joueur l'a déjà, ne rien faire
    if player:HasAchieved(achievementId) then
        return false
    end
    
    -- Vérifier si quelqu'un d'autre a déjà cet achievement dans la DB
    if IsAchievementAlreadyEarned(achievementId) then
        return false
    end
    
    -- Personne ne l'a → le donner à ce joueur
    player:SetAchievement(achievementId)
    return true
end

-- -------------------------------------------------------
-- Handler : déclenché à chaque gain de niveau
-- -------------------------------------------------------
local function OnPlayerLevelUp(event, player, oldLevel)
    local newLevel = player:GetLevel()

    -- On ne traite que l'atteinte du niveau maximum
    if newLevel < MAX_LEVEL then
        return
    end

    local race  = player:GetRace()
    local class = player:GetClass()
    local playerName = player:GetName()

    -- PREM'S Pandaren (race Alliance ou Horde)
    if race == RACE_PANDAREN_ALLIANCE or race == RACE_PANDAREN_HORDE then
        if GiveFirstAchievementIfNotEarned(player, ACHIEVEMENT_PANDAREN) then
            SendWorldMessage("|cff00ff00[PREM'S] " .. playerName .. " est le premier Pandaren à atteindre le niveau 80 !|r")
        end
    end

    -- PREM'S Moine (classe)
    if class == CLASS_MONK then
        if GiveFirstAchievementIfNotEarned(player, ACHIEVEMENT_MONK) then
            SendWorldMessage("|cff00ff00[PREM'S] " .. playerName .. " est le premier Moine à atteindre le niveau 80 !|r")
        end
    end
end

-- -------------------------------------------------------
-- Enregistrement de l'événement Eluna
-- PLAYER_EVENT_ON_LEVEL_CHANGE = 13
-- -------------------------------------------------------
RegisterPlayerEvent(13, OnPlayerLevelUp)
