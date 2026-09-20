local GAMEOBJECT_ENTRY = 1268729
local TELEPORT_DELAY   = 6000
local DOOR_OPEN_TIME   = 6
local PROXIMITY_RANGE  = 0.9

local TELEPORT_MAP = 833
local TELEPORT_X   = -654.685
local TELEPORT_Y   = 1756.82
local TELEPORT_Z   = 5.3588
local TELEPORT_O   = 3.23284

local function onTeleportDelay(eventId, delay, repeats, player)
    if player and player:IsInWorld() then
        player:Teleport(TELEPORT_MAP, TELEPORT_X, TELEPORT_Y, TELEPORT_Z, TELEPORT_O)
    end
end

local function onGameObjectUse(event, go, player)
    go:UseDoorOrButton(DOOR_OPEN_TIME)

    player:RegisterEvent(onTeleportDelay, TELEPORT_DELAY, 1)

    return true
end

local function onUpdate(event, go, diff)
    local players = go:GetPlayersInRange(PROXIMITY_RANGE)

    for _, player in ipairs(players) do
        player:Teleport(TELEPORT_MAP, TELEPORT_X, TELEPORT_Y, TELEPORT_Z, TELEPORT_O)
    end
end

RegisterGameObjectEvent(GAMEOBJECT_ENTRY, 14, onGameObjectUse)
RegisterGameObjectEvent(GAMEOBJECT_ENTRY, 1, onUpdate)
