-- Constants
local UNIT_ENTRY = 9000109
local ITEM_ID_SESAME = 900109
local ITEM_ID_OTHER = 900019

local Sesame = {}
Sesame.Config = {
    MinLvl = 200,
    DbName = 'auc_eluna',
    Level = 0,
}

-- Création de la base de données et de la table si elles n'existent pas
local createDatabaseAndTable = function()
    CharDBExecute('CREATE DATABASE IF NOT EXISTS `' .. Sesame.Config.DbName .. '` CHARACTER SET utf8mb4;')
    CharDBExecute([[
        CREATE TABLE IF NOT EXISTS `]] .. Sesame.Config.DbName .. [[`.`sesame_welcome` (
            `account_id` INT(10) NOT NULL, 
            `SesameActive` INT(10) NOT NULL DEFAULT 0, 
            PRIMARY KEY (`account_id`)
        );
    ]])
end
createDatabaseAndTable()

-- Fonction pour obtenir l'état du Sésame pour un joueur
function Sesame.GetWelcomeStatus(player)
    local accountId = player:GetAccountId()
    local result = CharDBQuery('SELECT SesameActive FROM `' .. Sesame.Config.DbName .. '`.`sesame_welcome` WHERE account_id = ' .. accountId .. ';')

    if result then
        return result:GetUInt32(0)
    else
        -- Insérer un nouvel enregistrement si le joueur n'existe pas encore dans la base de données
        CharDBExecute('INSERT IGNORE INTO `' .. Sesame.Config.DbName .. '`.`sesame_welcome` (account_id) VALUES (' .. accountId .. ');')
        return 0
    end
end

-- Fonction pour mettre à jour l'état du Sésame d'un joueur
function Sesame.ActivateSesame(accountId)
    CharDBExecute('UPDATE `' .. Sesame.Config.DbName .. '`.`sesame_welcome` SET `SesameActive` = 1 WHERE account_id = ' .. accountId .. ';')
end

-- Fonction pour gérer l'interaction de bienvenue avec l'NPC
function Sesame.OnGossipHello(event, player, object)
    player:GossipClearMenu()
    player:GossipSetText('Salutations, noble ' .. player:GetName() .. '.\n\nJe suis l\'Avant-garde de la Légion, envoyé par les anciens pour t’accueillir en ces terres d\'Azeroth. En témoignage de ton courage et pour te préparer aux épreuves à venir, je t’offre un Sésame de niveau 80, unique et précieux. Que ta force grandisse et que ton chemin soit glorieux parmi les champions d\'|cff400080Azeroth Universe|r. Sache cependant qu’un seul Sésame est accordé par compte, alors fais-en bon usage.')
    player:GossipMenuAddItem(3, 'Oui, je suis prêt à accepter ce don et à embrasser mon destin.', 1, 100)
	player:GossipMenuAddItem(7, 'Non, je refuse cette offre pour l\'instant. Que nos chemins se croisent à nouveau.', 1, 101)
    player:GossipSendMenu(0x7FFFFFFF, object)
end
RegisterCreatureGossipEvent(UNIT_ENTRY, 1, Sesame.OnGossipHello)

-- Fonction pour gérer la sélection des options dans le menu de l'NPC
function Sesame.OnGossipSelect(event, player, object, sender, intid, code, menu_id)
    local accountId = player:GetAccountId()
    local sesameActive = Sesame.GetWelcomeStatus(player)

    if intid == 100 then
        player:GossipClearMenu()
        player:GossipMenuAddItem(4, 'Nous allons procéder à l\'activation de votre sésame. Êtes-vous prêt ?', 1, 102)
        player:GossipSendMenu(0x7FFFFFFF, object)
    elseif intid == 101 then
        player:SendNotification('Au revoir !')
        player:GossipComplete()
    elseif intid == 102 then
        if sesameActive == 1 then
            player:SendNotification('Désolé, mais vous avez déjà obtenu un Sésame 80. Au revoir !')
        else
            Sesame.ActivateSesame(accountId)
            player:AddItem(ITEM_ID_SESAME, 1)
            player:AddItem(ITEM_ID_OTHER, 1)
            player:SendNotification('Et voici pour votre Sésame 80 ! Au revoir !')
        end
        player:GossipComplete()
    end
end
RegisterCreatureGossipEvent(UNIT_ENTRY, 2, Sesame.OnGossipSelect)
