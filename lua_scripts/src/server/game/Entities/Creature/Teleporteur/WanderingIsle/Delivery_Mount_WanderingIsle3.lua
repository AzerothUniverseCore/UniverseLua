local NpcId = 12015
local MenuId = 12015

local pathTable = {}

table.insert(pathTable, {772, 928.319, 3609.18, 199.291})
table.insert(pathTable, {772, 935.032, 3611.79, 207.864})
table.insert(pathTable, {772, 940.92, 3611.56, 218.88})
table.insert(pathTable, {772, 950.671, 3604.47, 227.133})
table.insert(pathTable, {772, 946.69, 3595.3, 236.71})
table.insert(pathTable, {772, 936.168, 3598.53, 244.554})
table.insert(pathTable, {772, 938.264, 3611.2, 252.738})
table.insert(pathTable, {772, 930.935, 3609, 257.779})
table.insert(pathTable, {772, 919.899, 3605.55, 252.077})

local WanderingIsletreePath = AddTaxiPath(pathTable, 142785, 142785)

local function OnGossipHello(event, player, object)
	player:GossipClearMenu()
	player:GossipSetText('Bonjour '..player:GetName()..'!\n\nJe propose un voyage à Brise-du-Matin.\n\nVoulez-vous y aller ?');
	player:GossipMenuAddItem(2, "Oui ! Allez à Brise-du-Matin !", 1, 1)
	player:GossipMenuAddItem(7, 'Pas maintenant... Au revoir !', 1, 2);
	player:GossipSendMenu(0x7FFFFFFF, object)
    end
	
	local function OnGossipSelect(event, player, object, sender, intid, code, menuid)
	if (intid == 1) then
		player:StartTaxi(WanderingIsletreePath)
        player:GossipComplete();
		end
		
		if(intid == 2) then
		player:SendNotification('|cffff0000Reviens me voir si tu veux voyager.|r');
		player:GossipComplete();
	end
end
		
RegisterCreatureGossipEvent(NpcId, 1, OnGossipHello)
RegisterCreatureGossipEvent(NpcId, 2, OnGossipSelect)
RegisterPlayerGossipEvent(MenuId, 2, OnGossipSelect)