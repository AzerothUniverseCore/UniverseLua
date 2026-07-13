-- Création du miniboss Orc niveau 80
local npcEntry = 9000371 -- Remplacez 12345 par l'ID d'entrée de votre miniboss

local spells = {
    9876, -- ID du premier sort
    9835, -- ID du deuxième sort
    9853, -- ID du troisième sort
	9867,
	9858,
	9896,
	10060,
	10134,
	10442,
	10732,
	18152,
	18399,
	18607,
	18670,
	18807,
	18972,
	22993,
	22994,
    -- Ajoutez les ID des autres sorts ici
}

function MiniBossOrc_OnSpawn(event, creature)
    creature:SetData("miniboss_spawned", true) -- Marquer le miniboss comme apparu
end

function MiniBossOrc_OnEnterCombat(event, creature, target)
    creature:RegisterEvent(MiniBossOrc_CastRandomSpell, 6000, 0) -- Lancer un sort aléatoire toutes les 6 secondes
end

function MiniBossOrc_CastRandomSpell(event, delay, pCall, creature)
    local target = creature:GetVictim()
    if not target then
        creature:RemoveEvents() -- Si la cible est perdue, arrêter de lancer des sorts
        return
    end
    local randomSpell = spells[math.random(1, #spells)] -- Choisir un sort aléatoire de la liste
    creature:CastSpell(target, randomSpell, true) -- Lancer le sort sur la cible
end

function MiniBossOrc_OnLeaveCombat(event, creature)
    creature:RemoveEvents() -- Arrêter tous les événements lorsque le miniboss quitte le combat
end

function MiniBossOrc_OnDied(event, creature, killer)
    creature:RemoveEvents() -- Arrêter tous les événements lorsque le miniboss meurt
end

RegisterCreatureEvent(npcEntry, 1, MiniBossOrc_OnEnterCombat)
RegisterCreatureEvent(npcEntry, 2, MiniBossOrc_OnLeaveCombat)
RegisterCreatureEvent(npcEntry, 3, MiniBossOrc_OnDied)
RegisterCreatureEvent(npcEntry, 4, MiniBossOrc_OnSpawn)
