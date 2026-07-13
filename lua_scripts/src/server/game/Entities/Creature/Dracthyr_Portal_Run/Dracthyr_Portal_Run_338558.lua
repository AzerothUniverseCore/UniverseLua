local NPC_ENTRY = 338558

local WAYPOINTS = {
    {x = 1622,07,   y = 1630,01, z = 7,82284},
    {x = 1621,01,   y = 1646,47, z = 8,19621},
    {x = 1620,59,   y = 1660,42, z = 7,86518},
    {x = 1616,58,   y = 1675,13, z = 7,90205},
    {x = 1611,1,    y = 1689,67, z = 8,00385},
    {x = 1600,52,   y = 1702,91, z = 8,17347},
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