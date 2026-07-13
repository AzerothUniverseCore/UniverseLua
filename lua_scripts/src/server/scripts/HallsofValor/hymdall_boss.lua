-- ============================================================
--  Hymdall - Le Gardien | NPC ID : 94960
--  Salles des Valeureux
--  TrinityCore 3.3.5a | Eluna Lua 2023/2024
-- ============================================================

local NPC_HYMDALL = 94960

-- ------------------------------------------------------------
-- Spell IDs
-- ------------------------------------------------------------
local SPELL_HEROIC_STRIKE      = 29426
local SPELL_THUNDER_CLAP       = 36706
local SPELL_WHIRLWIND          = 41056
local SPELL_CLEAVE             = 15284
local SPELL_THUNDERSTRUCK      = 64688
local SPELL_STORM_STRIKE       = 17364
local SPELL_BATTLE_SHOUT       = 31403
local SPELL_INTIMIDATING_SHOUT = 19134
local SPELL_BLADESTORM         = 46425
local SPELL_ENRAGE             = 8599

-- ------------------------------------------------------------
-- Callbacks des sorts (fonctions passées à RegisterEvent)
-- ------------------------------------------------------------
local function Cast_HeroicStrike(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_HEROIC_STRIKE, false)
    end
end

local function Cast_ThunderClap(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_THUNDER_CLAP, false)
    creature:SendUnitEmote("Hymdall frappe le sol avec force !", 0)
end

local function Cast_Whirlwind(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_WHIRLWIND, false)
    creature:SendUnitYell("Reculez ou mourrez !", 0)
end

local function Cast_Cleave(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_CLEAVE, false)
    end
end

local function Cast_Thunderstruck(eventId, delay, repeats, creature)
    -- GetRandomPlayer n'existe pas en Eluna 3.3.5 — on cible le nearest player
    local target = creature:GetNearestPlayer(30)
    if not target then
        target = creature:GetVictim()
    end
    if target then
        creature:CastSpell(target, SPELL_THUNDERSTRUCK, false)
        creature:SendUnitEmote("La foudre s'abat sur l'un des intrus !", 0)
    end
end

local function Cast_StormStrike(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_STORM_STRIKE, false)
    end
end

local function Cast_BattleShout(eventId, delay, repeats, creature)
    creature:AddAura(SPELL_BATTLE_SHOUT, creature)
    creature:SendUnitYell("La force des Salles coule dans mes veines !", 0)
end

local function Cast_IntimidatingShout(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_INTIMIDATING_SHOUT, false)
    creature:SendUnitEmote("Hymdall rugit d'une voix terrifiante !", 0)
end

local function Cast_Bladestorm(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_BLADESTORM, false)
    creature:SendUnitYell("Voilà la tempête des lames !", 0)
end

local function Check_Enrage(eventId, delay, repeats, creature)
    local hpPct = creature:GetHealthPct()
    if hpPct <= 20 and not creature:HasAura(SPELL_ENRAGE) then
        creature:AddAura(SPELL_ENRAGE, creature)
        creature:SendUnitYell("RARGH ! Vous m'avez poussé à bout !", 0)
        creature:RemoveEventById(eventId)
    end
end

-- ------------------------------------------------------------
-- OnEnterCombat
-- ------------------------------------------------------------
local function Hymdall_OnEnterCombat(event, creature, target)
    creature:SendUnitYell("Vous n'aurez pas accès à ces salles ! Je suis le Gardien !", 0)
    creature:AddAura(SPELL_BATTLE_SHOUT, creature)

    -- RegisterEvent(func, delay_ms, repeats, creature)  repeats=0 = infini
    creature:RegisterEvent(Cast_HeroicStrike,      4000,  0)
    creature:RegisterEvent(Cast_ThunderClap,       8000,  0)
    creature:RegisterEvent(Cast_Whirlwind,         15000, 0)
    creature:RegisterEvent(Cast_Cleave,            6000,  0)
    creature:RegisterEvent(Cast_Thunderstruck,     20000, 0)
    creature:RegisterEvent(Cast_StormStrike,       10000, 0)
    creature:RegisterEvent(Cast_BattleShout,       30000, 0)
    creature:RegisterEvent(Cast_IntimidatingShout, 25000, 0)
    creature:RegisterEvent(Cast_Bladestorm,        35000, 0)
    creature:RegisterEvent(Check_Enrage,           1000,  0)
end

-- ------------------------------------------------------------
-- OnDied
-- ------------------------------------------------------------
local function Hymdall_OnDied(event, creature, killer)
    creature:SendUnitYell("Impossible... Les Salles... sont à vous...", 0)
    creature:RemoveEvents()
end

-- ------------------------------------------------------------
-- OnReset
-- ------------------------------------------------------------
local function Hymdall_OnReset(event, creature)
    creature:SendUnitYell("Ne revenez plus jamais ici.", 0)
    creature:RemoveEvents()
end

-- ------------------------------------------------------------
-- Enregistrement Eluna
-- ------------------------------------------------------------
RegisterCreatureEvent(NPC_HYMDALL, 1,  Hymdall_OnEnterCombat)
RegisterCreatureEvent(NPC_HYMDALL, 2,  Hymdall_OnDied)
RegisterCreatureEvent(NPC_HYMDALL, 4,  Hymdall_OnReset)
