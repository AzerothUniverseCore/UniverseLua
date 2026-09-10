require('sys_player_informations');

local ITEM_ID = 132747

local function OnGossipHello(event, player, item)
    local accountId = player:GetAccountId()
    local query = string.format("SELECT `rank` FROM auc_eluna.mod_account_rank WHERE accountID = %d", accountId)
    local result = CharDBQuery(query)

    if result and result:GetInt32(0) == 1 then
        player:SendBroadcastMessage("Vous êtes déjà contributeur.")
    else
		player:GossipSetText("Bonjour " .. player:GetName() .. ",\n\nEn activant votre statut de contributeur, vous bénéficierez immédiatement de nombreux avantages exclusifs, sans avoir besoin de vous déconnecter.")
        player:GossipMenuAddItem(0, "Je souhaite activer mon contributeur", 0, 1)
        player:GossipSendMenu(0x7FFFFFFF, item)
    end
end

local function ActivateContributor(player, accountId)
    local query1 = string.format("UPDATE auc_eluna.mod_account_rank SET `rank` = 1 WHERE accountID = %d", accountId)
    local query2 = string.format("INSERT INTO auc_chars.premium (AccountId, active) VALUES (%d, 1) ON DUPLICATE KEY UPDATE active = 1", accountId)

    CharDBExecute(query1)
    CharDBExecute(query2)

    for _, onlinePlayer in ipairs(GetPlayersInWorld()) do
        if onlinePlayer:GetAccountId() == accountId then
            local guidLow = onlinePlayer:GetGUIDLow()
            if not playerInformations[guidLow] then
                playerInformations[guidLow] = {}
            end
            playerInformations[guidLow].rank = 1

            if GrantContributorKit then
                GrantContributorKit(onlinePlayer)
            end
        end
    end
end

local function OnGossipSelect(event, player, item, sender, intid, code, menu_id)
    if intid == 1 then
        local accountId = player:GetAccountId()

        ActivateContributor(player, accountId)

        player:SendBroadcastMessage("Felicitations, votre statut de contributeur est desormais actif ! Vos avantages sont deja disponibles.")
        player:GossipComplete()
    end
end

RegisterItemGossipEvent(ITEM_ID, 1, OnGossipHello)
RegisterItemGossipEvent(ITEM_ID, 2, OnGossipSelect)
