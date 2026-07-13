local NpcId = 167027
local MenuId = 167027
local QUEST_ID_ALLIANCE = 55193
local QUEST_ID_HORDE    = 59940

local pathTable = {}

table.insert(pathTable, {859, 109.815, -2412.36, 95.7007})
table.insert(pathTable, {859, 121.212, -2403.37, 97.9435})
table.insert(pathTable, {859, 140.864, -2385.64, 97.2217})
table.insert(pathTable, {859, 157.014, -2374.13, 96.6915})
table.insert(pathTable, {859, 163.487, -2343.93, 101,989})
table.insert(pathTable, {859, 169.662, -2296.37, 110.338})
table.insert(pathTable, {859, 182.408, -2252.96, 113.234})
table.insert(pathTable, {859, 214.726, -2242.2, 144.3})
table.insert(pathTable, {859, 264.218, -2244.16, 147.527})
table.insert(pathTable, {859, 280.559, -2295.67, 137.154})
table.insert(pathTable, {859, 279.998, -2346.72, 125.425})
table.insert(pathTable, {859, 254.75, -2382.55, 122.676})
table.insert(pathTable, {859, 205.583, -2411.69, 121.092})
table.insert(pathTable, {859, 154.103, -2384.61, 110.305})
table.insert(pathTable, {859, 123.024, -2403.4, 100.569})
table.insert(pathTable, {859, 108.253, -2413.72, 95.9917})

local IsleReachAHPath = AddTaxiPath(pathTable, 167027, 167027)

local function OnGossipHello(event, player, object)
	player:GossipClearMenu()
	player:GossipSetText('Bonjour '..player:GetName()..'!\n\nJe propose un voyage rapide en exploro-matic 5000 pour la visite des Confins de l’Exil.\n\nVoulez-vous visitez ?');
	player:GossipMenuAddItem(2, "Oui, pourquoi pas ! Prêt à embarquer !", 1, 1)
	player:GossipMenuAddItem(7, 'Pas maintenant... Au revoir !', 1, 2);
	player:GossipSendMenu(0x7FFFFFFF, object)
    end
	
	local function OnGossipSelect(event, player, object, sender, intid, code, menuid)
	if (intid == 1) then
		player:StartTaxi(IsleReachAHPath)
        player:GossipComplete();
		if (player:HasQuest(QUEST_ID_ALLIANCE)) then
            player:CompleteQuest(QUEST_ID_ALLIANCE)
        end
        if (player:HasQuest(QUEST_ID_HORDE)) then
            player:CompleteQuest(QUEST_ID_HORDE)
        end
	end
		
		if(intid == 2) then
		player:SendNotification('|cffff0000Reviens me voir si tu veux voyager.|r');
		player:GossipComplete();
	end
end
		
RegisterCreatureGossipEvent(NpcId, 1, OnGossipHello)
RegisterCreatureGossipEvent(NpcId, 2, OnGossipSelect)
RegisterPlayerGossipEvent(MenuId, 2, OnGossipSelect)