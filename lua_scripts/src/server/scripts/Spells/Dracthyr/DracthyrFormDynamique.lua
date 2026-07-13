local SPELL_DRAGONS_FORM = 351240  -- ID du sort pour la transformation en Dracthyr

local function isDracthyr(player)
    local raceId = player:GetRace()  -- Récupère l'ID de la race du joueur
    return raceId == 28 or raceId == 29  -- Dracthyr correspond aux raceId 28 et 29
end

-- Fonction pour récupérer le displayId d'une forme Dracthyr en fonction du genre
local function GetDracthyrDisplayId(player, gender)
	-- Vérifie si le joueur est un Dracthyr avant de procéder
    if not isDracthyr(player) then
        return nil  -- Si ce n'est pas un Dracthyr, on retourne nil
    end

    -- Déterminer le genre (0 = Male, 1 = Female)
    local genderStr = gender == 0 and 'Male' or 'Female'

    -- Récupérer un displayId pour la forme Dracthyr du genre choisi
    local query = CharDBQuery(string.format("SELECT displayId FROM creature_morphs WHERE creatureType = 'Dracthyr_%s' ORDER BY RAND() LIMIT 1;", genderStr))

    if query then
        return query:GetUInt32(0)
    end

    return nil
end

-- Fonction pour sauvegarder le displayId actuel en base de données
local function SaveDracthyrDisplayId(player, displayId)
    local guid = player:GetGUIDLow()
    CharDBExecute(string.format("REPLACE INTO character_dracthyr_display (guid, displayId) VALUES (%d, %d);", guid, displayId))
end

-- Fonction pour appliquer la transformation Dracthyr
local function ApplyDracthyrMorph(player)
	-- Vérifie si le joueur est un Dracthyr avant de procéder
    if not isDracthyr(player) then
        return  -- Si ce n'est pas un Dracthyr, on ne fait rien
    end

    -- Déterminer le genre du joueur (0 = Male, 1 = Female)
    local gender = player:GetGender() -- 0 pour Male, 1 pour Female
    local displayId = GetDracthyrDisplayId(player, gender)

    if displayId then
        -- Appliquer le displayId si pas déjà appliqué
        if player:GetDisplayId() ~= displayId then
            player:SetDisplayId(displayId)
            -- Sauvegarder l'apparence actuelle du joueur dans la base de données
            SaveDracthyrDisplayId(player, displayId)
        end
    else
        -- Si aucun displayId n'est trouvé, vous pouvez afficher un message d'erreur ici
        player:SendBroadcastMessage("Erreur : Impossible de récupérer le displayId pour la forme Dracthyr.")
    end
end

-- Fonction pour charger et restaurer l'apparence du joueur à la connexion
--local function LoadDracthyrDisplayId(event, player)
--	-- Vérifie si le joueur est un Dracthyr avant de charger l'apparence
--    if not isDracthyr(player) then
--        return  -- Si ce n'est pas un Dracthyr, on ne fait rien
--    end
--
--    local guid = player:GetGUIDLow()
--    local query = CharDBQuery(string.format("SELECT displayId FROM character_dracthyr_display WHERE guid = %d;", guid))
--
--    if query then
--        local savedDisplayId = query:GetUInt32(0)
--        if savedDisplayId and savedDisplayId > 0 then
--            -- Restaurer l'apparence du joueur à son displayId sauvegardé
--            player:SetDisplayId(savedDisplayId)
--			
--			if not player:HasAura(SPELL_DRAGONS_FORM) then
--                player:CastSpell(player, SPELL_DRAGONS_FORM, true)
--            end
--        end
--    end
--end

-- Gestion du sort pour appliquer la transformation en Dracthyr
local function OnDracthyrSpellCast(event, player, spell)
    if spell:GetEntry() == SPELL_DRAGONS_FORM then
        -- Appliquer la transformation en Dracthyr
        ApplyDracthyrMorph(player)
    end
end

-- Enregistrer les événements
--RegisterPlayerEvent(3, LoadDracthyrDisplayId)  -- Quand un joueur se connecte (restaurer l'apparence)
RegisterPlayerEvent(5, OnDracthyrSpellCast)   -- Quand un joueur caste le sort Dracthyr (320555)
