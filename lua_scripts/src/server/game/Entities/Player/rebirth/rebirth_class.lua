--[[
    Rebirth Class

    Represents a Rebirth progression (level 1-30, XP curve 50/100/150...
    /1450 kills). Adapted from paragon_class.lua : has NO statistics/points
    system at all -- Rebirth levels simply unlock the Pierre de Rebirth
    options (handled by rebirth_hook.lua), nothing to invest.

    LINK MODE -- like Paragon, Rebirth progression can be linked either to
    the ACCOUNT (every character on the account shares the same level/XP,
    stored in account_rebirth) or to the CHARACTER (each character has its
    own independent level/XP, stored in character_rebirth), controlled by
    the LEVEL_LINKED_TO_ACCOUNT config field ('1' = account, '0' =
    character). Default is account-linked, matching the legacy
    auc_eluna.rebirth_accounts table this system replaces.

    Mediator Events:
    - OnRebirthLevelChanged: (player, rebirth, old_level, new_level)
    - OnRebirthExperienceChanged: (rebirth, old_exp, new_exp)

    @class Rebirth
    @author iThorgrim (Paragon) / adapted for Rebirth
    @license AGL v3
]]

local Repository = require("rebirth_repository")
local Config = require("rebirth_config")

local Rebirth = Object:extend()

local function CalculateMaxExperienceForLevel(level)
    level = level or tonumber(Config:GetByField("REBIRTH_STARTING_LEVEL")) or 1
    local base_max_exp = tonumber(Config:GetByField("BASE_MAX_EXPERIENCE")) or 50
    return base_max_exp * level
end

-- ============================================================================
-- CONSTRUCTOR
-- ============================================================================

function Rebirth:new(guid, account_id)
    self.guid = guid
    self.account = account_id

    self.level = tonumber(Config:GetByField("REBIRTH_STARTING_LEVEL")) or 1
    self.exp = {
        current = tonumber(Config:GetByField("REBIRTH_STARTING_EXPERIENCE")) or 0,
        max = CalculateMaxExperienceForLevel(self.level)
    }
end

-- ============================================================================
-- DATABASE OPERATIONS
-- ============================================================================

function Rebirth:Load(callback)
    local function ApplyData(data)
        if data and data.level then
            self.level = data.level
            self.exp.current = data.current_experience or 0
            self.exp.max = CalculateMaxExperienceForLevel(self.level)
        end

        if callback then
            callback(self.account, self)
        end
    end

    if Config:GetByField("LEVEL_LINKED_TO_ACCOUNT") == "1" then
        Repository:GetRebirthByAccountId(self.account, ApplyData)
    else
        Repository:GetRebirthByCharacter(self.guid, ApplyData)
    end
end

function Rebirth:Save()
    if Config:GetByField("LEVEL_LINKED_TO_ACCOUNT") == "1" then
        Repository:SaveRebirthByAccount(self.account, self.level, self.exp.current)
    else
        Repository:SaveRebirthByCharacter(self.guid, self.level, self.exp.current)
    end
end

---
--- Saves synchronously (blocking). Used at logout, exactly like Paragon's
--- SaveSync : CharDBExecute is async and can be dropped mid-logout, whereas
--- CharDBQuery (used internally by SaveRebirthByAccountSync) blocks until
--- the write is actually committed.
---
function Rebirth:SaveSync()
    if Config:GetByField("LEVEL_LINKED_TO_ACCOUNT") == "1" then
        Repository:SaveRebirthByAccountSync(self.account, self.level, self.exp.current)
    else
        Repository:SaveRebirthByCharacterSync(self.guid, self.level, self.exp.current)
    end
end

-- ============================================================================
-- LEVEL ACCESSORS
-- ============================================================================

function Rebirth:GetLevel()
    return self.level
end

function Rebirth:SetLevel(level)
    if not level or level < 1 then
        return self
    end

    local level_cap = tonumber(Config:GetByField("REBIRTH_LEVEL_CAP")) or 30
    if level_cap > 0 and level > level_cap then
        level = level_cap
    end

    local previous_level = self.level
    if previous_level ~= level then
        self.level = level
        self.exp.max = CalculateMaxExperienceForLevel(level)

        if Mediator then
            local player_obj = self._player
            Mediator.On("OnRebirthLevelChanged", {
                arguments = { player_obj, self, previous_level, level }
            })
        end
    end

    return self
end

function Rebirth:AddLevel(levels)
    levels = levels or 1
    if levels <= 0 then
        return self
    end

    return self:SetLevel(self.level + levels)
end

function Rebirth:IsMaxLevel()
    local level_cap = tonumber(Config:GetByField("REBIRTH_LEVEL_CAP")) or 30
    return level_cap > 0 and self.level >= level_cap
end

-- ============================================================================
-- EXPERIENCE ACCESSORS
-- ============================================================================

function Rebirth:GetExperience()
    return self.exp.current
end

function Rebirth:SetExperience(experience)
    if not experience or experience < 0 then
        experience = 0
    end

    experience = math.min(experience, self.exp.max)

    local previous_exp = self.exp.current
    if previous_exp ~= experience then
        self.exp.current = experience

        if Mediator then
            Mediator.On("OnRebirthExperienceChanged", {
                arguments = { self, previous_exp, experience }
            })
        end
    end

    return self
end

function Rebirth:AddExperience(amount)
    if not amount or amount <= 0 then
        return self
    end

    local new_exp = self.exp.current + amount
    return self:SetExperience(new_exp)
end

function Rebirth:GetExperienceForNextLevel()
    return self.exp.max
end

function Rebirth:GetExperienceProgress()
    if self.exp.max == 0 then
        return 0
    end

    return (self.exp.current / self.exp.max) * 100
end

-- ============================================================================
-- UTILITY
-- ============================================================================

function Rebirth:GetAccountId()
    return self.account
end

function Rebirth:GetGUID()
    return self.guid
end

function Rebirth:GetState()
    return {
        account = self.account,
        guid = self.guid,
        level = self.level,
        experience = self.exp.current,
        experience_max = self.exp.max
    }
end

return Rebirth
