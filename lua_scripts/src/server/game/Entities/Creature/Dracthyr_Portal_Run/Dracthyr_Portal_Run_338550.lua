local NPC_ENTRY = 338550

local WAYPOINTS = {
    {x = 1689.3,  y = 1595.16, z = 3.81134},
    {x = 1694.93, y = 1596.45, z = 4.39608},
    {x = 1700.57, y = 1597.41, z = 5.09882},
    {x = 1709.86, y = 1597.4,  z = 5.96688},
    {x = 1715.35, y = 1597.33, z = 6.62043},
    {x = 1721.51, y = 1597.26, z = 7.51729},
    {x = 1726.55, y = 1597.42, z = 8.13966},
    {x = 1730.56, y = 1597.85, z = 8.40534},
    {x = 1739.07, y = 1599.79, z = 8.61011},
    {x = 1745.89, y = 1602.0,  z = 8.87294},
    {x = 1754.14, y = 1604.83, z = 8.72838},
    {x = 1767.74, y = 1609.65, z = 8.51277},
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