local m_config = {
    elunaDB = 'auc_eluna',
}

local ITEM_TO_SPELL = {
    [200015] = 200015, -- Jina-Kang, Kindness of Chi-Ji
    [200016] = 200016, -- Xing-Ho, Breath of Yu'lon
    [200017] = 200017, -- Qian-Le, Courage of Niuzao
    [200018] = 200018, -- Gong-Lu, Strength of Xuen
}

local EQUIPMENT_SLOT_BACK = 14
local INVENTORY_SLOT_BAG_0 = 255

--[[
    AIO REQUIREMENT
]]--
local AIO = AIO or require("AIO");
local h_legendarywings = AIO.AddHandlers("h_legendarywings", {})

local m_wings = {}
m_wings.cache = {} -- [guid] = { hide = bool }

--[[ DON'T TOUCH THIS ]]--
CharDBQuery('CREATE DATABASE IF NOT EXISTS `'..m_config.elunaDB..'`;');
CharDBQuery('CREATE TABLE IF NOT EXISTS `'..m_config.elunaDB..'`.`characters_legendary_wings_pref` (`guid` int(10) unsigned NOT NULL, `hide_effect` tinyint(1) NOT NULL DEFAULT 0, PRIMARY KEY (`guid`)) ENGINE=InnoDB DEFAULT CHARSET=latin1;');

function h_legendarywings.pushState(player)
    local pGuid = player:GetGUIDLow()
    local hide = m_wings.cache[pGuid] and m_wings.cache[pGuid].hide or false
    AIO.Msg():Add("h_legendarywings", "setState", hide and 1 or 0):Send(player)
end

local function ApplyToEquippedItem(player, hide)
    local item = player:GetItemByPos(INVENTORY_SLOT_BAG_0, EQUIPMENT_SLOT_BACK)
    if not item then
        return
    end
    local entry = item:GetEntry()
    local spellId = ITEM_TO_SPELL[entry]
    if not spellId then
        return
    end

    if hide then
        player:RemoveAura(spellId)
    else
        if not player:HasAura(spellId) then
            player:AddAura(spellId, player)
        end
    end
end

function m_wings.load(player)
    local pGuid = player:GetGUIDLow()
    if not m_wings.cache[pGuid] then
        m_wings.cache[pGuid] = { hide = false }
    end

    local q = CharDBQuery('SELECT hide_effect FROM '..m_config.elunaDB..'.characters_legendary_wings_pref WHERE guid = '..pGuid..';')
    if q then
        m_wings.cache[pGuid].hide = (q:GetUInt8(0) == 1)
    else
        CharDBQuery('INSERT IGNORE INTO '..m_config.elunaDB..'.characters_legendary_wings_pref (guid, hide_effect) VALUES ('..pGuid..', 0);')
        m_wings.cache[pGuid].hide = false
    end
end

function h_legendarywings.getState(msg, player)
    local pGuid = player:GetGUIDLow()
    if not m_wings.cache[pGuid] then
        m_wings.load(player)
    end
    msg:Add("h_legendarywings", "setState", m_wings.cache[pGuid].hide and 1 or 0)
    return msg
end
AIO.AddOnInit(h_legendarywings.getState)

function h_legendarywings.setState(player, hideValue)
    local pGuid = player:GetGUIDLow()
    local hide = (hideValue == 1 or hideValue == true)

    if not m_wings.cache[pGuid] then
        m_wings.cache[pGuid] = { hide = false }
    end
    m_wings.cache[pGuid].hide = hide

    CharDBQuery('UPDATE '..m_config.elunaDB..'.characters_legendary_wings_pref SET hide_effect = '..(hide and 1 or 0)..' WHERE guid = '..pGuid..';')

    ApplyToEquippedItem(player, hide)
    h_legendarywings.pushState(player)
end

function m_wings.onLogin(event, player)
    m_wings.load(player)
    local pGuid = player:GetGUIDLow()
    if m_wings.cache[pGuid].hide then
        ApplyToEquippedItem(player, true)
    end
end
RegisterPlayerEvent(3, m_wings.onLogin)

function m_wings.onEquip(event, player, item, bag, slot)
    if not item then
        return
    end
    local spellId = ITEM_TO_SPELL[item:GetEntry()]
    if not spellId then
        return
    end

    local pGuid = player:GetGUIDLow()
    if not m_wings.cache[pGuid] then
        m_wings.load(player)
    end
    if m_wings.cache[pGuid].hide then
        player:RemoveAura(spellId)
    end
end
RegisterPlayerEvent(29, m_wings.onEquip)
