local NPC_ID = 62983

-- Liste des sorts
local SPELLS = {
    123181,
	123121,
	123244,
	123213,
	123233,
	123441,
	123250,
	123493,
	123505,
	123620,
	123625,
	123797,
	123705,
	123712,
	127535,
	125652,
	125724,
	125697,
}

local CreatureAI = {}

function CreatureAI.OnEnterCombat(event, creature, target)
    creature:RegisterEvent(CreatureAI.CastRandomSpell, 2000, 0)
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
