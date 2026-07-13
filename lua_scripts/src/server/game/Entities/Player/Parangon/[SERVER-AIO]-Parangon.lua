--[[
    Système Parangon - AIO
]]--

local AIO = AIO or require("aio")

local parangon = {

    config = {
        db_name = 'auc_eluna',

        pointsPerLevel = 1,
        minLevel = 1,

        expMulti = 1,
        expMax = 5,

        pveKill = 1,
        pvpKill = 2,

        levelDiff = 90,
    },

    spells = {
        [7464] = 'Force',
        [7471] = 'Agilité',
        [7477] = 'Endurance',
        [7468] = 'Intelligence',
        [7597] = 'Coup Critique',
        [37728] = 'Hâte',
        [55565] = 'Puissance des sorts',
        [9136] = 'Puissance d\'attaque',
        [1502002] = 'Esquive',
        [7511] = 'Defense',
        [13665] = 'Parade',
        [27949] = 'Régén vie/mana',
        [18672] = 'Résistance',
        [9760] = 'Armure',
        [46412] = 'Résilience',
        [15464] = 'Score de toucher',
    },
}

local parangon_addon = AIO.AddHandlers("AIO_Parangon", {})

parangon.account = {}

-- Fonction d'envoi des informations au client
function parangon_addon.sendInformations(msg, player)
    local pGuid = player:GetGUIDLow()
    local pAcc = player:GetAccountId()

    local temp = {
        stats = {},
        level = 1,
        points = 0,
    }
    
    -- Récupérer toutes les statistiques
    for stat, _ in pairs(parangon.spells) do
        temp.stats[stat] = player:GetData('parangon_stats_'..stat) or 0
    end

    -- S'assurer que le compte existe
    if not parangon.account[pAcc] then
        parangon.account[pAcc] = {
            level = 1,
            exp = 0,
            exp_max = parangon.config.expMax,
        }
    end

    temp.level = parangon.account[pAcc].level
    temp.points = player:GetData('parangon_points') or 0
    temp.exps = {
        exp = parangon.account[pAcc].exp,
        exp_max = parangon.account[pAcc].exp_max
    }

    return msg:Add("AIO_Parangon", "setInfo", temp.stats, temp.level, temp.points, temp.exps)
end
AIO.AddOnInit(parangon_addon.sendInformations)

-- Fonction pour envoyer les informations au client
function parangon.setAddonInfo(player)
    parangon_addon.sendInformations(AIO.Msg(), player):Send(player)
end

-- Initialisation des tables de base de données
function parangon.onServerStart(event)
    CharDBExecute('CREATE DATABASE IF NOT EXISTS `'..parangon.config.db_name..'`;')
    CharDBExecute('CREATE TABLE IF NOT EXISTS `'..parangon.config.db_name..'`.`account_parangon` (`account_id` INT(11) NOT NULL, `level` INT(11) DEFAULT 1, `exp` INT(11) DEFAULT 0, PRIMARY KEY (`account_id`) );')
    CharDBExecute('CREATE TABLE IF NOT EXISTS `'..parangon.config.db_name..'`.`characters_parangon` (`account_id` INT(11) NOT NULL, `guid` INT(11) NOT NULL, `strength` INT(11) DEFAULT 0, `agility` INT(11) DEFAULT 0, `stamina` INT(11) DEFAULT 0, `intellect` INT(11) DEFAULT 0, `criticalhit` INT(11) DEFAULT 0, `haste` INT(11) DEFAULT 0, `spellpower` INT(11) DEFAULT 0, `attackpower` INT(11) DEFAULT 0, `dodge` INT(11) DEFAULT 0, `defense` INT(11) DEFAULT 0, `parry` INT(11) DEFAULT 0, `healthregeneration` INT(11) DEFAULT 0, `resistance` INT(11) DEFAULT 0, `armor` INT(11) DEFAULT 0, `resilience` INT(11) DEFAULT 0, `hitrating` INT(11) DEFAULT 0, PRIMARY KEY (`account_id`, `guid`));')
    --print('Eluna :: Paragon System initialized')
end
RegisterServerEvent(14, parangon.onServerStart)

-- Appliquer les statistiques (auras)
function parangon_addon.setStats(player)
    local pLevel = player:GetLevel()

    if pLevel >= parangon.config.minLevel then
        for spell, _ in pairs(parangon.spells) do
            local statValue = player:GetData('parangon_stats_'..spell) or 0
            
            -- Retirer l'aura existante
            player:RemoveAura(spell)
            
            -- Ajouter l'aura avec le bon nombre de stacks si > 0
            if statValue > 0 then
                player:AddAura(spell, player)
                local aura = player:GetAura(spell)
                if aura then
                    aura:SetStackAmount(statValue)
                end
            end
        end
    end
end

-- Gérer l'ajout/retrait de points
function parangon_addon.setStatsInformation(player, stat, value, flags)
    local pCombat = player:IsInCombat()
    
    if pCombat then
        player:SendNotification('Vous ne pouvez pas faire ça en combat.')
        return false
    end
    
    local pLevel = player:GetLevel()
    if pLevel < parangon.config.minLevel then
        player:SendNotification('Vous n\'avez pas le niveau requis.')
        return false
    end
    
    local currentPoints = player:GetData('parangon_points') or 0
    local currentStat = player:GetData('parangon_stats_'..stat) or 0
    local spentPoints = player:GetData('parangon_points_spend') or 0
    
    if flags then
        -- Ajouter des points
        if currentPoints >= value then
            player:SetData('parangon_stats_'..stat, currentStat + value)
            player:SetData('parangon_points', currentPoints - value)
            player:SetData('parangon_points_spend', spentPoints + value)
        else
            player:SendNotification('Vous n\'avez plus de points à attribuer.')
            return false
        end
    else
        -- Retirer des points
        if currentStat >= value then
            player:SetData('parangon_stats_'..stat, currentStat - value)
            player:SetData('parangon_points', currentPoints + value)
            player:SetData('parangon_points_spend', spentPoints - value)
        else
            player:SendNotification('Vous n\'avez pas de points à retirer.')
            return false
        end
    end
    
    -- Mettre à jour l'affichage
    parangon.setAddonInfo(player)
    
    return true
end

-- Définir toutes les statistiques du personnage
function Player:setParangonInfo(strength, agility, stamina, intellect, criticalhit, haste, spellpower, attackpower, dodge, defense, parry, healthregeneration, resistance, armor, resilience, hitrating)
    self:SetData('parangon_stats_7464', strength or 0)
    self:SetData('parangon_stats_7471', agility or 0)
    self:SetData('parangon_stats_7477', stamina or 0)
    self:SetData('parangon_stats_7468', intellect or 0)
    self:SetData('parangon_stats_7597', criticalhit or 0)
    self:SetData('parangon_stats_37728', haste or 0)
    self:SetData('parangon_stats_55565', spellpower or 0)
    self:SetData('parangon_stats_9136', attackpower or 0)
    self:SetData('parangon_stats_1502002', dodge or 0)
    self:SetData('parangon_stats_7511', defense or 0)
    self:SetData('parangon_stats_13665', parry or 0)
    self:SetData('parangon_stats_27949', healthregeneration or 0)
    self:SetData('parangon_stats_18672', resistance or 0)
    self:SetData('parangon_stats_9760', armor or 0)
    self:SetData('parangon_stats_46412', resilience or 0)
    self:SetData('parangon_stats_15464', hitrating or 0)
end

-- Calculer les points disponibles
function Player:point_calc()
    local pAcc = self:GetAccountId()
    
    -- Initialiser le compte si nécessaire
    if not parangon.account[pAcc] then
        parangon.account[pAcc] = {
            level = 1,
            exp = 0,
            exp_max = parangon.config.expMax
        }
    end
    
    -- Initialiser les points dépensés si nécessaire
    local spentPoints = self:GetData('parangon_points_spend')
    if not spentPoints then
        spentPoints = 0
        self:SetData('parangon_points_spend', 0)
    end
    
    -- Calculer les points disponibles
    local totalPoints = parangon.account[pAcc].level * parangon.config.pointsPerLevel
    local availablePoints = totalPoints - spentPoints
    
    self:SetData('parangon_points', availablePoints)
end

-- Connexion du joueur
function parangon.onLogin(event, player)
    local pGuid = player:GetGUIDLow()
    local pAcc = player:GetAccountId()
    
    -- 1. CHARGER LES INFORMATIONS DE COMPTE D'ABORD
    if not parangon.account[pAcc] then
        parangon.account[pAcc] = {
            level = 1,
            exp = 0,
            exp_max = parangon.config.expMax,
        }

        local getParangonAccInfo = AuthDBQuery('SELECT level, exp FROM `'..parangon.config.db_name..'`.`account_parangon` WHERE account_id = '..pAcc)
        if getParangonAccInfo then
            parangon.account[pAcc].level = getParangonAccInfo:GetUInt32(0)
            parangon.account[pAcc].exp = getParangonAccInfo:GetUInt32(1)
            parangon.account[pAcc].exp_max = parangon.config.expMax * parangon.account[pAcc].level
        else
            CharDBExecute('INSERT IGNORE INTO `'..parangon.config.db_name..'`.`account_parangon` VALUES ('..pAcc..', 1, 0)')
        end
    end
    
    -- 2. CHARGER LES STATISTIQUES DU PERSONNAGE
    local getParangonCharInfo = CharDBQuery('SELECT strength, agility, stamina, intellect, criticalhit, haste, spellpower, attackpower, dodge, defense, parry, healthregeneration, resistance, armor, resilience, hitrating FROM `'..parangon.config.db_name..'`.`characters_parangon` WHERE guid = '..pGuid)
    
    if getParangonCharInfo then
        -- Charger les stats depuis la base de données
        player:setParangonInfo(
            getParangonCharInfo:GetUInt32(0),  -- strength
            getParangonCharInfo:GetUInt32(1),  -- agility
            getParangonCharInfo:GetUInt32(2),  -- stamina
            getParangonCharInfo:GetUInt32(3),  -- intellect
            getParangonCharInfo:GetUInt32(4),  -- criticalhit
            getParangonCharInfo:GetUInt32(5),  -- haste
            getParangonCharInfo:GetUInt32(6),  -- spellpower
            getParangonCharInfo:GetUInt32(7),  -- attackpower
            getParangonCharInfo:GetUInt32(8),  -- dodge
            getParangonCharInfo:GetUInt32(9),  -- defense
            getParangonCharInfo:GetUInt32(10), -- parry
            getParangonCharInfo:GetUInt32(11), -- healthregeneration
            getParangonCharInfo:GetUInt32(12), -- resistance
            getParangonCharInfo:GetUInt32(13), -- armor
            getParangonCharInfo:GetUInt32(14), -- resilience
            getParangonCharInfo:GetUInt32(15)  -- hitrating
        )
        
        -- Calculer le total des points dépensés
        local totalSpent = 0
        for i = 0, 15 do
            totalSpent = totalSpent + getParangonCharInfo:GetUInt32(i)
        end
        
        player:SetData('parangon_points_spend', totalSpent)
    else
        -- Nouveau personnage - initialiser avec des valeurs par défaut
        CharDBExecute('INSERT IGNORE INTO `'..parangon.config.db_name..'`.`characters_parangon` VALUES ('..pAcc..', '..pGuid..', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)')
        player:setParangonInfo(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        player:SetData('parangon_points_spend', 0)
    end

    -- 3. CALCULER LES POINTS DISPONIBLES
    player:point_calc()
    
    -- 4. APPLIQUER LES AURAS
    parangon_addon.setStats(player)
    
    -- 5. SYNCHRONISER AVEC LE CLIENT
    parangon.setAddonInfo(player)
end
RegisterPlayerEvent(3, parangon.onLogin)

-- Charger les joueurs déjà connectés au démarrage du serveur
function parangon.getPlayers(event)
    for _, player in pairs(GetPlayersInWorld()) do
        parangon.onLogin(event, player)
    end
    --print('Eluna :: Paragon System start')
end
RegisterServerEvent(33, parangon.getPlayers)

-- Déconnexion du joueur
function parangon.onLogout(event, player)
    local pAcc = player:GetAccountId()
    local pGuid = player:GetGUIDLow()
    
    -- Récupérer toutes les statistiques
    local strength = player:GetData('parangon_stats_7464') or 0
    local agility = player:GetData('parangon_stats_7471') or 0
    local stamina = player:GetData('parangon_stats_7477') or 0
    local intellect = player:GetData('parangon_stats_7468') or 0
    local criticalhit = player:GetData('parangon_stats_7597') or 0
    local haste = player:GetData('parangon_stats_37728') or 0
    local spellpower = player:GetData('parangon_stats_55565') or 0
    local attackpower = player:GetData('parangon_stats_9136') or 0
    local dodge = player:GetData('parangon_stats_1502002') or 0
    local defense = player:GetData('parangon_stats_7511') or 0
    local parry = player:GetData('parangon_stats_13665') or 0
    local healthregeneration = player:GetData('parangon_stats_27949') or 0
    local resistance = player:GetData('parangon_stats_18672') or 0
    local armor = player:GetData('parangon_stats_9760') or 0
    local resilience = player:GetData('parangon_stats_46412') or 0
    local hitrating = player:GetData('parangon_stats_15464') or 0
    
    -- Sauvegarder les statistiques du personnage
    CharDBExecute('REPLACE INTO `'..parangon.config.db_name..'`.`characters_parangon` VALUES ('..pAcc..', '..pGuid..', '..strength..', '..agility..', '..stamina..', '..intellect..', '..criticalhit..', '..haste..', '..spellpower..', '..attackpower..', '..dodge..', '..defense..', '..parry..', '..healthregeneration..', '..resistance..', '..armor..', '..resilience..', '..hitrating..')')

    -- Sauvegarder les informations du compte
    if parangon.account[pAcc] then
        local level = parangon.account[pAcc].level
        local exp = parangon.account[pAcc].exp
        CharDBExecute('REPLACE INTO `'..parangon.config.db_name..'`.`account_parangon` VALUES ('..pAcc..', '..level..', '..exp..')')
    end
end
RegisterPlayerEvent(4, parangon.onLogout)

-- Sauvegarder tous les joueurs connectés à l'arrêt du serveur
function parangon.setPlayers(event)
    for _, player in pairs(GetPlayersInWorld()) do
        parangon.onLogout(event, player)
    end
    --print('Eluna :: Paragon System saved for all online players')
end
RegisterServerEvent(16, parangon.setPlayers)

-- Donner de l'expérience Parangon
function parangon.setExp(player, victim)
    local pLevel = player:GetLevel()
    local vLevel = victim:GetLevel()
    local pAcc = player:GetAccountId()

    -- Vérifier la différence de niveau
    local levelDiff = math.abs(pLevel - vLevel)
    if levelDiff > parangon.config.levelDiff then
        return
    end

    -- Initialiser le compte si nécessaire
    if not parangon.account[pAcc] then
        parangon.account[pAcc] = {
            level = 1,
            exp = 0,
            exp_max = parangon.config.expMax
        }
    end

    -- Donner l'expérience selon le type de victime
    local isPlayer = GetGUIDEntry(victim:GetGUID())
    if isPlayer == 0 then
        -- PVP Kill
        parangon.account[pAcc].exp = parangon.account[pAcc].exp + parangon.config.pvpKill
    else
        -- PVE Kill
        parangon.account[pAcc].exp = parangon.account[pAcc].exp + parangon.config.pveKill
    end
    
    -- Mettre à jour l'interface
    parangon.setAddonInfo(player)

    -- Vérifier si le joueur monte de niveau
    if parangon.account[pAcc].exp >= parangon.account[pAcc].exp_max then
        player:SetParangonLevel(1)
    end
end

-- Event de kill (créature ou joueur)
function parangon.onKillCreatureOrPlayer(event, player, victim)
    local pLevel = player:GetLevel()

    if pLevel >= parangon.config.minLevel then
        local pGroup = player:GetGroup()
        
        if pGroup then
            -- Donner l'expérience à tous les membres du groupe
            for _, groupMember in pairs(pGroup:GetMembers()) do
                parangon.setExp(groupMember, victim)
            end
        else
            -- Donner l'expérience au joueur seul
            parangon.setExp(player, victim)
        end
    end
end
RegisterPlayerEvent(6, parangon.onKillCreatureOrPlayer)  -- PLAYER_EVENT_KILL_PLAYER
RegisterPlayerEvent(7, parangon.onKillCreatureOrPlayer)  -- PLAYER_EVENT_KILL_CREATURE

-- Monter de niveau Parangon
function Player:SetParangonLevel(level)
    local pAcc = self:GetAccountId()

    -- Initialiser si nécessaire
    if not parangon.account[pAcc] then
        parangon.account[pAcc] = {
            level = 1,
            exp = 0,
            exp_max = parangon.config.expMax
        }
    end

    -- Augmenter le niveau
    parangon.account[pAcc].level = parangon.account[pAcc].level + level
    parangon.account[pAcc].exp = 0
    parangon.account[pAcc].exp_max = parangon.config.expMax * parangon.account[pAcc].level

    -- Recalculer les points disponibles
    self:point_calc()

    -- Mettre à jour l'interface
    parangon.setAddonInfo(self)

    -- Effet visuel
    self:CastSpell(self, 24312, true)
    self:RemoveAura(24312)
    
    -- Notification
    self:SendNotification('|CFF00A2FFVous venez de passer un niveau de Parangon.\nFélicitations, vous êtes maintenant au niveau '..parangon.account[pAcc].level..' !')
end