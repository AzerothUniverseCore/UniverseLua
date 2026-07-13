-- ============================================================
--  Peroth'arn - Le Démon Eredar | NPC ID : 55085
--  Puits d'éternité
--  TrinityCore 3.3.5a | Eluna Lua 2023/2024
-- ============================================================

local NPC_PEROTHARD = 55085

-- ------------------------------------------------------------
-- Spell IDs  (sorts WotLK 3.3.5 thème fel / ombre / démon)
-- ------------------------------------------------------------
local SPELL_FEL_FLAMES        = 68163   -- Fel Flames : flammes fel projetées sur une cible
local SPELL_SHADOW_BOLT       = 47809   -- Shadow Bolt : projectile ombre-fel sur la cible
local SPELL_RAIN_OF_FIRE      = 42223   -- Rain of Fire : pluie de feu fel sur une zone
local SPELL_CURSE_OF_AGONY    = 47864   -- Curse of Agony : malédiction fel sur la cible
local SPELL_FEAR              = 38595   -- Fear : panique sur un joueur proche
local SPELL_RAKE              = 48574   -- Rake : griffes avant — dégâts + saignement
local SPELL_SWIPE             = 48562   -- Swipe : frappe en arc large
local SPELL_MANGLE            = 48566   -- Mangle : déchirure physique lourde
local SPELL_CLEAVE            = 15284   -- Cleave : frappe en cône devant le boss
local SPELL_FEL_NOVA          = 47430   -- Fel Nova : explosion fel massive en zone
local SPELL_DEMONIC_AURA      = 34883   -- Demonic Aura : aura fel passive (buff boss)
local SPELL_SHADOW_WORD_PAIN  = 48125   -- Shadow Word: Pain : malédiction ombre persistante
local SPELL_ENRAGE            = 8599    -- Enrage : fureur à 20% PV

-- ------------------------------------------------------------
-- Callbacks des sorts
-- ------------------------------------------------------------

-- Fel Flames sur joueur proche
local function Cast_FelFlames(eventId, delay, repeats, creature)
    local target = creature:GetNearestPlayer(35)
    if not target then target = creature:GetVictim() end
    if target then
        creature:CastSpell(target, SPELL_FEL_FLAMES, false)
        creature:SendUnitEmote("Les flammes fel consumment la chair des mortels !", 0)
    end
end

-- Shadow Bolt sur le tank
local function Cast_ShadowBolt(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_SHADOW_BOLT, false)
    end
end

-- Rain of Fire sur un joueur proche
local function Cast_RainOfFire(eventId, delay, repeats, creature)
    local target = creature:GetNearestPlayer(40)
    if not target then target = creature:GetVictim() end
    if target then
        creature:CastSpell(target, SPELL_RAIN_OF_FIRE, false)
        creature:SendUnitEmote("Le ciel saigne le feu fel ! Dispersez-vous !", 0)
    end
end

-- Curse of Agony sur le tank
local function Cast_CurseOfAgony(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_CURSE_OF_AGONY, false)
        creature:SendUnitEmote("Peroth'arn pose une malédiction dévastatrice sur sa cible !", 0)
    end
end

-- Fear sur un joueur proche
local function Cast_Fear(eventId, delay, repeats, creature)
    local target = creature:GetNearestPlayer(20)
    if not target then target = creature:GetVictim() end
    if target then
        creature:CastSpell(target, SPELL_FEAR, false)
        creature:SendUnitYell("TREMBLEZ DEVANT MOI !", 0)
    end
end

-- Rake : griffes + saignement sur le tank
local function Cast_Rake(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_RAKE, false)
    end
end

-- Swipe : large balayage en arc
local function Cast_Swipe(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_SWIPE, false)
    creature:SendUnitEmote("Peroth'arn lacère tout ce qui se trouve devant lui !", 0)
end

-- Mangle : déchirure physique lourde sur le tank
local function Cast_Mangle(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_MANGLE, false)
    end
end

-- Cleave : frappe en cône
local function Cast_Cleave(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_CLEAVE, false)
    end
end

-- Fel Nova : explosion fel massive
local function Cast_FelNova(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_FEL_NOVA, false)
    creature:SendUnitYell("L'énergie fel vous dévore ! Ressentez ma puissance !", 0)
end

-- Shadow Word: Pain sur le tank
local function Cast_ShadowWordPain(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_SHADOW_WORD_PAIN, false)
        creature:SendUnitEmote("L'ombre ronge l'âme de sa cible !", 0)
    end
end

-- Enrage à 20% PV
local function Check_Enrage(eventId, delay, repeats, creature)
    local hpPct = creature:GetHealthPct()
    if hpPct <= 20 and not creature:HasAura(SPELL_ENRAGE) then
        creature:AddAura(SPELL_ENRAGE, creature)
        creature:SendUnitYell("VOUS NE POUVEZ PAS ME VAINCRE ! JE SUIS L'OMBRE ET LE FEL !", 0)
        creature:RemoveEventById(eventId)
    end
end

-- ------------------------------------------------------------
-- OnEnterCombat
-- ------------------------------------------------------------
local function Perothard_OnEnterCombat(event, creature, target)
    creature:SendUnitYell("Vous osez pénétrer dans ce sanctuaire ? Vos âmes appartiennent au Néant !", 0)
    creature:AddAura(SPELL_DEMONIC_AURA, creature)

    -- RegisterEvent(func, delay_ms, repeats, creature)  repeats=0 = infini
    creature:RegisterEvent(Cast_Rake,          4000,  0)   -- Griffes rapides sur tank
    creature:RegisterEvent(Cast_Cleave,        6000,  0)   -- Frappe en cône
    creature:RegisterEvent(Cast_ShadowBolt,    7000,  0)   -- Projectile ombre
    creature:RegisterEvent(Cast_Mangle,        9000,  0)   -- Déchirure lourde
    creature:RegisterEvent(Cast_CurseOfAgony,  11000, 0)   -- Malédiction tank
    creature:RegisterEvent(Cast_Swipe,         13000, 0)   -- Balayage en arc
    creature:RegisterEvent(Cast_ShadowWordPain,16000, 0)   -- Douleur ombre persistante
    creature:RegisterEvent(Cast_FelFlames,     18000, 0)   -- Flammes fel sur joueur
    creature:RegisterEvent(Cast_Fear,          22000, 0)   -- Peur sur joueur proche
    creature:RegisterEvent(Cast_RainOfFire,    28000, 0)   -- Pluie de feu
    creature:RegisterEvent(Cast_FelNova,       38000, 0)   -- Explosion fel massive
    creature:RegisterEvent(Check_Enrage,       1000,  0)   -- Vérif enrage
end

-- ------------------------------------------------------------
-- OnDied
-- ------------------------------------------------------------
local function Perothard_OnDied(event, creature, killer)
    creature:SendUnitYell("Le Puits... vous accordera... ce que vous méritez...", 0)
    creature:RemoveEvents()
end

-- ------------------------------------------------------------
-- OnReset
-- ------------------------------------------------------------
local function Perothard_OnReset(event, creature)
    creature:SendUnitYell("Fuyez pendant que vous le pouvez encore.", 0)
    creature:RemoveEvents()
end

-- ------------------------------------------------------------
-- Enregistrement Eluna
-- ------------------------------------------------------------
RegisterCreatureEvent(NPC_PEROTHARD, 1, Perothard_OnEnterCombat)
RegisterCreatureEvent(NPC_PEROTHARD, 2, Perothard_OnDied)
RegisterCreatureEvent(NPC_PEROTHARD, 4, Perothard_OnReset)
