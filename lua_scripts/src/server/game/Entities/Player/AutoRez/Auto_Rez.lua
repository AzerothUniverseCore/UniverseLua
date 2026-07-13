local SPELL_ID = 51916 -- Sort qui invoque le PNJ pour ressusciter
local MAX_RESS = 3 -- Nombre maximum de résurrections
local RESS_TIMER = 10800 -- 3 heures (en secondes) avant de récupérer les résurrections

local playerRessData = {} -- Stocke les résurrections des joueurs

function OnPlayerLogin(event, player)
    local guid = player:GetGUIDLow()

    -- Initialise les données si le joueur n'a pas encore de suivi
    if not playerRessData[guid] then
        playerRessData[guid] = {count = MAX_RESS, lastReset = os.time()}
    end

    -- Vérifie si le timer des 3 heures est écoulé pour réinitialiser les résurrections
    if os.time() - playerRessData[guid].lastReset >= RESS_TIMER then
        playerRessData[guid].count = MAX_RESS
        playerRessData[guid].lastReset = os.time()
        player:SendBroadcastMessage("|cff00ff00Vos résurrections ont été réinitialisées !|r")
    end
end

function OnKilledByCreature(event, killer, player)
    local guid = player:GetGUIDLow()
    
    -- Vérifie si le joueur est en champ de bataille ou en arène
    local map = player:GetMap()
    if map:IsBattleground() or map:IsArena() then
        player:SendBroadcastMessage("|cffff0000Les résurrections ne sont pas disponibles en champ de bataille ou en arène.|r")
        return
    end
    
    -- Vérifie si le joueur a encore des résurrections disponibles
    if playerRessData[guid] and playerRessData[guid].count > 0 then
        playerRessData[guid].count = playerRessData[guid].count - 1
        player:SendBroadcastMessage("|cffff0000Un ange vient vous sauver... Il vous reste " .. playerRessData[guid].count .. " résurrections.|r")

        -- Laisse le PNJ faire l'animation et ressusciter le joueur
        player:CastSpell(player, SPELL_ID, true)
    else
        player:SendBroadcastMessage("|cffff0000Vous avez utilisé toutes vos résurrections ! Libérez votre esprit.|r\nVos résurrections seront réinitialisées après 3 heures. Une fois ce délai écoulé, déconnectez-vous puis reconnectez votre personnage.|r")
        -- Le joueur va au cimetière normalement
    end
end

RegisterPlayerEvent(3, OnPlayerLogin) -- Déclencheur à la connexion du joueur
RegisterPlayerEvent(8, OnKilledByCreature) -- Déclencheur à la mort du joueur