-- ExpModifier_AIO_Server.lua
require('sys_player_informations');

--[[ 
    MOD_EXP REQUIREMENT
]]--
local m_config = {
    elunaDB = 'auc_eluna',
};
local m_exp = {};

--[[ 
    AIO REQUIREMENT
]]--
local AIO = AIO or require("AIO");
local h_expmodifier = AIO.AddHandlers("h_expmodifier", {})

--[[ 
    getRateModifier
    Récupère le multiplicateur et le statut premium du joueur
]]--
function h_expmodifier.getRateModifier(msg, player)
    local pGuid = player:GetGUIDLow()
    if not(m_exp[pGuid]) then
        m_exp[pGuid] = {
            mod_exp = 1;
        }
    end

    -- Récupération du statut premium depuis playerInformations
    local isPremium = 0
    if playerInformations[pGuid] and playerInformations[pGuid].rank == 1 then
        isPremium = 1
    end

    msg:Add("h_expmodifier", "setMyRate", m_exp[pGuid].mod_exp);
    msg:Add("h_expmodifier", "setPremiumButtons", isPremium);
    return msg
end
AIO.AddOnInit(h_expmodifier.getRateModifier)

function h_expmodifier.update(player)
    h_expmodifier.getRateModifier(AIO.Msg(), player):Send(player);
end

--[[ DON'T TOUCH THIS ]]--
CharDBQuery('CREATE DATABASE IF NOT EXISTS `'..m_config.elunaDB..'`;');
CharDBQuery('CREATE TABLE IF NOT EXISTS `'..m_config.elunaDB..'`.`characters_exp_rates` (`guid` int(10) NOT NULL, `mod_exp` INT(2) NOT NULL DEFAULT 1, PRIMARY KEY (`guid`)) ENGINE=InnoDB DEFAULT CHARSET=latin1;');

function m_exp.onConnect(event, player)
    local pGuid = player:GetGUIDLow()
    if not(m_exp[pGuid]) then
        m_exp[pGuid] = {
            mod_exp = 1;
        }
    end
    local GetRateExp = CharDBQuery('SELECT mod_exp FROM '..m_config.elunaDB..'.characters_exp_rates WHERE guid = '..pGuid..';')
    if GetRateExp ~= nil then
        m_exp[pGuid].mod_exp = GetRateExp:GetUInt32(0)
    else
        local AddRateExp = CharDBQuery('INSERT IGNORE INTO '..m_config.elunaDB..'.characters_exp_rates (guid, mod_exp) VALUES ('..pGuid..', 1);')
        m_exp[pGuid].mod_exp = 1
    end
    h_expmodifier.update(player)
end
RegisterPlayerEvent(3, m_exp.onConnect)

function m_exp.onDisconnect(event, player)
    local pGuid = player:GetGUIDLow()
    if not(m_exp[pGuid]) then
        m_exp[pGuid] = {
            mod_exp = 1;
        }
    end
    local SaveRateExp = CharDBQuery('UPDATE '..m_config.elunaDB..'.characters_exp_rates SET mod_exp = '..m_exp[pGuid].mod_exp..' WHERE guid = '..pGuid..';')
end
RegisterPlayerEvent(4, m_exp.onDisconnect)

function m_exp.onReceiveExp(event, player, amount, victim)
    local pGuid = player:GetGUIDLow()
    if not(m_exp[pGuid]) then
        m_exp[pGuid] = {
            mod_exp = 1;
        }
    end

    return amount * m_exp[pGuid].mod_exp
end
RegisterPlayerEvent(12, m_exp.onReceiveExp)

function m_exp.getAllPlayerExp(event)
    for i, player in ipairs(GetPlayersInWorld()) do
        m_exp.onConnect(event, player)
    end
end
RegisterServerEvent(33, m_exp.getAllPlayerExp)

function m_exp.saveAllPlayerExp(event)
    for i, player in ipairs(GetPlayersInWorld()) do
        m_exp.onDisconnect(event, player)
    end
end
RegisterServerEvent(16, m_exp.saveAllPlayerExp)

--[[ 
    setRateModifier
    Fonction pour définir le multiplicateur d'XP
    Vérifie le statut premium pour x4 et x5
]]--
function h_expmodifier.setRateModifier(player, modifier)
    local pGuid = player:GetGUIDLow()
    if not(m_exp[pGuid]) then
        m_exp[pGuid] = {
            mod_exp = 1;
        }
    end
    
    -- Vérification du statut premium pour x4 et x5
    local isPremium = false
    if playerInformations[pGuid] and playerInformations[pGuid].rank == 1 then
        isPremium = true
    end
    
    -- Vérifier si le joueur essaie de définir x4 ou x5 sans être premium
    if (modifier == 4 or modifier == 5) and not isPremium then
        player:SendNotification('Vous devez être Contributeur Premium pour utiliser ce multiplicateur!')
        return
    end
    
    -- Validation du modificateur
    if modifier < 1 or modifier > 5 then
        player:SendNotification('Multiplicateur invalide!')
        return
    end
    
    m_exp[pGuid].mod_exp = modifier;
    player:SendNotification('Votre multiplicateur d\'expérience est maintenant en x'..m_exp[pGuid].mod_exp..'!')

    h_expmodifier.update(player)
end