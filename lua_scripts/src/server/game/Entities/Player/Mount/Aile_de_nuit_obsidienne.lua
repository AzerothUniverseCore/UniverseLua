local function onCast(event, player, spell, skipCheck)
  if (spell:GetEntry() == 121820) then
    player:CastSpell(player, 42917, true);
  end
end
RegisterPlayerEvent(5, onCast)
