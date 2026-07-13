local NPC_ID = 62980

-- Liste des sorts
local SPELLS = {
    -- 122440,
	-- 122740,
	-- 122852,
	122761,
	122760,
	123812, -- ok
	-- 123811,
	122713, -- ok
	122706, -- ok
	-- 122707,
	-- 123791, -- ok
	-- 132236,
	-- 122334,
	122336, -- ok
	-- 124018, 
	123833, -- ok
	-- 129353,
	125785, -- ok
	124668, -- ok
	-- 127496,
	-- 127541,
	-- 127542,
	-- 127543,
}

local CreatureAI = {}

function CreatureAI.OnEnterCombat(event, creature, target)
    creature:RegisterEvent(CreatureAI.CastRandomSpell, 3000, 0)
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
