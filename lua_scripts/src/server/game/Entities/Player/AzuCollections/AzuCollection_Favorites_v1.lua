--[[
	AzuCollection_Favorites.lua  (script Eluna cote SERVEUR)
	================================================================
	A installer dans le dossier lua_scripts/ du serveur Eluna, EN PLUS
	de AzuCollection_ItemGrant_v4.lua et AzuCollection_TransmogTracker_v2.lua
	(tous coexistent -- chacun ecoute son propre prefixe d'addon message,
	Eluna autorise plusieurs handlers sur le meme evenement). Necessite
	aussi le script SQL create_azu_collection_favorites.sql, a executer
	UNE FOIS sur la base "characters".

	ROLE : les favoris (Montures/Familiers/Jouets/Apparences Garde-robe,
	l'etoile qu'on peut cocher sur chaque objet) survivaient tant que le
	personnage restait connecte (round 92 : correctif cote client pour que
	l'etoile ne se decoche plus toute seule en changeant de selection),
	mais disparaissaient totalement a la deconnexion -- rien ne les
	sauvegardait de facon persistante. Ce n'est ni un SavedVariable
	(les tables SIRUS_*_FAVORITE_* sont de simples tables Lua en memoire,
	jamais declarees dans les SavedVariables du .toc), ni gere par un
	quelconque script serveur existant.

	PROTOCOLE (client : Utils\C_PetJournal.lua, Utils\C_MountJournal.lua,
	Utils\C_ToyBox.lua, Utils\C_TransmogCollection.lua -- tous partagent
	le meme protocole a 3 messages, CHAR_COLLECTION_* defini dans
	Collection_Compat.lua : MOUNT=0, PET=1, APPEARANCE=2, TOY=3) :
	  - ACMSG_C_A_F "collectionType|item"  (client -> serveur, ajout)
	  - ACMSG_C_R_F "collectionType|item"  (client -> serveur, retrait)
	  - ASMSG_C_A_F "collectionType|item"  (serveur -> client, confirmation
	    ajout -- le client a DEJA tout le code pour traiter ce message et
	    rafraichir son affichage, voir EventHandler:ASMSG_C_A_F dans
	    C_PetJournal.lua ; aucune modification client necessaire ici)
	  - ASMSG_C_R_F "collectionType|item"  (serveur -> client, confirmation
	    retrait -- idem, deja gere cote client)
	  - ASMSG_C_F_L "collectionType|item1,item2,..." (serveur -> client,
	    liste complete envoyee au login pour repeupler les tables
	    SIRUS_*_FAVORITE_* -- deja gere cote client aussi, EventHandler:ASMSG_C_F_L)

	Ce script se contente donc de PERSISTER ces evenements en base et de
	rejouer la liste complete au login -- tout le reste (mise a jour de
	l'affichage) est deja pris en charge par du code client existant qui
	n'attendait simplement jamais aucune reponse serveur jusqu'ici.

	NOTE SUR "item" : ce n'est pas toujours un itemID numerique -- pour
	Montures/Familiers/Jouets c'est un "hash" (identifiant interne Sirus,
	chaine alphanumerique), seul le cas Apparences (Garde-robe) utilise un
	itemAppearanceID numerique. On stocke donc "item" tel quel en VARCHAR
	et on ne le traite jamais comme un nombre cote serveur -- on se
	contente de le faire transiter, avec une validation stricte de son
	format pour eviter toute injection SQL (le client n'est jamais fiable).
	================================================================
]]

local ADD_PREFIX      = "ACMSG_C_A_F"
local REMOVE_PREFIX   = "ACMSG_C_R_F"
local ADD_REPLY       = "ASMSG_C_A_F"
local REMOVE_REPLY    = "ASMSG_C_R_F"
local LIST_REPLY      = "ASMSG_C_F_L"
local CHAT_MSG_WHISPER = 7

-- Format attendu du "item" : alphanumerique + tiret uniquement (couvre les
-- hash Sirus et les itemAppearanceID numeriques). Toute valeur qui ne
-- correspond pas a ce motif est rejetee silencieusement (requete
-- falsifiee/corrompue).
local function IsValidItemToken(item)
	return item ~= nil and item:match("^[%w%-]+$") ~= nil;
end

-- ADDON_EVENT_ON_MESSAGE = 30 -- (event, sender, type, prefix, msg, target)
local function OnFavoriteMsg(event, sender, msgType, prefix, msg, target)
	if not sender or not msg then
		return;
	end

	if prefix ~= ADD_PREFIX and prefix ~= REMOVE_PREFIX then
		return;
	end

	local collectionTypeStr, item = msg:match("^(%d+)|(.+)$");
	local collectionType = tonumber(collectionTypeStr);
	if not collectionType or not IsValidItemToken(item) then
		return;
	end

	local guid = sender:GetGUIDLow();

	if prefix == ADD_PREFIX then
		CharDBExecute(("INSERT IGNORE INTO azu_collection_favorites (guid, collectionType, itemHash) VALUES (%d, %d, '%s')"):format(guid, collectionType, item));
		sender:SendAddonMessage(ADD_REPLY, msg, CHAT_MSG_WHISPER, sender);
	else
		CharDBExecute(("DELETE FROM azu_collection_favorites WHERE guid=%d AND collectionType=%d AND itemHash='%s'"):format(guid, collectionType, item));
		sender:SendAddonMessage(REMOVE_REPLY, msg, CHAT_MSG_WHISPER, sender);
	end
end

-- PLAYER_EVENT_ON_LOGIN = 3 -- (event, player)
-- Rejoue la liste complete des favoris enregistres, groupes par type de
-- collection (une ligne ASMSG_C_F_L par type present), pour repeupler les
-- tables SIRUS_*_FAVORITE_* cote client des la connexion.
local function OnLogin(event, player)
	local guid = player:GetGUIDLow();
	local result = CharDBQuery(("SELECT collectionType, itemHash FROM azu_collection_favorites WHERE guid=%d"):format(guid));
	if not result then
		return;
	end

	local byType = {};
	repeat
		local collectionType = result:GetUInt32(0);
		local itemHash = result:GetString(1);
		byType[collectionType] = byType[collectionType] or {};
		table.insert(byType[collectionType], itemHash);
	until not result:NextRow();

	for collectionType, items in pairs(byType) do
		local msg = collectionType .. "|" .. table.concat(items, ",");
		player:SendAddonMessage(LIST_REPLY, msg, CHAT_MSG_WHISPER, player);
	end
end

RegisterServerEvent(30, OnFavoriteMsg); -- 30 = ADDON_EVENT_ON_MESSAGE
RegisterPlayerEvent(3, OnLogin);        -- 3  = PLAYER_EVENT_ON_LOGIN
