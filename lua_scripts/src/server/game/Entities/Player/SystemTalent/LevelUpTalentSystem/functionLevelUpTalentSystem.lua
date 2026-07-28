local function GrantTalentPointsOnLevelUp(event, player, oldLevel)
    local level = player:GetLevel()
    local pointsToGrant = 0

    -- Points de talent dès le niveau 10
    if level >= 10 and level <= 90 then
        -- Les niveaux spécifiques où vous attribuez 1 point de talent
        -- Distribution régulière pour avoir exactement 60 points entre 10 et 90
        local talentLevels = {
            10, 12, 13, 15, 16, 17, 19, 20, 21, 23, 24, 25, 27, 28, 29, 31,
            32, 33, 35, 36, 37, 39, 40, 42, 43, 44, 46, 47, 48, 50, 51, 52,
            54, 55, 56, 58, 59, 60, 62, 63, 64, 66, 67, 69, 70, 71, 73, 74,
            75, 77, 78, 79, 81, 82, 83, 85, 86, 87, 89, 90
        }

        -- Vérifiez si le niveau actuel est dans la liste des niveaux avec points de talent
        if table.contains(talentLevels, level) then
            pointsToGrant = 1
        end
    end

    -- Si des points doivent être accordés
    if pointsToGrant > 0 then
        for i = 1, pointsToGrant do
            player:AddItem(338404, 1)  -- Remplacer par l'ID d'objet correspondant
        end

        -- Détection de la locale du joueur (LOCALE_frFR = 2, sinon on retombe sur enUS)
        local locale = player:GetSession():GetSessionDbcLocale()
        local pointWord = pointsToGrant > 1 and "points" or "point"
        local message

        if locale == LOCALE_frFR then
            message = "|cff00ff00Vous avez gagné " .. pointsToGrant .. " " .. pointWord .. " de talent pour avoir atteint le niveau " .. level .. "!|r"
        else
            message = "|cff00ff00You have gained " .. pointsToGrant .. " talent " .. pointWord .. " for reaching level " .. level .. "!|r"
        end

        player:SendAreaTriggerMessage(message)
    end
end

-- Fonction pour vérifier si un tableau contient un élément
function table.contains(tbl, val)
    for i = 1, #tbl do
        if tbl[i] == val then
            return true
        end
    end
    return false
end

RegisterPlayerEvent(13, GrantTalentPointsOnLevelUp)
