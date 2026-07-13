local NpcId = 32971
local MenuId = 32971

local pathTable = {
	{826, 12316.4, 14578.0, 1.51446},
    {826, 12320.0, 14590.3, 4.77921},
    {826, 12328.3, 14621.8, 20.7823},
    {826, 12341.0, 14689.9, 22.3503},
    {826, 12354.1, 14764.9, 14.2609},
    {826, 12358.5, 14793.7, 7.26133},
    {826, 12363.6, 14813.9, 1.41233}
}

local pathTableTwo = {
	{826, 12315.5, 14577.3, 1.48624},
    {826, 12320.1, 14585.6, 7.39254},
    {826, 12327.2, 14613.4, 16.7889},
    {826, 12341.0, 14676.4, 21.0957},
    {826, 12349.0, 14725.3, 24.3008},
    {826, 12352.0, 14782.4, 25.4714},
    {826, 12349.0, 14810.6, 21.5685},
	{826, 12342.3, 14836.8, 12.6615},
	{826, 12332.9, 14865.7, 1.96924}
}

local pathTableTree = {
	{826, 12316.6, 14577.9, 1.52764},
    {826, 12332.6, 14566.1, 8.15687},
    {826, 12363.5, 14537.9, 9.22961},
    {826, 12379.0, 14518.8, 6.16188},
    {826, 12384.2, 14504.3, 2.67923}
}

local DoomHammerPath = AddTaxiPath(pathTable, 150030, 150030)
local DoomHammerPathTwo = AddTaxiPath(pathTableTwo, 150034, 150034)
local DoomHammerPathTree = AddTaxiPath(pathTableTree, 142771, 142771)

local function OnGossipHello(event, player, object)
    player:GossipClearMenu()
    player:GossipSetText('Bonjour '..player:GetName()..'!\n\nJe propose des voyages jusqu\'à votre maître de métiers.\n\nOù souhaitez-vous aller ?')
    player:GossipMenuAddItem(2, "Aller chez le maître des Herboristes !", 1, 1)
    player:GossipMenuAddItem(2, "Aller chez le maître des Ingénieurs !", 1, 2)
	player:GossipMenuAddItem(2, "Aller chez le maître des Forgeron !", 1, 3)
    player:GossipMenuAddItem(7, 'Nul part... Au revoir !', 1, 4)
    player:GossipSendMenu(0x7FFFFFFF, object)
end

local function OnGossipSelect(event, player, object, sender, intid, code, menuid)
    if intid == 1 then
            player:StartTaxi(DoomHammerPath)
            player:GossipComplete()
    elseif intid == 2 then
        player:StartTaxi(DoomHammerPathTwo)
        player:GossipComplete()
	elseif intid == 3 then
        player:StartTaxi(DoomHammerPathTree)
        player:GossipComplete()
    elseif intid == 4 then
        player:SendNotification('|cffff0000Reviens me voir si tu veux voyager.|r')
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NpcId, 1, OnGossipHello)
RegisterCreatureGossipEvent(NpcId, 2, OnGossipSelect)
RegisterPlayerGossipEvent(MenuId, 2, OnGossipSelect)
