local function OnPlayerLogin(event, player)
    local race = player:GetRace()
    local gender = player:GetGender()

    -- Vérifiez si le personnage est un Worgen (race 12 uniquement)
    if race == 12 then -- ID de la race Worgen (12)
        local spellId
        if gender == 0 then -- Masculin
            spellId = 68995 -- ID du sort pour les mâles
        elseif gender == 1 then -- Féminin
            spellId = 68996 -- ID du sort pour les femelles
        end

        -- Apprenez le sort au joueur
        if spellId then
            player:LearnSpell(spellId)
        end
    end
end

RegisterPlayerEvent(3, OnPlayerLogin)
