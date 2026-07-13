-- Gangresabre - TrinityCore 3.3.5
-- Clic sur NPC 101518 → crédite le kill, complete la quête 40378, apprend + monte 142790

local MOUNT_SPELL_ID = 142790
local NPC_ENTRY      = 101518
local QUEST_ID       = 40378

local function OnGossipHello(event, player, creature)
    -- Créditer l'objectif kill de la quête (comme si le joueur avait tué le NPC)
    player:KilledMonsterCredit(NPC_ENTRY)

    -- Compléter la quête si les objectifs sont remplis
    player:CompleteQuest(QUEST_ID)

    -- Apprendre la monture si nécessaire
    if not player:HasSpell(MOUNT_SPELL_ID) then
        player:LearnSpell(MOUNT_SPELL_ID)
        player:SendBroadcastMessage("Vous avez appris à invoquer votre monture !")
    end

    -- Monter
    player:CastSpell(player, MOUNT_SPELL_ID, true)

    -- Fermer le gossip sans menu
    player:GossipComplete()
end

RegisterCreatureGossipEvent(NPC_ENTRY, 1, OnGossipHello)
