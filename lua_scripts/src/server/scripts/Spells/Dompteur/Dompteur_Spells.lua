local AIO = AIO or require("AIO")

-- =============================================
--   SORTS PAR NIVEAU
--   Format : [niveau] = { spellID, spellID, ... }
-- =============================================
local DompteurSpells = {
    -- Niveau 1 : sorts de départ donnés au login
    [1] = {
        75,     -- Auto Shot (passif tir automatique)
        2764,   -- Throw (lancer)
        6197,   -- Eagle Eye
        5225,   -- Track Beasts (passif)
        1494,   -- Track Beasts (actif)
        587,    -- Conjure Food
        5504,   -- Conjure Water
    },
    -- Niveau 4
    [4] = {
        2973,   -- Raptor Strike rang 1
        1978,   -- Serpent Sting rang 1
    },
    -- Niveau 6
    [6] = {
        3044,   -- Arcane Shot rang 1
    },
    -- Niveau 8
    [8] = {
        5116,   -- Concussive Shot rang 1
        6991,   -- Feed Pet
    },
    -- Niveau 10 : socle du Dompteur
    [10] = {
        1515,   -- Tame Beast
        883,    -- Call Pet
        2641,   -- Dismiss Pet
        982,    -- Revive Pet
        1002,   -- Eyes of the Beast
        6150,   -- Beast Lore
        1130,   -- Hunter's Mark rang 1
        136,    -- Mend Pet rang 1
        5118,   -- Aspect of the Cheetah
        13163,  -- Aspect of the Monkey
        13165,  -- Aspect of the Hawk rang 1
    },
    -- Niveau 12
    [12] = {
        1978,   -- Serpent Sting rang 2 (remplace rang 1)
        3110,   -- Mend Pet rang 2
    },
    -- Niveau 14
    [14] = {
        1499,   -- Freezing Trap rang 1
        3043,   -- Scorpid Sting rang 1
    },
    -- Niveau 16
    [16] = {
        14326,  -- Hunter's Mark rang 2
        14290,  -- Mend Pet rang 3
        14315,  -- Aspect of the Hawk rang 2
    },
    -- Niveau 18
    [18] = {
        13795,  -- Immolation Trap rang 1
        --409,    -- Raptor Strike rang 2
    },
    -- Niveau 20
    [20] = {
        14323,  -- Hunter's Mark rang 3
        2643,   -- Multi-Shot rang 1
        18937,  -- Aspect of the Hawk rang 3
        3034,   -- Viper Sting rang 1
    },
    -- Niveau 22
    [22] = {
        14308,  -- Mend Pet rang 4
    },
    -- Niveau 24
    [24] = {
        27014,  -- Serpent Sting rang 3
        2974,   -- Raptor Strike rang 3
        13813,  -- Explosive Trap rang 1
    },
    -- Niveau 26
    [26] = {
        14318,  -- Aspect of the Hawk rang 4
        14325,  -- Hunter's Mark rang 4
    },
    -- Niveau 28
    [28] = {
        14310,  -- Mend Pet rang 5
        --18916,  -- Immolation Trap rang 2
    },
    -- Niveau 30
    [30] = {
        5384,   -- Feign Death
        1543,   -- Flare
        19185,  -- Entrapment (passif proc)
        13809,  -- Ice Trap rang 1
        19506,  -- Trueshot Aura (passif groupe)
    },
    -- Niveau 32
    [32] = {
        14316,  -- Aspect of the Hawk rang 5
        14295,  -- Mend Pet rang 6
    },
    -- Niveau 34
    [34] = {
        14297,  -- Serpent Sting rang 4
        14327,  -- Hunter's Mark rang 5 (TBC rank)
        2643,   -- Multi-Shot rang 2 (reuplaod)
    },
    -- Niveau 36
    [36] = {
        --18917,  -- Immolation Trap rang 3
        --14296,  -- Mend Pet rang 7
    },
    -- Niveau 38
    [38] = {
        14319,  -- Aspect of the Hawk rang 6
    },
    -- Niveau 40
    [40] = {
        19801,  -- Tranquilizing Shot
        20736,  -- Distracting Shot
        13159,  -- Aspect of the Pack
        19396,  -- Bestial Wrath (Beast Mastery cooldown)
    },
    -- Niveau 42
    [42] = {
        14298,  -- Serpent Sting rang 5
        14311,  -- Mend Pet rang 8
    },
    -- Niveau 44
    [44] = {
        27023,  -- Immolation Trap rang 4
        27019,  -- Multi-Shot rang 3
    },
    -- Niveau 46
    [46] = {
        14320,  -- Aspect of the Hawk rang 7
        14313,  -- Mend Pet rang 9
    },
    -- Niveau 48
    [48] = {
        27016,  -- Serpent Sting rang 6
    },
    -- Niveau 50
    [50] = {
        34477,  -- Misdirection
        27022,  -- Explosive Trap rang 2
        27021,  -- Ice Trap rang 2
    },
    -- Niveau 52
    [52] = {
        --27020,  -- Multi-Shot rang 4
        --27017,  -- Serpent Sting rang 7
        14314,  -- Mend Pet rang 10
    },
    -- Niveau 54
    [54] = {
        27024,  -- Immolation Trap rang 5
        25294,  -- Aspect of the Hawk rang 8
    },
    -- Niveau 56
    [56] = {
        --27018,  -- Serpent Sting rang 8
    },
    -- Niveau 58
    [58] = {
        49066,  -- Mend Pet rang 11
    },
    -- Niveau 60
    [60] = {
        53338,  -- Hunter's Mark rang max (WotLK)
        60053,  -- Explosive Trap rang 3
        60054,  -- Immolation Trap rang 6
        61006,  -- Aspect of the Dragonhawk (remplace Hawk + Monkey)
    },
    -- Niveau 62
    [62] = {
        49001,  -- Serpent Sting rang 9
        --49070,  -- Multi-Shot rang 5
    },
    -- Niveau 68
    [68] = {
        56641,  -- Steady Shot rang 1 (WotLK)
        49052,  -- Mend Pet rang 12
    },
    -- Niveau 70
    [70] = {
        49055,  -- Serpent Sting rang 10
        60192,  -- Explosive Trap rang 4
        49067,  -- Immolation Trap rang 7
        781,    -- Disengage (WotLK)
    },
    -- Niveau 75
    [75] = {
        49050,  -- Mend Pet rang 13
        49048,  -- Multi-Shot rang 6
    },
    -- Niveau 80 : rangs max + passifs
    [80] = {
        49065,  -- Serpent Sting rang 11 (max)
        60053,  -- Explosive Trap rang final
        49056,  -- Steady Shot rang final
        49045,  -- Mend Pet rang 14 (max)
        61317,  -- Aspect of the Dragonhawk rang 2
        53351,  -- Kill Shot (exécution 20% HP, WotLK)
        34026,  -- Kill Command (passif pet, WotLK)
        1038,   -- Beast Training (ouvre interface entraînem. pet)
    },
}

-- =============================================
--   SKILLS PAR NIVEAU
--   Format : [niveau] = { { skillID, step, current, max }, ... }
--   step    = rang du skill (1 en général)
--   current = valeur actuelle accordée
--   max     = valeur maximale accordée
-- =============================================
local DompteurSkills = {
    -- Niveau 1
    [1] = {
        --{ 264, 1, 1, 300 },  -- Armes à distance (Bows)
        { 136, 1, 1, 300 },  -- Bâtons (pour mêlée d'appoint)
        { 173, 1, 1, 300 },  -- Dagues (arme secondaire)
    },
    -- Niveau 10 : Apprivoisement débloqué
    [10] = {
        --{ 264, 1, 75, 300 }, -- Mise à jour Armes à distance
    },
    -- Niveau 40
    [40] = {
        --{ 264, 1, 200, 300 }, -- Progression Armes à distance
    },
    -- Niveau 80
    [80] = {
        --{ 264, 1, 400, 400 }, -- Armes à distance max
    },
}

-- ID de classe du Dompteur (classe custom 15)
local DOMPTEUR_CLASS_ID = 15

-- =============================================
--   SERVEUR
-- =============================================
if AIO.AddAddon() then

    local function GiveSpellsForLevel(player, level)
        local spells = DompteurSpells[level]
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
    --   skillID : identifiant du skill (ex. 264 = Armes à distance)
    --   step    : rang de la compétence (toujours 1 pour les armes)
    --   current : valeur actuelle accordée au joueur
    --   max     : valeur maximale de la compétence
    local function GiveSkillsForLevel(player, level)
        local skills = DompteurSkills[level]
        if skills then
            for _, skillData in ipairs(skills) do
                local skillID, step, current, max = skillData[1], skillData[2], skillData[3], skillData[4]
                player:SetSkill(skillID, step, current, max)
            end
        end
    end

    local function OnLogin(event, player)
        if player:GetClass() ~= DOMPTEUR_CLASS_ID then return end

        -- Donner tous les sorts correspondant aux niveaux <= niveau actuel
        local currentLevel = player:GetLevel()
        for level, _ in pairs(DompteurSpells) do
            if level <= currentLevel then
                GiveSpellsForLevel(player, level)
            end
        end

        -- Donner tous les skills correspondant aux niveaux <= niveau actuel
        for level, _ in pairs(DompteurSkills) do
            if level <= currentLevel then
                GiveSkillsForLevel(player, level)
            end
        end
    end

    local function OnLevelChange(event, player, oldLevel)
        if player:GetClass() ~= DOMPTEUR_CLASS_ID then return end

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
