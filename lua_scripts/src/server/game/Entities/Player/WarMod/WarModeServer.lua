local AIO = AIO or require("AIO")

local WarModeHandlers = AIO.AddHandlers("WarMode", {})

-- Détermine la langue du compte du joueur (0 = enUS, sinon frFR)
local function GetPlayerLocale(player)
    local ok, result = pcall(function()
        local accountId = player:GetAccountId()
        local q = AuthDBQuery("SELECT locale FROM account WHERE id = " .. accountId .. ";")
        if q then
            local localeId = q:GetUInt8(0)
            if localeId == 0 then
                return "enUS"
            end
        end
        return "frFR"
    end)
    if ok and result then
        return result
    end
    return "frFR"
end

local WarModeNotif = {
    frFR = {
        CANT_CHANGE_IN_COMBAT = "Vous ne pouvez pas changer votre mode guerre pendant un combat.",
        ACTIVATED = "Le mode guerre a été activé ! Bonus d'XP et d'or de 10% activés.",
        ALREADY_ACTIVE = "Le mode guerre est déjà activé.",
        DEACTIVATED = "Le mode guerre a été désactivé ! Bonus retirés.",
        ALREADY_INACTIVE = "Le mode guerre est déjà désactivé.",
    },
    enUS = {
        CANT_CHANGE_IN_COMBAT = "You cannot change your War Mode while in combat.",
        ACTIVATED = "War Mode has been enabled! 10% XP and gold bonus activated.",
        ALREADY_ACTIVE = "War Mode is already enabled.",
        DEACTIVATED = "War Mode has been disabled! Bonuses removed.",
        ALREADY_INACTIVE = "War Mode is already disabled.",
    },
}

local function L(player)
    return WarModeNotif[GetPlayerLocale(player)] or WarModeNotif.frFR
end

-- Configuration
local ITEM_ID = 339830
local EXP_BONUS_AURA_ID = 57353
local WAR_MODE_AURA_1 = 40043
local WAR_MODE_AURA_2 = 41876
local GOLD_BONUS_PERCENT = 10
local EXP_BONUS_MULTIPLIER = 1.10

-- Vérifie si le joueur est en donjon ou raid
local function IsInInstance(player)
    local map = player:GetMap()
    return map:IsDungeon() or map:IsRaid()
end

-- Timer pour garder le PvP actif si War Mode est activé
local function KeepPvPActive(eventId, delay, repeats, player)
    if player:IsInWorld() and player:HasAura(EXP_BONUS_AURA_ID) then
        player:SetPvP(true)
    else
        player:RemoveEventById(eventId)
    end
end

-- Fonction pour charger l'état du War Mode
local function LoadWarModeState(player)
    local guid = player:GetGUIDLow()
    local result = CharDBQuery("SELECT warmode_active FROM player_warmode WHERE guid = " .. guid)

    if result then
        local warmode_active = result:GetUInt8(0)
        if warmode_active == 1 then
            player:SetPvP(true)
            player:AddAura(EXP_BONUS_AURA_ID, player)
            player:AddAura(WAR_MODE_AURA_1, player)
            player:AddAura(WAR_MODE_AURA_2, player)
            player:RegisterEvent(KeepPvPActive, 5000, 0)
        end
        return warmode_active == 1
    end
    return false
end

-- Fonction pour sauvegarder l'état du War Mode
local function SaveWarModeState(player)
    local guid = player:GetGUIDLow()
    local warmode_active = player:IsPvPFlagged() and 1 or 0

    CharDBExecute("INSERT INTO player_warmode (guid, warmode_active) VALUES (" .. guid .. ", " .. warmode_active .. ") " ..
                  "ON DUPLICATE KEY UPDATE warmode_active = " .. warmode_active)
end

-- Handler pour basculer le War Mode
function WarModeHandlers.ToggleWarMode(player, activate)
    if player:IsInCombat() then
        AIO.Handle(player, "WarMode", "ShowMessage", L(player).CANT_CHANGE_IN_COMBAT, true)
        return
    end

    if activate then
        -- Activer War Mode
        if not player:HasAura(EXP_BONUS_AURA_ID) then
            player:SetPvP(true)
            player:AddAura(EXP_BONUS_AURA_ID, player)
            player:AddAura(WAR_MODE_AURA_1, player)
            player:AddAura(WAR_MODE_AURA_2, player)
            player:RegisterEvent(KeepPvPActive, 5000, 0)
            SaveWarModeState(player)
            AIO.Handle(player, "WarMode", "UpdateStatus", true)
            AIO.Handle(player, "WarMode", "ShowMessage", L(player).ACTIVATED, false)
        else
            AIO.Handle(player, "WarMode", "ShowMessage", L(player).ALREADY_ACTIVE, true)
        end
    else
        -- Désactiver War Mode
        if player:HasAura(EXP_BONUS_AURA_ID) then
            player:SetPvP(false)
            player:RemoveAura(EXP_BONUS_AURA_ID)
            player:RemoveAura(WAR_MODE_AURA_1)
            player:RemoveAura(WAR_MODE_AURA_2)
            player:RemoveEvents()
            SaveWarModeState(player)
            AIO.Handle(player, "WarMode", "UpdateStatus", false)
            AIO.Handle(player, "WarMode", "ShowMessage", L(player).DEACTIVATED, false)
        else
            AIO.Handle(player, "WarMode", "ShowMessage", L(player).ALREADY_INACTIVE, true)
        end
    end
end

-- Handler pour demander le statut
function WarModeHandlers.RequestStatus(player)
    local isActive = player:IsPvPFlagged()
    AIO.Handle(player, "WarMode", "UpdateStatus", isActive)
end

-- Bonus d'or
local function OnLootMoney(event, player, amount)
    if player:IsPvPFlagged() and not IsInInstance(player) then
        local bonus = math.floor(amount * (GOLD_BONUS_PERCENT / 100))
        player:ModifyMoney(bonus)
    end
    return amount
end

-- Bonus d'expérience
local function OnReceiveExp(event, player, amount, victim)
    if player:IsPvPFlagged() and not IsInInstance(player) then
        return math.floor(amount * EXP_BONUS_MULTIPLIER)
    end
    return amount
end

-- Maintenir PvP lors du changement de map
local function OnChangeMap(event, player)
    if player:HasAura(EXP_BONUS_AURA_ID) then
        player:SetPvP(true)
        player:RegisterEvent(KeepPvPActive, 5000, 0)
    end
end

-- Login
local function OnPlayerLogin(event, player)
    if player:GetItemCount(ITEM_ID) == 0 then
        player:AddItem(ITEM_ID, 1)
    end

    local isActive = LoadWarModeState(player)
    AIO.Handle(player, "WarMode", "Initialize", isActive)
end

-- Logout
local function OnPlayerLogout(event, player)
    SaveWarModeState(player)
    player:RemoveEvents()
end

-- Commande pour ouvrir l'interface
local function OnPlayerCommand(event, player, command)
    if command == "warmode" or command == "wm" then
        AIO.Handle(player, "WarMode", "ShowPanel")
        return false
    end
end

-- Enregistrement des événements
RegisterPlayerEvent(3, OnPlayerLogin)
RegisterPlayerEvent(4, OnPlayerLogout)
RegisterPlayerEvent(37, OnLootMoney)
RegisterPlayerEvent(12, OnReceiveExp)
RegisterPlayerEvent(28, OnChangeMap)
RegisterPlayerEvent(42, OnPlayerCommand)

-- Gossip pour l'item
local function OnItemGossipHello(event, player, item)
    AIO.Handle(player, "WarMode", "ShowPanel")
end

RegisterItemGossipEvent(ITEM_ID, 1, OnItemGossipHello)