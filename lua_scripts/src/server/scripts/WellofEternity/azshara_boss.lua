-- ============================================================
--  Reine Azshara - La Reine Éternelle | NPC ID : 54853
--  Puits d'éternité
--  TrinityCore 3.3.5a | Eluna Lua 2023/2024
-- ============================================================

local NPC_AZSHARA = 54853

-- ------------------------------------------------------------
-- Spell IDs  (sorts WotLK 3.3.5 thème arcane / foudre / enchantement)
-- ------------------------------------------------------------
local SPELL_ARCANE_BLAST       = 42897   -- Arcane Blast : explosion arcane puissante sur la cible
local SPELL_ARCANE_MISSILES    = 42846   -- Arcane Missiles : salve de missiles arcaniques
local SPELL_ARCANE_EXPLOSION   = 42921   -- Arcane Explosion : AOE arcane autour du boss
local SPELL_CHAIN_LIGHTNING    = 45297   -- Chain Lightning : foudre en chaîne sur plusieurs cibles
local SPELL_LIGHTNING_BOLT     = 49238   -- Lightning Bolt : éclair direct sur la cible
local SPELL_POLYMORPH          = 42914   -- Polymorph : transformation mouton sur un joueur
local SPELL_FROST_NOVA         = 42917   -- Frost Nova : gel des joueurs autour du boss
local SPELL_PYROBLAST          = 42925   -- Pyroblast : boule de feu massive sur la cible
local SPELL_BLIZZARD           = 42208   -- Blizzard : tempête de glace sur une zone
local SPELL_ARCANE_SURGE       = 33558   -- Arcane Surge : onde arcane dévastatrice (buff boss)
local SPELL_MANA_VOID          = 32830   -- Mana Void : vide de mana sur les casters
local SPELL_ENRAGE             = 8599    -- Enrage : fureur à 20% PV

-- ------------------------------------------------------------
-- Callbacks des sorts
-- ------------------------------------------------------------

-- Arcane Blast sur le tank
local function Cast_ArcaneBlast(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_ARCANE_BLAST, false)
    end
end

-- Arcane Missiles sur la cible principale
local function Cast_ArcaneMissiles(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_ARCANE_MISSILES, false)
        creature:SendUnitEmote("Azshara canalise la magie arcanique avec grâce et puissance !", 0)
    end
end

-- Arcane Explosion AOE autour du boss
local function Cast_ArcaneExplosion(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_ARCANE_EXPLOSION, false)
    creature:SendUnitYell("L'arcane jaillit de mon être ! Reculez !", 0)
end

-- Chain Lightning sur un joueur proche
local function Cast_ChainLightning(eventId, delay, repeats, creature)
    local target = creature:GetNearestPlayer(40)
    if not target then target = creature:GetVictim() end
    if target then
        creature:CastSpell(target, SPELL_CHAIN_LIGHTNING, false)
        creature:SendUnitEmote("La foudre bondit de cible en cible !", 0)
    end
end

-- Lightning Bolt sur le tank
local function Cast_LightningBolt(eventId, delay, repeats, creature)
    local victim = creature:GetVictim()
    if victim then
        creature:CastSpell(victim, SPELL_LIGHTNING_BOLT, false)
    end
end

-- Polymorph sur un joueur proche
local function Cast_Polymorph(eventId, delay, repeats, creature)
    local target = creature:GetNearestPlayer(30)
    if not target then target = creature:GetVictim() end
    if target then
        creature:CastSpell(target, SPELL_POLYMORPH, false)
        creature:SendUnitEmote("Azshara sourit et transforme un intrus d'un geste élégant.", 0)
    end
end

-- Frost Nova : gel autour du boss
local function Cast_FrostNova(eventId, delay, repeats, creature)
    creature:CastSpell(creature, SPELL_FROST_NOVA, false)
    creature:SendUnitYell("Restez donc à vos places... c'est un ordre.", 0)
end

-- Pyroblast : boule de feu massive sur joueur proche
local function Cast_Pyroblast(eventId, delay, repeats, creature)
    local target = creature:GetNearestPlayer(35)
    if not target then target = creature:GetVictim() end
    if target then
        creature:CastSpell(target, SPELL_PYROBLAST, false)
        creature:SendUnitEmote("La Reine lève la main et une boule de feu incandescente jaillit !", 0)
    end
end

-- Blizzard sur un joueur proche
local function Cast_Blizzard(eventId, delay, repeats, creature)
    local target = creature:GetNearestPlayer(40)
    if not target then target = creature:GetVictim() end
    if target then
        creature:CastSpell(target, SPELL_BLIZZARD, false)
        creature:SendUnitYell("Le froid éternel vous engloutira !", 0)
    end
end

-- Mana Void : drain de mana sur les casters
local function Cast_ManaVoid(eventId, delay, repeats, creature)
    local target = creature:GetNearestPlayer(30)
    if not target then target = creature:GetVictim() end
    if target then
        creature:CastSpell(target, SPELL_MANA_VOID, false)
        creature:SendUnitEmote("Azshara aspire le mana de ses adversaires pour alimenter sa magie !", 0)
    end
end

-- Enrage à 20% PV
local function Check_Enrage(eventId, delay, repeats, creature)
    local hpPct = creature:GetHealthPct()
    if hpPct <= 20 and not creature:HasAura(SPELL_ENRAGE) then
        creature:AddAura(SPELL_ENRAGE, creature)
        creature:SendUnitYell("Vous m'avez forcée à employer toute ma puissance... Quelle impertinence !", 0)
        creature:RemoveEventById(eventId)
    end
end

-- ------------------------------------------------------------
-- OnEnterCombat
-- ------------------------------------------------------------
local function Azshara_OnEnterCombat(event, creature, target)
    creature:SendUnitYell("Quelle audace... Vous oserez me défier, moi, Azshara ? Cela m'amuse... pour l'instant.", 0)
    creature:AddAura(SPELL_ARCANE_SURGE, creature)

    -- RegisterEvent(func, delay_ms, repeats, creature)  repeats=0 = infini
    creature:RegisterEvent(Cast_ArcaneBlast,    4000,  0)   -- Blast arcane tank rapide
    creature:RegisterEvent(Cast_LightningBolt,  6000,  0)   -- Éclair direct
    creature:RegisterEvent(Cast_ArcaneMissiles, 9000,  0)   -- Salve arcanique
    creature:RegisterEvent(Cast_ChainLightning, 12000, 0)   -- Foudre en chaîne
    creature:RegisterEvent(Cast_Polymorph,      16000, 0)   -- Mouton sur joueur
    creature:RegisterEvent(Cast_ManaVoid,       19000, 0)   -- Drain de mana
    creature:RegisterEvent(Cast_ArcaneExplosion,22000, 0)   -- AOE arcane
    creature:RegisterEvent(Cast_FrostNova,      26000, 0)   -- Gel autour du boss
    creature:RegisterEvent(Cast_Pyroblast,      32000, 0)   -- Boule de feu massive
    creature:RegisterEvent(Cast_Blizzard,       40000, 0)   -- Tempête de glace
    creature:RegisterEvent(Check_Enrage,        1000,  0)   -- Vérif enrage
end

-- ------------------------------------------------------------
-- OnDied
-- ------------------------------------------------------------
local function Azshara_OnDied(event, creature, killer)
    creature:SendUnitYell("Impossible... Moi... défaite... par des... mortels ordinaires...", 0)
    creature:RemoveEvents()
end

-- ------------------------------------------------------------
-- OnReset
-- ------------------------------------------------------------
local function Azshara_OnReset(event, creature)
    creature:SendUnitYell("Vous avez eu de la chance. Ne tentez plus le destin.", 0)
    creature:RemoveEvents()
end

-- ------------------------------------------------------------
-- Enregistrement Eluna
-- ------------------------------------------------------------
RegisterCreatureEvent(NPC_AZSHARA, 1, Azshara_OnEnterCombat)
RegisterCreatureEvent(NPC_AZSHARA, 2, Azshara_OnDied)
RegisterCreatureEvent(NPC_AZSHARA, 4, Azshara_OnReset)
