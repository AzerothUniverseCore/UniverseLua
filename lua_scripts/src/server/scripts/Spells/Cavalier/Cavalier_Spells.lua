local AIO = AIO or require("AIO")

-- =============================================
--   SORTS PAR NIVEAU
--   Format : [niveau] = { spellID, spellID, ... }
-- =============================================
local CavalierSpells = {
    -- -----------------------------------------------
    --   NIVEAU 1 : sorts de départ donnés au login
    -- -----------------------------------------------
    [1] = {
        -- Combat mêlée de base
        78,     -- Heroic Strike rang 1 (Warrior)
        2457,   -- Battle Stance (Warrior)
        6673,   -- Battle Shout rang 1 (Warrior)
        -- Défense / survie
        7328,   -- Redemption rang 1 (Paladin - résurrection)
        -- Utilitaire
        587,    -- Conjure Food
        5504,   -- Conjure Water
    },
    -- Niveau 4
    [4] = {
        1715,   -- Hamstring rang 1 (Warrior - ralentissement)
        20271,  -- Judgement (Paladin - jugement générique, WotLK)
    },
    -- Niveau 6
    [6] = {
        772,    -- Rend rang 1 (Warrior - DoT saignement)
        20154,  -- Seal of Righteousness rang 1 (Paladin)
    },
    -- Niveau 8
    [8] = {
        100,    -- Charge rang 1 (Warrior - chargé hors combat)
        2048,   -- Heroic Strike rang 2 (Warrior)
        20164,  -- Seal of Righteousness rang 2
    },
    -- Niveau 10
    [10] = {
        355,    -- Taunt (Warrior)
        6343,   -- Thunder Clap rang 1 (Warrior)
        25780,  -- Blessing of Kings (Paladin - buff +stats)
        20174,  -- Seal of Righteousness rang 3
    },
    -- Niveau 12
    [12] = {
        7386,   -- Sunder Armor rang 1 (Warrior)
        20928,  -- Holy Light rang 1 (Paladin - heal)
        20184,  -- Seal of Righteousness rang 4
    },
    -- Niveau 14
    [14] = {
        5246,   -- Intimidating Shout (Warrior - AoE fear)
        19740,  -- Blessing of Might rang 1 (Paladin - AP buff)
        5588,   -- Hamstring rang 2 (Warrior)
    },
    -- Niveau 16
    [16] = {
        11564,  -- Heroic Strike rang 3
        20194,  -- Seal of Righteousness rang 5
        20929,  -- Holy Light rang 2
    },
    -- Niveau 18
    [18] = {
        6572,   -- Revenge rang 1 (Warrior - Defensive Stance)
        7369,   -- Sunder Armor rang 2
        --20200,  -- Seal of Righteousness rang 6
    },
    -- Niveau 20 : MONTURE rang 1 + auras
    [20] = {
        13819,  -- Summon Warhorse (Paladin - monture terrestre 60%)
        34769,  -- Summon Thalassian Warhorse (Blood Elf version)
        7381,   -- Defensive Stance (Warrior)
        71,     -- Devotion Aura rang 1 (Paladin - armure groupe)
        --20218,  -- Seal of Righteousness rang 7
        19742,  -- Blessing of Might rang 2
        20930,  -- Holy Light rang 3
        2687,   -- Bloodrage (Warrior - rage hors combat)
    },
    -- Niveau 22
    [22] = {
        11565,  -- Heroic Strike rang 4
        --20204,  -- Seal of Righteousness rang 8
        --7370,   -- Sunder Armor rang 3
    },
    -- Niveau 24
    [24] = {
        6574,   -- Revenge rang 2
        --2835,   -- Thunder Clap rang 2
        --20931,  -- Holy Light rang 4
        20210,  -- Seal of Righteousness rang 9 (max Vanilla)
    },
    -- Niveau 26
    [26] = {
        11566,  -- Heroic Strike rang 5
        --19743,  -- Blessing of Might rang 3
        2062,   -- Devotion Aura rang 2
    },
    -- Niveau 28
    [28] = {
        1161,   -- Challenging Shout (Warrior - AoE taunt)
        --7371,   -- Sunder Armor rang 4
        25292,  -- Holy Light rang 5
    },
    -- Niveau 30
    [30] = {
        5308,   -- Execute rang 1 (Warrior - finisher <20% HP)
        20216,  -- Retribution Aura rang 1 (Paladin - riposte holy)
        --19744,  -- Blessing of Might rang 4
        --20293,  -- Hammer of Justice rang 1 (Paladin - stun)
    },
    -- Niveau 32
    [32] = {
        11567,  -- Heroic Strike rang 6
        11580,  -- Rend rang 3
        --2835,   -- Thunder Clap rang 3
        7372,   -- Sunder Armor rang 5
    },
    -- Niveau 34
    [34] = {
        --6575,   -- Revenge rang 3
        --20932,  -- Holy Light rang 6
        --19745,  -- Blessing of Might rang 5
    },
    -- Niveau 36
    [36] = {
        20925,  -- Holy Light rang 7
        20166,  -- Seal of Command rang 1 (Paladin - dégâts saints)
        7373,   -- Sunder Armor rang 6
        --2835,   -- Thunder Clap rang 4
    },
    -- Niveau 38
    [38] = {
        11568,  -- Heroic Strike rang 7
        20217,  -- Retribution Aura rang 2
        19746,  -- Blessing of Might rang 6
    },
    -- Niveau 40
    [40] = {
        11578,  -- Execute rang 2
        20294,  -- Hammer of Justice rang 2
        2062,   -- Devotion Aura rang 3
        --20305,  -- Divine Protection rang 1 (Paladin - bulle 50%)
        --20934,  -- Holy Light rang 8
        7386,   -- Sunder Armor rang 7
    },
    -- Niveau 42
    [42] = {
        --11569,  -- Heroic Strike rang 8
        --19747,  -- Blessing of Might rang 7
        20170,  -- Seal of Command rang 2
    },
    -- Niveau 44
    [44] = {
        6576,   -- Revenge rang 4
        --2835,   -- Thunder Clap rang 5
        --20935,  -- Holy Light rang 9
    },
    -- Niveau 46
    [46] = {
        11574,  -- Rend rang 4
        --20218,  -- Retribution Aura rang 3
        --19748,  -- Blessing of Might rang 8
    },
    -- Niveau 48
    [48] = {
        --11570,  -- Heroic Strike rang 9
        20295,  -- Hammer of Justice rang 3
        20936,  -- Holy Light rang 10
    },
    -- Niveau 50
    [50] = {
        --11579,  -- Execute rang 3
        7381,   -- Defensive Stance
        8380,   -- Intercept rang 1 (Warrior - charge en combat)
        2062,   -- Devotion Aura rang 4
        19749,  -- Blessing of Might rang 9
        20166,  -- Seal of Command rang 3
    },
    -- Niveau 54
    [54] = {
        --11575,  -- Rend rang 5
        20219,  -- Retribution Aura rang 4
        20937,  -- Holy Light rang 11
    },
    -- Niveau 58
    [58] = {
        --11571,  -- Heroic Strike rang 10
        20296,  -- Hammer of Justice rang 4
        --20750,  -- Blessing of Might rang 10
    },
    -- Niveau 60 : MONTURE épique + Crusader Aura
    [60] = {
        34767,  -- Summon Charger (Paladin - monture épique terrestre 100%)
        35018,  -- Summon Thalassian Charger (Blood Elf version)
        32223,  -- Crusader Aura (Paladin - +20% vitesse montée, groupe)
        --20580,  -- Execute rang 4
        11580,  -- Intercept rang 2
        47422,  -- Holy Light rang 12
        20220,  -- Retribution Aura rang 5
        25291,  -- Seal of Command rang max
        20928,  -- Lay on Hands rang 1 (Paladin - full heal)
    },
    -- Niveau 64
    [64] = {
        25202,  -- Heroic Strike rang 11
        29383,  -- Hammer of Justice rang 5 (TBC)
        47420,  -- Holy Light rang 13
    },
    -- Niveau 68
    [68] = {
        30357,  -- Intercept rang 3
        20221,  -- Retribution Aura rang 6
        27140,  -- Blessing of Might rang 11 (TBC)
        57318,  -- Heroic Strike rang 12
    },
    -- Niveau 70 : sorts TBC max
    [70] = {
        19750,  -- Blessing of Might rang 12
        48817,  -- Holy Light rang 14 (WotLK)
        48952,  -- Lay on Hands rang 2
        25899,  -- Seal of Command rang TBC max
    },
    -- Niveau 75
    [75] = {
        57319,  -- Heroic Strike rang 13
        54428,  -- Intercept rang 4
        48931,  -- Hammer of Justice rang 6
    },
    -- Niveau 80 : rangs max + passifs WotLK
    [80] = {
        48968,  -- Holy Light rang 14 max WotLK
        48953,  -- Lay on Hands rang 3 (max)
        48938,  -- Blessing of Might rang 13 (max)
        54043,  -- Seal of Command max WotLK
        53600,  -- Shield of Righteousness (Paladin - bouclier)
        32223,  -- Crusader Aura (confirmé max, 1 seul rang)
        57318,  -- Heroic Strike rang max
        --25388,  -- Intervene (Warrior - rush allié)
        5384,   -- Heroic Throw (Warrior - lancer de hache/lance)
        20222,  -- Retribution Aura rang 7 (max)
        6190,   -- Battle Shout rang max
        50720,  -- Vigilance (Warrior - redirige menace alliée)
    },
}

-- =============================================
--   SKILLS PAR NIVEAU
--   Format : [niveau] = { { skillID, step, current, max }, ... }
--   step    = rang du skill (1 en général)
--   current = valeur actuelle accordée
--   max     = valeur maximale accordée
-- =============================================
local CavalierSkills = {
    -- Niveau 1 : armes de mêlée lourdes + bouclier
    [1] = {
        { 44,  1, 1, 300 },  -- Épées à deux mains
        { 54,  1, 1, 300 },  -- Masses à deux mains
        --{ 107, 1, 1, 300 },  -- Armes d'hast (lances, hallebardes)
        { 95,  1, 1, 300 },  -- Boucliers
    },
    -- Niveau 20 : montée en compétence armes
    [20] = {
        { 44,  1, 100, 300 },
        { 54,  1, 100, 300 },
        --{ 107, 1, 100, 300 },
    },
    -- Niveau 40
    [40] = {
        { 44,  1, 200, 300 },
        { 54,  1, 200, 300 },
        --{ 107, 1, 200, 300 },
        { 95,  1, 200, 300 },
    },
    -- Niveau 80 : compétences max
    [80] = {
        { 44,  1, 400, 400 },  -- Épées à deux mains max
        { 54,  1, 400, 400 },  -- Masses à deux mains max
        --{ 107, 1, 400, 400 },  -- Armes d'hast max
        { 95,  1, 400, 400 },  -- Boucliers max
    },
}

-- ID de classe du Cavalier (classe custom 12)
local CAVALIER_CLASS_ID = 12

-- =============================================
--   SERVEUR
-- =============================================
if AIO.AddAddon() then

    local function GiveSpellsForLevel(player, level)
        local spells = CavalierSpells[level]
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
    --   skillID : identifiant du skill (ex. 44 = Épées à deux mains)
    --   step    : rang de la compétence (toujours 1 pour les armes)
    --   current : valeur actuelle accordée au joueur
    --   max     : valeur maximale de la compétence
    local function GiveSkillsForLevel(player, level)
        local skills = CavalierSkills[level]
        if skills then
            for _, skillData in ipairs(skills) do
                local skillID, step, current, max = skillData[1], skillData[2], skillData[3], skillData[4]
                player:SetSkill(skillID, step, current, max)
            end
        end
    end

    local function OnLogin(event, player)
        if player:GetClass() ~= CAVALIER_CLASS_ID then return end

        -- Donner tous les sorts correspondant aux niveaux <= niveau actuel
        local currentLevel = player:GetLevel()
        for level, _ in pairs(CavalierSpells) do
            if level <= currentLevel then
                GiveSpellsForLevel(player, level)
            end
        end

        -- Donner tous les skills correspondant aux niveaux <= niveau actuel
        for level, _ in pairs(CavalierSkills) do
            if level <= currentLevel then
                GiveSkillsForLevel(player, level)
            end
        end
    end

    local function OnLevelChange(event, player, oldLevel)
        if player:GetClass() ~= CAVALIER_CLASS_ID then return end

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
