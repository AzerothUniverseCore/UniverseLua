local AIO = AIO or require("AIO")

local ChoiceSpellClassHandlers = AIO.AddHandlers("ChoiceSpellClassHandler", {})

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

local SPELL_CATALOG = {
    Cavalier = {
        { key = "attaque_sournoise", name = "Attaque sournoise", ranks = { {53,4}, {2589,12}, {2590,20}, {2591,28}, {8721,36}, {11279,44}, {11280,52}, {11281,60}, {26863,68}, {48656,74}, {48657,80} } },
        { key = "attaque_pernicieuse", name = "Attaque pernicieuse", ranks = { {1752,1}, {1757,6}, {1758,14}, {1759,22}, {1760,30}, {8621,38}, {11293,46}, {11294,54}, {26861,62}, {26862,70}, {48637,76}, {48638,80} } },
        { key = "evisceration", name = "Eviscération", ranks = { {2098,1}, {6760,8}, {6761,16}, {6762,24}, {8623,32}, {8624,40}, {11299,48}, {11300,56}, {26865,64}, {41177,70}, {48667,73}, {48668,79} } },
        { key = "garrot", name = "Garrot", ranks = { {703,14}, {8631,22}, {8632,30}, {8633,38}, {11289,46}, {11290,54}, {26839,61}, {26884,70}, {48675,75}, {48676,80} } },
        { key = "coup_de_pied", name = "Coup de pied", ranks = { {1766,12}, {1767,26}, {1768,42}, {1769,58}, {38768,69} } },
        { key = "debiter", name = "Débiter", ranks = { {5171,10}, {6774,42} } },
        { key = "coup_bas", name = "Coup bas", ranks = { {1833,26} } },
        { key = "camouflage", name = "Camouflage", ranks = { {1785,20}, {1786,40} } },
        { key = "feinte", name = "Feinte", ranks = { {1966,16}, {6768,28}, {8637,40}, {11303,52}, {25302,60}, {27448,64}, {48658,72}, {48659,78} } },
        { key = "vol_a_la_tire", name = "Vol à la tire", ranks = { {921,4} } },
        { key = "distraction", name = "Distraction", ranks = { {1725,22} } },
        { key = "embuscade", name = "Embuscade", ranks = { {8676,18} } },
        { key = "aiguillon_perfide", name = "Aiguillon perfide", ranks = { {408,30} } },
        { key = "exposer_armure", name = "Exposer l'armure", ranks = { {8647,14} } },
        { key = "rupture", name = "Rupture", ranks = { {1943,20}, {8639,28}, {8640,36}, {11273,44}, {11274,52}, {11275,60}, {26867,68}, {48671,74}, {48672,79} } },
        { key = "hemorragie", name = "Hémorragie", ranks = { {16511,30}, {17347,46}, {17348,58}, {26864,70}, {48660,80} } },
        { key = "demantelement", name = "Démantèlement", ranks = { {51722,20} } },
        { key = "cape_d_ombre", name = "Cape d'ombre", ranks = { {31224,66}, {39666,70} } },
        { key = "premeditation", name = "Préméditation", ranks = { {14183,20} } },
        { key = "danse_de_l_ombre", name = "Danse de l'ombre", ranks = { {51713,60} } },
        { key = "eventail_de_couteaux", name = "Eventail de couteaux", ranks = { {51723,80} } },
        { key = "frappe_fantome", name = "Frappe fantôme", ranks = { {33925,20} } },
    },
    Chronomancer = {
        { key = "eclair_de_givre", name = "Eclair de givre", ranks = { {116,4}, {205,8}, {837,14}, {7322,20}, {8406,26}, {8407,32}, {8408,38}, {10179,44}, {10180,50}, {10181,56}, {25304,60}, {27071,63}, {27072,69}, {38697,70}, {42841,75}, {42842,79} } },
        { key = "cone_de_froid", name = "Cône de froid", ranks = { {120,26}, {8492,34}, {10159,42}, {10160,50}, {10161,58}, {27087,65}, {42930,72}, {42931,79} } },
        { key = "blizzard", name = "Blizzard", ranks = { {10,20}, {6141,28}, {8427,36}, {10185,44}, {10186,52}, {10187,60}, {27085,68}, {42937,74}, {42938,80} } },
        { key = "barriere_de_glace", name = "Barrière de glace", ranks = { {11426,40}, {13031,46}, {13032,52}, {13033,58}, {27134,64}, {33405,70}, {43038,75}, {43039,80} } },
        { key = "metamorphose", name = "Métamorphose", ranks = { {118,8}, {12824,20}, {12825,40}, {12826,60} } },
        { key = "nova_de_givre", name = "Nova de givre", ranks = { {122,10}, {865,26}, {6131,40}, {10230,54}, {27088,67}, {42917,75} } },
        { key = "contresort", name = "Contresort", ranks = { {2139,24}, {29961,70} } },
        { key = "javelot_de_glace", name = "Javelot de glace", ranks = { {30455,66}, {42913,72}, {42914,78} } },
        { key = "ralentissement", name = "Ralentissement", ranks = { {10855,28} } },
        { key = "armure_de_givre", name = "Armure de givre", ranks = { {168,1}, {7300,10}, {7301,20}, {31256,70} } },
        { key = "bloc_de_glace", name = "Bloc de glace", ranks = { {45438,30} } },
        { key = "veines_glaciales", name = "Veines glaciales", ranks = { {12472,20} } },
    },
    Dompteur = {
        { key = "attaque_du_raptor", name = "Attaque du raptor", ranks = { {2973,1}, {14260,8}, {14261,16}, {14262,24}, {14263,32}, {14264,40}, {14265,48}, {14266,56}, {27014,63}, {48995,71}, {48996,77} } },
        { key = "morsure_de_serpent", name = "Morsure de serpent", ranks = { {1978,4}, {13549,10}, {13550,18}, {13551,26}, {13552,34}, {13553,42}, {13554,50}, {13555,58}, {25295,60}, {27016,67}, {49000,73}, {49001,79} } },
        { key = "tir_des_arcanes", name = "Tir des arcanes", ranks = { {3044,6}, {14281,12}, {14282,20}, {14283,28}, {14284,36}, {14285,44}, {14286,52}, {14287,60}, {27019,69}, {49044,73}, {49045,79} } },
        { key = "fleches_multiples", name = "Flèches multiples", ranks = { {2643,18}, {14288,30}, {14289,42}, {14290,54}, {25294,60}, {27021,67}, {49047,74}, {49048,80} } },
        { key = "marque_du_chasseur", name = "Marque du chasseur", ranks = { {1130,6}, {14323,22}, {14324,40}, {14325,58}, {53338,76} } },
        { key = "guerison_du_familier", name = "Guérison du familier", ranks = { {136,12}, {3111,20}, {3661,28}, {3662,36}, {13542,44}, {13543,52}, {13544,60}, {27046,68}, {48989,74}, {48990,80} } },
        { key = "aspect_du_faucon", name = "Aspect du faucon", ranks = { {13165,10}, {14318,18}, {14319,28}, {14320,38}, {14321,48}, {14322,58}, {25296,60}, {27044,68} } },
        { key = "visee", name = "Visée", ranks = { {19434,20}, {20900,28}, {20901,36}, {20902,44}, {20903,52}, {20904,60}, {27065,70}, {49049,75}, {49050,80} } },
        { key = "piege_explosif", name = "Piège explosif", ranks = { {13813,34}, {14316,44}, {14317,54}, {27025,61}, {49066,71}, {49067,77} } },
        { key = "piege_givrant", name = "Piège givrant", ranks = { {1499,20}, {14310,40}, {14311,60}, {31933,65} } },
        { key = "tir_tranquillisant", name = "Tir tranquillisant", ranks = { {19801,60} } },
        { key = "tir_assure", name = "Tir assuré", ranks = { {56641,50} } },
        { key = "trait_de_choc", name = "Trait de choc", ranks = { {5116,8} } },
        { key = "desengagement", name = "Désengagement", ranks = { {781,20} } },
        { key = "fleche_de_dispersion", name = "Flèche de dispersion", ranks = { {19503,15} } },
        { key = "fleche_noire", name = "Flèche noire", ranks = { {3674,50}, {63668,57}, {63669,63}, {63670,69}, {63671,75}, {63672,80} } },
        { key = "aspect_de_la_vipere", name = "Aspect de la vipère", ranks = { {34074,20} } },
        { key = "dissuasion", name = "Dissuasion", ranks = { {19263,60} } },
        { key = "piqure_de_scorpide", name = "Piqûre de scorpide", ranks = { {3043,22} } },
        { key = "aspect_de_la_meute", name = "Aspect de la meute", ranks = { {13159,40} } },
        { key = "effrayer_une_bete", name = "Effrayer une bête", ranks = { {1513,14}, {14326,30}, {14327,46} } },
    },
    Evoker = {
        { key = "eclair", name = "Eclair", ranks = { {403,1}, {529,8}, {548,14}, {915,20}, {943,26}, {6041,32}, {10391,38}, {10392,44}, {15207,50}, {15208,56}, {25448,62}, {25449,67}, {49237,73}, {49238,79} } },
        { key = "chaine_d_eclairs", name = "Chaîne d'éclairs", ranks = { {421,32}, {930,40}, {2860,48}, {10605,56}, {25439,63}, {25442,70}, {49268,74}, {49269,80} } },
        { key = "projectiles_des_arcanes", name = "Projectiles des arcanes", ranks = { {5143,8}, {5144,16}, {5145,24}, {8416,32}, {8417,40}, {10211,48}, {10212,56}, {25345,60}, {27075,63}, {27076,64}, {38699,69}, {38703,70}, {42843,75}, {42845,79} } },
        { key = "explosion_des_arcanes", name = "Explosion des arcanes", ranks = { {1449,14}, {8437,22}, {8438,30}, {8439,38}, {10201,46}, {10202,54}, {27080,62}, {27082,70}, {42920,76}, {42921,80} } },
        { key = "bouclier_de_mana", name = "Bouclier de mana", ranks = { {1463,20}, {8494,28}, {8495,36}, {10191,44}, {10192,52}, {10193,60}, {27131,68}, {43019,73}, {43020,79} } },
        { key = "deflagration_des_arcanes", name = "Déflagration des arcanes", ranks = { {30451,64}, {42894,71}, {42896,76}, {42897,80} } },
        { key = "pouvoir_des_arcanes", name = "Pouvoir des arcanes", ranks = { {12042,70} } },
        { key = "presence_spirituelle", name = "Présence spirituelle", ranks = { {12043,64} } },
        { key = "intelligence_des_arcanes", name = "Intelligence des arcanes", ranks = { {1459,1} } },
        { key = "lenteur", name = "Lenteur", ranks = { {31589,50} } },
        { key = "transfert", name = "Transfert", ranks = { {1953,20} } },
        { key = "delivrance_malediction", name = "Délivrance de la malédiction", ranks = { {475,18} } },
    },
    Geomancer = {
        { key = "horion_de_terre", name = "Horion de terre", ranks = { {8042,4}, {8044,8}, {8045,14}, {8046,24}, {10412,36}, {10413,48}, {10414,60}, {25454,69}, {49230,74}, {49231,79} } },
        { key = "arme_croque_roc", name = "Arme Croque-roc", ranks = { {8017,1}, {8018,8}, {8019,16}, {10399,24} } },
        { key = "epines", name = "Epines", ranks = { {467,6}, {782,14}, {1075,24}, {8914,34}, {9756,44}, {9910,54}, {26992,64}, {53307,74} } },
        { key = "sarments", name = "Sarments", ranks = { {26989,68}, {53308,78} } },
        { key = "totem_de_force_de_la_terre", name = "Totem de force de la terre", ranks = { {8075,10}, {8160,24}, {8161,38}, {10442,52}, {25361,60}, {25528,65}, {57622,75}, {58643,80} } },
        { key = "totem_de_magma", name = "Totem de magma", ranks = { {8187,26}, {10579,36}, {10580,46}, {10581,56}, {25550,65}, {58732,73}, {58735,78} } },
        { key = "totem_de_peau_de_pierre", name = "Totem de peau de pierre", ranks = { {8071,4}, {8154,14}, {8155,24}, {10406,34}, {10407,44}, {10408,54}, {25508,63}, {25509,70}, {58751,73}, {58753,78} } },
        { key = "purification", name = "Purification", ranks = { {17550,57} } },
        { key = "seisme", name = "Séisme", ranks = { {61882,80} } },
        { key = "horion_de_givre", name = "Horion de givre", ranks = { {8056,20} } },
        { key = "horion_de_flammes", name = "Horion de flammes", ranks = { {8050,10} } },
        { key = "salve_de_guerison", name = "Salve de guérison", ranks = { {1064,40}, {10622,46}, {10623,54}, {25422,61}, {25423,68}, {55458,74}, {55459,80} } },
    },
    Necromancer = {
        { key = "trait_de_l_ombre", name = "Trait de l'ombre", ranks = { {686,1}, {695,6}, {705,12}, {1088,20}, {1106,28}, {7641,36}, {11659,44}, {11660,52}, {11661,60}, {27209,69}, {47808,74}, {47809,79} } },
        { key = "mot_de_l_ombre_douleur", name = "Mot de l'ombre : Douleur", ranks = { {589,4}, {594,10}, {970,18}, {992,26}, {2767,34}, {10892,42}, {10893,50}, {10894,58}, {25367,65}, {25368,70}, {48124,75}, {48125,80} } },
        { key = "drain_d_ame", name = "Drain d'âme", ranks = { {1120,10}, {8288,24}, {8289,38}, {11675,52}, {27217,67}, {47855,77} } },
        { key = "drain_de_vie", name = "Drain de vie", ranks = { {689,14}, {699,22}, {709,30}, {7651,38}, {11699,46}, {11700,54}, {27219,62}, {27220,69}, {30412,70}, {47857,78} } },
        { key = "malediction_d_agonie", name = "Malédiction d'agonie", ranks = { {980,8}, {1014,18}, {6217,28}, {11711,38}, {11712,48}, {11713,58}, {27218,67}, {47863,73}, {47864,79}, {69404,80} } },
        { key = "armure_demoniaque", name = "Armure démoniaque", ranks = { {706,20}, {1086,30}, {11733,40}, {11734,50}, {11735,60}, {27260,70}, {47793,76}, {47889,80} } },
        { key = "voile_mortel", name = "Voile mortel", ranks = { {6789,42}, {17925,50}, {17926,58}, {27223,68}, {47859,73}, {47860,78} } },
        { key = "fouet_mental", name = "Fouet mental", ranks = { {15407,20}, {17311,28}, {17312,36}, {17313,44}, {17314,52}, {18807,60}, {25387,68}, {48155,74}, {48156,80} } },
        { key = "peste_devorante", name = "Peste dévorante", ranks = { {2944,20}, {19276,28}, {19277,36}, {19278,44}, {19279,52}, {19280,60}, {25467,68}, {48299,73}, {48300,79} } },
        { key = "toucher_vampirique", name = "Toucher vampirique", ranks = { {34914,50}, {34916,60}, {34917,70}, {48159,75}, {48160,80} } },
        { key = "mot_de_l_ombre_mort", name = "Mot de l'ombre : Mort", ranks = { {32379,62}, {32996,70}, {48157,75}, {48158,80} } },
        { key = "pacte_noir", name = "Pacte noir", ranks = { {18220,40}, {18937,50}, {18938,60}, {27265,70}, {59092,80} } },
        { key = "malediction_de_faiblesse", name = "Malédiction de faiblesse", ranks = { {702,4}, {1108,12}, {6205,22}, {7646,32}, {11707,42}, {11708,52}, {27224,61}, {30909,69}, {50511,71} } },
        { key = "peur", name = "Peur", ranks = { {5782,16} } },
        { key = "malediction_des_elements", name = "Malédiction des éléments", ranks = { {1490,20} } },
        { key = "malediction_funeste", name = "Malédiction funeste", ranks = { {603,24} } },
        { key = "hurlement_de_terreur", name = "Hurlement de terreur", ranks = { {5484,30} } },
        { key = "controle_mental", name = "Contrôle mental", ranks = { {605,40} } },
        { key = "furie_de_l_ombre", name = "Furie de l'ombre", ranks = { {30283,45} } },
        { key = "lien_spirituel", name = "Lien spirituel", ranks = { {19028,50} } },
        { key = "carapace_anti_magie", name = "Carapace anti-magie", ranks = { {48707,55} } },
        { key = "bouclier_d_os", name = "Bouclier d'os", ranks = { {49222,58} } },
        { key = "froid_devorant", name = "Froid dévorant", ranks = { {49203,60} } },
        { key = "poigne_de_la_mort", name = "Poigne de la mort", ranks = { {49576,60} } },
        { key = "changeliche", name = "Changeliche", ranks = { {49039,62} } },
        { key = "chancre_impie", name = "Chancre impie", ranks = { {49194,64} } },
        { key = "sang_vampirique", name = "Sang vampirique", ranks = { {55233,66} } },
        { key = "zone_anti_magie", name = "Zone anti-magie", ranks = { {51052,68} } },
        { key = "armee_des_morts", name = "Armée des morts", ranks = { {42650,70} } },
        { key = "invocation_d_une_gargouille", name = "Invocation d'une gargouille", ranks = { {49206,75} } },
        { key = "frappe_du_fleau", name = "Frappe du Fléau", ranks = { {55090,76} } },
        { key = "frappe_de_peste", name = "Frappe de peste", ranks = { {45462,76} } },
        { key = "toucher_de_glace", name = "Toucher de glace", ranks = { {45477,77} } },
        { key = "mort_et_decomposition", name = "Mort et décomposition", ranks = { {43265,78} } },
    },
    Pyromancer = {
        { key = "boule_de_feu", name = "Boule de feu", ranks = { {133,1}, {143,6}, {145,12}, {3140,18}, {8400,24}, {8401,30}, {8402,36}, {10148,42}, {10149,48}, {10150,54}, {10151,60}, {27070,66}, {38692,70}, {42832,74}, {42833,78}, {42834,82} } },
        { key = "trait_de_feu", name = "Trait de feu", ranks = { {2136,6}, {2137,14}, {2138,22}, {8412,30}, {8413,38}, {10197,46}, {10199,54}, {27078,61}, {27079,70}, {42872,74}, {42873,80} } },
        { key = "brulure", name = "Brûlure", ranks = { {2948,22}, {8444,28}, {8445,34}, {8446,40}, {10205,46}, {10206,52}, {10207,58}, {27073,65}, {27074,70}, {42858,73}, {42859,78} } },
        { key = "choc_de_flammes", name = "Choc de flammes", ranks = { {2120,16}, {2121,24}, {8422,32}, {8423,40}, {10215,48}, {10216,56}, {27086,64}, {42925,72}, {42926,79} } },
        { key = "explosion_pyrotechnique", name = "Explosion pyrotechnique", ranks = { {11366,20}, {12505,24}, {12522,30}, {12523,36}, {12524,42}, {12525,48}, {12526,54}, {18809,60}, {27132,66}, {33938,70}, {42890,73}, {42891,77} } },
        { key = "bombe_vivante", name = "Bombe vivante", ranks = { {44457,60}, {55359,70}, {55360,80} } },
        { key = "souffle_du_dragon", name = "Souffle du dragon", ranks = { {31661,50}, {33041,56}, {33042,64}, {33043,70}, {42949,75}, {42950,80} } },
        { key = "combustion", name = "Combustion", ranks = { {11129,40} } },
        { key = "immolation", name = "Immolation", ranks = { {348,1}, {707,10}, {1094,20}, {2941,30}, {11665,40}, {11667,50}, {11668,60}, {27215,69}, {47810,75}, {47811,80} } },
        { key = "vague_explosive", name = "Vague explosive", ranks = { {11113,30} } },
        { key = "gardien_de_feu", name = "Gardien de feu", ranks = { {543,20} } },
        { key = "armure_fournaise", name = "Armure de la fournaise", ranks = { {30482,62} } },
    },
    RavageurChaos = {
        { key = "frappe_heroique", name = "Frappe héroïque", ranks = { {78,1}, {284,8}, {285,16}, {1608,24}, {11564,32}, {11565,40}, {11566,48}, {11567,56}, {25286,60}, {29567,70}, {47449,72}, {47450,76} } },
        { key = "coup_de_tonnerre", name = "Coup de tonnerre", ranks = { {6343,6}, {8198,18}, {8204,28}, {8205,38}, {11580,48}, {11581,58}, {25264,67}, {47501,73}, {47502,78} } },
        { key = "fracasser_armure", name = "Fracasser armure", ranks = { {7386,10}, {7405,22}, {8380,34}, {11596,46}, {11597,58}, {25225,67}, {47467,77} } },
        { key = "vengeance", name = "Vengeance", ranks = { {6572,14}, {6574,24}, {7379,34}, {11600,44}, {11601,54}, {25269,63}, {30357,70}, {57823,80} } },
        { key = "execution", name = "Exécution", ranks = { {5308,24}, {20658,32}, {20660,40}, {20661,48}, {20662,56}, {25234,65}, {25236,70}, {47470,73}, {47471,80} } },
        { key = "cri_de_guerre", name = "Cri de guerre", ranks = { {2048,69}, {47436,78} } },
        { key = "tourbillon", name = "Tourbillon", ranks = { {1680,36} } },
        { key = "represailles", name = "Représailles", ranks = { {20240,1} } },
        { key = "charge", name = "Charge", ranks = { {100,4}, {6178,26}, {11578,46}, {29320,70}, {53148,80} } },
        { key = "onde_de_choc", name = "Onde de choc", ranks = { {46968,60} } },
        { key = "provocation", name = "Provocation", ranks = { {26281,60} } },
        { key = "balayage", name = "Balayage", ranks = { {31279,20}, {53528,32}, {53529,48}, {53532,64}, {53533,80} } },
    },
    Venomancer = {
        { key = "evisceration", name = "Eviscération", ranks = { {2098,1}, {6760,8}, {6761,16}, {6762,24}, {8623,32}, {8624,40}, {11299,48}, {11300,56}, {26865,64}, {41177,70}, {48667,73}, {48668,79} } },
        { key = "garrot", name = "Garrot", ranks = { {703,14}, {8631,22}, {8632,30}, {8633,38}, {11289,46}, {11290,54}, {26839,61}, {26884,70}, {48675,75}, {48676,80} } },
        { key = "coup_de_pied", name = "Coup de pied", ranks = { {1766,12}, {1767,26}, {1768,42}, {1769,58}, {38768,69} } },
        { key = "poison_mortel", name = "Poison mortel", ranks = { {2818,30}, {2819,38}, {11353,46}, {11354,54}, {25349,60}, {26967,62}, {27186,70}, {57969,76}, {57970,80} } },
        { key = "poison_instantane", name = "Poison instantané", ranks = { {8679,20}, {8685,28}, {8688,36}, {11335,44}, {11336,52}, {11337,60}, {26890,68}, {57964,73}, {57965,79} } },
        { key = "poison_douloureux", name = "Poison douloureux", ranks = { {13218,32}, {13222,40}, {13223,48}, {13224,56}, {27188,64}, {57974,72}, {57975,78} } },
        { key = "poison_affaiblissant", name = "Poison affaiblissant", ranks = { {3408,20} } },
        { key = "poison_de_distraction_mentale", name = "Poison de distraction mentale", ranks = { {5761,24} } },
        { key = "assommer", name = "Assommer", ranks = { {6770,8} } },
        { key = "attaque_pernicieuse", name = "Attaque pernicieuse", ranks = { {1752,22} } },
        { key = "evasion", name = "Evasion", ranks = { {5277,6} } },
        { key = "sprint", name = "Sprint", ranks = { {2983,10} } },
        { key = "disparition", name = "Disparition", ranks = { {1856,16} } },
        { key = "cecite", name = "Cécité", ranks = { {2094,34} } },
        { key = "rupture", name = "Rupture", ranks = { {1943,20}, {8639,28}, {8640,36}, {11273,44}, {11274,52}, {11275,60}, {26867,68}, {48671,74}, {48672,79} } },
        { key = "hemorragie", name = "Hémorragie", ranks = { {16511,30}, {17347,46}, {17348,58}, {26864,70}, {48660,80} } },
        { key = "demantelement", name = "Démantèlement", ranks = { {51722,20} } },
        { key = "cape_d_ombre", name = "Cape d'ombre", ranks = { {31224,66}, {39666,70} } },
        { key = "premeditation", name = "Préméditation", ranks = { {14183,20} } },
        { key = "danse_de_l_ombre", name = "Danse de l'ombre", ranks = { {51713,60} } },
        { key = "eventail_de_couteaux", name = "Eventail de couteaux", ranks = { {51723,80} } },
        { key = "frappe_fantome", name = "Frappe fantôme", ranks = { {33925,20} } },
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

local UTILITY_SPELLS = { 587, 5504 }

local function GetMaxSlots(level)
    return level
end

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

local function GrantAbilityRanksUpToLevel(player, ability, level)
    for _, rank in ipairs(ability.ranks) do
        local spellId, reqLevel = rank[1], rank[2]
        if reqLevel <= level and not player:HasSpell(spellId) then
            player:LearnSpell(spellId)
        end
    end
end

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

local function SendStateFromChoices(player, choices)
    local level = player:GetLevel()
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

local function SendState(player)
    local guid = player:GetGUIDLow()
    local choices = LoadChoices(guid)
    SendStateFromChoices(player, choices)
end

function ChoiceSpellClassHandlers.RequestState(player)
    if not IsSecondaryClass(player) then
        player:SendBroadcastMessage("|cffFF6060[Sorts]|r Ce systeme n'est disponible que pour les classes secondaires.")
        return
    end
    SendState(player)
end

function ChoiceSpellClassHandlers.ChooseAbility(player, classKey, abilityKey)
    if not IsSecondaryClass(player) then return end
    if not classKey or not abilityKey then return end

    local ability = FindAbility(classKey, abilityKey)
    if not ability then
        player:SendBroadcastMessage("|cffFF6060[Sorts]|r Aptitude inconnue.")
        return
    end

    local guid = player:GetGUIDLow()
    local level = player:GetLevel()
    local choices = LoadChoices(guid)

    for _, c in ipairs(choices) do
        if c.classKey == classKey and c.abilityKey == abilityKey then
            player:SendBroadcastMessage("|cffFFD700[Sorts]|r Vous avez deja choisi cette aptitude.")
            SendStateFromChoices(player, choices)
            return
        end
    end

    local maxSlots = GetMaxSlots(level)
    if #choices >= maxSlots then
        player:SendBroadcastMessage("|cffFF6060[Sorts]|r Aucun emplacement libre (" .. #choices .. "/" .. maxSlots .. ").")
        SendStateFromChoices(player, choices)
        return
    end

    SaveChoice(guid, classKey, abilityKey)
    GrantAbilityRanksUpToLevel(player, ability, level)
    player:SendBroadcastMessage("|cffFFD700[Sorts]|r Aptitude apprise : " .. ability.name)

    -- FIX synchro : on ajoute le nouveau choix a la liste DEJA CHARGEE en
    -- memoire au lieu de re-interroger la base juste apres l'ecriture.
    table.insert(choices, { classKey = classKey, abilityKey = abilityKey })
    SendStateFromChoices(player, choices)
end

function ChoiceSpellClassHandlers.RemoveAbility(player, classKey, abilityKey)
    if not IsSecondaryClass(player) then return end
    if not classKey or not abilityKey then return end

    local ability = FindAbility(classKey, abilityKey)
    if not ability then return end

    local guid = player:GetGUIDLow()

    local choices = LoadChoices(guid)
    for i, c in ipairs(choices) do
        if c.classKey == classKey and c.abilityKey == abilityKey then
            table.remove(choices, i)
            break
        end
    end

    DeleteChoice(guid, classKey, abilityKey)
    RevokeAbility(player, ability)
    player:SendBroadcastMessage("|cffFFD700[Sorts]|r Aptitude retiree : " .. ability.name)
    SendStateFromChoices(player, choices)
end

function ChoiceSpellClassHandlers.ResetAll(player)
    if not IsSecondaryClass(player) then return end

    local guid = player:GetGUIDLow()
    local choices = LoadChoices(guid)
    if #choices == 0 then
        player:SendBroadcastMessage("|cffFFD700[Sorts]|r Aucune aptitude a reinitialiser.")
        return
    end

    for _, c in ipairs(choices) do
        local ability = FindAbility(c.classKey, c.abilityKey)
        if ability then
            RevokeAbility(player, ability)
        end
        DeleteChoice(guid, c.classKey, c.abilityKey)
    end

    player:SendBroadcastMessage("|cffFFD700[Sorts]|r Toutes les aptitudes ont ete reinitialisees.")
	
    SendStateFromChoices(player, {})
end


local function OnLogin(event, player)
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
RegisterPlayerEvent(13, OnLevelChange)
