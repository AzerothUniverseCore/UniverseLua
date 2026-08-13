-- Script Lua pour TrinityCore 3.3.5
-- Vérifie régulièrement l'état du buff "Forme Dracthyr" (ID 320555) :
--   - tant qu'il est actif, accorde "Survoler" (ID 320556) et "Vol" (ID 320570)
--   - dès qu'il disparaît, retire les deux

local BUFF_FORME_DRACTHYR = 320555
local SPELL_SURVOLER = 320556
local SPELL_VOL = 320570 -- Envol, +350% vitesse de vol en forme Dracthyr

-- Auras qui doivent exister UNIQUEMENT tant que la forme Dracthyr est
-- active : accordées si elle est présente, retirées si elle ne l'est plus
-- (ajoute d'autres IDs ici si besoin).
local DEPENDENT_AURAS = { SPELL_SURVOLER, SPELL_VOL }

-- Fonction appelée périodiquement pour tous les joueurs
function CheckAuras(event, delay, repeats, player)
    -- Vérifie si le joueur est en ligne
    if not player:IsInWorld() then
        return
    end

    if player:HasAura(BUFF_FORME_DRACTHYR) then
        -- Toujours en forme Dracthyr : s'assure que les auras dépendantes
        -- sont bien présentes (les accorde si elles manquent).
        for _, spellId in ipairs(DEPENDENT_AURAS) do
            if not player:HasAura(spellId) then
                player:AddAura(spellId, player)
            end
        end
    else
        -- Plus en forme Dracthyr : retire toutes les auras qui en dépendent.
        for _, spellId in ipairs(DEPENDENT_AURAS) do
            if player:HasAura(spellId) then
                player:RemoveAura(spellId)
            end
        end
    end
end

-- Enregistrement de la vérification pour chaque joueur, toutes les secondes
function StartAuraCheck(event, player)
    -- Lance une vérification périodique des auras pour ce joueur
    player:RegisterEvent(CheckAuras, 1000, 0) -- 1000ms = 1 seconde, 0 = répétition infinie
end

-- Supprime la vérification si le joueur se déconnecte
function StopAuraCheck(event, player)
    player:RemoveEvents()
end

-- Enregistrement des événements de connexion et déconnexion
RegisterPlayerEvent(3, StartAuraCheck) -- À la connexion du joueur
RegisterPlayerEvent(4, StopAuraCheck) -- À la déconnexion du joueur
