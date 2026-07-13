local VILLE_PAR_NPC_ID = {
    [68]   = "hurlevent",
    [1976] = "hurlevent",
    [1756] = "hurlevent",
    [5595] = "forgefer",
    [4262] = "darnassus",
    [16733] = "exodar",
    [3296] = "orgrimmar",
    [3084] = "pitons_foudre",
    [36213] = "fossoyeuse",
    [16222] = "lune_argent",
}

local FACTIONS_VILLE = {
    hurlevent = "Alliance",
    forgefer = "Alliance",
    darnassus = "Alliance",
    exodar = "Alliance",
    orgrimmar = "Horde",
    pitons_foudre = "Horde",
    fossoyeuse = "Horde",
    lune_argent = "Horde",
}

local CONFIG_VILLE = {
    hurlevent = {
    responses = {
        ["guerrier"] = "Les maîtres guerriers sont au Centre de commandement dans le Quartier des Anciens. Cherchez Ander Germaine.",
        ["hotel des ventes"] = "L'Hôtel des ventes se trouve dans le Quartier marchand.",
        ["banque"] = "La banque est dans le Quartier marchand, près de l'Hôtel des ventes.",
        ["port de hurlevent"] = "Le Port de Hurlevent se trouve à l'ouest de la Place de la Cathédrale, en suivant la route principale.",
        ["tram des profondeurs"] = "Le Tram des profondeurs est dans le Quartier nain, près des forges.",
        ["auberge"] = "L'auberge principale de la ville est dans le Quartier marchand.",
        ["maitre de griffons"] = "Le maître de griffons est à la tour de vol près de l'entrée du Quartier marchand.",
        ["maitre de guilde"] = "Les services de guilde sont dans le Quartier marchand, côté ouest.",
        ["serrurier"] = "Essayez Benik Boltshead dans le Quartier nain, près des forgerons.",
        ["maitre des ecuries"] = "Le maître des écuries, Jenova Stoneshield, est dans le Quartier nain.",
        ["coiffeur"] = "Le salon de coiffure est dans le Quartier marchand, près de l'Hôtel des ventes.",
        ["salon des officiers"] = "Le Salon des officiers est à l'intérieur de la Salle des Champions, dans le Quartier des Anciens.",
        ["maitre de champ bataille"] = "Les maîtres de champ de bataille sont dans la Salle de guerre au sein du Donjon de Hurlevent.",
        ["alchimie"] = "L'alchimie est enseignée par Lilyssia Nightbreeze à Besoins alchimiques dans le Quartier des mages.",
        ["travail du cuir"] = "Simon Tanner enseigne le travail du cuir à La Cachette protectrice dans le Quartier des Anciens.",
        ["herboristerie"] = "La formation en herboristerie est offerte par Tannysa dans le Quartier des mages.",
        ["minage"] = "Gelman Stonehand enseigne le minage à Minage Stonehand dans le Quartier nain.",
        ["forge"] = "La formation de forgeron est disponible à la forge dans le Quartier nain.",
        ["cuisine"] = "La cuisine est enseignée par Stephen Ryback à la Taverne du Cochon et du Sifflet dans le Quartier des Anciens.",
        ["enchantement"] = "L'enchantement est géré par Lucan Cordell dans le Quartier des mages.",
        ["ingenierie"] = "Les maîtres ingénieurs sont dans le Quartier nain. Demandez Farud ou Lilliam Sparkspindle.",
        ["premiers secours"] = "Angela Leifeld enseigne les premiers secours sur la Place de la Cathédrale.",
        ["peche"] = "La formation en pêche est disponible auprès d'Arnold Leland dans le Quartier marchand près des canaux.",
        ["calligraphie"] = "La calligraphie est enseignée par Catarina Stanford dans le Quartier des mages.",
        ["depecage"] = "Le dépeçage est enseigné par Maris Granger dans le Quartier des Anciens, près des travailleurs du cuir.",
        ["couture"] = "Les maîtres couturiers sont dans le Quartier des mages. Demandez Georgio Bolero ou Jalane Ayrole.",
        ["druide"] = "Sheldras Moontree forme les druides près du Puits de lune dans le Quartier du Parc.",
        ["chasseur"] = "La formation de chasseur est dans le Quartier nain. Cherchez Einris, Ulfir ou Thorfin.",
        ["mage"] = "La formation de mage a lieu dans le Sanctum du mage dans le Quartier des mages.",
        ["paladin"] = "Les maîtres paladins sont sur la Place de la Cathédrale. Grayson Shadowbreaker dirige l'ordre.",
        ["pretre"] = "Les prêtres s'entraînent sur la Place de la Cathédrale et dans le Parc. Cherchez Laurena ou Frère Benjamin.",
        ["voleur"] = "La formation de voleur est dans le bâtiment SI:7 dans le Quartier des Anciens.",
        ["chaman"] = "Farseer Umbrua forme les chamans à l'étage de l'auberge Golden Keg, Quartier nain.",
        ["demoniste"] = "Les démonistes sont formés dans la cave de l'Agneau égorgé, dans le Quartier des mages.",
    }
    },
    forgefer = {
    responses = {
        ["cuisine"] = "La formation en cuisine est au Bronze Kettle dans la Grande forge—demandez Daryl Riknussun.",
        ["minage"] = "La formation en minage est dans le quartier de la Grande forge. Cherchez Geofram Bouldertoe.",
        ["forge"] = "La formation de forgeron se fait à la Grande forge. Les maîtres incluent Groum Stonebeard, Rotgath Stonebeard, Bengus Deepforge ou Ironus Coldsteel.",
        ["enchantement"] = "Visitez Thonys Pillarstone ou Gimble Thistlefuzz à la Grande forge pour les leçons d'enchantement.",
        ["ingenierie"] = "Les maîtres ingénieurs sont à Tinker Town. Demandez Jemma Quikswitch, Trixie Quikswitch ou Springspindle Fizzlegear.",
        ["premiers secours"] = "La formation en premiers secours est disponible auprès de Nissa Firestone dans le bâtiment médical de la Grande forge.",
        ["peche"] = "La formation en pêche est gérée par Grimnur Stonebrand dans la Caverne désolée, près des canaux.",
        ["calligraphie"] = "Les leçons de calligraphie sont données par Elise Brightletter dans la zone des scribes du Quartier des mages.",
        ["depecage"] = "La formation en dépeçage est à la Grande forge. Demandez Balthus Stoneflayer.",
        ["couture"] = "La formation en couture se fait dans la boutique de tailleur de la Grande forge avec Jormund Stonebrow.",
        ["alchimie"] = "L'instruction en alchimie est aux Potions de Berryfizz à Tinker Town, avec Vosur Brakthel ou Tally Berryfizz.",
        ["druide"] = "La formation de druide est dans les Communes, près du Puits de lune.",
        ["chasseur"] = "Les maîtres chasseurs sont situés dans le Quartier militaire. Cherchez Daera Brightspear, Olmin Burningbeard, Regnus Thundergranite ou Ulbrek Firehand.",
        ["mage"] = "La formation de mage se fait dans la Salle des mystères du Quartier mystique. Les maîtres incluent Dink, Bink, Juli Stormkettle et Milstaff Stormeye.",
        ["paladin"] = "Les maîtres paladins sont dans le Quartier mystique. Voyez Beldruk Doombrow ou Brandur Ironhammer.",
        ["pretre"] = "La formation de prêtre est offerte dans le Quartier mystique. Cherchez le Grand prêtre Rohan, Braenna Flintcrag ou Toldren Deepiron.",
        ["voleur"] = "La formation de voleur est dans la Caverne désolée. Les maîtres incluent Hulfdan Blackbeard, Ormyr Flinteye et Fenthwick.",
        ["chaman"] = "La formation de chaman est donnée par Farseer Javad dans la zone de la Grande forge.",
        ["demoniste"] = "Les maîtres démonistes sont dans la Caverne désolée. Demandez Alexander Calder, Briarthorn, Thistleheart ou Keric Smolderblade.",
    }
    },
    darnassus = {
    responses = {
        ["guerrier"]     = "Les maîtres guerriers sont sur la Terrasse des guerriers. Cherchez Sildanair, Arias'ta Bladesinger ou Darnath Bladesinger.",
        ["druide"]       = "Les maîtres druides sont dans l'Enclave cénarienne. Cherchez Fylerian Nightwing, Denatharion, Mathrengyl Bearwalker, Lyros Swiftwind ou Talran of the Wild.",
        ["chasseur"]     = "Les maîtres chasseurs et le maître des familiers Silvaria sont dans la section Chasseurs de l'Enclave cénarienne.",
        ["voleur"]       = "La formation de voleur est dans la Guilde des voleurs souterraine dans l'Enclave cénarienne. Essayez Syurna, Anishar ou Erion Shadewhisper.",
        ["pretre"]       = "Les maîtres prêtres sont dans le Temple de la Lune. Cherchez Astarii Starseeker, Jandria, Lariia ou la Princesse Alathea.",
        ["mage"]         = "La formation de mage est à l'étage du Temple de la Lune. Les maîtres incluent Tarelvir, Dyrhara, Maelir et Myriam Spellwaker, avec la maître des portails Elissa Dumas.",
        ["paladin"]      = "La formation de paladin est également dans le Temple de la Lune—cherchez Rukua.",
        ["demoniste"]    = "La formation de démoniste est près de la zone du temple—Vitus Darkwalker.",
        ["alchimie"]     = "Les maîtres alchimistes Ainethil, Milla Fairancora et Sylvanna Forestmoon sont sur la Terrasse des artisans.",
        ["cuisine"]      = "La formation en cuisine est avec Alegorn sur la Terrasse des artisans.",
        ["premiers secours"] = "La formation en premiers secours est offerte par Dannelor sur la Terrasse des artisans.",
        ["enchantement"] = "La formation en enchantement est dirigée par Lalina Summermoon et Taladan sur la Terrasse des artisans.",
        ["couture"]      = "La couture est enseignée par Me'lynn et Trianna à l'étage de la Terrasse des artisans.",
        ["travail du cuir"] = "La formation en travail du cuir et dépeçage est sur la Terrasse des artisans—demandez Telonis ou Eladriel.",
        ["herboristerie"] = "La formation en herboristerie est dans les Jardins du temple avec Firodren Mooncaller (fournitures par Chardryn).",
        ["minage"]       = "La formation en minage est sur la Terrasse des artisans—cherchez le Contremaître Pernic.",
        ["ingenierie"]   = "La formation en ingénierie est sur la Terrasse des artisans avec Tana Lentner.",
        ["calligraphie"] = "Les leçons de calligraphie sont données par Feyden Darkin sur la Terrasse des artisans.",
        ["joaillerie"]   = "La formation en joaillerie est également sur la Terrasse des artisans—voyez Aessa Silverdew.",
        ["banque"]       = "La banque et les services de guilde sont dans les Jardins du temple, près de l'entrée.",
        ["hotel des ventes"] = "L'Hôtel des ventes est situé sur la Terrasse des marchands, à partir de la Terrasse des artisans.",
        ["auberge"]      = "L'auberge est tenue par Saelienne sur la Terrasse des artisans, près de la zone d'approvisionnement général.",
        ["maitre des ecuries"] = "Le Maître des écuries Alassin est dans l'Enclave cénarienne près de la section des chasseurs.",
        ["maitre de griffons"] = "Le Maître des hippogrifes Leora dessert la zone de vol dans l'Enclave cénarienne.",
        ["maitre de guilde"] = "Les services de guilde et le vendeur de tabards Ellaercia sont sur la Terrasse des artisans aux côtés de Lysheana.",
        ["coiffeur"]     = "Il n'y a pas de salon de coiffure à Darnassus—essayez Hurlevent ou Forgefer.",
        ["maitre de champ bataille"] = "Les maîtres de champ de bataille sont sur la Terrasse des guerriers, près des maîtres guerriers.",
    }
  },
exodar = {
    responses = {
        ["hotel des ventes"]   = "L'Hôtel des ventes est situé dans le Siège du Naaru, dans le hall central.",
        ["banque"]            = "Les services bancaires sont dans le Siège du Naaru, dans le centre. Les marchands incluent Kellag, Jaela et Ossco.",
        ["maitre de griffons"]  = "Le maître de griffons Stephanos dessert les joueurs près du point de vol du Siège du Naaru.",
        ["maitre des ecuries"]   = "Le Maître des écuries Arthaid est au niveau supérieur du centre.",
        ["auberge"]             = "L'auberge est tenue par le Soigneur Breel sur la plateforme d'entrée juste au-dessus de la rampe principale.",
        ["boite aux lettres"]         = "Les boîtes aux lettres sont près de la banque, de l'hôtel des ventes, de la plateforme de l'auberge et près de la zone de vol des griffons.",
        ["maitre de guilde"]    = "Le Maître de guilde Funaam et le vendeur de tabards Issca se tiennent à l'entrée du Niveau des marchands.",
        ["maitre de champ bataille"]    = "Les maîtres de champ de bataille comme Hunara et Liedel le Juste sont dans la Crypte des lumières.",
        ["guerrier"]         = "Les maîtres guerriers Behomat, Kazi et Ahonan se trouvent sur la Terrasse des guerriers au-dessus du Niveau des marchands.",
        ["paladin"]         = "Les maîtres paladins Baatun, Jol et Kavaan enseignent dans la Chapelle de la lumière, à l'intérieur de la Crypte des lumières.",
        ["pretre"]          = "Les maîtres prêtres Izmir, Caedmos et Fallat sont dans la Crypte des lumières.",
        ["mage"]            = "Les maîtres mages comme Edirah, Harnan et Bati sont dans la Crypte des lumières. Lunaraa est la maître des portails.",
        ["voleur"]           = "Le maître voleur Capitaine stellaire Barabos est sur la Terrasse des guerriers donnant sur le Niveau des marchands.",
        ["chasseur"]          = "Les maîtres chasseurs Vord, Deremiis et Killac sont dans le Sanctuaire des chasseurs sur le Niveau des marchands, avec le maître des familiers Ganaar.",
        ["chaman"]          = "Les maîtres chamans incluant le Farseer Nobundo, Hobahken, Sulaa et Gurrag sont situés dans la Salle de cristal.",
        ["demoniste"]         = "Le maître démoniste Soulspeaker Niir et le maître des démons Atharuun résident dans la Salle de cristal.",
        ["alchimie"]         = "L'alchimie est enseignée par Lucc et Altaa près de la Crypte des lumières dans le Niveau des marchands.",
        ["forge"]   = "La formation de forgeron est disponible au niveau inférieur du Niveau des marchands—demandez Miall.",
        ["enchantement"]      = "La formation en enchantement se fait dans la Salle de cristal—cherchez Nahogg.",
        ["ingenierie"]     = "Les maîtres ingénieurs sont dans le Niveau des marchands. Demandez Ockil.",
        ["calligraphie"]     = "Les leçons de calligraphie sont offertes par Thoth dans la Salle de cristal.",
        ["joaillerie"]   = "La formation en joaillerie est dans la Salle de cristal—demandez Farii près de la section joaillerie.",
        ["travail du cuir"]  = "La formation en travail du cuir et dépeçage est dans le Niveau des marchands—voyez Akham ou Remere.",
        ["couture"]       = "La formation en couture est à l'étage du Niveau des marchands avec Refik et l'assistant Kayaart.",
        ["minage"]          = "La formation en minage est située à l'arrière du Niveau des marchands—demandez Muaat.",
        ["herboristerie"]       = "La formation en herboristerie est dans la Crypte des lumières—cherchez Cemmorhan.",
        ["peche"]         = "La formation en pêche est à côté des Eaux bénies par la lumière dans la Salle de cristal avec Erett.",
        ["premiers secours"]       = "La formation en premiers secours est fournie par Nus dans la Salle de cristal près de la grotte de cristal.",
        ["cuisine"]         = "La cuisine est enseignée par Mumman sur la plateforme au-dessus de l'entrée principale, près de l'auberge.",
    }
  },
  orgrimmar = {
    responses = {
        ["banque"]            = "La banque et l'hôtel des ventes sont dans la Vallée de la force, avec les boîtes aux lettres et les vendeurs commerciaux.",
        ["hotel des ventes"]   = "Les services de l'Hôtel des ventes sont dans la Vallée de la force, à côté de la zone bancaire.",
        ["maitre de griffons"]  = "Le Maître des coursiers du vent Doras opère à l'extérieur du point de vol de la Vallée de la force.",
        ["maitre des ecuries"]   = "Le Maître des écuries Xon'cha dessert les écuries dans la Vallée de l'honneur.",
        ["auberge"]             = "L'auberge est située dans la Vallée des esprits, près de la Loge des esprits.",
        ["maitre de guilde"]    = "Le Maître de guilde Urtrun Clanbringer et le vendeur Goram sont près de Grommash Hold dans la Vallée de la sagesse.",
        ["maitre de champ bataille"]    = "Les maîtres de champ de bataille se trouvent dans la Vallée de l'honneur à la Salle des braves.",
        ["guerrier"]         = "Les maîtres guerriers Grezz Ragefist, Sorek et Zel'mak sont dans la Salle des braves, Vallée de l'honneur.",
        ["chasseur"]          = "La formation de chasseur est dans la Salle des chasseurs, Vallée de l'honneur. Les maîtres incluent Sian'dur, Xor'juul et Ormak Grimshot, plus le maître des familiers Xoa'stu.",
        ["mage"]            = "Les maîtres mages Uthel'nay, Enyo, Deino et Pephredo enseignent dans la Vallée des esprits. Lunaraa gère la formation des portails.",
        ["pretre"]          = "Les maîtres prêtres Ur'kyo et X'year sont stationnés à la Loge des esprits dans la Vallée des esprits.",
        ["voleur"]           = "La formation de voleur est dans la Faille des ombres. Demandez Gest, Ormok ou Shenthul.",
        ["demoniste"]         = "Les maîtres démonistes comme Grol'dar, Zevrost et Mirket sont dans l'Enclave du feu sombre à l'intérieur de la Faille des ombres.",
        ["chaman"]          = "La formation de chaman est dans Grommash Hold dans la Vallée de la sagesse. Les maîtres incluent Kardris Dreamseeker, Sagorne Crestrider et Sian'tsu.",
        ["alchimie"]         = "La formation en alchimie est offerte à l'Alchimie et Potions de Yelmak dans Le Traîneau. Les maîtres incluent Yelmak et Whuut.",
        ["forge"]   = "La formation de forgeron se fait dans la Vallée de l'honneur à L'Enclume ardente, avec Borgosh Corebender, Okothos Ironrager, Saru Steelfury ou Shayis Steelfury.",
        ["ingenierie"]     = "Les maîtres ingénieurs Nogg, Roxxik et Thund enseignent aux artisans dans l'Atelier de machines de Nogg, Vallée de l'honneur.",
        ["enchantement"]      = "La formation en enchantement est disponible chez Runeworks de Godan dans Le Traîneau. Demandez Godan ou Jhag.",
        ["travail du cuir"]  = "La formation en travail du cuir et dépeçage est dans Le Traîneau chez Travailleurs du cuir Kodohide—demandez Karolek, Kamari ou Thuwd.",
        ["couture"]       = "La formation en couture a lieu chez Marchandises en tissu de Magar dans Le Traîneau. Demandez Magar ou Snang.",
        ["cuisine"]         = "Les leçons de cuisine se font dans Le Traîneau au Foyer de Borstan. Parlez à Zamja.",
        ["herboristerie"]       = "La formation en herboristerie est donnée par Jandi à l'Arboretum de Jandi dans Le Traîneau.",
        ["minage"]          = "La formation en minage est située à Minage du Canyon rouge dans la Vallée de l'honneur. Les maîtres incluent Makaru ou Gorina.",
        ["premiers secours"]       = "La formation en premiers secours est à la Loge des esprits dans la Vallée des esprits. Demandez Arnok.",
        ["peche"]         = "Les leçons de pêche sont offertes par Lumak près des étangs dans la Vallée de l'honneur.",
        ["calligraphie"]     = "La formation en calligraphie est dans Le Traîneau. Cherchez Jo'mah.",
        ["joaillerie"]   = "La formation en joaillerie est dans Le Traîneau. Voyez Lugrah ou Nerog.",
    }
  },
  pitons_foudre = {
    responses = {
      ["banque"]            = "La Banque, l'Hôtel des ventes et la boîte aux lettres sont sur la Butte inférieure—trouvez-les près du poste de coursiers du vent et du Vendeur de réactifs Chepi.",
      ["hotel des ventes"]   = "L'Hôtel des ventes se trouve à côté de la banque sur la Butte inférieure.",
      ["maitre de griffons"]  = "Le Maître des coursiers du vent Tal est au sommet du perchoir des coursiers sur la Butte inférieure.",
      ["maitre des ecuries"]   = "Le Maître des écuries Bulrug est sur la Butte inférieure près de la banque.",
      ["auberge"]             = "L'Aubergiste Pala et l'auberge sont situés sur la Butte inférieure juste au sud du perchoir des coursiers.",
      ["maitre de guilde"]    = "Vous trouverez le Maître de guilde et le vendeur Randah Songhorn sur la Butte inférieure près des marchandises commerciales et des tentes d'approvisionnement général.",
      ["maitre de champ bataille"]    = "Les maîtres de champ de bataille (Alterac, Goulet des Warsong, Bassin d'Arathi) sont sur la Butte des chasseurs près de la Salle des chasseurs.",
      ["maitre d armes"]   = "Le Maître d'armes Ansekhwa (masses à une et deux mains/bâtons/fusils) est également sur la Butte inférieure.",
      ["guerrier"]         = "Les maîtres guerriers Sark Ragetotem, Torm Ragetotem et Ker Ragetotem sont dans la Salle des chasseurs sur la Butte des chasseurs.",
      ["chasseur"]          = "Les maîtres chasseurs Urek, Kary et Holt Thunderhorn (avec le maître des familiers Hesuwa) sont dans la Salle des chasseurs sur la Butte des chasseurs.",
      ["mage"]            = "Les maîtres mages Archimage Shymm, Ursyn Ghull et Thurston Xane, plus la maître des portails Birgitte Cranston, sont aux Bassins de vision sur la Butte des esprits.",
      ["pretre"]          = "Les maîtres prêtres Miles Welsh, Malakai Cross et Père Cobb sont aux Bassins de vision sur la Butte des esprits.",
      ["chaman"]          = "Les maîtres chamans Siln, Beram et Tigor Skychaser sont basés dans la Salle des esprits sur la Butte des esprits.",
      ["druide"]           = "Les maîtres druides Turak Runetotem, Sheal Runetotem et Kym Wildmane sont sur la Butte des anciens (Salle des anciens).",
      ["alchimie"]         = "Les maîtres alchimistes Kray et Bena Winterhoof sont sur la Butte centrale à l'Alchimie de Bena.",
      ["enchantement"]      = "Les maîtres enchanteurs Mot et Teg Dawnstrider sont chez Enchanteurs Dawnstrider sur la Butte centrale.",
      ["travail du cuir"]  = "Travail du cuir/spécialistes Mooranta, Tarn, Una et Mak (et couturier Vhan, Tepa) sont aux boutiques d'Armurier et Tailleur sur la Butte centrale.",
      ["herboristerie"]       = "Le maître herboriste Komin Winterhoof et le vendeur d'herboristerie Nida Winterhoof sont dans le jardin d'herbes sur la Butte centrale.",
      ["minage"]          = "Le maître mineur Brek Stonehoof est sur la Butte inférieure près du vendeur de réactifs Kurm Stonehoof.",
      ["forge"]   = "Les maîtres forgerons Thrag et Karn Stonehoof sont à la Forge de Kam sur la Butte inférieure.",
      ["couture"]       = "Les maîtres couturiers Vhan et Tepa sont juste au-dessus de la terrasse de l'Armurier sur la Butte centrale.",
      ["cuisine"]         = "Le maître cuisinier Aska Mistrunner (et fournisseur Naal) sont sur la Haute butte dans la Cuisine d'Aska.",
      ["peche"]         = "Le maître pêcheur Kah Mistrunner (et fournitures Sewa) opèrent depuis Appâts et articles de pêche du Sommet sur la Haute butte.",
      ["premiers secours"]       = "Le maître des premiers secours Pand Stonebinder est situé dans la zone des Bassins de vision sur la Butte des esprits.",
    }
  },
  fossoyeuse = {
  responses = {
    ["banque"]            = "La banque et la boîte aux lettres sont dans le Quartier marchand près des vendeurs de marchandises générales.",
    ["hotel des ventes"]   = "L'Hôtel des ventes est à côté de la banque dans le Quartier marchand.",
    ["maitre de griffons"]  = "Le maître de vol est situé dans la cour au-dessus, au niveau de surface de Fossoyeuse près des tours de zeppelin.",
    ["maitre des ecuries"]   = "Le Maître des écuries Anya Maulray est dans le Quartier marchand.",
    ["auberge"]             = "L'Aubergiste Norman est dans le Quartier marchand, près du feu de cuisine.",
    ["maitre de guilde"]    = "Le Maître de guilde et le vendeur de tabards sont dans le Quartier marchand près de la zone de marchandises générales.",
    ["maitre de champ bataille"]    = "Les maîtres de champ de bataille sont stationnés dans le Quartier de la guerre près des maîtres guerriers.",
    ["maitre d armes"]   = "Le Maître d'armes Archibald est dans le Quartier de la guerre et forme aux arbalètes, épées, armes d'hast et dagues.",
    ["guerrier"]         = "Les maîtres guerriers sont dans le Quartier de la guerre aux côtés de la zone de forge.",
    ["pretre"]          = "Les maîtres prêtres sont également dans le Quartier de la guerre.",
    ["voleur"]           = "Les maîtres voleurs sont dans le Quartier des voleurs. Cherchez Carolyn Ward et ses associés.",
    ["demoniste"]         = "Les maîtres démonistes sont dans le Quartier de la magie avec le maître des démons.",
    ["mage"]            = "Les maîtres mages et le maître des portails sont situés dans le Quartier de la magie.",
    ["chaman"]          = "Nous ne communions pas avec les éléments, et n'avons pas de maîtres chamans à Fossoyeuse.",
    ["druide"]           = "Il n'y a pas de maîtres druides à Fossoyeuse. Vous devrez aller aux Pitons-du-Tonnerre à la place.",
    ["alchimie"]         = "Les maîtres alchimistes sont dans l'Apothicarium dans l'aile ouest de la ville.",
    ["enchantement"]      = "Les maîtres enchanteurs se trouvent également dans l'Apothicarium.",
    ["herboristerie"]       = "La formation en herboristerie et les fournitures sont situées dans l'Apothicarium.",
    ["ingenierie"]     = "Les maîtres ingénieurs sont dans le Quartier des voleurs près des bricoleurs.",
    ["premiers secours"]       = "La formation en premiers secours est disponible dans le Quartier des voleurs.",
    ["travail du cuir"]  = "Les maîtres en travail du cuir et dépeçage se trouvent dans le Quartier des voleurs.",
    ["couture"]       = "Les maîtres couturiers sont situés dans le Quartier de la magie.",
    ["forge"]   = "Les maîtres forgerons sont dans le Quartier de la guerre près des forges.",
    ["minage"]          = "Le maître mineur et les fournitures sont près de la zone de forge dans le Quartier de la guerre.",
    ["cuisine"]         = "Le maître cuisinier Eunice Burch est dans le Quartier marchand près du foyer.",
    ["peche"]         = "Le maître pêcheur Armand Cromwell est dans le Quartier de la magie près des canaux.",
  }
},
lune_argent = {
    responses = {
      ["banque"]           = "La Banque de Lune-d'argent est dans le Bazar, coin sud-est près de l'Échange royal.",
      ["hotel des ventes"]  = "Il y a deux Hôtels des ventes : un au centre du Bazar, et l'Hôtel des ventes de l'Échange royal dans la section est.",
      ["maitre de griffons"] = "Le maître de vol (Maître des faucons-dragons Skymistress Gloaming) se tient juste à l'extérieur de la Porte du berger à l'ouest de la ville.",
      ["maitre des ecuries"]  = "Le Maître des écuries Shalenn s'occupe des montures sur la Place des Farstriders, à l'extérieur de la salle des rôdeurs.",
      ["auberge"]            = "Choisissez entre l'Auberge de Lune-d'argent dans l'Échange royal (tenue par Velandra) ou le Repos du voyageur entre la Marche des anciens et le Bazar.",
      ["maitre de guilde"]   = "Le Maître de guilde Tandrine et le vendeur de tabards résident le long de la Marche des anciens près de la Porte du magister.",
      ["maitre de champ bataille"]   = "Les maîtres de champ de bataille sont situés près des zones d'entraînement derrière l'Échange royal sur la Place des Farstriders.",
      ["maitre d armes"]  = "Le maître guerrier Lothan Silverblade supervise les armes près de la fonderie sur la Place des Farstriders.",
      ["guerrier"]        = "Les maîtres guerriers incluant Lothan sont sur la Place des Farstriders près de la fonderie.",
      ["chasseur"]         = "Le maître chasseur Zandine est sur la Place des Farstriders dans la salle des rôdeurs.",
      ["mage"]           = "Le maître mage Quithas (et autres magisters) sont à l'intérieur de la Flèche de Solfurie.",
      ["pretre"]         = "Le maître prêtre Belestra est également à l'intérieur de la Flèche de Solfurie.",
      ["paladin"]     = "Le Champion Bachi des Chevaliers de sang forme les paladins dans l'enclave sur la Place des Farstriders sous Dame Liadrin.",
      ["voleur"]          = "Le maître voleur Zelanis et ses associés opèrent dans l'Allée du meurtre, sur la Place des Farstriders.",
      ["demoniste"]      = "Le maître démoniste Alamma (avec maître des démons) est également dans l'Allée du meurtre au sein du quartier de l'auberge.",
      ["druide"]          = "Il n'y a pas de maîtres druides à Lune-d'argent — allez aux Pitons-du-Tonnerre à la place.",
      ["chaman"]         = "Pas de maîtres chamans ici. Essayez Orgrimmar ou les Pitons-du-Tonnerre.",
      ["alchimie"]        = "Le maître alchimiste Camberon est dans la Cour du soleil à côté de l'Échange royal.",
      ["enchantement"]     = "Le maître enchanteur Sedana se tient dans les alcôves de la Cour du soleil.",
      ["herboristerie"]      = "Le maître herboriste Nathera et les fournitures d'alchimie sont dans l'alcôve de la Cour du soleil.",
      ["calligraphie"]    = "Le maître calligraphe Zantasia se trouve près des alchimistes dans la Cour du soleil.",
      ["joaillerie"]  = "La joaillière Kalinda a son atelier à l'extrémité sud de l'Échange royal.",
      ["travail du cuir"] = "Le maître en travail du cuir Lynalis (et fournitures de dépeçage Ty'n) sont le long de l'extrémité sud-est de la Marche des anciens.",
      ["minage"]         = "Le maître mineur Belil est sur la Place des Farstriders près de la fonderie.",
      ["couture"]      = "Le maître couturier Keelen est au nord de l'Hôtel des ventes dans les niveaux inférieurs du Bazar.",
      ["cuisine"]        = "Le maître cuisinier Sylann travaille à l'étage du Repos du voyageur près des cuisines de la taverne.",
      ["premiers secours"]      = "Le maître des premiers secours Alestus est sur la Marche des anciens, près de l'entrée de l'Échange royal.",
      ["peche"]        = "Le maître pêcheur Drathen est situé sur la Marche des anciens près de l'Échange royal.",
    }
  },
}

local cles_reponses = {
    -- Classes (en premier pour éviter les conflits)
    ["maitre voleur"] = "voleur", ["voleur"] = "voleur",
    ["maitre guerrier"] = "guerrier", ["guerrier"] = "guerrier",
    ["maitre druide"] = "druide", ["druide"] = "druide",
    ["maitre chasseur"] = "chasseur", ["chasseur"] = "chasseur",
    ["maitre mage"] = "mage", ["mage"] = "mage",
    ["maitre paladin"] = "paladin", ["paladin"] = "paladin",
    ["maitre pretre"] = "pretre", ["pretre"] = "pretre",
    ["maitre chaman"] = "chaman", ["chaman"] = "chaman",
    ["maitre demoniste"] = "demoniste", ["demoniste"] = "demoniste",
    -- Services de ville
    ["hotel des ventes"] = "hotel des ventes",
    ["banque"] = "banque",
    ["port de hurlevent"] = "port de hurlevent", ["port"] = "port de hurlevent",
    ["tram des profondeurs"] = "tram des profondeurs",
    ["auberge"] = "auberge",
    ["maitre de griffons"] = "maitre de griffons",
    ["maitre de vol"] = "maitre de griffons", ["vol"] = "maitre de griffons", ["voler"] = "maitre de griffons",
    ["maitre de guilde"] = "maitre de guilde",
    ["serrurier"] = "serrurier",
    ["maitre des ecuries"] = "maitre des ecuries",
    ["coiffeur"] = "coiffeur",
    ["salon des officiers"] = "salon des officiers",
    ["maitre de champ bataille"] = "maitre de champ bataille",
    -- Métiers
    ["alchimie"] = "alchimie",
    ["travail du cuir"] = "travail du cuir",
    ["herboristerie"] = "herboristerie", ["herbe"] = "herboristerie",
    ["minage"] = "minage",
    ["forge"] = "forge",
    ["cuisine"] = "cuisine",
    ["enchantement"] = "enchantement",
    ["ingenierie"] = "ingenierie",
    ["premiers secours"] = "premiers secours",
    ["peche"] = "peche",
    ["calligraphie"] = "calligraphie",
    ["depecage"] = "depecage",
    ["couture"] = "couture"
}

local reponsesBienvenue = {
    "De rien. Maintenant circulez s'il vous plaît.", "Ne le mentionnez pas.", "Heureux d'aider... je suppose.",
    "Circulez, citoyen.", "Je fais juste mon travail.", "Bien, bien. De rien.",
    "De rien. Essayez de ne pas vous perdre à nouveau.", "J'ai l'air d'un guide touristique ?",
    "Bonne journée à vous, citoyen.", "Ne faisons pas de cela une habitude.",
    "C'est noté.",
    "N'hésitez pas à demander plus d'aide. Ce n'est pas comme si j'allais quelque part."
}

local reponsesAgaceesAlliance = {
    "Ouais, ouais – circulez.",
    "Assez de remerciements, citoyen.",
    "Encore un 'merci' et vous nettoyez les Casemates.",
    "Ça suffit, citoyen. Je ne suis pas votre mère.",
    "Si vous êtes si reconnaissant, écrivez un poème. Silencieusement.",
    "J'ai l'air d'avoir besoin d'applaudissements ? Circulez.",
    "Continuez comme ça et vous frotterez des bottes dans les Casemates.",
    "Encore un 'merci' et je vous dénonce pour flânerie.",
    "Vous m'avez plus remercié que mon officier supérieur ne l'a jamais fait.",
    "On a compris. Vous êtes poli. Maintenant allez être poli ailleurs.",
    "Par Elune, vous êtes collant.",
    "Vous devez être nouveau ici. On ne discute pas autant d'habitude.",
    "Je brille, ou vous fixez toujours après un merci ?",
    "Vous êtes à un 'merci' d'être de garde vous-même.",
    "Circulez avant que je vous assigne à la paperasse.",
    "Ce n'est pas un club social, citoyen.",
    "Je ne suis pas assez payé pour une surcharge de gratitude.",
    "Vous commencez à ressembler à un barde. S'il vous plaît, non.",
}

local reponsesAgaceesHorde = {
    "Ce n'est pas une partie de thé. Bougez.",
    "Dites 'merci' encore une fois. Je vous mets au défi.",
    "On n'est pas amis. Continuez à marcher.",
    "Vous me faites perdre mon temps, troufion ?",
    "Un mot de plus et vous serez aux latrines.",
    "Si vous essayez de m'impressionner, ça ne marche pas.",
    "Assez. Allez faire quelque chose d'utile.",
    "Vous parlez trop. Battez-vous ou partez.",
    "La gratitude ne vous sauvera pas si vous devenez mou.",
    "Vous pensez que je fais ça pour les louanges ? Dégagez de ma vue.",
    "Vous voulez une médaille aussi ?",
    "Allez embêter un péon.",
    "On est Horde. On ne se dorlote pas.",
    "Cette langue va vous attirer des ennuis.",
    "La prochaine fois, hochez juste la tête et partez.",
    "Vous montrez de la faiblesse à chaque mot.",
    "On n'a pas besoin de remerciements. On a besoin de résultats.",
    "Parlez moins. Saignez plus.",
}

local RAYON_DETECTION, DELAI_REPONSE, TEMPS_REFROIDISSEMENT, FENETRE_MERCI, TEMPS_SILENCE =
      10,               500,           30 * 1000,              15,              120
local etatInteraction = {}

local function purgerEtat(pGUID, maintenant)
    local pdata = etatInteraction[pGUID]
    if not pdata then return end
    for npcGUID, motscles in pairs(pdata) do
        for cle, st in pairs(motscles) do
            if st.dernierTempsReponse and maintenant - st.dernierTempsReponse > TEMPS_REFROIDISSEMENT then
                motscles[cle] = nil
            end
        end
        if next(motscles) == nil then
            pdata[npcGUID] = nil
        end
    end
    if next(pdata) == nil then etatInteraction[pGUID] = nil end
end

local function JoueurAppartientFactionVille(joueur, ville)
    local factionVille = FACTIONS_VILLE[ville]
    if not factionVille then return true end

    local estAlliance = joueur:GetTeam() == 0
    if factionVille == "Alliance" and not estAlliance then return false end
    if factionVille == "Horde" and estAlliance then return false end

    return true
end


local function SurJoueurDit(event, joueur, msg)
    local minuscule = string.lower(msg)
    if not minuscule:find("ou", 1, true) and not minuscule:find("merci", 1, true) then return end

    local pnpPlusProche, ville, meilleureDistance = nil, nil, RAYON_DETECTION + 1
    for _, npc in ipairs(joueur:GetCreaturesInRange(RAYON_DETECTION)) do
        local c = VILLE_PAR_NPC_ID[npc:GetEntry()]
        if c then
            local d = joueur:GetDistance(npc)
            if d < meilleureDistance then
                pnpPlusProche, ville, meilleureDistance = npc, c, d
            end
        end
    end
    if not pnpPlusProche then return end
    local cfg = CONFIG_VILLE[ville]; if not cfg then return end
    if not JoueurAppartientFactionVille(joueur, ville) then return end

    local pGUID, cGUID, maintenant = joueur:GetGUIDLow(), pnpPlusProche:GetGUIDLow(), os.time()
    purgerEtat(pGUID, maintenant)

        if minuscule:find("merci", 1, true) then
    etatInteraction[pGUID]        = etatInteraction[pGUID]        or {}
    etatInteraction[pGUID][cGUID] = etatInteraction[pGUID][cGUID] or {}
    local t = etatInteraction[pGUID][cGUID].mercis or { count = 0 }
    t.count = t.count + 1
    etatInteraction[pGUID][cGUID].mercis = t

    if t.count > 3 then
        if maintenant - (t.dernierTempsReponse or 0) < TEMPS_SILENCE then
            return
        else
            t.count = 1
        end
    end

    if not ville then return end
    local estVilleHorde = (ville == "orgrimmar" or ville == "fossoyeuse" or ville == "pitons_foudre" or ville == "lune_argent")
local listeAgacee = estVilleHorde and reponsesAgaceesHorde or reponsesAgaceesAlliance

local reponse
if     t.count == 1 then reponse = reponsesBienvenue[math.random(#reponsesBienvenue)]
elseif t.count == 2 then reponse = listeAgacee[1]
elseif t.count == 3 then reponse = listeAgacee[2]
else                    reponse = listeAgacee[3] end

    CreateLuaEvent(function()
        local pl = GetPlayerByGUID(pGUID); if not pl then return end
        for _, npc in ipairs(pl:GetCreaturesInRange(RAYON_DETECTION)) do
            if npc:GetGUIDLow() == cGUID
               and not npc:IsInCombat()
               and not npc:IsInEvadeMode() then
                npc:SendUnitSay(reponse, 0)
                t.dernierTempsReponse = os.time()
                break
            end
        end
    end, DELAI_REPONSE, 1)
    return
end

    for alias, canonique in pairs(cles_reponses) do
        if minuscule:find(alias, 1, true) then
            local motcle, base = canonique, cfg.responses[canonique]
            if base then
                etatInteraction[pGUID]            = etatInteraction[pGUID]            or {}
                etatInteraction[pGUID][cGUID]     = etatInteraction[pGUID][cGUID]     or {}
                local st                          = etatInteraction[pGUID][cGUID][motcle] or { count = 0 }
                st.count                          = st.count + 1
                etatInteraction[pGUID][cGUID][motcle] = st

                if st.count > 4 then
                    if maintenant - (st.dernierTempsReponse or 0) < TEMPS_SILENCE then
                        return
                    else
                        st.count = 1
                    end
                end

                local r = base
                if st.count == 2 then
                    r = (ville == "forgefer") and "Vous avez assez demandé, mon gars."
                        or "Vous me harcelez ?"
                elseif st.count == 3 then
                    r = (ville == "forgefer") and "J'ai l'air d'un foutu guide touristique ?"
                        or "Laissez-moi tranquille."
                elseif st.count == 4 then
                    r = (ville == "forgefer") and
                        "Dites encore un mot et vous refroidirez vos talons dans la Salle de justice."
                        or
                        "Je vous emmène aux Casemates si vous continuez à me faire perdre mon temps."
                end

                local npcGUID, joueurGUID = cGUID, pGUID
                CreateLuaEvent(function()
                    local pl = GetPlayerByGUID(joueurGUID); if not pl then return end
                    for _, npc in ipairs(pl:GetCreaturesInRange(RAYON_DETECTION)) do
                        if npc:GetGUIDLow() == npcGUID
                           and not npc:IsInCombat()
                           and not npc:IsInEvadeMode() then
                            npc:SendUnitSay(r, 0)
                            local pd = etatInteraction[joueurGUID]
                            if pd and pd[npcGUID] and pd[npcGUID][motcle] then
                                pd[npcGUID][motcle].dernierTempsReponse = os.time()
                            end
                            break
                        end
                    end
                end, DELAI_REPONSE, 1)
                return
            end
        end
    end
end

RegisterPlayerEvent(18, SurJoueurDit)