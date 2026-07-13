require('sys_player_informations');

--[[
  playerInformations[player:GetGUIDLow()] = {
    rank,
    expRate,
    isSesam;
  }
]]--

-- System
  local function OnReceiveExp(event, player, amount, victim)
    return amount * playerInformations[player:GetGUIDLow()].expRate;
  end
  RegisterPlayerEvent(12, OnReceiveExp)
