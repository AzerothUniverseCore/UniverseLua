function New_Char(event, player)
    SendWorldMessage("Nous souhaitons la bienvenue à " .. player:GetName() .. ", notre nouveau joueur sur Azeroth Universe !", 2)
end

RegisterPlayerEvent(30, New_Char)
