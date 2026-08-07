local BLOCKED_SPELL_ID  = 42201
local BLOCKED_MAP_ID    = 807
local BLOCKED_AREA_ID   = 50707
local CHECK_INTERVAL_MS = 500

local PLAYER_EVENT_ON_LOGIN = 3

local function CheckAndBlock(eventId, delay, repeats, player)
    if not player or not player:IsInWorld() then return end

    if player:GetMapId() == BLOCKED_MAP_ID and player:GetAreaId() == BLOCKED_AREA_ID then
        if player:HasAura(BLOCKED_SPELL_ID) then
            player:RemoveAura(BLOCKED_SPELL_ID)
        end
    end
end

RegisterPlayerEvent(PLAYER_EVENT_ON_LOGIN, function(event, player)
    player:RegisterEvent(CheckAndBlock, CHECK_INTERVAL_MS, 0)
end)
