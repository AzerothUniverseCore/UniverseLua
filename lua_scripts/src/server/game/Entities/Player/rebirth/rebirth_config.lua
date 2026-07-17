--[[
    Rebirth Configuration Manager

    Singleton service that loads and caches general Rebirth configuration
    (level cap, experience curve, experience rewards per source) from the
    database. Adapted from paragon_config.lua : the categories/statistics
    part is entirely removed since Rebirth has no stat investment panel.

    Also caches the editable-in-database CONTENT of the 4 category rows
    (Pierre options, Pierre Preuve teleports, Heritage items, Reward items)
    -- an admin can add/remove/re-level any entry directly via SQL without
    touching Lua code (see rebirth_config_pierre_options /
    rebirth_config_proof_teleports / rebirth_config_heritage_items /
    rebirth_config_reward_items, seeded in rebirth_repository.lua).

    @class Config
    @author iThorgrim (Paragon) / adapted for Rebirth
    @license AGL v3
]]

local Repository = require("rebirth_repository")

local Config = Object:extend()
local Instance = nil

function Config:new()
    self:BuildRebirthExperience()

    local config_data = Repository:GetConfig()
    self.config = config_data or {}

    -- Editable-in-database content (Pierre / Pierre Preuve / Heritage /
    -- Recompenses) : loaded once at startup, exactly like the experience
    -- tables above. Restart the server (or re-require this module) to pick
    -- up DB edits made while it was running.
    self.pierreOptions = Repository:GetPierreOptionsConfig() or {}
    self.proofTeleports = Repository:GetProofTeleportsConfig() or {}
    self.heritageItems = Repository:GetHeritageItemsConfig() or {}
    self.rewardItems = Repository:GetRewardItemsConfig() or {}
end

function Config:GetByField(field)
    if not field or not self.config then
        return nil
    end

    return self.config[field] or nil
end

function Config:BuildRebirthExperience()
    self.experience = {
        creature = Repository:GetConfigCreatureExperience() or {},
        achievement = Repository:GetConfigAchievementExperience() or {},
        skill = Repository:GetConfigSkillExperience() or {},
        quest = Repository:GetConfigQuestExperience() or {}
    }
end

local function GetExperienceForSource(self, source_type, entry_id)
    if not source_type or not entry_id then
        return nil
    end

    local source_data = self.experience[source_type]
    if not source_data then
        return nil
    end

    return source_data[entry_id] or nil
end

function Config:GetCreatureExperience(creature_entry)
    return GetExperienceForSource(self, "creature", creature_entry)
end

function Config:GetAchievementExperience(achievement_id)
    return GetExperienceForSource(self, "achievement", achievement_id)
end

function Config:GetSkillExperience(skill_id)
    return GetExperienceForSource(self, "skill", skill_id)
end

function Config:GetQuestExperience(quest_id)
    return GetExperienceForSource(self, "quest", quest_id)
end

--- Editable-in-database content accessors (see rebirth_config_pierre_options
--- / rebirth_config_proof_teleports / rebirth_config_heritage_items /
--- rebirth_config_reward_items). rebirth_hook.lua reads these instead of
--- the static tables in rebirth_constant.lua.

function Config:GetPierreOptions()
    return self.pierreOptions or {}
end

function Config:GetProofTeleports()
    return self.proofTeleports or {}
end

function Config:GetHeritageItems()
    return self.heritageItems or {}
end

function Config:GetRewardItems()
    return self.rewardItems or {}
end

function Config:GetInstance()
    if not Instance then
        Instance = Config()
    end

    return Instance
end

return Config:GetInstance()
