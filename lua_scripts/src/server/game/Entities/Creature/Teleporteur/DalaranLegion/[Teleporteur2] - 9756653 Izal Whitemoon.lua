local UnitEntry = 9756653

local SPELL_LAUNCH = 66797  -- Poussee de la mort
local SPELL_GLIDE  = 131347 -- Glide

local GOSSIP_OPTION = "Pret a decoller !"
local TALK_TEXT      = "Prepare toi a te diriger vers le portail Legion ! Bon vol !"

local GLIDE_KEEPALIVE_INTERVAL  = 300
local GLIDE_KEEPALIVE_MAX_TICKS = 40

local function onGlideKeepAlive(eventId, delay, repeats, player)
    if not player or not player:IsInWorld() then
        return
    end

    if not player:IsFalling() then
        player:RemoveEventById(eventId)
        return
    end

    if not player:HasAura(SPELL_GLIDE) then
        player:AddAura(SPELL_GLIDE, player)
    end
end

local function OnGossipHello(event, player, unit)
    player:GossipMenuAddItem(0, GOSSIP_OPTION, 1, 1)
    player:GossipSendMenu(1, unit)
    return true
end

local function OnGossipSelect(event, player, unit, sender, intid, code)
    player:GossipComplete()

    if (intid == 1) then
        unit:SendChatMessageToPlayer(12, 0, TALK_TEXT, player)

        unit:CastSpell(player, SPELL_LAUNCH, true)
        unit:AddAura(SPELL_GLIDE, player)

        player:RegisterEvent(onGlideKeepAlive, GLIDE_KEEPALIVE_INTERVAL, GLIDE_KEEPALIVE_MAX_TICKS)
    end

    return true
end

RegisterCreatureGossipEvent(UnitEntry, 1, OnGossipHello)
RegisterCreatureGossipEvent(UnitEntry, 2, OnGossipSelect)
