local function OnCreatureKill(event, player, creature)
    if player:GetMapId() == 734 then
        local monsterId = 5102132 -- Remplacez VOTRE_MONSTRE_ID par l'ID de votre monstre
        if creature:GetEntry() == monsterId then
            local newPhase = 1 -- Remplacez VOTRE_NOUVELLE_PHASE par le numéro de phase souhaité

            local phaseMask = 1^(newPhase - 1)
            player:SetPhaseMask(phaseMask)
            player:SaveToDB()
        end
    end
end

RegisterPlayerEvent(7, OnCreatureKill) -- 7 correspond à l'événement de mort de créature
