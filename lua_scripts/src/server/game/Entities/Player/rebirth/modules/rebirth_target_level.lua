--[[
    Rebirth Target Level Module

    Handles the client's request for the Rebirth level of its current target,
    shown as a small badge near the TargetFrame. Adapted verbatim from
    paragon_target_level.lua (identical behaviour, renamed hook/addon fields).

    @module rebirth_target_level
    @author iThorgrim (Paragon) / adapted for Rebirth
]]

-- ============================================================================
-- CONSTANTS
-- ============================================================================

-- TYPEID constants (TrinityCore TypeID enum)
local TYPEID_PLAYER = 4

-- ============================================================================
-- MODULE CONFIGURATION
-- ============================================================================

-- Uses id 6 for both the request slot (Hook.Addon.Functions, client -> server)
-- and the response slot (SendServerResponse, server -> client), mirroring the
-- exact numbering paragon_target_level.lua used for the same feature. Ids 3-5
-- are intentionally left free here: response id 3 is used by rebirth_hook.lua
-- for the options-list payload (equivalent of Paragon's "all data" slot 3),
-- and Rebirth has no points/statistic slots (Paragon's 4 and 5), so they are
-- simply skipped rather than repurposed.
local RebirthHook = require("rebirth_hook")
RebirthHook.Addon.Functions[6] = "OnRebirthClientRequestTargetLevel"

RegisterClientRequests(RebirthHook.Addon, true)

-- ============================================================================
-- SERVER HOOK HANDLERS
-- ============================================================================

---
--- Handles client request to get the Rebirth level of their current target.
---
--- Validates that the target exists and is a player, then retrieves their
--- Rebirth data and sends the level back to the requesting client.
---
--- Uses target:GetTypeId() == TYPEID_PLAYER (4) instead of IsPlayer(), which
--- is not exposed in the Eluna TrinityWotlk Lua API.
---
--- @param player The player object making the request
--- @param _ Unused parameter (always nil for addon requests)
--- @return boolean True if target level was sent, false otherwise
---
function OnRebirthClientRequestTargetLevel(player, _)
    if not player then
        return false
    end

    -- Get the player's current target
    local target = player:GetSelection()
    if not target then
        -- No target selected, send level 0 to hide UI
        player:SendServerResponse(RebirthHook.Addon.Prefix, 6, 0)
        return false
    end

    -- Check if target is a player using GetTypeId()
    -- IsPlayer() is not exposed in Eluna TrinityWotlk -- use GetTypeId() == 4
    local type_id = target:GetTypeId()
    if not type_id or type_id ~= TYPEID_PLAYER then
        -- Target is not a player, send level 0 to hide UI
        player:SendServerResponse(RebirthHook.Addon.Prefix, 6, 0)
        return false
    end

    -- Cast to Player to access player-specific data
    -- ToPlayer() returns nil if the unit is not actually a player
    local target_player = target:ToPlayer()
    if not target_player then
        player:SendServerResponse(RebirthHook.Addon.Prefix, 6, 0)
        return false
    end

    -- Get target's Rebirth data (account-linked, cached by account id)
    local target_rebirth = RebirthHook.CacheGet(target_player)
    if not target_rebirth then
        -- Target has no Rebirth data (shouldn't happen but handle gracefully)
        player:SendServerResponse(RebirthHook.Addon.Prefix, 6, 0)
        return false
    end

    -- Send target's Rebirth level to the client
    local target_level = target_rebirth:GetLevel()
    player:SendServerResponse(RebirthHook.Addon.Prefix, 6, target_level or 0)

    return true
end

-- ============================================================================
-- MODULE INITIALIZATION
-- ============================================================================

-- print("[Rebirth] Rebirth Target Level module loaded")
