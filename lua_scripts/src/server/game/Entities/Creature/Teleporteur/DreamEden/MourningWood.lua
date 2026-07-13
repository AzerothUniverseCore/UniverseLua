local NpcId = 338048
local MenuId = 338048

local pathTable = {
	{811, -10227.8, -9747.15, -27.405},
	{811, -10188.3, -9836.74, -8.8453},
	{811, -10297.5, -10053.6, -10.1016},
	{811, -10538.1, -10209.8, -1.03888},
	{811, -10848.9, -10580.8, 98.7004},
	{811, -11006.7, -10988.6, 81.2336},
	{811, -11059.6, -11241.7, 78.6844},
	{811, -11195.2, -11501.8, 95.4182},
	{811, -11293.2, -11483.9, 68.1062},
	{811, -11358.2, -11469.2, 52.0661},
	{811, -11426.8, -11451.1, 32.6261}
}

local pathTableTwo = {
	{811, -10217.4, -9747.3, -27.7682},
	{811, -10198.6, -9803.75, -14.6664},
	{811, -10241.4, -9963.76, -4.0139},
	{811, -10283.1, -10177, -2.372},
	{811, -10299.2, -10393.7, 43.8252},
	{811, -10313.4, -10601, 75.2423},
	{811, -10329.9, -10961.8, 75.1722},
	{811, -10341.1, -11183.8, 56.579},
	{811, -10381.8, -11236.3, 64.2996},
	{811, -10341.6, -11255.2, 39.2977}
}

local MourningWoodToWitchWoodPath = AddTaxiPath(pathTable, 541, 2224)
local MourningWoodToGreatWoodPath = AddTaxiPath(pathTableTwo, 541, 2224)

local function OnGossipHello(event, player, object)
    player:GossipClearMenu()
    player:GossipSetText('Bonjour '..player:GetName()..'!\n\nJe propose des voyages.\n\nOù souhaitez-vous aller ?')
    player:GossipMenuAddItem(2, "Allez à WitchWood !", 1, 1)
    player:GossipMenuAddItem(2, "Allez à GreatWood !", 1, 2)
    player:GossipMenuAddItem(7, 'Nul part... Au revoir !', 1, 4)
    player:GossipSendMenu(0x7FFFFFFF, object)
end

local function OnGossipSelect(event, player, object, sender, intid, code, menuid)
    if intid == 1 then
            player:StartTaxi(MourningWoodToWitchWoodPath)
            player:GossipComplete()
    elseif intid == 2 then
        player:StartTaxi(MourningWoodToGreatWoodPath)
        player:GossipComplete()
    elseif intid == 4 then
        player:SendNotification('|cffff0000Reviens me voir si tu veux voyager.|r')
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NpcId, 1, OnGossipHello)
RegisterCreatureGossipEvent(NpcId, 2, OnGossipSelect)
RegisterPlayerGossipEvent(MenuId, 2, OnGossipSelect)
