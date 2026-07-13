local NpcId = 12016
local MenuId = 12016

local pathTable = {}

table.insert(pathTable, {772, 910.778, 3612.88, 253.835})
table.insert(pathTable, {772, 915.773, 3623.44, 254.681})
table.insert(pathTable, {772, 922.559, 3637.8, 255.754})
table.insert(pathTable, {772, 918.383, 3643.92, 260.234})
table.insert(pathTable, {772, 906.1, 3663.59, 280.163})
table.insert(pathTable, {772, 880.057, 3749, 281.402})
table.insert(pathTable, {772, 872.987, 3863.43, 277.985})
table.insert(pathTable, {772, 871.136, 4035, 254.998})
table.insert(pathTable, {772, 907.686, 4106.53, 241.287})
table.insert(pathTable, {772, 967.076, 4136.26, 238.841})
table.insert(pathTable, {772, 1051.4, 4173.36, 234.442})
table.insert(pathTable, {772, 1115.54, 4169.37, 195.787})

local WanderingIslefourPath = AddTaxiPath(pathTable, 142785, 142785)

local function OnGossipHello(event, player, object)
	player:GossipClearMenu()
	player:GossipSetText('Bonjour '..player:GetName()..'!\n\nJe propose un voyage à Brise-du-Matin.\n\nVoulez-vous y aller ?');
	player:GossipMenuAddItem(2, "Oui ! Allez à Brise-du-Matin !", 1, 1)
	player:GossipMenuAddItem(7, 'Pas maintenant... Au revoir !', 1, 2);
	player:GossipSendMenu(0x7FFFFFFF, object)
    end
	
	local function OnGossipSelect(event, player, object, sender, intid, code, menuid)
	if (intid == 1) then
		player:StartTaxi(WanderingIslefourPath)
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