-- ============================================================
--  Bourberax - Le Vase Putride | NPC ID : 112255
--  Palais Sacrenuit
--  TrinityCore 3.3.5a | Eluna Lua 2023/2024
-- ============================================================

local NPC_BOURBERAX = 112255

-- ------------------------------------------------------------
-- Spell IDs  (sorts WotLK cohérents avec un slime putride / vase corrompu)
-- ------------------------------------------------------------
local SPELL_ACID_SPIT          = 55492   -- Crachat acide (projectile direct)
local SPELL_POISON_CLOUD        = 53312   -- Nuage toxique (AoE zone persistante)
local SPELL_SLIME_NOVA          = 42638   -- Nova de slime (burst autour de lui)
local SPELL_CORROSIVE_OOZE      = 56743   -- Vase corrosive (DoT empoisonnement)
local SPELL_DISEASE_CLOUD       = 37506   -- Nuage de maladie (debuff zone)
local SPELL_PUTRID_BILE         = 53378   -- Bile putride (projectile empoisonné)
local SPELL_TOXIC_VOLLEY        = 34616   -- Volée toxique (multi-cibles)
local SPELL_PLAGUE_STRIKE       = 49917   -- Frappe pestilentielle (dégâts + DoT)
local SPELL_NAUSEATING_POISON   = 30993   -- Poison nauséabond (slow + DoT)
local SPELL_ENRAGE              = 8599    -- Enrage à basse vie

-- ------------------------------------------------------------
-- Callbacks des sorts
-- ------------------------------------------------------------
local function Cast_AcidSpit(eventId, delay, repeats, creature)
    local target = creature:GetNearestPlayer(40)
    if not target then
        target = creature:GetVictim()
    end
    if target then
        creature:CastSpell(target, SPELL_ACID_SPIT, false)
        creature:SendUnitEmote("Bourberax crache un jet d'acide corrosif !", 0)
    end
end

local function Cast_PoisonCloud(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_POISON_CLOUD, false)
        creature:SendUnitEmote("Une épaisse vapeur toxique s'échappe du corps de Bourberax !", 0)
    end
end

local function Cast_SlimeNova(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_SLIME_NOVA, false)
    creature:SendUnitYell("*Bourberax gargouille et explose en une gerbe de vase !*", 0)
end

local function Cast_CorrosiveOoze(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_CORROSIVE_OOZE, false)
        creature:SendUnitEmote("La vase corrosive de Bourberax ronge l'armure de sa proie !", 0)
    end
end

local function Cast_DiseaseCloud(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_DISEASE_CLOUD, false)
    creature:SendUnitEmote("Un nuage de maladie pestilentielle enveloppe les intrus !", 0)
end

local function Cast_PutridBile(eventId, delay, repeats, creature)
    local target = creature:GetNearestPlayer(40)
    if not target then
        target = creature:GetVictim()
    end
    if target then
        creature:CastSpell(target, SPELL_PUTRID_BILE, false)
        creature:SendUnitEmote("Bourberax régurgite une bile immonde sur ses ennemis !", 0)
    end
end

local function Cast_ToxicVolley(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_TOXIC_VOLLEY, false)
    creature:SendUnitYell("Vous baignerez tous dans mon venin !", 0)
end

local function Cast_PlagueStrike(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_PLAGUE_STRIKE, false)
    end
end

local function Cast_NauseatingPoison(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_NAUSEATING_POISON, false)
        creature:SendUnitEmote("Le poison de Bourberax ralentit et affaiblit son adversaire !", 0)
    end
end

local function Check_Enrage(eventId, delay, repeats, creature)
    local hpPct = creature:GetHealthPct()
    if hpPct <= 20 and not creature:HasAura(SPELL_ENRAGE) then
        creature:AddAura(SPELL_ENRAGE, creature)
        creature:SendUnitYell("*Bourberax gargouille violemment et déborde de vase toxique !*", 0)
        creature:RemoveEventById(eventId)
    end
end

-- ------------------------------------------------------------
-- OnEnterCombat
-- ------------------------------------------------------------
local function Bourberax_OnEnterCombat(event, creature, target)
    creature:SendUnitYell("*Bourberax gargouillle... une odeur pestilentielle emplit la salle !*", 0)

    -- Crachat acide vers cible aléatoire
    creature:RegisterEvent(Cast_AcidSpit,          5000,  0)
    -- Frappe pestilentielle sur le tank
    creature:RegisterEvent(Cast_PlagueStrike,       3500,  0)
    -- DoT vase corrosive
    creature:RegisterEvent(Cast_CorrosiveOoze,      8000,  0)
    -- Poison ralentissant
    creature:RegisterEvent(Cast_NauseatingPoison,   12000, 0)
    -- Nuage de poison zone
    creature:RegisterEvent(Cast_PoisonCloud,        16000, 0)
    -- Bile putride vers joueur aléatoire
    creature:RegisterEvent(Cast_PutridBile,         20000, 0)
    -- Nuage de maladie AoE
    creature:RegisterEvent(Cast_DiseaseCloud,       24000, 0)
    -- Nova de slime burst autour de lui
    creature:RegisterEvent(Cast_SlimeNova,          28000, 0)
    -- Volée toxique multi-cibles
    creature:RegisterEvent(Cast_ToxicVolley,        33000, 0)
    -- Vérif enrage (< 20 % HP)
    creature:RegisterEvent(Check_Enrage,            1000,  0)
end

-- ------------------------------------------------------------
-- OnDied
-- ------------------------------------------------------------
local function Bourberax_OnDied(event, creature, killer)
    creature:SendUnitYell("*Bourberax se répand en une flaque de vase inerte...*", 0)
    creature:RemoveEvents()
end

-- ------------------------------------------------------------
-- OnReset
-- ------------------------------------------------------------
local function Bourberax_OnReset(event, creature)
    creature:SendUnitYell("*Bourberax gargouille et se stabilise, prêt à engloutir le prochain intrus...*", 0)
    creature:RemoveEvents()
end

-- ------------------------------------------------------------
-- Enregistrement Eluna
-- ------------------------------------------------------------
RegisterCreatureEvent(NPC_BOURBERAX, 1,  Bourberax_OnEnterCombat)
RegisterCreatureEvent(NPC_BOURBERAX, 2,  Bourberax_OnDied)
RegisterCreatureEvent(NPC_BOURBERAX, 4,  Bourberax_OnReset)
