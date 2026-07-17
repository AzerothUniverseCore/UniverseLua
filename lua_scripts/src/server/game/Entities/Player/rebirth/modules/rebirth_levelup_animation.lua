--[[
    Rebirth Level-Up Animation Module

    Casts a short visual spell effect when a player gains a Rebirth level,
    removed automatically after 3 seconds. Adapted from
    paragon_levelup_animation.lua (identical behaviour, renamed events/field).

    Registered mediator events:
    - OnRebirthLevelChanged: React to level-up events

    @module rebirth_levelup_animation
    @author Paragon Team / adapted for Rebirth
]]

local Config = require("rebirth_config")

local function RemoveAura(_, _, _, player)
    local spell_id = tonumber(Config:GetByField("LEVEL_UP_ANIMATION"))
    if spell_id and player then
        player:RemoveAura(spell_id)
    end
end

local function OnRebirthLevelChanged(player, _, old_level, new_level)
    if not player or new_level <= old_level then
        return
    end

    local spell_id = tonumber(Config:GetByField("LEVEL_UP_ANIMATION"))
    if not spell_id then
        return
    end

    player:CastSpell(player, spell_id, true)
    player:RegisterEvent(RemoveAura, 3000, 1)
end

RegisterMediatorEvent("OnRebirthLevelChanged", OnRebirthLevelChanged)

-- print("[Rebirth] Rebirth Level Animation module loaded")
