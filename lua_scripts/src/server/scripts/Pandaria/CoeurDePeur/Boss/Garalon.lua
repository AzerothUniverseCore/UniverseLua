local NPC_ID = 62164

-- Liste des sorts
local SPELLS = {
    122735,
	122774,
	128555,
	122835,
	123092,
	123120,
	-- 122786,
	47008,
}

local CreatureAI = {}

function CreatureAI.OnEnterCombat(event, creature, target)
    creature:RegisterEvent(CreatureAI.CastRandomSpell, 14000, 0)
end

function CreatureAI.CastRandomSpell(event, delay, pCall, creature)
    local target = creature:GetVictim()
    if target then
        local randomSpellIndex = math.random(1, #SPELLS)
        local randomSpellID = SPELLS[randomSpellIndex]
        creature:CastSpell(target, randomSpellID, true)
    end
end

function CreatureAI.Register()
    RegisterCreatureEvent(NPC_ID, 1, CreatureAI.OnEnterCombat)
end

CreatureAI.Register()
