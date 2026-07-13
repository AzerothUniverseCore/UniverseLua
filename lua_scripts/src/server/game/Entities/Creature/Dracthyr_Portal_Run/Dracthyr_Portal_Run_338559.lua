local NPC_ENTRY = 338559

local WAYPOINTS = {
    {x = 1590,7,  y = 1608,04, z = 12,9443},
    {x = 1581,81,  y = 1617,55, z = 15,214},
    {x = 1568,03,  y = 1623,14, z = 18,4477},
    {x = 1544,87,  y = 1621,84, z = 23,0763},
    {x = 1524,75,  y = 1622,06, z = 26,7124},
    {x = 1517,02,  y = 1644,7, z = 28,537},
    {x = 1497,89,  y = 1653,27, z = 30,8252},
}

local CHECK_DIST = 2.0
local MOVE_SPEED = 2.5

local function DistTo(creature, wp)
    local cx, cy = creature:GetX(), creature:GetY()
    local dx, dy = cx - wp.x, cy - wp.y
    return math.sqrt(dx*dx + dy*dy)
end

local function MoveToWaypoint(creature, index)
    if not creature or not creature:IsInWorld() then return end

    local wp = WAYPOINTS[index]
    --print(string.format("[DR] Vers point #%d => (%.2f, %.2f, %.2f)", index, wp.x, wp.y, wp.z))

    -- Tentative : MoveTo(id, x, y, z, speed)
    creature:MoveTo(index, wp.x, wp.y, wp.z, MOVE_SPEED)

    creature:RegisterEvent(function(eventId, delay, repeats, c)
        if not c or not c:IsInWorld() then return end

        local dist = DistTo(c, wp)
        --print(string.format("[DR] Polling #%d => dist=%.2f pos=(%.2f, %.2f, %.2f)", index, dist, c:GetX(), c:GetY(), c:GetZ()))

        if dist <= CHECK_DIST then
            c:RemoveEventById(eventId)
            --print("[DR] Point #" .. index .. " atteint")

            if index >= #WAYPOINTS then
                --print("[DR] Dernier point => despawn")
                c:RegisterEvent(function(eid, _, _, cc)
                    if cc and cc:IsInWorld() then
                        cc:DespawnOrUnsummon(0)
                    end
                    cc:RemoveEventById(eid)
                end, 500, 1)
            else
                MoveToWaypoint(c, index + 1)
            end
        end
    end, 500, 0)
end

local function OnSpawn(event, creature)
    --print("[DR] OnSpawn => entry=" .. tostring(creature:GetEntry()) .. " GUID=" .. tostring(creature:GetGUIDLow()))
    creature:RegisterEvent(function(eid, _, _, c)
        c:RemoveEventById(eid)
        c:SetWalk(true)
        MoveToWaypoint(c, 1)
    end, 1000, 1)
end

RegisterCreatureEvent(NPC_ENTRY, 5, OnSpawn)
--print("[DR] Script chargé, NPC_ENTRY=" .. NPC_ENTRY)