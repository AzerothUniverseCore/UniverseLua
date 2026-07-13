local NpcId = 338036
local MenuId = 338040
local QUEST_ID = 338040

local pathTable = {}

table.insert(pathTable, {807, 11667.6, 11960.6, -0.990158})
table.insert(pathTable, {807, 11691, 11964.9, 16.3643})
table.insert(pathTable, {807, 11739.2, 11969.8, 24.8163})
table.insert(pathTable, {807, 11798.5, 12040.5, 47.429})
table.insert(pathTable, {807, 11895.3, 12117, 104.955})
table.insert(pathTable, {807, 11953.5, 12204.9, 168.442})
table.insert(pathTable, {807, 11848.3, 12326.5, 198.257})
table.insert(pathTable, {807, 11884, 12403.6, 197.719})
table.insert(pathTable, {807, 11959.6, 12451.7, 155.042})
table.insert(pathTable, {807, 11975.7, 12469.3, 147.115})

local ForgottenReachQuestPath = AddTaxiPath(pathTable, 150505, 150505)

local function OnGossipHello(event, player, object)
    player:GossipClearMenu()
    player:GossipSetText('Bonjour '..player:GetName()..'!\n\nJe propose un trajet pour rendre visite à Alyissia.\n\nVoulez-vous rendre visite à Alyissia ?')
    player:GossipMenuAddItem(2, "Oui, pourquoi pas ! Prêt à embarquer !", 1, 1)
    player:GossipMenuAddItem(7, 'Pas maintenant... Au revoir !', 1, 2)
    player:GossipSendMenu(0x7FFFFFFF, object)
end

local function OnGossipSelect(event, player, object, sender, intid, code, menuid)
    if (intid == 1) then
        -- Vérifier si le joueur est au niveau 16 ou plus
        if player:GetLevel() >= 16 then
            player:StartTaxi(ForgottenReachQuestPath)
            player:GossipComplete()
            if (player:HasQuest(QUEST_ID)) then
                player:CompleteQuest(QUEST_ID)
                player:GossipComplete()
            end
        else
            player:SendNotification("Vous devez être au moins au niveau 16 pour voyager.")
            player:GossipComplete()
        end
    end

    if(intid == 2) then
        player:SendNotification('|cffff0000Reviens me voir si tu veux voyager.|r')
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NpcId, 1, OnGossipHello)
RegisterCreatureGossipEvent(NpcId, 2, OnGossipSelect)
RegisterPlayerGossipEvent(MenuId, 2, OnGossipSelect)
