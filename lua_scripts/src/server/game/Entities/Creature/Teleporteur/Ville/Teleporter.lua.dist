--------------------- AFFICHAGE + CONDITIONS DE TÉLÉPORTATION ---------------------

local NpcId = 7565 -- A MODIFIER PAR VOTRE NPC ENTRY
local MenuId = 70000 -- A MODIFIER PAR UN MENU ENTRY INEXISTANT

local function OnGossipHello(event, player, object)
    -- Vérifie si le joueur est en BG ou en arène
    if player:GetMap():IsBattleground() or player:GetMap():IsArena() then
        player:SendBroadcastMessage("Vous ne pouvez pas accéder au menu de téléportation depuis un champ de bataille ou une arène.")
        player:GossipComplete()  -- Ferme le menu sans afficher quoi que ce soit
        return
    end

    -- Sinon, affiche le menu de téléportation
    player:GossipClearMenu()
    player:GossipSetText("Salut |cff350000"..player:GetName().."|r, tu souhaiterais voyager quelque part ? Il suffit de me dire où tu veux aller. Je suis à ton service.")
    player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_bg_masterofallbgs:17:17:-21|tCapitales", 1, 1)
    player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_zone_easternkingdoms_01:17:17:-21|tRoyaumes de l'Est", 1, 2)
    player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_zone_kalimdor_01:17:17:-21|tKalimdor", 1, 3)
    player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_zone_northrend_01:17:17:-21|tNorfendre", 1, 4)
    player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_zone_outland_01:17:17:-21|tOutreterre", 1, 5)
    player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_dungeon_cotstratholme_heroic:17:17:-21|tDonjons Vanilla", 1, 6)
    player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_dungeon_cotstratholme_25man:17:17:-21|tDonjons The Burning Crusade", 1, 7)
    player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_dungeon_cotstratholme_normal:17:17:-21|tDonjons Wrath of the Lich King", 1, 8)
    --player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_dungeon_ulduarraid_irondwarf_01:17:17:-21|tDonjons Custom", 1, 9)
    player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_dungeon_utgardepinnacle_heroic:17:17:-21|tRaids Vanilla", 1, 10)
    player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_dungeon_utgardepinnacle_10man:17:17:-21|tRaids The Burning Crusade", 1, 11)
    player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_dungeon_utgardepinnacle_normal:17:17:-21|tRaids Wrath of the Lich King", 1, 12)
    --player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_dungeon_ulduarraid_ironsentinel_01:17:17:-21|tRaids Custom", 1, 13)
    player:GossipSendMenu(0x7FFFFFFF, object, MenuId) -- MenuId necessaire pour les joueurs
end

local function OnGossipSelect(event, player, object, sender, intid, code, menuid)
    -- OnGossipHello
    if (intid == 0) then -- RETOUR
        player:GossipClearMenu()
        player:GossipSetText("Salut |cff350000"..player:GetName().."|r, tu souhaiterais voyager quelque part ? Il suffit de me dire où tu veux aller. Je suis à ton service.")
        player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_bg_masterofallbgs:17:17:-21|tCapitales", 1, 1)
        player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_zone_easternkingdoms_01:17:17:-21|tRoyaumes de l'Est", 1, 2)
        player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_zone_kalimdor_01:17:17:-21|tKalimdor", 1, 3)
        player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_zone_northrend_01:17:17:-21|tNorfendre", 1, 4)
        player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_zone_outland_01:17:17:-21|tOutreterre", 1, 5)
        player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_dungeon_cotstratholme_heroic:17:17:-21|tDonjons Vanilla", 1, 6)
        player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_dungeon_cotstratholme_25man:17:17:-21|tDonjons The Burning Crusade", 1, 7)
        player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_dungeon_cotstratholme_normal:17:17:-21|tDonjons Wrath of the Lich King", 1, 8)
        --player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_dungeon_ulduarraid_irondwarf_01:17:17:-21|tDonjons Custom", 1, 9)
        player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_dungeon_utgardepinnacle_heroic:17:17:-21|tRaids Vanilla", 1, 10)
        player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_dungeon_utgardepinnacle_10man:17:17:-21|tRaids The Burning Crusade", 1, 11)
        player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_dungeon_utgardepinnacle_normal:17:17:-21|tRaids Wrath of the Lich King", 1, 12)
        --player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_dungeon_ulduarraid_ironsentinel_01:17:17:-21|tRaids Custom", 1, 13)
        player:GossipSendMenu(0x7FFFFFFF, object, MenuId)
    end

    -- CAPITALES
    if (intid == 1) then
        if (player:GetTeam() == 0) then -- ALLIANCE
            player:GossipSetText("Pour l'|cff3498dbAlliance|r !")
            player:GossipMenuAddItem(0, "Hurlevent", 1, 14)
            player:GossipMenuAddItem(0, "Forgefer", 1, 15)
            player:GossipMenuAddItem(0, "Darnassus", 1, 16)
            player:GossipMenuAddItem(0, "Exodar", 1, 17)
        elseif (player:GetTeam() == 1) then -- HORDE
            player:GossipSetText("Pour la |cffe74c3cHorde|r !")
            player:GossipMenuAddItem(0, "Orgrimmar", 1, 18)
            player:GossipMenuAddItem(0, "Fossoyeuse", 1, 19)
            player:GossipMenuAddItem(0, "Les Pitons du Tonnerre", 1, 20)
            player:GossipMenuAddItem(0, "Lune-d'argent", 1, 21)
        end -- LES DEUX
        if (player:GetLevel() >= 60) then
            player:GossipMenuAddItem(0, "Shattrath", 1, 22)
        end
        if (player:GetLevel() >= 70) then
            player:GossipMenuAddItem(0, "Dalaran", 1, 23)
        end
        player:GossipMenuAddItem(0, "|TInterface\\icons\\inv_misc_ammo_arrow_04:17:17:-21|t|cffecf0f1Retour", 0, 0)
        player:GossipSendMenu(0x7FFFFFFF, object, MenuId) -- MenuId necessaire pour les joueurs

    -- ROYAUMES DE l'EST
    elseif (intid == 2) then
        if (player:GetTeam() == 0) then -- ALLIANCE
            if (player:GetLevel() >= 1) then
                player:GossipSetText("Pour l'|cff3498dbAlliance|r !")
                player:GossipMenuAddItem(0, "Dun Morogh", 1, 24)
                player:GossipMenuAddItem(0, "Forêt d'Elwynn", 1, 25)
            end
            if (player:GetLevel() >= 8) then
                player:GossipMenuAddItem(0, "Loch Modan", 1, 26)
                player:GossipMenuAddItem(0, "Marche de l'Ouest", 1, 27)
            end
        end
        if (player:GetTeam() == 1) then -- HORDE
            if (player:GetLevel() >= 1) then
                player:GossipSetText("Pour la |cffe74c3cHorde|r !")
                player:GossipMenuAddItem(0, "Bois des Chants éternels", 1, 28)
                player:GossipMenuAddItem(0, "Clairières de Tirisfal", 1, 29)
            end
            if (player:GetLevel() >= 8) then
                player:GossipMenuAddItem(0, "Forêt des Pins argentés", 1, 30)
                player:GossipMenuAddItem(0, "Les Terres fantômes", 1, 31)
            end
        end -- LES DEUX
        if (player:GetLevel() >= 13) then
            player:GossipMenuAddItem(0, "Les Carmines", 1, 32)
        end
        if (player:GetLevel() >= 18) then
            player:GossipMenuAddItem(0, "Bois de la Pénombre", 1, 33)
            player:GossipMenuAddItem(0, "Contreforts de Hautebrande", 1, 34)
            player:GossipMenuAddItem(0, "Les Paluns", 1, 35)
        end
        if (player:GetLevel() >= 28) then
            player:GossipMenuAddItem(0, "Hautes-terres d'Arathi", 1, 36)
            player:GossipMenuAddItem(0, "Montagnes d'Alterac", 1, 37)
            player:GossipMenuAddItem(0, "Vallée de Strangleronce", 1, 38)
        end
        if (player:GetLevel() >= 33) then
            player:GossipMenuAddItem(0, "Marais des Chagrins", 1, 39)
            player:GossipMenuAddItem(0, "Terres ingrates", 1, 40)
        end
        if (player:GetLevel() >= 38) then
            player:GossipMenuAddItem(0, "Les Hinterlands", 1, 41)
        end
        if (player:GetLevel() >= 43) then
            player:GossipMenuAddItem(0, "Gorge des Vents brûlants", 1, 42)
            player:GossipMenuAddItem(0, "Terres foudroyées", 1, 43)
        end
        if (player:GetLevel() >= 48) then
            player:GossipMenuAddItem(0, "Maleterres de l'ouest", 1, 44)
            player:GossipMenuAddItem(0, "Steppes ardentes", 1, 45)
        end
        if (player:GetLevel() >= 53) then
            player:GossipMenuAddItem(0, "Maleterres de l'est", 1, 46)
        end
        if (player:GetLevel() >= 69) then
            player:GossipMenuAddItem(0, "Île de Quel'Danas", 1, 47)
        end
        player:GossipMenuAddItem(0, "|TInterface\\icons\\inv_misc_ammo_arrow_04:17:17:-21|t|cffecf0f1Retour", 0, 0)
        player:GossipSendMenu(0x7FFFFFFF, object, MenuId) -- MenuId necessaire pour les joueurs

    -- KALIMDOR
    elseif (intid == 3) then
        if (player:GetTeam() == 0) then -- ALLIANCE
            if (player:GetLevel() >= 1) then
                player:GossipSetText("Pour l'|cff3498dbAlliance|r !")
                player:GossipMenuAddItem(0, "Île de Brume-azur", 1, 48)
                player:GossipMenuAddItem(0, "Teldrassil", 1, 49)
            end
            if (player:GetLevel() >= 8) then
                player:GossipMenuAddItem(0, "Île de Brume-sang", 1, 50)
                player:GossipMenuAddItem(0, "Sombrivage", 1, 51)
            end
        end
        if (player:GetTeam() == 1) then -- HORDE
            if (player:GetLevel() >= 1) then
                player:GossipSetText("Pour la |cffe74c3cHorde|r !")
                player:GossipMenuAddItem(0, "Durotar", 1, 52)
                player:GossipMenuAddItem(0, "Mulgore", 1, 53)
            end
            if (player:GetLevel() >= 8) then
                player:GossipMenuAddItem(0, "Les Tarides", 1, 54)
            end
        end -- LES DEUX
        if (player:GetLevel() >= 13) then
            player:GossipMenuAddItem(0, "Les Serres-Rocheuses", 1, 55)
        end
        if (player:GetLevel() >= 18) then
            player:GossipMenuAddItem(0, "Orneval", 1, 56)
        end
        if (player:GetLevel() >= 23) then
            player:GossipMenuAddItem(0, "Mille pointes", 1, 57)
        end
        if (player:GetLevel() >= 28) then
            player:GossipMenuAddItem(0, "Désolace", 1, 58)
        end
        if (player:GetLevel() >= 33) then
            player:GossipMenuAddItem(0, "Marécage d'Âprefange", 1, 59)
        end
        if (player:GetLevel() >= 38) then
            player:GossipMenuAddItem(0, "Féralas", 1, 60)
            player:GossipMenuAddItem(0, "Tanaris", 1, 61)
        end
        if (player:GetLevel() >= 43) then
            player:GossipMenuAddItem(0, "Azshara", 1, 62)
        end
        if (player:GetLevel() >= 45) then
            player:GossipMenuAddItem(0, "Cratère d'Un'Goro", 1, 63)
        end
        if (player:GetLevel() >= 46) then
            player:GossipMenuAddItem(0, "Gangrebois", 1, 64)
        end
        if (player:GetLevel() >= 53) then
            player:GossipMenuAddItem(0, "Silithus", 1, 65)
            player:GossipMenuAddItem(0, "Berceau-de-l'Hiver", 1, 66)
        end
        if (player:GetLevel() >= 60) then
            player:GossipMenuAddItem(0, "Reflet-de-Lune", 1, 67)
        end
        player:GossipMenuAddItem(0, "|TInterface\\icons\\inv_misc_ammo_arrow_04:17:17:-21|t|cffecf0f1Retour", 0, 0)
        player:GossipSendMenu(0x7FFFFFFF, object, MenuId) -- MenuId necessaire pour les joueurs

    -- NORFENDRE
    elseif (intid == 4) then
        if (player:GetTeam() == 0) then -- ALLIANCE
            player:GossipSetText("Pour l'|cff3498dbAlliance|r !")
        elseif (player:GetTeam() == 1) then -- HORDE
            player:GossipSetText("Pour la |cffe74c3cHorde|r !")
        end
        if (player:GetLevel() >= 68) then
            player:GossipMenuAddItem(0, "Toundra Boréenne", 1, 68)
            player:GossipMenuAddItem(0, "Fjord Hurlant", 1, 69)
        end
        if (player:GetLevel() >= 70) then
            player:GossipMenuAddItem(0, "Les Grisonnes", 1, 70)
        end
        if (player:GetLevel() >= 71) then
            player:GossipMenuAddItem(0, "Désolation des dragons", 1, 71)
        end
        if (player:GetLevel() >= 73) then
            player:GossipMenuAddItem(0, "Zul'Drak", 1, 72)
        end
        if (player:GetLevel() >= 75) then
            player:GossipMenuAddItem(0, "Bassin de Sholazar", 1, 73)
        end
        if (player:GetLevel() >= 77) then
            player:GossipMenuAddItem(0, "La Couronne de glace", 1, 74)
            player:GossipMenuAddItem(0, "Les pics Foudroyés", 1, 75)
            player:GossipMenuAddItem(0, "Forêt du Chant de cristal", 1, 76)
        end
        player:GossipMenuAddItem(0, "|TInterface\\icons\\inv_misc_ammo_arrow_04:17:17:-21|t|cffecf0f1Retour", 0, 0)
        player:GossipSendMenu(0x7FFFFFFF, object, MenuId) -- MenuId necessaire pour les joueurs
        
    -- OUTRETERRE
    elseif (intid == 5) then
        if (player:GetTeam() == 0) then -- ALLIANCE
            player:GossipSetText("Pour l'|cff3498dbAlliance|r !")
        elseif (player:GetTeam() == 1) then -- HORDE
            player:GossipSetText("Pour la |cffe74c3cHorde|r !")
        end
        if (player:GetLevel() >= 57) then
            player:GossipMenuAddItem(0, "Péninsule des Flammes infernales", 1, 77)
        end
        if (player:GetLevel() >= 58) then
            player:GossipMenuAddItem(0, "Marécage de Zangar", 1, 78)
        end
        if (player:GetLevel() >= 60) then
            player:GossipMenuAddItem(0, "Forêt de Terokkar", 1, 79)
        end
        if (player:GetLevel() >= 62) then
            player:GossipMenuAddItem(0, "Nagrand", 1, 80)
        end
        if (player:GetLevel() >= 63) then
            player:GossipMenuAddItem(0, "Les Tranchantes", 1, 81)
        end
        if (player:GetLevel() >= 65) then
            player:GossipMenuAddItem(0, "Raz-de-Neant", 1, 82)
            player:GossipMenuAddItem(0, "Vallée d'Ombrelune", 1, 83)
        end
        player:GossipMenuAddItem(0, "|TInterface\\icons\\inv_misc_ammo_arrow_04:17:17:-21|t|cffecf0f1Retour", 0, 0)
        player:GossipSendMenu(0x7FFFFFFF, object, MenuId) -- MenuId necessaire pour les joueurs

    -- DONJONS VANILLA
    elseif (intid == 6) then
        if (player:GetTeam() == 0) then -- ALLIANCE
            player:GossipSetText("Pour l'|cff3498dbAlliance|r !")
        elseif (player:GetTeam() == 1) then -- HORDE
            player:GossipSetText("Pour la |cffe74c3cHorde|r !")
        end
        if (player:GetLevel() >= 15) then
            player:GossipMenuAddItem(0, "Gouffre de Ragefeu", 1, 84)
        end
        if (player:GetLevel() >= 17) then
            player:GossipMenuAddItem(0, "Cavernes des lamentations", 1, 85)
            player:GossipMenuAddItem(0, "Les Mortemines", 1, 86)
        end
        if (player:GetLevel() >= 18) then
            player:GossipMenuAddItem(0, "Donjon d'Ombrecroc", 1, 87)
        end
        if (player:GetLevel() >= 21) then
            player:GossipMenuAddItem(0, "Profondeurs de Brassenoire", 1, 88)
        end
        if (player:GetLevel() >= 22) then
            player:GossipMenuAddItem(0, "La Prison", 1, 89)
        end
        if (player:GetLevel() >= 24) then
            player:GossipMenuAddItem(0, "Kraal de Tranchebauge", 1, 90)
        end
        if (player:GetLevel() >= 25) then
            player:GossipMenuAddItem(0, "Gnomeran", 1, 91)
        end
        if (player:GetLevel() >= 29) then
            player:GossipMenuAddItem(0, "Monastère écarlate", 1, 92)
        end
        if (player:GetLevel() >= 34) then
            player:GossipMenuAddItem(0, "Souilles de Tranchebauge", 1, 93)
        end
        if (player:GetLevel() >= 37) then
            player:GossipMenuAddItem(0, "Uldaman", 1, 94)
        end
        if (player:GetLevel() >= 41) then
            player:GossipMenuAddItem(0, "Maraudon", 1, 95)
        end
        if (player:GetLevel() >= 43) then
            player:GossipMenuAddItem(0, "Zul'Farrak", 1, 96)
        end
        if (player:GetLevel() >= 47) then
            player:GossipMenuAddItem(0, "Le temple d'Atal'Hakkar", 1, 97)
            player:GossipMenuAddItem(0, "Temple englouti", 1, 98)
        end
        if (player:GetLevel() >= 49) then
            player:GossipMenuAddItem(0, "Profondeurs de Rochenoire", 1, 99)
        end
        if (player:GetLevel() >= 55) then
            player:GossipMenuAddItem(0, "Hache-tripes", 1, 100)
            player:GossipMenuAddItem(0, "Scholomance", 1, 101)
            player:GossipMenuAddItem(0, "Stratholme", 1, 102)
        end
        if (player:GetLevel() >= 57) then
            player:GossipMenuAddItem(0, "Pic Rochenoire", 1, 103)
        end
        player:GossipMenuAddItem(0, "|TInterface\\icons\\inv_misc_ammo_arrow_04:17:17:-21|t|cffecf0f1Retour", 0, 0)
        player:GossipSendMenu(0x7FFFFFFF, object, MenuId) -- MenuId necessaire pour les joueurs
    
    -- DONJONS THE BURNING CRUSADE
    elseif (intid == 7) then
        if (player:GetTeam() == 0) then -- ALLIANCE
            player:GossipSetText("Pour l'|cff3498dbAlliance|r !")
        elseif (player:GetTeam() == 1) then -- HORDE
            player:GossipSetText("Pour la |cffe74c3cHorde|r !")
        end
        if (player:GetLevel() >= 59) then
            player:GossipMenuAddItem(0, "Remparts des Flammes infernales", 1, 104)
        end
        if (player:GetLevel() >= 61) then
            player:GossipMenuAddItem(0, "La Fournaise du sang", 1, 105)
        end
        if (player:GetLevel() >= 62) then
            player:GossipMenuAddItem(0, "Les enclos aux esclaves", 1, 106)
        end
        if (player:GetLevel() >= 63) then
            player:GossipMenuAddItem(0, "La Basse-tourbière", 1, 107)
        end
        if (player:GetLevel() >= 64) then
            player:GossipMenuAddItem(0, "Tombes-mana", 1, 108)
        end
        if (player:GetLevel() >= 65) then
            player:GossipMenuAddItem(0, "Cryptes Auchenaï", 1, 109)
        end
        if (player:GetLevel() >= 66) then
            player:GossipMenuAddItem(0, "Contreforts de Hautebrande d'antan", 1, 110)
            player:GossipMenuAddItem(0, "Passé d'Hyjal", 1, 111)
        end
        if (player:GetLevel() >= 67) then
            player:GossipMenuAddItem(0, "Citadelle des Flammes infernales", 1, 112)
            player:GossipMenuAddItem(0, "La Botanica", 1, 113)
            player:GossipMenuAddItem(0, "Labyrinthe des ombres", 1, 114)
            player:GossipMenuAddItem(0, "Le Caveau de la vapeur", 1, 115)
            player:GossipMenuAddItem(0, "Le Méchanar", 1, 116)
            player:GossipMenuAddItem(0, "Les Salles brisées", 1, 117)
            player:GossipMenuAddItem(0, "Les salles des Sethekk", 1, 118)
        end
        if (player:GetLevel() >= 67) then
            player:GossipMenuAddItem(0, "L'Arcatraz", 1, 119)
            player:GossipMenuAddItem(0, "Le Noir Marécage", 1, 120)
            player:GossipMenuAddItem(0, "Terrasse des Magistères", 1, 121)
        end
        player:GossipMenuAddItem(0, "|TInterface\\icons\\inv_misc_ammo_arrow_04:17:17:-21|t|cffecf0f1Retour", 0, 0)
        player:GossipSendMenu(0x7FFFFFFF, object, MenuId) -- MenuId necessaire pour les joueurs
    
    -- DONJONS WRATH OF THE LICH KING
    elseif (intid == 8) then
        if (player:GetTeam() == 0) then -- ALLIANCE
            player:GossipSetText("Pour l'|cff3498dbAlliance|r !")
        elseif (player:GetTeam() == 1) then -- HORDE
            player:GossipSetText("Pour la |cffe74c3cHorde|r !")
        end
        if (player:GetLevel() >= 69) then
            player:GossipMenuAddItem(0, "Donjon d'Utgarde", 1, 122)
        end
        if (player:GetLevel() >= 71) then
            player:GossipMenuAddItem(0, "Le Nexus", 1, 123)
        end
        if (player:GetLevel() >= 72) then
            player:GossipMenuAddItem(0, "Azjol-Nérub", 1, 124)
        end
        if (player:GetLevel() >= 73) then
            player:GossipMenuAddItem(0, "Ahn'kahet : l'Ancien royaume", 1, 125)
        end
        if (player:GetLevel() >= 74) then
            player:GossipMenuAddItem(0, "Donjon de Drak'Tharon", 1, 126)
        end
        if (player:GetLevel() >= 75) then
            player:GossipMenuAddItem(0, "Le fort Pourpre", 1, 127)
        end
        if (player:GetLevel() >= 76) then
            player:GossipMenuAddItem(0, "Gundrak", 1, 128)
        end
        if (player:GetLevel() >= 77) then
            player:GossipMenuAddItem(0, "Les salles de Pierre", 1, 129)
        end
        if (player:GetLevel() >= 79) then
            player:GossipMenuAddItem(0, "Cime d'Utgarde", 1, 130)
            player:GossipMenuAddItem(0, "Fosse de Saron", 1, 131)
            player:GossipMenuAddItem(0, "L'épreuve du champion", 1, 132)
            player:GossipMenuAddItem(0, "L'Épuration de Stratholme", 1, 133)
            player:GossipMenuAddItem(0, "L'Oculus", 1, 134)
            player:GossipMenuAddItem(0, "La Forge des âmes", 1, 135)
            player:GossipMenuAddItem(0, "Les salles de Foudre", 1, 136)
            player:GossipMenuAddItem(0, "Salles des Reflets", 1, 137)
        end
        player:GossipMenuAddItem(0, "|TInterface\\icons\\inv_misc_ammo_arrow_04:17:17:-21|t|cffecf0f1Retour", 0, 0)
        player:GossipSendMenu(0x7FFFFFFF, object, MenuId) -- MenuId necessaire pour les joueurs

    -- RAIDS VANILLA
    elseif (intid == 10) then
        if (player:GetTeam() == 0) then -- ALLIANCE
            player:GossipSetText("Pour l'|cff3498dbAlliance|r !")
        elseif (player:GetTeam() == 1) then -- HORDE
            player:GossipSetText("Pour la |cffe74c3cHorde|r !")
        end
        if (player:GetLevel() >= 57) then
            player:GossipMenuAddItem(0, "Zul'Gurub", 1, 138)
        end
        if (player:GetLevel() >= 60) then
            player:GossipMenuAddItem(0, "Ahn'Qiraj", 1, 139)
            player:GossipMenuAddItem(0, "Cœur du Magma", 1, 140)
            player:GossipMenuAddItem(0, "Repaire de l'Aile noire", 1, 141)
            player:GossipMenuAddItem(0, "Ruines d'Ahn'Qiraj", 1, 142)
        end
        player:GossipMenuAddItem(0, "|TInterface\\icons\\inv_misc_ammo_arrow_04:17:17:-21|t|cffecf0f1Retour", 0, 0)
        player:GossipSendMenu(0x7FFFFFFF, object, MenuId) -- MenuId necessaire pour les joueurs

    -- RAIDS THE BURNING CRUSADE
    elseif (intid == 11) then
        if (player:GetTeam() == 0) then -- ALLIANCE
            player:GossipSetText("Pour l'|cff3498dbAlliance|r !")
        elseif (player:GetTeam() == 1) then -- HORDE
            player:GossipSetText("Pour la |cffe74c3cHorde|r !")
        end
        if (player:GetLevel() >= 70) then
            player:GossipMenuAddItem(0, "Caverne du sanctuaire du Serpent", 1, 143)
            player:GossipMenuAddItem(0, "Donjon de la Tempête", 1, 144)
            player:GossipMenuAddItem(0, "Karazhan", 1, 145)
            player:GossipMenuAddItem(0, "Le repaire de Magtheridon", 1, 146)
            player:GossipMenuAddItem(0, "Plateau du Puits de soleil", 1, 147)
            player:GossipMenuAddItem(0, "Repaire de Gruul", 1, 148)
            player:GossipMenuAddItem(0, "Sommet d'Hyjal", 1, 149)
            player:GossipMenuAddItem(0, "Temple noir", 1, 150)
            player:GossipMenuAddItem(0, "Zul'Aman", 1, 151)
        end
        player:GossipMenuAddItem(0, "|TInterface\\icons\\inv_misc_ammo_arrow_04:17:17:-21|t|cffecf0f1Retour", 0, 0)
        player:GossipSendMenu(0x7FFFFFFF, object, MenuId) -- MenuId necessaire pour les joueurs

    -- RAIDS WRATH OF THE LICH KING
    elseif (intid == 12) then
        if (player:GetTeam() == 0) then -- ALLIANCE
            player:GossipSetText("Pour l'|cff3498dbAlliance|r !")
        elseif (player:GetTeam() == 1) then -- HORDE
            player:GossipSetText("Pour la |cffe74c3cHorde|r !")
        end
        if (player:GetLevel() >= 80) then
            player:GossipMenuAddItem(0, "Caveau d'Archavon", 1, 152)
            player:GossipMenuAddItem(0, "Citadelle de la Couronne de glace", 1, 153)
            player:GossipMenuAddItem(0, "L'épreuve du croisé", 1, 154)
            player:GossipMenuAddItem(0, "L'Œil de l'éternité", 1, 155)
            --player:GossipMenuAddItem(0, "La salle Cramoisie", 1, 156) (ICC)
            --player:GossipMenuAddItem(0, "Laboratoire des désopilantes atrocités alchimiques de Putricide", 1, 157) (ICC)
            --player:GossipMenuAddItem(0, "Le repaire de la reine du Givre", 1, 158) (ICC)
            --player:GossipMenuAddItem(0, "Le sanctum de Sang", 1, 159) (ICC)
            player:GossipMenuAddItem(0, "Le sanctum Obsidien", 1, 160)
            player:GossipMenuAddItem(0, "Le sanctum Rubis", 1, 161)
            --player:GossipMenuAddItem(0, "Le Trône de glace", 1, 162) (ICC)
            player:GossipMenuAddItem(0, "Naxxramas", 1, 163)
            player:GossipMenuAddItem(0, "Ulduar", 1, 164)
			player:GossipMenuAddItem(0, "Onyxia", 1, 165)
        end
        player:GossipMenuAddItem(0, "|TInterface\\icons\\inv_misc_ammo_arrow_04:17:17:-21|t|cffecf0f1Retour", 0, 0)
        player:GossipSendMenu(0x7FFFFFFF, object, MenuId) -- MenuId necessaire pour les joueurs

    -- DONJONS CUSTOM
    --elseif (intid == 9) then
        --if (player:GetTeam() == 0) then -- ALLIANCE
            --player:GossipSetText("Pour l'|cff3498dbAlliance|r !")
        --elseif (player:GetTeam() == 1) then -- HORDE
            --player:GossipSetText("Pour la |cffe74c3cHorde|r !")
        --end
        --player:GossipMenuAddItem(0, "|TInterface\\icons\\inv_misc_ammo_arrow_04:17:17:-21|t|cffecf0f1Retour", 0, 0)
        --player:GossipSendMenu(0x7FFFFFFF, object, MenuId) -- MenuId necessaire pour les joueurs

    -- RAIDS CUSTOM
    --elseif (intid == 13) then
        --if (player:GetTeam() == 0) then -- ALLIANCE
            --player:GossipSetText("Pour l'|cff3498dbAlliance|r !")
        --elseif (player:GetTeam() == 1) then -- HORDE
            --player:GossipSetText("Pour la |cffe74c3cHorde|r !")
        --end
        --player:GossipMenuAddItem(0, "|TInterface\\icons\\inv_misc_ammo_arrow_04:17:17:-21|t|cffecf0f1Retour", 0, 0)
        --player:GossipSendMenu(0x7FFFFFFF, object, MenuId) -- MenuId necessaire pour les joueurs
    
    
    end

--------------------- COORDONNÉES DE TÉLÉPORTATION ---------------------

    -- CAPITALES
    if (intid == 14) then -- HURLEVENT
        player:Teleport(0, -8850.00, 634.90, 98.21, 0.27)
    player:GossipComplete()
    end
    if (intid == 15) then -- FORGEFER
        player:Teleport(0, -4903.00, -968.23, 501.53, 2.47)
    player:GossipComplete()
    end
    if (intid == 16) then -- DARNASSUS
        player:Teleport(1, 9951.38, 2296.58, 1339.38, 1.59)
    player:GossipComplete()
    end
    if (intid == 17) then -- EXODAR
        player:Teleport(530, -3962.34, -11674.88, -138.88, 3.93)
    player:GossipComplete()
    end
    if (intid == 18) then -- ORGRIMMAR
        player:Teleport(1, 1517.55, -4412.03, 21.7103, 0.243466)
    player:GossipComplete()
    end
    if (intid == 19) then -- FOSSOYEUSE
        player:Teleport(0, 1587.19, 240.28, -52.14, 3.14)
    player:GossipComplete()
    end
    if (intid == 20) then -- LES PITONS DU TONNERRE
        player:Teleport(1, -1239.57, 116.76, 130.08, 3.21)
    player:GossipComplete()
    end
    if (intid == 21) then -- LUNE-D'ARGENT
        player:Teleport(530, 9994.80, -7047.10, 45.89, 3.98)
    player:GossipComplete()
    end
    if (intid == 22) then -- SHATTRATH
        player:Teleport(530, -1873.41, 5426.07, -10.46, 3.59)
    player:GossipComplete()
    end
    if (intid == 23) then -- DALARAN
        player:Teleport(571, 5833.99, 483.51, 658.26, 4.66)
    player:GossipComplete()
    end

    -- ROYAUMES DE L'EST
    if (intid == 24) then -- DUN MOROGH
        player:Teleport(0, -5674.12, -541.04, 398.22, 2.00)
        player:GossipComplete()
    end
    if (intid == 25) then -- FORÊT D'ELWYNN
        player:Teleport(0, -9623.87, -289.72, 57.89, 4.98)
        player:GossipComplete()
    end
    if (intid == 26) then -- LOCH MODAN
        player:Teleport(0, -5250.10, -2889.32, 339.28, 0.58)
        player:GossipComplete()
    end
    if (intid == 27) then -- MARCHE DE L'OUEST
        player:Teleport(0, -10228.13, 1228.17, 43.37, 6.17)
        player:GossipComplete()
    end
    if (intid == 28) then -- BOIS DES CHANTS ÉTERNELS
        player:Teleport(0, 8717.86, -6673.97, 70.25, 6.23)
        player:GossipComplete()
    end
    if (intid == 29) then -- CLAIRIÉRES DE TIRISFAL
        player:Teleport(0, 1881.829712, 1606.71, 92.64, 3.60)
        player:GossipComplete()
    end
    if (intid == 30) then -- FORÊT DES PINS ARGENTÉS
        player:Teleport(0, 344.11, 1241.18, 81.07, 3.02)
        player:GossipComplete()
    end
    if (intid == 31) then -- LES TERRES FANTÔMES
        player:Teleport(0, 7025.41, -6814.60, 42.12, 3.12)
        player:GossipComplete()
    end
    if (intid == 32) then -- LES CARMINES
        player:Teleport(0, -9466.62, -2349.54, 77.45, 1.77)
        player:GossipComplete()
    end
    if (intid == 33) then -- BOIS DE LA PÉNOMBRE
        player:Teleport(0, -10898.29, -364.78, 39.26, 3.04)
    player:GossipComplete()
    end
    if (intid == 34) then -- CONTREFORTS DE HAUTEBRANDE
        player:Teleport(0, -436.65, -581.25, 53.59, 1.25)
    player:GossipComplete()
    end
    if (intid == 35) then -- LES PALUNS
        player:Teleport(0, -3170.62, -2446.80, 9.66, 3.43)
    player:GossipComplete()
    end
    if (intid == 36) then -- HAUTES-TERRES D'ARATHI
        player:Teleport(0, -1797.74, -2410.44, 56.19, 5.97)
    player:GossipComplete()
    end
    if (intid == 37) then -- MONTAGNES D'ALTERAC
        player:Teleport(0, 795.50, -423.51, 135.64, 5.41)
    player:GossipComplete()
    end
    if (intid == 38) then -- VALLÉE DE STRANGLERONCE
        player:Teleport(0, -13262.70, 161.44, 36.43, 4.21)
    player:GossipComplete()
    end
    if (intid == 39) then -- MARAIS DES CHAGRINS
        player:Teleport(0, -10331.19, -3331.52, 22.32, 3.21)
    player:GossipComplete()
    end
    if (intid == 40) then -- TERRES INGRATES
        player:Teleport(0, -6107.74, -3446.64, 269.08, 2.97)
    player:GossipComplete()
    end
    if (intid == 41) then -- LES HINTERLANDS
        player:Teleport(0, 228.66, -3289.66, 109.78, 2.27)
    player:GossipComplete()
    end
    if (intid == 42) then -- GORGE DES VENTS BRÛLANTS
        player:Teleport(0, -7303.36, -1064.39, 277.07, 5.98)
    player:GossipComplete()
    end
    if (intid == 43) then -- TERRES FOUDROYÉES
        player:Teleport(0, -11182.68, -3018.01, 7.38, 3.89)
    player:GossipComplete()
    end
    if (intid == 44) then -- MALETERRES DE L'OUEST
        player:Teleport(0, 1678.17, -1359.16, 69.84, 5.02)
    player:GossipComplete()
    end
    if (intid == 45) then -- STEPPES ARDENTES
        player:Teleport(0, -7973.72, -2116.98, 127.35, 2.14)
    player:GossipComplete()
    end
    if (intid == 46) then -- MALETERRES DE L'EST
        player:Teleport(0, 3327.35, -3379.54, 144.85, 3.11)
    player:GossipComplete()
    end
    if (intid == 47) then -- ÎLE DE QUEL'DANAS
        player:Teleport(530, 12636.836914, -6634.67, 15.60, 5.16)
    player:GossipComplete()
    end

    -- KALIMDOR
    if (intid == 48) then -- ÎLE DE BRUME-AZUR
        player:Teleport(530, -4213.03, -12342.61, 4.66, 1.15)
        player:GossipComplete()
    end
    if (intid == 49) then -- TELDRASSIL
        player:Teleport(1, 10111.29, 1557.72, 1324.32, 4.04)
        player:GossipComplete()
    end
    if (intid == 50) then -- ÎLE DE BRUME-SANG
        player:Teleport(530, -1799.99, -11409.41, 45.93, 6.05)
        player:GossipComplete()
    end
    if (intid == 51) then -- SOMBRIVAGE
        player:Teleport(1, 5756.25, 298.50, 20.60, 5.96)
        player:GossipComplete()
    end
    if (intid == 52) then -- DUROTAR
        player:Teleport(1, 280.32, -4420.97, 17.50, 4.48)
        player:GossipComplete()
    end
    if (intid == 53) then -- MULGORE
        player:Teleport(1, -2192.18, -736.41, -13.40, 2.92)
        player:GossipComplete()
    end
    if (intid == 54) then -- LES TARIDES
        player:Teleport(1, 47.95, -2710.51, 91.66, 4.49)
        player:GossipComplete()
    end
    if (intid == 55) then -- LES SERRES-ROCHEUSES
        player:Teleport(1, 1576.12, 1027.56, 137.50, 0.55)
        player:GossipComplete()
    end
    if (intid == 56) then -- ORNEVAL
        player:Teleport(1, 1935.29, -2168.62, 93.91, 3.05)
        player:GossipComplete()
    end
    if (intid == 57) then -- MILLE POINTES
        player:Teleport(1, -4969.02, -1726.89, -62.12, 3.79)
    player:GossipComplete()
    end
    if (intid == 58) then -- DÉSOLACE
        player:Teleport(1, -606.39, 2211.75, 92.98, 0.80)
    player:GossipComplete()
    end
    if (intid == 59) then -- MARÉCAGE D'ÂPREFANGE
        player:Teleport(1, -4019.96, -2770.88, 32.99, 2.93)
    player:GossipComplete()
    end
    if (intid == 60) then -- FÉRALAS
        player:Teleport(1, -4837.60, 1325.27, 81.74, 3.22)
    player:GossipComplete()
    end
    if (intid == 61) then -- TANARIS
        player:Teleport(1, -7138.90, -3812.16, 9.19, 5.22)
    player:GossipComplete()
    end
    if (intid == 62) then -- AZSHARA
        player:Teleport(1, 3347.96, -4618.07, 92.63, 5.48)
    player:GossipComplete()
    end
    if (intid == 63) then -- CRATÉRE D'UN'GORO
        player:Teleport(1, -7943.22, -2119.09, -218.34, 6.07)
    player:GossipComplete()
    end
    if (intid == 64) then -- GANGREBOIS
        player:Teleport(1, 4102.36, -1006.80, 272.73, 2.99)
    player:GossipComplete()
    end
    if (intid == 65) then -- SILITHUS
        player:Teleport(1, -7426.87, 1005.30, 1.13, 2.96)
    player:GossipComplete()
    end
    if (intid == 66) then -- BERCEAU-DE-L'HIVER
        player:Teleport(1, 6702.82, -4496.97, 722.44, 4.01)
    player:GossipComplete()
    end
    if (intid == 67) then -- REFLET-DE-LUNE
        player:Teleport(1, 7964.52, -2362.58, 487.18, 2.33)
    player:GossipComplete()
    end

    -- NORFENDRE
    if (intid == 68) then -- TOUNDRA BORÉENNE
        player:Teleport(571, 3264.33, 5277.25, 40.06, 2.29)
    player:GossipComplete()
    end
    if (intid == 69) then -- FJORD HURLANT
        player:Teleport(571, 1902.15, -4883.91, 171.36, 3.11)
    player:GossipComplete()
    end
    if (intid == 70) then -- LES GRISONNES
        player:Teleport(571, 4323.39, -3606.85, 248.10, 0.23)
    player:GossipComplete()
    end
    if (intid == 71) then -- DÉSOLATION DES DRAGONS
        player:Teleport(571, 3546.39, 276.98, 45.59, 4.73)
    player:GossipComplete()
    end
    if (intid == 72) then -- ZUL'DRAK
        player:Teleport(571, 5559.07, -3210.45, 371.30, 2.33)
    player:GossipComplete()
    end
    if (intid == 73) then -- BASSIN DE SHOLAZAR
        player:Teleport(571, 5383.45, 4954.70, -124.76, 2.61)
    player:GossipComplete()
    end
    if (intid == 74) then -- LA COURONNE DE GLACE
        player:Teleport(571, 7667.72, 2059.60, 394.53, 6.26)
    player:GossipComplete()
    end
    if (intid == 75) then -- LES PICS FOUDROYÉS
        player:Teleport(571, 6887.43, -1633.37, 854.38, 2.36)
    player:GossipComplete()
    end
    if (intid == 76) then -- FORÊT DU CHANT DE CRISTAL
        player:Teleport(571, 5474.06, 39.76, 149.54, 6.27)
    player:GossipComplete()
    end

    -- OUTRETERRE
    if (intid == 77) then -- PÉNINSULE DES FLAMMES INFERNALES
        player:Teleport(530, -127.92, 2886.83, -2.69, 3.01)
    player:GossipComplete()
    end
    if (intid == 78) then -- MARÉCAGE DE ZANGAR
        player:Teleport(530, 253.41, 7083.81, 37.19, 2.91)
    player:GossipComplete()
    end
    if (intid == 79) then -- FORÊT DE TEROKKAR
        player:Teleport(530, -2000.46, 4451.54, 8.37, 4.40)
    player:GossipComplete()
    end
    if (intid == 80) then -- NAGRAND
        player:Teleport(530, -1145.94, 8182.35, 3.60, 6.13)
    player:GossipComplete()
    end
    if (intid == 81) then -- LES TRANCHANTES
        player:Teleport(530, 1989.23, 6366.78, 141.60, 0.73)
    player:GossipComplete()
    end
    if (intid == 82) then -- RAZ-DE-NÉANT
        player:Teleport(530, 4054.17, 3563.14, 121.31, 4.81)
    player:GossipComplete()
    end
    if (intid == 83) then -- VALLÉE D'OMBRELUNE
        player:Teleport(530, -3192.51, 2015.26, 96.61, 0.82)
    player:GossipComplete()
    end

    -- DONJONS VANILLA
    if (intid == 84) then -- GOUFFRE DE RAGEFEU
        player:Teleport(1, 1814.61, -4420.41, -18.76, 5.26)
    player:GossipComplete()
    end
    if (intid == 85) then -- CAVERNES DES LAMENTATIONS
        player:Teleport(1, -719.64, -2224.22, 17.01, 1.04)
    player:GossipComplete()
    end
    if (intid == 86) then -- LES MORTEMINES
        player:Teleport(0, -11208.38, 1675.82, 24.57, 1.55)
    player:GossipComplete()
    end
    if (intid == 87) then -- DONJON D'OMBRECROC
        player:Teleport(0, -232.19, 1569.26, 76.89, 1.23)
    player:GossipComplete()
    end
    if (intid == 88) then -- PROFONDEURS DE BRASSENOIRE
        player:Teleport(1, 4247.74, 745.87, -24.29, 1.23)
    player:GossipComplete()
    end
    if (intid == 89) then -- LA PRISON
        player:Teleport(0, -8768.92, 842.92, 89.42, 0.68)
    player:GossipComplete()
    end
    if (intid == 90) then -- KRAAL DE TRANCHEBAUGE
        player:Teleport(1, -4659.01, -2524.85, 81.38, 4.35)
    player:GossipComplete()
    end
    if (intid == 91) then -- GNOMERAN
        player:Teleport(0, -5163.54, 927.46, 257.17, 1.57)
    player:GossipComplete()
    end
    if (intid == 92) then -- MONASTÉRE ÉCARLATE
        player:Teleport(0, 2888.12, -808.03, 160.33, 4.07)
    player:GossipComplete()
    end
    if (intid == 93) then -- SOUILLES DE TRANCHEBAUGE
        player:Teleport(1, -4657.68, -2521.35, 81.13, 4.52)
    player:GossipComplete()
    end
    if (intid == 94) then -- ULDAMAN
        player:Teleport(0, -6067.66, -2954.97, 209.77, 0.05)
    player:GossipComplete()
    end
    if (intid == 95) then -- MARAUDON
        player:Teleport(1, -1471.00, 2618.59, 76.21, 3.30)
    player:GossipComplete()
    end
    if (intid == 96) then -- ZUL'FARRAK
        player:Teleport(1, -6797.73, -2892.48, 8.87, 0.15)
    player:GossipComplete()
    end
    if (intid == 97) then -- LE TEMPLE D'ATAL'HAKKAR
        player:Teleport(0, -10474.79, -3817.110, 28.97, 2.92)
    player:GossipComplete()
    end
    if (intid == 98) then -- TEMPLE ENGLOUTI
        player:Teleport(0, -10175.09, -3995.14, -112.90, 5.95)
    player:GossipComplete()
    end
    if (intid == 99) then -- PROFONDEURS DE BRASSENOIRE
        player:Teleport(0, -7183.041016, -917.23706, 165.479996 , 5.131231)
    player:GossipComplete()
    end
    if (intid == 100) then -- HACHE-TRIPES
        player:Teleport(1, -3828.01, 1250.21, 160.22, 3.20)
    player:GossipComplete()
    end
    if (intid == 101) then -- SCHOLOMANCE
        player:Teleport(0, 1271.68, -2555.05, 92.27, 0.51)
    player:GossipComplete()
    end
    if (intid == 102) then -- STRATHOLME
        player:Teleport(0, 3392.09, -3345.69, 142.25, 4.83)
    player:GossipComplete()
    end
    if (intid == 103) then -- PIC ROCHENOIRE
        player:Teleport(0, -7524.22, -1230.06, 285.73, 5.17)
    player:GossipComplete()
    end

    -- DONJONS THE BURNING CRUSADE
    if (intid == 104) then -- REMPARTS DES FLAMMES INFERNALES
        player:Teleport(530, -361.14, 3073.32, -15.07, 1.89)
    player:GossipComplete()
    end
    if (intid == 105) then -- LA FOURNAISE DU SANG
        player:Teleport(530, -303.42, 3163.96, 31.73, 2.18)
    player:GossipComplete()
    end
    if (intid == 106) then -- LES ENCLOS AUX ESCLAVES
        player:Teleport(530, 728.72, 7013.72, -71.54, 0.03)
    player:GossipComplete()
    end
    if (intid == 107) then -- LA BASSE-TOURBIÉRES
        player:Teleport(530, 780.60, 6752.40, -72.53, 4.91)
    player:GossipComplete()
    end
    if (intid == 108) then -- TOMBES-MANA
        player:Teleport(530, -3079.25, 4942.82, -101.04, 6.25)
    player:GossipComplete()
    end
    if (intid == 109) then -- CRYPTES AUCHENAÏ
        player:Teleport(530, -3362.14, 5227.66, -101.04, 1.52)
    player:GossipComplete()
    end
    if (intid == 110) then -- CONTREFORTS DE HAUTEBRANDE D'ANTAN
        player:Teleport(1, -8359.46, -4058.02, -208.181, 0.03)
    player:GossipComplete()
    end
    if (intid == 111) then -- PASSÉ D'HYJAL
        player:Teleport(1, -8175.61, -4173.76, -165.99, 0.88)
    player:GossipComplete()
    end
    if (intid == 112) then -- CITADELLE DES FLAMMES INFERNALES
        player:Teleport(530, -361.19, 3073.86, -15.06, 1.85)
    player:GossipComplete()
    end
    if (intid == 113) then -- LA BOTANICA
        player:Teleport(530, 3411.49, 1484.66, 182.83, 5.65)
    player:GossipComplete()
    end
    if (intid == 114) then -- LABYRINTHE DES OMBRES
        player:Teleport(530, -3646.58, 4943.61, -101.04, 3.14)
    player:GossipComplete()
    end
    if (intid == 115) then -- LE CAVEAU DE LA VAPEUR
        player:Teleport(530, 816.58, 6935.09, -80.53, 1.57)
    player:GossipComplete()
    end
    if (intid == 116) then -- LE MÉCHANAR
        player:Teleport(530, 2865.33, 1549.52, 252.15, 3.84)
    player:GossipComplete()
    end
    if (intid == 117) then -- LES SALLES BRISÉES
        player:Teleport(530, -309.23, 3078.39, -3.63, 1.60)
    player:GossipComplete()
    end
    if (intid == 118) then -- LES SALLES DES SETHEKK
        player:Teleport(556, 0.93, 1.00, 0.00, 3.14)
    player:GossipComplete()
    end
    if (intid == 119) then -- L'ARCATRAZ
        player:Teleport(530, 3309.82, 1336.45, 505.55, 5.11)
    player:GossipComplete()
    end
    if (intid == 120) then -- LE NOIR MARÉCAGE
        player:Teleport(1, -8751.83, -4199.19, -209.50, 2.02)
    player:GossipComplete()
    end
    if (intid == 121) then -- TERRASSE DES MAGISTÉRES
        player:Teleport(530, 12885.95, -7336.29, 65.48, 4.21)
    player:GossipComplete()
    end

    -- DONJONS WRATH OF THE LICH KING
    if (intid == 122) then -- DONJON D'UTGARDE
        player:Teleport(571, 1228.54, -4862.57, 41.24, 0.26)
    player:GossipComplete()
    end
    if (intid == 123) then -- LE NEXUS
        player:Teleport(571, 3897.20, 6985.30, 69.48, 0.11)
    player:GossipComplete()
    end
    if (intid == 124) then -- AZJOL-NÉRUB
        player:Teleport(571, 3676.41, 2167.81, 35.85, 2.42)
    player:GossipComplete()
    end
    if (intid == 125) then -- AHN'KAHET : l'ANCIEN ROYAUME
        player:Teleport(571, 3641.84, 2032.93, 2.47, 4.34)
    player:GossipComplete()
    end
    if (intid == 126) then -- DONJON DE DRAK'THARON
        player:Teleport(571, 4774.46, -2025.92, 229.36, 1.59)
    player:GossipComplete()
    end
    if (intid == 127) then -- LE FORT POURPRE
        player:Teleport(571, 5689.90, 499.00, 652.71, 4.03)
    player:GossipComplete()
    end
    if (intid == 128) then -- GUNDRAK
        player:Teleport(571, 6702.47, -4660.54, 441.56, 3.91)
    player:GossipComplete()
    end
    if (intid == 129) then -- LES SALLES DE PIERRE
        player:Teleport(571, 8922.26, -974.08, 1039.23, 1.55)
    player:GossipComplete()
    end
    if (intid == 130) then -- CIME D'UTGARDE
        player:Teleport(571, 1242.80, -4857.88, 217.75, 3.48)
    player:GossipComplete()
    end
    if (intid == 131) then -- FOSSE DE SARON
        player:Teleport(571, 5590.95, 2009.09, 798.18, 3.81)
    player:GossipComplete()
    end
    if (intid == 132) then -- L'ÉPREUVE DU CHAMPION
        player:Teleport(571, 8570.72, 791.79, 558.56, 3.08)
    player:GossipComplete()
    end
    if (intid == 133) then -- L'ÉPURATION DE STRATHOLME
        player:Teleport(1, -8756.68, -4457.72, -200.55, 4.60)
    player:GossipComplete()
    end
    if (intid == 134) then -- L'OCULUS
        player:Teleport(571, 3875.04, 6984.40, 106.78, 3.17)
    player:GossipComplete()
    end
    if (intid == 135) then -- LA FORGE DES ÂMES
        player:Teleport(571, 5669.05, 2005.67, 798.04, 5.43)
    player:GossipComplete()
    end
    if (intid == 136) then -- LES SALLES DE FOUDRE
        player:Teleport(571, 9183.73, -1385.63, 1110.20, 5.55)
    player:GossipComplete()
    end
    if (intid == 137) then -- SALLES DES REFLETS
        player:Teleport(571, 5627.81, 1973.17, 803.02, 4.56)
    player:GossipComplete()
    end

    -- RAIDS VANILLA
    if (intid == 138) then -- ZUL'GURUB
        player:Teleport(0, -11916.67, -1221.56, 92.28, 4.71)
    player:GossipComplete()
    end
    if (intid == 139) then -- AHN'QIRAJ
        player:Teleport(1, -8241.86, 1992.88, 129.07, 0.80)
    player:GossipComplete()
    end
    if (intid == 140) then -- COEUR DU MAGMA
        player:Teleport(230, 1118.22, -462.38, -103.75, 3.31)
    player:GossipComplete()
    end
    if (intid == 141) then -- REPAIRE DE l'AILE NOIRE
        player:Teleport(229, 175.10, -474.76, 116.83, 0.02)
    player:GossipComplete()
    end
    if (intid == 142) then -- RUINES D'AHN'QIRAJ
        player:Teleport(1, -8418.50, 1505.91, 31.82, 2.75)
    player:GossipComplete()
    end

    -- RAIDS THE BURNING CRUSADE
    if (intid == 143) then -- CAVERNE DU SANCTUAIRE DU SERPENT
        player:Teleport(530, 828.24, 6865.43, -63.78, 6.25)
    player:GossipComplete()
    end
    if (intid == 144) then -- DONJON DE LA TEMPÊTE
        player:Teleport(530, 3087.26, 1372.71, 184.57, 4.66)
    player:GossipComplete()
    end
    if (intid == 145) then -- KARAZHAN
        player:Teleport(0, -11112.78, -2005.68, 49.33, 0.64)
    player:GossipComplete()
    end
    if (intid == 146) then -- LE REPAIRE DE MAGTHERIDON
        player:Teleport(530, -312.20, 3086.30, -116.53, 5.19)
    player:GossipComplete()
    end
    if (intid == 147) then -- PLATEAU DU PUITS DE SOLEIL
        player:Teleport(530, 12562.41, -6774.76, 15.09, 3.13)
    player:GossipComplete()
    end
    if (intid == 148) then -- REPAIRE DE GRUUL
        player:Teleport(530, 3547.42, 5088.04, 2.99, 5.72)
    player:GossipComplete()
    end
    if (intid == 149) then -- SOMMET D'HYJAL
        player:Teleport(1, -8172.49, -4174.45, -165.91, 1.04)
    player:GossipComplete()
    end
    if (intid == 150) then -- TEMPLE NOIR
        player:Teleport(530, -3649.91, 317.46, 35.28, 2.94)
    player:GossipComplete()
    end
    if (intid == 151) then -- ZUL'AMAN
        player:Teleport(530, 6850.58, -7991.87, 191.09, 4.72)
    player:GossipComplete()
    end

    -- RAIDS WRATH OF THE LICH KING
    if (intid == 152) then -- CAVEAU D'ARCHAVON
        player:Teleport(571, 5481.72, 2840.79, 418.67, 0.00)
    player:GossipComplete()
    end
    if (intid == 153) then -- CITADELLE DE LA COURONNE DE GLACE
        player:Teleport(571, 5788.99, 2070.56, 636.06, 3.57)
    player:GossipComplete()
    end
    if (intid == 154) then -- L'ÉPREUVE DU CROISÉ
        player:Teleport(571, 8515.63, 734.76, 558.56, 1.57)
    player:GossipComplete()
    end
    if (intid == 155) then -- L'OEIL DE L'ÉTERNITÉ
        player:Teleport(571, 3867.09, 6985.80, 153.33, 5.80)
    player:GossipComplete()
    end
    --if (intid == 156) then -- LA SALLE CRAMOISIE (ICC)
        --player:Teleport(571, 5791.22, 2071.98, 636.06, 3.60)
    --player:GossipComplete()
    --end
    --if (intid == 157) then -- LABORATOIRE DES DÉSOPILANTES ATROCITÉS ALCHIMIQUES DE PUTRICIDE (ICC)
        --player:Teleport(571, 5791.22, 2071.98, 636.06, 3.60)
    --player:GossipComplete()
    --end
    --if (intid == 158) then -- LE REPAIRE DE LA REINE DU GIVRE (ICC)
        --player:Teleport(571, 5791.22, 2071.98, 636.06, 3.60)
    --player:GossipComplete()
    --end
    --if (intid == 159) then -- LE SANCTUM DE SANG (ICC)
        --player:Teleport(571, 5791.22, 2071.98, 636.06, 3.60)
    --player:GossipComplete()
    --end
    if (intid == 160) then -- LE SANCTUM OBSIDIEN
        player:Teleport(571, 3448.96, 261.27, -110.29, 3.23)
    player:GossipComplete()
    end
    if (intid == 161) then -- LE SANCTUM RUBIS
        player:Teleport(571, 3603.95, 192.52, -111.11, 5.27)
    player:GossipComplete()
    end
    --if (intid == 162) then -- LE TRÔNE DE GLACE (ICC)
        --player:Teleport(571, 5791.22, 2071.98, 636.06, 3.60)
    --player:GossipComplete()
    --end
    if (intid == 163) then -- NAXXRAMAS
        player:Teleport(571, 3668.81, -1267.71, 243.50, 2.17)
    player:GossipComplete()
    end
    if (intid == 164) then -- ULDUAR
        player:Teleport(571, 9345.48, -1114.88, 1245.08, 6.26)
    player:GossipComplete()
    end
	if (intid == 165) then -- Onyxia
        player:Teleport(1, -4699.46, -3722.58, 51.5341, 3.71376)
    player:GossipComplete()
    end

    -- DONJONS CUSTOM

    -- RAIDS CUSTOM

end

RegisterCreatureGossipEvent(NpcId, 1, OnGossipHello)
RegisterCreatureGossipEvent(NpcId, 2, OnGossipSelect)
