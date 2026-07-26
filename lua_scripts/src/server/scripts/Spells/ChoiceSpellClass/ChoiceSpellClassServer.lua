-- ============================================================
--  ChoiceSpellClassServer.lua
--  TrinityCore 3.3.5 (Universe) — Eluna + AIO
--
--  Systeme de choix libre de sorts pour les 9 classes secondaires.
--  Remplace l'octroi automatique fixe (ancien systeme "1 classe =
--  1 liste de sorts figee"). A la place :
--    - Chaque classe secondaire est un onglet dans une UI unique.
--    - Le joueur debloque des emplacements ("slots") au fil des niveaux.
--    - Il peut remplir ces emplacements avec N'IMPORTE QUELLE aptitude
--      de N'IMPORTE QUEL onglet (melange libre entre classes).
--    - Le respec est libre, immediat et gratuit depuis l'interface.
--
--  Catalogue : toutes les aptitudes ci-dessous ont ete verifiees contre
--  spell.sql (WotLK 3.3.5 frFR) -- vrais IDs joueur (pas de sorts PNJ),
--  vraies chaines de rangs (pas de doublons/IDs corrompus), vrais sorts
--  castables pour les poisons (pas les auras de degats homonymes).
--
--  Persistance : table `character_secondary_spell_choices` (voir le
--  fichier SQL de migration fourni a cote de ce script).
-- ============================================================

local AIO = AIO or require("AIO")

local ChoiceSpellClassHandlers = AIO.AddHandlers("ChoiceSpellClassHandler", {})

-- ------------------------------------------------------------
--  Bilingue frFR/enUS : locale du compte (auth DB), mise en cache
--  au login, meme convention que le reste des systemes bilingues
--  du serveur (Store, WarchiefCommandBoard, Mythic, Netheril, etc.)
-- ------------------------------------------------------------
local LOCALE_FRFR_ID = 2 -- LocaleConstant::LOCALE_frFR (core)
local PlayerLocale = {}  -- PlayerLocale[guidLow] = "frFR" | "enUS"

local function LoadPlayerLocale(player)
    local guidLow = player:GetGUIDLow()
    local locale = "enUS"

    local result = AuthDBQuery(string.format(
        "SELECT locale FROM account WHERE id = %d", player:GetAccountId()
    ))
    if result then
        if result:GetUInt8(0) == LOCALE_FRFR_ID then
            locale = "frFR"
        end
    end

    PlayerLocale[guidLow] = locale
    return locale
end

local function GetLocale(guidLow)
    return PlayerLocale[guidLow] or "enUS"
end

-- Textes des messages de chat (SendBroadcastMessage)
local L = {
    enUS = {
        secondaryOnly     = "|cffFF6060[Spells]|r This system is only available for secondary classes.",
        unknownAbility    = "|cffFF6060[Spells]|r Unknown ability.",
        alreadyChosen     = "|cffFFD700[Spells]|r You have already chosen this ability.",
        slotsFull         = "|cffFF6060[Spells]|r Ability limit reached for your level (%d/%d).",
        abilityLearned    = "|cffFFD700[Spells]|r Ability learned: %s",
        abilityRemoved    = "|cffFFD700[Spells]|r Ability removed: %s",
        nothingToReset    = "|cffFFD700[Spells]|r No abilities to reset.",
        allReset          = "|cffFFD700[Spells]|r All abilities have been reset.",
    },
    frFR = {
        secondaryOnly     = "|cffFF6060[Sorts]|r Ce systeme n'est disponible que pour les classes secondaires.",
        unknownAbility    = "|cffFF6060[Sorts]|r Aptitude inconnue.",
        alreadyChosen     = "|cffFFD700[Sorts]|r Vous avez deja choisi cette aptitude.",
        slotsFull         = "|cffFF6060[Sorts]|r Nombre d'aptitude atteint pour votre niveaux (%d/%d).",
        abilityLearned    = "|cffFFD700[Sorts]|r Aptitude apprise : %s",
        abilityRemoved    = "|cffFFD700[Sorts]|r Aptitude retiree : %s",
        nothingToReset    = "|cffFFD700[Sorts]|r Aucune aptitude a reinitialiser.",
        allReset          = "|cffFFD700[Sorts]|r Toutes les aptitudes ont ete reinitialisees.",
    },
}

-- Nom d'aptitude a afficher dans les messages, selon la locale du joueur
local function AbilityDisplayName(ability, locale)
    if locale == "frFR" then
        return ability.name
    end
    return ability.name_en or ability.name
end

-- ------------------------------------------------------------
--  IDs des 9 classes secondaires (correspondance avec les
--  anciens fichiers ClassSecondary/<Classe>/<Classe>_Spells.lua)
-- ------------------------------------------------------------
local SECONDARY_CLASS_IDS = {
    [12] = true, -- Cavalier
    [15] = true, -- Dompteur
    [17] = true, -- Evoker (Evocateur)
    [18] = true, -- Necromancer
    [19] = true, -- Venomancer
    [20] = true, -- Pyromancer
    [21] = true, -- Chronomancer
    [22] = true, -- Geomancer
    [23] = true, -- RavageurChaos
}

local function IsSecondaryClass(player)
    return SECONDARY_CLASS_IDS[player:GetClass()] == true
end

-- ------------------------------------------------------------
--  Catalogue des aptitudes par classe (genere depuis spell.sql,
--  verifie : pas de sorts PNJ, pas de doublons corrompus, poisons
--  = vrai sort d'enduit d'arme et non l'aura de degats appliquee)
-- ------------------------------------------------------------
local SPELL_CATALOG = {
    Cavalier = {
        { key = "attaque_sournoise", name = "Attaque sournoise", name_en = "Sinister Strike", ranks = { {53,4}, {2589,12}, {2590,20}, {2591,28}, {8721,36}, {11279,44}, {11280,52}, {11281,60}, {26863,68}, {48656,74}, {48657,80} } },
        { key = "attaque_pernicieuse", name = "Attaque pernicieuse", name_en = "Backstab", ranks = { {1752,1}, {1757,6}, {1758,14}, {1759,22}, {1760,30}, {8621,38}, {11293,46}, {11294,54}, {26861,62}, {26862,70}, {48637,76}, {48638,80} } },
        { key = "evisceration", name = "Eviscération", name_en = "Eviscerate", ranks = { {2098,1}, {6760,8}, {6761,16}, {6762,24}, {8623,32}, {8624,40}, {11299,48}, {11300,56}, {26865,64}, {41177,70}, {48667,73}, {48668,79} } },
        { key = "garrot", name = "Garrot", name_en = "Garrote", ranks = { {703,14}, {8631,22}, {8632,30}, {8633,38}, {11289,46}, {11290,54}, {26839,61}, {26884,70}, {48675,75}, {48676,80} } },
        { key = "coup_de_pied", name = "Coup de pied", name_en = "Kick", ranks = { {1766,12}, {1767,26}, {1768,42}, {1769,58}, {38768,69} } },
        { key = "debiter", name = "Débiter", name_en = "Slice and Dice", ranks = { {5171,10}, {6774,42} } },
        { key = "coup_bas", name = "Coup bas", name_en = "Cheap Shot", ranks = { {1833,26} } },
        { key = "camouflage", name = "Camouflage", name_en = "Stealth", ranks = { {1785,20}, {1786,40} } },
        { key = "feinte", name = "Feinte", name_en = "Feint", ranks = { {1966,16}, {6768,28}, {8637,40}, {11303,52}, {25302,60}, {27448,64}, {48658,72}, {48659,78} } },
        { key = "vol_a_la_tire", name = "Vol à la tire", name_en = "Pick Pocket", ranks = { {921,4} } },
        { key = "distraction", name = "Distraction", name_en = "Distract", ranks = { {1725,22} } },
        { key = "embuscade", name = "Embuscade", name_en = "Ambush", ranks = { {8676,18} } },
        { key = "aiguillon_perfide", name = "Aiguillon perfide", name_en = "Kidney Shot", ranks = { {408,30} } },
        { key = "exposer_armure", name = "Exposer l'armure", name_en = "Expose Armor", ranks = { {8647,14} } },
        { key = "rupture", name = "Rupture", name_en = "Rupture", ranks = { {1943,20}, {8639,28}, {8640,36}, {11273,44}, {11274,52}, {11275,60}, {26867,68}, {48671,74}, {48672,79} } },
        { key = "hemorragie", name = "Hémorragie", name_en = "Hemorrhage", ranks = { {16511,30}, {17347,46}, {17348,58}, {26864,70}, {48660,80} } },
        { key = "demantelement", name = "Démantèlement", name_en = "Dismantle", ranks = { {51722,20} } },
        { key = "cape_d_ombre", name = "Cape d'ombre", name_en = "Cloak of Shadows", ranks = { {31224,66}, {39666,70} } },
        { key = "premeditation", name = "Préméditation", name_en = "Premeditation", ranks = { {14183,20} } },
        { key = "danse_de_l_ombre", name = "Danse de l'ombre", name_en = "Shadow Dance", ranks = { {51713,60} } },
        { key = "eventail_de_couteaux", name = "Eventail de couteaux", name_en = "Fan of Knives", ranks = { {51723,80} } },
        { key = "frappe_fantome", name = "Frappe fantôme", name_en = "Ghostly Strike", ranks = { {33925,20} } },
    },
    Chronomancer = {
        { key = "eclair_de_givre", name = "Eclair de givre", name_en = "Frostbolt", ranks = { {116,4}, {205,8}, {837,14}, {7322,20}, {8406,26}, {8407,32}, {8408,38}, {10179,44}, {10180,50}, {10181,56}, {25304,60}, {27071,63}, {27072,69}, {38697,70}, {42841,75}, {42842,79} } },
        { key = "cone_de_froid", name = "Cône de froid", name_en = "Cone of Cold", ranks = { {120,26}, {8492,34}, {10159,42}, {10160,50}, {10161,58}, {27087,65}, {42930,72}, {42931,79} } },
        { key = "blizzard", name = "Blizzard", name_en = "Blizzard", ranks = { {10,20}, {6141,28}, {8427,36}, {10185,44}, {10186,52}, {10187,60}, {27085,68}, {42937,74}, {42938,80} } },
        { key = "barriere_de_glace", name = "Barrière de glace", name_en = "Ice Barrier", ranks = { {11426,40}, {13031,46}, {13032,52}, {13033,58}, {27134,64}, {33405,70}, {43038,75}, {43039,80} } },
        { key = "metamorphose", name = "Métamorphose", name_en = "Polymorph", ranks = { {118,8}, {12824,20}, {12825,40}, {12826,60} } },
        { key = "nova_de_givre", name = "Nova de givre", name_en = "Frost Nova", ranks = { {122,10}, {865,26}, {6131,40}, {10230,54}, {27088,67}, {42917,75} } },
        { key = "contresort", name = "Contresort", name_en = "Counterspell", ranks = { {2139,24}, {29961,70} } },
        { key = "javelot_de_glace", name = "Javelot de glace", name_en = "Ice Lance", ranks = { {30455,66}, {42913,72}, {42914,78} } },
        { key = "ralentissement", name = "Ralentissement", name_en = "Slow", ranks = { {10855,28} } },
        { key = "armure_de_givre", name = "Armure de givre", name_en = "Frost Armor", ranks = { {168,1}, {7300,10}, {7301,20}, {31256,70} } },
        { key = "bloc_de_glace", name = "Bloc de glace", name_en = "Ice Block", ranks = { {45438,30} } },
        { key = "veines_glaciales", name = "Veines glaciales", name_en = "Icy Veins", ranks = { {12472,20} } },
    },
    Dompteur = {
        { key = "attaque_du_raptor", name = "Attaque du raptor", name_en = "Raptor Strike", ranks = { {2973,1}, {14260,8}, {14261,16}, {14262,24}, {14263,32}, {14264,40}, {14265,48}, {14266,56}, {27014,63}, {48995,71}, {48996,77} } },
        { key = "morsure_de_serpent", name = "Morsure de serpent", name_en = "Serpent Sting", ranks = { {1978,4}, {13549,10}, {13550,18}, {13551,26}, {13552,34}, {13553,42}, {13554,50}, {13555,58}, {25295,60}, {27016,67}, {49000,73}, {49001,79} } },
        { key = "tir_des_arcanes", name = "Tir des arcanes", name_en = "Arcane Shot", ranks = { {3044,6}, {14281,12}, {14282,20}, {14283,28}, {14284,36}, {14285,44}, {14286,52}, {14287,60}, {27019,69}, {49044,73}, {49045,79} } },
        { key = "fleches_multiples", name = "Flèches multiples", name_en = "Multi-Shot", ranks = { {2643,18}, {14288,30}, {14289,42}, {14290,54}, {25294,60}, {27021,67}, {49047,74}, {49048,80} } },
        { key = "marque_du_chasseur", name = "Marque du chasseur", name_en = "Hunter's Mark", ranks = { {1130,6}, {14323,22}, {14324,40}, {14325,58}, {53338,76} } },
        { key = "guerison_du_familier", name = "Guérison du familier", name_en = "Mend Pet", ranks = { {136,12}, {3111,20}, {3661,28}, {3662,36}, {13542,44}, {13543,52}, {13544,60}, {27046,68}, {48989,74}, {48990,80} } },
        { key = "aspect_du_faucon", name = "Aspect du faucon", name_en = "Aspect of the Hawk", ranks = { {13165,10}, {14318,18}, {14319,28}, {14320,38}, {14321,48}, {14322,58}, {25296,60}, {27044,68} } },
        { key = "visee", name = "Visée", name_en = "Aimed Shot", ranks = { {19434,20}, {20900,28}, {20901,36}, {20902,44}, {20903,52}, {20904,60}, {27065,70}, {49049,75}, {49050,80} } },
        { key = "piege_explosif", name = "Piège explosif", name_en = "Explosive Trap", ranks = { {13813,34}, {14316,44}, {14317,54}, {27025,61}, {49066,71}, {49067,77} } },
        { key = "piege_givrant", name = "Piège givrant", name_en = "Freezing Trap", ranks = { {1499,20}, {14310,40}, {14311,60}, {31933,65} } },
        { key = "tir_tranquillisant", name = "Tir tranquillisant", name_en = "Tranquilizing Shot", ranks = { {19801,60} } },
        { key = "tir_assure", name = "Tir assuré", name_en = "Steady Shot", ranks = { {56641,50} } },
        { key = "trait_de_choc", name = "Trait de choc", name_en = "Concussive Shot", ranks = { {5116,8} } },
        { key = "desengagement", name = "Désengagement", name_en = "Disengage", ranks = { {781,20} } },
        { key = "fleche_de_dispersion", name = "Flèche de dispersion", name_en = "Scatter Shot", ranks = { {19503,15} } },
        { key = "fleche_noire", name = "Flèche noire", name_en = "Black Arrow", ranks = { {3674,50}, {63668,57}, {63669,63}, {63670,69}, {63671,75}, {63672,80} } },
        { key = "aspect_de_la_vipere", name = "Aspect de la vipère", name_en = "Aspect of the Viper", ranks = { {34074,20} } },
        { key = "dissuasion", name = "Dissuasion", name_en = "Deterrence", ranks = { {19263,60} } },
        { key = "piqure_de_scorpide", name = "Piqûre de scorpide", name_en = "Scorpid Sting", ranks = { {3043,22} } },
        { key = "aspect_de_la_meute", name = "Aspect de la meute", name_en = "Aspect of the Pack", ranks = { {13159,40} } },
        { key = "effrayer_une_bete", name = "Effrayer une bête", name_en = "Scare Beast", ranks = { {1513,14}, {14326,30}, {14327,46} } },
    },
    Evoker = {
        { key = "eclair", name = "Eclair", name_en = "Lightning Bolt", ranks = { {403,1}, {529,8}, {548,14}, {915,20}, {943,26}, {6041,32}, {10391,38}, {10392,44}, {15207,50}, {15208,56}, {25448,62}, {25449,67}, {49237,73}, {49238,79} } },
        { key = "chaine_d_eclairs", name = "Chaîne d'éclairs", name_en = "Chain Lightning", ranks = { {421,32}, {930,40}, {2860,48}, {10605,56}, {25439,63}, {25442,70}, {49268,74}, {49269,80} } },
        { key = "projectiles_des_arcanes", name = "Projectiles des arcanes", name_en = "Arcane Missiles", ranks = { {5143,8}, {5144,16}, {5145,24}, {8416,32}, {8417,40}, {10211,48}, {10212,56}, {25345,60}, {27075,63}, {27076,64}, {38699,69}, {38703,70}, {42843,75}, {42845,79} } },
        { key = "explosion_des_arcanes", name = "Explosion des arcanes", name_en = "Arcane Explosion", ranks = { {1449,14}, {8437,22}, {8438,30}, {8439,38}, {10201,46}, {10202,54}, {27080,62}, {27082,70}, {42920,76}, {42921,80} } },
        { key = "bouclier_de_mana", name = "Bouclier de mana", name_en = "Mana Shield", ranks = { {1463,20}, {8494,28}, {8495,36}, {10191,44}, {10192,52}, {10193,60}, {27131,68}, {43019,73}, {43020,79} } },
        { key = "deflagration_des_arcanes", name = "Déflagration des arcanes", name_en = "Arcane Blast", ranks = { {30451,64}, {42894,71}, {42896,76}, {42897,80} } },
        { key = "pouvoir_des_arcanes", name = "Pouvoir des arcanes", name_en = "Arcane Power", ranks = { {12042,70} } },
        { key = "presence_spirituelle", name = "Présence spirituelle", name_en = "Spiritual Presence", ranks = { {12043,64} } },
        { key = "intelligence_des_arcanes", name = "Intelligence des arcanes", name_en = "Arcane Intellect", ranks = { {1459,1} } },
        { key = "lenteur", name = "Lenteur", name_en = "Slow", ranks = { {31589,50} } },
        { key = "transfert", name = "Transfert", name_en = "Transfer", ranks = { {1953,20} } },
        { key = "delivrance_malediction", name = "Délivrance de la malédiction", name_en = "Remove Curse", ranks = { {475,18} } },
    },
    Geomancer = {
        { key = "horion_de_terre", name = "Horion de terre", name_en = "Earth Shock", ranks = { {8042,4}, {8044,8}, {8045,14}, {8046,24}, {10412,36}, {10413,48}, {10414,60}, {25454,69}, {49230,74}, {49231,79} } },
        { key = "arme_croque_roc", name = "Arme Croque-roc", name_en = "Rockbiter Weapon", ranks = { {8017,1}, {8018,8}, {8019,16}, {10399,24} } },
        { key = "epines", name = "Epines", name_en = "Thorns", ranks = { {467,6}, {782,14}, {1075,24}, {8914,34}, {9756,44}, {9910,54}, {26992,64}, {53307,74} } },
        { key = "sarments", name = "Sarments", name_en = "Vines", ranks = { {26989,68}, {53308,78} } },
        { key = "totem_de_force_de_la_terre", name = "Totem de force de la terre", name_en = "Strength of Earth Totem", ranks = { {8075,10}, {8160,24}, {8161,38}, {10442,52}, {25361,60}, {25528,65}, {57622,75}, {58643,80} } },
        { key = "totem_de_magma", name = "Totem de magma", name_en = "Magma Totem", ranks = { {8187,26}, {10579,36}, {10580,46}, {10581,56}, {25550,65}, {58732,73}, {58735,78} } },
        { key = "totem_de_peau_de_pierre", name = "Totem de peau de pierre", name_en = "Stoneskin Totem", ranks = { {8071,4}, {8154,14}, {8155,24}, {10406,34}, {10407,44}, {10408,54}, {25508,63}, {25509,70}, {58751,73}, {58753,78} } },
        { key = "purification", name = "Purification", name_en = "Purge", ranks = { {17550,57} } },
        { key = "seisme", name = "Séisme", name_en = "Earthquake", ranks = { {61882,80} } },
        { key = "horion_de_givre", name = "Horion de givre", name_en = "Frost Shock", ranks = { {8056,20} } },
        { key = "horion_de_flammes", name = "Horion de flammes", name_en = "Flame Shock", ranks = { {8050,10} } },
        { key = "salve_de_guerison", name = "Salve de guérison", name_en = "Chain Heal", ranks = { {1064,40}, {10622,46}, {10623,54}, {25422,61}, {25423,68}, {55458,74}, {55459,80} } },
    },
    Necromancer = {
        { key = "trait_de_l_ombre", name = "Trait de l'ombre", name_en = "Shadow Bolt", ranks = { {686,1}, {695,6}, {705,12}, {1088,20}, {1106,28}, {7641,36}, {11659,44}, {11660,52}, {11661,60}, {27209,69}, {47808,74}, {47809,79} } },
        { key = "mot_de_l_ombre_douleur", name = "Mot de l'ombre : Douleur", name_en = "Shadow Word: Pain", ranks = { {589,4}, {594,10}, {970,18}, {992,26}, {2767,34}, {10892,42}, {10893,50}, {10894,58}, {25367,65}, {25368,70}, {48124,75}, {48125,80} } },
        { key = "drain_d_ame", name = "Drain d'âme", name_en = "Drain Soul", ranks = { {1120,10}, {8288,24}, {8289,38}, {11675,52}, {27217,67}, {47855,77} } },
        { key = "drain_de_vie", name = "Drain de vie", name_en = "Drain Life", ranks = { {689,14}, {699,22}, {709,30}, {7651,38}, {11699,46}, {11700,54}, {27219,62}, {27220,69}, {30412,70}, {47857,78} } },
        { key = "malediction_d_agonie", name = "Malédiction d'agonie", name_en = "Curse of Agony", ranks = { {980,8}, {1014,18}, {6217,28}, {11711,38}, {11712,48}, {11713,58}, {27218,67}, {47863,73}, {47864,79}, {69404,80} } },
        { key = "armure_demoniaque", name = "Armure démoniaque", name_en = "Demon Armor", ranks = { {706,20}, {1086,30}, {11733,40}, {11734,50}, {11735,60}, {27260,70}, {47793,76}, {47889,80} } },
        { key = "voile_mortel", name = "Voile mortel", name_en = "Deathly Veil", ranks = { {6789,42}, {17925,50}, {17926,58}, {27223,68}, {47859,73}, {47860,78} } },
        { key = "fouet_mental", name = "Fouet mental", name_en = "Mind Flay", ranks = { {15407,20}, {17311,28}, {17312,36}, {17313,44}, {17314,52}, {18807,60}, {25387,68}, {48155,74}, {48156,80} } },
        { key = "peste_devorante", name = "Peste dévorante", name_en = "Devouring Plague", ranks = { {2944,20}, {19276,28}, {19277,36}, {19278,44}, {19279,52}, {19280,60}, {25467,68}, {48299,73}, {48300,79} } },
        { key = "toucher_vampirique", name = "Toucher vampirique", name_en = "Vampiric Touch", ranks = { {34914,50}, {34916,60}, {34917,70}, {48159,75}, {48160,80} } },
        { key = "mot_de_l_ombre_mort", name = "Mot de l'ombre : Mort", name_en = "Shadow Word: Death", ranks = { {32379,62}, {32996,70}, {48157,75}, {48158,80} } },
        { key = "pacte_noir", name = "Pacte noir", name_en = "Dark Pact", ranks = { {18220,40}, {18937,50}, {18938,60}, {27265,70}, {59092,80} } },
        { key = "malediction_de_faiblesse", name = "Malédiction de faiblesse", name_en = "Curse of Weakness", ranks = { {702,4}, {1108,12}, {6205,22}, {7646,32}, {11707,42}, {11708,52}, {27224,61}, {30909,69}, {50511,71} } },
        { key = "peur", name = "Peur", name_en = "Fear", ranks = { {5782,16} } },
        { key = "malediction_des_elements", name = "Malédiction des éléments", name_en = "Curse of the Elements", ranks = { {1490,20} } },
        { key = "malediction_funeste", name = "Malédiction funeste", name_en = "Curse of Doom", ranks = { {603,24} } },
        { key = "hurlement_de_terreur", name = "Hurlement de terreur", name_en = "Howl of Terror", ranks = { {5484,30} } },
        { key = "controle_mental", name = "Contrôle mental", name_en = "Mind Control", ranks = { {605,40} } },
        { key = "furie_de_l_ombre", name = "Furie de l'ombre", name_en = "Shadowfury", ranks = { {30283,45} } },
        { key = "lien_spirituel", name = "Lien spirituel", name_en = "Spirit Link", ranks = { {19028,50} } },
        { key = "carapace_anti_magie", name = "Carapace anti-magie", name_en = "Anti-Magic Shell", ranks = { {48707,55} } },
        { key = "bouclier_d_os", name = "Bouclier d'os", name_en = "Bone Shield", ranks = { {49222,58} } },
        { key = "froid_devorant", name = "Froid dévorant", name_en = "Devouring Cold", ranks = { {49203,60} } },
        { key = "poigne_de_la_mort", name = "Poigne de la mort", name_en = "Death Grip", ranks = { {49576,60} } },
        { key = "changeliche", name = "Changeliche", name_en = "Lichborne", ranks = { {49039,62} } },
        { key = "chancre_impie", name = "Chancre impie", name_en = "Unholy Blight", ranks = { {49194,64} } },
        { key = "sang_vampirique", name = "Sang vampirique", name_en = "Vampiric Blood", ranks = { {55233,66} } },
        { key = "zone_anti_magie", name = "Zone anti-magie", name_en = "Anti-Magic Zone", ranks = { {51052,68} } },
        { key = "armee_des_morts", name = "Armée des morts", name_en = "Army of the Dead", ranks = { {42650,70} } },
        { key = "invocation_d_une_gargouille", name = "Invocation d'une gargouille", name_en = "Summon Gargoyle", ranks = { {49206,75} } },
        { key = "frappe_du_fleau", name = "Frappe du Fléau", name_en = "Scourge Strike", ranks = { {55090,76} } },
        { key = "frappe_de_peste", name = "Frappe de peste", name_en = "Plague Strike", ranks = { {45462,76} } },
        { key = "toucher_de_glace", name = "Toucher de glace", name_en = "Icy Touch", ranks = { {45477,77} } },
        { key = "mort_et_decomposition", name = "Mort et décomposition", name_en = "Death and Decay", ranks = { {43265,78} } },
    },
    Pyromancer = {
        { key = "boule_de_feu", name = "Boule de feu", name_en = "Fireball", ranks = { {133,1}, {143,6}, {145,12}, {3140,18}, {8400,24}, {8401,30}, {8402,36}, {10148,42}, {10149,48}, {10150,54}, {10151,60}, {27070,66}, {38692,70}, {42832,74}, {42833,78}, {42834,82} } },
        { key = "trait_de_feu", name = "Trait de feu", name_en = "Fire Bolt", ranks = { {2136,6}, {2137,14}, {2138,22}, {8412,30}, {8413,38}, {10197,46}, {10199,54}, {27078,61}, {27079,70}, {42872,74}, {42873,80} } },
        { key = "brulure", name = "Brûlure", name_en = "Scorch", ranks = { {2948,22}, {8444,28}, {8445,34}, {8446,40}, {10205,46}, {10206,52}, {10207,58}, {27073,65}, {27074,70}, {42858,73}, {42859,78} } },
        { key = "choc_de_flammes", name = "Choc de flammes", name_en = "Flame Shock", ranks = { {2120,16}, {2121,24}, {8422,32}, {8423,40}, {10215,48}, {10216,56}, {27086,64}, {42925,72}, {42926,79} } },
        { key = "explosion_pyrotechnique", name = "Explosion pyrotechnique", name_en = "Pyrotechnic Explosion", ranks = { {11366,20}, {12505,24}, {12522,30}, {12523,36}, {12524,42}, {12525,48}, {12526,54}, {18809,60}, {27132,66}, {33938,70}, {42890,73}, {42891,77} } },
        { key = "bombe_vivante", name = "Bombe vivante", name_en = "Living Bomb", ranks = { {44457,60}, {55359,70}, {55360,80} } },
        { key = "souffle_du_dragon", name = "Souffle du dragon", name_en = "Dragon's Breath", ranks = { {31661,50}, {33041,56}, {33042,64}, {33043,70}, {42949,75}, {42950,80} } },
        { key = "combustion", name = "Combustion", name_en = "Combustion", ranks = { {11129,40} } },
        { key = "immolation", name = "Immolation", name_en = "Immolate", ranks = { {348,1}, {707,10}, {1094,20}, {2941,30}, {11665,40}, {11667,50}, {11668,60}, {27215,69}, {47810,75}, {47811,80} } },
        { key = "vague_explosive", name = "Vague explosive", name_en = "Explosive Wave", ranks = { {11113,30} } },
        { key = "gardien_de_feu", name = "Gardien de feu", name_en = "Fire Ward", ranks = { {543,20} } },
        { key = "armure_fournaise", name = "Armure de la fournaise", name_en = "Molten Armor", ranks = { {30482,62} } },
    },
    RavageurChaos = {
        { key = "frappe_heroique", name = "Frappe héroïque", name_en = "Heroic Strike", ranks = { {78,1}, {284,8}, {285,16}, {1608,24}, {11564,32}, {11565,40}, {11566,48}, {11567,56}, {25286,60}, {29567,70}, {47449,72}, {47450,76} } },
        { key = "coup_de_tonnerre", name = "Coup de tonnerre", name_en = "Thunder Clap", ranks = { {6343,6}, {8198,18}, {8204,28}, {8205,38}, {11580,48}, {11581,58}, {25264,67}, {47501,73}, {47502,78} } },
        { key = "fracasser_armure", name = "Fracasser armure", name_en = "Sunder Armor", ranks = { {7386,10}, {7405,22}, {8380,34}, {11596,46}, {11597,58}, {25225,67}, {47467,77} } },
        { key = "vengeance", name = "Vengeance", name_en = "Revenge", ranks = { {6572,14}, {6574,24}, {7379,34}, {11600,44}, {11601,54}, {25269,63}, {30357,70}, {57823,80} } },
        { key = "execution", name = "Exécution", name_en = "Execute", ranks = { {5308,24}, {20658,32}, {20660,40}, {20661,48}, {20662,56}, {25234,65}, {25236,70}, {47470,73}, {47471,80} } },
        { key = "cri_de_guerre", name = "Cri de guerre", name_en = "Battle Shout", ranks = { {2048,69}, {47436,78} } },
        { key = "tourbillon", name = "Tourbillon", name_en = "Whirlwind", ranks = { {1680,36} } },
        { key = "represailles", name = "Représailles", name_en = "Retaliation", ranks = { {20240,1} } },
        { key = "charge", name = "Charge", name_en = "Charge", ranks = { {100,4}, {6178,26}, {11578,46}, {29320,70}, {53148,80} } },
        { key = "onde_de_choc", name = "Onde de choc", name_en = "Shockwave", ranks = { {46968,60} } },
        { key = "provocation", name = "Provocation", name_en = "Taunt", ranks = { {26281,60} } },
        { key = "balayage", name = "Balayage", name_en = "Sweep", ranks = { {31279,20}, {53528,32}, {53529,48}, {53532,64}, {53533,80} } },
    },
    Venomancer = {
        { key = "evisceration", name = "Eviscération", name_en = "Eviscerate", ranks = { {2098,1}, {6760,8}, {6761,16}, {6762,24}, {8623,32}, {8624,40}, {11299,48}, {11300,56}, {26865,64}, {41177,70}, {48667,73}, {48668,79} } },
        { key = "garrot", name = "Garrot", name_en = "Garrote", ranks = { {703,14}, {8631,22}, {8632,30}, {8633,38}, {11289,46}, {11290,54}, {26839,61}, {26884,70}, {48675,75}, {48676,80} } },
        { key = "coup_de_pied", name = "Coup de pied", name_en = "Kick", ranks = { {1766,12}, {1767,26}, {1768,42}, {1769,58}, {38768,69} } },
        { key = "poison_mortel", name = "Poison mortel", name_en = "Deadly Poison", ranks = { {2818,30}, {2819,38}, {11353,46}, {11354,54}, {25349,60}, {26967,62}, {27186,70}, {57969,76}, {57970,80} } },
        { key = "poison_instantane", name = "Poison instantané", name_en = "Instant Poison", ranks = { {8679,20}, {8685,28}, {8688,36}, {11335,44}, {11336,52}, {11337,60}, {26890,68}, {57964,73}, {57965,79} } },
        { key = "poison_douloureux", name = "Poison douloureux", name_en = "Wound Poison", ranks = { {13218,32}, {13222,40}, {13223,48}, {13224,56}, {27188,64}, {57974,72}, {57975,78} } },
        { key = "poison_affaiblissant", name = "Poison affaiblissant", name_en = "Weakening Poison", ranks = { {3408,20} } },
        { key = "poison_de_distraction_mentale", name = "Poison de distraction mentale", name_en = "Mind-Numbing Poison", ranks = { {5761,24} } },
        { key = "assommer", name = "Assommer", name_en = "Sap", ranks = { {6770,8} } },
        { key = "attaque_pernicieuse", name = "Attaque pernicieuse", name_en = "Backstab", ranks = { {1752,22} } },
        { key = "evasion", name = "Evasion", name_en = "Evasion", ranks = { {5277,6} } },
        { key = "sprint", name = "Sprint", name_en = "Sprint", ranks = { {2983,10} } },
        { key = "disparition", name = "Disparition", name_en = "Vanish", ranks = { {1856,16} } },
        { key = "cecite", name = "Cécité", name_en = "Blind", ranks = { {2094,34} } },
        { key = "rupture", name = "Rupture", name_en = "Rupture", ranks = { {1943,20}, {8639,28}, {8640,36}, {11273,44}, {11274,52}, {11275,60}, {26867,68}, {48671,74}, {48672,79} } },
        { key = "hemorragie", name = "Hémorragie", name_en = "Hemorrhage", ranks = { {16511,30}, {17347,46}, {17348,58}, {26864,70}, {48660,80} } },
        { key = "demantelement", name = "Démantèlement", name_en = "Dismantle", ranks = { {51722,20} } },
        { key = "cape_d_ombre", name = "Cape d'ombre", name_en = "Cloak of Shadows", ranks = { {31224,66}, {39666,70} } },
        { key = "premeditation", name = "Préméditation", name_en = "Premeditation", ranks = { {14183,20} } },
        { key = "danse_de_l_ombre", name = "Danse de l'ombre", name_en = "Shadow Dance", ranks = { {51713,60} } },
        { key = "eventail_de_couteaux", name = "Eventail de couteaux", name_en = "Fan of Knives", ranks = { {51723,80} } },
        { key = "frappe_fantome", name = "Frappe fantôme", name_en = "Ghostly Strike", ranks = { {33925,20} } },
    },
}

local CLASS_LABELS = {
    Cavalier = "Cavalier",
    Chronomancer = "Chronomancien",
    Dompteur = "Dompteur",
    Evoker = "Evocateur",
    Geomancer = "Geomancien",
    Necromancer = "Necromancien",
    Pyromancer = "Pyromancien",
    RavageurChaos = "Ravageur du Chaos",
    Venomancer = "Empoisonneur",
}

local CLASS_ORDER = { "Cavalier", "Chronomancer", "Dompteur", "Evoker", "Geomancer", "Necromancer", "Pyromancer", "RavageurChaos", "Venomancer" }
-- ------------------------------------------------------------
--  Index rapide : { class_key = { [ability_key] = abilityDef } }
-- ------------------------------------------------------------
local ABILITY_INDEX = {}
for classKey, abilities in pairs(SPELL_CATALOG) do
    ABILITY_INDEX[classKey] = {}
    for _, a in ipairs(abilities) do
        ABILITY_INDEX[classKey][a.key] = a
    end
end

local function FindAbility(classKey, abilityKey)
    local byClass = ABILITY_INDEX[classKey]
    if not byClass then return nil end
    return byClass[abilityKey]
end

-- ------------------------------------------------------------
--  Sorts utilitaires accordes gratuitement a toute classe
--  secondaire (pas un "choix", juste un petit confort de jeu) :
--  Invocation de nourriture / d'eau.
-- ------------------------------------------------------------
local UTILITY_SPELLS = { 587, 5504 }

-- ------------------------------------------------------------
--  Nombre d'emplacements debloques selon le niveau du joueur.
--  FIX (retour joueur) : l'ancienne formule (1 + un emplacement
--  tous les 4 niveaux) etait trop restrictive et declenchait
--  "Aucun emplacement libre" bien trop tot. Desormais 1 emplacement
--  PAR niveau (donc jusqu'a 80 emplacements a niveau max), largement
--  au-dessus du plus gros catalogue (Necromancien, ~35 aptitudes) :
--  choix quasi totalement libre en fin de progression.
-- ------------------------------------------------------------
local function GetMaxSlots(level)
    return level
end

-- ------------------------------------------------------------
--  Acces base de donnees (characters DB)
-- ------------------------------------------------------------
local function LoadChoices(guid)
    local choices = {}
    local result = CharDBQuery(
        "SELECT class_key, ability_key FROM character_secondary_spell_choices " ..
        "WHERE guid = " .. guid
    )
    if result then
        repeat
            table.insert(choices, {
                classKey   = result:GetString(0),
                abilityKey = result:GetString(1),
            })
        until not result:NextRow()
    end
    return choices
end

local function SaveChoice(guid, classKey, abilityKey)
    CharDBExecute(
        "INSERT IGNORE INTO character_secondary_spell_choices (guid, class_key, ability_key) VALUES (" ..
        guid .. ", '" .. classKey .. "', '" .. abilityKey .. "')"
    )
end

local function DeleteChoice(guid, classKey, abilityKey)
    CharDBExecute(
        "DELETE FROM character_secondary_spell_choices WHERE guid = " .. guid ..
        " AND class_key = '" .. classKey .. "' AND ability_key = '" .. abilityKey .. "'"
    )
end

-- ------------------------------------------------------------
--  Octroi / retrait des sorts d'une aptitude
-- ------------------------------------------------------------

-- Apprend tous les rangs de l'aptitude dont le niveau requis est
-- atteint par le joueur (les rangs plus eleves seront appris plus
-- tard automatiquement, via OnLevelChange).
local function GrantAbilityRanksUpToLevel(player, ability, level)
    for _, rank in ipairs(ability.ranks) do
        local spellId, reqLevel = rank[1], rank[2]
        if reqLevel <= level and not player:HasSpell(spellId) then
            player:LearnSpell(spellId)
        end
    end
end

-- Desapprend TOUS les rangs connus de l'aptitude (respec).
local function RevokeAbility(player, ability)
    for _, rank in ipairs(ability.ranks) do
        local spellId = rank[1]
        if player:HasSpell(spellId) then
            player:RemoveSpell(spellId)
        end
    end
end

local function GrantUtilitySpells(player)
    for _, spellId in ipairs(UTILITY_SPELLS) do
        if not player:HasSpell(spellId) then
            player:LearnSpell(spellId)
        end
    end
end

-- ------------------------------------------------------------
--  Envoie au client l'etat courant (emplacements + choix)
-- ------------------------------------------------------------
local function SendState(player)
    local guid = player:GetGUIDLow()
    local level = player:GetLevel()
    local choices = LoadChoices(guid)

    local maxSlots = GetMaxSlots(level)
    local usedSlots = #choices

    -- Serialise en une liste plate "classKey|abilityKey" pour eviter
    -- de depasser le nombre d'arguments AIO avec des sous-tables.
    local flat = {}
    for _, c in ipairs(choices) do
        table.insert(flat, c.classKey .. "|" .. c.abilityKey)
    end

    AIO.Handle(player, "ChoiceSpellClassHandler", "SyncState", maxSlots, usedSlots, unpack(flat))
end

-- ------------------------------------------------------------
--  Handler AIO : le joueur ouvre l'interface -> on lui envoie
--  son etat courant (le catalogue lui-meme est deja embarque
--  cote client, pas besoin de le transmettre).
-- ------------------------------------------------------------
function ChoiceSpellClassHandlers.RequestState(player)
    local locale = GetLocale(player:GetGUIDLow())
    if not IsSecondaryClass(player) then
        player:SendBroadcastMessage(L[locale].secondaryOnly)
        return
    end
    SendState(player)
end

-- ------------------------------------------------------------
--  Handler AIO : choisir une aptitude dans un emplacement libre
-- ------------------------------------------------------------
function ChoiceSpellClassHandlers.ChooseAbility(player, classKey, abilityKey)
    if not IsSecondaryClass(player) then return end
    if not classKey or not abilityKey then return end

    local guid = player:GetGUIDLow()
    local locale = GetLocale(guid)

    local ability = FindAbility(classKey, abilityKey)
    if not ability then
        player:SendBroadcastMessage(L[locale].unknownAbility)
        return
    end

    local level = player:GetLevel()
    local choices = LoadChoices(guid)

    -- Deja choisie ?
    for _, c in ipairs(choices) do
        if c.classKey == classKey and c.abilityKey == abilityKey then
            player:SendBroadcastMessage(L[locale].alreadyChosen)
            SendState(player)
            return
        end
    end

    local maxSlots = GetMaxSlots(level)
    if #choices >= maxSlots then
        player:SendBroadcastMessage(string.format(L[locale].slotsFull, #choices, maxSlots))
        SendState(player)
        return
    end

    SaveChoice(guid, classKey, abilityKey)
    GrantAbilityRanksUpToLevel(player, ability, level)
    player:SendBroadcastMessage(string.format(L[locale].abilityLearned, AbilityDisplayName(ability, locale)))
    SendState(player)
end

-- ------------------------------------------------------------
--  Handler AIO : retirer une aptitude (respec libre et gratuit)
-- ------------------------------------------------------------
function ChoiceSpellClassHandlers.RemoveAbility(player, classKey, abilityKey)
    if not IsSecondaryClass(player) then return end
    if not classKey or not abilityKey then return end

    local ability = FindAbility(classKey, abilityKey)
    if not ability then return end

    local guid = player:GetGUIDLow()
    local locale = GetLocale(guid)
    DeleteChoice(guid, classKey, abilityKey)
    RevokeAbility(player, ability)
    player:SendBroadcastMessage(string.format(L[locale].abilityRemoved, AbilityDisplayName(ability, locale)))
    SendState(player)
end

-- ------------------------------------------------------------
--  Handler AIO : reinitialisation complete (retire TOUTES les
--  aptitudes choisies d'un coup, gratuit et instantane comme le
--  reste du respec de ce systeme).
-- ------------------------------------------------------------
function ChoiceSpellClassHandlers.ResetAll(player)
    if not IsSecondaryClass(player) then return end

    local guid = player:GetGUIDLow()
    local locale = GetLocale(guid)
    local choices = LoadChoices(guid)
    if #choices == 0 then
        player:SendBroadcastMessage(L[locale].nothingToReset)
        return
    end

    for _, c in ipairs(choices) do
        local ability = FindAbility(c.classKey, c.abilityKey)
        if ability then
            RevokeAbility(player, ability)
        end
        DeleteChoice(guid, c.classKey, c.abilityKey)
    end

    player:SendBroadcastMessage(L[locale].allReset)
    SendState(player)
end

-- ------------------------------------------------------------
--  Login : charge la locale du compte, les choix existants et
--  (re)donne les sorts dont le niveau requis est deja atteint
--  (filet de securite, couvre par exemple un niveau change
--  hors-jeu / GM).
-- ------------------------------------------------------------
local function OnLogin(event, player)
    LoadPlayerLocale(player)

    if not IsSecondaryClass(player) then return end

    GrantUtilitySpells(player)

    local level = player:GetLevel()
    local choices = LoadChoices(player:GetGUIDLow())
    for _, c in ipairs(choices) do
        local ability = FindAbility(c.classKey, c.abilityKey)
        if ability then
            GrantAbilityRanksUpToLevel(player, ability, level)
        end
    end
end

-- ------------------------------------------------------------
--  Logout : libere le cache de locale (evite une fuite memoire
--  sur un serveur qui tourne longtemps).
-- ------------------------------------------------------------
local function OnLogout(event, player)
    PlayerLocale[player:GetGUIDLow()] = nil
end

-- ------------------------------------------------------------
--  Level up : accorde les nouveaux rangs des aptitudes deja
--  choisies (le nombre d'emplacements augmente aussi, mais ca
--  ne necessite aucune action serveur -- le joueur verra juste
--  un emplacement libre de plus la prochaine fois qu'il ouvre
--  l'interface).
-- ------------------------------------------------------------
local function OnLevelChange(event, player, oldLevel)
    if not IsSecondaryClass(player) then return end

    local level = player:GetLevel()
    local choices = LoadChoices(player:GetGUIDLow())
    for _, c in ipairs(choices) do
        local ability = FindAbility(c.classKey, c.abilityKey)
        if ability then
            GrantAbilityRanksUpToLevel(player, ability, level)
        end
    end
end

RegisterPlayerEvent(3,  OnLogin)
RegisterPlayerEvent(4,  OnLogout)
RegisterPlayerEvent(13, OnLevelChange)
