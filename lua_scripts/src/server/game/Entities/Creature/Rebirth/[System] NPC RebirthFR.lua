local UnitEntry = 9000101;

local Rebirth = {};
Rebirth.Config = {
	--LevelRequisPourLancerLeRebirth
	MinLvl = 80;
	--DBName
	DbName = 'auc_eluna';
	--RebirthLevel
	Level = 0; 
};

--CréationDeTableDB
CharDBQuery('CREATE DATABASE IF NOT EXISTS `'..Rebirth.Config.DbName..'` CHARACTER SET utf8mb4;');
CharDBQuery('CREATE TABLE IF NOT EXISTS `'..Rebirth.Config.DbName..'`.`rebirth_accounts` ( `account_id` INT(10) NOT NULL, `RebirthLevel` INT(10) NOT NULL DEFAULT 0, PRIMARY KEY (`account_id`) );');

Rebirth.Level={
	level
};

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

function Rebirth.onGossipHello(event, player, object)--Gossip du pnj
	if (player:GetLevel() >= 80) then
			player:GossipClearMenu();
			player:GossipSetText('Bonjour '..player:GetName()..',\n\nPréparez-vous à plonger dans un voyage épique de renaissance !\n\nEn choisissant la renaissance, vous recommencerez au |cffff0000niveau 1|r à chaque niveau de Rebirth, vous ouvrant ainsi les portes des récompenses les plus prestigieuses et des défis les plus captivants.');	--Faire un gossip disant "(Le personnage qui parle au pnj) a X niveau rebirth" -- \n\n*|cff8000ffVous serez déconnecté lors de la procédure|r.*
			player:GossipMenuAddItem(9, 'Je souhaite commencer mon rebirth.', 1, 100); --4 correspond a l'icone, 1 correspond au sender (NPC), 100 est l'intid qui renvoi vers un autre gossip
			player:GossipMenuAddItem(7, 'Je ne souhaite pas le faire tout de suite... Au revoir.', 1, 101);
			player:GossipSendMenu(0x7FFFFFFF, object); --0x7FFFFFFF sert a afficher un text avant les choix,
			player:AddItem(80001, 1);
			player:AddItem(90004, 1);
	else
 	   player:SendNotification('|cffff0000Revenez au level 80 !|r'); 	--phrase = Vous n avez pas le niveau requis pour actionnez la fonction rebirth revenez au level 80, revenez me voir plus tard.
	end
end
RegisterCreatureGossipEvent(9000101, 1, Rebirth.onGossipHello);

function Rebirth.onGossipSelect(event, player, object, sender, intid, code, menu_id, spell)
	local accountId = player:GetAccountId();

	--Proposer un choix si il veut ou pas rebirth.
	if(intid == 100)then
		Rebirth.GetRebirth(player)
		local accountId = player:GetAccountId();
		player:GossipMenuAddItem(4,'|cffff0000Nous allons proceder à votre rebirth, êtes vous prêt?|r', 1, 102);
		player:GossipSendMenu(0x7FFFFFFF, object);
	end

	if(intid == 101) then
		player:SendNotification('|cffff0000Revenez me voir quand vous serez prêt.|r');
		player:GossipComplete();
	end

	if (intid == 102) then
		local accountId = player:GetAccountId();
		if(Rebirth.Level[accountId].level == 30) then
			player:SendNotification('|cffff0000Félicitation ! Vous avez atteint le Rebirth maximum !|r');	--phrase => Vous êtes au dernier rebirth accéssible.
			player:GossipComplete();
		else
			Rebirth.Level[accountId].level = Rebirth.Level[accountId].level + 1;
			if(Rebirth.Level[accountId].level == 1)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 1 !|r'); -- Notification si le joueur à atteint le Rebirth 1
				player:AddItem(90004, 1);
		else
			if(Rebirth.Level[accountId].level == 2)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 2 !|r'); -- Notification si le joueur à atteint le Rebirth 2
		else
			if(Rebirth.Level[accountId].level == 3)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 3 !|r'); -- Notification si le joueur à atteint le Rebirth 3
		else
			if(Rebirth.Level[accountId].level == 4)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 4 !|r'); -- Notification si le joueur à atteint le Rebirth 4
		else
			if(Rebirth.Level[accountId].level == 5)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 5 !|r'); -- Notification si le joueur à atteint le Rebirth 5
		else
			if(Rebirth.Level[accountId].level == 6)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 6 !|r'); -- Notification si le joueur à atteint le Rebirth 6
		else
			if(Rebirth.Level[accountId].level == 7)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 7 !|r'); -- Notification si le joueur à atteint le Rebirth 7
		else
			if(Rebirth.Level[accountId].level == 8)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 8 !|r'); -- Notification si le joueur à atteint le Rebirth 8
		else
			if(Rebirth.Level[accountId].level == 9)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 9 !|r'); -- Notification si le joueur à atteint le Rebirth 9
		else
			if(Rebirth.Level[accountId].level == 10)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 10 !|r'); -- Notification si le joueur à atteint le Rebirth 10
		else
			if(Rebirth.Level[accountId].level == 11)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 11 !|r'); -- Notification si le joueur à atteint le Rebirth 11
		else
			if(Rebirth.Level[accountId].level == 12)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 12 !|r'); -- Notification si le joueur à atteint le Rebirth 12
		else
			if(Rebirth.Level[accountId].level == 13)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 13 !|r'); -- Notification si le joueur à atteint le Rebirth 13
		else
			if(Rebirth.Level[accountId].level == 14)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 14 !|r'); -- Notification si le joueur à atteint le Rebirth 14
		else
			if(Rebirth.Level[accountId].level == 15)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 15 !|r'); -- Notification si le joueur à atteint le Rebirth 15
		else
			if(Rebirth.Level[accountId].level == 16)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 16 !|r'); -- Notification si le joueur à atteint le Rebirth 16
		else
			if(Rebirth.Level[accountId].level == 17)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 17 !|r'); -- Notification si le joueur à atteint le Rebirth 17
		else
			if(Rebirth.Level[accountId].level == 18)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 18 !|r'); -- Notification si le joueur à atteint le Rebirth 18
		else
			if(Rebirth.Level[accountId].level == 19)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 19 !|r'); -- Notification si le joueur à atteint le Rebirth 19
		else
			if(Rebirth.Level[accountId].level == 20)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 20 !|r'); -- Notification si le joueur à atteint le Rebirth 20
		else
			if(Rebirth.Level[accountId].level == 21)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 21 !|r'); -- Notification si le joueur à atteint le Rebirth 21
		else
			if(Rebirth.Level[accountId].level == 22)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 22 !|r'); -- Notification si le joueur à atteint le Rebirth 22
		else
			if(Rebirth.Level[accountId].level == 23)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 23 !|r'); -- Notification si le joueur à atteint le Rebirth 23
		else
			if(Rebirth.Level[accountId].level == 24)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 24 !|r'); -- Notification si le joueur à atteint le Rebirth 24
		else
			if(Rebirth.Level[accountId].level == 25)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 25 !|r'); -- Notification si le joueur à atteint le Rebirth 25
		else
			if(Rebirth.Level[accountId].level == 26)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 26 !|r'); -- Notification si le joueur à atteint le Rebirth 26
		else
			if(Rebirth.Level[accountId].level == 27)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 27 !|r'); -- Notification si le joueur à atteint le Rebirth 27
		else
			if(Rebirth.Level[accountId].level == 28)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 28 !|r'); -- Notification si le joueur à atteint le Rebirth 28
		else
			if(Rebirth.Level[accountId].level == 29)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 29 !|r'); -- Notification si le joueur à atteint le Rebirth 29
		else
			if(Rebirth.Level[accountId].level == 30)then
			player:SendNotification('|CFF00A2FFFélicitation ! Vous avez atteint le Rebirth 30 !|r'); -- Notification si le joueur à atteint le Rebirth 30
																													end
																												end
																											end
																										end
																									end
																								end
																							end
																						end
																					end
																				end
																			end
																		end
																	end
																end
															end
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end
			--Si il accepte, incrément son rebirth et mettre son personnage level 1
			CharDBQuery('UPDATE `'..Rebirth.Config.DbName..'`.`rebirth_accounts` SET `RebirthLevel` = '..Rebirth.Level[accountId].level..' WHERE account_id = '..accountId..';');

			player:SetLevel(1) --Remise au niveau 1
			player:SendNotification('|cffff0000Nous procédons actuellement à votre rebirth, que la chance vous accompagne !|r');
			player:GossipComplete();
			--player:KickPlayer();
			--Player:LogoutPlayer();
		end
	end
end
RegisterCreatureGossipEvent(9000101, 2, Rebirth.onGossipSelect);