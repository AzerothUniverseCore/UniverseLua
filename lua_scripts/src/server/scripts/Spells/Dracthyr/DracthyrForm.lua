-- Script Lua pour TrinityCore 3.3.5
-- Attribuer un displayId unique à un joueur lors de la création et le maintenir lorsqu'il utilise le sort 320555 (Forme Dracthyr)

-- Définir l'ID du sort Forme Dracthyr
local SPELL_DRAGONS_FORM = 320555

local function isDracthyr(player)
    local raceId = player:GetRace()  -- Récupère l'ID de la race du joueur
    return raceId == 28 or raceId == 29  -- Dracthyr correspond aux raceId 28 et 29
end

-- Fonction pour attribuer un displayId unique lors de la création du personnage en fonction du genre
local function assignDracthyrDisplayId(player)
    -- Récupère le genre du joueur (0 = Male, 1 = Female)
    local gender = player:GetGender()  -- 0 pour Male, 1 pour Female
	
	-- Vérifie si le joueur est un Dracthyr
    if not isDracthyr(player) then
        return  -- Si ce n'est pas un Dracthyr, on ne fait rien
    end

    -- Déterminer le genre sous forme de chaîne (Male ou Female)
    local genderStr = gender == 0 and 'Male' or 'Female'

    -- Récupère un displayId aléatoire pour la forme Dracthyr en fonction du genre
    local query = string.format("SELECT displayId FROM creature_morphs WHERE creatureType = 'Dracthyr_%s' ORDER BY RAND() LIMIT 1", genderStr)
    local result = WorldDBQuery(query)

    if result then
        local displayId = result:GetUInt32(0)
        -- Enregistrer ce displayId pour le personnage dans la table `character_dracthyr_display`
        local guid = player:GetGUIDLow()  -- Utilise GetGUIDLow() pour obtenir la valeur du GUID en entier
        query = string.format("INSERT IGNORE INTO character_dracthyr_display (guid, displayId) VALUES (%d, %d)", guid, displayId)
        WorldDBQuery(query)

        -- Applique le displayId au joueur
        player:SetDisplayId(displayId)
    end
end

-- Fonction pour gérer le changement de display lors de l'utilisation du sort Forme Dracthyr
local function onDracthyrFormSpellCast(event, player, spell)
    -- Vérifie si le sort lancé est bien Forme Dracthyr (ID = 320555)
    if spell:GetEntry() == SPELL_DRAGONS_FORM then
	-- Vérifie si le joueur est un Dracthyr avant d'appliquer le displayId
        if not isDracthyr(player) then
            return  -- Si ce n'est pas un Dracthyr, on ne fait rien
        end
        -- Vérifie si le joueur a déjà un displayId enregistré dans la table `character_dracthyr_display`
        local guid = player:GetGUIDLow()  -- Utilise GetGUIDLow() pour obtenir la valeur du GUID en entier
        local query = string.format("SELECT displayId FROM character_dracthyr_display WHERE guid = %d", guid)
        local result = WorldDBQuery(query)

        if result then
            local displayId = result:GetUInt32(0)
            
            -- Si le displayId existe déjà, l'appliquer sans changer
            if displayId and displayId > 0 then
                player:SetDisplayId(displayId)
            else
                -- Si aucun displayId n'est trouvé, assigner un displayId aléatoire
                assignDracthyrDisplayId(player)
            end
        else
            -- Si aucun displayId n'est trouvé, assigner un displayId aléatoire
            assignDracthyrDisplayId(player)
        end
    end
end

-- Événement pour la création d'un joueur
local function onPlayerCreate(event, player)
-- Vérifie si le joueur est un Dracthyr avant d'attribuer un displayId
    if isDracthyr(player) then
    -- Appeler la fonction pour assigner un displayId unique lors de la création du personnage
    assignDracthyrDisplayId(player)
	end
end

local function onPlayerLogin(event, player)
-- Vérifie si le joueur est un Dracthyr avant d'attribuer un displayId
    if isDracthyr(player) then
    local guid = player:GetGUIDLow()
    local query = string.format("SELECT displayId FROM character_dracthyr_display WHERE guid = %d", guid)
    local result = WorldDBQuery(query)

    if result then
        local displayId = result:GetUInt32(0)
        if displayId and displayId > 0 then
            player:SetDisplayId(displayId)
			
			if not player:HasAura(SPELL_DRAGONS_FORM) then
                    player:CastSpell(player, SPELL_DRAGONS_FORM, true)
                end
			end
		end
	end
end

RegisterPlayerEvent(3, onPlayerLogin)  -- 3 = PLAYER_EVENT_ON_LOGIN

-- Inscription des événements
RegisterPlayerEvent(3, onPlayerCreate)  -- 3 correspond à l'événement PLAYER_EVENT_ON_LOGIN, ce qui est aussi un événement lors de la création
RegisterPlayerEvent(5, onDracthyrFormSpellCast)  -- 5 correspond à l'événement PLAYER_EVENT_ON_SPELL_CAST
