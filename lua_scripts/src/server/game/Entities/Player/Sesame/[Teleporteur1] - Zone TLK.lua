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

local UnitEntry = 2000015

local T = {
        [1] = { "|TInterface\\icons\\achievement_zone_northrend_01:35|t Norfendre", 2,
				{"|TInterface\\icons\\achievement_zone_boreantundra_01:35|t Toundra Boréenne", 571, 3230, 5279, 47, 3},
                {"|TInterface\\icons\\achievement_zone_crystalsong_01:35|t Forêt du Chant de cristal", 571, 5732, 1016, 175, 3.6},
                {"|TInterface\\icons\\achievement_zone_dragonblight_01:35|t Désolation des dragons", 571, 3547, 274, 46, 1.6},			
				{"|TInterface\\icons\\achievement_zone_grizzlyhills_01:35|t Les Grisonnes", 571, 3759, -2672, 177, 3},
                {"|TInterface\\icons\\achievement_zone_howlingfjord_01:35|t Fjord Hurlant", 571, 772, -2905, 7, 5},
                {"|TInterface\\icons\\achievement_zone_icecrown_07:35|t La Couronne de glace", 571, 8517, 676, 559, 4.7},
				{"|TInterface\\icons\\achievement_zone_sholazar_01:35|t Bassin de Sholazar", 571, 5571, 5739, -75, 2},
                {"|TInterface\\icons\\achievement_zone_stormpeaks_01:35|t Les pics Foudroyés", 571, 6121, -1025, 409, 4.7},
                {"|TInterface\\icons\\spell_frost_chillingblast:35|t Joug d’Hiver", 571, 5135, 2840, 408, 3},
				{"|TInterface\\icons\\achievement_zone_zuldrak_03:35|t Zul'Drak", 571, 5761, -3547, 387, 5},
                {"|TInterface\\icons\\spell_frost_frostward:35|t Dalaran", 571, 5826, 470, 659, 1.4},
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