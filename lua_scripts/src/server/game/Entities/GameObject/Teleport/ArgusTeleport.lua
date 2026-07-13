local coordinates = {781, -10985.1, 2748.45, 332.855, 4.68076}

-- Function called on each update
local function Update(event, go, diff)
    -- Get all players in range of the GameObject
    local players = go:GetPlayersInRange(0.6)

    -- Teleport each player
    for _, player in ipairs(players) do
        local map, x, y, z, o = table.unpack(coordinates)
        player:Teleport(map, x, y, z, o)
    end
end

-- Register the event for GameObject ID 1660051
RegisterGameObjectEvent(1660051, 1, Update)
