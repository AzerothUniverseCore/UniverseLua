local NPC_ID = 9940641
local GOSSIP_MENU_ID = 9940641
local SKILL_RECYCLER_ID = 338050 -- Remplacez cet ID par celui du métier SKILL_RECYCLER

local function OnGossipHello(event, player, creature)
    player:GossipClearMenu()
    player:GossipMenuAddItem(0, "Apprendre le métier de recycleur", 0, 1, true, "Êtes-vous sûr de vouloir apprendre le métier de recycleur ?")
    player:GossipSendMenu(1, creature)
end

local function OnGossipSelect(event, player, creature, sender, intid, code)
    if (intid == 1) then
        if (player:HasSkill(SKILL_RECYCLER_ID) == false) then
            player:LearnSpell(SKILL_RECYCLER_ID)
            player:SendBroadcastMessage("Félicitations, vous avez appris le métier de recycleur !")
        else
            player:SendBroadcastMessage("Vous connaissez déjà ce métier !")
        end
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect)
