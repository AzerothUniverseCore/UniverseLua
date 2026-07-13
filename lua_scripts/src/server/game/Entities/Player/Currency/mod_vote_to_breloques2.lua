local function onLogin(event, player)
  local getVP = CharDBQuery('SELECT vp FROM auc_website.users WHERE username = "'..player:GetAccountName()..'";')
  
  -- Vérifier si la requête a retourné des résultats
  if getVP then
    if getVP:GetUInt32(0) > 1 then
      local dp = math.floor((getVP:GetUInt32(0) / 1))
      local setVP = CharDBQuery('UPDATE auc_website.users SET vp = 0, dp = dp + '..dp..' WHERE username = "'..player:GetAccountName()..'";')
    end
  end
end
RegisterPlayerEvent(3, onLogin)
