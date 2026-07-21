-- Mod_Me_ConvertServer.lua
-- Serveur Eluna pour la conversion des Breloques Supérieures du site
-- (auc_website.users.dp) en objet du jeu "Breloque Supérieure" (item 7000655).
--
-- Déclenchement : PNJ 2000040 (même créature que mod_me_convert_superior_command.lua
-- et que le bloc gossip "optionnel" de Mod_Me_PanelServer.lua).
--
-- /!\ IMPORTANT : Eluna exécute TOUS les handlers RegisterCreatureGossipEvent
-- enregistrés sur cette créature+événement, dans leur ordre d'enregistrement.
-- Si mod_me_convert_superior_command.lua (menu natif, MenuId 999) et/ou le bloc
-- gossip optionnel de Mod_Me_PanelServer.lua sont encore chargés en même temps
-- que ce script, leurs fenêtres de gossip natives peuvent apparaître en même
-- temps que/à la place de cette UI AIO, selon l'ordre de chargement des scripts.
-- Pour un fonctionnement garanti et sans collision, commentez/désactivez les
-- RegisterCreatureGossipEvent(2000040, ...) des deux autres scripts si vous ne
-- souhaitez garder que cette nouvelle UI de conversion sur ce PNJ.

local AIO = AIO or require("AIO")

local ConvertHandlers = AIO.AddHandlers("ModMeConvert", {})

local CONVERT_NPC_ENTRY = 2000040
local CONVERT_ITEM_ID = 7000655
local MAIL_EXPIRE_DAYS = 30

-- ===================== Helpers =====================

local function GetPlayerDP(player)
    local result = CharDBQuery('SELECT dp FROM `auc_website`.`users` WHERE username = "'..player:GetAccountName()..'";')
    if result then
        return result:GetUInt32(0)
    end
    return 0
end

-- Envoi de l'objet par courrier lorsque l'ajout direct à l'inventaire échoue
-- (sacs pleins). Utilise le schéma standard TrinityCore (mail / mail_items /
-- item_instance) car Eluna n'expose pas de fonction native "AddItemToMail".
-- /!\ Zone à tester en jeu : les ID (item_instance.guid / mail.id) sont
-- calculés via MAX(...)+1, ce qui est la méthode communément utilisée dans les
-- scripts Eluna mais n'est pas garanti à 100% contre une collision en cas
-- d'écriture concurrente. À vérifier en conditions réelles sur le serveur.
-- Textes du courrier de secours (sacs pleins), localisés selon la langue du
-- client au moment de la demande de conversion (envoyée par le client, voir
-- ConvertHandlers.RequestConvert ci-dessous).
local MAIL_TEXT = {
    frFR = {
        subject = "Conversion de Breloques",
        body = "Voici votre/vos Breloque(s) Superieure(s) issue(s) de la conversion. Votre inventaire etait plein au moment de la conversion.",
    },
    enUS = {
        subject = "Charm Conversion",
        body = "Here is/are your Greater Charm(s) from the conversion. Your bags were full at the time of the conversion.",
    },
}

local function SendItemByMail(player, itemEntry, count, locale)
    local guidResult = CharDBQuery("SELECT MAX(guid) FROM item_instance;")
    local newItemGuid = 1
    if guidResult and not guidResult:IsNull(0) then
        newItemGuid = guidResult:GetUInt32(0) + 1
    end

    local mailIdResult = CharDBQuery("SELECT MAX(id) FROM mail;")
    local newMailId = 1
    if mailIdResult and not mailIdResult:IsNull(0) then
        newMailId = mailIdResult:GetUInt32(0) + 1
    end

    local texts = MAIL_TEXT[locale] or MAIL_TEXT.frFR
    local receiverGuid = player:GetGUIDLow()
    local subject = texts.subject
    local body = texts.body
    local expireTime = os.time() + (MAIL_EXPIRE_DAYS * 24 * 60 * 60)
    local deliverTime = os.time()

    CharDBExecute(string.format(
        "INSERT INTO item_instance (guid, itemEntry, owner_guid, count, duration, flags, durability) VALUES (%d, %d, %d, %d, 0, 0, 0);",
        newItemGuid, itemEntry, receiverGuid, count
    ))

    -- messageType = 1 (MAIL_CREATURE) : le champ "sender" est interprété comme
    -- l'entry de la créature émettrice (et non un guid de personnage).
    CharDBExecute(string.format(
        'INSERT INTO mail (id, messageType, stationery, mailTemplateId, sender, receiver, subject, body, has_items, expire_time, deliver_time, money, cod, checked) VALUES (%d, 1, 41, 0, %d, %d, "%s", "%s", 1, %d, %d, 0, 0, 0);',
        newMailId, CONVERT_NPC_ENTRY, receiverGuid, subject, body, expireTime, deliverTime
    ))

    CharDBExecute(string.format(
        "INSERT INTO mail_items (mail_id, item_guid, receiver) VALUES (%d, %d, %d);",
        newMailId, newItemGuid, receiverGuid
    ))

    return true
end

-- ===================== Handlers AIO =====================

-- locale ("frFR"/"enUS", envoyee par le client via GetLocale()) : conservee
-- ici uniquement pour le texte du courrier de secours (sacs pleins), car les
-- messages de statut affiches dans l'UI sont desormais construits cote
-- client a partir d'un "code" (voir ConvertHandlers.ConvertResult dans
-- Mod_Me_ConvertClient.lua) plutot que d'un texte en dur envoye par le
-- serveur.
local PlayerLocale = {}

function ConvertHandlers.RequestConvertData(player, locale)
    if locale then
        PlayerLocale[player:GetGUIDLow()] = locale
    end
    local dp = GetPlayerDP(player)
    AIO.Handle(player, "ModMeConvert", "UpdateConvertData", { dp = dp })
end

function ConvertHandlers.RequestConvert(player, amount, locale)
    amount = tonumber(amount)
    if locale then
        PlayerLocale[player:GetGUIDLow()] = locale
    end
    local playerLocale = locale or PlayerLocale[player:GetGUIDLow()]

    if not amount or amount ~= math.floor(amount) or amount <= 0 then
        AIO.Handle(player, "ModMeConvert", "ConvertResult", {
            success = false,
            code = "invalid_amount",
        })
        return
    end

    amount = math.floor(amount)

    local currentDP = GetPlayerDP(player)
    if amount > currentDP then
        AIO.Handle(player, "ModMeConvert", "ConvertResult", {
            success = false,
            code = "insufficient_balance",
            dp = currentDP,
        })
        return
    end

    -- Déduction autoritaire du solde site AVANT l'octroi de l'objet, pour
    -- éviter tout risque de duplication en cas de double-clic/spam.
    CharDBExecute('UPDATE `auc_website`.`users` SET dp = dp - '..amount..' WHERE username = "'..player:GetAccountName()..'";')
    local newDP = currentDP - amount

    local granted = false
    local viaMail = false

    local item = player:AddItem(CONVERT_ITEM_ID, amount)
    if item then
        granted = true
    else
        -- Sacs pleins (ou autre échec) : envoi par courrier, conformément au
        -- choix explicite de l'utilisateur.
        viaMail = SendItemByMail(player, CONVERT_ITEM_ID, amount, playerLocale)
        granted = viaMail
    end

    if not granted then
        -- Filet de sécurité : ni l'ajout direct ni le courrier n'ont
        -- fonctionné, on rembourse intégralement le solde site.
        CharDBExecute('UPDATE `auc_website`.`users` SET dp = dp + '..amount..' WHERE username = "'..player:GetAccountName()..'";')
        AIO.Handle(player, "ModMeConvert", "ConvertResult", {
            success = false,
            code = "failed",
            dp = currentDP,
        })
        return
    end

    CharDBExecute('INSERT IGNORE INTO auc_eluna.mod_me_shop_logs VALUES ('..player:GetGUIDLow()..', "'..os.date()..'", "Conversion Breloques Superieures (site -> jeu) x'..amount..'", 1)')

    AIO.Handle(player, "ModMeConvert", "ConvertResult", {
        success = true,
        code = viaMail and "success_mail" or "success_bag",
        amount = amount,
        dp = newDP,
    })
end

-- ===================== Déclenchement via le PNJ =====================

local function ConvertOnGossipHello(event, player, object)
    -- Ferme immédiatement toute fenêtre de gossip native, puis ouvre l'UI AIO.
    -- Voir l'avertissement en haut de fichier concernant l'ordre des scripts
    -- si d'autres gossip hooks restent enregistrés sur ce PNJ.
    player:GossipComplete()
    AIO.Handle(player, "ModMeConvert", "ShowConvertUI")
end
RegisterCreatureGossipEvent(CONVERT_NPC_ENTRY, 1, ConvertOnGossipHello)
