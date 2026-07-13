local NpcId = 338049
local MenuId = 338049

local pathTable = {
	{811, -10348, -11226, 51.633},
    {811, -10386.3, -11020.5, 60.7756},
    {811, -10476, -10601.5, 57.344},
    {811, -10392.4, -10292.3, 56.6811},
    {811, -10262, -9984.32, 42.8791},
    {811, -10229.2, -9742.48, -33.722}
}

local pathTableTwo = {
	{811, -10348, -11226, 51.633},
    {811, -10456, -11139.6, 48.208},
    {811, -10769, -11063.4, 51.661},
    {811, -10943, -11127.4, 55.9376},
    {811, -11187.8, -11420.3, 68.8338},
    {811, -11227.3, -11509.3, 89.2854},
    {811, -11336.2, -11481.7, 58.6533},
	{811, -11425.9, -11450.9, 32.6257}
}

local GreatWoodToMourningWoodPath = AddTaxiPath(pathTable, 541, 2224)
local GreatWoodToWitchWoodPath = AddTaxiPath(pathTableTwo, 541, 2224)

local function OnGossipHello(event, player, object)
    player:GossipClearMenu()
    player:GossipSetText('Bonjour '..player:GetName()..'!\n\nJe propose des voyages.\n\nOù souhaitez-vous aller ?')
    player:GossipMenuAddItem(2, "Allez à Mourningwood !", 1, 1)
    player:GossipMenuAddItem(2, "Allez à WitchWood !", 1, 2)
    player:GossipMenuAddItem(7, 'Nul part... Au revoir !', 1, 4)
    player:GossipSendMenu(0x7FFFFFFF, object)
end

local function OnGossipSelect(event, player, object, sender, intid, code, menuid)
    if intid == 1 then
            player:StartTaxi(GreatWoodToMourningWoodPath)
            player:GossipComplete()
    elseif intid == 2 then
        player:StartTaxi(GreatWoodToWitchWoodPath)
        player:GossipComplete()
    elseif intid == 4 then
        player:SendNotification('|cffff0000Reviens me voir si tu veux voyager.|r')
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NpcId, 1, OnGossipHello)
RegisterCreatureGossipEvent(NpcId, 2, OnGossipSelect)
RegisterPlayerGossipEvent(MenuId, 2, OnGossipSelect)
