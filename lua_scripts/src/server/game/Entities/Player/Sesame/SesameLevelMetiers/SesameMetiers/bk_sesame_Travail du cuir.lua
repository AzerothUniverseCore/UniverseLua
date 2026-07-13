--[[


██████╗ ██████╗ ██████╗ ███████╗                      ██████╗ ██╗      █████╗ ███╗   ██╗██╗  ██╗
██╔════╝██╔═══██╗██╔══██╗██╔════╝                      ██╔══██╗██║     ██╔══██╗████╗  ██║██║ ██╔╝
██║     ██║   ██║██║  ██║█████╗      █████╗            ██████╔╝██║     ███████║██╔██╗ ██║█████╔╝
██║     ██║   ██║██║  ██║██╔══╝      ╚════╝            ██╔══██╗██║     ██╔══██║██║╚██╗██║██╔═██╗
╚██████╗╚██████╔╝██████╔╝███████╗              ███████╗██████╔╝███████╗██║  ██║██║ ╚████║██║  ██╗
╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝              ╚══════╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝


]]--
local jobLib = require('jobLib');

local itemid = 9000207;

local function onUseSesame(event, player, item, target)
  local iEntry = item:GetEntry()
  local pLevel = player:GetLevel()
  local pClass = player:GetClass()
  if iEntry == itemid then
    if pLevel ~= 0 then
	if (player:GetCoinage() >= 0) then
            player:ModifyMoney(0)
		  end
		  
		  jobLib.learnJob(player, 'Leatherworking');
		  player:SetSkill( 165, 0, 450, 450 )
		  
      --[[ On va chercher les objets stockés en Base de donnée correspondant à la classe du joueur ]]--
      local getItem = WorldDBQuery('SELECT entry, count from `auc_eluna`.`mod_sesametrainerfak` WHERE classid = '..pClass..';')
      if getItem ~= nil then
        repeat
          local iEntry = getItem:GetUInt32(0)
          local eCount = getItem:GetUInt32(1)
          if CountEmptyInventorySpaces(player) ~= 0 then
            player:AddItem(iEntry, eCount)
          else
            SendMail("", player:GetGUIDLow(), 0, 61, 1, 0, 0, iEntry, eCount)
          end
        until not getItem:NextRow()
      else
        player:SendNotification('')
      end
      player:SetLevel(0)
    else
      player:SendNotification('')
      return false;
    end
  end
end
RegisterItemEvent(itemid, 2, onUseSesame)
