local AIO = AIO or require("AIO")

-- =============================================
--   SORTS PAR NIVEAU — ÉVOCATEUR
--   Format : [niveau] = { spellID, spellID, ... }
-- =============================================
local EvocateurSpells = {
    -- Niveau 1 : sorts de départ donnés au login
    [1] = {
        8873,   -- Fire Breath rang 1 (NPC dragon)
        6509,   -- Frost Breath rang 1 (NPC)
        403,    -- Lightning Bolt rang 1
        5143,   -- Arcane Missiles rang 1
        1463,   -- Mana Shield rang 1
        122,    -- Frost Nova rang 1
    },
    -- Niveau 4
    [4] = {
        11197,  -- Fire Breath rang 2
        529,    -- Lightning Bolt rang 2
        5144,   -- Arcane Missiles rang 2
    },
    -- Niveau 8
    [8] = {
        120,    -- Cone of Cold rang 1
        548,    -- Lightning Bolt rang 3
        8364,   -- Frost Breath rang 2
        2120,   -- Flamestrike rang 1
    },
    -- Niveau 10
    [10] = {
        421,    -- Chain Lightning rang 1
        5145,   -- Arcane Missiles rang 3
        8494,   -- Mana Shield rang 2
        20712,  -- Fire Breath rang 3
    },
    -- Niveau 12
    [12] = {
        8492,   -- Cone of Cold rang 2
        915,    -- Lightning Bolt rang 4
        8416,   -- Arcane Missiles rang 4
        9672,   -- Frost Breath rang 3
        2121,   -- Flamestrike rang 2
    },
    -- Niveau 14
    [14] = {
        930,    -- Chain Lightning rang 2
        943,    -- Lightning Bolt rang 5
        8417,   -- Arcane Missiles rang 5
        8495,   -- Mana Shield rang 3
    },
    -- Niveau 16
    [16] = {
        10159,  -- Cone of Cold rang 3
        6041,   -- Lightning Bolt rang 6
        10211,  -- Arcane Missiles rang 6
        34997,  -- Fire Breath rang 4
        8422,   -- Flamestrike rang 3
    },
    -- Niveau 20
    [20] = {
        2860,   -- Chain Lightning rang 3
        10391,  -- Lightning Bolt rang 7
        10212,  -- Arcane Missiles rang 7
        10191,  -- Mana Shield rang 4
        865,    -- Frost Nova rang 2
        10159,  -- Cone of Cold rang 3
        29951,  -- Frost Breath rang 4
    },
    -- Niveau 24
    [24] = {
        10605,  -- Chain Lightning rang 4
        10392,  -- Lightning Bolt rang 8
        25345,  -- Arcane Missiles rang 8
        10160,  -- Cone of Cold rang 4
        44461,  -- Fire Breath rang 5
        8423,   -- Flamestrike rang 4
        30451,  -- Arcane Blast rang 1
    },
    -- Niveau 28
    [28] = {
        25442,  -- Chain Lightning rang 5
        15207,  -- Lightning Bolt rang 9
        38699,  -- Arcane Missiles rang 9
        10161,  -- Cone of Cold rang 5
        10192,  -- Mana Shield rang 5
        6131,   -- Frost Nova rang 3
        10215,  -- Flamestrike rang 5
        38094,  -- Arcane Blast rang 2
    },
    -- Niveau 30
    [30] = {
        1953,   -- Blink
        30065,  -- Frost Breath rang 5
        38095,  -- Arcane Blast rang 3
    },
    -- Niveau 36
    [36] = {
        49268,  -- Chain Lightning rang 6
        25448,  -- Lightning Bolt rang 10
        42846,  -- Arcane Missiles rang 10
        27087,  -- Cone of Cold rang 6
        27131,  -- Mana Shield rang 6
        10230,  -- Frost Nova rang 4
        10216,  -- Flamestrike rang 6
    },
    -- Niveau 40
    [40] = {
        55858,  -- Fire Breath rang 6
        55613,  -- Frost Breath rang 6
        42894,  -- Arcane Blast rang 4
        51490,  -- Thunderstorm rang 1
        31589,  -- Slow rang 1 (Arcane)
    },
    -- Niveau 50
    [50] = {
        49237,  -- Lightning Bolt rang 11
        42931,  -- Cone of Cold rang 7
        42843,  -- Mana Shield rang 7
        27088,  -- Frost Nova rang 5
        27087,  -- Cone of Cold rang 6
        27086,  -- Flamestrike rang 7
    },
    -- Niveau 60
    [60] = {
        33763,  -- Lifebloom rang 1
        48438,  -- Wild Growth rang 1
        --20781,  -- Breath of Life (NPC)
        5185,   -- Healing Touch rang 1
        5186,   -- Healing Touch rang 2
        774,    -- Rejuvenation rang 1
        1058,   -- Rejuvenation rang 2
    },
    -- Niveau 70 : rangs intermédiaires
    [70] = {
        43107,  -- Static Discharge
        56095,  -- Ball Lightning (NPC)
        42917,  -- Frost Nova rang 6
        42208,  -- Blizzard rang 8
        25033,  -- Lightning Breath (NPC dragon)
        49206,  -- Invocation / Summon Gargoyle (ambiance draconique)
    },
    -- Niveau 80 : rangs max + passifs
    [80] = {
        49237,  -- Lightning Bolt rang 11
        49268,  -- Chain Lightning rang 6
        42931,  -- Cone of Cold rang 7
        55858,  -- Fire Breath rang 6
        55613,  -- Frost Breath rang 6
        42894,  -- Arcane Blast rang 4
        42846,  -- Arcane Missiles rang 10
        42917,  -- Frost Nova rang 6
        42843,  -- Mana Shield rang 7
        42208,  -- Blizzard rang 8
        42925,  -- Flamestrike rang 8
        48450,  -- Lifebloom rang 2
        48440,  -- Rejuvenation rang 12
        48377,  -- Healing Touch rang 13
        48438,  -- Wild Growth rang 1
        51490,  -- Thunderstorm rang 1
        --49174,  -- Spellweave (passif)
    },
}

-- =============================================
--   SKILLS PAR NIVEAU
--   Format : [niveau] = { { skillID, step, current, max }, ... }
-- =============================================
local EvocateurSkills = {
    -- Niveau 1 : Bâtons (136) accordé dès le départ
    [1] = {
        { 136, 1, 1, 300 },  -- Bâtons
    },
}

-- ID de classe de l'Évocateur (classe custom 17)
local EVOCATEUR_CLASS_ID = 17

-- =============================================
--   SERVEUR
-- =============================================
if AIO.AddAddon() then

    local function GiveSpellsForLevel(player, level)
        local spells = EvocateurSpells[level]
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
        local skills = EvocateurSkills[level]
        if skills then
            for _, skillData in ipairs(skills) do
                local skillID, step, current, max = skillData[1], skillData[2], skillData[3], skillData[4]
                player:SetSkill(skillID, step, current, max)
            end
        end
    end

    local function OnLogin(event, player)
        if player:GetClass() ~= EVOCATEUR_CLASS_ID then return end

        -- Donner tous les sorts correspondant aux niveaux <= niveau actuel
        local currentLevel = player:GetLevel()
        for level, _ in pairs(EvocateurSpells) do
            if level <= currentLevel then
                GiveSpellsForLevel(player, level)
            end
        end

        -- Donner tous les skills correspondant aux niveaux <= niveau actuel
        for level, _ in pairs(EvocateurSkills) do
            if level <= currentLevel then
                GiveSkillsForLevel(player, level)
            end
        end
    end

    local function OnLevelChange(event, player, oldLevel)
        if player:GetClass() ~= EVOCATEUR_CLASS_ID then return end

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

-- Aucun code client nécessaire
