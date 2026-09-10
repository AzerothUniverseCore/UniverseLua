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
    },
    enUS = {
        GREETING = "Hey there, adventurer! I can tell you about quests, dungeons, battlegrounds, the Contributor system, or the AzerothUniverse shop. Just ask me what you'd like to know!",
        CONTRIBUTOR = "To become a Contributor, open the in-game shop (Escape Menu > Contributor) and get the Contributor Stone, then use it: your status activates instantly, no need to reconnect! You'll unlock an exclusive mount, items, +50% gold, dungeon buffs, and a weekly bundle by mail on all your characters.",
        QUESTS = "For quests, check your map: yellow exclamation marks show NPCs offering them. For a dungeon, form a group and open the Dungeon Finder (default key I). For a battleground, talk to the Battlemaster in your capital city, or open the Battlegrounds tab in the interface.",
        SHOP = "The AzerothUniverse line features items exclusive to our server, with several upgrade tiers (S0 to S8, M0 to M+FULL). You'll find them in the in-game shop (Escape Menu), or as rewards from systems like the Contributor program.",
        HELP = "Welcome to Azeroth Universe! Type .help in game for the command list, and feel free to join our Discord if you have a question. You can also just ask me directly: quests, dungeons, battlegrounds, the Contributor system, or the shop!",
    },
}

local Topics = {
    { key = "CONTRIBUTOR", keywords = { "contributeur", "contributor", "pierre de contributeur", "breloque" } },
    { key = "SHOP", keywords = { "boutique", "shop", "azerothuniverse", "azeroth universe" } },
    { key = "QUESTS", keywords = { "quete", "quête", "quest", "donjon", "dungeon", "instance", "champ de bataille", "battleground", " bg " } },
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
