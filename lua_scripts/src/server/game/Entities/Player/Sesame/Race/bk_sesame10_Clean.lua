--[[


██████╗ ██████╗ ██████╗ ███████╗                      ██████╗ ██╗      █████╗ ███╗   ██╗██╗  ██╗
██╔════╝██╔═══██╗██╔══██╗██╔════╝                      ██╔══██╗██║     ██╔══██╗████╗  ██║██║ ██╔╝
██║     ██║   ██║██║  ██║█████╗      █████╗            ██████╔╝██║     ███████║██╔██╗ ██║█████╔╝
██║     ██║   ██║██║  ██║██╔══╝      ╚════╝            ██╔══██╗██║     ██╔══██║██║╚██╗██║██╔═██╗
╚██████╗╚██████╔╝██████╔╝███████╗              ███████╗██████╔╝███████╗██║  ██║██║ ╚████║██║  ██╗
╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝              ╚══════╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝


]]--

local itemid = 143280;

local function onUseSesame(event, player, item, target)
  local iEntry = item:GetEntry()
  local pLevel = player:GetLevel()
  local pClass = player:GetClass()
  if iEntry == itemid then
    if pLevel ~= 10 then
	if (player:GetCoinage() >= 0) then
            player:ModifyMoney(1000000)
		  end
      --[[ On va chercher les objets stockés en Base de donnée correspondant à la classe du joueur ]]--
      local getItem = WorldDBQuery('SELECT entry, count from `auc_eluna`.`mod_sesametrainerfak` WHERE classid = '..pClass..';')
      if getItem ~= nil then
        repeat
          local iEntry = getItem:GetUInt32(0)
          local eCount = getItem:GetUInt32(1)
          if CountEmptyInventorySpaces(player) ~= 0 then
            player:AddItem(iEntry, eCount)
          else
            SendMail("Votre équipement!", "Syphréna vous remercie pour votre achat. La sociétés postale à retrouvés ceci pour vous !", player:GetGUIDLow(), 0, 61, 1, 0, 0, iEntry, eCount)
          end
        until not getItem:NextRow()
      else
        player:SendNotification('Une erreure est survenue, merci de contacter un administrateur.')
      end
      player:SetLevel(10)
    else
      player:SendNotification('Vous ne pouvez plus utiliser cet objet, votre sésame est limité à un par personnage !')
      return false;
    end
  end
end
RegisterItemEvent(itemid, 2, onUseSesame)
