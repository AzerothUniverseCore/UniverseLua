local AURA_SPELL_ID = 750000

local function OnLogin(event, player)
    if player:HasAura(AURA_SPELL_ID) then
        player:RemoveAura(AURA_SPELL_ID)
    end
end

RegisterPlayerEvent(3, OnLogin)
