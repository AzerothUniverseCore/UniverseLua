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
    [1] = { "Horde Cities", 1,    --  This will be the main menu title, as well as which faction can use the said menu. 0 = Alliance, 1 = Horde, 2 = Both
        {"Orgrimmar", 1, 1503, -4415.5, 22, 0},
    },
    You can copy paste the above into the script and change the values as informed.
]==]

local ItemEntry = 90007

local T = {
    [1] = { "Villes de la Horde", 1,
        {"Orgrimmar", 1, 1517.55, -4412.03, 21.7103, 0.243466},
		{"Marteau du Destin", 826, 12416.3, 14708.5, 1.67375, 5.21026},
        {"Fossoyeuse", 0, 1831, 238.5, 61.6, 0},
        {"Pitons du Tonnerre", 1, -1278, 122, 132, 0},
        {"Lune d'Argent", 530, 9484, -7294, 15, 0},
		{"Sanctuaire des Deux-Lunes", 754, 1678.38, 931.508, 471.425, 0.143189},
		{"Nerozias", 726, -15810.128906, -14193.071289, 77.352615, 0.805357},
    },
    [2] = { "Villes de l'Alliance", 0,
        {"Hurlevent", 0, -8905, 560, 94, 0.62},
		{"Comté de l'espoir", 810, 15645.4, 15241.5, 26.565, 3.04774},
        {"Forgefer", 0, -4795, -1117, 499, 0},
        {"Darnassus", 1, 9952, 2280.5, 1342, 1.6},
        {"Exodar", 530, -3863, -11736, -106, 2},
		{"Sanctuaire des Sept-Étoiles", 754, 821.866, 253.792, 503.92, 3.73811},
		{"Nerozias", 726, -15798.256836, -13451.877930, 88.816940, 3.332687},
    },
    [3] = { "Zones Outreterre", 2,
        {"Les Tranchantes", 530, 1481, 6829, 107, 6},
        {"Péninsule des Flammes infernales", 530, -249, 947, 85, 2},
        {"Nagrand", 530, -1769, 7150, -9, 2},
        {"Raz de Néant", 530, 3043, 3645, 143, 2},
        {"Vallée d’Ombrelune", 530, -3034, 2937, 87, 5},
        {"Forêt de Terokkar", 530, -1942, 4689, -2, 5},
        {"Marécage de Zangar", 530, -217, 5488, 23, 2},
        {"Shattrath", 530, -1822, 5417, 1, 3},
    },
    [4] = { "Zones Norfendre", 2,
        {"Toundra Boréenne", 571, 3230, 5279, 47, 3},
        {"Forêt du Chant de cristal", 571, 5732, 1016, 175, 3.6},
        {"Désolation des dragons", 571, 3547, 274, 46, 1.6},
        {"Les Grisonnes", 571, 3759, -2672, 177, 3},
        {"Fjord Hurlant", 571, 772, -2905, 7, 5},
        {"La Couronne de glace", 571, 8517, 676, 559, 4.7},
        {"Bassin de Sholazar", 571, 5571, 5739, -75, 2},
        {"Les pics Foudroyés", 571, 6121, -1025, 409, 4.7},
        {"Joug d’Hiver", 571, 5135, 2840, 408, 3},
        {"Zul'Drak", 571, 5761, -3547, 387, 5},
        {"Dalaran", 571, 5826, 470, 659, 1.4},
    },
    [5] = { "Zones PvP", 2,
        {"Arène des Gurubashi", 0, -13229, 226, 33, 1},
        {"Hache tripes", 1, -3669, 1094, 160, 3},
        {"Arène de Nagrand", 530, -1983, 6562, 12, 2},
        {"Arène des Tranchantes", 530, 2910, 5976, 2, 4},
    },
	[6] = { "Azeroth Universe", 2,
		{"(Aventure) Les Ports Oubliés", 807, 11742.5, 11860.6, -0.169944, 4.85993},
        {"(Aventure) Nétheril Camp 1", 725, -14749.907227, -13192.527344, 34.431049, 1.896851},
		{"(Aventure) Nétheril Camp 2", 725, -14763.747070, -13609.506836, 27.086132, 4.800987},
		{"(Aventure) Vaisseau de la Légion", 781, -11800.76, 2974.97, 2745.97, 1.57},
		{"(Capitale) Dalaran (Légion)", 781, -11908.80, 2961.10, 1857.40, 5.04},
		{"(Capitale) Oakvale", 811, -10710.6, -11590.6, -100.793, 0.208627},
		--{"(Divers) Séjour céleste", 771, 1127.44, 7223.68, 101.824, 3.13896},
		{"(Métiers) Sanctum de la Lumière", 781, -11237.9, 3285.19, 163.365, 1.56564},
		{"(Entraîneur) Hall du Gardien", 800, -816.193, 4692.72, 939.663, 3.0359},
		{"(Cosmétique) Le Vindicaar", 781, -10985.1, 2748.45, 332.855, 4.68076},
		{"(Cosmétique) Temple Halo du Néant", 801, 1234.33, 1344.18, 185.081, 0.00819301},
		{"(Bot) Le Marteau gangrené", 798, 1508.94, 1412.19, 243.361, 0.0534305},
		{"(Event) Le Maelström", 802, 1070.35, 1119.89, 19.6602, 4.07609},
	},
	[7] = { "Donjons/Raids", 2,
		{"[1] Chemin du Rêve d’émeraude", 792, 1658.18, 1573.7, 5.84094, 2.46316},
		{"[2] Chemin du Rêve d’émeraude", 793, 1658.18, 1573.7, 5.84094, 2.46316},
		{"[3] Chemin du Rêve d’émeraude", 822, 1658.18, 1573.7, 5.84094, 2.46316},
	},
	--[8] = { "Évènement", 2,
        --{"Alezan", 740, 15488.6, 15922.8, 1.04991, 6.28168},
		--{"Les Salines", 1, -6190.786133, -3889.768555, -60.031086, 1.549685},
	--},
}

-- CODE STUFFS! DO NOT EDIT BELOW
-- UNLESS YOU KNOW WHAT YOU'RE DOING!

local function OnGossipHello(event, player, item)
    -- Vérifie si le joueur est en BG ou en arène
    if player:GetMap():IsBattleground() or player:GetMap():IsArena() then
        player:SendBroadcastMessage("Vous ne pouvez pas accéder au menu de téléportation depuis un champ de bataille ou une arène.")
        player:GossipComplete()
        return
    end

    -- Show main menu
    for i, v in ipairs(T) do
        if (v[2] == 2 or v[2] == player:GetTeam()) then
            player:GossipMenuAddItem(0, v[1], i, 0)
        end
    end
    player:GossipSendMenu(1, item)
end 

local function OnGossipSelect(event, player, item, sender, intid, code)
    if (sender == 0) then
        -- retour au menu principal
        OnGossipHello(event, player, item)
        return
    end

    if (intid == 0) then
        -- afficher le menu de téléportation
        for i, v in ipairs(T[sender]) do
            if (i > 2) then
                player:GossipMenuAddItem(0, v[1], sender, i)
            end
        end
        player:GossipMenuAddItem(0, "Retour", 0, 0)
        player:GossipSendMenu(1, item)
        return
    else
        -- empêcher la téléportation si le joueur est en BG ou en arène
        if player:GetMap():IsBattleground() or player:GetMap():IsArena() then
            player:SendBroadcastMessage("Vous ne pouvez pas vous téléporter depuis un champ de bataille ou une arène.")
            player:GossipComplete()
            return
        end

        -- téléporter le joueur
        local name, map, x, y, z, o = table.unpack(T[sender][intid])
        player:Teleport(map, x, y, z, o)
    end
    
    player:GossipComplete()
end

RegisterItemGossipEvent(ItemEntry, 1, OnGossipHello)
RegisterItemGossipEvent(ItemEntry, 2, OnGossipSelect)