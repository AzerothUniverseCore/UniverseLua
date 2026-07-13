local function onGossipHello(event, player, object)
	player:GossipClearMenu()
	player:GossipSetText('Par délà les cieux il existe un monde ou les Anges existe!\nUne formule est connu pour les invoquers.\n\nSi vous la trouvez je vous offre une mascotte, Tyraël l\'ange tombés du ciel.\n\nIndice : Un titan de feu et de pierre garde un secret dans le Temple Noir.\nSon nom résonne avec puissance... Chaque lettre cache un chiffre, additionnez-les pour percer le mystère.\n\n? =?\n? = ?\n? = 16\nR = ?\n? = ?\n? = ?\nU = ?\n? = 19\n')
	player:GossipMenuAddItem(4, 'Je connais la formule', 1, 100, true, 'Additionnez donc les chiffres que vous avez trouvez.')
	player:GossipMenuAddItem(4, 'Je ne connais pas la formule..', 1, 101)
	player:GossipSendMenu(0x7FFFFFFF, object)
end
RegisterCreatureGossipEvent(29093, 1, onGossipHello)

local function onGossipSelect(event, player, object, sender, intid, code, menu_id)
	if (intid == 100)then
		if (code == '132') then
			local pItem = player:HasItem( 39656, 1, true );
			local pSpell = player:HasSpell(53082);
			if (pItem == false and pSpell == false) then
				player:AddItem(39656);
				player:GossipComplete()
				player:SendNotification('Vous avez réussis.\nAttention ne répétez cela à personne!')
			else
				player:SendNotification('Vous avez déjà résolus l\'énigme ?..')
				player:GossipComplete()
			end
		else
			player:SendNotification('Vous n\'avez pas réussis.\nDommage, une autre fois peut être ?')
			player:GossipComplete()
		end
	elseif (intid == 101) then
		player:GossipComplete()
	end
end
RegisterCreatureGossipEvent(29093, 2, onGossipSelect)

local function onGossipHello(event, player, object)
	player:GossipClearMenu()
	player:GossipSetText('Par délà les cieux il existe un monde ou les Anges existe!\nUne formule est connu pour les invoquers.\n\nSi vous la trouvez je vous offre une mascotte, Tyraël l\'ange tombés du ciel.\n\nIndice : Un titan de feu et de pierre garde un secret dans le Temple Noir.\nSon nom résonne avec puissance... Chaque lettre cache un chiffre, additionnez-les pour percer le mystère.\n\n? =?\n? = ?\n? = 16\nR = ?\n? = ?\n? = ?\nU = ?\n? = 19\n')
	player:GossipMenuAddItem(4, 'Je connais la formule', 1, 100, true, 'Additionnez donc les chiffres que vous avez trouvez.')
	player:GossipMenuAddItem(4, 'Je ne connais pas la formule..', 1, 101)
	player:GossipSendMenu(0x7FFFFFFF, object)
end
RegisterCreatureGossipEvent(29095, 1, onGossipHello)

local function onGossipSelect(event, player, object, sender, intid, code, menu_id)
	if (intid == 100)then
		if (code == '132') then
			local pItem = player:HasItem( 39656, 1, true );
			local pSpell = player:HasSpell(53082);
			if (pItem == false and pSpell == false) then
				player:AddItem(39656);
				player:GossipComplete()
				player:SendNotification('Vous avez réussis.\nAttention ne répétez cela à personne!')
			else
				player:SendNotification('Vous avez déjà résolus l\'énigme ?..')
				player:GossipComplete()
			end
		else
			player:SendNotification('Vous n\'avez pas réussis.\nDommage, une autre fois peut être ?')
			player:GossipComplete()
		end
	elseif (intid == 101) then
		player:GossipComplete()
	end
end
RegisterCreatureGossipEvent(29095, 2, onGossipSelect)
-- Code de la mascote : 132 Supremus