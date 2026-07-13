local AIO = AIO or require("AIO")

-- =============================================
--   SORTS PAR NIVEAU — NÉCROMANCIEN
--   Format : [niveau] = { spellID, spellID, ... }
-- =============================================
local NecromancerSpells = {
    -- Niveau 1 : sorts de départ donnés au login
    [1] = {
        686,    -- Shadow Bolt rang 1
        589,    -- Shadow Word: Pain rang 1
        1120,   -- Drain Soul rang 1
        689,    -- Drain Life rang 1
        980,    -- Curse of Agony rang 1
        5782,   -- Fear rang 1
        18220,  -- Dark Pact rang 1
        706,    -- Demon Armor rang 1
    },
    -- Niveau 4
    [4] = {
        695,    -- Shadow Bolt rang 2
        594,    -- Shadow Word: Pain rang 2
        699,    -- Drain Life rang 2
        702,    -- Curse of Weakness rang 1
    },
    -- Niveau 8
    [8] = {
        705,    -- Shadow Bolt rang 3
        970,    -- Shadow Word: Pain rang 3
        709,    -- Drain Life rang 3
        1014,   -- Curse of Agony rang 2
        8288,   -- Drain Soul rang 2
        6213,   -- Fear rang 2
    },
    -- Niveau 10
    [10] = {
        10556,  -- Summon Skeleton (NPC)
        46584,  -- Raise Dead (DK base)
        1108,   -- Curse of Weakness rang 2
        1098,   -- Demon Armor rang 2
    },
    -- Niveau 12
    [12] = {
        1088,   -- Shadow Bolt rang 4
        992,    -- Shadow Word: Pain rang 4
        7651,   -- Drain Life rang 4
        6217,   -- Curse of Agony rang 3
        6205,   -- Curse of Weakness rang 3
        8289,   -- Drain Soul rang 3
        5138,   -- Drain Mana rang 1
    },
    -- Niveau 14
    [14] = {
        6789,   -- Death Coil (Warlock) rang 1
        603,    -- Curse of Doom rang 1
        1714,   -- Curse of Tongues rang 1
    },
    -- Niveau 16
    [16] = {
        1106,   -- Shadow Bolt rang 5
        2767,   -- Shadow Word: Pain rang 5
        11699,  -- Drain Life rang 5
        11711,  -- Curse of Agony rang 4
        7646,   -- Curse of Weakness rang 4
        6213,   -- Fear rang 2
        6215,   -- Fear rang 3
    },
    -- Niveau 18
    [18] = {
        15407,  -- Mind Flay rang 1
        2944,   -- Devouring Plague rang 1
        18937,  -- Dark Pact rang 2
        --6226,   -- Drain Mana rang 2
    },
    -- Niveau 20
    [20] = {
        7641,   -- Shadow Bolt rang 6
        10892,  -- Shadow Word: Pain rang 6
        11700,  -- Drain Life rang 6
        11712,  -- Curse of Agony rang 5
        11707,  -- Curse of Weakness rang 5
        8289,   -- Drain Soul rang 3
        11675,  -- Drain Soul rang 4
        12782,  -- Summon Skeleton Warrior
        15286,  -- Vampiric Embrace
        11733,  -- Demon Armor rang 3
    },
    -- Niveau 24
    [24] = {
        11659,  -- Shadow Bolt rang 7
        10893,  -- Shadow Word: Pain rang 7
        --27221,  -- Drain Life rang 7
        11713,  -- Curse of Agony rang 6
        11708,  -- Curse of Weakness rang 6
        17311,  -- Mind Flay rang 2
        19276,  -- Devouring Plague rang 2
        5484,   -- Howl of Terror rang 1
        18938,  -- Dark Pact rang 3
    },
    -- Niveau 28
    [28] = {
        11660,  -- Shadow Bolt rang 8
        10894,  -- Shadow Word: Pain rang 8
        --11703,  -- Drain Mana rang 3
        17312,  -- Mind Flay rang 3
        19277,  -- Devouring Plague rang 3
        17925,  -- Death Coil rang 2
        14821,  -- Summon Skeleton Mage
    },
    -- Niveau 30
    [30] = {
        11661,  -- Shadow Bolt rang 9
        17313,  -- Mind Flay rang 4
        19278,  -- Devouring Plague rang 4
        30283,  -- Shadowfury rang 1
        --10911,  -- Dominate Mind
        605,    -- Mind Control
    },
    -- Niveau 36
    [36] = {
        25307,  -- Shadow Bolt rang 10
        25367,  -- Shadow Word: Pain rang 9
        --27221,  -- Drain Life rang 7
        27218,  -- Curse of Agony rang 7
        27224,  -- Curse of Weakness rang 7
        17314,  -- Mind Flay rang 5
        19279,  -- Devouring Plague rang 5
        --11704,  -- Drain Mana rang 4
        18807,  -- Mind Flay rang 6
        17926,  -- Death Coil rang 3
        16468,  -- Summon Skeleton Archer
        20555,  -- Animate Dead (NPC)
        30413,  -- Shadowfury rang 2
        27220,  -- Dark Pact rang 4
        11734,  -- Demon Armor rang 4
    },
    -- Niveau 40
    [40] = {
        32379,  -- Shadow Word: Death rang 1
        34914,  -- Vampiric Touch rang 1
        25387,  -- Mind Flay rang 7
        19280,  -- Devouring Plague rang 6
        25810,  -- Drain Mana rang 5
        17928,  -- Howl of Terror rang 2
        30414,  -- Shadowfury rang 3
        27260,  -- Demon Armor rang 5
        27223,  -- Death Coil rang 4
        19028,  -- Soul Link
        --30908,  -- Soul Leech
    },
    -- Niveau 50
    [50] = {
        47809,  -- Shadow Bolt rang 11
        47759,  -- Shadow Word: Pain rang 10
        47857,  -- Drain Life rang 8
        47863,  -- Curse of Agony rang 8
        30909,  -- Curse of Weakness rang 8
        34916,  -- Vampiric Touch rang 2
        26711,  -- Devouring Plague rang 7
        48155,  -- Mind Flay rang 8
        48156,  -- Mind Flay rang 9
        32996,  -- Shadow Word: Death rang 2
        48707,  -- Anti-Magic Shell
        49222,  -- Bone Shield
        49203,  -- Hungering Cold
        28084,  -- Corpse Explosion (TBC NPC)
    },
    -- Niveau 60
    [60] = {
        47810,  -- Shadow Bolt rang 12
        47760,  -- Shadow Word: Pain rang 11
        --47858,  -- Drain Life rang 9
        47867,  -- Curse of Agony rang 8
        50511,  -- Curse of Weakness rang 9
        47855,  -- Drain Soul rang 5
        --47868,  -- Dark Pact rang 5
        47893,  -- Demon Armor rang 6
        47859,  -- Death Coil rang 5
        49576,  -- Death Grip
        49039,  -- Lichborne
        49194,  -- Unholy Blight
        55233,  -- Vampiric Blood
        51052,  -- Anti-Magic Zone
        42650,  -- Army of the Dead
        49206,  -- Summon Gargoyle
        49895,  -- Death Coil (DK)
    },
    -- Niveau 70 : rangs intermédiaires WotLK
    [70] = {
        48157,  -- Shadow Word: Death rang 3
        48158,  -- Shadow Word: Death rang 4
        48159,  -- Vampiric Touch rang 3
        48160,  -- Vampiric Touch rang 4
        47846,  -- Shadowfury rang 4
        47847,  -- Shadowfury rang 5
        48299,  -- Devouring Plague rang 8
        52150,  -- Raise Dead (Ghoul)
        46598,  -- Summon Risen Warrior
        55090,  -- Scourge Strike rang 1
        45462,  -- Plague Strike rang 1
        55078,  -- Blood Plague (DK)
        55095,  -- Frost Fever (DK)
        50842,  -- Pestilence
        49936,  -- Death & Decay
    },
    -- Niveau 80 : rangs max + passifs
    [80] = {
        47810,  -- Shadow Bolt rang 12
        47760,  -- Shadow Word: Pain rang 11
        --47858,  -- Drain Life rang 9
        48159,  -- Vampiric Touch rang 3
        48299,  -- Devouring Plague rang 8
        48156,  -- Mind Flay rang 9
        48158,  -- Shadow Word: Death rang 4
        47847,  -- Shadowfury rang 5
        55265,  -- Scourge Strike rang 2
        49921,  -- Plague Strike rang 5
        51325,  -- Corpse Explosion (WotLK)
        48792,  -- Icebound Fortitude (passif)
        51271,  -- Unbreakable Armor (passif)
        47198,  -- Death's Embrace (passif)
        57330,  -- Horn of Winter rang 1
        57623,  -- Horn of Winter rang 2
        48265,  -- Unholy Presence
        48266,  -- Shadow Presence / Frost Presence
        48263,  -- Blood Presence
        3714,   -- Path of Frost
    },
}

-- =============================================
--   SKILLS PAR NIVEAU
--   Format : [niveau] = { { skillID, step, current, max }, ... }
-- =============================================
local NecromancerSkills = {
    -- Niveau 1 : Bâtons (136) accordé dès le départ
    [1] = {
        { 136, 1, 1, 300 },  -- Bâtons
    },
}

-- ID de classe du Nécromancien (classe custom 18)
local NECROMANCER_CLASS_ID = 18

-- =============================================
--   SERVEUR
-- =============================================
if AIO.AddAddon() then

    local function GiveSpellsForLevel(player, level)
        local spells = NecromancerSpells[level]
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
        local skills = NecromancerSkills[level]
        if skills then
            for _, skillData in ipairs(skills) do
                local skillID, step, current, max = skillData[1], skillData[2], skillData[3], skillData[4]
                player:SetSkill(skillID, step, current, max)
            end
        end
    end

    local function OnLogin(event, player)
        if player:GetClass() ~= NECROMANCER_CLASS_ID then return end

        -- Donner tous les sorts correspondant aux niveaux <= niveau actuel
        local currentLevel = player:GetLevel()
        for level, _ in pairs(NecromancerSpells) do
            if level <= currentLevel then
                GiveSpellsForLevel(player, level)
            end
        end

        -- Donner tous les skills correspondant aux niveaux <= niveau actuel
        for level, _ in pairs(NecromancerSkills) do
            if level <= currentLevel then
                GiveSkillsForLevel(player, level)
            end
        end
    end

    local function OnLevelChange(event, player, oldLevel)
        if player:GetClass() ~= NECROMANCER_CLASS_ID then return end

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
