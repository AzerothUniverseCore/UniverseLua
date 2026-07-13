local ItemId = 90004;
local MenuId = 900004;
local Rebirth = {};
local Cooldowns = {}
local COOLDOWN_TIME = 60


Rebirth.Level={}

Rebirth.Config = {
    MinLvl = 80,
    DbName = 'auc_eluna',
    Level = 0
};

CharDBQuery('CREATE DATABASE IF NOT EXISTS `'..Rebirth.Config.DbName..'` CHARACTER SET utf8mb4;');
CharDBQuery('CREATE TABLE IF NOT EXISTS `'..Rebirth.Config.DbName..'`.`rebirth_accounts` ( `account_id` INT(10) NOT NULL, `RebirthLevel` INT(10) NOT NULL DEFAULT 0, PRIMARY KEY (`account_id`) );');

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

function Item_menu(event, player, object)
    -- Vérifie si le joueur est dans un champ de bataille ou une arène
    if player:GetMap():IsBattleground() or player:GetMap():IsArena() then
        player:SendNotification("|CFF00A2FFVous ne pouvez pas ouvrir votre Pierre de Rebirth depuis un champ de bataille ou une arène.|r")
        player:GossipComplete()  -- Ferme le menu sans afficher quoi que ce soit
        return
    end

    -- Vérifie si le joueur est en combat
    if(player:IsInCombat()) then
        player:SendNotification("|CFF00A2FFRetentez une fois votre combat fini!|r")
    else
        player:GossipClearMenu() -- required for player gossip

        Rebirth.GetRebirth(player)
        local accountId = player:GetAccountId()

        if(Rebirth.Level[accountId].level >= 1) then
            player:GossipMenuAddItem(3, "Amélioration d'état", 1, 1)
            player:GossipMenuAddItem(8, "Restaurer la santé", 1, 2)
            player:GossipMenuAddItem(8, "Réparer l'équipement", 1, 7)
            player:GossipMenuAddItem(2, "Retirer le mal de résurrection", 1, 3)
        end

        if(Rebirth.Level[accountId].level >= 10) then
            player:GossipMenuAddItem(3, "Réinitialiser le temps des sorts", 1, 13)
            player:GossipMenuAddItem(2, "Retirer le déserteur", 1, 14)
			player:GossipMenuAddItem(9, "Réinitialiser les instances", 1, 20)
            player:GossipMenuAddItem(7, "--------------------------------", 1, 10)
            player:GossipMenuAddItem(3, "Réinitialiser les talents", 1, 9)
            player:GossipMenuAddItem(7, "--------------------------------", 1, 11)
        end

        if(Rebirth.Level[accountId].level >= 1) then
            player:GossipMenuAddItem(9, "Mont Hyjal 1-80 (EXP Rebirth)", 1, 5)
        end

        if(Rebirth.Level[accountId].level >= 1) then
            if (player:GetLevel() >= 80) then
                player:GossipMenuAddItem(9, "Hyjal TDF 80 (EXP Rebirth)", 1, 18)
            end

            player:GossipMenuAddItem(1, "Nerozias (Shop/PvP)", 1, 4)
            player:GossipMenuAddItem(7, "--------------------------------", 1, 12)
            player:GossipMenuAddItem(7, "Fermer", 1, 6)
            player:GossipSendMenu(1, object, MenuId)
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------------------

function OnSelect(event, player, id, sender, intid, code)
	if (intid == 1) then -- Buffs
		local accountId = player:GetAccountId();	

		if(Rebirth.Level[accountId].level >= 1)then-- Renaissance Croissante
			if(Rebirth.Level[accountId].level >= 5)then 
				if(Rebirth.Level[accountId].level >= 9)then
					if(Rebirth.Level[accountId].level >= 11)then
						if(Rebirth.Level[accountId].level >= 15)then
							if(Rebirth.Level[accountId].level >= 19)then
								if(Rebirth.Level[accountId].level >= 21)then
									if(Rebirth.Level[accountId].level >= 25)then
										if(Rebirth.Level[accountId].level >= 29)then
											player:CastSpell(player, 150408, true);
										else
											player:CastSpell(player, 150407, true);
										end
									else
										player:CastSpell(player, 150406, true);
									end
								else
									player:CastSpell(player, 150405, true);
								end
							else
								player:CastSpell(player, 150404, true);
							end
						else
							player:CastSpell(player, 150403, true);
						end
					else
						player:CastSpell(player, 150402, true);
					end
				else
					player:CastSpell(player, 150401, true);
				end
			else
				player:CastSpell(player, 150400, true);
			end
		end
		
		if(Rebirth.Level[accountId].level >= 2)then-- Renaissance Féroce
			if(Rebirth.Level[accountId].level >= 7)then 
				if(Rebirth.Level[accountId].level >= 10)then
					if(Rebirth.Level[accountId].level >= 12)then
						if(Rebirth.Level[accountId].level >= 17)then
							if(Rebirth.Level[accountId].level >= 20)then
								if(Rebirth.Level[accountId].level >= 22)then
									if(Rebirth.Level[accountId].level >= 27)then
										if(Rebirth.Level[accountId].level >= 30)then
											player:CastSpell(player, 150418, true);
										else
											player:CastSpell(player, 150417, true);
										end
									else
										player:CastSpell(player, 150416, true);
									end
								else
									player:CastSpell(player, 150415, true);
								end
							else
								player:CastSpell(player, 150414, true);
							end
						else
							player:CastSpell(player, 150413, true);
						end
					else
						player:CastSpell(player, 150412, true);
					end
				else
					player:CastSpell(player, 150411, true);
				end
			else
				player:CastSpell(player, 150410, true);
			end
		end

		if(Rebirth.Level[accountId].level >= 3)then-- Renaissance Persistante
			if(Rebirth.Level[accountId].level >= 13)then 
				if(Rebirth.Level[accountId].level >= 23)then
					player:CastSpell(player, 150432, true);
				else
					player:CastSpell(player, 150431, true);
				end
			else
				player:CastSpell(player, 150430, true);
			end
		end

		if(Rebirth.Level[accountId].level >= 4)then-- Renaissance Robuste
			if(Rebirth.Level[accountId].level >= 6)then 
				if(Rebirth.Level[accountId].level >= 8)then
					if(Rebirth.Level[accountId].level >= 14)then
						if(Rebirth.Level[accountId].level >= 16)then
							if(Rebirth.Level[accountId].level >= 18)then
								if(Rebirth.Level[accountId].level >= 24)then
									if(Rebirth.Level[accountId].level >= 26)then
										if(Rebirth.Level[accountId].level >= 28)then
											player:CastSpell(player, 150428, true);
										else
											player:CastSpell(player, 150427, true);
										end
									else
										player:CastSpell(player, 150426, true);
									end
								else
									player:CastSpell(player, 150425, true);
								end
							else
								player:CastSpell(player, 150424, true);
							end
						else
							player:CastSpell(player, 150423, true);
						end
					else
						player:CastSpell(player, 150422, true);
					end
				else
					player:CastSpell(player, 150421, true);
				end
			else
				player:CastSpell(player, 150420, true);
			end
		end
		player:CastSpell(player, 31726, true);
		player:SendNotification("|CFF00A2FFVous bénéficiez de toutes les améliorations d'état possible !|r");
		player:GossipComplete();
	end

	if (intid == 2) then -- Soigner
		player:SetHealth(player:GetMaxHealth());
		player:SetPower( player:GetMaxPower());
		player:CastSpell(player, 31726, true);
		player:SendNotification("|CFF00A2FFVous revoila en bonne santé !|r");
        player:GossipComplete();
	end
	if (intid == 3) then -- Retirez le mal de résurrection
		player:RemoveAura(15007);
		player:CastSpell(player, 31726, true);
		player:SendNotification("|CFF00A2FFVous revoila prêt aux combats !|r");
        player:GossipComplete();
	end
	if (intid == 7) then -- Réparation de l'équipement
        player:DurabilityRepairAll(false)
		player:CastSpell(player, 31726, true);
		player:SendNotification("|CFF00A2FFVotre équipement est réparé !|r");
        player:GossipComplete()
    end
	
	if (intid == 9) then -- Reset Talents
        player:ResetTalents(true)
		player:CastSpell(player, 31726, true);
		player:SendNotification("|CFF00A2FFVos talents ont été réinitialisés|r");
        player:GossipComplete()
    end
	
	if (intid == 13) then -- Reinitialise le temps des sorts
		local accountId = player:GetAccountId()
		local currentTime = os.time()
		
	if Cooldowns[accountId] and (currentTime - Cooldowns[accountId] < COOLDOWN_TIME) then
		local remainingTime = COOLDOWN_TIME - (currentTime - Cooldowns[accountId])
		player:SendNotification("|cff00f0f0Encore|r |cffffff00" .. remainingTime .. " secondes|r |cff00f0f0avant la réinitialisation des sorts.|r")
		player:GossipComplete()
	else
		Cooldowns[accountId] = currentTime
        player:ResetAllCooldowns()
		player:CastSpell(player, 31726, true);
		player:SendNotification("|CFF00A2FFVos temps de recharge de vos sorts ont été réinitialisés|r");
        player:GossipComplete()
    end
end
	
	if (intid == 14) then -- Reinitialise le temps des sorts
        player:RemoveAura(26013);
		player:CastSpell(player, 31726, true);
		player:SendNotification("|CFF00A2FFVous revoila prêt pour un nouveau champs de bataille !|r");
        player:GossipComplete()
    end
	
	if (intid == 10) then -- Separate
        player:GossipComplete()
    end
	
	if (intid == 11) then -- Separate
        player:GossipComplete()
    end
	
	if (intid == 12) then -- Separate
        player:GossipComplete()
    end
	
	if (intid == 4) then
		if (player:IsHorde())then -- Zone Shop Horde
			player:Teleport(726, -15810.128906, -14193.071289, 77.352615, 0.805357);
		end
		if (player:IsAlliance())then -- Zone Shop Alliance
			player:Teleport(726, -15798.256836, -13451.877930, 88.816940, 3.332687);
		end
      	player:GossipComplete();
	end
	
	if (intid == 5) then -- Zone EXP Rebirth (Hyjal)
		player:Teleport(1, 4619.39, -3847.96, 943.94, 1.12);
       	player:GossipComplete();
	end
	
	if (intid == 18) then -- Zone EXP Rebirth (Hyjal TDF)
		player:Teleport(1, 4677.54, -3681.55, 697.771, 1.62796);
       	player:GossipComplete();
	end
	
	if (intid == 20) then -- Vos instances ont été réinitalisées
        player:UnbindAllInstances()
		player:CastSpell(player, 31726, true);
		player:SendNotification("|CFF00A2FFVos instances ont été réinitalisées.|r");
        player:GossipComplete()
    end

	if (intid == 6) then -- Ferme le GossipMenu
       	player:GossipComplete();
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------------------

RegisterItemGossipEvent(ItemId, 1, Item_menu);
RegisterItemGossipEvent(ItemId, 2, OnSelect);
-----------------------------------------------------------------------------------------------------------------------------------------------------