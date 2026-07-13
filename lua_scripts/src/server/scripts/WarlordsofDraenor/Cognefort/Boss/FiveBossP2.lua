local function OnCreatureKill(event, player, creature)
    if player:GetMapId() == 734 then
        local monsterId = 5101132
        if creature:GetEntry() == monsterId then
            local currentPhase = player:GetPhaseMask()
            local newPhase = currentPhase * 2

            player:SetPhaseMask(newPhase)
            player:SaveToDB()
        end
    end
end

RegisterPlayerEvent(7, OnCreatureKill)
