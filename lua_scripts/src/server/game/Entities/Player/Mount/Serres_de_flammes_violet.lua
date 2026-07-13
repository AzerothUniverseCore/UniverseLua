local function onCast(event, player, spell, skipCheck)
  if (spell:GetEntry() == 200013) then
    player:CastSpell(player, 32712, true);
  end
end
RegisterPlayerEvent(5, onCast)
