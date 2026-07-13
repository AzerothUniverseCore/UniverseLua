local NpcId = 338035
local MenuId = 338035
local QUEST_ID = 338035

local pathTable = {}

table.insert(pathTable, {807, 11598.6, 11889.8, 13.4022})
table.insert(pathTable, {807, 11617.8, 11881.5, 24.178})
table.insert(pathTable, {807, 11675.6, 11860.7, 40.5854})
table.insert(pathTable, {807, 11775.4, 11861.4, 58.7932})
table.insert(pathTable, {807, 11839.6, 11886.1, 63.0396})
table.insert(pathTable, {807, 11902.1, 11967.5, 72.1884})
table.insert(pathTable, {807, 11917.3, 12063.6, 92.9065})
table.insert(pathTable, {807, 11947.8, 12130.8, 128.189})
table.insert(pathTable, {807, 11987.5, 12217.6, 170.833})
table.insert(pathTable, {807, 12019.6, 12322.5, 161.44})
table.insert(pathTable, {807, 12095.7, 12342.3, 147.145})
table.insert(pathTable, {807, 12204.3, 12351.2, 112.783})
table.insert(pathTable, {807, 12304.8, 12378.9, 80.7057})
table.insert(pathTable, {807, 12368.5, 12416.7, 71.2307})
table.insert(pathTable, {807, 12402.5, 12435.2, 68.0916})
table.insert(pathTable, {807, 12423.2, 12478.6, 50.9714})
table.insert(pathTable, {807, 12450.9, 12539.2, 49.0221})
table.insert(pathTable, {807, 12474.4, 12588.3, 49.7146})
table.insert(pathTable, {807, 12478.5, 12620, 43.0805})
table.insert(pathTable, {807, 12480.5, 12682, 29.7677})
table.insert(pathTable, {807, 12469.2, 12707.9, 22.1237})
table.insert(pathTable, {807, 12451.8, 12739.6, 12.0206})
table.insert(pathTable, {807, 12439.9, 12765.9, 16.0927})
table.insert(pathTable, {807, 12426.8, 12776.9, 13.5018})
table.insert(pathTable, {807, 12403.5, 12783.4, 11.8271})
table.insert(pathTable, {807, 12381.7, 12781.1, 13.7917})
table.insert(pathTable, {807, 12344.2, 12774.3, 10.3323})
table.insert(pathTable, {807, 12321.4, 12758.1, 11.1023})
table.insert(pathTable, {807, 12303.1, 12735.2, 17.4575})
table.insert(pathTable, {807, 12260.4, 12687.6, 18.5685})
table.insert(pathTable, {807, 12231.7, 12637, 26.3614})
table.insert(pathTable, {807, 12189.4, 12593.1, 32.556})
table.insert(pathTable, {807, 12166.5, 12541.9, 32.5951})
table.insert(pathTable, {807, 12135.8, 12462.2, 37.4528})
table.insert(pathTable, {807, 12091.2, 12375.7, 60.4113})
table.insert(pathTable, {807, 12016.1, 12307.1, 106.045})
table.insert(pathTable, {807, 11972, 12250.6, 131.813})
table.insert(pathTable, {807, 11925.4, 12211.6, 128.517})
table.insert(pathTable, {807, 11827.5, 12182.1, 100.162})
table.insert(pathTable, {807, 11765.9, 12159.4, 83.5916})
table.insert(pathTable, {807, 11732, 12120.7, 76.4846})
table.insert(pathTable, {807, 11696.7, 12051, 71.5036})
table.insert(pathTable, {807, 11737.6, 11945.9, 69.9049})
table.insert(pathTable, {807, 11728.8, 11870.1, 78.8769})
table.insert(pathTable, {807, 11701.7, 11857, 78.0085})
table.insert(pathTable, {807, 11660, 11853.7, 58.0235})
table.insert(pathTable, {807, 11634.7, 11866.4, 40.6186})
table.insert(pathTable, {807, 11611.6, 11881.3, 22.2051})
table.insert(pathTable, {807, 11599.8, 11888.7, 13.4021})

local ForgottenReachPath = AddTaxiPath(pathTable, 150505, 150505)

local function OnGossipHello(event, player, object)
	player:GossipClearMenu()
	player:GossipSetText('Bonjour '..player:GetName()..'!\n\nJe propose un voyage pour la visite Des Ports Oubliés.\n\nVoulez-vous visitez ?');
	player:GossipMenuAddItem(2, "Oui, pourquoi pas ! Prêt à embarquer !", 1, 1)
	player:GossipMenuAddItem(7, 'Pas maintenant... Au revoir !', 1, 2);
	player:GossipSendMenu(0x7FFFFFFF, object)
    end
	
	local function OnGossipSelect(event, player, object, sender, intid, code, menuid)
	if (intid == 1) then
		player:StartTaxi(ForgottenReachPath)
        player:GossipComplete();
		if (player:HasQuest(QUEST_ID)) then
            player:CompleteQuest(QUEST_ID)
            player:GossipComplete()
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