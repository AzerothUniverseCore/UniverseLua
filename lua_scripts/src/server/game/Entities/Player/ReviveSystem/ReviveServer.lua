local AIO = AIO or require("AIO")

if AIO.IsMainState and not AIO.IsMainState() then
    return
end

----------------------------------------------------------------------------
-- CONFIGURATION
----------------------------------------------------------------------------
local REVIVE_HANDLER_NAME   = "Revive"
local REVIVE_MAX_CHARGES    = 10       -- nombre de resurrections avant reinitialisation
local REVIVE_RESET_MINUTES  = 30       -- delai de reinitialisation des charges (minutes)
local REVIVE_HEALTH_PERCENT = 100      -- % de vie/mana rendu a la resurrection
local REVIVE_RESS_SICKNESS  = false    -- applique la maladie de resurrection
----------------------------------------------------------------------------

local REVIVE_RESET_SECONDS = REVIVE_RESET_MINUTES * 60

local charges = {}

local function GetCharges(guidLow)
    local data = charges[guidLow]
    local now = os.time()

    if not data or now >= data.resetAt then
        data = { count = REVIVE_MAX_CHARGES, resetAt = now + REVIVE_RESET_SECONDS }
        charges[guidLow] = data
    end

    return data
end

local function SendStatus(player)
    local data = GetCharges(player:GetGUIDLow())
    local secondsLeft = data.resetAt - os.time()
    AIO.Handle(player, REVIVE_HANDLER_NAME, "UpdateStatus", data.count, secondsLeft, REVIVE_MAX_CHARGES)
end

local ReviveHandlers = AIO.AddHandlers(REVIVE_HANDLER_NAME, {})

function ReviveHandlers.RequestStatus(player)
    if not player then return end
    SendStatus(player)
end

function ReviveHandlers.RequestRevive(player)
    if not player then return end

    if player:IsAlive() then
        AIO.Handle(player, REVIVE_HANDLER_NAME, "ReviveResult", false, "ALIVE")
        return
    end

    local data = GetCharges(player:GetGUIDLow())

    if data.count <= 0 then
        AIO.Handle(player, REVIVE_HANDLER_NAME, "ReviveResult", false, "NO_CHARGES")
        SendStatus(player)
        return
    end

    data.count = data.count - 1

    player:ResurrectPlayer(REVIVE_HEALTH_PERCENT, REVIVE_RESS_SICKNESS)
    player:SpawnBones()

    AIO.Handle(player, REVIVE_HANDLER_NAME, "ReviveResult", true)
    SendStatus(player)
end

local function OnLogin(event, player)
    SendStatus(player)
end
RegisterPlayerEvent(3, OnLogin)
