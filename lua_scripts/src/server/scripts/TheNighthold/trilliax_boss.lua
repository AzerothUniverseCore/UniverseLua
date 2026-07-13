-- ============================================================
--  Trilliax - L'Automate de Nettoyage | NPC ID : 104288
--  Palais Sacrenuit
--  TrinityCore 3.3.5a | Eluna Lua 2023/2024
-- ============================================================

local NPC_TRILLIAX = 104288

-- ------------------------------------------------------------
-- Spell IDs SÛRS pour 3.3.5a — vérifiés sans morph/suicide
-- ------------------------------------------------------------
local SPELL_CLEAVE             = 15284   -- Cleave (sûr, tank-facing)
local SPELL_ARCANE_SLASH       = 22887   -- Arcane Blow — sûr, pas de morph
local SPELL_FLAME_BREATH       = 34847   -- Flame Breath directionnel ✅
local SPELL_FLAME_JETS         = 54099   -- Flame Jets (Flame Leviathan) — sûr
local SPELL_ARCANE_PULSE       = 36032   -- Arcane Blast AoE — sûr
local SPELL_SABER_LASH         = 50800   -- Saber Lash ✅ sûr
local SPELL_SHOCKWAVE          = 46968   -- Shockwave ✅ sûr
local SPELL_WHIRLING_BLADES    = 23308   -- Whirlwind mécanique — sûr
local SPELL_BERSERK            = 26662   -- Berserk (haste + dmg, pas de morph)
-- SPELL_OVERLOAD retiré — remplacé par un self-buff sûr
local SPELL_POWER_SURGE        = 33666   -- Power Surge (self dmg buff) — sûr

-- ------------------------------------------------------------
-- État interne
-- ------------------------------------------------------------
local enraged = {}

-- ------------------------------------------------------------
-- Utilitaire : cast sécurisé sur victime
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
-- Callbacks — rotation propre
-- ------------------------------------------------------------
local function Cast_ArcaneSlash(eventId, delay, repeats, creature)
    SafeCastOnVictim(creature, SPELL_ARCANE_SLASH)
end

local function Cast_Cleave(eventId, delay, repeats, creature)
    SafeCastOnVictim(creature, SPELL_CLEAVE)
    creature:SendUnitEmote("Les lames de Trilliax s'abattent en un arc meurtrier !", 0)
end

local function Cast_SaberLash(eventId, delay, repeats, creature)
    SafeCastOnVictim(creature, SPELL_SABER_LASH)
    creature:SendUnitEmote("Trilliax décoche un coup de lame surpuissant !", 0)
end

local function Cast_FlameBreath(eventId, delay, repeats, creature)
    SafeCastSelf(creature, SPELL_FLAME_BREATH)
    creature:SendUnitEmote("Trilliax active son brûleur intégré !", 0)
end

local function Cast_FlameJets(eventId, delay, repeats, creature)
    SafeCastSelf(creature, SPELL_FLAME_JETS)
    creature:SendUnitYell("Protocole de stérilisation activé. Incinération en cours.", 0)
end

local function Cast_Shockwave(eventId, delay, repeats, creature)
    SafeCastSelf(creature, SPELL_SHOCKWAVE)
    creature:SendUnitYell("Système de défense périphérique engagé !", 0)
end

local function Cast_WhirlingBlades(eventId, delay, repeats, creature)
    SafeCastSelf(creature, SPELL_WHIRLING_BLADES)
    creature:SendUnitYell("Lames rotatoires déployées. Nettoyage en cours !", 0)
end

local function Cast_ArcanePulse(eventId, delay, repeats, creature)
    SafeCastSelf(creature, SPELL_ARCANE_PULSE)
    creature:SendUnitEmote("Trilliax libère une pulsation arcanique dévastatrice !", 0)
end

local function Cast_PowerSurge(eventId, delay, repeats, creature)
    -- Remplacement sûr de l'ancien Overload
    if creature:IsAlive() and not creature:HasAura(SPELL_POWER_SURGE) then
        creature:AddAura(SPELL_POWER_SURGE, creature)
        creature:SendUnitEmote("Les circuits de Trilliax surchauffent !", 0)
    end
end

local function Check_Enrage(eventId, delay, repeats, creature)
    if not creature:IsAlive() then return end
    local guid = creature:GetGUID()
    if creature:GetHealthPct() <= 20 and not enraged[guid] then
        enraged[guid] = true
        creature:AddAura(SPELL_BERSERK, creature)
        creature:SendUnitYell("Systèmes critiques. Mode destruction totale activé !", 0)
        creature:RemoveEventById(eventId)
    end
end

-- ------------------------------------------------------------
-- OnEnterCombat
-- ------------------------------------------------------------
local function Trilliax_OnEnterCombat(event, creature, target)
    creature:SendUnitYell("Intrus détectés. Protocole d'élimination engagé.", 0)

    -- Rotation espacée, repeats=0 = boucle infinie à intervalle fixe
    creature:RegisterEvent(Cast_ArcaneSlash,   4000,  0)  -- toutes les 4s
    creature:RegisterEvent(Cast_Cleave,        7000,  0)  -- toutes les 7s
    creature:RegisterEvent(Cast_SaberLash,     12000, 0)  -- toutes les 12s
    creature:RegisterEvent(Cast_FlameBreath,   16000, 0)  -- toutes les 16s
    creature:RegisterEvent(Cast_FlameJets,     20000, 0)  -- toutes les 20s
    creature:RegisterEvent(Cast_Shockwave,     24000, 0)  -- toutes les 24s
    creature:RegisterEvent(Cast_WhirlingBlades,28000, 0)  -- toutes les 28s
    creature:RegisterEvent(Cast_ArcanePulse,   35000, 0)  -- toutes les 35s
    creature:RegisterEvent(Cast_PowerSurge,    40000, 0)  -- toutes les 40s
    creature:RegisterEvent(Check_Enrage,       1000,  0)  -- check HP chaque seconde
end

-- ------------------------------------------------------------
-- OnDied
-- ------------------------------------------------------------
local function Trilliax_OnDied(event, creature, killer)
    creature:SendUnitYell("Systèmes... hors ligne... Nettoyage... incomplet...", 0)
    enraged[creature:GetGUID()] = nil
    creature:RemoveEvents()
end

-- ------------------------------------------------------------
-- OnReset / OnLeaveCombat
-- ------------------------------------------------------------
local function Trilliax_OnReset(event, creature)
    creature:SendUnitYell("Menace neutralisée. Reprise du protocole de nettoyage standard.", 0)
    enraged[creature:GetGUID()] = nil
    creature:RemoveEvents()
end

-- ------------------------------------------------------------
-- Enregistrement Eluna
-- ------------------------------------------------------------
RegisterCreatureEvent(NPC_TRILLIAX, 1,  Trilliax_OnEnterCombat)
RegisterCreatureEvent(NPC_TRILLIAX, 2,  Trilliax_OnDied)
RegisterCreatureEvent(NPC_TRILLIAX, 4,  Trilliax_OnReset)