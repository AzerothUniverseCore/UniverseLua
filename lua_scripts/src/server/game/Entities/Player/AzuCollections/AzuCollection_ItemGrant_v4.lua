--[[
	AzuCollection_ItemGrant.lua  (script Eluna cote SERVEUR)
	================================================================
	A installer dans le dossier lua_scripts/ du serveur Eluna, puis
	".reload eluna" (ou redemarrage du worldserver).

	ROLE : recoit la demande envoyee par le patch client
	Collection_Compat.lua (fonction AzuCollection_RequestItem, appelee au
	clic sur un Jouet ou une Relique/Heritage collecte(e) dans l'UI
	Collections). Le client envoie un message d'addon (SendAddonMessage,
	prefixe "AZUCOL") au lieu d'un vrai paquet reseau custom -- c'est le
	seul canal client->serveur disponible sans toucher au C++ du core.
	Ce script capte ce message et cree PHYSIQUEMENT l'objet dans le sac
	du joueur (player:AddItem), au lieu du systeme "sort de jouet" retail
	(qui ne met jamais d'item dans le sac) et sans passer par le courrier.

	ENTITLEMENT (round 76) -- MEME MODELE POUR JOUETS ET RELIQUES/HERITAGE :

	Chaque objet coute COLLECTION_CURRENCY_COST exemplaires de l'item
	COLLECTION_CURRENCY_ITEM (43228, "Eclat du gardien des pierres"). Le
	serveur verifie que le joueur possede au moins ce montant, le retire,
	puis cree l'item ; si l'ajout d'item echoue (sacs pleins), la monnaie
	est remboursee automatiquement. Les listes TOY_ITEM_WHITELIST et
	HEIRLOOM_ITEM_WHITELIST restent le garde-fou anti-triche : un client
	modifie ne peut toujours pas demander un itemID hors de ces listes.

	HISTORIQUE :
	- Round 60 : entitlement Reliques par sort universel "Faux sort" (18282)
	  car les vrais spellID d'heritage (ex: 320570) sont des sorts RETAIL
	  MODERNES absents du spell.dbc WotLK 3.3.5 -- HasSpell() etait donc
	  TOUJOURS false pour ces IDs, quel que soit l'etat reel du joueur.
	- Round 62 : remplace entierement ce controle par sort par un cout en
	  monnaie pour les Reliques/Heritage UNIQUEMENT. Les Jouets gardaient
	  encore leur ancien systeme par sort (player:HasSpell(spellID)), car
	  la plupart de leurs spellID sont de vrais sorts WotLK classiques qui
	  existent reellement dans ce client (ex: 16739 pour l'Orbe de
	  tromperie).
	- Round 76 (ce fichier) : sur demande explicite, les Jouets passent
	  desormais EUX AUSSI au systeme par monnaie, pour la meme raison que
	  les Reliques -- 31 itemID de Jouets utilisaient malgre tout des
	  spellID retail modernes inexistants en 3.3.5 (meme probleme que les
	  Reliques d'origine), ce qui les rendait injouables (case vide, pas de
	  nom). Ces 31 itemID ont ete retires de la whitelist (et du fichier de
	  donnees cote client, Generated_CollectionToy.lua) car ils ne
	  correspondent a aucun contenu recuperable dans ce client. La liste
	  TOY_SPELL_BY_ITEM (sorts) est donc abandonnee au profit de
	  TOY_ITEM_WHITELIST (simple whitelist d'itemID, comme pour les
	  Reliques).

	IMPORTANT - CORRECTION (round 55) :
	La toute premiere version de ce script filtrait sur
	"Type ~= CHAT_MSG_ADDON" -- or CHAT_MSG_ADDON n'est PAS forcement une
	variable globale predefinie par Eluna. Si elle n'existe pas, elle vaut
	nil, et "Type ~= nil" est TOUJOURS vrai pour un vrai message (Type est
	un nombre) -> la fonction faisait un retour immediat, SANS AUCUNE
	ERREUR LUA (comparer a nil n'erreure jamais), pour CHAQUE message recu.
	On ne filtre donc plus du tout sur Type ici : seul le prefixe "AZUCOL"
	(deja separe pour nous par le moteur via RegisterServerEvent, voir
	round 61 plus bas) est verifie.

	DIAGNOSTIC : la ligne "print" ci-dessous (desactivee par defaut) permet
	de confirmer, dans la console/les logs du worldserver, que ce hook
	recoit bien CHAQUE message de chat du joueur (pas seulement AZUCOL) --
	utile si jamais rien ne se passe encore : decommentez-la, cliquez un
	Jouet ou une Relique en jeu, et regardez si une ligne apparait dans la
	console.
	================================================================
]]

local ADDON_PREFIX = "AZUCOL"

-- ROUND 76 : liste des itemID Jouets valides -- reprise de l'ancienne
-- TOY_SPELL_BY_ITEM (102 entrees, generee depuis
-- ClientDataGenerated/Generated_CollectionToy.lua) MOINS les 31 itemID
-- retires (spellID retail modernes inexistants en 3.3.5, meme probleme
-- que les Reliques d'origine). Sert UNIQUEMENT de whitelist anti-triche
-- desormais (l'entitlement par sort est abandonne au profit du cout en
-- monnaie, voir COLLECTION_CURRENCY_ITEM plus bas).
local TOY_ITEM_WHITELIST = {
	[1973] = true,
	[13379] = true,
	[17712] = true,
	[17716] = true,
	[18660] = true,
	[18984] = true,
	[18986] = true,
	[21540] = true,
	[23767] = true,
	[30542] = true,
	[30544] = true,
	[30690] = true,
	[32542] = true,
	[32566] = true,
	[32782] = true,
	[33079] = true,
	[33219] = true,
	[33223] = true,
	[33927] = true,
	[34480] = true,
	[34499] = true,
	[34686] = true,
	[35227] = true,
	[35275] = true,
	[36862] = true,
	[36863] = true,
	[37254] = true,
	[37460] = true,
	[37710] = true,
	[37863] = true,
	[38301] = true,
	[38578] = true,
	[40768] = true,
	[43499] = true,
	[43824] = true,
	[44430] = true,
	[44606] = true,
	[44719] = true,
	[44820] = true,
	[45011] = true,
	[45013] = true,
	[45014] = true,
	[45015] = true,
	[45016] = true,
	[45017] = true,
	[45018] = true,
	[45019] = true,
	[45020] = true,
	[45021] = true,
	[45057] = true,
	[45063] = true,
	[45984] = true,
	[46780] = true,
	[46843] = true,
	[48933] = true,
	[49040] = true,
	[49703] = true,
	[49704] = true,
	[50471] = true,
	[52201] = true,
	[52251] = true,
	[52253] = true,
	[54212] = true,
	[54343] = true,
	[54437] = true,
	[54438] = true,
	[54452] = true,
	[54651] = true,
	[54653] = true,
	[100164] = true,
	[100165] = true,
}

-- ROUND 62 : liste des itemID Reliques/Heritage valides -- reprise
-- directement de la table "heirloomItems" du systeme AIO fourni
-- (HeirloomClient.lua, 38 objets). Sert UNIQUEMENT de whitelist
-- anti-triche desormais (l'entitlement par sort est abandonne au
-- profit du cout en monnaie, voir COLLECTION_CURRENCY_ITEM plus bas).
local HEIRLOOM_ITEM_WHITELIST = {
	[42943] = true,
	[42944] = true,
	[42945] = true,
	[42946] = true,
	[42947] = true,
	[42948] = true,
	[42949] = true,
	[42950] = true,
	[42951] = true,
	[42952] = true,
	[42984] = true,
	[42985] = true,
	[42991] = true,
	[42992] = true,
	[44091] = true,
	[44092] = true,
	[44093] = true,
	[44094] = true,
	[44095] = true,
	[44096] = true,
	[44097] = true,
	[44098] = true,
	[44099] = true,
	[44100] = true,
	[44101] = true,
	[44102] = true,
	[44103] = true,
	[44105] = true,
	[44107] = true,
	[48677] = true,
	[48683] = true,
	[48685] = true,
	[48687] = true,
	[48689] = true,
	[48691] = true,
	[48716] = true,
	[48718] = true,
	[50255] = true,
}

-- ROUND 76 : renomme (etait HEIRLOOM_CURRENCY_ITEM/COST) puisque desormais
-- partage par les Jouets ET les Reliques/Heritage.
local COLLECTION_CURRENCY_ITEM = 43228 -- Eclat du gardien des pierres
local COLLECTION_CURRENCY_COST = 50

-- Cree l'objet demande contre COLLECTION_CURRENCY_COST exemplaires de
-- COLLECTION_CURRENCY_ITEM. Utilise pour les Jouets ET les Reliques/
-- Heritage (round 76 : meme logique unifiee, reprise de
-- HeirloomServer.lua fourni par l'utilisateur). Si l'ajout de l'item
-- echoue (sacs pleins), la monnaie deja retiree est remboursee.
local function GrantItemForCurrency(player, itemID)
	-- true = inclut la banque personnelle (round 75) : sans ca, deposer
	-- l'objet a la banque le rendait "rachetable" par erreur. La banque de
	-- GUILDE reste hors de portee de cette API cote serveur comme cote
	-- client -- limitation connue, aucun contournement fiable sans toucher
	-- au C++ du core.
	if player:GetItemCount(itemID, true) > 0 then
		player:SendBroadcastMessage("|cffff8000[Collections]|r Vous possedez deja cet objet.");
		return;
	end

	local currencyCount = player:GetItemCount(COLLECTION_CURRENCY_ITEM, false);
	if currencyCount < COLLECTION_CURRENCY_COST then
		player:SendBroadcastMessage(("|cffff0000[Collections]|r Il vous faut %d Eclat(s) du gardien des pierres (vous en avez %d)."):format(COLLECTION_CURRENCY_COST, currencyCount));
		return;
	end

	player:RemoveItem(COLLECTION_CURRENCY_ITEM, COLLECTION_CURRENCY_COST);

	local item = player:AddItem(itemID, 1);
	if item then
		player:SendBroadcastMessage("|cff00ccff[Collections]|r Objet ajoute a votre sac.");
	else
		-- Sac plein : on rembourse les Eclats retires plus haut.
		player:AddItem(COLLECTION_CURRENCY_ITEM, COLLECTION_CURRENCY_COST);
		player:SendBroadcastMessage("|cffff0000[Collections]|r Impossible d'ajouter l'objet (sacs pleins ?). Eclats rembourses.");
	end
end

local function HandleRequest(player, message)
	-- message attendu : "TOY:1973" ou "HEIRLOOM:42943"
	local kind, itemIDStr = message:match("^(%a+):(%d+)$");
	local itemID = tonumber(itemIDStr);
	if not kind or not itemID then
		return;
	end

	if kind == "TOY" then
		if not TOY_ITEM_WHITELIST[itemID] then
			-- itemID absent de la whitelist : requete invalide/falsifiee, on ignore.
			return;
		end
		GrantItemForCurrency(player, itemID);
	elseif kind == "HEIRLOOM" then
		if not HEIRLOOM_ITEM_WHITELIST[itemID] then
			-- itemID absent de la whitelist : requete invalide/falsifiee, on ignore.
			return;
		end
		GrantItemForCurrency(player, itemID);
	end
end

-- ROUND 61 : CAUSE RACINE TROUVEE. Ce script utilisait
-- RegisterPlayerEvent(30, ...), en supposant que 30 = PLAYER_EVENT_ON_CHAT.
-- FAUX sur les deux points :
--   1) 30 cote PLAYER_EVENT_* correspond en realite a PLAYER_EVENT_ON_FIRST_LOGIN
--      (event, player) -- un evenement qui ne se declenche qu'une seule fois,
--      a la toute premiere connexion du personnage, jamais sur un message de
--      chat. Notre gestionnaire n'etait donc JAMAIS appele pour un clic en jeu.
--   2) PLAYER_EVENT_ON_CHAT vaut en fait 18, pas 30, et de toute facon les
--      messages d'addon (SendAddonMessage) NE PASSENT PAS par cet evenement
--      cote PLAYER -- Eluna a un evenement DEDIE, cote SERVER (pas PLAYER) :
--      ADDON_EVENT_ON_MESSAGE = 30, enregistre via RegisterServerEvent (pas
--      RegisterPlayerEvent), avec la signature
--      (event, sender, type, prefix, msg, target) -- le prefixe est deja
--      separe pour nous par le moteur, plus besoin de parser
--      "AZUCOL\t..." a la main avec un pattern.
--   Verifie via la documentation officielle Eluna/AzerothCore (evenements
--   serveur, table "events.server.on_addon_message"). CONFIRME EN JEU PAR
--   L'UTILISATEUR : le clic sur un objet Heritage cree bien l'item dans le
--   sac une fois l'entitlement rempli.
-- ============================================================
local function OnAddonMsg(event, sender, msgType, prefix, msg, target)
	-- print(("[AzuCollection debug] addon msg de %s, prefix=%s, msg=%s"):format(sender and sender:GetName() or "?", tostring(prefix), tostring(msg)));

	if prefix ~= ADDON_PREFIX or not sender or not msg then
		return;
	end

	HandleRequest(sender, msg);
end

RegisterServerEvent(30, OnAddonMsg); -- 30 = ADDON_EVENT_ON_MESSAGE (cote SERVER, pas PLAYER)
