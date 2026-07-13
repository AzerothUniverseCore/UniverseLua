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

local ItemEntry = 900010

local T = {
    [1] = { "Donjons Vanilla", 2,
        {"Gouffre de Ragefeu (LvL 15)", 1, 1806.70, -4401.45, -18.33, 5.18},
		{"Les Mortemines (LvL 15)", 0, -11208.22, 1673.25, 24.64, 1.59},
		{"Donjon d’Ombrecroc (LvL 19)", 0, -233.88, 1564.45, 76.88, 1.20},
        {"Cavernes des Lamentations (LvL 20)", 1, -737.81, -2218.34, 16.81, 2.66},
		{"Profondeurs de Brassenoire (LvL 20)", 1, 4248.02, 741.78, -25.25, 1.25},
		{"La Prison (LvL 20)", 0, -8774.83, 838.35, 92.24, 0.69},
		{"Gnomeregan (LvL 24)", 0, -5163.05, 922.94, 257.17, 1.51},
		{"Salles Écarlates (LvL 26)", 0, 2874.44, -818.21, 160.33, 3.52},
		{"Monastère écarlate (LvL 28)", 0, 2909.99, -803.25, 160.33, 0.36},
        {"Kraal de Tranchebauge (LvL 30)", 1, -4472.23, -1704.22, 84.83, 1.08},
		{"Maraudon (LvL 30)", 1, -1464.89, 2614.08, 76.60, 3.06},
		{"Uldaman (LvL 36)", 0, -6084.97, -2956.21, 204.43, 0.04},
		{"Hache-Tripes (LvL 37)", 1, -3980.50, 808.86, 161.02, 4.70},
        {"Souilles de Tranchebauge (LvL 40)", 1, -4653.14, -2515.51, 81.06, 4.23},
		{"Schomolance (LvL 41)", 0, 1267.17, -2556.68, 94.12, 0.46},
		{"Stratholme (LvL 44)", 0, 3392.07, -3350.35, 142.25, 4.70},
		{"Zul’Farrak (LvL 47)", 1, -6804.83, -2891.94, 8.89, 0.150800},
		{"Profondeurs de Rochenoire (LvL 47)", 0, -7183.98, -914.96, 165.48, 5.09},
		{"Temple englouti (LvL 53)", 0, -10184.47, -3992.77, -109.19, 6.05},
		{"Bas du pic Rochenoire (LvL 56)", 0, -7527.07, -1224.54, 285.73, 5.22},
    },
	[2] = { "Donjons The Burning Crusade", 2,
        {"Flammes Infernales (LvL 60)", 530, -359.57, 3072.35, -15.08, 2.02},
        {"La Fournaise du sang (LvL 60)", 530, -298.11, 3156.08, 31.62, 2.18},
		{"Les enclos aux esclaves (LvL 62)", 530, 726.97, 7011.69, -71.76, 0.08},
		{"La Basse-tourbière (LvL 63)", 530, 781.45, 6757.16, -72.53, 4.70},
		{"Tombes-mana (LvL 64)", 530, -3083.00, 4943.88, -101.04, 0.00},
		{"Cryptes Auchenaï (LvL 65)", 530, -3361.86, 5224.06, -101.05, 1.63},
		{"Contreforts de Hautebrande (LvL 67)", 1, -8360.29, -4059.09, -208.20, 0.11},
		{"Les salles des Sethekk (LvL 68)", 530, -3362.26, 4673.03, -101.05, 4.75},
		{"Le Noir marécage (LvL 68)", 1, -8751.69, -4196.78, -209.50, 2.14},
		{"Labyrinthe des Ombres (LvL 69)", 530, -3635.94, 4942.93, -101.05, 3.16},
        {"Les salles Brisées (LvL 70)", 530, -308.89, 3071.54, -3.64, 1.76},
		{"Le caveau de la Vapeur (LvL 70)", 530, 816.62, 6933.96, -80.63, 1.58},
		{"L’Arcatraz (LvL 70)", 530, 3304.75, 1349.67, 502.29, 5.08},
		{"Le Méchanar (LvL 70)", 530, 2879.71, 1559.64, 248.89, 3.88},
		{"La Botanica (LvL 70)", 530, 3406.40, 1489.29, 182.83, 5.57},
		{"Terrasse des Magistères (LvL 70)", 530, 12887.28, -7326.78, 65.49, 4.38},
    },
	[3] = { "Donjons Wrath of the lich King", 2,
		{"Le Nexus (LvL 68)", 571, 3891.91, 6985.21, 69.48, 0.07},
		{"Donjon d’Utgarde (LvL 70)", 571, 1217.09, -4864.99, 41.25, 0.28},
		{"Ahn’kahet : l’Ancien royaume (LvL 73)", 571, 3644.37, 2039.17, 1.78, 4.31},
		{"Azjol-Nérub (LvL 74)", 571, 3685.65, 2164.00, 35.94, 2.60},
		{"Donjon de Drak’Tharon (LvL 75)", 571, 4773.81, -2034.27, 229.38, 1.54},
		{"Gundrak (LvL 77)", 571, 6952.56, -4420.38, 450, 0.79},
		{"Le fort Pourpre (LvL 77)", 571, 5704.15, 515.90, 649.78, 4.03},
		{"Les salles de Pierre (LvL 78)", 571, 8921.20, -982.43, 1039.19, 1.58},
        {"Cime d’Utgarde (LvL 79)", 571, 1252.53, -4854.94, 215.79, 3.46},
        {"L’Oculus (LvL 80)", 571, 3880.85, 6984.69, 106.32, 3.20},
		{"L’Épuration de Stratholme (LvL 80)", 1, -8754.99, -4447.41, -199.40, 4.61},
		{"Les salles de Foudre (LvL 80)", 571, 9106.93, -1320.29, 1058.40, 5.52},
		{"L’épreuve du champion (LvL 80)", 571, 8580.83, 792.13, 558.23, 3.14},
		{"La fosse de Saron (LvL 80)", 571, 5603.97, 2019.59, 798.04, 3.83},
		{"La Forge des Âmes (LvL 80)", 571, 5659.56, 2016.51, 798.04, 5.44},
		{"Salles des Reflets (LvL 80)", 571, 5631.17, 2002.24, 798.05, 4.61},
    },
	[4] = { "Donjons Cataclysm", 2,
        {"[S0] Les Terres de Fyra (LvL 80)", 792, 1749.49, 1602.87, 8.83, 0.40},
		{"[S5] La cime du Vortex (LvL 80)", 793, 1572.81, 1557.98, 16.02, 3.59},
		{"[S7] Puits d’éternité (LvL 80)", 793, 1750.71, 1602.87, 8.85, 0.47},
    },
	[5] = { "Donjons Mist of Pandaria", 2,
		{"[S2] Palais Mogu’shan (LvL 80)", 792, 1565.55, 1553.94, 17.79, 3.54},
        {"[S2] Temple du Serpent de jade (LvL 80)", 792, 1758.69, 1513.01, 6.14, 5.91},
		{"[S3] Caveaux Mogu’shan (LvL 80)", 792, 1616.98, 1677.39, 7.82, 2.12},
        {"[S6] Siège du temple de Niuzao (LvL 80)", 793, 1593.95, 1488.00, 11.70, 3.86},
        {"[A] Brasserie Brune d’Orage (LvL 80)", 793, 1520.78, 1644.59, 28.05, 2.80},
        {"[A] Monastère des Pandashan (LvL 80)", 792, 1520.78, 1644.59, 28.05, 2.80},
    },
	[6] = { "Donjons Warlords of Draenor", 2,
        {"[S3] Cognefort (LvL 80)", 792, 1593.95, 1488.00, 11.70, 3.86},
		{"[S6] Orée-du-Ciel (LvL 80)", 793, 1758.69, 1513.01, 6.14, 5.91},
    },
	[7] = { "Donjons Légion", 2,
        {"[A] Vaisseau de la Légion (LvL 80)", 793, 1616.98, 1677.39, 7.82, 2.12},
    },
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