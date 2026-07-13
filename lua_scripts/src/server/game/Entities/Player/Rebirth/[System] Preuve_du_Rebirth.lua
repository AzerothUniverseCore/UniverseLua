-----------------------------------------------------------------------------------------------------------------------------------------------------

local ItemId = 80001;
local MenuId = 900005;
local Rebirth = {};
-----------------------------------------------------------------------------------------------------------------------------------------------------

Rebirth.Level={
	level
};
-----------------------------------------------------------------------------------------------------------------------------------------------------


Rebirth.Config = {
	--LevelRequisPourLancerLeRebirth
	MinLvl = 80;
	--DBName
	DbName = 'auc_eluna';
	--RebirthLevel
	Level = 0; 
};
-----------------------------------------------------------------------------------------------------------------------------------------------------

CharDBQuery('CREATE DATABASE IF NOT EXISTS `'..Rebirth.Config.DbName..'` CHARACTER SET utf8mb4;');
CharDBQuery('CREATE TABLE IF NOT EXISTS `'..Rebirth.Config.DbName..'`.`rebirth_accounts` ( `account_id` INT(10) NOT NULL, `RebirthLevel` INT(10) NOT NULL DEFAULT 0, PRIMARY KEY (`account_id`) );');
-----------------------------------------------------------------------------------------------------------------------------------------------------

function Rebirth.GetRebirth(player)
    local accountId = player:GetAccountId()
    local RebirthNiv = CharDBQuery('SELECT RebirthLevel FROM `'..Rebirth.Config.DbName..'`.`rebirth_accounts` WHERE account_id = '..accountId..';');
    
    if RebirthNiv then
        Rebirth.Level[accountId] = { level = RebirthNiv:GetUInt32(0) }
    else
        CharDBQuery('INSERT IGNORE INTO `'..Rebirth.Config.DbName..'`.`rebirth_accounts` (account_id) VALUES ('..accountId..');');
        Rebirth.Level[accountId] = { level = 0 }
    end
    return Rebirth.Level[accountId].level;
end

function Item_Trigger(item, event, player)
    Item_menu(item, player);
end
-----------------------------------------------------------------------------------------------------------------------------------------------------

function Item_menu(event, player, object)
    -- Vérifie si le joueur est dans un champ de bataille ou une arène
    if player:GetMap():IsBattleground() or player:GetMap():IsArena() then
        player:SendNotification("|CFF00A2FFVous ne pouvez pas ouvrir votre Pierre Preuve de Rebirth depuis un champ de bataille ou une arène.|r")
        player:GossipComplete()  -- Ferme le menu sans afficher quoi que ce soit
        return
    end

    -- Vérifie si le joueur est en combat
    if(player:IsInCombat()) then
        player:SendNotification("Retentez une fois votre combat fini!")
    else
        player:GossipClearMenu() -- required for player gossip

        Rebirth.GetRebirth(player)
        local accountId = player:GetAccountId()

        if(Rebirth.Level[accountId].level >= 1) then
            if (player:GetLevel() >= 80) then
                player:GossipMenuAddItem(1, "Preuve du Rebirth 1", 1, 1)
            else
                player:SendNotification('|cffff0000Preuve du rebirth requis le niveau 80 !|r')
            end
        end
		
		if(Rebirth.Level[accountId].level >= 2) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 2", 1, 2);
			end
		end
			
		if(Rebirth.Level[accountId].level >= 3) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 3", 1, 3);
			end
		end	
			
		if(Rebirth.Level[accountId].level >= 4) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 4", 1, 4);
			end	
		end
			
		if(Rebirth.Level[accountId].level >= 5) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 5", 1, 5);
			end	
		end
			
		if(Rebirth.Level[accountId].level >= 6) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 6", 1, 7);
			end	
		end
			
		if(Rebirth.Level[accountId].level >= 7) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 7", 1, 8);
			end
		end	
			
		if(Rebirth.Level[accountId].level >= 8) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 8", 1, 9);
			end
		end	
			
		if(Rebirth.Level[accountId].level >= 9) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 9", 1, 10);
			end	
		end
			
		if(Rebirth.Level[accountId].level >= 10) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 10", 1, 11);
			end
		end
		
		if(Rebirth.Level[accountId].level >= 11) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 11", 1, 12);
			end
		end
		
		if(Rebirth.Level[accountId].level >= 12) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 12", 1, 13);
			end
		end
		
		if(Rebirth.Level[accountId].level >= 13) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 13", 1, 14);
			end
		end
		
		if(Rebirth.Level[accountId].level >= 14) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 14", 1, 15);
			end
		end
		
		if(Rebirth.Level[accountId].level >= 15) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 15", 1, 16);
			end
		end
		
		if(Rebirth.Level[accountId].level >= 16) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 16", 1, 17);
			end
		end
		
		if(Rebirth.Level[accountId].level >= 17) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 17", 1, 18);
			end
		end
		
		if(Rebirth.Level[accountId].level >= 18) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 18", 1, 19);
			end
		end
		
		if(Rebirth.Level[accountId].level >= 19) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 19", 1, 20);
			end
		end
		
		if(Rebirth.Level[accountId].level >= 20) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 20", 1, 21);
			end
		end
		
		if(Rebirth.Level[accountId].level >= 21) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 21", 1, 22);
			end
		end
		
		if(Rebirth.Level[accountId].level >= 22) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 22", 1, 23);
			end
		end
		
		if(Rebirth.Level[accountId].level >= 23) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 23", 1, 24);
			end
		end
		
		if(Rebirth.Level[accountId].level >= 25) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 25", 1, 25);
			end
		end
		
		if(Rebirth.Level[accountId].level >= 30) then
		if (player:GetLevel() >= 80) then
   			player:GossipMenuAddItem(1, "Preuve du Rebirth 30", 1, 30);
			end
		end
		
		player:GossipMenuAddItem(7, "Fermer", 1, 6);
   		player:GossipSendMenu(1, object, MenuId);
   	end
end
-----------------------------------------------------------------------------------------------------------------------------------------------------


function OnSelect(event, player, id, sender, intid, code)

	if (intid == 1) then -- Preuve du Rebirth 1
		player:Teleport(790, 1769.7, 1956.42, 171.919, 1.64839);
		player:SendNotification("Tuer Preuve du rebirth 1 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 2) then -- Preuve du Rebirth 2
		player:Teleport(790, 1943.65, 1878.12, 172.419, 5.15801);
		player:SendNotification("Tuer Preuve du rebirth 2 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 3) then -- Preuve du Rebirth 3
		player:Teleport(790, 1796.24, 1930, 219.407, 4.91501);
		player:SendNotification("Tuer Preuve du rebirth 3 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 4) then -- Preuve du Rebirth 4
		player:Teleport(789, -1038.06, 986.274, 39.8764, 0.134207);
		player:SendNotification("Tuer Preuve du rebirth 4 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 5) then -- Preuve du Rebirth 5
		player:Teleport(787, 1326.85, 3951.82, 146.721, 0.526314);
		player:SendNotification("Tuer Preuve du rebirth 5 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 7) then -- Preuve du Rebirth 6
		player:Teleport(787, 1050.13, 3452.75, 22.9212, 4.13536);
		player:SendNotification("Tuer Preuve du rebirth 6 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 8) then -- Preuve du Rebirth 7
		player:Teleport(787, 1202.98, 4021.83, 17.8164, 2.35377);
		player:SendNotification("Tuer Preuve du rebirth 7 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 9) then -- Preuve du Rebirth 8
		player:Teleport(787, 778.766, 4108, 10.7071, 4.71718);
		player:SendNotification("Tuer Preuve du rebirth 8 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 10) then -- Preuve du Rebirth 9
		player:Teleport(787, 794.676, 3964.91, 15.1994, 1.46751);
		player:SendNotification("Tuer Preuve du rebirth 9 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 11) then -- Preuve du Rebirth 10
		player:Teleport(787, 831.401, 4040.64, 11.4455, 4.5403);
		player:SendNotification("Tuer Preuve du rebirth 10 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 12) then -- Preuve du Rebirth 11
		player:Teleport(787, 770.165, 3961.95, 16.2116, 3.66332);
		player:SendNotification("Tuer Preuve du rebirth 11 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 13) then -- Preuve du Rebirth 12
		player:Teleport(787, 344.784, 3930.99, 11.7014, 1.0129);
		player:SendNotification("Tuer Preuve du rebirth 12 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 14) then -- Preuve du Rebirth 13
		player:Teleport(787, 366.739, 4002.49, 8.22053, 4.03824);
		player:SendNotification("Tuer Preuve du rebirth 13 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 15) then -- Preuve du Rebirth 14
		player:Teleport(787, 427.101, 3935.04, 10.8254, 2.20355);
		player:SendNotification("Tuer Preuve du rebirth 14 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 16) then -- Preuve du Rebirth 15
		player:Teleport(805, 769.36, 3962.35, 16.2566, 0.178442);
		player:SendNotification("Tuer Preuve du rebirth 15 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 17) then -- Preuve du Rebirth 16
		player:Teleport(805, 794.549, 3965.46, 15.1994, 1.48086);
		player:SendNotification("Tuer Preuve du rebirth 16 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 18) then -- Preuve du Rebirth 17
		player:Teleport(805, 831.177, 4039.4, 11.4804, 1.60206);
		player:SendNotification("Tuer Preuve du rebirth 17 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 19) then -- Preuve du Rebirth 18
		player:Teleport(805, 622.997, 4021.16, 2.26248, 5.14433);
		player:SendNotification("Tuer Preuve du rebirth 18 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 20) then -- Preuve du Rebirth 19
		player:Teleport(805, 671.665, 4088.43, 11.0523, 1.58553);
		player:SendNotification("Tuer Preuve du rebirth 19 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 21) then -- Preuve du Rebirth 20
		player:Teleport(806, 4979.15, -4072.42, 39.1177, 0.37697);
		player:SendNotification("Tuer Preuve du rebirth 20 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 22) then -- Preuve du Rebirth 21
		player:Teleport(806, 4758.56, -4079.27, 7.38757, 1.93283);
		player:SendNotification("Tuer Preuve du rebirth 21 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 23) then -- Preuve du Rebirth 22
		player:Teleport(806, 3689.28, -3996.02, 29.9337, 4.05044);
		player:SendNotification("Tuer Preuve du rebirth 22 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 24) then -- Preuve du Rebirth 23
		player:Teleport(806, 3574.12, -3930.26, 22.7411, 4.84368);
		player:SendNotification("Tuer Preuve du rebirth 23 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 25) then -- Preuve du Rebirth 25
		player:Teleport(806, -621.186, -1504.62, -23.0804, 3.99204);
		player:SendNotification("Tuer Preuve du rebirth 25 pour être récompenser !");
       	player:GossipComplete();
	end
	
	if (intid == 30) then -- Preuve du Rebirth 30
		player:Teleport(806, -146.922, -1931.93, 81.5285, 4.80995);
		player:SendNotification("Tuer Preuve du rebirth 30 pour être récompenser !");
       	player:GossipComplete();
	end

	if (intid == 6) then -- Ferme le GossipMenu
       	player:GossipComplete();
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------------------

RegisterItemGossipEvent(ItemId, 1, Item_menu);
RegisterItemGossipEvent(ItemId, 2, OnSelect);
-----------------------------------------------------------------------------------------------------------------------------------------------------