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

local UnitEntry = 8000196

local T = {	
		
		[1] = { "|TInterface\\icons\\achievement_zone_firelands:35|t Hyjal TDF (EXP Rebirth)", 2,
				{"|TInterface\\icons\\achievement_challengemode_arakkoaspires_bronze:35|t Départ Hyjal TDF", 1, 4677.54, -3681.55, 697.771, 1.62796},
				{"|TInterface\\icons\\achievement_alliedrace_vulpera:35|t Hologramme Vulpérin 80", 1, 4689.37, -3661.96, 696.896, 2.50541},
				{"|TInterface\\icons\\achievement_character_pandaren_female:35|t Hologramme Pandaren 80", 1, 4655.66, -3589.57, 689.016, 2.39247},
				{"|TInterface\\icons\\achievement_alliedrace_nightborne:35|t Hologramme Sacrenuit 80", 1, 4562.91, -3647.3, 674.69, 4.70217},
				{"|TInterface\\icons\\achievement_worganhead:35|t Hologramme Worgen 80", 1, 4519.64, -3720.22, 665.191, 3.25311},
				{"|TInterface\\icons\\inv_misc_skullfel_01:35|t Hologramme Elf Illidari 80", 1, 4432.1, -3655.65, 644.581, 1.81363},
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