--[[


██████╗ ██████╗ ██████╗ ███████╗                      ██████╗ ██╗      █████╗ ███╗   ██╗██╗  ██╗
██╔════╝██╔═══██╗██╔══██╗██╔════╝                      ██╔══██╗██║     ██╔══██╗████╗  ██║██║ ██╔╝
██║     ██║   ██║██║  ██║█████╗      █████╗            ██████╔╝██║     ███████║██╔██╗ ██║█████╔╝
██║     ██║   ██║██║  ██║██╔══╝      ╚════╝            ██╔══██╗██║     ██╔══██║██║╚██╗██║██╔═██╗
╚██████╗╚██████╔╝██████╔╝███████╗              ███████╗██████╔╝███████╗██║  ██║██║ ╚████║██║  ██╗
╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝              ╚══════╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝


]]--
local jobLib = require('jobLib');


local itemid = 9000103;

local Rebirth = {};
Rebirth.Config = {
  --LevelRequisPourLancerLeRebirth
  MinLvl = 80;
  --DBName
  DbName = 'auc_eluna';
  --RebirthLevel
  Level = 0; 
};

--CréationDeTableDB
CharDBQuery('CREATE DATABASE IF NOT EXISTS `'..Rebirth.Config.DbName..'` CHARACTER SET utf8mb4;');
CharDBQuery('CREATE TABLE IF NOT EXISTS `'..Rebirth.Config.DbName..'`.`Rebirth_characters` ( `guid` INT(10) NOT NULL, `account_id` INT(10) NOT NULL, `RebirthLevel` INT(10) NOT NULL DEFAULT 0, PRIMARY KEY (`guid`, `account_id`) );');

Rebirth.Level={
  level
};

function Rebirth.GetRebirth(player)

    local pGuid = player:GetGUIDLow();

    local RebirthNiv = CharDBQuery('SELECT RebirthLevel FROM `'..Rebirth.Config.DbName..'`.`Rebirth_characters` WHERE guid = '..pGuid..';');
    
    if(RebirthNiv)then
        Rebirth.Level[pGuid] = {
            level = RebirthNiv:GetUInt32(0),
        }
    else
        local createAccount = CharDBQuery('INSERT IGNORE INTO `'..Rebirth.Config.DbName..'`.`Rebirth_characters` (guid, account_id) VALUES ('..pGuid..', '..player:GetAccountId()..');');
        Rebirth.Level[pGuid] = {
            level = 0,
        }
    end
    return Rebirth.Level[pGuid].level;
end


local function onUseSesame(event, player, item, target)
  local iEntry = item:GetEntry()
  local pLevel = player:GetLevel()
  local pClass = player:GetClass()
  local pGuid = player:GetGUIDLow();
  Rebirth.GetRebirth(player);

  if iEntry == itemid then
    if(Rebirth.Level[pGuid].level == 0 ) then
      if pLevel ~= 80 then
	  if (player:GetCoinage() >= 0) then
            player:ModifyMoney(18000000)
		  end
		  
		  jobLib.learnJob(player, 'Enchanting');
		  player:SetSkill( 333, 0, 450, 450 )
		  
        --[[ On va chercher les objets stockés en Base de donnée correspondant à la classe du joueur ]]--
        local getItem = WorldDBQuery('SELECT entry, count from `auc_eluna`.`mod_sesamestuff` WHERE classid = '..pClass..';')
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
          player:SendNotification('Une erreure est survenue, merci de contacter un administrateur.')
        end
        player:SetLevel(80)
        else
        player:SendNotification('Vous ne pouvez plus utiliser cet objet !')
        return false;
      end
    else
      player:SendNotification('Vous avez commencé votre rebirth, le sésame ne fonctionneras pas.');
    end
  end
end
RegisterItemEvent(itemid, 2, onUseSesame)