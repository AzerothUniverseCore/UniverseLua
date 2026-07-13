local NpcId = 12013
local MenuId = 12013

local pathTable = {}

table.insert(pathTable, {772, 1295.32, 3919.51, 129.441})
table.insert(pathTable, {772, 1311.6, 3914.96, 126.67})
table.insert(pathTable, {772, 1336.19, 3906.76, 108.338})
table.insert(pathTable, {772, 1344.12, 3894.72, 101.907})
table.insert(pathTable, {772, 1340.62, 3877.7, 98.3263})
table.insert(pathTable, {772, 1330.87, 3854.92, 98.1448})
table.insert(pathTable, {772, 1299.21, 3829.06, 108.821})
table.insert(pathTable, {772, 1228.04, 3730.48, 143.846})
table.insert(pathTable, {772, 1115.05, 3628.16, 189.858})
table.insert(pathTable, {772, 1055.02, 3608.72, 201.146})
table.insert(pathTable, {772, 1005.58, 3603.68, 198.662})
table.insert(pathTable, {772, 966.134, 3605.17, 196.592})

local WanderingIsleonePath = AddTaxiPath(pathTable, 142785, 142785)

local function OnGossipHello(event, player, object)
	player:GossipClearMenu()
	player:GossipSetText('Bonjour '..player:GetName()..'!\n\nJe propose un voyage au Temple des Cinq matins.\n\nVoulez-vous y aller ?');
	player:GossipMenuAddItem(2, "Oui ! Allez au Temple des Cinq matins !", 1, 1)
	player:GossipMenuAddItem(7, 'Pas maintenant... Au revoir !', 1, 2);
	player:GossipSendMenu(0x7FFFFFFF, object)
    end
	
	local function OnGossipSelect(event, player, object, sender, intid, code, menuid)
	if (intid == 1) then
		player:StartTaxi(WanderingIsleonePath)
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