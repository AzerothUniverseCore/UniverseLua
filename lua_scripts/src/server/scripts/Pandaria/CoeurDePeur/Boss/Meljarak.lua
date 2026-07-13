local NPC_ID = 62397

-- Liste des sorts
local SPELLS = {
    -- 121896,
	-- 122406,
	-- 131813,
	125933,
	125935,
	125936,
	122354,
	-- 125873,
	47008,
	122224,
	131830,
	131835,
	-- 131814,
	131842,
	-- 121807,
	-- 123962,
	123963,
	-- 122409,
	-- 121876,
	121881,
	-- 121874,
	-- 121885,
	-- 129078,
	122055,
	-- 122064,
	129005,
	129009,
	-- 122125,
	-- 122193,
	122149,
}

local CreatureAI = {}

function CreatureAI.OnEnterCombat(event, creature, target)
    creature:RegisterEvent(CreatureAI.CastRandomSpell, 5000, 0)
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
