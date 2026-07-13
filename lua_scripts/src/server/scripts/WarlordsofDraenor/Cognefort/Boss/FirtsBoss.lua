local NPC_WARRIOR_ID = 338007

local SPELL_SMITE_STOMP_ID = 0
local SPELL_PULVERIZE_ID = 2676
local SPELL_CRANE_KICK_ID = 1300768
local SPELL_RAPTOR_ATTACK_ID = 27014
local SPELL_CHARGE_ID = 49758

local WarriorAI = {}

function WarriorAI.OnEnterCombat(event, creature, target)
    creature:RegisterEvent(WarriorAI.CastCharge, 1000, 0) -- 0 signifie qu'il se répète indéfiniment
    creature:RegisterEvent(WarriorAI.CastSmiteStomp, 10000, 0) -- 0 signifie qu'il se répète indéfiniment
    creature:RegisterEvent(WarriorAI.CastPulverize, 15000, 0) -- 0 signifie qu'il se répète indéfiniment
    creature:RegisterEvent(WarriorAI.CastCraneKick, 25000, 0) -- 0 signifie qu'il se répète indéfiniment
    creature:RegisterEvent(WarriorAI.CastRaptorAttack, 35000, 0) -- 0 signifie qu'il se répète indéfiniment
end

function WarriorAI.CastCharge(event, delay, pCall, creature)
    local target = creature:GetVictim()
    if target then
        creature:CastSpell(target, SPELL_CHARGE_ID, true)
    end
end

function WarriorAI.CastSmiteStomp(event, delay, pCall, creature)
    local target = creature:GetVictim()
    if target then
        creature:CastSpell(target, SPELL_SMITE_STOMP_ID, true)
    end
end

function WarriorAI.CastPulverize(event, delay, pCall, creature)
    local target = creature:GetVictim()
    if target then
        creature:CastSpell(target, SPELL_PULVERIZE_ID, true)
    end
end

function WarriorAI.CastCraneKick(event, delay, pCall, creature)
    local target = creature:GetVictim()
    if target then
        creature:CastSpell(target, SPELL_CRANE_KICK_ID, true)
    end
end

function WarriorAI.CastRaptorAttack(event, delay, pCall, creature)
    local target = creature:GetVictim()
    if target then
        creature:CastSpell(target, SPELL_RAPTOR_ATTACK_ID, true)
    end
end

function WarriorAI.Register()
    RegisterCreatureEvent(NPC_WARRIOR_ID, 1, WarriorAI.OnEnterCombat)
end

WarriorAI.Register()
