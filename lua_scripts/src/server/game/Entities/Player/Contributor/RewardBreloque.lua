local REWARD_ITEM_ID = 7000655  -- ID de la Breloque supérieure
local REWARD_AMOUNT = 20       -- Nombre de points donnés
local INTERVAL = 900          -- Intervalle en secondes (15 minutes)

-- Fonction pour vérifier si un compte est premium
local function IsPremiumPlayer(player)
    local query = CharDBQuery("SELECT active FROM premium WHERE AccountId = " .. player:GetAccountId())
    if query then
        return query:GetInt32(0) == 1
    end
    return false
end

-- Fonction pour donner la récompense
local function GiveReward(eventId, delay, repeats, player)
    if IsPremiumPlayer(player) then
        player:AddItem(REWARD_ITEM_ID, REWARD_AMOUNT)
        player:SendBroadcastMessage("Vous avez reçu " .. REWARD_AMOUNT .. " Breloques supérieures pour votre fidélité !")
    end
end

-- Déclencheur lors de la connexion
local function OnPlayerLogin(event, player)
    if IsPremiumPlayer(player) then
        player:RegisterEvent(GiveReward, INTERVAL * 1000, 0, player)
    end
end

RegisterPlayerEvent(3, OnPlayerLogin)
