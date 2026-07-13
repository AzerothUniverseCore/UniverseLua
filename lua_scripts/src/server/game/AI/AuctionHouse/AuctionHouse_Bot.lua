-- Credits Mithras & Niam5 for code functions --

local auctionConfig = {
    auctionWebhookURL = "https://discord.com/api/webhooks/1341951257186926695/WAx1R6fe9Mpj23daXnOWTBi_4rabqPHXYwKer3NJLbViZ6Ry3LZ6T3YpP_9RiHqlYAQb",
    lastCheckedTimestamp = 0
}

local function SendDiscordEmbed(title, description, color, webhookURL)
    local jsonData = string.format([[
    {
        "embeds": [{
            "title": "%s",
            "description": "%s",
            "color": %d
        }]
    }]], title, description, color)

    local curlCommand = 'curl -X POST -H "Content-Type: application/json" -d @- '..webhookURL
    local curlProcess = io.popen(curlCommand, 'w')
    curlProcess:write(jsonData)
    curlProcess:close()
end

local function ConvertCopperToGoldSilverCopper(copper)
    local gold = math.floor(copper / 10000)
    local remaining = copper % 10000
    local silver = math.floor(remaining / 100)
    local remainingCopper = remaining % 100
    return gold, silver, remainingCopper
end

local function ConvertSecondsToReadableTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    return hours, minutes
end

local function OnAuctionAdd(event, auctionId, owner, item, expireTime, buyout, startBid, currentBid, bidderGUIDLow)
    local remainingTime = expireTime - os.time()
    local itemCount = item:GetCount()

    -- Convertir les prix en gold/silver/copper
    local goldBid, silverBid, copperBid = ConvertCopperToGoldSilverCopper(startBid)
    local goldBuyout, silverBuyout, copperBuyout = ConvertCopperToGoldSilverCopper(buyout)

    -- Formater les prix
    local priceStringBid = string.format("%d🪙 %02d🥈 %02d🥉", goldBid, silverBid, copperBid)
    local priceStringBuyout = string.format("%d🪙 %02d🥈 %02d🥉", goldBuyout, silverBuyout, copperBuyout)

    -- Temps restant
    local hours, minutes = ConvertSecondsToReadableTime(remainingTime)
    local timeString = remainingTime > 0 and string.format("%d heures %d minutes", hours, minutes) or "Vente terminée"

    -- Définir le titre et la description de l'embed
    local embedTitle = string.format("📢 Nouvelle enchère par %s !", owner:GetName())
    local embedDescription

    if buyout >= 1 then
        embedDescription = string.format("🛒 **Objet** : [%s] x%d\n💰 **Mise de départ** : %s\n⚡ **Prix d'achat immédiat** : %s\n⏳ **Temps restant** : %s", 
                                         item:GetName(), itemCount, priceStringBid, priceStringBuyout, timeString)
    else
        embedDescription = string.format("🛒 **Objet** : [%s] x%d\n💰 **Mise de départ** : %s\n⏳ **Temps restant** : %s", 
                                         item:GetName(), itemCount, priceStringBid, timeString)
    end

    -- Envoyer l'embed
    SendDiscordEmbed(embedTitle, embedDescription, 15158332, auctionConfig.auctionWebhookURL) -- Couleur rouge
end

-- Register the event handler for AUCTION_EVENT_ON_ADD
RegisterServerEvent(26, OnAuctionAdd)
