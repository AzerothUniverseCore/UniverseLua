local NpcId = 55918
local MenuId = 55918

local pathTable = {}

table.insert(pathTable, {772, 920.522, 4566.78, 233.891})
table.insert(pathTable, {772, 929.465, 4575.8, 238.278})
table.insert(pathTable, {772, 986.223, 4630.43, 252.202})
table.insert(pathTable, {772, 1152.48, 4790.42, 252.202})
table.insert(pathTable, {772, 1075.16, 4922.29, 222.705})
table.insert(pathTable, {772, 886.221, 5009.29, 260.383})
table.insert(pathTable, {772, 684.365, 4857.57, 199.339})
table.insert(pathTable, {772, 446.567, 4607.81, 174.554})
table.insert(pathTable, {772, 245.948, 4327.19, 146.064})
table.insert(pathTable, {772, 97.4595, 4086.76, 182.717})
table.insert(pathTable, {772, 73.5675, 3817.19, 183.629})
table.insert(pathTable, {772, 256.358, 3805.53, 189.337})
table.insert(pathTable, {772, 459.687, 3761.05, 185.88})
table.insert(pathTable, {772, 619.942, 3707.26, 210.203})
table.insert(pathTable, {772, 745.435, 3664.94, 194.005})

local WanderingIslefivePath = AddTaxiPath(pathTable, 55918, 55918)

local function OnGossipHello(event, player, object)
	player:GossipClearMenu()
	player:GossipSetText('Bonjour '..player:GetName()..'!\n\nJe propose un voyage au Temple des Cinq matins.\n\nVoulez-vous y aller ?');
	player:GossipMenuAddItem(2, "Oui ! Allez au Temple des Cinq matins !", 1, 1)
	player:GossipMenuAddItem(7, 'Pas maintenant... Au revoir !', 1, 2);
	player:GossipSendMenu(0x7FFFFFFF, object)
    end
	
	local function OnGossipSelect(event, player, object, sender, intid, code, menuid)
	if (intid == 1) then
		player:StartTaxi(WanderingIslefivePath)
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