-- ID du sort à bloquer
local SPELL_ID = 44795

-- Intervalle périodique (en millisecondes) pour vérifier si le joueur a le sort actif
local CHECK_INTERVAL = 1000

-- Fonction appelée lorsqu'un joueur se connecte
local function OnLogin(event, player)
    -- Supprime le sort du joueur s'il est actif
    if player:HasAura(SPELL_ID) then
        player:RemoveAura(SPELL_ID)
        -- player:SendBroadcastMessage("Le sort 44795 est bloqué sur ce serveur.")
    end

    -- Démarre une vérification périodique
    player:RegisterEvent(function(eventId, delay, repeats, player)
        if player:HasAura(SPELL_ID) then
            player:RemoveAura(SPELL_ID)
            player:SendBroadcastMessage("Le sort 44795 a été supprimé.")
        end
    end, CHECK_INTERVAL)
end

-- Fonction appelée lorsqu'un joueur tente de lancer un sort
local function OnCastSpell(event, player, spell, skipCheck)
    if spell:GetEntry() == SPELL_ID then
        spell:Cancel() -- Annule le lancement du sort
        -- player:SendBroadcastMessage("Vous ne pouvez pas lancer le sort 44795 sur ce serveur.")
        return false -- Bloque l'exécution
    end
end

-- Enregistrement des événements
RegisterPlayerEvent(3, OnLogin) -- Événement 3 : Connexion du joueur
RegisterPlayerEvent(5, OnCastSpell) -- Événement 5 : Tentative de lancer un sort
