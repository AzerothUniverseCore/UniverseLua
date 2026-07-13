local AIO = AIO or require("AIO")

-- =============================================
--   SORTS PAR NIVEAU
--   Format : [niveau] = { spellID, spellID, ... }
-- =============================================
local PyromancerSpells = {
    -- Niveau 1 : sorts de départ donnés au login
    [1] = {
        133,    -- Fireball rang 1
        2136,   -- Fire Blast rang 1
        587,    -- Conjure Food
        5504,   -- Conjure Water
    },
    -- Niveau 4
    [4] = {
        2948,   -- Scorch rang 1
    },
    -- Niveau 8
    [8] = {
        2120,   -- Flamestrike rang 1
    },
    -- Niveau 10
    [10] = {
        122,    -- Frost Nova
    },
    -- Niveau 12
    [12] = {
        11129,  -- Combustion
    },
    -- Niveau 14
    [14] = {
        11113,  -- Blast Wave rang 1
    },
    -- Niveau 18
    [18] = {
        11366,  -- Pyroblast rang 1
    },
    -- Niveau 20
    [20] = {
        44457,  -- Living Bomb rang 1
    },
    -- Niveau 24
    [24] = {
        31661,  -- Dragon's Breath rang 1
    },
    -- Niveau 30
    [30] = {
        30482,  -- Molten Armor
    },
    -- Niveau 36
    [36] = {
        543,    -- Fire Ward rang 1
    },
    -- Niveau 40
    [40] = {
        55342,  -- Mirror Image
    },
    -- Niveau 50
    [50] = {
        1953,   -- Blink
    },
    -- Niveau 60
    [60] = {
        1459,   -- Arcane Intellect
    },
    -- Niveau 70 : rangs intermédiaires
    [70] = {
        42859,  -- Scorch rang 9
        42873,  -- Fire Blast rang 9
    },
    -- Niveau 80 : rangs max + passifs
    [80] = {
        38692,  -- Fireball rang 13
        42890,  -- Pyroblast rang 14
        42926,  -- Flamestrike rang 8
        55360,  -- Living Bomb rang 3
        42950,  -- Dragon's Breath rang 5
        42945,  -- Blast Wave rang 7
        12654,  -- Ignite (passif)
        44448,  -- Hot Streak (passif)
        11083,  -- Burning Soul (passif)
        11100,  -- Pyromaniac (passif)
        31641,  -- Playing with Fire (passif)
        11124,  -- Fire Power (passif)
    },
}

-- =============================================
--   SKILLS PAR NIVEAU
--   Format : [niveau] = { { skillID, step, current, max }, ... }
--   step    = rang du skill (1 en général)
--   current = valeur actuelle accordée
--   max     = valeur maximale accordée
-- =============================================
local PyromancerSkills = {
    -- Niveau 1 : Bâtons (136) accordé dès le départ
    [1] = {
        { 136, 1, 1, 300 },  -- Bâtons (mises à jour au niveau max souhaité)
    },
}

-- ID de classe du Pyromancien (classe custom 20)
local PYROMANCER_CLASS_ID = 20

-- =============================================
--   SERVEUR
-- =============================================
if AIO.AddAddon() then

    local function GiveSpellsForLevel(player, level)
        local spells = PyromancerSpells[level]
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
        local skills = PyromancerSkills[level]
        if skills then
            for _, skillData in ipairs(skills) do
                local skillID, step, current, max = skillData[1], skillData[2], skillData[3], skillData[4]
                player:SetSkill(skillID, step, current, max)
            end
        end
    end

    local function OnLogin(event, player)
        if player:GetClass() ~= PYROMANCER_CLASS_ID then return end

        -- Donner tous les sorts correspondant aux niveaux <= niveau actuel
        local currentLevel = player:GetLevel()
        for level, _ in pairs(PyromancerSpells) do
            if level <= currentLevel then
                GiveSpellsForLevel(player, level)
            end
        end

        -- Donner tous les skills correspondant aux niveaux <= niveau actuel
        for level, _ in pairs(PyromancerSkills) do
            if level <= currentLevel then
                GiveSkillsForLevel(player, level)
            end
        end
    end

    local function OnLevelChange(event, player, oldLevel)
        if player:GetClass() ~= PYROMANCER_CLASS_ID then return end

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
