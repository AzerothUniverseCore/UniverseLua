local function onCast(event, player, spell, skipCheck)
  if (spell:GetEntry() == 294197) then
    player:CastSpell(player, 2120, true);
  end
end
RegisterPlayerEvent(5, onCast)
