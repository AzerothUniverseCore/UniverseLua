local phasedDungeons={};

phasedDungeons.config = {
  
  npcEntry = 9000046;
  
  maxDifficulty = 2; -- Difficulty > 1 && Limit is 31
  
  minLevel = 80; -- Minimum level for Difficulty +
  
};

function phasedDungeons.onGossipHello(event, player, object)
  
  local pPhase = player:GetPhaseMask(); -- Ont récupére la phase du joueur
  local pLevel = player:GetLevel(); -- Ont récupére le niveau du joueur
  
  if (pLevel >= phasedDungeons.config.minLevel)then -- Si le joueur est niveau égale ou supérieur à minLevel ..
    
    if (pPhase ~= 1)then -- Si sa phase est différente de 1 ...
      player:GossipMenuAddItem(9, 'Revenir à la difficulté A0', 1, 1); -- Ont affiche la possibilités de passer à la difficultés normal
      player:GossipMenuAddItem(0, 'Finalement j\'ai changés d\'avis', 1, 0);
      
    else -- Sinon
      
      for i = 1, phasedDungeons.config.maxDifficulty do -- On affiche autant de menu qu'il y a de maxDifficulty
        player:GossipMenuAddItem(9, "Vaisseau de la Légion A"..i, 1, phaseCalc(i)); -- Puis ont affiche le menu
      end
	  player:GossipMenuAddItem(0, 'Finalement j\'ai changés d\'avis', 1, 0);
    end
    
    player:GossipSetText('Oh! Je vois un aventurier prêt à combattre des créatures plus puissantes ..\n\nSeulement serais vous prêt pour ce qui vous attends ?'); -- Texte customisés
    player:GossipSendMenu(0x7FFFFFFF, object); -- On envoie le menu
    
  else
    player:SendNotification('Vous devez être du niveau '..phasedDungeons.config.minLevel..' minimum.'); -- On envoie un message d'erreur si le joueur n'est pas niveau minLevel
  end
end
RegisterCreatureGossipEvent(phasedDungeons.config.npcEntry, 1, phasedDungeons.onGossipHello);

function phasedDungeons.delPhase(event, player)
  player:SetPhaseMask(1);
  return true;
end

function phasedDungeons.addPhase(event, player, phase)
  player:SetPhaseMask(phase);
  return true;
end

function phasedDungeons.onGossipSelect(event, player, object, sender, intid, code, menuid)
  
  if (intid == 0)then -- Si le joueur fait le choix 0 alors
    
    player:GossipComplete(); -- Puis ont ferme le Gossip
  
elseif (intid == 1)then-- Si le joueur fait le choix 1 (Donc retour à la normal) alors
  
    phasedDungeons.delPhase(event, player); -- On remet sa phase à 1
    player:SendNotification('Vous voilà dans la difficulté Vaisseau de la Légion A0'); -- On envoie un message au joueur
    phasedDungeons.onGossipHello(event, player, object); -- On renvoie le menu
  
  else -- Si il fait un choix supérieur à 1
    
    for i = 1, phasedDungeons.config.maxDifficulty do -- On récupére toutes les maxDifficulty
      
      if(intid == phaseCalc(i))then -- Si notre choix correspond à un niveau de difficultés alors
        
        phasedDungeons.addPhase(event, player, intid); -- On phase le joueur dans sa difficultés choisis
        player:SendNotification('Vous voilà dans la difficulté Vaisseau de la Légion A'..i); -- On envoie un message au joueur
        player:GossipComplete(); -- Puis ont ferme le Gossip
      end
    end
  end
end
RegisterCreatureGossipEvent(phasedDungeons.config.npcEntry, 2, phasedDungeons.onGossipSelect);

function phasedDungeons.onMapChange(event, player)
  
  local pPhase = player:GetPhaseMask(); -- Ont récupére la phase du joueur
  local pMap = player:GetMap(); -- Ont récupére la map du joueur
  
  if(pMap:IsDungeon() == false or pMap:IsRaid() == false)then -- Si la map n'est ni un Donjon ni un Raid alors
  
    if(pPhase ~= 1)then -- Si le joueur est dans une autre phase que la 1 alors
      phasedDungeons.delPhase(event, player); -- Ont déphase le joueur
    end
  end
end
RegisterPlayerEvent(28, phasedDungeons.onMapChange);
