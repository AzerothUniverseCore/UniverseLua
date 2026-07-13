local MINIBOSS_NPC_ID = 5100127

local SPELL_FLAMES_1 = 11684
local SPELL_FLAMES_2 = 70283
local SPELL_FLAMES_3 = 39132
local SPELL_FLAMES_SHOCK = 10448
local SPELL_FLAMES_STRIKE = 11829
local SPELL_FLAMES_BREAK = 16785
local SPELL_FLAMES_TOTEM = 15867
local SPELL_FLAMES_WRATH = 16559
local SPELL_VERY_HOT_FLAMES = 20570
local SPELL_FLAMES_WHIP = 27655
local SPELL_FLAMES_WAVE_1 = 33803
local SPELL_FLAMES_WAVE_2 = 33804

local MiniBossAI = {}

local spellsToCast = {
    SPELL_FLAMES_1,
    SPELL_FLAMES_2,
    SPELL_FLAMES_3,
    SPELL_FLAMES_SHOCK,
    SPELL_FLAMES_STRIKE,
    SPELL_FLAMES_BREAK,
    SPELL_FLAMES_TOTEM,
    SPELL_FLAMES_WRATH,
    SPELL_VERY_HOT_FLAMES,
    SPELL_FLAMES_WHIP,
    SPELL_FLAMES_WAVE_1,
    SPELL_FLAMES_WAVE_2
}

local currentIndex = 1

function MiniBossAI.OnEnterCombat(event, creature, target)
    creature:RegisterEvent(MiniBossAI.CastNextSpell, 10000, 0)
end

function MiniBossAI.CastNextSpell(event, delay, pCall, creature)
    local target = creature:GetVictim()
    
    if not target then
        creature:RemoveEvents()
        return
    end
    
    creature:CastSpell(target, spellsToCast[currentIndex], true)
    
    currentIndex = currentIndex + 1
    if currentIndex > #spellsToCast then
        currentIndex = 1
    end
end

function MiniBossAI.Register()
    RegisterCreatureEvent(MINIBOSS_NPC_ID, 1, MiniBossAI.OnEnterCombat)
end

MiniBossAI.Register()
