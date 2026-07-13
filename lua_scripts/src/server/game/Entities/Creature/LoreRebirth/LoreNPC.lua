local NPC_ID = 338080 -- Remplacez 338080 par l'ID de votre NPC

function OnGossipHello(event, player, object)
    player:GossipClearMenu()
    player:GossipSetText("Bienvenue, aventurier, permettez-moi de vous expliquer le lore du système de Rebirth.\n\nLe Rebirth est un système conçu pour récompenser les efforts de votre personnage. Il implique de parcourir à nouveau les niveaux de 1 à 90, mais pas seulement ! Il inclut également la progression à travers les niveaux de Rebirth. À chaque niveau de Rebirth atteint, vous bénéficierez de 'Buffs de caractéristiques' activables à tout moment à l'aide d'une pierre spéciale appelée 'Pierre de Rebirth'. Cette pierre débloquera bien plus que de simples améliorations d'état pour votre personnage. En plus de l'expérience acquise grâce aux niveaux de Rebirth, vous pourrez collecter des 'Infusions de Vie' et des 'Explosions de Vie'. Ces éléments vous permettront d'obtenir des héritages personnalisés et des niveaux supplémentaires.")

    player:GossipSendMenu(0x7FFFFFFF, object)
end

RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)
