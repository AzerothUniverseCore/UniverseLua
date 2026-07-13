--[==[
    = How to add new locations =

    Example:

    The first line will be the main menu ID (Here [1], 
    increment this for each main menu option!),
    the main menu gossip title (Here "Horde Cities"),
    as well as which faction can use the said menu (Here 1 (Horde)). 
    0 = Alliance, 1 = Horde, 2 = Both

    The second line is the name of the main menu's sub menus, 
    separated by name (Here "Orgrimmar") and teleport coordinates
    using Map, X, Y, Z, O (Here 1, 1503, -4415.5, 22, 0)

    [1] = { "Horde Cities", 1,	--  This will be the main menu title, as well as which faction can use the said menu. 0 = Alliance, 1 = Horde, 2 = Both
        {"Orgrimmar", 1, 1503, -4415.5, 22, 0},
    },

    You can copy paste the above into the script and change the values as informed.
]==]

local UnitEntry = 9000130

local T = {	
		
		[1] = { "|TInterface\\icons\\inv_flymaldraxxusmount_black:35|t Nerozias", 0,
				{"|TInterface\\icons\\Achievement_BG_returnXflags_def_WSG.png:35|t Se téléporter", 726, -15733.9, -13426.6, 94.0575, 4.94998},
				},
		[2] = { "|TInterface\\icons\\inv_flymaldraxxusmount_black:35|t Nerozias", 1,
				{"|TInterface\\icons\\Achievement_BG_returnXflags_def_WSG.png:35|t Se téléporter", 726, -15705.7, -14232.7, 78.4658, 4.74821},
				},
		[3] = { "|TInterface\\icons\\achievement_zone_mount hyjal:35|t Mont Hyjal 1-80", 2,
				{"|TInterface\\icons\\Achievement_BG_returnXflags_def_WSG.png:35|t Se téléporter", 1, 4619.39, -3847.96, 943.94, 1.12},
				},
		[4] = { "|TInterface\\icons\\achievement_zone_firelands:35|t Hyjal TDF 80", 2,
				{"|TInterface\\icons\\Achievement_BG_returnXflags_def_WSG.png:35|t Se téléporter", 1, 4677.54, -3681.55, 697.771, 1.62796},
				},
}

-- CODE STUFFS! DO NOT EDIT BELOW
-- UNLESS YOU KNOW WHAT YOU'RE DOING!

local function OnGossipHello(event, player, unit)
    -- Show main menu
    for i, v in ipairs(T) do
        if (v[2] == 2 or v[2] == player:GetTeam()) then
            player:GossipMenuAddItem(0, v[1], i, 0)
        end
    end
    player:GossipSendMenu(1, unit)
end	

local function OnGossipSelect(event, player, unit, sender, intid, code)
    if (sender == 0) then
        -- return to main menu
        OnGossipHello(event, player, unit)
        return
    end

    if (intid == 0) then
        -- Show teleport menu
        for i, v in ipairs(T[sender]) do
            if (i > 2) then
                player:GossipMenuAddItem(0, v[1], sender, i)
            end
        end
        player:GossipMenuAddItem(0, "Retour", 0, 0)
        player:GossipSendMenu(1, unit)
        return
    else
        -- teleport
        local name, map, x, y, z, o = table.unpack(T[sender][intid])
        player:Teleport(map, x, y, z, o)
    end
    
    player:GossipComplete()
end

RegisterCreatureGossipEvent(UnitEntry, 1, OnGossipHello)
RegisterCreatureGossipEvent(UnitEntry, 2, OnGossipSelect)