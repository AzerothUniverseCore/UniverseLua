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

local UnitEntry = 8000198

local T = {	
		
		[1] = { "|TInterface\\icons\\achievement_zone_mount hyjal:35|t Hyjal (EXP Rebirth)", 2,
				{"|TInterface\\icons\\achievement_challengemode_arakkoaspires_bronze:35|t Départ Hyjal", 1, 4631.39, -3826.93, 943.539, 1.16736},
				{"|TInterface\\icons\\inv_misc_candle_03:35|t Hologramme Kobold 6-10", 1, 4525.91, -3504.31, 1001.81, 1.37847},
                {"|TInterface\\icons\\inv_crate_01:35|t Hologramme Trogg 11-15", 1, 4646.11, -2976.1, 1072.85, 2.86287},
                {"|TInterface\\icons\\inv_misc_ancientarrakoafeather:35|t Hologramme Harpie 16-20", 1, 4463.35, -2727.49, 1099.06, 1.55125},
				{"|TInterface\\icons\\spell_druid_bearhug:35|t Hologramme Furbolgs 21-25", 1, 4519.13, -2302.94, 1138.52, 0.997544},
				{"|TInterface\\icons\\inv_misc_head_centaur_01:35|t Hologramme Centaure 26-30", 1, 4688.44, -1655.1, 1284.27, 0.569501},
				{"|TInterface\\icons\\achievement_character_troll_male:35|t Hologramme Troll 31-35", 1, 5019.89, -1646.42, 1327.34, 5.0502},
				{"|TInterface\\icons\\achievement_character_gnome_male:35|t Hologramme Gnome 36-40", 1, 5135.86, -1896.6, 1363.64, 5.10769},
				{"|TInterface\\icons\\achievement_character_tauren_male:35|t Hologramme Tauren 41-45", 1, 5169.13, -2016.94, 1365.52, 3.59158},
				{"|TInterface\\icons\\achievement_character_nightelf_male:35|t Hologramme Elfe de Nuit 46-50", 1, 5115.38, -2337.03, 1410.79, 4.77752},
				{"|TInterface\\icons\\achievement_character_undead_male:35|t Hologramme Mort-Vivant 51-55", 1, 5459.44, -2307.59, 1459.73, 5.53935},
				{"|TInterface\\icons\\achievement_character_dwarf_male:35|t Hologramme Nain 56-60", 1, 5282.25, -2817.75, 1521.34, 5.14035},
				{"|TInterface\\icons\\achievement_character_orc_male:35|t Hologramme Orc 61-65", 1, 5239.79, -3038.53, 1563.46, 4.91259},
				{"|TInterface\\icons\\achievement_character_human_male:35|t Hologramme Humain 66-70", 1, 5258.63, -3593.88, 1593.53, 4.44528},
				{"|TInterface\\icons\\achievement_character_bloodelf_male:35|t Hologramme Elfe de Sang 71-75", 1, 5458.97, -3721.49, 1586.19, 6.0789},
				{"|TInterface\\icons\\achievement_character_draenei_male:35|t Hologramme Draenei 76-80", 1, 5578.35, -3616.83, 1570.6, 1.13482},
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