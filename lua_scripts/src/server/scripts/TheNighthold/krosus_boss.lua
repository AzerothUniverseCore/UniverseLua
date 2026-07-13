-- ============================================================
--  Krosus - Le Démon Félon | NPC ID : 101002
--  Palais Sacrenuit
--  TrinityCore 3.3.5a | Eluna Lua 2023/2024
-- ============================================================

local NPC_KROSUS = 101002

-- ------------------------------------------------------------
-- Spell IDs  (sorts WotLK cohérents avec un démon fel corrompu)
-- ------------------------------------------------------------
local SPELL_FEL_FIREBALL       = 47773   -- Boule de feu fel (projectile direct)
local SPELL_SHADOW_BOLT        = 17228   -- Éclair des ombres (dégâts shadow)
local SPELL_BURNING_SMASH      = 47721   -- Smash enflammé (dégâts zone au sol)
local SPELL_FEL_BEAM           = 54509   -- Rayon fel en ligne
local SPELL_RAIN_OF_FIRE       = 42223   -- Pluie de feu (zone persistante)
local SPELL_CORRUPT            = 47812   -- Corruption (DoT shadow)
local SPELL_SHADOW_NOVA        = 47948   -- Nova des ombres (burst zone)
local SPELL_IMMOLATE           = 47811   -- Immolation (DoT feu)
local SPELL_CHAOS_BOLT         = 50796   -- Éclair du chaos (dégâts lourds)
local SPELL_ENRAGE             = 8599    -- Enrage à basse vie

-- ------------------------------------------------------------
-- Callbacks des sorts
-- ------------------------------------------------------------
local function Cast_FelFireball(eventId, delay, repeats, creature)
    local target = creature:GetNearestPlayer(40)
    if not target then
        target = creature:GetVictim()
    end
    if target then
        creature:CastSpell(target, SPELL_FEL_FIREBALL, false)
    end
end

local function Cast_ShadowBolt(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_SHADOW_BOLT, false)
    end
end

local function Cast_BurningSmash(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_BURNING_SMASH, false)
    creature:SendUnitEmote("Krosus fracasse le sol de son poing colossal !", 0)
end

local function Cast_FelBeam(eventId, delay, repeats, creature)
    local target = creature:GetNearestPlayer(40)
    if not target then
        target = creature:GetVictim()
    end
    if target then
        creature:CastSpell(target, SPELL_FEL_BEAM, false)
        creature:SendUnitEmote("Un rayon de Fel dévaste tout sur son passage !", 0)
    end
end

local function Cast_RainOfFire(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_RAIN_OF_FIRE, false)
        creature:SendUnitYell("Brûlez dans les flammes du Néant !", 0)
    end
end

local function Cast_Corrupt(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_CORRUPT, false)
        creature:SendUnitEmote("L'énergie corrompue de Krosus ronge son adversaire !", 0)
    end
end

local function Cast_ShadowNova(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_SHADOW_NOVA, false)
    creature:SendUnitYell("L'Ombre vous engloutira tous !", 0)
end

local function Cast_Immolate(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_IMMOLATE, false)
    end
end

local function Cast_ChaosBolt(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_CHAOS_BOLT, false)
        creature:SendUnitEmote("Krosus concentre toute l'énergie du Chaos en un seul impact !", 0)
    end
end

local function Check_Enrage(eventId, delay, repeats, creature)
    local hpPct = creature:GetHealthPct()
    if hpPct <= 20 and not creature:HasAura(SPELL_ENRAGE) then
        creature:AddAura(SPELL_ENRAGE, creature)
        creature:SendUnitYell("VOUS NE POUVEZ PAS M'ARRÊTER ! LE FEL EST ÉTERNEL !", 0)
        creature:RemoveEventById(eventId)
    end
end

-- ------------------------------------------------------------
-- OnEnterCombat
-- ------------------------------------------------------------
local function Krosus_OnEnterCombat(event, creature, target)
    creature:SendUnitYell("Votre résistance n'est que faiblesse ! Le Sacrenuit tombera !", 0)

    -- Attaque rapide shadow de base
    creature:RegisterEvent(Cast_ShadowBolt,    4000,  0)
    -- Boule de feu fel vers joueur aléatoire
    creature:RegisterEvent(Cast_FelFireball,   6000,  0)
    -- DoT feu
    creature:RegisterEvent(Cast_Immolate,      9000,  0)
    -- DoT shadow
    creature:RegisterEvent(Cast_Corrupt,       12000, 0)
    -- Smash zone autour de lui
    creature:RegisterEvent(Cast_BurningSmash,  15000, 0)
    -- Rayon fel directionnel
    creature:RegisterEvent(Cast_FelBeam,       20000, 0)
    -- Pluie de feu zone
    creature:RegisterEvent(Cast_RainOfFire,    25000, 0)
    -- Nova des ombres burst
    creature:RegisterEvent(Cast_ShadowNova,    30000, 0)
    -- Éclair du chaos (coup lourd)
    creature:RegisterEvent(Cast_ChaosBolt,     35000, 0)
    -- Vérif enrage (< 20 % HP)
    creature:RegisterEvent(Check_Enrage,       1000,  0)
end

-- ------------------------------------------------------------
-- OnDied
-- ------------------------------------------------------------
local function Krosus_OnDied(event, creature, killer)
    creature:SendUnitYell("Impossible... Le Fel... ne peut pas... être vaincu...", 0)
    creature:RemoveEvents()
end

-- ------------------------------------------------------------
-- OnReset
-- ------------------------------------------------------------
local function Krosus_OnReset(event, creature)
    creature:SendUnitYell("Vous avez eu de la chance. Cela ne se reproduira pas.", 0)
    creature:RemoveEvents()
end

-- ------------------------------------------------------------
-- Enregistrement Eluna
-- ------------------------------------------------------------
RegisterCreatureEvent(NPC_KROSUS, 1,  Krosus_OnEnterCombat)
RegisterCreatureEvent(NPC_KROSUS, 2,  Krosus_OnDied)
RegisterCreatureEvent(NPC_KROSUS, 4,  Krosus_OnReset)
