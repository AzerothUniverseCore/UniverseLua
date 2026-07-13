local ItemId = 9017;
local MenuId = 90017;

local function PremiumOnLogin(event, player)  -- Envoyez un massage de bienvenue au joueur et dites-lui qu'il est premium ou non.
    local result = CharDBQuery("SELECT AccountId FROM premium WHERE active=1 and AccountId = "..player:GetAccountId())
    if (result) then
        player:SendBroadcastMessage("|cffffff00[Contributeur]|r|CFFFE8A0E Bonjour "..player:GetName().." N'oubliez pas de voter toutes les 3 heures ! C'est bien pour nous, et il parait que ça rajeunis les joueurs. |r")
    else
        player:SendBroadcastMessage("|CFFE55BB0[Voteur]|r|CFFFE8A0E Bonjour "..player:GetName().." N'oubliez pas de voter toutes les 3 heures ! C'est bien pour nous, et il parait que ça rajeunis les joueurs. |r")
    end
end

local function PremiumOnChat(event, player, msg, _, lang)
    local result = CharDBQuery("SELECT AccountId FROM premium WHERE active=1 and AccountId = "..player:GetAccountId())
    if (msg == "#premium") then  -- Use #premium for sending the gossip menu
        if (result) then
            OnPremiumHello(event, player)
        else
            player:SendBroadcastMessage("|CFFE55BB0[Premium]|r|CFFFE8A0E Désoler "..player:GetName().." vous n'êtes pas contributeur chez Azeroth Universe ! |r")
        end
    end
end

function OnPremiumHello(event, player)
    player:GossipClearMenu()
    player:GossipMenuAddItem(0, "Banque", 0, 3)
    player:GossipMenuAddItem(0, "Hôtel des ventes", 0, 4)
	-- player:GossipMenuAddItem(0, "Vendeur", 0, 5)
    player:GossipMenuAddItem(0, "Fermer", 0, 1)
    -- Room for more premium things
    player:GossipSendMenu(1, player, 100)
end

function OnPremiumSelect(event, player, _, sender, intid, code)
    if (intid == 1) then                     -- Close the Gossip
        player:GossipComplete()
    elseif (intid == 2) then                 -- Go back to main menu
        OnPremiumHello(event, player)
    elseif (intid == 3) then                 -- Send Bank Window
        player:SendShowBank(player)
    elseif (intid == 4) then                 -- Send Auctions Window
        player:SendAuctionMenu(player)
	elseif (intid == 5) then                 -- Send Auctions Window
        player:SendAuctionMenu(player)
    end
    -- Room for more premium things
end

RegisterPlayerEvent(3, PremiumOnLogin)              -- Register Event On Login
RegisterPlayerEvent(18, PremiumOnChat)              -- Register Evenet on Chat Command use
RegisterPlayerGossipEvent(100, 2, OnPremiumSelect)  -- Register Event for Gossip Select
RegisterItemGossipEvent(ItemId, 1, OnPremiumHello);
RegisterItemGossipEvent(ItemId, 2, OnPremiumSelect);
