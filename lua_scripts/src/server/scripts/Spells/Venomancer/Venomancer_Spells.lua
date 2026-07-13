local AIO = AIO or require("AIO")

-- =============================================
--   SORTS PAR NIVEAU
--   Format : [niveau] = { spellID, spellID, ... }
-- =============================================
local VenomancerSpells = {
    -- Niveau 1 : sorts de départ donnés au login
    [1] = {
        2818,   -- Deadly Poison rang 1
        8679,   -- Instant Poison rang 1
        3408,   -- Crippling Poison rang 1 (slow)
        587,    -- Conjure Food
        5504,   -- Conjure Water
    },
    -- Niveau 4
    [4] = {
        13218,  -- Wound Poison rang 1
    },
    -- Niveau 8
    [8] = {
        2819,   -- Deadly Poison rang 2
        8680,   -- Instant Poison rang 2
    },
    -- Niveau 12
    [12] = {
        3034,   -- Viper Sting (Hunter) - drain mana + DoT nature
        13222,  -- Wound Poison rang 2
    },
    -- Niveau 16
    [16] = {
        11335,  -- Instant Poison rang 3
        11353,  -- Deadly Poison rang 3
    },
    -- Niveau 20
    [20] = {
        13223,  -- Wound Poison rang 3
        3409,   -- Crippling Poison rang 2
        --3065,   -- Scorpid Poison (pet spell - DoT nature)
    },
    -- Niveau 24
    [24] = {
        11336,  -- Instant Poison rang 4
        11354,  -- Deadly Poison rang 4
    },
    -- Niveau 28
    [28] = {
        13224,  -- Wound Poison rang 4
        --11201,  -- Mind-Numbing Poison rang 1 (interruption cast)
    },
    -- Niveau 32
    [32] = {
        11337,  -- Instant Poison rang 5
        24131,  -- Wyvern Sting (sleep + DoT poison)
    },
    -- Niveau 36
    [36] = {
        25349,  -- Deadly Poison rang 5
        34655,  -- Paralytic Poison rang 1 (stun)
    },
    -- Niveau 40
    [40] = {
        --25348,  -- Instant Poison rang 6
        27189,  -- Wound Poison rang 5
        11202,  -- Mind-Numbing Poison rang 2
        --5237,   -- Anesthetic Poison rang 1
    },
    -- Niveau 44
    [44] = {
        26967,  -- Deadly Poison rang 6
        34657,  -- Paralytic Poison rang 2
    },
    -- Niveau 48
    [48] = {
        26891,  -- Instant Poison rang 7
        11203,  -- Mind-Numbing Poison rang 3
    },
    -- Niveau 52
    [52] = {
        27186,  -- Deadly Poison rang 7
        37864,  -- Paralytic Poison rang 3
    },
    -- Niveau 60
    [60] = {
        35760,  -- Virulent Poison (DoT nature court)
        36049,  -- Infectious Poison
    },
    -- Niveau 70 : rangs intermédiaires WotLK
    [70] = {
        57965,  -- Instant Poison rang 8
        57968,  -- Deadly Poison rang 8
        57975,  -- Wound Poison rang 6
    },
    -- Niveau 80 : rangs max
    [80] = {
        57970,  -- Deadly Poison rang 9 (max)
        57978,  -- Wound Poison rang 7 (max)
        24423,  -- Poison Spit (Spider - nature DoT AoE)
        19128,  -- Scorpid Poison rang 2
        35346,  -- Poison générique (passif proc)
        36049,  -- Infectious Poison (passif)
    },
}

-- =============================================
--   SKILLS PAR NIVEAU
--   Format : [niveau] = { { skillID, step, current, max }, ... }
--   step    = rang du skill (1 en général)
--   current = valeur actuelle accordée
--   max     = valeur maximale accordée
-- =============================================
local VenomancerSkills = {
    -- Niveau 1 : Dagues (173) + Bâtons (136)
    [1] = {
        { 173, 1, 1, 300 },  -- Dagues
        { 136, 1, 1, 300 },  -- Bâtons
		{ 414, 1, 1, 300 },  -- Cuir
    },
}

-- ID de classe du Venomancer (classe custom 19)
local VENOMANCER_CLASS_ID = 19

-- =============================================
--   SERVEUR
-- =============================================
if AIO.AddAddon() then

    local function GiveSpellsForLevel(player, level)
        local spells = VenomancerSpells[level]
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
    --   skillID : identifiant du skill (ex. 173 = Dagues)
    --   step    : rang de la compétence (toujours 1 pour les armes)
    --   current : valeur actuelle accordée au joueur
    --   max     : valeur maximale de la compétence
    local function GiveSkillsForLevel(player, level)
        local skills = VenomancerSkills[level]
        if skills then
            for _, skillData in ipairs(skills) do
                local skillID, step, current, max = skillData[1], skillData[2], skillData[3], skillData[4]
                player:SetSkill(skillID, step, current, max)
            end
        end
    end

    local function OnLogin(event, player)
        if player:GetClass() ~= VENOMANCER_CLASS_ID then return end

        -- Donner tous les sorts correspondant aux niveaux <= niveau actuel
        local currentLevel = player:GetLevel()
        for level, _ in pairs(VenomancerSpells) do
            if level <= currentLevel then
                GiveSpellsForLevel(player, level)
            end
        end

        -- Donner tous les skills correspondant aux niveaux <= niveau actuel
        for level, _ in pairs(VenomancerSkills) do
            if level <= currentLevel then
                GiveSkillsForLevel(player, level)
            end
        end
    end

    local function OnLevelChange(event, player, oldLevel)
        if player:GetClass() ~= VENOMANCER_CLASS_ID then return end

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
