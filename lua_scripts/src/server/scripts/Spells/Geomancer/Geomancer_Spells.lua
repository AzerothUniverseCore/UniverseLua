local AIO = AIO or require("AIO")

-- =============================================
--   SORTS PAR NIVEAU — GÉOMANCIEN
--   Format : [niveau] = { spellID, spellID, ... }
-- =============================================
local GeomancerSpells = {
    -- Niveau 1 : sorts de départ donnés au login
    [1] = {
        8042,   -- Earth Shock rang 1
        8017,   -- Rockbiter Weapon rang 1
        5730,   -- Stoneclaw Totem rang 1
        8075,   -- Strength of Earth Totem rang 1
        3600,   -- Earthbind Totem
        8072,   -- Stoneskin Totem
        6524,   -- Ground Tremor
    },
    -- Niveau 4
    [4] = {
        8044,   -- Earth Shock rang 2
        8018,   -- Rockbiter Weapon rang 2
    },
    -- Niveau 8
    [8] = {
        8045,   -- Earth Shock rang 3
        6390,   -- Stoneclaw Totem rang 2
        8160,   -- Strength of Earth Totem rang 2
    },
    -- Niveau 10
    [10] = {
        8046,   -- Earth Shock rang 4
        8019,   -- Rockbiter Weapon rang 3
        6391,   -- Stoneclaw Totem rang 3
        8161,   -- Strength of Earth Totem rang 3
    },
    -- Niveau 12
    [12] = {
        5176,   -- Wrath rang 1
        467,    -- Thorns rang 1
    },
    -- Niveau 14
    [14] = {
        10412,  -- Earth Shock rang 5
        10399,  -- Rockbiter Weapon rang 4
        6392,   -- Stoneclaw Totem rang 4
    },
    -- Niveau 16
    [16] = {
        5177,   -- Wrath rang 2
        782,    -- Thorns rang 2
        339,    -- Entangling Roots rang 1
    },
    -- Niveau 18
    [18] = {
        10413,  -- Earth Shock rang 6
        10427,  -- Stoneclaw Totem rang 5
        10442,  -- Strength of Earth Totem rang 4
    },
    -- Niveau 20
    [20] = {
        5178,   -- Wrath rang 3
        1075,   -- Thorns rang 3
        1062,   -- Entangling Roots rang 2
        16106,  -- Rockbiter Weapon rang 5
    },
    -- Niveau 24
    [24] = {
        6780,   -- Wrath rang 4
        8914,   -- Thorns rang 4
        5195,   -- Entangling Roots rang 3
        10428,  -- Stoneclaw Totem rang 6
    },
    -- Niveau 28
    [28] = {
        8905,   -- Wrath rang 5
        9756,   -- Thorns rang 5
        5196,   -- Entangling Roots rang 4
        10414,  -- Earth Shock rang 7
    },
    -- Niveau 30
    [30] = {
        61882,  -- Earthquake (WotLK)
        20594,  -- Stone Form
    },
    -- Niveau 34
    [34] = {
        9912,   -- Wrath rang 6
        9910,   -- Thorns rang 6
        9852,   -- Entangling Roots rang 5
        25454,  -- Earth Shock rang 8
        16107,  -- Rockbiter Weapon rang 6
    },
    -- Niveau 40
    [40] = {
        26984,  -- Wrath rang 7
        26992,  -- Thorns rang 7
        9853,   -- Entangling Roots rang 6
        25525,  -- Rockbiter Weapon rang 7
        25361,  -- Strength of Earth Totem rang 5
        25552,  -- Magma Totem rang 5
        59566,  -- Earthen Power (passif)
    },
    -- Niveau 50
    [50] = {
        26985,  -- Wrath rang 8
        26989,  -- Entangling Roots rang 7
        39187,  -- Rock Spike
        43208,  -- Rock Shield
        52616,  -- Earthen Shield
    },
    -- Niveau 60
    [60] = {
        8190,   -- Magma Totem rang 1
        10585,  -- Magma Totem rang 2
        10586,  -- Magma Totem rang 3
        10587,  -- Magma Totem rang 4
        62107,  -- Rock Spike (WotLK)
        59307,  -- Hardened Skin
    },
    -- Niveau 70 : rangs intermédiaires
    [70] = {
        48460,  -- Wrath rang 9
        53308,  -- Entangling Roots rang 8
        26992,  -- Thorns rang 7
        49230,  -- Earth Shock rang 9
        --25479,  -- Rockbiter Weapon rang 7
        57621,  -- Strength of Earth Totem rang 6
    },
    -- Niveau 80 : rangs max + passifs
    [80] = {
        49230,  -- Earth Shock rang 9
        58582,  -- Stoneclaw Totem rang 8
        57621,  -- Strength of Earth Totem rang 6
        58734,  -- Magma Totem rang 6
        53307,  -- Thorns rang 8
        59566,  -- Earthen Power (passif)
        59307,  -- Hardened Skin (passif)
        52616,  -- Earthen Shield (passif)
        --11253,  -- Endurance (aura passif)
    },
}

-- =============================================
--   SKILLS PAR NIVEAU
--   Format : [niveau] = { { skillID, step, current, max }, ... }
-- =============================================
local GeomancerSkills = {
    -- Niveau 1 : Masses (54) et Bâtons (136) accordés dès le départ
    [1] = {
        { 136, 1, 1, 300 },  -- Bâtons
        { 54,  1, 1, 300 },  -- Masses (1 main)
    },
}

-- ID de classe du Géomancien (classe custom 22)
local GEOMANCER_CLASS_ID = 22

-- =============================================
--   SERVEUR
-- =============================================
if AIO.AddAddon() then

    local function GiveSpellsForLevel(player, level)
        local spells = GeomancerSpells[level]
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
        local skills = GeomancerSkills[level]
        if skills then
            for _, skillData in ipairs(skills) do
                local skillID, step, current, max = skillData[1], skillData[2], skillData[3], skillData[4]
                player:SetSkill(skillID, step, current, max)
            end
        end
    end

    local function OnLogin(event, player)
        if player:GetClass() ~= GEOMANCER_CLASS_ID then return end

        -- Donner tous les sorts correspondant aux niveaux <= niveau actuel
        local currentLevel = player:GetLevel()
        for level, _ in pairs(GeomancerSpells) do
            if level <= currentLevel then
                GiveSpellsForLevel(player, level)
            end
        end

        -- Donner tous les skills correspondant aux niveaux <= niveau actuel
        for level, _ in pairs(GeomancerSkills) do
            if level <= currentLevel then
                GiveSkillsForLevel(player, level)
            end
        end
    end

    local function OnLevelChange(event, player, oldLevel)
        if player:GetClass() ~= GEOMANCER_CLASS_ID then return end

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
