local function SetPlayerPhase(player, newPhase)
    player:SetPhaseMask(newPhase)
    player:SaveToDB()
end

local function SetGroupPhase(player, newPhase)
    local group = player:GetGroup()

    if group then
        for _, groupMember in ipairs(group:GetMembers()) do
            SetPlayerPhase(groupMember, newPhase)
        end
    else
        SetPlayerPhase(player, newPhase)
    end
end

local function OnCreatureKill(event, player, creature)
    if player:GetMapId() == 779 then
        local monsterId = 63035
        if creature:GetEntry() == monsterId then
            local currentPhase = player:GetPhaseMask()
            local newPhase = currentPhase * 2

            -- Appliquer le changement de phase à tout son groupe (s'il est dans un groupe)
            SetGroupPhase(player, newPhase)
        end
    end
end

RegisterPlayerEvent(7, OnCreatureKill)
