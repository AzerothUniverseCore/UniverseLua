local ALL_MOUNTS_COMMAND = "allmountgame"
local REQUIRED_RANK = 3

-- Table des ID de sorts pour toutes les montures de Vanilla à WotLK + Azeroth Universe
local mountSpells = {
    458,    -- Brown Horse
    459,    -- Gray Wolf
    468,    -- White Stallion
    32235,  -- Golden Gryphon
    32239,  -- Ebon Gryphon
    33660,  -- Swift Pink Hawkstrider
    59567,  -- Azure Drake
    59650,  -- Black Drake
    61294,  -- Blue Drake
    17481,	-- Rivendare's Deathcharger
    40192,	-- Ashes of Al'ar
    41514,	-- Azure Netherwing Drake
    43688,	-- Amani War Bear
    51412,	-- Big Battle Bear
    58983,	-- Big Blizzard Bear
    59567,	-- Azure Drake
    59568,	-- Blue Drake
    59572,	-- Black Polar Bear
    59650,	-- Black Drake
    59976,	-- Black Proto-Drake
    59996,	-- Blue Proto-Drake
    60025,	-- Albino Drake
    62048,	-- Black Dragonhawk Mount
    63844,	-- Argent Hippogryph
    67466,	-- Argent Warhorse
    71342,	-- Big Love Rocket
    200012,	-- Violet flametalon							#Arcanic
    200013, -- Orange flametalon							#Arcanic
    200014, -- Green flametalon								#Arcanic
    24252,  -- Swift Zulian Tiger
    142757,
    142758,
    142759,
    142760,
    142761,
    142767,
    142768,
    142769,
    142771,
    142772,
    142773,
    142774,
    142775,
    142776,
    142777,
    142778,
    142779,
    142780,
    142781,
    142785,
    142786,
    142787,
    142788,
    142791,
    142792,
    142793,
    --142794,
    142795,
    142796,
    142797,
    142798,
    142799,							
    121820,
    294197,
    150000,
    150001,
    150002,
    150003,
    150004,
    150005,
    150006,
    150007,
    150008,
    150009,
    150010,
    150011,
    150012,
    150013,
    150014,
    150015,
    150020,
    150021,
    150022,
    150023,
    150024,
    150025,
    150030,
    150034,
    150037,
    150050,
    150054,
    150057,
    150058,
    150059,
    150060,
    150125,
    150143,
    150144,
    150145,
    150146,
    150147,
    150246,
    150248,
    150249,
    150505,
    150506,
    150507,
    150508,
    150509,
    150510,
    150511,
    150512,
    150513,
    150514,
    150515,
    150516,
    150517,
    150518,
    150519,
    150520,
    150521,
    150522,
    150523,
    150524,
    150525,
    150526,
    150527,
    150528,
    150529,
    150530,
    150531,
    300525,
    300526,
	636218,
    -- 150169,
    48778, -- AcherusDeathcharger
    60025, -- AlbinoDrake
    43688, -- AmaniWarBear
    16056, -- AncientFrostsaber
    16081, -- ArcticWolf
    66906, -- ArgentCharger
    63844, -- ArgentHippogryph
    66907, -- ArgentWarhorse
    67466, -- ArgentWarhorse
    61230, -- ArmoredBlueWindRider
    60114, -- ArmoredBrownBear
    60116, -- ArmoredBrownBear
    61229, -- ArmoredSnowyGryphon
    40192, -- AshesofAl'ar
    59567, -- AzureDrake
    41514, -- AzureNetherwingDrake
    51412, -- BigBattleBear
    58983, -- BigBlizzardBear
    71342, -- BigLoveRocket
    22719, -- BlackBattlestrider
    59650, -- BlackDrake
    35022, -- BlackHawkstrider
    16055, -- BlackNightsaber
    59976, -- BlackProto-Drake
    25863, -- BlackQirajiBattleTank
    26655, -- BlackQirajiBattleTank
    26656, -- BlackQirajiBattleTank
    17461, -- BlackRam
    64977, -- BlackSkeletalHorse
    470,   -- BlackStallion
    60118, -- BlackWarBear
    60119, -- BlackWarBear
    48027, -- BlackWarElekk
    22718, -- BlackWarKodo
    59785, -- BlackWarMammoth
    59788, -- BlackWarMammoth
    22720, -- BlackWarRam
    22721, -- BlackWarRaptor
    22717, -- BlackWarSteed
    22723, -- BlackWarTiger
    22724, -- BlackWarWolf
    64658, -- BlackWolf
    74856, -- BlazingHippogryph
    72808, -- BloodbathedFrostbroodVanquisher
    61996, -- BlueDragonhawk
    59568, -- BlueDrake
    35020, -- BlueHawkstrider
    10969, -- BlueMechanostrider
    59996, -- BlueProto-Drake
    25953, -- BlueQirajiBattleTank
    39803, -- BlueRidingNetherRay
    17463, -- BlueSkeletalHorse
    64656, -- BlueSkeletalWarhorse
    32244, -- BlueWindRider
    50869, -- BrewfestKodo
    43899, -- BrewfestRam
    59569, -- BronzeDrake
    34406, -- BrownElekk
    18990, -- BrownKodo
    6899,  -- BrownRam
    17464, -- BrownSkeletalHorse
    6654,  -- BrownWolf
    58615, -- BrutalNetherDrake
    75614, -- CelestialSteed
    43927, -- CenarionWarHippogryph
    6648,  -- ChestnutMare
    24576, -- Chromatic Drake
    41515, -- CobaltNetherwingDrake
    39315, -- CobaltRidingTalbuk
    34896, -- CobaltWarTalbuk
    73313, -- CrimsonDeathcharger
    68188, -- Crusader'sBlackWarhorse
    68187, -- Crusader'sWhiteWarhorse
    39316, -- DarkRidingTalbuk
    63635, -- DarkspearRaptor
    34790, -- DarkWarTalbuk
    63637, -- DarnassianNightsaber
    64927, -- DeadlyGladiator'sFrostWyrm
    6653,  -- DireWolf
    32239, -- EbonGryphon
    63639, -- ExodarElekk
    36702, -- FieryWarhorse
    61451, -- FlyingCarpet
    44153, -- FlyingMachine
    63643, -- ForsakenWarhorse
    17460, -- FrostRam
    23509, -- FrostwolfHowler
    75596, -- FrostyFlyingCarpet
    65439, -- FuriousGladiator'sFrostWyrm
    63638, -- GnomereganMechanostrider
    61465, -- GrandBlackWarMammoth
    61467, -- GrandBlackWarMammoth
    61469, -- GrandIceMammoth
    61470, -- GrandIceMammoth
    35710, -- GrayElekk
    18989, -- GrayKodo
    6777,  -- GrayRam
    35713, -- GreatBlueElekk
    49379, -- GreatBrewfestKodo
    23249, -- GreatBrownKodo
    65641, -- GreatGoldenKodo
    23248, -- GreatGrayKodo
    35712, -- GreatGreenElekk
    35714, -- GreatPurpleElekk
    65637, -- GreatRedElekk
    23247, -- GreatWhiteKodo
    18991, -- GreenKodo
    17453, -- GreenMechanostrider
    61294, -- GreenProto-Drake
    26056, -- GreenQirajiBattleTank
    39798, -- GreenRidingNetherRay
    17465, -- GreenSkeletalWarhorse
    32245, -- GreenWindRider
    48025, -- HeadlessHorseman'sMount
    72807, -- IceboundFrostbroodVanquisher
    59797, -- IceMammoth
    59799, -- IceMammoth
    17459, -- IcyBlueMechanostriderModA
    72286, -- Invincible'sReins
    63956, -- IronboundProto-Drake
    63636, -- IronforgeRam
    17450, -- IvoryRaptor
    65917, -- MagicRooster
    61309, -- MagnificentFlyingCarpet
    55531, -- Mechano-Hog
    60424, -- Mekgineer'sChopper
    44744, -- MercilessNetherDrake
    63796, -- Mimiron'sHead
    16084, -- MottledRedRaptor
    66846, -- OchreSkeletalWarhorse
    69395, -- OnyxianDrake
    41513, -- OnyxNetherwingDrake
    63640, -- OrgrimmarWolf
    16082, -- Palomino
    32345, -- PeepthePhoenixMount
    472,   -- Pinto
    60021, -- PlaguedProto-Drake
    35711, -- PurpleElekk
    35018, -- PurpleHawkstrider
    41516, -- PurpleNetherwingDrake
    39801, -- PurpleRidingNetherRay
    23246, -- PurpleSkeletalWarhorse
    66090, -- Quel'doreiSteed
    41252, -- RavenLord
    61997, -- RedDragonhawk
    59570, -- RedDrake
    34795, -- RedHawkstrider
    10873, -- RedMechanostrider
    59961, -- RedProto-Drake
    26054, -- RedQirajiBattleTank
    39800, -- RedRidingNetherRay
    17462, -- RedSkeletalHorse
    22722, -- RedSkeletalWarhorse
    16080, -- RedWolf
    67336, -- RelentlessGladiator'sFrostWyrm
    30174, -- RidingTurtle
    17481, -- Rivendare'sDeathcharger
    63963, -- RustedProto-Drake
    64731, -- SeaTurtle
    66087, -- SilverCovenantHippogryph
    63642, -- SilvermoonHawkstrider
    39802, -- SilverRidingNetherRay
    39317, -- SilverRidingTalbuk
    34898, -- SilverWarTalbuk
    32240, -- SnowyGryphon
    42776, -- SpectralTiger
    10789, -- SpottedFrostsaber
    23510, -- StormpikeBattleCharger
    63232, -- StormwindSteed
    66847, -- StripedDawnsaber
    10793, -- StripedNightsaber
    66088, -- SunreaverDragonhawk
    66091, -- SunreaverHawkstrider
    68057, -- SwiftAllianceSteed
    32242, -- SwiftBlueGryphon
    23241, -- SwiftBlueRaptor
    43900, -- SwiftBrewfestRam
    23238, -- SwiftBrownRam
    23229, -- SwiftBrownSteed
    23250, -- SwiftBrownWolf
    65646, -- SwiftBurgundyWolf
    23221, -- SwiftFrostsaber
    23239, -- SwiftGrayRam
    65640, -- SwiftGraySteed
    23252, -- SwiftGrayWolf
    32290, -- SwiftGreenGryphon
    35025, -- SwiftGreenHawkstrider
    23225, -- SwiftGreenMechanostrider
    32295, -- SwiftGreenWindRider
    68056, -- SwiftHordeWolf
    23219, -- SwiftMistsaber
    65638, -- SwiftMoonsaber
    37015, -- SwiftNetherDrake
    23242, -- SwiftOliveRaptor
    23243, -- SwiftOrangeRaptor
    23227, -- SwiftPalomino
    33660, -- SwiftPinkHawkstrider
    32292, -- SwiftPurpleGryphon
    35027, -- SwiftPurpleHawkstrider
    65644, -- SwiftPurpleRaptor
    32297, -- SwiftPurpleWindRider
    24242, -- SwiftRazzashiRaptor
    32289, -- SwiftRedGryphon
    65639, -- SwiftRedHawkstrider
    32246, -- SwiftRedWindRider
    55164, -- SwiftSpectralGryphon
    42777, -- SwiftSpectralTiger
    23338, -- SwiftStormsaber
    23251, -- SwiftTimberWolf
    65643, -- SwiftVioletRam
    35028, -- SwiftWarstrider
    46628, -- SwiftWhiteHawkstrider
    23223, -- SwiftWhiteMechanostrider
    23240, -- SwiftWhiteRam
    23228, -- SwiftWhiteSteed
    23222, -- SwiftYellowMechanostrider
    32296, -- SwiftYellowWindRider
    49322, -- SwiftZhevra
    24252, -- SwiftZulianTiger
    39318, -- TanRidingTalbuk
    34899, -- TanWarTalbuk
    32243, -- TawnyWindRider
    18992, -- TealKodo
    63641, -- ThunderBluffKodo
    580,   -- TimberWolf
    60002, -- Time-LostProto-Drake
    61425, -- Traveler'sTundraMammoth
    61447, -- Traveler'sTundraMammoth
    44151, -- Turbo-ChargedFlyingMachine
    65642, -- Turbostrider
    10796, -- TurquoiseRaptor
    59571, -- TwilightDrake
    17454, -- UnpaintedMechanostrider
    49193, -- VengefulNetherDrake
    64659, -- VenomhideRavasaur
    41517, -- VeridianNetherwingDrake
    41518, -- VioletNetherwingDrake
    60024, -- VioletProto-Drake
    10799, -- VioletRaptor
    64657, -- WhiteKodo
    15779, -- WhiteMechanostriderModB
    54753, -- WhitePolarBear
    6898,  -- WhiteRam
    39319, -- WhiteRidingTalbuk
    65645, -- WhiteSkeletalWarhorse
    16083, -- WhiteStallion
    34897, -- WhiteWarTalbuk
    54729, -- WingedSteedoftheEbonBlade
    17229, -- WinterspringFrostsaber
    59791, -- WoolyMammoth
    59793, -- WoolyMammoth
    74918, -- WoolyWhiteRhino
    71810, -- WrathfulGladiator'sFrostWyrm
    46197, -- X-51Nether-Rocket
    46199, -- X-51Nether-RocketX-TREME
    75973, -- X-53TouringRocket
    26055, -- YellowQirajiBattleTank
    150534,
    150535,
    150536,
    150537,
    180100,
    180101,
    180102,
    180103,
    180104,
    180105,
    180106,
    180107,
    180108,
    180109,
    180110,
    180111,
    180112,
    180113,
    180114,
    180115,
    180116,
    180117,
    180118,
    180119,
    180120,
    180121,
    180122,
    180123,
    180124,
    180125,
    180126,
    180127,
    180128,
    180129,
    180130,
    180131,
    180132,
    180133,
    180134,
    180135,
    180136,
    180137,
    180138,
    180139,
    180140,
    150305,
    470,	-- Black Stallion					#Alliance
    6896,	-- Black Ram						#Alliance
    10969,	-- Blue Mechanostrider				#Alliance
    16055,	-- Black Nightsaber					#Alliance
    16056,	-- Ancient Frostsaber				#Alliance
    17461,	-- Black Ram						#Alliance
    22717,	-- Black War Steed					#Alliance
    22719,	-- Black Battlestrider				#Alliance
    22720,	-- Black War Ram					#Alliance
    22723,	-- Black War Tiger					#Alliance
    33630,	-- Blue Mechanostrider				#Alliance
    35710,	-- Gray Elekk						#Alliance
    48027,	-- Black War Elekk					#Alliance
    59785,	-- Black War Mammoth				#Alliance
    60114,	-- Armored Brown Bear				#Alliance
    60118,	-- Black War Bear					#Alliance
    61229,	-- Armored Snowy Gryphon			#Alliance
    61996,	-- Blue Dragonhawk					#Alliance
    578,	-- Black Wolf						#Horde
    22718,	-- Black War Kodo					#Horde
    22721,	-- Black War Raptor					#Horde
    22724,	-- Black War Wolf					#Horde
    35020,	-- Blue Hawkstrider					#Horde
    35022,	-- Black Hawkstrider				#Horde
    59788,	-- Black War Mammoth				#Horde
    60116,	-- Armored Brown Bear				#Horde
    60119,	-- Black War Bear					#Horde
    61230,	-- Armored Blue Wind Rider			#Horde
    64658,	-- Black Wolf						#Horde
    64977,	-- Black Skeletal Horse				#Horde
	23214,
	23161,
	8395,
	5784,
	8394,
	34767,
	34769,
	13819,
}

local function LearnAllMounts(player)
    for _, spellId in ipairs(mountSpells) do
        if not player:HasSpell(spellId) then
            player:LearnSpell(spellId)
        end
    end
    player:SendBroadcastMessage("Toutes les montures de Vanilla à WotLK + Azeroth Universe ont été apprises.")
end

local function OnChatCommand(event, player, command)
    if command == ALL_MOUNTS_COMMAND then
        if player:GetGMRank() >= REQUIRED_RANK then
            LearnAllMounts(player)
        else
            player:SendBroadcastMessage("Vous n'avez pas la permission d'utiliser cette commande.")
        end
        return false -- Bloque l'exécution des commandes suivantes
    end
end

RegisterPlayerEvent(42, OnChatCommand)