local ACHIEVEMENT_LEVEL_90       = 6754   -- Haut Fait "Niveau 90"
local ACHIEVEMENT_LEVEL_90_PREMS = 6755   -- "PREMIER au niveau 90 sur le royaume"
local TARGET_LEVEL                = 90

local function IsAchievementAlreadyEarned(achievementId)
    local query = CharDBQuery("SELECT achievement FROM character_achievement WHERE achievement = " .. achievementId .. " LIMIT 1")

    if query then
        return true
    end
    return false
end

local function OnPlayerLevelUp(event, player, oldLevel)
    local newLevel = player:GetLevel()

    if newLevel < TARGET_LEVEL then
        return
    end

    local playerName = player:GetName()

    if not player:HasAchieved(ACHIEVEMENT_LEVEL_90) then
        player:SetAchievement(ACHIEVEMENT_LEVEL_90)
    end

    if not player:HasAchieved(ACHIEVEMENT_LEVEL_90_PREMS) then
        if not IsAchievementAlreadyEarned(ACHIEVEMENT_LEVEL_90_PREMS) then
            player:SetAchievement(ACHIEVEMENT_LEVEL_90_PREMS)
            SendWorldMessage("|cff00ff00[PREM'S] " .. playerName .. " est le premier à atteindre le niveau 90 sur le royaume !|r")
        end
    end
end

RegisterPlayerEvent(13, OnPlayerLevelUp)
