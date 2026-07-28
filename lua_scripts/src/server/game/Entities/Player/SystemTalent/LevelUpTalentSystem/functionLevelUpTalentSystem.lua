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

        -- Détecte la langue du client (index numérique côté serveur Eluna : 0 = enUS, 2 = frFR, etc.)
        local locale = player:GetDbcLocale()
        local pointWord = pointsToGrant > 1 and "points" or "point"

        -- Table des traductions, indexée par LocaleConstant
        local localizedTexts = {
            [0] = "|cff00ff00You have gained " .. pointsToGrant .. " talent " .. pointWord .. " for reaching level " .. level .. "!|r",       -- enUS
            [2] = "|cff00ff00Vous avez gagné " .. pointsToGrant .. " " .. pointWord .. " de talent pour avoir atteint le niveau " .. level .. "!|r", -- frFR
        }

        -- Récupère le texte correspondant à la langue actuelle ou par défaut en anglais
        local message = localizedTexts[locale] or localizedTexts[0]

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
