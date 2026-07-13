--[[


██████╗ ██████╗ ██████╗ ███████╗                      ██████╗ ██╗      █████╗ ███╗   ██╗██╗  ██╗
██╔════╝██╔═══██╗██╔══██╗██╔════╝                      ██╔══██╗██║     ██╔══██╗████╗  ██║██║ ██╔╝
██║     ██║   ██║██║  ██║█████╗      █████╗            ██████╔╝██║     ███████║██╔██╗ ██║█████╔╝
██║     ██║   ██║██║  ██║██╔══╝      ╚════╝            ██╔══██╗██║     ██╔══██║██║╚██╗██║██╔═██╗
╚██████╗╚██████╔╝██████╔╝███████╗              ███████╗██████╔╝███████╗██║  ██║██║ ╚████║██║  ██╗
╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝              ╚══════╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝


]]--
local itemid = 900109

local Sesame = {}
Sesame.Config = {
    MinLvl = 200,
    DbName = 'auc_eluna',
    Level = 0,
}

-- Création de la table dans la base de données si elle n'existe pas
CharDBQuery('CREATE DATABASE IF NOT EXISTS `' .. Sesame.Config.DbName .. '` CHARACTER SET utf8mb4;')
CharDBQuery([[CREATE TABLE IF NOT EXISTS `]] .. Sesame.Config.DbName .. [[`.`sesame_welcome` (
    `account_id` INT(10) NOT NULL,
    `SesameActive` INT(10) NOT NULL DEFAULT 0,
    PRIMARY KEY (`account_id`)
);]])

Sesame.Level = {
    level
}

-- Fonction pour récupérer le statut de Sésame d'un joueur
function Sesame.GetRebirth(player)
    local pGuid = player:GetGUIDLow()
    local SesameWelcome = CharDBQuery('SELECT SesameActive FROM `' .. Sesame.Config.DbName .. '`.`sesame_welcome` WHERE account_id = ' .. player:GetAccountId() .. ';')
    
    if SesameWelcome then
        Sesame.Level[pGuid] = { level = SesameWelcome:GetUInt32(0) }
    else
        CharDBQuery('INSERT IGNORE INTO `' .. Sesame.Config.DbName .. '`.`sesame_welcome` (account_id) VALUES (' .. player:GetAccountId() .. ');')
        Sesame.Level[pGuid] = { level = 1 }
    end
    return Sesame.Level[pGuid].level
end

-- Fonction déclenchée lorsque l'objet Sésame est utilisé
local function onUseSesame(event, player, item, target)
    local iEntry = item:GetEntry()
    local pLevel = player:GetLevel()
    local pClass = player:GetClass()
    local pGuid = player:GetGUIDLow()
    Sesame.GetRebirth(player)

    if iEntry == itemid then
        if Sesame.Level[pGuid].level == 1 then
            if pLevel ~= 80 then
                if player:GetCoinage() >= 0 then
                    player:ModifyMoney(18000000)
                end
                
                -- Ajout de 46 exemplaires de l'item 338404
                player:AddItem(338404, 46)

                -- Ajout d'équipement en fonction de la classe du joueur
                local getItem = WorldDBQuery('SELECT entry, count FROM `auc_eluna`.`mod_sesamestuff` WHERE classid = ' .. pClass .. ';')
                if getItem ~= nil then
                    repeat
                        local iEntry = getItem:GetUInt32(0)
                        local eCount = getItem:GetUInt32(1)
                        if CountEmptyInventorySpaces(player) ~= 0 then
                            player:AddItem(iEntry, eCount)
                        else
                            SendMail("Votre équipement!", "Syphréna à retrouvés ceci pour vous !", player:GetGUIDLow(), 0, 61, 1, 0, 0, iEntry, eCount)
                        end
                    until not getItem:NextRow()
                else
                    player:SendNotification('Une erreur est survenue, merci de contacter un administrateur.')
                end
                
                -- Réglage du niveau du joueur à 80
                player:SetLevel(80)
            else
                player:SendNotification('Vous ne pouvez plus utiliser cet objet !')
                return false
            end
        else
            player:SendNotification('Vous avez déjà eu votre Sésame, le sésame ne fonctionne plus.')
        end
    end
end
RegisterItemEvent(itemid, 2, onUseSesame)
