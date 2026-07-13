--[[
    StartingHeirloomCurrency.lua
    ------------------------------------------------------------
    Donne automatiquement 500 Eclats du gardien (item 43228) à
    chaque nouveau personnage, lors de sa toute première connexion
    (juste après la création).

    Fonctionnement :
    Eluna ne possède pas d'événement "ON_CHARACTER_CREATE" direct
    pour les joueurs. La technique standard consiste à écouter
    PLAYER_EVENT_ON_LOGIN et à vérifier le temps de jeu total du
    personnage via GetTotalPlayedTime(). Sur un personnage tout
    juste créé, cette valeur vaut 0 lors de la toute première
    connexion (et uniquement à ce moment-là), ce qui permet de
    détecter la création de façon fiable sans avoir besoin d'une
    table SQL supplémentaire.
------------------------------------------------------------]]

local GUARDIAN_SHARD_ITEM_ID = 43228   -- Eclat du gardien des pierres
local STARTING_SHARD_AMOUNT  = 500     -- Quantité offerte à la création

local function OnFirstLogin(event, player)
    -- GetTotalPlayedTime() == 0 uniquement lors de la toute première
    -- connexion du personnage, immédiatement après sa création.
    if player:GetTotalPlayedTime() ~= 0 then
        return
    end

    local added = player:AddItem(GUARDIAN_SHARD_ITEM_ID, STARTING_SHARD_AMOUNT)

    if added then
        player:SendBroadcastMessage(
            "|cff00ff00Bienvenue ! Vous avez reçu " .. STARTING_SHARD_AMOUNT ..
            " Eclats du gardien pour débuter votre collection d'héritages.|r"
        )
    else
        -- Cas très improbable au tout premier login (sacs quasi vides),
        -- mais on couvre le cas d'un sac plein par sécurité.
        player:SendBroadcastMessage(
            "|cffff0000Impossible de vous donner vos Eclats du gardien de bienvenue : sacs pleins.|r"
        )
    end
end

RegisterPlayerEvent(3, OnFirstLogin) -- 3 = PLAYER_EVENT_ON_LOGIN
