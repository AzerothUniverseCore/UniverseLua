local CHAT_MSG_SAY = 1    -- CHAT_MSG_SAY
local CHAT_MSG_YELL = 6   -- CHAT_MSG_YELL

local SAY_RANGE = 25.0
local YELL_RANGE = 100.0

local REPLY_COOLDOWN_SECONDS = 20
local lastReplyAt = {} -- [playerGUIDLow] = os.time() du dernier message envoye

-- ============================================================================
-- Langue du compte (meme logique que WeeklyContributorReward.lua)
-- ============================================================================

local function GetAccountLocale(accountId)
    local ok, result = pcall(function()
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

-- ============================================================================
-- Sujets reconnus et reponses
-- ============================================================================

local Locales = {
    frFR = {
        GREETING = "Salut aventurier ! Je peux te renseigner sur les quetes, les donjons, les champs de bataille, le systeme Contributeur ou la boutique AzerothUniverse. Demande-moi ce que tu veux savoir !",
        CONTRIBUTOR = "Pour devenir Contributeur, va dans la boutique du jeu (Menu Echap > Contributeur) et procure-toi la Pierre de Contributeur, puis utilise-la : ton statut s'active immediatement, sans te reconnecter ! Tu debloques une monture exclusive, des objets, +50% d'or, des buffs en donjon, et un lot hebdomadaire par courrier sur tous tes personnages.",
        QUESTS = "Pour les quetes, regarde ta carte : les points d'exclamation jaunes indiquent les PNJ qui en proposent. Pour un donjon, forme un groupe puis ouvre l'Outil de Recherche de Groupe (touche I par defaut). Pour un champ de bataille, parle au Maitre des Champs de Bataille dans ta capitale, ou ouvre l'onglet Champs de Bataille de l'interface.",
        SHOP = "La gamme AzerothUniverse regroupe des objets exclusifs a notre serveur, avec plusieurs paliers d'amelioration (S0 a S8, M0 a M+FULL). Tu les trouveras dans la boutique du jeu (Menu Echap), ou en recompense de certains systemes comme le programme Contributeur.",
        HELP = "Bienvenue sur Azeroth Universe ! Tape .help en jeu pour la liste des commandes, et n'hesite pas a rejoindre notre Discord si tu as une question. Tu peux aussi me demander directement : quetes, donjons, champs de bataille, systeme Contributeur ou boutique !",
        FEATURES = "Azeroth Universe propose : Azeroth Cataclysm + Pandarie, niveau max 90, classes et races custom, systemes Paragon/Rebirth, equipement Heroique/Mythique, donjons/raids/arenes personnalises, transmogrification, montures et familiers WotLK+, et bien plus. Demande-moi les classes, la progression, le PvP, les montures ou la personnalisation pour en savoir plus !",
        WORLD = "Azeroth Universe se joue sur l'Azeroth Cataclysm (remplace l'Azeroth WotLK d'origine), avec en plus le continent de Pandarie et ses quetes de Mists of Pandaria. Niveau max 90, 31 races jouables et 24 classes jouables au total !",
        CLASSES = "En plus des classes WotLK, on a porte le Moine, le Chasseur de Demons et l'Evoker, et cree 2 classes 100% custom : Mage de Combat Sanglant et Heros. Il y a aussi des classes secondaires exclusives : Pyromancer, Geomancer, Chronomancer, Venomancer, Necromancer, Ravageur du Chaos, Dompteur et Cavalier.",
        PROGRESSION = "Au niveau max, la progression continue avec le systeme Paragon et le systeme Rebirth (avec sa propre Pierre de Rebirth), les armes artefacts (A0 a A8, ameliorables), et l'equipement Heroique (S0 a S8) puis Mythique (jusqu'a M+8) avec du Mythique+ complet, du raid Mythique et des donjons Mythique+. Les plafonds de statistiques ont ete supprimes !",
        PVPCONTENT = "On propose des donjons et raids personnalises, un Codex des Rencontres (Guide d'Aventure) pour t'y reperer, un Tableau d'Appel du Heros, l'Arene 1c1, et de nouvelles arenes/champs de bataille : Arene Tol'Viron, Temple de Kotmogu, Les Pics Jumeaux, Le Croc du Tigre et Bataille de Gilneas.",
        CUSTOMIZATION = "Tu peux transmogrifier ton equipement, le retoucher (reforge) et l'ameliorer, garder toutes tes apparences dans ta Garde-Robe, et visiter la Zone Cosmetique. Il y a aussi un PNJ d'Habillage (DressNPC) et un marchand de presentation transmog pour previsualiser tes tenues.",
        MOUNTS = "Toutes les montures WotLK et plus sont disponibles, avec vol autorise en Azeroth et en Pandarie, et un Journal des Montures valable sur tout le compte. Meme chose pour les familiers de combat, avec leur propre Journal des Familiers compte entier.",
        ACCOUNTFEATURES = "Ton compte peut avoir jusqu'a 50 personnages au total, dont 20 par royaume. Les hauts faits sont partages sur tout le compte, et tu disposes de Grimoires d'Identite et de Conversion pour gerer tes dons/votes.",
        GAMEPLAY = "Le ramassage de butin se fait en zone, tu as une Recherche de Groupe en solo, SoloCraft, un MultiTrainer et un MultiVendor pour gagner du temps. Sans oublier le systeme de Bot PNJ (comme moi !), un teleporteur, un modificateur de taux d'XP avec des weekends XP, et des evenements reguliers.",
    },
    enUS = {
        GREETING = "Hey there, adventurer! I can tell you about quests, dungeons, battlegrounds, the Contributor system, or the AzerothUniverse shop. Just ask me what you'd like to know!",
        CONTRIBUTOR = "To become a Contributor, open the in-game shop (Escape Menu > Contributor) and get the Contributor Stone, then use it: your status activates instantly, no need to reconnect! You'll unlock an exclusive mount, items, +50% gold, dungeon buffs, and a weekly bundle by mail on all your characters.",
        QUESTS = "For quests, check your map: yellow exclamation marks show NPCs offering them. For a dungeon, form a group and open the Dungeon Finder (default key I). For a battleground, talk to the Battlemaster in your capital city, or open the Battlegrounds tab in the interface.",
        SHOP = "The AzerothUniverse line features items exclusive to our server, with several upgrade tiers (S0 to S8, M0 to M+FULL). You'll find them in the in-game shop (Escape Menu), or as rewards from systems like the Contributor program.",
        HELP = "Welcome to Azeroth Universe! Type .help in game for the command list, and feel free to join our Discord if you have a question. You can also just ask me directly: quests, dungeons, battlegrounds, the Contributor system, or the shop!",
        FEATURES = "Azeroth Universe features: Cataclysm Azeroth + Pandaria, max level 90, custom classes and races, Paragon/Rebirth systems, Heroic/Mythic gear, custom dungeons/raids/arenas, transmogrification, WotLK+ mounts and pets, and much more. Ask me about classes, progression, PvP, mounts or customization to learn more!",
        WORLD = "Azeroth Universe runs on Cataclysm Azeroth (replacing the original WotLK Azeroth), plus the Pandaria continent with its Mists of Pandaria questlines. Max level is 90, with 31 playable races and 24 playable classes in total!",
        CLASSES = "On top of the WotLK classes, we ported the Monk, Demon Hunter and Evoker, and created 2 fully custom classes: Blood Battle Mage and Hero. There are also exclusive secondary classes: Pyromancer, Geomancer, Chronomancer, Venomancer, Necromancer, Ravageur du Chaos, Dompteur and Cavalier.",
        PROGRESSION = "At max level, progression continues with the Paragon and Rebirth systems (Rebirth has its own Pierre de Rebirth stone), artifact weapons (A0 to A8, upgradeable), and Heroic gear (S0 to S8) then Mythic gear (up to M+8) with full Mythic+, Mythic raid difficulty and Mythic+ dungeons. Stat caps have been removed!",
        PVPCONTENT = "We offer custom dungeons and raids, a Codex Encounter Journal (Adventure Guide) to help you find your way, a Hero's Call Board, 1v1 Arena, and new arenas/battlegrounds: Tol'viron Arena, Temple of Kotmogu, Twin Peaks, The Tiger's Peak and Battle for Gilneas.",
        CUSTOMIZATION = "You can transmogrify your gear, reforge and upgrade it, keep every look in your Wardrobe, and visit the Cosmetic Zone. There's also a DressNPC and a transmog display vendor to preview your outfits.",
        MOUNTS = "All WotLK+ mounts are available, with flying allowed in both Azeroth and Pandaria, plus an account-wide Mount Journal. Same for battle pets, with their own account-wide Pet Journal.",
        ACCOUNTFEATURES = "Your account can have up to 50 characters total, with up to 20 per realm. Achievements are shared account-wide, and you have Identity and Conversion Grimoires to manage your donations/votes.",
        GAMEPLAY = "Loot pickup works zone-wide, and you get Solo LFG, SoloCraft, a MultiTrainer and a MultiVendor to save time. Not to mention the NPC Bot System (like me!), a teleporter, an XP rate modifier with XP weekends, and regular events.",
    },
}

local Topics = {
    { key = "CONTRIBUTOR", keywords = { "contributeur", "contributor", "pierre de contributeur", "breloque" } },
    { key = "SHOP", keywords = { "boutique", "shop", "azerothuniverse", "azeroth universe" } },
    { key = "QUESTS", keywords = { "quete", "quête", "quest", "donjon", "dungeon", "instance", "champ de bataille", "battleground", " bg " } },
    { key = "WORLD", keywords = { "cataclysm", "azeroth cataclysm", "pandarie", "pandaria", "mists of pandaria", "niveau max", "level max", "niveau 90", "level 90", "race jouable", "races jouables", "playable race", "31 races", "24 classes", "combien de classe", "combien de race" } },
    { key = "CLASSES", keywords = { "classe custom", "custom class", "classe heros", "hero class", "moine", "monk", "chasseur de demon", "chasseur de démons", "demon hunter", "evocateur", "évocateur", "evoker", "mage de combat sanglant", "blood battle mage", "mage de guerre du sang", "blood war mage", "pyromancien", "pyromancer", "geomancien", "geomancer", "chronomancien", "chronomancer", "empoisonneur", "venomancer", "necromancien", "necromancer", "ravageur du chaos", "chaos ravager", "dompteur", "maitre des betes", "beastmaster", "classe cavalier", "cavalier class", "classe chevalier", "chevalier class", "specialisation prestige", "prestige specialization" } },
    { key = "PROGRESSION", keywords = { "parangon", "paragon", "rebirth", "pierre de rebirth", "arme artefact", "armes artefact", "artifact weapon", "equipement heroique", "heroic gear", "equipement mythique", "mythic gear", "mythique+", "mythic+", "m+full", "raid mythique", "mythic raid", "plafond de statistique", "stat cap" } },
    { key = "PVPCONTENT", keywords = { "raid personnalise", "custom raid", "donjon personnalise", "custom dungeon", "codex des rencontres", "encounter journal", "guide d'aventure", "adventure guide", "tableau d'appel du heros", "hero's call board", "arene 1c1", "1v1 arena", "tol'vir", "tol'viron", "kotmogu", "croc du tigre", "tiger's peak", "pics jumeaux", "twin peaks", "bataille de gilneas", "battle for gilneas", "nouvelle arene", "nouveau champ de bataille" } },
    { key = "CUSTOMIZATION", keywords = { "transmogrification", "transmog", "retouche d'equipement", "reforging", "amelioration d'equipement", "item upgrade", "garde-robe", "wardrobe", "zone cosmetique", "cosmetic zone", "dressnpc", "marchand de presentation", "display vendor" } },
    { key = "MOUNTS", keywords = { "monture volante", "flying mount", "journal des montures", "mount journal", "familier de combat", "battle pet", "journal des familiers", "pet journal" } },
    { key = "ACCOUNTFEATURES", keywords = { "20 personnages", "combien de personnage", "characters per realm", "haut fait compte", "account-wide achievement", "grimoire d'identite", "grimoire de conversion", "identity grimoire", "conversion grimoire" } },
    { key = "GAMEPLAY", keywords = { "ramassage de butin", "zone loot", "loot en zone", "recherche de groupe solo", "solo lfg", "solocraft", "multitrainer", "multivendor", "systeme de bot", "bot system", "systeme de modele pnj", "npc template", "teleporteur", "teleporter", "modificateur de taux", "xp rate", "taux d'exp", "xp weekend", "evenement du serveur", "server event" } },
    { key = "FEATURES", keywords = { "caracteristique", "caracteristiques", "fonctionnalite", "fonctionnalites", "features", "quoi de neuf sur le serveur", "que propose le serveur", "contenu du serveur", "presente moi le serveur", "presentation du serveur" } },
    { key = "HELP", keywords = { "aide", "help", "debuter", "débuter", "nouveau joueur", "comment jouer", "commande" } },
    { key = "GREETING", keywords = { "bonjour", "salut", "coucou", "hello", "hi " } },
}

local function MatchTopic(rawMsg)
    local lowerMsg = " " .. string.lower(rawMsg) .. " "
    for _, topic in ipairs(Topics) do
        for _, keyword in ipairs(topic.keywords) do
            if string.find(lowerMsg, keyword, 1, true) then
                return topic.key
            end
        end
    end
    return nil
end

-- ============================================================================
-- Detection des bots a proximite
-- ============================================================================

local function IsNpcBot(creature)
    local scriptName = creature:GetScriptName()
    return scriptName ~= nil and string.find(scriptName, "_bot", 1, true) ~= nil
end

local function GetClosestNearbyBot(player, range)
    local nearbyCreatures = player:GetCreaturesInRange(range)
    if not nearbyCreatures then
        return nil
    end

    local closestBot, closestDist = nil, nil
    for _, creature in ipairs(nearbyCreatures) do
        if creature:IsAlive() and IsNpcBot(creature) then
            local dist = player:GetExactDistance(creature)
            if not closestDist or dist < closestDist then
                closestBot, closestDist = creature, dist
            end
        end
    end

    return closestBot
end

-- ============================================================================
-- Handler principal
-- ============================================================================

local function OnPlayerChat(event, player, msg, Type, lang)
    if Type ~= CHAT_MSG_SAY and Type ~= CHAT_MSG_YELL then
        return
    end

    local guidLow = player:GetGUIDLow()
    local now = os.time()
    if lastReplyAt[guidLow] and (now - lastReplyAt[guidLow]) < REPLY_COOLDOWN_SECONDS then
        return
    end

    local topicKey = MatchTopic(msg)
    if not topicKey then
        return
    end

    local range = (Type == CHAT_MSG_YELL) and YELL_RANGE or SAY_RANGE
    local closestBot = GetClosestNearbyBot(player, range)
    if not closestBot then
        return
    end

    local L = Locales[GetAccountLocale(player:GetAccountId())] or Locales.frFR
    local answer = L[topicKey]
    if not answer then
        return
    end

    lastReplyAt[guidLow] = now

    local CHAT_MSG_WHISPER = 7
    local CHAT_MSG_MONSTER_SAY = 12
    local ok, err = pcall(function()
        closestBot:SendChatMessageToPlayer(CHAT_MSG_MONSTER_SAY, 0, answer, player)
        closestBot:SendChatMessageToPlayer(CHAT_MSG_WHISPER, 0, answer, player)
    end)
    if not ok then
        print(string.format("[BotAssistant] Erreur envoi de reponse a %s : %s", player:GetName(), tostring(err)))
    end
end
RegisterPlayerEvent(18, OnPlayerChat)
