local npc_id = 77000  -- L'ID du PNJ auquel le joueur doit parler
local spawn_npc_id = 70000  -- L'ID du PNJ à faire apparaître
local spawn_duration = 60  -- Durée pendant laquelle le PNJ apparaîtra (en secondes)

-- Fonction pour poser la question au joueur avec une boîte de dialogue Oui/Non
function AskForPatch(event, player, creature)
    -- Efface le menu précédent
    player:GossipClearMenu()
    
    -- Texte de la question qui s'affiche au joueur
    player:GossipSetText("$N, êtes-vous prêt à invoquer vos fidèles combattants ? Sachez que vous ne pourrez en appeler que deux à vos côtés en raison des limites imposées par la magie d'invocation. Choisissez bien vos alliés, car ils seront vos plus précieux atouts dans la bataille !")

    -- Ajouter une option Oui pour confirmer que le joueur a le patch
    player:GossipMenuAddItem(9, "Oui, je suis prêt à invoquer mes alliés !", 1, 100)  -- Option Oui
    -- Ajouter une option Non pour dire que le joueur n'a pas le patch
    player:GossipMenuAddItem(7, "Non, je reviendrai plus tard.", 1, 101)  -- Option Non
    
    -- Envoi du menu de confirmation au joueur
    player:GossipSendMenu(0x7FFFFFFF, creature)  -- Utilisation de 0x7FFFFFFF pour envoyer un menu complet
end

-- Fonction pour gérer la réponse du joueur au menu de confirmation
function OnSelectGossipOption(event, player, creature, sender, action)
    if creature:GetEntry() == npc_id then  -- Vérifie que le joueur parle bien au PNJ avec l'ID 77000
        if action == 100 then  -- Si le joueur choisit l'option "Oui, j'ai bien le patch"
            -- Récupération de la position du joueur
            local x, y, z, o = player:GetX(), player:GetY(), player:GetZ(), player:GetO()

            -- Spawn du PNJ 70000 à la position du joueur avec un type de spawn temporaire et un timer de despawn
            local bot = creature:SpawnCreature(spawn_npc_id, x, y, z, o, 3, spawn_duration * 1000)  -- Type 3 : TEMPSUMMON_TIMED_DESPAWN

            -- Vérifie si le bot a été invoqué correctement
            if bot then
                player:SendBroadcastMessage("Alleria : Je suis ici pour vous servir, mais seulement pour une minute. Utilisez ce temps à bon escient !")
            else
                player:SendBroadcastMessage("Un trouble mystérieux empêche l'invocation... Essayez de nouveau, héros.")
            end

        elseif action == 101 then  -- Si le joueur choisit l'option "Non, je n'ai pas le patch"
            player:SendBroadcastMessage("Revenez lorsque vous serez prêt à rassembler vos fidèles combattants. N'oubliez pas, vous ne pourrez en invoquer que deux à la fois !")  -- Message pour indiquer que le joueur doit activer le patch
        end
        
        -- Ferme le menu de gossip
        player:GossipComplete()
    end
end

-- Enregistrer les événements
RegisterCreatureGossipEvent(npc_id, 1, AskForPatch)  -- Afficher le menu avec la question sur le patch
RegisterCreatureGossipEvent(npc_id, 2, OnSelectGossipOption)  -- Gérer les choix dans le menu de gossip
