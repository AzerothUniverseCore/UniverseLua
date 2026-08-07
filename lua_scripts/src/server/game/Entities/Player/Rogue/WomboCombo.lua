local PLAYER_EVENT_ON_DEAL_DAMAGE   = 57
local PLAYER_EVENT_ON_TARGET_CHANGE = 58
local PLAYER_EVENT_ON_LOGOUT        = 4

local LAST_COMBO = {}

local function IsComboClass(player)
    local class = player:GetClass()
    return class == 4 or class == 11
end

local function OnDealDamage(event, player, victim, damage)
    if not IsComboClass(player) then return end
    if not victim then return end

    local points = player:GetComboPoints()
    if points > 0 then
        LAST_COMBO[player:GetGUIDLow()] = { points = points, targetGuid = victim:GetGUID() }
    end
end

local function OnTargetChange(event, player, newTarget)
    if not IsComboClass(player) then return end
    if not newTarget or not newTarget:IsAlive() then return end

    local pGuid   = player:GetGUIDLow()
    local newGuid = newTarget:GetGUID()

    local points = player:GetComboPoints()
    if points > 0 then
        local comboTarget = player:GetComboTarget()
        if comboTarget and comboTarget:GetGUID() == newGuid then
            LAST_COMBO[pGuid] = nil
            return
        end
        player:AddComboPoints(newTarget, points)
        LAST_COMBO[pGuid] = nil
        return
    end

    local last = LAST_COMBO[pGuid]
    if last and last.points > 0 and last.targetGuid ~= newGuid then
        player:AddComboPoints(newTarget, last.points)
    end
    LAST_COMBO[pGuid] = nil
end

RegisterPlayerEvent(PLAYER_EVENT_ON_DEAL_DAMAGE, OnDealDamage)
RegisterPlayerEvent(PLAYER_EVENT_ON_TARGET_CHANGE, OnTargetChange)
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGOUT, function(event, player)
    LAST_COMBO[player:GetGUIDLow()] = nil
end)
