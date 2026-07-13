-- Script Lua pour TrinityCore 3.3.5
-- Vérifie régulièrement si le joueur perd le buff "Forme Dracthyr" (ID 320555)
-- Si oui, retire "Survoler" (ID 320556)

local BUFF_FORME_DRACTHYR = 320555
local SPELL_SURVOLER = 320556

-- Fonction appelée périodiquement pour tous les joueurs
function CheckAuras(event, delay, repeats, player)
    -- Vérifie si le joueur est en ligne
    if not player:IsInWorld() then
        return
    end

    -- Vérifie si le joueur n'a plus l'aura "Forme Dracthyr"
    if not player:HasAura(BUFF_FORME_DRACTHYR) then
        -- Vérifie si le joueur a encore l'aura "Survoler"
        if player:HasAura(SPELL_SURVOLER) then
            -- Retire l'aura "Survoler"
            player:RemoveAura(SPELL_SURVOLER)
        end
    end
end

-- Enregistrement de la vérification pour chaque joueur, toutes les 2 secondes
function StartAuraCheck(event, player)
    -- Lance une vérification périodique des auras pour ce joueur
    player:RegisterEvent(CheckAuras, 1000, 0) -- 1000ms = 2 secondes, 0 = répétition infinie
end

-- Supprime la vérification si le joueur se déconnecte
function StopAuraCheck(event, player)
    player:RemoveEvents()
end

-- Enregistrement des événements de connexion et déconnexion
RegisterPlayerEvent(3, StartAuraCheck) -- À la connexion du joueur
RegisterPlayerEvent(4, StopAuraCheck) -- À la déconnexion du joueur
