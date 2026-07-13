local function GrantTalentPointsOnLevelUp(event, player, oldLevel)
    local level = player:GetLevel()
    local pointsToGrant = 0

    -- Points de talent dès le niveau 10
    if level >= 10 and level <= 80 then
        -- Les niveaux spécifiques où vous attribuez 1 point de talent
        -- Distribution régulière pour avoir exactement 60 points entre 10 et 80
        local talentLevels = {
            10, 12, 14, 16, 18, 20, 21, 22, 24, 26, 28, 30, 31, 32, 34, 36, 38, 
            40, 41, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 62, 64, 66, 68, 
            70, 72, 74, 76, 78, 80
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
        player:SendAreaTriggerMessage("|cff00ff00Vous avez gagné " .. pointsToGrant .. " point" .. (pointsToGrant > 1 and "s" or "") .. " de talent pour avoir atteint le niveau " .. level .. "!|r")
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
