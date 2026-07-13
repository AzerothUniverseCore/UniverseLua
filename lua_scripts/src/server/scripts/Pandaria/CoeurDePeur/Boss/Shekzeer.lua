local NPC_ID = 62837

-- Liste des sorts
local SPELLS = {
    --123713,
	-- 123723,
	--123707,
	--123504,
	--123255,
	-- 123596,
	-- 123184,
	-- 123735,
	-- 123788,
	-- 125464,
	--124845,
	--124849,
	--124844,
	-- 124842,
	-- 124843,
	--124863,
	-- 124862,
	-- 125390,
	--124077,
	--125886,
	--124097,
	--124748,
	-- 124092,
	-- 124310,
	-- 125803,
	-- 125704,
	-- 125719,
	-- 125824,
	-- 124777,
	--124807,
	--124821,
	--125422,
	--125451,
	72242,
	-- 125098,
	26662,
	-- 125283,
	-- 123846,
	-- 123840,
	-- 125639,
	--123845,
	--125638,
	--126121,
	-- 126125,
}

local CreatureAI = {}

function CreatureAI.OnEnterCombat(event, creature, target)
    creature:RegisterEvent(CreatureAI.CastRandomSpell, 8000, 0)
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
