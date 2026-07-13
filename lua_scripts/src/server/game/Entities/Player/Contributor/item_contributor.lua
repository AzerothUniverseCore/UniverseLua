local ITEM_ID = 132747 -- Remplacez par l'ID réel de l'item

local function OnGossipHello(event, player, item)
    local accountId = player:GetAccountId()
    local query = string.format("SELECT rank FROM auc_eluna.mod_account_rank WHERE accountID = %d", accountId)
    local result = CharDBQuery(query)
    
    if result and result:GetInt32(0) == 1 then
        player:SendBroadcastMessage("Vous êtes déjà contributeur.")
    else
		player:GossipSetText("Bonjour " .. player:GetName() .. ",\n\nEn activant votre statut de contributeur, vous bénéficierez de nombreux avantages exclusifs.\n\n*|cff8000ffVous serez déconnecté lors de la procédure, et vous devrez vous reconnecter une seconde fois après l'activation pour que les bonus prennent effet, y compris pour les nouveaux personnages créés.|r*")
        player:GossipMenuAddItem(0, "Je souhaite activer mon contributeur", 0, 1)
        player:GossipSendMenu(0x7FFFFFFF, item)
    end
end

local function DelayedUpdate(eventId, delay, repeats, accountId)
    local query1 = string.format("UPDATE auc_eluna.mod_account_rank SET rank = 1 WHERE accountID = %d", accountId)
    local query2 = string.format("INSERT INTO auc_chars.premium (AccountId, active) VALUES (%d, 1) ON DUPLICATE KEY UPDATE active = 1", accountId)
    
    CharDBExecute(query1)
    CharDBExecute(query2)
end

local function OnGossipSelect(event, player, item, sender, intid, code, menu_id)
    if intid == 1 then
        local accountId = player:GetAccountId()
        
        player:SendBroadcastMessage("Vous allez être déconnecté pour l'activation de votre statut de contributeur.")
        player:KickPlayer()
        
        CreateLuaEvent(function() DelayedUpdate(0, 0, 0, accountId) end, 1000, 1)
    end
end

RegisterItemGossipEvent(ITEM_ID, 1, OnGossipHello)
RegisterItemGossipEvent(ITEM_ID, 2, OnGossipSelect)