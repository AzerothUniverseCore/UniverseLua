local NPC_ID = 62511

-- Liste des sorts
local SPELLS = {
    122004,
    121994,
    122503,
    121949,
    122370,
    122784,
    124824,
    122556,
    123014,
    122547,
    122551,
    126939,
    122398,
    122389,
    123059,
    123060,
    123156,
    122516,
    122395,
    122408,
    122413,
    122420,
    122419,
    122418,
    122457,
    122540,
    122415,
    43671, 
    122348,
    122532,
    142191,
    125498,
    125508,
    125502,
    142189,
}

local CreatureAI = {}

function CreatureAI.OnEnterCombat(event, creature, target)
    creature:RegisterEvent(CreatureAI.CastRandomSpell, 12000, 0)
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
