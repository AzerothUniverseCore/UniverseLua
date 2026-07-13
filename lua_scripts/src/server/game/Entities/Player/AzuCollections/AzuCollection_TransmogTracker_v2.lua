--[[
	AzuCollection_TransmogTracker.lua  (script Eluna cote SERVEUR)
	================================================================
	REMPLACE AzuCollection_TransmogTracker_v1.lua (supprimer l'ancien
	fichier du dossier lua_scripts/ avant d'installer celui-ci -- les
	deux ne doivent jamais tourner en meme temps, sinon chaque equip/
	requete serait traite en double : double insertion DB -- sans
	consequence grace a INSERT IGNORE -- mais aussi double envoi de
	messages au client). Necessite toujours le script SQL
	create_azu_collection_transmog_appearances.sql (base "characters",
	execution unique, inchange).

	ROLE : c'est la piece manquante identifiee lors du diagnostic de la
	barre de progression "0/X" toujours a zero dans l'onglet Garde-robe.
	Le client (Utils/C_TransmogCollection.lua) envoie un message d'addon
	ACMSG_C_I_GET_MODELS contenant une liste de triplets
	"invType:classID:subClassID:" (une categorie d'apparences) des qu'un
	onglet Garde-robe est ouvert pour la premiere fois, et attend en
	retour un message ASMSG_C_I_GET_MODELS contenant la liste (separee
	par des virgules) des itemID d'apparence que CE PERSONNAGE a deja
	reellement porte/debloque parmi cette categorie.

	ROUND 90 -- CORRECTION : la v1 de ce script enregistrait bien chaque
	equipement dans la table azu_collection_transmog_appearances, mais
	ne prevenait JAMAIS le client en temps reel qu'une NOUVELLE apparence
	venait d'etre debloquee. Or le client ne renvoie une requete
	ACMSG_C_I_GET_MODELS pour une categorie donnee QU'UNE SEULE FOIS par
	session (garde anti-doublon SIRUS_COLLECTION_RECEIVED_APPEARANCES
	cote client) -- rouvrir le meme onglet Garde-robe ne redemande donc
	rien au serveur. Resultat observe par l'utilisateur : s'equiper d'un
	nouvel objet en jeu ne faisait RIEN changer a l'affichage (toujours
	"0/278"), meme apres coup.
	Sirus a en realite DEUX messages distincts pour ce systeme (les deux
	geres cote client dans Utils\C_TransmogCollection.lua) :
	  - ASMSG_C_I_GET_MODELS (pluriel, liste complete) : reponse a une
	    demande de categorie, envoyee UNE FOIS au premier affichage.
	  - ASMSG_C_I_ADD_MODEL (singulier, UN SEUL itemID) : notification
	    "live" envoyee des qu'une NOUVELLE apparence est debloquee
	    (typiquement au moment de l'equipement), pour mettre a jour
	    l'affichage EN TEMPS REEL sans attendre un rechargement complet
	    de la categorie. C'est ce deuxieme message qui manquait
	    entierement. Il est desormais envoye a la fin de OnEquip, juste
	    apres l'insertion en base.

	FONCTIONNEMENT (mis a jour) :
	1) PLAYER_EVENT_ON_EQUIP (29) : enregistre (guid, itemID) en base,
	   PUIS envoie immediatement ASMSG_C_I_ADD_MODEL(itemID) au joueur
	   pour mise a jour instantanee de la grille/barre de progression
	   ouverte, sans necessiter de reconnexion ni de changement d'onglet.
	2) PLAYER_EVENT_ON_LOGIN (3) : rattrapage pour les personnages deja
	   equipes avant l'installation de ce script -- relit les 19
	   emplacements (sac 255, slots 0 a 18) et les insere en base. PAS de
	   push ASMSG_C_I_ADD_MODEL ici (le client n'a pas encore charge/
	   affiche l'UI Collection a cet instant du login) -- ces objets
	   remontent naturellement via la reponse ASMSG_C_I_GET_MODELS la
	   premiere fois que le joueur ouvre chaque onglet, comme avant.
	3) ADDON_EVENT_ON_MESSAGE (30), prefixe "ACMSG_C_I_GET_MODELS" :
	   inchange -- croise les itemID candidats de la categorie demandee
	   (base "world", item_template) avec la table du joueur (base
	   "characters"), renvoie la liste via ASMSG_C_I_GET_MODELS.

	RAPPEL IMPORTANT POUR TESTER : le suivi est base sur le fait
	d'EQUIPER un objet (PLAYER_EVENT_ON_EQUIP), pas seulement de le
	posseder en sac. Un ".additem" seul ne suffit pas -- il faut equiper
	reellement l'objet au moins une fois pour que son apparence soit
	enregistree, exactement comme le systeme de Garde-robe retail.

	Canal SendAddonMessage : CHAT_MSG_WHISPER (valeur numerique 7 dans
	l'enum ChatMsg de TrinityCore/SharedDefines.h) -- canal standard pour
	un message d'addon cible vers un seul joueur.
	================================================================
]]

local TRACK_PREFIX = "ACMSG_C_I_GET_MODELS"
local REPLY_PREFIX  = "ASMSG_C_I_GET_MODELS"
local ADD_PREFIX    = "ASMSG_C_I_ADD_MODEL"
local CHAT_MSG_WHISPER = 7

-- ============================================================
-- 1) Enregistrement des apparences portees
-- ============================================================

local function RecordAppearance(player, itemID)
	if not player or not itemID or itemID == 0 then
		return;
	end
	local guid = player:GetGUIDLow();
	CharDBExecute(("INSERT IGNORE INTO azu_collection_transmog_appearances (guid, itemId) VALUES (%d, %d)"):format(guid, itemID));
end

-- PLAYER_EVENT_ON_EQUIP = 29 -- (event, player, item, bag, slot)
-- ROUND 90 : ajout du push ASMSG_C_I_ADD_MODEL apres l'enregistrement en
-- base, pour que la grille/barre de progression Garde-robe deja ouverte
-- se mette a jour immediatement (voir explication en tete de fichier).
local function OnEquip(event, player, item, bag, slot)
	if not item then
		return;
	end

	local itemID = item:GetEntry();
	RecordAppearance(player, itemID);

	if player then
		player:SendAddonMessage(ADD_PREFIX, tostring(itemID), CHAT_MSG_WHISPER, player);
	end
end

-- PLAYER_EVENT_ON_LOGIN = 3 -- (event, player)
-- Rattrapage : relit les 19 emplacements d'equipement (sac pseudo 255,
-- slots 0 a 18 = EQUIPMENT_SLOT_START a EQUIPMENT_SLOT_END) et enregistre
-- ce qui est deja porte, pour les personnages existants avant ce script.
-- Pas de push ASMSG_C_I_ADD_MODEL ici (voir note ROUND 90 en tete de
-- fichier) -- ces objets remontent via ASMSG_C_I_GET_MODELS au premier
-- affichage de chaque onglet, comme avant.
local function OnLogin(event, player)
	for slot = 0, 18 do
		local item = player:GetItemByPos(255, slot);
		if item then
			RecordAppearance(player, item:GetEntry());
		end
	end
end

-- ============================================================
-- 2) Reponse a la demande de progression (ACMSG_C_I_GET_MODELS)
-- ============================================================

-- Parse "invType1:classID1:subClassID1:invType2:classID2:subClassID2:..."
-- (le ":" final apres le tout dernier triplet est optionnel selon la
-- facon dont le client a construit la chaine -- gere par le "?" en fin
-- de motif).
local function ParseTriplets(msg)
	local triplets = {};
	for invType, classID, subClassID in msg:gmatch("(%d+):(%d+):(%d+):?") do
		table.insert(triplets, {
			invType = tonumber(invType),
			classID = tonumber(classID),
			subClassID = tonumber(subClassID),
		});
	end
	return triplets;
end

-- Construit "SELECT entry FROM item_template WHERE (InventoryType=a AND
-- class=b AND subclass=c) OR (...)" -- une clause OR par triplet, plutot
-- qu'un IN de tuples, pour rester compatible avec toutes les versions de
-- MySQL/MariaDB.
local function BuildItemTemplateQuery(triplets)
	local clauses = {};
	for _, t in ipairs(triplets) do
		table.insert(clauses, ("(InventoryType=%d AND class=%d AND subclass=%d)"):format(t.invType, t.classID, t.subClassID));
	end
	if #clauses == 0 then
		return nil;
	end
	return "SELECT entry FROM item_template WHERE " .. table.concat(clauses, " OR ");
end

local function GetCollectedItemIDsForCategory(player, triplets)
	local query = BuildItemTemplateQuery(triplets);
	if not query then
		return {};
	end

	local worldResult = WorldDBQuery(query);
	if not worldResult then
		return {};
	end

	-- Liste des itemID candidats pour cette categorie (base "world").
	local candidateIDs = {};
	local candidateCount = 0;
	repeat
		local entry = worldResult:GetUInt32(0);
		candidateCount = candidateCount + 1;
		candidateIDs[candidateCount] = entry;
	until not worldResult:NextRow();

	if candidateCount == 0 then
		return {};
	end

	local idList = table.concat(candidateIDs, ",");
	local guid = player:GetGUIDLow();
	local charResult = CharDBQuery(("SELECT itemId FROM azu_collection_transmog_appearances WHERE guid=%d AND itemId IN (%s)"):format(guid, idList));

	local collected = {};
	if charResult then
		repeat
			table.insert(collected, charResult:GetUInt32(0));
		until not charResult:NextRow();
	end

	return collected;
end

-- ADDON_EVENT_ON_MESSAGE = 30 -- (event, sender, type, prefix, msg, target)
local function OnAddonMsg(event, sender, msgType, prefix, msg, target)
	-- print(("[AzuCollection TransmogTracker debug] addon msg de %s, prefix=%s, msg=%s"):format(sender and sender:GetName() or "?", tostring(prefix), tostring(msg)));

	if prefix ~= TRACK_PREFIX or not sender or not msg then
		return;
	end

	local triplets = ParseTriplets(msg);
	if #triplets == 0 then
		return;
	end

	local collectedIDs = GetCollectedItemIDsForCategory(sender, triplets);
	local reply = table.concat(collectedIDs, ",");

	sender:SendAddonMessage(REPLY_PREFIX, reply, CHAT_MSG_WHISPER, sender);
end

RegisterPlayerEvent(29, OnEquip); -- 29 = PLAYER_EVENT_ON_EQUIP
RegisterPlayerEvent(3, OnLogin);  -- 3  = PLAYER_EVENT_ON_LOGIN
RegisterServerEvent(30, OnAddonMsg); -- 30 = ADDON_EVENT_ON_MESSAGE
