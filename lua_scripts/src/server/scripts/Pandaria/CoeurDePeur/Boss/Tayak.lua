local NPC_ID = 62543

-- Liste des sorts
local SPELLS = {
    -- 128788,
	-- 122842,
	-- 122854,
	-- 122853,
	-- 122839,
	-- 122949,
	123017,
	123175,
	-- 123180,
	-- 123460,
	-- 123459,
	123471,
	-- 123470,
	-- 132254,
	123474,
	125310,
	-- 125325,
	-- 125327,
	-- 123814,
	-- 123598,
	-- 123599,
	-- 124024,
	-- 124785,
	-- 123633,
	-- 123616,
	-- 123805,
	-- 124025,
	-- 123597,
	-- 123639,
	-- 123640,
	-- 123643,
	-- 123644,
	-- 123645,
	26662, 
	123497,
	-- 128968,
	128949,
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
