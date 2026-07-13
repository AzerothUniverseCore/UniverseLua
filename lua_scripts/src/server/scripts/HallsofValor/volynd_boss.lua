-- ============================================================
--  Volynd Porte-tempête | NPC ID : 106320
--  Salles des Valeureux
--  TrinityCore 3.3.5a | Eluna Lua 2023/2024
-- ============================================================

local NPC_VOLYND = 106320

-- ------------------------------------------------------------
-- Spell IDs
-- ------------------------------------------------------------
local SPELL_MORTAL_STRIKE     = 39171   -- Frappe dévastatrice -50% soins
local SPELL_SHOCKWAVE         = 46968   -- Cône AoE stun devant
local SPELL_THUNDER_CLAP      = 36706   -- AoE foudre ralentisseur
local SPELL_STORMBOLT         = 64213   -- Projectile foudre stun monocible
local SPELL_REND              = 29574   -- DoT saignement
local SPELL_HAMSTRING         = 9080    -- Slow sur la cible
local SPELL_AVATAR            = 64440   -- Buff colossal boost dégâts
local SPELL_SLAM              = 47475   -- Frappe lente très puissante
local SPELL_CHAIN_LIGHTNING   = 45297   -- Foudre rebondissante 3 cibles
local SPELL_ENRAGE            = 8599    -- Enrage à 20% HP

-- ------------------------------------------------------------
-- Callbacks des sorts
-- ------------------------------------------------------------
local function Cast_MortalStrike(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_MORTAL_STRIKE, false)
    end
end

local function Cast_Shockwave(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_SHOCKWAVE, false)
    creature:SendUnitEmote("Volynd projette une onde de choc dévastatrice !", 0)
end

local function Cast_ThunderClap(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_THUNDER_CLAP, false)
    creature:SendUnitEmote("Le tonnerre gronde sous les pieds de Volynd !", 0)
end

local function Cast_Stormbolt(eventId, delay, repeats, creature)
    local target = creature:GetNearestPlayer(40)
    if not target then
        target = creature:GetVictim()
    end
    if target then
        creature:CastSpell(target, SPELL_STORMBOLT, false)
        creature:SendUnitYell("La tempête vous réclame !", 0)
    end
end

local function Cast_Rend(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_REND, false)
    end
end

local function Cast_Hamstring(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_HAMSTRING, false)
        creature:SendUnitEmote("Volynd tranche les tendons de sa cible !", 0)
    end
end

local function Cast_Avatar(eventId, delay, repeats, creature)
    creature:AddAura(SPELL_AVATAR, creature)
    creature:SendUnitYell("Je suis la tempête incarnée !", 0)
end

local function Cast_Slam(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_SLAM, false)
        creature:SendUnitEmote("Volynd abat son arme avec une force colossale !", 0)
    end
end

local function Cast_ChainLightning(eventId, delay, repeats, creature)
    local target = creature:GetNearestPlayer(40)
    if not target then
        target = creature:GetVictim()
    end
    if target then
        creature:CastSpell(target, SPELL_CHAIN_LIGHTNING, false)
        creature:SendUnitEmote("La foudre enchaîne les intrus !", 0)
    end
end

local function Check_Enrage(eventId, delay, repeats, creature)
    local hpPct = creature:GetHealthPct()
    if hpPct <= 20 and not creature:HasAura(SPELL_ENRAGE) then
        creature:AddAura(SPELL_ENRAGE, creature)
        creature:SendUnitYell("VOUS NE PASSEREZ PAS ! LA TEMPÊTE VOUS ENGLOUTIT !", 0)
        creature:RemoveEventById(eventId)
    end
end

-- ------------------------------------------------------------
-- OnEnterCombat
-- ------------------------------------------------------------
local function Volynd_OnEnterCombat(event, creature, target)
    creature:SendUnitYell("Aucun mortel ne franchira ces salles tant que je vivrai !", 0)
    creature:AddAura(SPELL_AVATAR, creature)

    creature:RegisterEvent(Cast_MortalStrike,   5000,  0)
    creature:RegisterEvent(Cast_Shockwave,      10000, 0)
    creature:RegisterEvent(Cast_ThunderClap,    8000,  0)
    creature:RegisterEvent(Cast_Stormbolt,      14000, 0)
    creature:RegisterEvent(Cast_Rend,           6000,  0)
    creature:RegisterEvent(Cast_Hamstring,      12000, 0)
    creature:RegisterEvent(Cast_Avatar,         40000, 0)
    creature:RegisterEvent(Cast_Slam,           18000, 0)
    creature:RegisterEvent(Cast_ChainLightning, 22000, 0)
    creature:RegisterEvent(Check_Enrage,        1000,  0)
end

-- ------------------------------------------------------------
-- OnDied
-- ------------------------------------------------------------
local function Volynd_OnDied(event, creature, killer)
    creature:SendUnitYell("La... tempête... s'apaise...", 0)
    creature:RemoveEvents()
end

-- ------------------------------------------------------------
-- OnReset
-- ------------------------------------------------------------
local function Volynd_OnReset(event, creature)
    creature:SendUnitYell("Fuyez, et ne revenez plus !", 0)
    creature:RemoveEvents()
end

-- ------------------------------------------------------------
-- Enregistrement Eluna
-- ------------------------------------------------------------
RegisterCreatureEvent(NPC_VOLYND, 1, Volynd_OnEnterCombat)
RegisterCreatureEvent(NPC_VOLYND, 2, Volynd_OnDied)
RegisterCreatureEvent(NPC_VOLYND, 4, Volynd_OnReset)
