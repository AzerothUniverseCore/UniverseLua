local NpcId = 338047
local MenuId = 338047

local pathTable = {
	{811, -11412.6, -11458.4, 42.2887},
	{811, -11354.3, -11472.5, 52.9268},
	{811, -11293, -11486.2, 44.4667},
	{811, -11208.8, -11451.4, 39.9279},
	{811, -11063.8, -11268.4, 36.0656},
	{811, -10999.1, -11092.4, 29.602},
	{811, -10917.7, -10826.9, 26.3757},
	{811, -10622.9, -10210, 24.6837},
	{811, -10392.7, -9927.09, 12.6047},
	{811, -10246, -9797.25, -10.7342},
	{811, -10228.2, -9742.89, -33.8027}
}

local pathTableTwo = {
	{811, -11404.4, -11461.5, 45.1821},
	{811, -11335.2, -11471.2, 57.9376},
	{811, -11136.9, -11482.6, 97.7151},
	{811, -10972.8, -11378.1, 166.071},
	{811, -10779.1, -11248.2, 141.602},
	{811, -10615.9, -11161.1, 123.304},
	{811, -10500.9, -11202.1, 131.077},
	{811, -10435.8, -11292, 88.8298},
	{811, -10374.3, -11241.5, 64.6546},
	{811, -10340.8, -11254.4, 39.3276}
}

local WitchWoodToMourningWoodPath = AddTaxiPath(pathTable, 541, 2224)
local WitchWoodToToGreatWoodPath = AddTaxiPath(pathTableTwo, 541, 2224)

local function OnGossipHello(event, player, object)
    player:GossipClearMenu()
    player:GossipSetText('Bonjour '..player:GetName()..'!\n\nJe propose des voyages.\n\nOù souhaitez-vous aller ?')
    player:GossipMenuAddItem(2, "Allez à Mourningwood !", 1, 1)
    player:GossipMenuAddItem(2, "Allez à GreatWood !", 1, 2)
    player:GossipMenuAddItem(7, 'Nul part... Au revoir !', 1, 4)
    player:GossipSendMenu(0x7FFFFFFF, object)
end

local function OnGossipSelect(event, player, object, sender, intid, code, menuid)
    if intid == 1 then
            player:StartTaxi(WitchWoodToMourningWoodPath)
            player:GossipComplete()
    elseif intid == 2 then
        player:StartTaxi(WitchWoodToToGreatWoodPath)
        player:GossipComplete()
    elseif intid == 4 then
        player:SendNotification('|cffff0000Reviens me voir si tu veux voyager.|r')
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NpcId, 1, OnGossipHello)
RegisterCreatureGossipEvent(NpcId, 2, OnGossipSelect)
RegisterPlayerGossipEvent(MenuId, 2, OnGossipSelect)
