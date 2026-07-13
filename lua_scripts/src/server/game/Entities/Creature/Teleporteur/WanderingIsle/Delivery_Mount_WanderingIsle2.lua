local NpcId = 12014
local MenuId = 12014

local pathTable = {}

table.insert(pathTable, {772, 592.525, 3151.21, 89.6656})
table.insert(pathTable, {772, 581.28, 3153.39, 93.3352})
table.insert(pathTable, {772, 554.145, 3164.88, 96.9031})
table.insert(pathTable, {772, 541.816, 3204.78, 96.0596})
table.insert(pathTable, {772, 507.396, 3245.46, 98.1551})
table.insert(pathTable, {772, 524.775, 3320.85, 100.867})
table.insert(pathTable, {772, 585.977, 3374.01, 116.37})
table.insert(pathTable, {772, 690.525, 3456.84, 147.159})
table.insert(pathTable, {772, 749.64, 3514.78, 161.314})
table.insert(pathTable, {772, 775.383, 3598.31, 175.195})
table.insert(pathTable, {772, 809.745, 3602.65, 206.096})
table.insert(pathTable, {772, 884.534, 3605.17, 198.891})
table.insert(pathTable, {772, 920.19, 3604.59, 196.515})

local WanderingIsletwoPath = AddTaxiPath(pathTable, 142785, 142785)

local function OnGossipHello(event, player, object)
	player:GossipClearMenu()
	player:GossipSetText('Bonjour '..player:GetName()..'!\n\nJe propose un voyage au Temple des Cinq matins.\n\nVoulez-vous y aller ?');
	player:GossipMenuAddItem(2, "Oui ! Allez au Temple des Cinq matins !", 1, 1)
	player:GossipMenuAddItem(7, 'Pas maintenant... Au revoir !', 1, 2);
	player:GossipSendMenu(0x7FFFFFFF, object)
    end
	
	local function OnGossipSelect(event, player, object, sender, intid, code, menuid)
	if (intid == 1) then
		player:StartTaxi(WanderingIsletwoPath)
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