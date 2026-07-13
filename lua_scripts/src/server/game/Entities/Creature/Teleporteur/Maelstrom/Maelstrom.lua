local NpcId = 338808  -- ID de votre NPC Taxi
local MenuId = 338808

-- Table contenant le chemin pour le trajet entre les cartes
local pathTable = {
-- Maelstrom
    {852, 825.495, 1043.61, 3.29472},
	{852, 785.914, 953.911, 7.28428},
	{852, 741.959, 866.064, 22.3356},
	{852, 782.229, 796.854, 16.0438},
	{852, 732.634, 644.914, 44.4739},
	{852, 806.96, 580.88, 19.5445},
	{852, 879.995, 559.787, -12.2877},
	{852, 957.472, 582.372, -32.6054},
	{852, 1013.39, 694.681, -52.3233},
	{852, 1038.53, 812.64, -51.3908},
	{852, 999.004, 872.337, -56.0119},
	{852, 921.887, 934.082, -63.3209},
	{852, 809.868, 895.006, -83.6091},
	{852, 774.379, 791.723, -92.8516},
	{852, 823.454, 729.462, -121.031},
	{852, 927.038, 743.005, -126.789},
	{852, 910.401, 816.521, -172.494},
	{852, 897.243, 789.666, -214.998},
-- Deepholm Zone	
    {851, 1017.03, 508.198, 707.217},
	{851, 1027.07, 514.962, 558.526},
	{851, 1045.11, 543.384, 493.315},
	{851, 1074.81, 584.537, 462.357},
	{851, 1145.91, 648.574, 398.089},
	{851, 1287.75, 639.97, 213.908},
	{851, 1414.02, 779.989, 64.5474},
	{851, 1193.11, 892.053, 52.3813},
	{851, 1067.09, 1020.66, 55.3494},
	{851, 936.989, 885.158, 45.2769},
	{851, 725.862, 768.517, 56.5636},
	{851, 665.215, 453.463, 13.3656},
	{851, 949.249, 511.128, -49.334}
}

-- Ajouter le chemin de taxi avec les points définis
local MapTransitionPath = AddTaxiPath(pathTable, 180102, 180102)

-- Fonction pour afficher le menu du NPC
local function OnGossipHello(event, player, object)
    player:GossipClearMenu()
    player:GossipSetText("Bonjour " .. player:GetName() .. "!\n\nJe propose un voyage dans le Tréfond. Souhaitez-vous y aller ?")
    player:GossipMenuAddItem(2, "Voyager dans le Tréfond !", 1, 1)
    player:GossipMenuAddItem(7, "Non merci, au revoir.", 1, 2)
    player:GossipSendMenu(0x7FFFFFFF, object)
end

-- Fonction pour gérer la sélection du joueur
local function OnGossipSelect(event, player, object, sender, intid, code, menuid)
    if intid == 1 then
        -- Lancer le trajet de taxi
        player:StartTaxi(MapTransitionPath)
        player:GossipComplete()
    elseif intid == 2 then
        player:SendNotification("|cffff0000Reviens me voir si tu changes d'avis !|r")
        player:GossipComplete()
    end
end

-- Enregistrement des événements pour le NPC
RegisterCreatureGossipEvent(NpcId, 1, OnGossipHello)
RegisterCreatureGossipEvent(NpcId, 2, OnGossipSelect)