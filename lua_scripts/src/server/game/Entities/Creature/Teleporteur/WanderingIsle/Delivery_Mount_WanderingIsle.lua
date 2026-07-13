local NpcId = 12012
local MenuId = 12012

local pathTable = {}

table.insert(pathTable, {772, 999.449, 2861.7, 91.1337})
table.insert(pathTable, {772, 961.699, 2843.11, 95.1522})
table.insert(pathTable, {772, 936.608, 2831.58, 96.27})
table.insert(pathTable, {772, 896.838, 2814.64, 96.8861})
table.insert(pathTable, {772, 855.911, 2801.67, 96.2759})
table.insert(pathTable, {772, 806.626, 2789.82, 98.9668})
table.insert(pathTable, {772, 758.189, 2822.2, 104.969})
table.insert(pathTable, {772, 751.226, 2842.32, 101.865})
table.insert(pathTable, {772, 741.01, 2897.18, 96.8329})
table.insert(pathTable, {772, 695.412, 2950.93, 93.4459})
table.insert(pathTable, {772, 630.49, 3021.08, 100.215})
table.insert(pathTable, {772, 616.451, 3053.63, 98.7142})
table.insert(pathTable, {772, 618.17, 3099.57, 96.7941})
table.insert(pathTable, {772, 628.979, 3140.12, 87.7456})

local WanderingIslePath = AddTaxiPath(pathTable, 142785, 142785)

local function OnGossipHello(event, player, object)
	player:GossipClearMenu()
	player:GossipSetText('Bonjour '..player:GetName()..'!\n\nJe propose un voyage à la Ferme Dai-Lo.\n\nVoulez-vous y aller ?');
	player:GossipMenuAddItem(2, "Oui ! Allez à la Ferme Dai-Lo !", 1, 1)
	player:GossipMenuAddItem(7, 'Pas maintenant... Au revoir !', 1, 2);
	player:GossipSendMenu(0x7FFFFFFF, object)
    end
	
	local function OnGossipSelect(event, player, object, sender, intid, code, menuid)
	if (intid == 1) then
		player:StartTaxi(WanderingIslePath)
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