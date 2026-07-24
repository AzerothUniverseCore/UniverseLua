-- The below config options can be changed to suit your needs.
-- Anything not in the config options requires changes to the code below,
-- do so at your own discretion.

local CONFIG = {
	maxLevel = 80, -- Character max level of server
	mailSenderGUID = 1, -- GUID of the character shown as sender of purchase mails
}

-- Bilingual frFR/enUS player-facing messages. Locale is resolved per-player via
-- GetPlayerLocale(player) (defined in Store_DataStruct.lua, reads account.locale),
-- with an automatic fallback to frFR if the DB lookup fails or the language isn't handled.
local StoreNotif = {
	frFR = {
		INSUFFICIENT_FUNDS = "Vous n'avez pas assez de %s|r",
		ALREADY_KNOWN_MOUNT = "Vous avez déjà cette monture",
		ALREADY_KNOWN_PET = "Vous avez déjà cette mascotte",
		ALREADY_KNOWN_TITLE = "Vous avez déjà ce titre",
		TOO_HIGH_LEVEL = "Votre niveau est trop élevé",
		MAIL_SUBJECT = "Achat de : %s",
		MAIL_BODY = "Merci pour votre achat !",
		PURCHASE_CONFIRMED = "%s Achat confirmé !",
	},
	enUS = {
		INSUFFICIENT_FUNDS = "You do not have enough %s|r",
		ALREADY_KNOWN_MOUNT = "You already know this mount",
		ALREADY_KNOWN_PET = "You already know this pet",
		ALREADY_KNOWN_TITLE = "You already have this title",
		TOO_HIGH_LEVEL = "Your level is too high",
		MAIL_SUBJECT = "Purchase of: %s",
		MAIL_BODY = "Thank you for your purchase!",
		PURCHASE_CONFIRMED = "%s Purchase confirmed!",
	},
}

local function L(player)
	return StoreNotif[GetPlayerLocale(player)] or StoreNotif.frFR
end

-- Picks the name/tooltip field in the right language from a cache row (service or
-- currency) that still carries the extra trailing _en fields (i.e. the RAW cache,
-- not a BuildLocalized*Data() copy). Falls back to the frFR value if no enUS text
-- was provided for that row.
local function LocalizedField(player, row, frIndex, enIndex)
	if GetPlayerLocale(player) == "enUS" and row[enIndex] and row[enIndex] ~= "" then
		return row[enIndex]
	end
	return row[frIndex]
end

--------------------

local AIO = AIO or require("AIO") and require("Store_DataStruct")

local CURRENCY_TYPES = {
	[1] = "GOLD",
	[2] = "ITEM_TOKEN",
	[3] = "SERVER_HANDLED"
}

local SHOP_UI = {
	serviceHandlers = {
		[1] = "ItemHandler", 		-- Okay
		[2] = "GoldHandler", 		-- Okay
		[3] = "MountHandler",		-- Okay
		[4] = "PetHandler",  		-- Okay
		[5] = "BuffHandler", 		-- Okay
		[6] = "UnusedHandler",		-- UNUSED
		[7] = "ServiceHandler", 	-- Okay
		[8] = "LevelHandler", 		-- Okay
		[9] = "TitleHandler",		-- Okay
	}
}

local KEYS = GetDataStructKeys();

local StoreHandler = AIO.AddHandlers("STORE_SERVER", {})

function StoreHandler.FrameData(player)
	local locale = GetPlayerLocale(player)
	AIO.Handle(player, "STORE_CLIENT", "FrameData", BuildLocalizedServiceData(locale), GetLinkData(), BuildLocalizedNavData(locale), BuildLocalizedCurrencyData(locale), player:GetGMRank())
end

function StoreHandler.UpdateCurrencies(player)
	local tmp = {}
	for currencyId, currency in pairs(GetCurrencyData()) do
		local val = 0
		local currencyTypeText = CURRENCY_TYPES[currency[KEYS.currency.currencyType]]
		
		-- Handle the different currency types
		if(currencyTypeText == "GOLD") then
			val = math.floor(player:GetCoinage() / 10000)
		end
		
		if(currencyTypeText == "ITEM_TOKEN") then
			val = player:GetItemCount(currency[KEYS.currency.data])
		end
		
		if(currencyTypeText == "SERVER_HANDLED") then
			-- Add your custom handling here for retreiving your server handled currencies
		end
		
		-- If value is larger than 10k then truncate to make sure it fits within the shop frame
		if(val > 9999) then
			val = "9999+"
		end
		
		table.insert(tmp, val)
	end
	AIO.Handle(player, "STORE_CLIENT", "UpdateCurrencies", tmp)
end

function StoreHandler.Purchase(player, serviceId)
	local services = GetServiceData()
	
	-- See if the requested service exists
	if(services[serviceId])then
		-- add the id to the service subtable so we don't have to pass an additional variable around
		services[serviceId].ID = serviceId
		local typeId = services[serviceId][KEYS.service.serviceType]
		
		local serviceHandler = SHOP_UI[SHOP_UI.serviceHandlers[typeId]]
		if(serviceHandler) then
			local success = serviceHandler(player, services[serviceId])
			if(success) then
				-- If purchase is successful, update the players currencies in UI and log purchase
				StoreHandler.UpdateCurrencies(player)
				SHOP_UI.LogPurchase(player, services[serviceId])
				
				-- Play success sound
				player:PlayDirectSound(120, player)
				
				-- Send success toast
				player:SendAreaTriggerMessage(string.format(L(player).PURCHASE_CONFIRMED, LocalizedField(player, services[serviceId], KEYS.service.name, KEYS.service.nameEn)))
			end
		end
	end
end

-- Helper functions
function SHOP_UI.DeductCurrency(player, currencyId, amount)
	local currency = GetCurrencyData()
	local currencyType = currency[currencyId][KEYS.currency.currencyType]
	local currencyName = LocalizedField(player, currency[currencyId], KEYS.currency.name, KEYS.currency.nameEn)
	local currencyData = currency[currencyId][KEYS.currency.data]
	
	-- Gold handling
	if(CURRENCY_TYPES[currencyType] == "GOLD") then
		if(player:GetCoinage() < amount * 10000) then
			player:SendAreaTriggerMessage("|cFFFF0000"..string.format(L(player).INSUFFICIENT_FUNDS, currencyName))
			player:PlayDirectSound(GetSoundEffect("notEnoughMoney", player:GetRace(), player:GetGender()), player)
			return false
		end
		
		player:SetCoinage(player:GetCoinage() - (amount * 10000))
	end
	
	-- Token handling
	if(CURRENCY_TYPES[currencyType] == "ITEM_TOKEN") then
		if not(player:HasItem(currencyData, amount)) then
			player:SendAreaTriggerMessage("|cFFFF0000"..string.format(L(player).INSUFFICIENT_FUNDS, currencyName))
			player:PlayDirectSound(GetSoundEffect("notEnoughMoney", player:GetRace(), player:GetGender()), player)
			return false
		end
		
		player:RemoveItem(currencyData, amount) 
	end
	
	-- Other special handlingm you have to add your own integration here.
	if(CURRENCY_TYPES[currencyType] == "SERVER_HANDLED") then
		return false
	end
	
	return true
end

function SHOP_UI.LogPurchase(player, data)
	local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
	WorldDBExecute("INSERT IGNORE INTO auc_world.store_logs(account, guid, serviceId, currencyId, cost) VALUES("..player:GetAccountId()..", "..player:GetGUIDLow()..", "..data.ID..", "..currency..", "..amount..");")
end

-- ITEMS
function SHOP_UI.ItemHandler(player, data)
	local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
	
	-- Deduct currency
	local deducted = SHOP_UI.DeductCurrency(player, currency, amount)
	
	-- If currency was not deducted from the player, abort and send message
	if not(deducted) then
		return false
	end
	
	-- Fetch all the rewards and store them temporarily
	local items = {}
	for i = 0, 7 do
		if(data[KEYS.service.reward_1+i] > 0 and data[KEYS.service.rewardCount_1+i] > 0) then
			table.insert(items, data[KEYS.service.reward_1+i])
			table.insert(items, data[KEYS.service.rewardCount_1+i])
		end
	end
	
	-- Send reward mail
	SendMail(string.format(L(player).MAIL_SUBJECT, LocalizedField(player, data, KEYS.service.name, KEYS.service.nameEn)), L(player).MAIL_BODY, player:GetGUIDLow(), CONFIG.mailSenderGUID, 62, 0, 0, 0, unpack(items))
	return true
end

-- GOLD
function SHOP_UI.GoldHandler(player, data)
	local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
	
	-- Deduct currency
	local deducted = SHOP_UI.DeductCurrency(player, currency, amount)
	
	-- If currency was not deducted from the player, abort and send message
	if not(deducted) then
		return false
	end
	
	-- Add gold to player
	player:ModifyMoney(data[KEYS.service.reward_1]*10000)
	return true
end

-- MOUNTS
function SHOP_UI.MountHandler(player, data)
	local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
	
	local knownCount, rewardCount = 0, 0
	for i = 0, 7 do
		if(data[KEYS.service.reward_1+i] > 0) then
			if(player:HasSpell(data[KEYS.service.reward_1+i])) then
				knownCount = knownCount + 1
			end
			rewardCount = rewardCount + 1
		end
	end
	
	-- check if player already has the spells learned
	if(knownCount == rewardCount) then
		player:SendAreaTriggerMessage("|cFFFF0000"..L(player).ALREADY_KNOWN_MOUNT.."|r")
		player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
		return false
	end
	
	-- Deduct currency
	local deducted = SHOP_UI.DeductCurrency(player, currency, amount)
	
	-- If currency was not deducted from the player, abort and send message
	if not(deducted) then
		return false
	end
	
	-- Teach mounts
	for i = 0, 7 do
		if(data[KEYS.service.reward_1+i] > 0) then
			player:LearnSpell(data[KEYS.service.reward_1+i])
		end
	end
	return true
end

-- PETS
function SHOP_UI.PetHandler(player, data)
	local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
	
	local knownCount, rewardCount = 0, 0
	for i = 0, 7 do
		if(data[KEYS.service.reward_1+i] > 0) then
			if(player:HasSpell(data[KEYS.service.reward_1+i])) then
				knownCount = knownCount + 1
			end
			rewardCount = rewardCount + 1
		end
	end
	
	-- check if player already has the spells learned
	if(knownCount == rewardCount) then
		player:SendAreaTriggerMessage("|cFFFF0000"..L(player).ALREADY_KNOWN_PET.."|r")
		player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
		return false
	end
	
	-- Deduct currency
	local deducted = SHOP_UI.DeductCurrency(player, currency, amount)
	
	-- If currency was not deducted from the player, abort and send message
	if not(deducted) then
		return false
	end
	
	-- Teach pets
	for i = 0, 7 do
		if(data[KEYS.service.reward_1+i] > 0) then
			player:LearnSpell(data[KEYS.service.reward_1+i])
		end
	end
	return true
end

-- BUFFS
function SHOP_UI.BuffHandler(player, data)
	local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
	
	-- Deduct currency
	local deducted = SHOP_UI.DeductCurrency(player, currency, amount)
	
	-- If currency was not deducted from the player, abort and send message
	if not(deducted) then
		return false
	end
	
	-- iterate over all reward slots and buff the player with all configured spells
	for i = 0, 7 do
		if(data[KEYS.service.reward_1+i] > 0) then
			player:CastSpell(player, data[KEYS.service.reward_1+i], true)
		end
	end
	return true
end

-- SERVICES
function SHOP_UI.ServiceHandler(player, data)
	local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
	
	-- Deduct currency
	local deducted = SHOP_UI.DeductCurrency(player, currency, amount)
	
	-- If currency was not deducted from the player, abort and send message
	if not(deducted) then
		return false
	end
	
	-- Set the AtLogin flag to whatever is defined in reward_1
	player:SetAtLoginFlag(data[KEYS.service.reward_1])
	
	return true
end

-- LEVELS
function SHOP_UI.LevelHandler(player, data)
	local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
	-- If flag is set to 1, then we set the player to the specified level instead of adding levels
	-- We need to check this before deducting any money
	if(data[KEYS.service.flags] == 1) then
		if(player:GetLevel() >= data[KEYS.service.reward_1]) then
			player:SendAreaTriggerMessage("|cFFFF0000"..L(player).TOO_HIGH_LEVEL.."|r")
			player:PlayDirectSound(GetSoundEffect("cantUse", player:GetRace(), player:GetGender()), player)
			return false
		end
	end
	
	-- Deduct currency
	local deducted = SHOP_UI.DeductCurrency(player, currency, amount)
	
	-- If currency was not deducted from the player, abort and send message
	if not(deducted) then
		return false
	end
	
	local level = player:GetLevel() + data[KEYS.service.reward_1]
	
	-- Ensure that players can't level higher than configured max
	if(level > CONFIG.maxLevel) then
		level = CONFIG.maxLevel
	end
	
	-- and again, if flag = 1 then we set the level instead of adding onto
	if(data[KEYS.service.flags] == 1) then
		level = data[KEYS.service.reward_1]
	end
	
	player:SetLevel(level)
	return true
end

-- TITLES
function SHOP_UI.TitleHandler(player, data)
	local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
	
	-- Check whether or not the player already has the specified title
	if(player:HasTitle(data[KEYS.service.reward_1])) then
		player:SendAreaTriggerMessage("|cFFFF0000"..L(player).ALREADY_KNOWN_TITLE.."|r")
		player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
		return false
	end
	
	-- Deduct currency
	local deducted = SHOP_UI.DeductCurrency(player, currency, amount)
	
	-- If currency was not deducted from the player, abort and send message
	if not(deducted) then
		return false
	end
	
	-- Give the player the defined title
	player:SetKnownTitle(data[KEYS.service.reward_1])
	return true
end

-- UNUSED
function SHOP_UI.UnusedHandler(player, data)
	local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
	
	-- Since this is unused, always return false until the function is in use.
	return false
end