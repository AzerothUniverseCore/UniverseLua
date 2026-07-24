--[[
    Rebirth Anniversary Experience Module

    Central module handling experience gains with automatic cascading
    level-ups, level-up notifications, and legacy DB sync.

    Adapted from paragon_anniversary.lua : the experience-multiplier feature
    (low/high level bonus-malus) was DROPPED on purpose for Rebirth, so the
    progression stays exactly what was asked : level N -> N+1 costs exactly
    BASE_MAX_EXPERIENCE * N creature kills (50, 100, 150 ... up to level 30),
    no hidden scaling.

    Registered mediator events:
    - OnUpdatePlayerExperience: Process experience and handle level-ups (REQUIRED)
    - OnRebirthLevelChanged: React to level-up events (notification + legacy DB sync)

    @module rebirth_anniversary
    @author iThorgrim (Paragon) / adapted for Rebirth
    @license AGL v3
]]

local Repository = require("rebirth_repository")
local RebirthHook = require("rebirth_hook")

-- Level-up notification, localized per player (see rebirth_hook.lua's
-- GetPlayerLocale / NOTICES for the frFR/enUS detection + message pattern).
local LEVEL_UP_NOTICE = {
    frFR = "|CFF00A2FFFélicitations ! Vous avez atteint le niveau de Rebirth %d !|r",
    enUS = "|CFF00A2FFCongratulations! You have reached Rebirth level %d!|r",
}

-- ============================================================================
-- LEVEL-UP PROCESSING
-- ============================================================================

---
--- Processes cascading level-ups when experience exceeds the threshold.
---
--- @param rebirth The Rebirth instance to update
--- @param gained_experience The amount of experience gained
--- @return rebirth The updated Rebirth instance
--- @return levels_gained The number of levels gained
---
local function ProcessMultipleLevelUps(rebirth, gained_experience)
    if gained_experience <= 0 then
        return rebirth, 0
    end

    local total_experience = rebirth:GetExperience() + gained_experience
    local levels_gained = 0

    -- Deja au niveau plafond (30) : on ne gaspille pas de cycles, l'XP au dela
    -- du seuil courant est simplement ignoree (plafonnee par SetExperience).
    if rebirth:IsMaxLevel() then
        rebirth:SetExperience(math.min(total_experience, rebirth:GetExperienceForNextLevel()))
        return rebirth, 0
    end

    while total_experience >= rebirth:GetExperienceForNextLevel() and not rebirth:IsMaxLevel() do
        total_experience = total_experience - rebirth:GetExperienceForNextLevel()
        rebirth:AddLevel(1)
        levels_gained = levels_gained + 1

        if rebirth:IsMaxLevel() then
            break
        end
    end

    rebirth:SetExperience(total_experience)

    return rebirth, levels_gained
end

---
--- Main process for handling experience gains with automatic level-ups.
---
--- @param player The player object receiving the experience
--- @param rebirth The Rebirth instance to update
--- @param specific_experience The amount of experience to add
--- @return rebirth The updated Rebirth instance
---
local function OnUpdatePlayerExperience(player, rebirth, specific_experience)
    if type(specific_experience) == "string" then
        specific_experience = tonumber(specific_experience)
    end

    if not rebirth or not specific_experience or specific_experience <= 0 then
        return rebirth
    end

    local levels_gained
    rebirth, levels_gained = ProcessMultipleLevelUps(rebirth, specific_experience)

    if rebirth then
        rebirth._last_levels_gained = levels_gained
        rebirth._last_exp_gained = specific_experience
    end

    return rebirth
end

-- ============================================================================
-- LEVEL-UP NOTIFICATIONS + LEGACY DB SYNC
-- ============================================================================

---
--- Handles Rebirth level changes : chat notification + mirror the new level
--- into auc_eluna.rebirth_accounts (legacy table read by Pierre_Rebirth.lua
--- and Preuve_du_Rebirth.lua, kept unmodified).
---
--- @param player The player object that leveled up
--- @param rebirth The Rebirth instance
--- @param old_level The previous level
--- @param new_level The new level
---
local function OnRebirthLevelChanged(player, rebirth, old_level, new_level)
    if not rebirth or old_level >= new_level then
        return
    end

    rebirth._last_level_change = {
        old_level = old_level,
        new_level = new_level,
        levels_gained = new_level - old_level
    }

    -- Mirror into the legacy table immediately (synchronous) so a kill that
    -- crosses a threshold unlocks the Pierre options right away, even if the
    -- player opens the gossip / uses an option in the same instant.
    Repository:SyncLegacyRebirthAccount(rebirth:GetAccountId(), new_level)

    if player then
        local locale = RebirthHook.GetPlayerLocale(player)
        local template = LEVEL_UP_NOTICE[locale] or LEVEL_UP_NOTICE.frFR
        player:SendNotification(string.format(template, new_level))
    end
end

-- ============================================================================
-- MODULE REGISTRATION
-- ============================================================================

RegisterMediatorEvent("OnUpdatePlayerExperience", OnUpdatePlayerExperience)
RegisterMediatorEvent("OnRebirthLevelChanged", OnRebirthLevelChanged)

-- print("[Rebirth] Rebirth Anniversary Experience module loaded")
