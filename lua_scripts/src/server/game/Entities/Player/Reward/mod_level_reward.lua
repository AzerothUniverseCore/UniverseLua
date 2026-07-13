local function onLevelUP(event, player)
  player:SendNotification('|CFF22A000Félicitation vous avez montez un niveau!\n\nVous êtes désormais niveau '..player:GetLevel()..'!')
  if (player:GetLevel()  == 10) or (player:GetLevel()  == 20) or (player:GetLevel()  == 30) or (player:GetLevel()  == 40) or (player:GetLevel()  == 50) or (player:GetLevel()  == 60) or (player:GetLevel()  == 70) or (player:GetLevel()  == 80) or (player:GetLevel()  == 90) then
    player:ModifyMoney(player:GetLevel()*10000)
    return false;
  end
end
