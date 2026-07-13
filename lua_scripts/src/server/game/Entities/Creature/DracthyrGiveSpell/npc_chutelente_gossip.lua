-- ============================================================
--  NPC Gossip - Chute Lente | NPC ID : 338590
--  TrinityCore 3.3.5a | Eluna Lua 2023/2024
-- ============================================================

local NPC_ID = 338590
local SPELL_SLOW_FALL = 50085   -- Chute Lente

local function OnGossipHello(event, player, object)
	player:GossipClearMenu()
	player:GossipSetText('Ah, '..player:GetName()..' ! Quelle joie de te voir par ici !\n\nMais dis-moi... tu ne comptes tout de même pas sauter sans ma Chute Lente ?\n\nAllez, laisse-moi t\'aider à descendre avec style !');
	player:GossipMenuAddItem(2, "Haha, allez ! Accordez-moi la Chute Lente !", 1, 1)
	player:GossipMenuAddItem(7, "Je réfléchis encore... À bientôt !", 1, 2);
	player:GossipSendMenu(0x7FFFFFFF, object)
end
	
local function OnGossipSelect(event, player, object, sender, intid, code, menuid)
	if (intid == 1) then
		player:CastSpell(player, SPELL_SLOW_FALL, true)
        player:GossipComplete();
	end
		
	if (intid == 2) then
		player:SendNotification('|cffff0000Pas de souci ! Je serai là quand tu seras prêt à t\'envoler !|r');
		player:GossipComplete();
	end
end
		
RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect)
RegisterPlayerGossipEvent(SPELL_SLOW_FALL, 2, OnGossipSelect)