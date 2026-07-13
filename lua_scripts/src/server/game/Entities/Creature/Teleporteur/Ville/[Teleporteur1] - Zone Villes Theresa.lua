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

local UnitEntry = 500090

local T = {
        [1] = { "|TInterface\\icons\\inv_bannerpvp_01:35|t Villes de la Horde", 1,
                {"|TInterface\\icons\\achievement_zone_durotar:35|t Orgrimmar", 1, 1517.55, -4412.03, 21.7103, 0.243466},
                {"|TInterface\\icons\\achievement_zone_tirisfalglades_01:35|t Fossoyeuse", 0, 1831, 238.5, 61.6, 0},
                {"|TInterface\\icons\\achievement_zone_mulgore_01:35|t Mulgore", 1, -1278, 122, 132, 0},
                {"|TInterface\\icons\\achievement_zone_bloodmystisle_01:35|t Lune d'Argent", 530, 9484, -7294, 15, 0},
				{"|TInterface\\icons\\achievement_zone_valeofeternalblossoms:35|t Sanctuaire des Deux-Lunes", 754, 1678.38, 931.508, 471.425, 0.143189},
        },
        [2] = { "|TInterface\\icons\\inv_bannerpvp_02:35|t Villes de l'Alliance", 0,
                {"|TInterface\\icons\\achievement_zone_elwynnforest:35|t Hurlevent", 0, -8905, 560, 94, 0.62},
                {"|TInterface\\icons\\achievement_zone_dunmorogh:35|t Dun Morogh", 0, -4795, -1117, 499, 0},
                {"|TInterface\\icons\\achievement_zone_ashenvale_01:35|t Darnassus", 1, 9952, 2280.5, 1342, 1.6},
                {"|TInterface\\icons\\achievement_zone_zangarmarsh:35|t Exodar", 530, -3863, -11736, -106, 2},
				{"|TInterface\\icons\\achievement_zone_valeofeternalblossoms:35|t Sanctuaire des Sept-Étoiles", 754, 821.866, 253.792, 503.92, 3.73811},
        },
        [3] = { "|TInterface\\icons\\achievement_bg_winwsg:35|t Zones PvP", 2,
                        {"|TInterface\\icons\\inv_misc_armorkit_14:35|t Arène de Gurubashi|PvP", 0, -13233.189453, 219.459229, 31.936506, 1.0},
						{"|TInterface\\icons\\achievement_zone_nagrand_02:35|t Arène de Nagrand|PvP", 530, -1979.782104, 6560.494629, 11.156476, 2.314995},
						{"|TInterface\\icons\\achievement_bg_killingblow_most:35|t Zone de Duel|PvP", 1, -10735.681641, 2479.739502, 6.486568, 4.562986},
        },
        [4] = { "|TInterface\\icons\\achievement_zone_nagrand_01:35|t Villes Neutre", 2,
				{"|TInterface\\icons\\ability_bossfellord_felfissure:35|t Vaisseau de la Légion", 781, -11800.76, 2974.97, 2745.97, 1.57},
				{"|TInterface\\icons\\spell_holy_pureofheart:35|t Krokuun", 781, -10985.1, 2748.45, 332.855, 4.68076},
				{"|TInterface\\icons\\spell_holy_lightsgrace:35|t Sanctum de la Lumière", 781, -11237.9, 3285.19, 163.365, 1.56564},
				{"|TInterface\\icons\\spell_arcane_teleportdalaranbrokenisles:35|t Dalaran (Légion)", 781, -11890.7, 2965.31, 1522.8, 4.77917},
				--{"|TInterface\\icons\\achievement_boss_svalasorrowgrave:35|t Séjour céleste", 771, 1127.44, 7223.68, 101.824, 3.13896},
				{"|TInterface\\icons\\spell_arcane_teleporthalloftheguardian:35|t Hall du Gardien", 800, -816.193, 4692.72, 939.663, 3.0359},
				{"|TInterface\\icons\\_HearthStoneDark_Priest:35|t Temple Halo-du-Néant", 801, 1234.33, 1344.18, 185.081, 0.00819301},
				{"|TInterface\\icons\\_HearthStoneDark_Shaman:35|t Le Maelström", 802, 1070.35, 1119.89, 19.6602, 4.07609},
				{"|TInterface\\icons\\_RuneMagmaVerte:35|t Le Marteau gangrené", 798, 1508.94, 1412.19, 243.361, 0.0534305},
                {"|TInterface\\icons\\spell_arcane_teleportdalaran:35|t Dalaran", 571, 5807.794922, 588.387268, 660.937134, 1.6},
                {"|TInterface\\icons\\spell_arcane_teleportshattrath:35|t Shattrath", 530, -1806.164307, 5323.119141, -12.428000, 2.1},
	    },		
		[5] = { "|TInterface\\icons\\spell_arcane_teleportstormwind:35|t Donjons", 2,
				{"|TInterface\\icons\\spell_arcane_teleportstormwind:35|t [1] Chemin du Rêve d'émeraude", 792, 1658.18, 1573.7, 5.84094, 2.46316},
				{"|TInterface\\icons\\spell_arcane_teleportstormwind:35|t [2] Chemin du Rêve d'émeraude", 793, 1658.18, 1573.7, 5.84094, 2.46316},
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