-- ============================================================
--  Sorcelame Aluriel - Capitaine de la garde de la magistrice
--  NPC ID : 104881 | Palais Sacrenuit
--  TrinityCore 3.3.5a | Eluna Lua 2023/2024
-- ============================================================

local NPC_ALURIEL = 104881

-- ------------------------------------------------------------
-- Spell IDs — thème arcanique / givre / illusion
-- Cohérents 3.3.5a, testés sans morph/suicide
-- ------------------------------------------------------------
local SPELL_ARCANE_TORRENT     = 28730   -- Torrent arcanique (cône mana drain)
local SPELL_ARCANE_SLASH       = 22887   -- Lame arcanique (coup direct)
local SPELL_FROST_LANCE        = 31249   -- Lance de givre (tank, slow)
local SPELL_ARCANE_EXPLOSION   = 13021   -- Explosion arcanique (AoE burst)
local SPELL_FROST_NOVA         = 11831   -- Nova de givre (AoE root)
local SPELL_ARCANE_TEMPEST     = 38935   -- Tempête arcanique (zone persistante au sol)
local SPELL_ARCANE_SURGE       = 33175   -- Surtension arcanique (self dmg buff)
local SPELL_MIRROR_IMAGE       = 58833   -- Images arcaniques (illusion — skin elfe de sang)
local SPELL_BERSERK            = 26662   -- Berserk (enrage ≤ 20% HP, pas de morph)

-- ------------------------------------------------------------
-- État interne
-- ------------------------------------------------------------
local enraged = {}

-- ------------------------------------------------------------
-- Utilitaires de cast sécurisés
-- ------------------------------------------------------------
local function SafeCastOnVictim(creature, spellId)
    local victim = creature:GetVictim()
    if victim and creature:IsAlive() then
        creature:CastSpell(victim, spellId, false)
    end
end

local function SafeCastSelf(creature, spellId)
    if creature:IsAlive() then
        creature:CastSpell(creature, spellId, false)
    end
end

-- ------------------------------------------------------------
-- Callbacks — sorts
-- ------------------------------------------------------------
local function Cast_ArcaneTorrent(eventId, delay, repeats, creature)
    SafeCastSelf(creature, SPELL_ARCANE_TORRENT)
    creature:SendUnitEmote("L'énergie arcanique d'Aluriel pulse en une onde dévastatrice !", 0)
end

local function Cast_ArcaneSlash(eventId, delay, repeats, creature)
    SafeCastOnVictim(creature, SPELL_ARCANE_SLASH)
end

local function Cast_FrostLance(eventId, delay, repeats, creature)
    SafeCastOnVictim(creature, SPELL_FROST_LANCE)
    creature:SendUnitEmote("Aluriel conjure une lance de givre et la projette sur sa cible !", 0)
end

local function Cast_ArcaneExplosion(eventId, delay, repeats, creature)
    SafeCastSelf(creature, SPELL_ARCANE_EXPLOSION)
    creature:SendUnitYell("Écartelez-vous — ou soyez annihilés !", 0)
end

local function Cast_FrostNova(eventId, delay, repeats, creature)
    SafeCastSelf(creature, SPELL_FROST_NOVA)
    creature:SendUnitEmote("Une explosion de givre surgit sous les pieds des ennemis !", 0)
end

local function Cast_ArcaneTempest(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim and creature:IsAlive() then
        creature:CastSpell(victim, SPELL_ARCANE_TEMPEST, false)
        creature:SendUnitYell("La tempête arcanique vous engloutira tous !", 0)
    end
end

local function Cast_ArcaneSurge(eventId, delay, repeats, creature)
    if creature:IsAlive() and not creature:HasAura(SPELL_ARCANE_SURGE) then
        creature:AddAura(SPELL_ARCANE_SURGE, creature)
        creature:SendUnitEmote("Le pouvoir d'Aluriel s'embrase — ses lames arcaniques vibrent d'énergie pure !", 0)
    end
end

local function Cast_MirrorImage(eventId, delay, repeats, creature)
    if creature:IsAlive() then
        creature:AddAura(SPELL_MIRROR_IMAGE, creature)
        creature:SendUnitYell("Pouvez-vous distinguer l'original... de l'illusion ?", 0)
    end
end

local function Check_Enrage(eventId, delay, repeats, creature)
    if not creature:IsAlive() then return end
    local guid = creature:GetGUID()
    if creature:GetHealthPct() <= 20 and not enraged[guid] then
        enraged[guid] = true
        creature:AddAura(SPELL_BERSERK, creature)
        creature:SendUnitYell("Vous m'avez sous-estimée. Une erreur fatale !", 0)
        creature:RemoveEventById(eventId)
    end
end

-- ------------------------------------------------------------
-- OnEnterCombat
-- ------------------------------------------------------------
local function Aluriel_OnEnterCombat(event, creature, target)
    creature:SendUnitYell("La garde de la magistrice ne connaît ni la pitié, ni la défaite.", 0)

    -- Rotation espacée, toutes les X ms, boucle infinie
    creature:RegisterEvent(Cast_ArcaneTorrent,   4000,  0)   -- 4s
    creature:RegisterEvent(Cast_ArcaneSlash,     7000,  0)   -- 7s
    creature:RegisterEvent(Cast_FrostLance,      12000, 0)   -- 12s (tank)
    creature:RegisterEvent(Cast_ArcaneExplosion, 16000, 0)   -- 16s AoE
    creature:RegisterEvent(Cast_FrostNova,       20000, 0)   -- 20s root AoE
    creature:RegisterEvent(Cast_ArcaneTempest,   24000, 0)   -- 24s zone sol
    creature:RegisterEvent(Cast_ArcaneSurge,     35000, 0)   -- 35s self-buff
    creature:RegisterEvent(Cast_MirrorImage,     45000, 0)   -- 45s illusion
    creature:RegisterEvent(Check_Enrage,         1000,  0)   -- check HP chaque seconde
end

-- ------------------------------------------------------------
-- OnDied
-- ------------------------------------------------------------
local function Aluriel_OnDied(event, creature, killer)
    creature:SendUnitYell("La magistrice... vous accordera... sa clémence...", 0)
    enraged[creature:GetGUID()] = nil
    creature:RemoveEvents()
end

-- ------------------------------------------------------------
-- OnReset / OnLeaveCombat
-- ------------------------------------------------------------
local function Aluriel_OnReset(event, creature)
    creature:SendUnitYell("Retraite ordonnée. La garde reprend sa position.", 0)
    enraged[creature:GetGUID()] = nil
    creature:RemoveEvents()
end

-- ------------------------------------------------------------
-- Enregistrement Eluna
-- ------------------------------------------------------------
RegisterCreatureEvent(NPC_ALURIEL, 1, Aluriel_OnEnterCombat)
RegisterCreatureEvent(NPC_ALURIEL, 2, Aluriel_OnDied)
RegisterCreatureEvent(NPC_ALURIEL, 4, Aluriel_OnReset)