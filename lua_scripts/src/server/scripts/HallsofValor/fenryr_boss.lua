-- ============================================================
--  Fenryr - Le Loup Ancestral | NPC ID : 99868
--  Salles des Valeureux
--  TrinityCore 3.3.5a | Eluna Lua 2023/2024
-- ============================================================

local NPC_FENRYR = 99868

-- ------------------------------------------------------------
-- Spell IDs  (sorts WotLK cohérents avec un loup bestial)
-- ------------------------------------------------------------
local SPELL_SAVAGE_BITE        = 46050   -- Morsure sauvage (dégâts directs)
local SPELL_GRIEVOUS_BITE      = 48920   -- Morsure déchirante (saignement DoT)
local SPELL_FERAL_CHARGE       = 49376   -- Charge bestiale vers la cible
local SPELL_HOWL_OF_TERROR     = 39048   -- Hurlement terrifiant (fuite)
local SPELL_REND               = 13738   -- Déchirure (saignement physique)
local SPELL_PRIMAL_HOWL        = 23604   -- Hurlement primal (debuff vitesse d'attaque)
local SPELL_SWIPE              = 53526   -- Coup de griffe en cône
local SPELL_VICIOUS_SLASH      = 43176   -- Taillade vicieuse (dégâts élevés)
local SPELL_ENRAGE             = 8599    -- Enrage à basse vie

-- ------------------------------------------------------------
-- Callbacks des sorts
-- ------------------------------------------------------------
local function Cast_SavageBite(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_SAVAGE_BITE, false)
    end
end

local function Cast_GrievousBite(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_GRIEVOUS_BITE, false)
        creature:SendUnitEmote("Fenryr lacère sa proie avec une férocité animale !", 0)
    end
end

local function Cast_FeralCharge(eventId, delay, repeats, creature)
    local target = creature:GetNearestPlayer(40)
    if not target then
        target = creature:GetVictim()
    end
    if target then
        creature:CastSpell(target, SPELL_FERAL_CHARGE, false)
        creature:SendUnitEmote("Fenryr bondit sur sa proie !", 0)
    end
end

local function Cast_HowlOfTerror(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_HOWL_OF_TERROR, false)
    creature:SendUnitYell("*Hurlement strident et glaçant*", 0)
end

local function Cast_Rend(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_REND, false)
    end
end

local function Cast_PrimalHowl(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_PRIMAL_HOWL, false)
    creature:SendUnitEmote("Fenryr pousse un hurlement primal qui glace le sang !", 0)
end

local function Cast_Swipe(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_SWIPE, false)
    creature:SendUnitEmote("Fenryr frappe sauvagement tout ce qui l'entoure !", 0)
end

local function Cast_ViciousSlash(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_VICIOUS_SLASH, false)
        creature:SendUnitEmote("Fenryr décoche une taillade meurtrière !", 0)
    end
end

local function Check_Enrage(eventId, delay, repeats, creature)
    local hpPct = creature:GetHealthPct()
    if hpPct <= 20 and not creature:HasAura(SPELL_ENRAGE) then
        creature:AddAura(SPELL_ENRAGE, creature)
        creature:SendUnitYell("*Fenryr rugit avec une rage déchaînée !*", 0)
        creature:RemoveEventById(eventId)
    end
end

-- ------------------------------------------------------------
-- OnEnterCombat
-- ------------------------------------------------------------
local function Fenryr_OnEnterCombat(event, creature, target)
    creature:SendUnitYell("*Fenryr gronde et se ramasse sur lui-même, prêt à bondir...*", 0)

    -- Attaque principale rapide
    creature:RegisterEvent(Cast_SavageBite,    3500,  0)
    -- Saignement toutes les 8 secondes
    creature:RegisterEvent(Cast_Rend,          8000,  0)
    -- Morsure déchirante (saignement lourd)
    creature:RegisterEvent(Cast_GrievousBite,  12000, 0)
    -- Charge vers un joueur aléatoire
    creature:RegisterEvent(Cast_FeralCharge,   18000, 0)
    -- Griffe en cône
    creature:RegisterEvent(Cast_Swipe,         10000, 0)
    -- Taillade forte
    creature:RegisterEvent(Cast_ViciousSlash,  22000, 0)
    -- Hurlement de terreur
    creature:RegisterEvent(Cast_HowlOfTerror,  30000, 0)
    -- Hurlement primal (debuff)
    creature:RegisterEvent(Cast_PrimalHowl,    25000, 0)
    -- Vérif enrage (< 20 % HP)
    creature:RegisterEvent(Check_Enrage,       1000,  0)
end

-- ------------------------------------------------------------
-- OnDied
-- ------------------------------------------------------------
local function Fenryr_OnDied(event, creature, killer)
    creature:SendUnitYell("*Fenryr s'effondre dans un dernier souffle...*", 0)
    creature:RemoveEvents()
end

-- ------------------------------------------------------------
-- OnReset
-- ------------------------------------------------------------
local function Fenryr_OnReset(event, creature)
    creature:SendUnitYell("*Fenryr retourne à sa veille, l'œil fixé sur les intrus...*", 0)
    creature:RemoveEvents()
end

-- ------------------------------------------------------------
-- Enregistrement Eluna
-- ------------------------------------------------------------
RegisterCreatureEvent(NPC_FENRYR, 1,  Fenryr_OnEnterCombat)
RegisterCreatureEvent(NPC_FENRYR, 2,  Fenryr_OnDied)
RegisterCreatureEvent(NPC_FENRYR, 4,  Fenryr_OnReset)
