local AIO = AIO or require("AIO")

-- =============================================
--   SORTS PAR NIVEAU
--   Format : [niveau] = { spellID, spellID, ... }
-- =============================================
local ChromancerSpells = {
    -- Niveau 1 : sorts de départ donnés au login
    [1] = {
        118,    -- Polymorph (contrôle temporel de base)
        2139,   -- Counterspell (interruption / distorsion)
        1953,   -- Blink (téléportation / phase)
        66,     -- Invisibility (phase / disparition)
    },
    -- Niveau 4
    [4] = {
        31589,  -- Slow (ralentissement du temps)
    },
    -- Niveau 8
    [8] = {
        122,    -- Frost Nova (root temporel)
    },
    -- Niveau 10
    [10] = {
        45524,  -- Chains of Ice (entrave temporelle)
    },
    -- Niveau 12
    [12] = {
        11426,  -- Ice Barrier (bouclier temporel)
    },
    -- Niveau 14
    [14] = {
        11113,  -- Blast Wave (stun / distorsion temporelle)
    },
    -- Niveau 18
    [18] = {
        12051,  -- Evocation (rembobinage / récupération temporelle)
    },
    -- Niveau 20
    [20] = {
        2825,   -- Bloodlust (accélération du temps)
    },
    -- Niveau 24
    [24] = {
        32182,  -- Heroism (manipulation du temps - haste buff)
    },
    -- Niveau 30
    [30] = {
        45438,  -- Ice Block (invulnérabilité / gel du temps)
    },
    -- Niveau 36
    [36] = {
        55342,  -- Mirror Image (dédoublement temporel)
    },
    -- Niveau 40
    [40] = {
        28271,  -- Polymorph: Turtle (distorsion temporelle avancée)
        28272,  -- Polymorph: Pig
    },
    -- Niveau 44
    [44] = {
        61025,  -- Polymorph: Serpent
        61305,  -- Polymorph: Black Cat
    },
    -- Niveau 48
    [48] = {
        61721,  -- Polymorph: Rabbit
        61780,  -- Polymorph: Turkey
    },
    -- Niveau 50
    [50] = {
        18469,  -- Counterspell - Silenced (silence temporel)
        33786,  -- Cyclone (distorsion / emprisonnement temporel)
    },
    -- Niveau 55
    [55] = {
        44614,  -- Frostfire Bolt (DoT temporel - gel + brûlure)
        48463,  -- Living Bomb (écho temporel explosif)
    },
    -- Niveau 60
    [60] = {
        31821,  -- Aura Mastery (maîtrise des flux temporels)
        28730,  -- Arcane Torrent (drain temporel)
    },
    -- Niveau 65
    [65] = {
        55078,  -- Blood Plague (vieillissement - DoT temporel)
        55095,  -- Frost Fever (gel du temps - DoT)
    },
    -- Niveau 70 : sorts intermédiaires avancés
    [70] = {
        66690,  -- Temporal Rift (faille temporelle - Ulduar)
        42914,  -- Siphon Soul (drain d'essence temporelle)
        47468,  -- Wrath (écho de nature temporelle)
    },
    -- Niveau 80 : sorts max + passifs
    [80] = {
        32612,  -- Invisibility (TBC - phase avancée)
        33697,  -- Warp (Draenei racial - téléportation temporelle)
        12654,  -- Ignite (résidu temporel - passif DoT)
        3355,   -- Freezing Trap Effect (piège temporel)
    },
}

-- =============================================
--   SKILLS PAR NIVEAU
--   Format : [niveau] = { { skillID, step, current, max }, ... }
--   step    = rang du skill (1 en général)
--   current = valeur actuelle accordée
--   max     = valeur maximale accordée
-- =============================================
local ChromancerSkills = {
    -- Niveau 1 : Bâtons (136) accordé dès le départ
    [1] = {
        { 136, 1, 1, 300 },  -- Bâtons
    },
}

-- ID de classe du Chronomancien (classe custom 21)
local CHRONOMANCER_CLASS_ID = 21

-- =============================================
--   SERVEUR
-- =============================================
if AIO.AddAddon() then

    local function GiveSpellsForLevel(player, level)
        local spells = ChromancerSpells[level]
        if spells then
            for _, spellID in ipairs(spells) do
                if not player:HasSpell(spellID) then
                    player:LearnSpell(spellID)
                end
            end
        end
    end

    -- Accorde les skills définis pour un niveau donné
    -- SetSkill(skillID, step, current, max)
    --   skillID : identifiant du skill (ex. 136 = Bâtons)
    --   step    : rang de la compétence (toujours 1 pour les armes)
    --   current : valeur actuelle accordée au joueur
    --   max     : valeur maximale de la compétence
    local function GiveSkillsForLevel(player, level)
        local skills = ChromancerSkills[level]
        if skills then
            for _, skillData in ipairs(skills) do
                local skillID, step, current, max = skillData[1], skillData[2], skillData[3], skillData[4]
                player:SetSkill(skillID, step, current, max)
            end
        end
    end

    local function OnLogin(event, player)
        if player:GetClass() ~= CHRONOMANCER_CLASS_ID then return end

        -- Donner tous les sorts correspondant aux niveaux <= niveau actuel
        local currentLevel = player:GetLevel()
        for level, _ in pairs(ChromancerSpells) do
            if level <= currentLevel then
                GiveSpellsForLevel(player, level)
            end
        end

        -- Donner tous les skills correspondant aux niveaux <= niveau actuel
        for level, _ in pairs(ChromancerSkills) do
            if level <= currentLevel then
                GiveSkillsForLevel(player, level)
            end
        end
    end

    local function OnLevelChange(event, player, oldLevel)
        if player:GetClass() ~= CHRONOMANCER_CLASS_ID then return end

        -- Donner les sorts du nouveau niveau
        local newLevel = player:GetLevel()
        GiveSpellsForLevel(player, newLevel)

        -- Donner les skills du nouveau niveau
        GiveSkillsForLevel(player, newLevel)
    end

    RegisterPlayerEvent(3,  OnLogin)
    RegisterPlayerEvent(13, OnLevelChange)
    return
end

-- Aucun code client nécessaire (pas de barre custom)
