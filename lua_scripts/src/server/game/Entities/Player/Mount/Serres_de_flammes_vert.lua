local function onCast(event, player, spell, skipCheck)
  if (spell:GetEntry() == 200014) then
    player:CastSpell(player, 48020, true);
  end
end
RegisterPlayerEvent(5, onCast)
