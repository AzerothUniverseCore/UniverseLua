-- ============================================================
--  Skorpyron - Le Scorpion Arcanique | NPC ID : 102263
--  Palais Sacrenuit
--  TrinityCore 3.3.5a | Eluna Lua 2023/2024
-- ============================================================

local NPC_SKORPYRON = 102263

-- ------------------------------------------------------------
-- Spell IDs  (sorts WotLK cohérents avec un scorpion cristallin arcanique)
-- ------------------------------------------------------------
local SPELL_ARCANE_SLASH       = 50182   -- Taillade arcanique (dégâts directs)
local SPELL_CRYSTAL_SPIKE      = 51332   -- Pointe de cristal (projectile arcanique)
local SPELL_POISON_STING       = 65983   -- Piqûre venimeuse (DoT poison)
local SPELL_SHATTER            = 46270   -- Fracas cristallin (AoE zone)
local SPELL_ARCANE_BARRAGE     = 50804   -- Barrage arcanique (salve à distance)
local SPELL_CRUSHING_CLAWS     = 50327   -- Pinces broyeuses (dégâts + armor debuff)
local SPELL_VENOM_SPRAY        = 59283   -- Jet de venin en cône (DoT)
local SPELL_ARCANE_RESONANCE   = 50543   -- Résonance arcanique (aura debuff)
local SPELL_CRYSTAL_PRISON     = 46771   -- Prison de cristal (root ciblé)
local SPELL_ENRAGE             = 8599    -- Enrage à basse vie

-- ------------------------------------------------------------
-- Callbacks des sorts
-- ------------------------------------------------------------
local function Cast_ArcaneSlash(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_ARCANE_SLASH, false)
    end
end

local function Cast_CrystalSpike(eventId, delay, repeats, creature)
    local target = creature:GetNearestPlayer(40)
    if not target then
        target = creature:GetVictim()
    end
    if target then
        creature:CastSpell(target, SPELL_CRYSTAL_SPIKE, false)
        creature:SendUnitEmote("Skorpyron propulse un éclat de cristal tranchant !", 0)
    end
end

local function Cast_PoisonSting(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_POISON_STING, false)
        creature:SendUnitEmote("Le dard de Skorpyron injecte un venin dévastateur !", 0)
    end
end

local function Cast_Shatter(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_SHATTER, false)
    creature:SendUnitEmote("Skorpyron fait éclater ses cristaux dans toutes les directions !", 0)
end

local function Cast_ArcaneBarrage(eventId, delay, repeats, creature)
    local target = creature:GetNearestPlayer(40)
    if not target then
        target = creature:GetVictim()
    end
    if target then
        creature:CastSpell(target, SPELL_ARCANE_BARRAGE, false)
        creature:SendUnitYell("Sentez le pouvoir des cristaux !", 0)
    end
end

local function Cast_CrushingClaws(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_CRUSHING_CLAWS, false)
        creature:SendUnitEmote("Les pinces massives de Skorpyron broient son adversaire !", 0)
    end
end

local function Cast_VenomSpray(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_VENOM_SPRAY, false)
    creature:SendUnitEmote("Skorpyron crache un jet de venin corrosif !", 0)
end

local function Cast_ArcaneResonance(eventId, delay, repeats, creature)
    creature:AddAura(SPELL_ARCANE_RESONANCE, creature)
    creature:SendUnitEmote("L'énergie arcanique de Skorpyron pulse avec une intensité croissante !", 0)
end

local function Cast_CrystalPrison(eventId, delay, repeats, creature)
    local target = creature:GetNearestPlayer(40)
    if not target then
        target = creature:GetVictim()
    end
    if target then
        creature:CastSpell(target, SPELL_CRYSTAL_PRISON, false)
        creature:SendUnitYell("Les cristaux vous emprisonnent !", 0)
    end
end

local function Check_Enrage(eventId, delay, repeats, creature)
    local hpPct = creature:GetHealthPct()
    if hpPct <= 20 and not creature:HasAura(SPELL_ENRAGE) then
        creature:AddAura(SPELL_ENRAGE, creature)
        creature:SendUnitYell("*Skorpyron vibre d'une énergie cristalline déchaînée !*", 0)
        creature:RemoveEventById(eventId)
    end
end

-- ------------------------------------------------------------
-- OnEnterCombat
-- ------------------------------------------------------------
local function Skorpyron_OnEnterCombat(event, creature, target)
    creature:SendUnitYell("*Skorpyron claque ses pinces et les cristaux qui l'entourent vibrent de rage !*", 0)

    -- Attaque de base arcanique
    creature:RegisterEvent(Cast_ArcaneSlash,      3500,  0)
    -- Pointe de cristal vers cible aléatoire
    creature:RegisterEvent(Cast_CrystalSpike,     7000,  0)
    -- DoT venin sur le tank
    creature:RegisterEvent(Cast_PoisonSting,      10000, 0)
    -- Pinces broyeuses (armor debuff)
    creature:RegisterEvent(Cast_CrushingClaws,    13000, 0)
    -- Jet de venin en cône
    creature:RegisterEvent(Cast_VenomSpray,       17000, 0)
    -- Éclatement de cristaux AoE
    creature:RegisterEvent(Cast_Shatter,          21000, 0)
    -- Barrage arcanique à distance
    creature:RegisterEvent(Cast_ArcaneBarrage,    25000, 0)
    -- Prison de cristal (root)
    creature:RegisterEvent(Cast_CrystalPrison,    29000, 0)
    -- Aura de résonance arcanique
    creature:RegisterEvent(Cast_ArcaneResonance,  35000, 0)
    -- Vérif enrage (< 20 % HP)
    creature:RegisterEvent(Check_Enrage,          1000,  0)
end

-- ------------------------------------------------------------
-- OnDied
-- ------------------------------------------------------------
local function Skorpyron_OnDied(event, creature, killer)
    creature:SendUnitYell("*Les cristaux de Skorpyron se brisent en mille éclats...*", 0)
    creature:RemoveEvents()
end

-- ------------------------------------------------------------
-- OnReset
-- ------------------------------------------------------------
local function Skorpyron_OnReset(event, creature)
    creature:SendUnitYell("*Skorpyron se fige, ses cristaux scintillant d'un éclat menaçant...*", 0)
    creature:RemoveEvents()
end

-- ------------------------------------------------------------
-- Enregistrement Eluna
-- ------------------------------------------------------------
RegisterCreatureEvent(NPC_SKORPYRON, 1,  Skorpyron_OnEnterCombat)
RegisterCreatureEvent(NPC_SKORPYRON, 2,  Skorpyron_OnDied)
RegisterCreatureEvent(NPC_SKORPYRON, 4,  Skorpyron_OnReset)
