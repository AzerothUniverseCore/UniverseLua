-- Importation des fonctions Lua de TrinityCore
local SPELL_TO_CAST = 320553 -- ID du sort principal
local SPELL_TO_APPLY = 320555 -- ID du sort à lancer automatiquement

-- Fonction qui se déclenche lorsqu'un joueur lance un sort
local function OnSpellCast(event, player, spell, skipCheck)
    -- Vérifie si le sort lancé est le sort principal
    if spell:GetEntry() == SPELL_TO_CAST then
        -- Vérifie si le joueur a déjà le buff du sort secondaire
        if not player:HasAura(SPELL_TO_APPLY) then
            -- Lance le sort secondaire sur le joueur
            player:CastSpell(player, SPELL_TO_APPLY, true)
        end
    end
end

-- Enregistre l'événement pour surveiller les lancers de sorts
RegisterPlayerEvent(5, OnSpellCast)
