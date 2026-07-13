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

local ItemEntry = 900011

local T = {
    [1] = { "Raids Vanilla", 2,
        {"Coeur du Magma (LvL 60)", 409, 1087.262085, -477.891083, -107.300995, 3.90},
        {"Ahn'Qiraj (LvL 60)", 1, -8240.01, 1991.52, 129.07, 0.90},
        {"Ruines d'Ahn'Qiraj (LvL 60)", 1, -8412.33, 1501.23, 29.21, 2.67},
        {"Repaire de l'Aile noire (LvL 60)", 0, -7652.93, -1223.13, 287.59, 2.77},
    },
	[2] = { "Raids The Burning Crusade", 2,
        {"Karazhan (LvL 70)", 0, -11121.54, -2012.26, 47.11, 0.65},
        {"Repaire de Gruul (LvL 70)", 530, 3529.89, 5112.59, 4.07, 5.28},
        {"Le repaire de Magtheridon (LvL 70)", 530, -314.62, 3090.60, -116.47, 5.18},
        {"Sanctuaire du Serpent (LvL 70)", 530, 796.69, 6865.96, -65.14, 0.08},
		{"Donjon de la Tempête (LvL 70)", 530, 3087.99, 1383.28, 184.82, 4.70},
		{"Sommet d’Hyjal (LvL 70)", 1, -8177.14, -4177.98, -166.72, 0.99},
		{"Temple noir (LvL 70)", 530, -3636.75, 318.07, 35.77, 3.16},
		{"Plateau du Puits de soleil (LvL 70)", 530, 12566.84, -6774.57, 15.09, 3.11},
    },
	[3] = { "Raids Wrath of the lich King", 2,
        {"Caveau d’Archavon (LvL 80)", 571, 5466.49, 2840.01, 418.67, 6.27},
        {"Naxxramas (LvL 80)", 571, 3668.58, -1276.83, 243.51, 5.71},
        {"Le sanctum Obsidien (LvL 80)", 571, 3457.03, 262.89, -113.81, 3.25},
        {"L’Œil de l’éternité (LvL 80)", 571, 3857.45, 6990.91, 152.11, 5.82},
		{"Ulduar (LvL 80)", 571, 9330.42, -1114.12, 1245.15, 6.25},
		{"L’épreuve du croisé (LvL 80)", 571, 8515.20, 726.12, 558.24, 1.59},
		{"Repaire d’Onyxia (LvL 80)", 1, -4687.18, -3714.30, 47.61, 3.68},
		{"La Couronne de glace (LvL 80)", 571, 5801.15, 2076.51, 636.06, 3.56},
		{"Le sanctum Rubis (LvL 80)", 571, 3599.23, 198.38, -113.78, 5.32},
    },
	[4] = { "Raids Cataclysm", 2,
		{"[S1] Terres de Feu (LvL 80)", 792, 1698.73, 1653.70, 8.94, 1.26},
    },
	[5] = { "Raids Mist of Pandaria", 2,
        {"[S4] Cœur de la peur (LvL 80)", 793, 1699.17, 1650.36, 8.63, 1.27},
        {"[S5] Terrasse Printanière (LvL 80)", 793, 1642.85, 1475.66, 10.91, 4.47},
    },
	[6] = { "Raids Warlords of Draenor", 2,
        {"[S4] Quais de Fer (LvL 80)", 792, 1692.43, 1267.45, 2.11, 4.90},
    },
	[7] = { "Raids Légion", 2,
        {"[S3] Antorus, le Trône ardent (LvL 80)", 792, 1642.85, 1475.66, 10.91, 4.47},
		{"[S7] Salles des Valeureux (LvL 80)", 793, 1692.43, 1267.45, 2.11, 4.90},
		{"[S8] Palais Sacrenuit (LvL 80)", 793, 1664.33, 1301.47, 2.20, 3.34},
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