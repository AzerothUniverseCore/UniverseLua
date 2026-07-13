-- ============================================================
--  Infernal Incendiaire - Le Démon de Pierre | NPC ID : 111210
--  Palais Sacrenuit
--  TrinityCore 3.3.5a | Eluna Lua 2023/2024
-- ============================================================

local NPC_INFERNAL = 111210

-- ------------------------------------------------------------
-- Spell IDs  (sorts WotLK 3.3.5 thème feu / démon / chaos)
-- ------------------------------------------------------------
local SPELL_IMMOLATION        = 50453   -- Immolation : dégâts feu AoE autour du boss
local SPELL_RAIN_OF_FIRE      = 42223   -- Rain of Fire : pluie de feu sur une zone
local SPELL_HELLFIRE          = 11683   -- Hellfire : canal AOE feu autour du boss (Warlock rank 1, safe)
local SPELL_SEARING_PAIN      = 47827   -- Searing Pain : brûlure ciblée sur le tank
local SPELL_FEL_NOVA          = 47430   -- Fel Nova : explosion fel en zone autour du boss
local SPELL_FEL_FLAMES        = 68163   -- Fel Flames : flammes fel projetées sur une cible
local SPELL_SHADOW_BOLT       = 47809   -- Shadow Bolt : projectile ombre-feu sur la cible
local SPELL_CLEAVE            = 15284   -- Cleave : frappe en cône devant le boss
local SPELL_KNOCKBACK         = 20686   -- Knockback : repoussement violent
local SPELL_INFERNAL_AURA     = 34883   -- Infernal Aura : aura de feu passive (buff boss)
local SPELL_ENRAGE            = 8599    -- Enrage : fureur à 20% PV

-- ------------------------------------------------------------
-- Callbacks des sorts
-- ------------------------------------------------------------

-- Immolation permanente autour du boss (aura feu)
local function Cast_Immolation(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_IMMOLATION, false)
    creature:SendUnitEmote("Les flammes infernales s'embrasent autour de l'Infernal !", 0)
end

-- Pluie de feu sur un joueur aléatoire proche
local function Cast_RainOfFire(eventId, delay, repeats, creature)
    local target = creature:GetNearestPlayer(40)
    if not target then
        target = creature:GetVictim()
    end
    if target then
        creature:CastSpell(target, SPELL_RAIN_OF_FIRE, false)
        creature:SendUnitEmote("Le ciel s'enflamme ! Dispersez-vous !", 0)
    end
end

-- Hellfire : explosion AOE autour du boss
local function Cast_Hellfire(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_HELLFIRE, false)
    creature:SendUnitYell("BRÛLEZ ! BRÛLEZ TOUS !", 0)
end

-- Searing Pain : brûlure directe sur le tank
local function Cast_SearingPain(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_SEARING_PAIN, false)
    end
end

-- Fel Nova : explosion fel massive en zone
local function Cast_FelNova(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_FEL_NOVA, false)
    creature:SendUnitYell("L'énergie fel explose ! Fuyez !", 0)
end

-- Fel Flames : flammes fel projetées sur une cible proche
local function Cast_FelFlames(eventId, delay, repeats, creature)
    local target = creature:GetNearestPlayer(35)
    if not target then
        target = creature:GetVictim()
    end
    if target then
        creature:CastSpell(target, SPELL_FEL_FLAMES, false)
        creature:SendUnitEmote("L'Infernal projette des flammes fel dévastatrices !", 0)
    end
end

-- Shadow Bolt : projectile ombre-feu sur la cible principale
local function Cast_ShadowBolt(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_SHADOW_BOLT, false)
    end
end

-- Cleave : frappe en cône
local function Cast_Cleave(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_CLEAVE, false)
    end
end

-- Knockback : repoussement brutal
local function Cast_Knockback(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_KNOCKBACK, false)
    creature:SendUnitEmote("L'Infernal frappe le sol et projette ses ennemis en arrière !", 0)
end

-- Enrage à 20% PV
local function Check_Enrage(eventId, delay, repeats, creature)
    local hpPct = creature:GetHealthPct()
    if hpPct <= 20 and not creature:HasAura(SPELL_ENRAGE) then
        creature:AddAura(SPELL_ENRAGE, creature)
        creature:SendUnitYell("MA RAGE EST SANS LIMITE ! VOUS ALLEZ BRÛLER POUR L'ÉTERNITÉ !", 0)
        creature:RemoveEventById(eventId)
    end
end

-- ------------------------------------------------------------
-- OnEnterCombat
-- ------------------------------------------------------------
local function Infernal_OnEnterCombat(event, creature, target)
    creature:SendUnitYell("Mortels insignifiants... Je vais vous réduire en cendres !", 0)
    creature:AddAura(SPELL_INFERNAL_AURA, creature)

    -- RegisterEvent(func, delay_ms, repeats, creature)  repeats=0 = infini
    creature:RegisterEvent(Cast_SearingPain,  4000,  0)   -- Brûlure tank rapide
    creature:RegisterEvent(Cast_Cleave,       6000,  0)   -- Cleave régulier
    creature:RegisterEvent(Cast_ShadowBolt,   8000,  0)   -- Shadow Bolt sur tank
    creature:RegisterEvent(Cast_Immolation,   12000, 0)   -- Aura feu périodique
    creature:RegisterEvent(Cast_FelFlames,    15000, 0)   -- Flammes fel sur cible
    creature:RegisterEvent(Cast_Knockback,    18000, 0)   -- Repoussement
    creature:RegisterEvent(Cast_RainOfFire,   22000, 0)   -- Pluie de feu
    creature:RegisterEvent(Cast_Hellfire,     30000, 0)   -- Explosion AOE lourde
    creature:RegisterEvent(Cast_FelNova,      40000, 0)   -- Fel Nova massive
    creature:RegisterEvent(Check_Enrage,      1000,  0)   -- Vérif enrage
end

-- ------------------------------------------------------------
-- OnDied
-- ------------------------------------------------------------
local function Infernal_OnDied(event, creature, killer)
    creature:SendUnitYell("Impossible... Mon feu... s'éteint...", 0)
    creature:RemoveEvents()
end

-- ------------------------------------------------------------
-- OnReset
-- ------------------------------------------------------------
local function Infernal_OnReset(event, creature)
    creature:SendUnitYell("Allez-vous en ! Ou brûlez !", 0)
    creature:RemoveEvents()
end

-- ------------------------------------------------------------
-- Enregistrement Eluna
-- ------------------------------------------------------------
RegisterCreatureEvent(NPC_INFERNAL, 1, Infernal_OnEnterCombat)
RegisterCreatureEvent(NPC_INFERNAL, 2, Infernal_OnDied)
RegisterCreatureEvent(NPC_INFERNAL, 4, Infernal_OnReset)
