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

local UnitEntry = 2000014

local T = {
        [1] = { "|TInterface\\icons\\inv_bannerpvp_01:35|t Villes de la Horde", 1, nameEn = "|TInterface\\icons\\inv_bannerpvp_01:35|t Horde Cities",
                {"|TInterface\\icons\\achievement_zone_durotar:35|t Orgrimmar", 1, 1517.55, -4412.03, 21.7103, 0.243466, nameEn = "|TInterface\\icons\\achievement_zone_durotar:35|t Orgrimmar"},
                {"|TInterface\\icons\\achievement_zone_tirisfalglades_01:35|t Fossoyeuse", 0, 1831, 238.5, 61.6, 0, nameEn = "|TInterface\\icons\\achievement_zone_tirisfalglades_01:35|t Undercity"},
                {"|TInterface\\icons\\achievement_zone_mulgore_01:35|t Mulgore", 1, -1278, 122, 132, 0, nameEn = "|TInterface\\icons\\achievement_zone_mulgore_01:35|t Mulgore"},
                {"|TInterface\\icons\\achievement_zone_bloodmystisle_01:35|t Lune d'Argent", 530, 9484, -7294, 15, 0, nameEn = "|TInterface\\icons\\achievement_zone_bloodmystisle_01:35|t Silvermoon"},
				{"|TInterface\\icons\\achievement_zone_valeofeternalblossoms:35|t Sanctuaire des Deux-Lunes", 754, 1678.38, 931.508, 471.425, 0.143189, nameEn = "|TInterface\\icons\\achievement_zone_valeofeternalblossoms:35|t Shrine of Two Moons"},
        },
        [2] = { "|TInterface\\icons\\inv_bannerpvp_02:35|t Villes de l'Alliance", 0, nameEn = "|TInterface\\icons\\inv_bannerpvp_02:35|t Alliance Cities",
                {"|TInterface\\icons\\achievement_zone_elwynnforest:35|t Hurlevent", 0, -8905, 560, 94, 0.62, nameEn = "|TInterface\\icons\\achievement_zone_elwynnforest:35|t Stormwind"},
                {"|TInterface\\icons\\achievement_zone_dunmorogh:35|t Dun Morogh", 0, -4795, -1117, 499, 0, nameEn = "|TInterface\\icons\\achievement_zone_dunmorogh:35|t Dun Morogh"},
                {"|TInterface\\icons\\achievement_zone_ashenvale_01:35|t Darnassus", 1, 9952, 2280.5, 1342, 1.6, nameEn = "|TInterface\\icons\\achievement_zone_ashenvale_01:35|t Darnassus"},
                {"|TInterface\\icons\\achievement_zone_zangarmarsh:35|t Exodar", 530, -3863, -11736, -106, 2, nameEn = "|TInterface\\icons\\achievement_zone_zangarmarsh:35|t Exodar"},
				{"|TInterface\\icons\\achievement_zone_valeofeternalblossoms:35|t Sanctuaire des Sept-Étoiles", 754, 821.866, 253.792, 503.92, 3.73811, nameEn = "|TInterface\\icons\\achievement_zone_valeofeternalblossoms:35|t Shrine of Seven Stars"},
        },
		[3] = { "|TInterface\\icons\\DP:35|t Azeroth Universe", 2, nameEn = "|TInterface\\icons\\DP:35|t Azeroth Universe",
                {"|TInterface\\icons\\ability_bossfellord_felfissure:35|t |cffffff00(Aventure)|r Vaisseau de la Légion", 781, -11800.76, 2974.97, 2745.97, 1.57, nameEn = "|TInterface\\icons\\ability_bossfellord_felfissure:35|t |cffffff00(Adventure)|r Legion Ship"},
				{"|TInterface\\icons\\spell_holy_pureofheart:35|t |cffffffff(Cosmétique)|r Le Vindicaar", 781, -10985.1, 2748.45, 332.855, 4.68076, nameEn = "|TInterface\\icons\\spell_holy_pureofheart:35|t |cffffffff(Cosmetic)|r The Vindicaar"},
				{"|TInterface\\icons\\spell_holy_lightsgrace:35|t |cff008000(Métiers)|r Sanctum de la Lumière", 781, -11237.9, 3285.19, 163.365, 1.56564, nameEn = "|TInterface\\icons\\spell_holy_lightsgrace:35|t |cff008000(Professions)|r Sanctum of Light"},
				{"|TInterface\\icons\\spell_arcane_teleportdalaranbrokenisles:35|t |cff008000(Zone)|r Dalaran (Légion)", 781, -11908.80, 2961.10, 1857.40, 5.04, nameEn = "|TInterface\\icons\\spell_arcane_teleportdalaranbrokenisles:35|t |cff008000(Zone)|r Dalaran (Legion)"},
				--{"|TInterface\\icons\\achievement_boss_svalasorrowgrave:35|t |cff008000(Divers)|r Séjour céleste", 771, 1127.44, 7223.68, 101.824, 3.13896},
				{"|TInterface\\icons\\spell_arcane_teleporthalloftheguardian:35|t |cff008000(Entraîneur)|r Hall du Gardien", 800, -816.193, 4692.72, 939.663, 3.0359, nameEn = "|TInterface\\icons\\spell_arcane_teleporthalloftheguardian:35|t |cff008000(Trainer)|r Hall of the Guardian"},
				{"|TInterface\\icons\\_HearthStoneDark_Priest:35|t |cffffffff(Cosmétique)|r Temple Halo-du-Néant", 801, 1234.33, 1344.18, 185.081, 0.00819301, nameEn = "|TInterface\\icons\\_HearthStoneDark_Priest:35|t |cffffffff(Cosmetic)|r Netherlight Temple"},
				{"|TInterface\\icons\\_HearthStoneDark_Shaman:35|t |cffffffff(Event)|r Le Maelström", 802, 1070.35, 1119.89, 19.6602, 4.07609, nameEn = "|TInterface\\icons\\_HearthStoneDark_Shaman:35|t |cffffffff(Event)|r The Maelstrom"},
				{"|TInterface\\icons\\_RuneMagmaVerte:35|t Le Marteau gangrené", 798, 1508.94, 1412.19, 243.361, 0.0534305, nameEn = "|TInterface\\icons\\_RuneMagmaVerte:35|t The Corrupted Hammer"},
        --[3] = { "|TInterface\\icons\\achievement_bg_winwsg:35|t Zones PvP", 2,
                        --{"|TInterface\\icons\\inv_misc_armorkit_14:35|t Arène de Gurubashi|PvP", 0, -13233.189453, 219.459229, 31.936506, 1.0},
						--{"|TInterface\\icons\\achievement_zone_nagrand_02:35|t Arène de Nagrand|PvP", 530, -1979.782104, 6560.494629, 11.156476, 2.314995},
						--{"|TInterface\\icons\\achievement_bg_killingblow_most:35|t Zone de Duel|PvP", 1, -10735.681641, 2479.739502, 6.486568, 4.562986},
        },
        [4] = { "|TInterface\\icons\\achievement_zone_nagrand_01:35|t Villes Neutre", 2, nameEn = "|TInterface\\icons\\achievement_zone_nagrand_01:35|t Neutral Cities",
                {"|TInterface\\icons\\spell_arcane_teleportdalaran:35|t Dalaran", 571, 5807.794922, 588.387268, 660.937134, 1.6, nameEn = "|TInterface\\icons\\spell_arcane_teleportdalaran:35|t Dalaran"},
                {"|TInterface\\icons\\spell_arcane_teleportshattrath:35|t Shattrath", 530, -1806.164307, 5323.119141, -12.428000, 2.1, nameEn = "|TInterface\\icons\\spell_arcane_teleportshattrath:35|t Shattrath"},
	    },		
		[5] = { "|TInterface\\icons\\spell_arcane_teleportstormwind:35|t Donjons/Raids", 2, nameEn = "|TInterface\\icons\\spell_arcane_teleportstormwind:35|t Dungeons/Raids",
				{"|TInterface\\icons\\spell_arcane_teleportstormwind:35|t [1] Chemin du Rêve d'émeraude", 792, 1658.18, 1573.7, 5.84094, 2.46316, nameEn = "|TInterface\\icons\\spell_arcane_teleportstormwind:35|t [1] Path of the Emerald Dream"},
				{"|TInterface\\icons\\spell_arcane_teleportstormwind:35|t [2] Chemin du Rêve d'émeraude", 793, 1658.18, 1573.7, 5.84094, 2.46316, nameEn = "|TInterface\\icons\\spell_arcane_teleportstormwind:35|t [2] Path of the Emerald Dream"},
				{"|TInterface\\icons\\spell_arcane_teleportstormwind:35|t [3] Chemin du Rêve d'émeraude", 822, 1658.18, 1573.7, 5.84094, 2.46316, nameEn = "|TInterface\\icons\\spell_arcane_teleportstormwind:35|t [3] Path of the Emerald Dream"},
		},
}

-- CODE STUFFS! DO NOT EDIT BELOW
-- UNLESS YOU KNOW WHAT YOU'RE DOING!

-- Détermine la langue du compte du joueur (0 = enUS, sinon frFR)
local function GetPlayerLocale(player)
    local ok, result = pcall(function()
        local accountId = player:GetAccountId()
        local q = AuthDBQuery("SELECT locale FROM account WHERE id = " .. accountId .. ";")
        if q then
            local localeId = q:GetUInt8(0)
            if localeId == 0 then
                return "enUS"
            end
        end
        return "frFR"
    end)
    if ok and result then
        return result
    end
    return "frFR"
end

local TeleporterNotif = {
    frFR = { BACK = "Retour" },
    enUS = { BACK = "Back" },
}

local function L(player)
    return TeleporterNotif[GetPlayerLocale(player)] or TeleporterNotif.frFR
end

-- Renvoie le libellé localisé d'une entrée (titre de catégorie ou destination) :
-- v.nameEn si le joueur est enUS et qu'un champ nameEn existe, sinon le frFR (v[1]).
local function LocalizedLabel(player, v)
    if GetPlayerLocale(player) == "enUS" and v.nameEn then
        return v.nameEn
    end
    return v[1]
end

local function OnGossipHello(event, player, unit)
    -- Show main menu
    for i, v in ipairs(T) do
        if (v[2] == 2 or v[2] == player:GetTeam()) then
            player:GossipMenuAddItem(0, LocalizedLabel(player, v), i, 0)
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
                player:GossipMenuAddItem(0, LocalizedLabel(player, v), sender, i)
            end
        end
        player:GossipMenuAddItem(0, L(player).BACK, 0, 0)
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