local NPC_GRUNT_THROG = 166583
local QUEST_DISCIPLE_CHALLENGE = 59927

local FACTION_HOSTILE = 15
local FACTION_FRIENDLY = 2104
local LOW_HEALTH_PERCENT = 20
local STABLE_HEALTH_PERCENT = 100

-- Table pour suivre les créatures qui se sont déjà rendues
local surrenderedCreatures = {}

-- Gossip Hello - Afficher le menu
local function OnGossipHello(event, player, creature)
    -- Vérifier si le joueur a la quête
    if not player:HasQuest(QUEST_DISCIPLE_CHALLENGE) then
        player:SendBroadcastMessage("Vous devez avoir la quête pour commencer le défi.")
        return
    end
    
    -- Réinitialiser si la créature s'est déjà rendue
    surrenderedCreatures[creature:GetGUID()] = nil
    creature:RemoveFlag(33, 2)
    creature:SetHealth(creature:GetMaxHealth())
    
    player:GossipClearMenu()
    player:GossipMenuAddItem(0, "Commencer le défi", 0, 1)
    player:GossipSendMenu(1, creature)
end

-- Gossip Select - Quand le joueur clique
local function OnGossipSelect(event, player, creature, sender, intid, code)
    if intid == 1 then
        player:GossipComplete()
        player:SendBroadcastMessage("Le défi commence !")
        
        -- Réinitialiser l'état
        surrenderedCreatures[creature:GetGUID()] = nil
        creature:RemoveFlag(33, 2)
        
        -- Changer la faction et attaquer
        creature:SetFaction(FACTION_HOSTILE)
        creature:ClearThreatList()
        creature:AddThreat(player, 100000)
        creature:AttackStart(player)
    end
end

-- Intercepter les dégâts AVANT qu'ils soient appliqués
local function OnDamageTaken(event, creature, attacker, damage)
    local guid = creature:GetGUID()
    
    -- Si déjà rendu, ignorer
    if surrenderedCreatures[guid] then
        return
    end
    
    if creature:GetFaction() == FACTION_HOSTILE then
        local currentHealth = creature:GetHealth()
        local maxHealth = creature:GetMaxHealth()
        local healthAfterDamage = currentHealth - damage
        local thresholdHealth = math.floor(maxHealth * (LOW_HEALTH_PERCENT / 100))
        
        -- Si le prochain coup va descendre sous le seuil
        if healthAfterDamage <= thresholdHealth then
            -- Stabiliser la vie à 100%
            local stableHealth = math.floor(maxHealth * (STABLE_HEALTH_PERCENT / 100))
            creature:SetHealth(stableHealth)
            
            -- Marquer comme rendu
            surrenderedCreatures[guid] = true
            
            -- Rendre immune aux dégâts
            creature:SetFlag(33, 2) -- UNIT_FLAG_NON_ATTACKABLE
            
            -- Repasser en faction amicale
            creature:SetFaction(FACTION_FRIENDLY)
            creature:ClearThreatList()
            creature:AttackStop()
            
            if attacker and attacker:ToPlayer() then
                local player = attacker:ToPlayer()
                player:SendBroadcastMessage("Victoire ! Grunt Throg se rend.")
                
                -- Compléter la quête directement (pas de KillCredit)
                if player:HasQuest(QUEST_DISCIPLE_CHALLENGE) then
                    player:CompleteQuest(QUEST_DISCIPLE_CHALLENGE)
                end
            end
        end
    end
end

local function OnLeaveCombat(event, creature)
    local guid = creature:GetGUID()
    
    if creature:GetFaction() == FACTION_HOSTILE then
        creature:SetFaction(FACTION_FRIENDLY)
    end
    
    -- Ne pas réinitialiser si rendu, attendre le prochain gossip
    if not surrenderedCreatures[guid] then
        creature:RemoveFlag(33, 2)
        creature:SetHealth(creature:GetMaxHealth())
    end
end

local function OnDied(event, creature, killer)
    local guid = creature:GetGUID()
    creature:SetFaction(FACTION_FRIENDLY)
    surrenderedCreatures[guid] = nil
end

local function OnSpawn(event, creature)
    local guid = creature:GetGUID()
    creature:SetFaction(FACTION_FRIENDLY)
    creature:SetHealth(creature:GetMaxHealth())
    creature:RemoveFlag(33, 2)
    surrenderedCreatures[guid] = nil
end

-- Enregistrer les gossips pour Grunt Throg
RegisterCreatureGossipEvent(NPC_GRUNT_THROG, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_GRUNT_THROG, 2, OnGossipSelect)

-- Enregistrer les événements de combat
RegisterCreatureEvent(NPC_GRUNT_THROG, 2, OnLeaveCombat)
RegisterCreatureEvent(NPC_GRUNT_THROG, 4, OnDied)
RegisterCreatureEvent(NPC_GRUNT_THROG, 5, OnSpawn)
RegisterCreatureEvent(NPC_GRUNT_THROG, 9, OnDamageTaken)