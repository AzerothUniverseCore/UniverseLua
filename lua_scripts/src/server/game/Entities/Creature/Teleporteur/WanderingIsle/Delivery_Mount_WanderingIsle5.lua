local NpcId = 120018
local MenuId = 120018

local pathTable = {}

table.insert(pathTable, {772, 259.699, 3829.76, 79.0937})
table.insert(pathTable, {772, 264.373, 3815.85, 92.0784})
table.insert(pathTable, {772, 284.831, 3796.02, 101.539})
table.insert(pathTable, {772, 329.786, 3777.36, 119.132})
table.insert(pathTable, {772, 403.319, 3746.75, 147.182})
table.insert(pathTable, {772, 507.234, 3715.14, 161.815})
table.insert(pathTable, {772, 794.872, 3633.67, 222.118})
table.insert(pathTable, {772, 862.875, 3614.93, 237.756})
table.insert(pathTable, {772, 889.406, 3609.11, 233.508})
table.insert(pathTable, {772, 905.841, 3606.73, 229.85})
table.insert(pathTable, {772, 918.329, 3605.63, 224.676})

local WanderingIslesixPath = AddTaxiPath(pathTable, 142785, 142785)

local function OnGossipHello(event, player, object)
    local questID = 29665

    -- Vérifie si l'objet player est valide
    if not player or not player:IsInWorld() then
        return
    end

    -- Vérifie si la quête 29665 a été complétée (récompense reçue)
    if not player:HasReceivedQuestReward(questID) then
        player:SendBroadcastMessage("|cff00ff98Vous devez d'abord terminer la quête : (De mal en pis) avant de pouvoir voyager.|r")
		player:SendNotification('|cff00ff98Vous devez d\'abord terminer la quête : (De mal en pis) avant de pouvoir voyager.|r')
        return
    end

    player:GossipClearMenu()
    player:GossipSetText('Bonjour ' .. player:GetName() .. '!\n\nJe propose un voyage au Temple des Cinq matins.\n\nVoulez-vous y aller ?')
    player:GossipMenuAddItem(2, "Oui ! Allez au Temple des Cinq matins !", 1, 1)
    player:GossipMenuAddItem(7, 'Pas maintenant... Au revoir !', 1, 2)
    player:GossipSendMenu(0x7FFFFFFF, object)
end

local function OnGossipSelect(event, player, object, sender, intid, code, menuid)
    if (intid == 1) then
        player:StartTaxi(WanderingIslesixPath)
        player:GossipComplete()
    elseif (intid == 2) then
        player:SendNotification('|cffff0000Reviens me voir si tu veux voyager.|r')
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NpcId, 1, OnGossipHello)
RegisterCreatureGossipEvent(NpcId, 2, OnGossipSelect)
RegisterPlayerGossipEvent(MenuId, 2, OnGossipSelect)
