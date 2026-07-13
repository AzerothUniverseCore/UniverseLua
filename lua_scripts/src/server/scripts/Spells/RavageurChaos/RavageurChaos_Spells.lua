local AIO = AIO or require("AIO")

-- =============================================
--   SORTS PAR NIVEAU
--   Format : [niveau] = { spellID, spellID, ... }
-- =============================================
local RavageurSpells = {
    -- -----------------------------------------------
    --   NIVEAU 1 : sorts de départ
    -- -----------------------------------------------
    [1] = {
        -- Attaques shadow de base
        686,    -- Shadow Bolt rang 1 (Warlock)
        172,    -- Corruption rang 1 (Warlock - DoT Shadow)
        -- Drain de vie
        689,    -- Drain Life rang 1 (Warlock)
        -- Malédiction de base
        702,    -- Curse of Weakness rang 1 (Warlock)
        -- Présence du chaos
        48263,  -- Blood Presence rang 1 (DK - absorbe de la vie)
        -- Utilitaire
        587,    -- Conjure Food
        5504,   -- Conjure Water
    },
    -- Niveau 4
    [4] = {
        348,    -- Immolate rang 1 (Warlock - DoT Feu Fel)
        5782,   -- Fear rang 1 (Warlock - peur)
    },
    -- Niveau 6
    [6] = {
        1490,   -- Curse of the Elements rang 1 (Warlock - -résistances)
        1094,   -- Shadow Bolt rang 2
    },
    -- Niveau 8
    [8] = {
        17877,  -- Shadowburn rang 1 (Warlock - execute shadow)
        2120,   -- Flamestrike rang 1 (dégâts Feu AoE, recyclé chaos)
        6217,   -- Corruption rang 2
    },
    -- Niveau 10
    [10] = {
        1454,   -- Life Tap rang 1 (Warlock - mana contre HP)
        1949,   -- Hellfire rang 1 (Warlock - AoE feu intérieur)
        --9180,   -- Immolate rang 2
        1120,   -- Shadow Bolt rang 3
        27220,  -- Drain Mana rang 1 (Warlock)
    },
    -- Niveau 12
    [12] = {
        --2970,   -- Corruption rang 3
        3110,   -- Drain Life rang 2
        6213,   -- Curse of the Elements rang 2
    },
    -- Niveau 14
    [14] = {
        5740,   -- Rain of Fire rang 1 (Warlock - AoE feu)
        11659,  -- Immolate rang 3
        7648,   -- Curse of Weakness rang 2
    },
    -- Niveau 16
    [16] = {
        7645,   -- Corruption rang 4
        5676,   -- Shadow Bolt rang 4
        11700,  -- Drain Life rang 3
    },
    -- Niveau 18
    [18] = {
        9034,   -- Hellfire rang 2
        19716,  -- Drain Mana rang 2
        11660,  -- Immolate rang 4
    },
    -- Niveau 20
    [20] = {
        7646,   -- Corruption rang 5
        --7647,   -- Shadow Bolt rang 5
        17925,  -- Fear rang 2
        11695,  -- Rain of Fire rang 2
        6219,   -- Curse of the Elements rang 3
    },
    -- Niveau 22
    [22] = {
        --11701,  -- Drain Life rang 4
        11661,  -- Immolate rang 5
        11659,  -- Life Tap rang 2
    },
    -- Niveau 24
    [24] = {
        11711,  -- Corruption rang 6
        11660,  -- Shadow Bolt rang 6
        11675,  -- Hellfire rang 3
        11700,  -- Shadowburn rang 2
    },
    -- Niveau 26
    [26] = {
        --11702,  -- Drain Life rang 5
        11963,  -- Immolate rang 6
        --11717,  -- Rain of Fire rang 3
    },
    -- Niveau 28
    [28] = {
        11712,  -- Corruption rang 7
        11661,  -- Shadow Bolt rang 7
        11661,  -- Curse of the Elements rang 4
        27223,  -- Drain Mana rang 3
    },
    -- Niveau 30
    [30] = {
        27213,  -- Shadowburn rang 3
        --11703,  -- Drain Life rang 6
        27215,  -- Immolate rang 7
        11695,  -- Life Tap rang 3
        -- Mobilité du chaos
        49576,  -- Death Grip (DK - attraction télékinésie)
    },
    -- Niveau 32
    [32] = {
        27209,  -- Corruption rang 8
        25307,  -- Shadow Bolt rang 8
        --11720,  -- Rain of Fire rang 4
    },
    -- Niveau 34
    [34] = {
        27212,  -- Drain Life rang 7
        27216,  -- Immolate rang 8
        11722,  -- Hellfire rang 4
    },
    -- Niveau 36
    [36] = {
        27214,  -- Shadowburn rang 4
        11722,  -- Corruption rang 9
        27209,  -- Curse of the Elements rang 5
        27220,  -- Drain Mana rang 4
    },
    -- Niveau 38
    [38] = {
        27213,  -- Drain Life rang 8
        27217,  -- Immolate rang 9
        27210,  -- Rain of Fire rang 5
    },
    -- Niveau 40
    [40] = {
        30283,  -- Shadowfury (Warlock - stun shadow AoE, WotLK)
        47897,  -- Shadowflame rang 1 (Warlock WotLK - cône shadow+feu)
        27209,  -- Corruption rang 10
        17962,  -- Conflagrate rang 1 (Warlock - explose Immolate)
        20790,  -- Amplify Curse (Warlock - améliore malédiction suivante)
        -- Drain soul pour les âmes
        1120,   -- Drain Soul rang 1
    },
    -- Niveau 42
    [42] = {
        27211,  -- Shadow Bolt rang 9
        47835,  -- Immolate rang 10
        -- Bouclier anti-magie
        48707,  -- Anti-Magic Shell (DK - absorbe sorts magiques)
    },
    -- Niveau 44
    [44] = {
        27218,  -- Drain Life rang 9
        27211,  -- Life Tap rang 4
        47813,  -- Rain of Fire rang 6
    },
    -- Niveau 46
    [46] = {
        --11723,  -- Hellfire rang 5
        27214,  -- Shadowburn rang 5
        47812,  -- Corruption rang 11
    },
    -- Niveau 48
    [48] = {
        47835,  -- Immolate rang 11
        27219,  -- Drain Life rang 10
        47814,  -- Drain Mana rang 5
    },
    -- Niveau 50
    [50] = {
        47809,  -- Shadow Bolt rang 10
        47833,  -- Rain of Fire rang 7
        47834,  -- Life Tap rang 5
        -- Contrôle du chaos
        5484,   -- Howl of Terror (Warlock - AoE fear)
        6358,   -- Seduction passive (séduction chaos)
    },
    -- Niveau 54
    [54] = {
        47820,  -- Corruption rang 12
        47836,  -- Immolate rang 12
        30108,  -- Unstable Affliction rang 1 (Warlock WotLK - DoT+silence)
    },
    -- Niveau 58
    [58] = {
        47810,  -- Shadow Bolt rang 11
        47837,  -- Drain Life rang 11
        47815,  -- Hellfire rang 6
    },
    -- Niveau 60
    [60] = {
        50796,  -- Chaos Bolt rang 1 (Warlock WotLK - sort chaos pénétrant)
        27243,  -- Seed of Corruption rang 1 (Warlock - bombe shadow)
        47816,  -- Rain of Fire rang 8
        -- Mort et chaos
        47541,  -- Death Coil (DK - projectile mort, heal ou dégâts)
        47476,  -- Strangulate (DK - silence distance)
    },
    -- Niveau 64
    [64] = {
        47821,  -- Corruption rang 13
        47838,  -- Immolate rang 13
        59172,  -- Chaos Bolt rang 2
    },
    -- Niveau 68
    [68] = {
        47811,  -- Shadow Bolt rang 12
        47818,  -- Conflagrate rang 2
        47893,  -- Unstable Affliction rang 2
        47897,  -- Shadowflame rang 2
    },
    -- Niveau 70
    [70] = {
        47822,  -- Corruption rang 14
        47839,  -- Immolate rang 14
        47835,  -- Drain Life rang 12
        59173,  -- Chaos Bolt rang 3
    },
    -- Niveau 75
    [75] = {
        47808,  -- Shadow Bolt rang 13
        47819,  -- Conflagrate rang 3
        --47894,  -- Unstable Affliction rang 3
        47898,  -- Shadowflame rang 3
    },
    -- Niveau 80 : rangs max + actifs WotLK
    [80] = {
        47809,  -- Shadow Bolt rang max
        47823,  -- Corruption rang max (14)
        47840,  -- Immolate rang max
        47836,  -- Drain Life rang max
        --59174,  -- Chaos Bolt rang max (4)
        47820,  -- Conflagrate rang max
        --47895,  -- Unstable Affliction rang max
        47899,  -- Shadowflame rang max
        47817,  -- Rain of Fire rang max
        47816,  -- Hellfire rang max
        27243,  -- Seed of Corruption max
        17962,  -- Conflagrate (rang unique, max WotLK)
        -- Passifs / cooldowns chaos finaux
        50977,  -- Chaos Bolt passif (Backdraft proc)
        48020,  -- Death Coil max (DK Unholy - dégâts/soin)
        57330,  -- Horn of Winter (DK - buff AP/Force groupe)
        47541,  -- Unholy Blight (DK - nuage de maladie AoE)
        48707,  -- Anti-Magic Shell max
        49576,  -- Death Grip (unique rang)
        6353,   -- Soul Fire rang 1 (Warlock - nuke feu de l'âme)
        47825,  -- Soul Fire rang max
    },
}

-- =============================================
--   SKILLS PAR NIVEAU
--   Format : [niveau] = { { skillID, step, current, max }, ... }
-- =============================================
local RavageurSkills = {
    -- Niveau 1 : armes légères (dagues, bâtons)
    [1] = {
        { 173, 1, 1, 300 },  -- Dagues
        { 136, 1, 1, 300 },  -- Bâtons
		{ 413, 1, 1, 300 },  -- Maille
		{ 414, 1, 1, 300 },  -- Cuir
		{ 43, 1, 1, 300 },  -- Epee
		{ 55, 1, 1, 300 },  -- Epee 2M
    },
    -- Niveau 40
    [40] = {
        { 173, 1, 200, 300 },
        { 136, 1, 200, 300 },
    },
    -- Niveau 80 : max
    [80] = {
        { 173, 1, 400, 400 },
        { 136, 1, 400, 400 },
    },
}

-- ID de classe du Ravageur du Chaos (classe custom 23)
local RAVAGEUR_CLASS_ID = 23

-- =============================================
--   SERVEUR
-- =============================================
if AIO.AddAddon() then

    local function GiveSpellsForLevel(player, level)
        local spells = RavageurSpells[level]
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
    --   skillID : identifiant du skill
    --   step    : rang de la compétence (toujours 1)
    --   current : valeur actuelle accordée au joueur
    --   max     : valeur maximale de la compétence
    local function GiveSkillsForLevel(player, level)
        local skills = RavageurSkills[level]
        if skills then
            for _, skillData in ipairs(skills) do
                local skillID, step, current, max = skillData[1], skillData[2], skillData[3], skillData[4]
                player:SetSkill(skillID, step, current, max)
            end
        end
    end

    local function OnLogin(event, player)
        if player:GetClass() ~= RAVAGEUR_CLASS_ID then return end

        local currentLevel = player:GetLevel()
        for level, _ in pairs(RavageurSpells) do
            if level <= currentLevel then
                GiveSpellsForLevel(player, level)
            end
        end

        for level, _ in pairs(RavageurSkills) do
            if level <= currentLevel then
                GiveSkillsForLevel(player, level)
            end
        end
    end

    local function OnLevelChange(event, player, oldLevel)
        if player:GetClass() ~= RAVAGEUR_CLASS_ID then return end

        local newLevel = player:GetLevel()
        GiveSpellsForLevel(player, newLevel)
        GiveSkillsForLevel(player, newLevel)
    end

    RegisterPlayerEvent(3,  OnLogin)
    RegisterPlayerEvent(13, OnLevelChange)
    return
end

-- Aucun code client nécessaire (pas de barre custom)
