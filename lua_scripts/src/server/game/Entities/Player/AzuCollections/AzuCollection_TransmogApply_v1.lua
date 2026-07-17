--[[
	AzuCollection_TransmogApply_v1.lua  (script Eluna cote SERVEUR)
	================================================================
	Applique reellement une transmogrification depuis l'onglet
	"Transmogrification" du journal Collections (Custom_Wardrobe.lua,
	porte depuis eZCollection). Reutilise EXACTEMENT le meme mecanisme que
	Transmog/TransmogrifierServer.lua (systeme AIO independant, deja
	fonctionnel sur Universe depuis longtemps) : ecriture directe des
	champs PLAYER_VISIBLE_ITEM_x_ENTRYID du joueur -- un artifice
	purement protocole qui change l'apparence visible SANS toucher a
	l'objet reellement equipe. Aucune magie cote client requise, et
	aucune dependance a AIO (ce systeme utilise le simple addon-message
	deja etabli pour tout le reste de la Collection, ACMSG_*/ASMSG_*).

	Table dediee azu_collection_transmog_applied, DIFFERENTE de
	transmog_char (utilisee par TransmogrifierServer.lua), pour ne
	jamais interferer si les deux systemes tournent en parallele.

	Necessite AzuCollection_TransmogTracker_v2.lua (deja installe) pour
	la table azu_collection_transmog_appearances : on ne peut appliquer
	QUE des apparences deja "collectees" par ce personnage (deja portees
	au moins une fois), exactement le principe retail du Garde-robe.

	PROTOCOLE (addon-message, canal CHAT_MSG_WHISPER comme le reste du
	systeme de Collection) :
	  ACMSG_TRANSMOG_APPLY   "slot:itemEntry"   client  -> serveur
	                         (itemEntry=0 = revert/retirer la transmog)
	  ASMSG_TRANSMOG_APPLIED "slot:itemEntry"   serveur -> client (confirmation)
	  ASMSG_TRANSMOG_SYNC    "slot:item,slot:item,..." serveur -> client (au login)
	  ASMSG_TRANSMOG_ERROR   texte              serveur -> client (refus)

	"slot" est le VRAI numero d'emplacement d'equipement WotLK (0-based,
	celui que renvoie TransmogLocationMixin:GetSlotID() cote client,
	identique a GetInventoryItemID("player", slot)) -- PAS le numerotage
	1-based propre a TransmogrifierServer.lua.
	================================================================
]]

local APPLY_TABLE = "azu_collection_transmog_applied"
local BASE_VISIBLE_ITEM_OFFSET = 283 -- PLAYER_VISIBLE_ITEM_1_ENTRYID (slot Tete = equipment slot 0)
local CHAT_MSG_WHISPER = 7

-- Round Transmog-7 : cout reel, meme valeur que TRANSMOG_COST dans
-- Transmog/TransmogrifierServer.lua (500000 cuivre = 50 pieces d'or), pour
-- rester coherent entre les deux systemes. DOIT correspondre exactement a
-- TRANSMOG_COST_PER_SLOT cote client (Collection_Compat.lua), sinon le
-- bouton Appliquer afficherait un prix different de ce qui est reellement
-- preleve. Le retrait (itemEntry == 0, revert) reste gratuit, comme
-- ResetSlot/ResetAll dans TransmogrifierServer.lua.
local TRANSMOG_COST_PER_SLOT = 500000

-- ============================================================
-- 1) Table + emplacements valides
-- ============================================================

local function CreateApplyTable()
	CharDBExecute("CREATE TABLE IF NOT EXISTS " .. APPLY_TABLE .. " (" ..
		"guid INT UNSIGNED NOT NULL, " ..
		"slot TINYINT UNSIGNED NOT NULL, " ..
		"item_entry INT UNSIGNED NOT NULL, " ..
		"PRIMARY KEY (guid, slot)" ..
		") ENGINE=InnoDB DEFAULT CHARSET=utf8")
end
CreateApplyTable()

-- Categories d'InventoryType valides par emplacement (memes categories que
-- TransmogrifierServer.lua, mais indexees par le vrai slot 0-based).
local EQUIPMENT_SLOTS = {
	[0]  = {invTypes = {1}},              -- Tete
	[2]  = {invTypes = {3}},              -- Epaules
	[4]  = {invTypes = {5, 20}},          -- Torse / Robe
	[5]  = {invTypes = {6}},              -- Taille
	[6]  = {invTypes = {7}},              -- Jambes
	[7]  = {invTypes = {8}},              -- Pieds
	[8]  = {invTypes = {9}},              -- Poignets
	[9]  = {invTypes = {10}},             -- Mains
	[14] = {invTypes = {16}},             -- Dos
	[15] = {invTypes = {13, 17, 21}},     -- Main droite (1M/2M/MH)
	[16] = {invTypes = {14, 22, 23, 13}}, -- Main gauche (bouclier/objet tenu/OH/1M)
	[17] = {invTypes = {15, 25, 26}},     -- Distance
}

-- ============================================================
-- 2) Verifications
-- ============================================================

local function IsAppearanceCollected(guid, itemEntry)
	local q = CharDBQuery(string.format(
		"SELECT 1 FROM azu_collection_transmog_appearances WHERE guid=%u AND itemId=%u",
		guid, itemEntry))
	return q ~= nil
end

local function IsItemCompatible(itemEntry, slotID)
	local slotConfig = EQUIPMENT_SLOTS[slotID]
	if not slotConfig then
		return false
	end

	local q = WorldDBQuery(string.format(
		"SELECT InventoryType FROM item_template WHERE entry=%u", itemEntry))
	if not q then
		return false
	end

	local invType = q:GetUInt8(0)
	for _, validInvType in ipairs(slotConfig.invTypes) do
		if invType == validInvType then
			return true
		end
	end
	return false
end

-- ============================================================
-- 2ter) Verification "collectionne OU dans les sacs" (round 29)
-- ============================================================

-- Meme convention 0-based que EQUIPMENT_SLOTS ci-dessus (numerotation
-- Eluna/TrinityCore native, differente de la numerotation Blizzard cote
-- client -- cf. le fix de decalage plus bas). Sac a dos = 16 emplacements
-- fixes (23-38), puis les 4 sacs equipes (emplacements 19-22) chacun avec
-- sa propre taille (bag:GetBagSize()).
local INVENTORY_SLOT_ITEM_START = 23
local INVENTORY_SLOT_ITEM_END = 39 -- exclusif
local INVENTORY_SLOT_BAG_START = 19
local INVENTORY_SLOT_BAG_END = 23 -- exclusif
local INVENTORY_SLOT_BAG_0 = 255

-- FIX ROUND TRANSMOG-50 : cette fonction ne comparait QUE l'itemEntry
-- exact. Or la grille cote client (GetAnAppearanceSourceFromVisual, dans
-- Custom_Wardrobe.lua) choisit un itemID "representatif" pour une
-- apparence donnee -- parmi TOUS les objets qui partagent le meme visuel
-- (ex. butin identique sur plusieurs difficultes/boss : "Drape-epaules
-- mercurien" / "Mantelet mercurien" / "Mantelet de Nefarius" partagent
-- tous le meme modele 3D), et cet itemID choisi n'est pas forcement celui
-- que le joueur possede reellement. Resultat rapporte : "Apparence non
-- debloquee" alors que l'objet EST bien dans le sac -- juste sous un
-- itemEntry different partageant la meme apparence visuelle (displayid).
-- On accepte donc aussi une correspondance par displayid (le vrai modele
-- 3D affiche), pas seulement par itemEntry exact.
local function GetItemDisplayID(itemEntry)
	local q = WorldDBQuery(string.format(
		"SELECT displayid FROM item_template WHERE entry=%u", itemEntry))
	if not q then
		return nil
	end
	return q:GetUInt32(0)
end

-- Petit cache pour eviter de re-interroger item_template pour le meme
-- entry plusieurs fois pendant le meme parcours des sacs.
local displayIDCache = {}
local function GetItemDisplayIDCached(entry)
	if displayIDCache[entry] ~= nil then
		return displayIDCache[entry]
	end
	local id = GetItemDisplayID(entry) or 0
	displayIDCache[entry] = id
	return id
end

local function ItemMatches(item, itemEntry, targetDisplayID)
	if not item then
		return false
	end
	local entry = item:GetEntry()
	if entry == itemEntry then
		return true
	end
	if not targetDisplayID or targetDisplayID == 0 then
		return false
	end
	-- Prefere item:GetDisplayId() si disponible sur cette build Eluna
	-- (pas de requete DB necessaire) ; sinon repli sur item_template via
	-- l'entry de CET objet du sac (plus lent mais portable partout).
	local ok, displayID = pcall(function() return item:GetDisplayId() end)
	if not ok or not displayID or displayID == 0 then
		displayID = GetItemDisplayIDCached(entry)
	end
	return displayID == targetDisplayID
end

local function PlayerHasItemInBags(player, itemEntry)
	local targetDisplayID = GetItemDisplayID(itemEntry)

	for slot = INVENTORY_SLOT_ITEM_START, INVENTORY_SLOT_ITEM_END - 1 do
		local item = player:GetItemByPos(INVENTORY_SLOT_BAG_0, slot)
		if ItemMatches(item, itemEntry, targetDisplayID) then
			return true
		end
	end

	for bagSlot = INVENTORY_SLOT_BAG_START, INVENTORY_SLOT_BAG_END - 1 do
		local bag = player:GetItemByPos(INVENTORY_SLOT_BAG_0, bagSlot)
		if bag then
			local bagSize = bag:GetBagSize()
			if bagSize then
				for j = 0, bagSize - 1 do
					local item = player:GetItemByPos(bagSlot, j)
					if ItemMatches(item, itemEntry, targetDisplayID) then
						return true
					end
				end
			end
		end
	end

	return false
end

-- ============================================================
-- 3) Application visuelle (PLAYER_VISIBLE_ITEM_x_ENTRYID)
-- ============================================================

local function ApplyVisual(player, slotID, itemEntry)
	local offset = BASE_VISIBLE_ITEM_OFFSET + (slotID * 2)
	player:SetUInt32Value(offset, itemEntry or 0)
	player:SetUInt32Value(offset + 1, 0) -- enchant visuel a 0
end

local function RestoreBaseVisual(player, slotID)
	local item = player:GetItemByPos(255, slotID)
	local itemEntry = item and item:GetEntry() or 0
	ApplyVisual(player, slotID, itemEntry)
end

-- ============================================================
-- 4) Persistance
-- ============================================================

local function SaveApplied(guid, slotID, itemEntry)
	CharDBExecute(string.format(
		"REPLACE INTO %s (guid, slot, item_entry) VALUES (%u, %u, %u)",
		APPLY_TABLE, guid, slotID, itemEntry))
end

local function ClearApplied(guid, slotID)
	CharDBExecute(string.format(
		"DELETE FROM %s WHERE guid=%u AND slot=%u",
		APPLY_TABLE, guid, slotID))
end

local function GetAllApplied(guid)
	local q = CharDBQuery(string.format(
		"SELECT slot, item_entry FROM %s WHERE guid=%u",
		APPLY_TABLE, guid))
	local result = {}
	if q then
		repeat
			table.insert(result, {slot = q:GetUInt8(0), item = q:GetUInt32(1)})
		until not q:NextRow()
	end
	return result
end

local function SendSync(player)
	local rows = GetAllApplied(player:GetGUIDLow())
	local parts = {}
	for _, row in ipairs(rows) do
		-- FIX ROUND TRANSMOG-27 : row.slot est stocke 0-based (cf. OnAddonMsg),
		-- le client attend sa propre numerotation 1-based (GetSlotID()).
		table.insert(parts, string.format("%d:%d", row.slot + 1, row.item))
	end
	player:SendAddonMessage("ASMSG_TRANSMOG_SYNC", table.concat(parts, ","), CHAT_MSG_WHISPER, player)
end

-- ============================================================
-- 5) Reception du message client (ADDON_EVENT_ON_MESSAGE = 30)
-- ============================================================

local function OnAddonMsg(event, sender, msgType, prefix, msg, target)
	if prefix ~= "ACMSG_TRANSMOG_APPLY" or not sender or not msg then
		return
	end

	local slotStr, itemStr = msg:match("^(%d+):(%d+)$")
	local clientSlotID = tonumber(slotStr)
	local itemEntry = tonumber(itemStr)
	if not clientSlotID or not itemEntry then
		return
	end

	-- FIX ROUND TRANSMOG-27 : le client (TransmogLocationMixin:GetSlotID(),
	-- lui-meme base sur l'API Blizzard GetInventorySlotInfo) numerote les
	-- emplacements en 1-based (HEADSLOT=1, SHOULDERSLOT=3, CHESTSLOT=5, ...),
	-- alors que ce script utilise partout ailleurs (EQUIPMENT_SLOTS,
	-- ApplyVisual/PLAYER_VISIBLE_ITEM_x_ENTRYID, GetItemByPos, l'evenement
	-- natif PLAYER_EVENT_ON_EQUIP) la numerotation 0-based de TrinityCore/
	-- Eluna (EQUIPMENT_SLOT_HEAD=0, ...). Les deux numerotations sont
	-- decalees d'exactement 1 -- confirme en jeu : cliquer Tete (slot client
	-- 1) donnait "Emplacement invalide" (slot serveur 1 = Cou, absent de
	-- EQUIPMENT_SLOTS), et pour les autres emplacements la transmog se
	-- serait appliquee AU MAUVAIS EMPLACEMENT sans erreur visible. On
	-- convertit donc une fois ici ; clientSlotID reste l'unique numero
	-- envoye/renvoye au client (SendSync et la confirmation ci-dessous),
	-- slotID (0-based) est utilise pour tout le reste en interne.
	local slotID = clientSlotID - 1

	local guid = sender:GetGUIDLow()

	if itemEntry == 0 then
		-- Revert : effacer la sauvegarde, remontrer l'objet reellement equipe.
		ClearApplied(guid, slotID)
		RestoreBaseVisual(sender, slotID)
		sender:SendAddonMessage("ASMSG_TRANSMOG_APPLIED", string.format("%d:0", clientSlotID), CHAT_MSG_WHISPER, sender)
		return
	end

	if not EQUIPMENT_SLOTS[slotID] then
		sender:SendAddonMessage("ASMSG_TRANSMOG_ERROR", "Emplacement invalide.", CHAT_MSG_WHISPER, sender)
		return
	end

	-- FIX ROUND TRANSMOG-29 : le round 27 avait retire toute verification de
	-- contenu (n'importe quel objet du jeu, jamais vu ni possede, pouvait
	-- etre applique) -- precision de l'utilisateur : trop large. On exige
	-- desormais que l'apparence soit COLLECTIONNEE (deja portee au moins une
	-- fois) OU PRESENTE DANS LES SACS actuellement (meme jamais equipee).
	-- IsItemCompatible (correspondance de type d'armure avec l'emplacement)
	-- reste volontairement NON appelee : le melange de types d'armure
	-- (Tete Tissu sur un perso Cuir, etc.) reste autorise, seule la
	-- verification de possession est reintroduite ici.
	if not IsAppearanceCollected(guid, itemEntry) and not PlayerHasItemInBags(sender, itemEntry) then
		sender:SendAddonMessage("ASMSG_TRANSMOG_ERROR", "Apparence non debloquee (ni collectionnee, ni dans vos sacs).", CHAT_MSG_WHISPER, sender)
		return
	end

	-- EQUIPMENT_SLOTS ci-dessus garde uniquement la liste des emplacements
	-- transmogables DU TOUT (meme limite qu'a la retail : pas de transmog
	-- sur cou/bagues/bijoux/tabard/chemise).

	-- Round Transmog-7 : le cout est verifie/preleve ICI cote serveur (source
	-- de verite), pas seulement affiche cote client. GetCoinage/ModifyMoney
	-- sont les memes appels que TransmogrifierServer.lua.
	local playerMoney = sender:GetCoinage()
	if playerMoney < TRANSMOG_COST_PER_SLOT then
		sender:SendAddonMessage("ASMSG_TRANSMOG_ERROR", "Argent insuffisant pour la transmogrification.", CHAT_MSG_WHISPER, sender)
		return
	end
	sender:ModifyMoney(-TRANSMOG_COST_PER_SLOT)

	SaveApplied(guid, slotID, itemEntry)
	ApplyVisual(sender, slotID, itemEntry)
	sender:SendAddonMessage("ASMSG_TRANSMOG_APPLIED", string.format("%d:%d", clientSlotID, itemEntry), CHAT_MSG_WHISPER, sender)
end

-- ============================================================
-- 6) Reapplication automatique (login + equipement)
-- ============================================================

-- PLAYER_EVENT_ON_LOGIN = 3
--
-- FIX ROUND TRANSMOG-30 (piste, non confirmee a 100% cote client mais
-- defensive et sans risque) : signale par l'utilisateur -- une
-- transmogrification appliquee ne survit pas a une deconnexion/reconnexion.
-- Le mecanisme (PLAYER_VISIBLE_ITEM_x_ENTRYID) est un champ reseau natif : une
-- fois pose, il DEVRAIT survivre tant que rien ne le reecrit. Hypothese la
-- plus probable : au login/entree en monde, le coeur du jeu envoie lui-meme
-- (a un moment variable, selon charge serveur/latence) les VRAIES valeurs
-- d'equipement au client -- si cet envoi natif arrive APRES notre unique
-- ecriture a 1500ms, il ecrase silencieusement notre apparence transmogifiee
-- par l'objet reellement equipe. Un delai fixe unique est fragile face a ce
-- genre de course. On repete donc l'application plusieurs fois sur les
-- premieres secondes suivant le login (notre ecriture la PLUS TARDIVE gagne
-- alors quoi qu'il arrive), plutot qu'une seule fois.
local REAPPLY_ON_LOGIN_ATTEMPTS = 5
local REAPPLY_ON_LOGIN_DELAY_MS = 1000

local function OnLogin(event, player)
	local guid = player:GetGUID()

	local function ReapplyTick()
		local plr = GetPlayerByGUID(guid)
		if not plr then
			return
		end

		local rows = GetAllApplied(plr:GetGUIDLow())
		for _, row in ipairs(rows) do
			ApplyVisual(plr, row.slot, row.item)
		end

		SendSync(plr)
	end

	player:RegisterEvent(ReapplyTick, REAPPLY_ON_LOGIN_DELAY_MS, REAPPLY_ON_LOGIN_ATTEMPTS)
end

-- PLAYER_EVENT_ON_EQUIP = 29 -- (event, player, item, bag, slot)
local function OnEquip(event, player, item, bag, slot)
	if bag ~= 255 then
		return
	end

	local slotID = slot
	if not EQUIPMENT_SLOTS[slotID] then
		return
	end

	local guid = player:GetGUID()

	player:RegisterEvent(function()
		local plr = GetPlayerByGUID(guid)
		if not plr then
			return
		end

		local q = CharDBQuery(string.format(
			"SELECT item_entry FROM %s WHERE guid=%u AND slot=%u",
			APPLY_TABLE, plr:GetGUIDLow(), slotID))
		if q then
			ApplyVisual(plr, slotID, q:GetUInt32(0))
		end
	end, 300, 1)
end

RegisterServerEvent(30, OnAddonMsg) -- ADDON_EVENT_ON_MESSAGE
RegisterPlayerEvent(3, OnLogin)     -- PLAYER_EVENT_ON_LOGIN
RegisterPlayerEvent(29, OnEquip)    -- PLAYER_EVENT_ON_EQUIP
