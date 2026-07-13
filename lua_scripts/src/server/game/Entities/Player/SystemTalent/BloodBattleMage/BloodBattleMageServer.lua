local AIO = AIO or require("AIO")
local BloodbattlemageHandlers = AIO.AddHandlers("TalentBloodbattlemagespell", {})
local TalentBloodbattlemagePointsSpend = {}

local MAX_TALENTS = 41

local talents = {

	-- Template 1
	
	-- Magie du sang
	
	["spellimprovedblood"] = {spellID = 300021, itemID = 338404},
	["spellseedgrowth"] = {spellID = 300113, itemID = 338404},
	["spelloppressiveray"] = {spellID = 300034, itemID = 338404},
	["spellbloodbundle"] = {spellID = 300039, itemID = 338404},
	["spellbloody"] = {spellID = 300229, itemID = 338404},
	["spellhomeothermal"] = {spellID = 300043, itemID = 338404},
	["spelltargeted"] = {spellID = 300209, itemID = 338404},
	["spelleffusion"] = {spellID = 300217, itemID = 338404},
	["spellseedpreparation"] = {spellID = 300089, itemID = 338404},
	["spellbloodtransfusion"] = {spellID = 300045, itemID = 338404},
	["spellbloodtransfusionimprove"] = {spellID = 300084, itemID = 338404},
	["spellsangthe"] = {spellID = 300064, itemID = 338404},
	["spellparasyteseed"] = {spellID = 300040, itemID = 338404},
	["spellmentalconditioning"] = {spellID = 300226, itemID = 338404},
	["spellwarmup"] = {spellID = 300026, itemID = 338404},
	["spellbloodcirculation"] = {spellID = 300224, itemID = 338404},
	["spellbloodessence"] = {spellID = 300050, itemID = 338404},
	["spellbloodyapparation"] = {spellID = 300052, itemID = 338404},
	["spellhotblood"] = {spellID = 300029, itemID = 338404},
	["spellnoblood"] = {spellID = 300116, itemID = 338404},
	["spellbloodsample"] = {spellID = 300100, itemID = 338404},
	["spellcollectivedonation"] = {spellID = 300119, itemID = 338404},
	["spellbloodflow"] = {spellID = 300170, itemID = 338404},
	["spellbloodstorm"] = {spellID = 300099, itemID = 338404},
	["spellreinforcedblood"] = {spellID = 300125, itemID = 338404},
	
	-- Template 2
	
	-- Sacrifice de sang
	
	["spellabilitymotivation"] = {spellID = 300095, itemID = 338404},
	["spellabilitybloodflow"] = {spellID = 300101, itemID = 338404},
	["spellabilitycare"] = {spellID = 300093, itemID = 338404},
	["spellabilityprotection"] = {spellID = 300091, itemID = 338404},
	["spellabilitysword"] = {spellID = 300092, itemID = 338404},
	["spellabilityprotector"] = {spellID = 300094, itemID = 338404},
	["spellabilitypureblood"] = {spellID = 300096, itemID = 338404},
	["spellharvestingsuffering"] = {spellID = 300149, itemID = 338404},
	["spellbloodbarrier"] = {spellID = 300109, itemID = 338404},
	["spellabilityimprovement"] = {spellID = 300180, itemID = 338404},
	["spellabilitypotential"] = {spellID = 300175, itemID = 338404},
	
	-- Blessure de sang
	
	["spellbloodprovocation"] = {spellID = 1502003, itemID = 338404},
	["spellmartialknowledge"] = {spellID = 300135, itemID = 338404},
	["spellmicrobalance"] = {spellID = 300130, itemID = 338404},
	["spellmortalbloodorb"] = {spellID = 300102, itemID = 338404},
	["spellmortalmultiplecontusion"] = {spellID = 300104, itemID = 338404},
	["spellmortalsurgicalstrike"] = {spellID = 300105, itemID = 338404},
	["spellmortaldestruction"] = {spellID = 300106, itemID = 338404},
	["spellcollectingblood"] = {spellID = 300140, itemID = 338404},
	["spellbloodyblood"] = {spellID = 300155, itemID = 338404},
	["spellbloodshed"] = {spellID = 300160, itemID = 338404},
	["spelllethalpowerfulimpulse"] = {spellID = 300110, itemID = 338404},
	["spellinternalhemorrhage"] = {spellID = 300165, itemID = 338404},
	["spellanticipateddestruction"] = {spellID = 300145, itemID = 338404},

}

-- Accesseur item talent (GetItemCount est l'API Eluna correcte)
local function GetTalentItemCount(player)
    return player:GetItemCount(338404)
end

-- Accesseur par GUID pour éviter la collision multi-joueurs
local function GetSpendList(player)
    local guid = player:GetGUIDLow()
    if not TalentBloodbattlemagePointsSpend[guid] then
        TalentBloodbattlemagePointsSpend[guid] = {}
    end
    return TalentBloodbattlemagePointsSpend[guid]
end

local function LearnTalent(player, talent, talentHandler)
    local accountID = player:GetAccountId()
    local guid      = player:GetGUIDLow()
    local spellID   = talent.spellID
    local itemID    = talent.itemID
    local spendList = GetSpendList(player)

    if player:HasSpell(spellID) then
        player:SendAreaTriggerMessage("|cff00ffffVous connaissez déjà ce talent !|r")
    else
        if player:HasItem(itemID) then
            if #spendList >= MAX_TALENTS then
                player:SendAreaTriggerMessage("|cffff0000Vous avez atteint la limite de talents !|r")
            else
                player:RemoveItem(itemID, 1)
                player:SendAreaTriggerMessage("|cff00ff00Vous avez appris un nouveau talent !|r")
                player:LearnSpell(spellID)
                table.insert(spendList, spellID)

                CharDBQuery("REPLACE INTO character_talentspell (guid, account_id, spell, active) VALUES ("
                    .. guid .. ", " .. accountID .. ", " .. spellID .. ", 1);")

                AIO.Handle(player, "TalentBloodbattlemagespell", "UpdateTalentCount", #spendList, MAX_TALENTS)
                AIO.Handle(player, "TalentBloodbattlemagespell", "UpdateTalentItemCount", GetTalentItemCount(player))

                local learnedSpells = {}
                learnedSpells[talentHandler] = true
                AIO.Handle(player, "TalentBloodbattlemagespell", "UpdateLearnedTalents", learnedSpells)
            end
        else
            player:SendAreaTriggerMessage("|cffff0000Vous n'avez pas de point de talent !|r")
            AIO.Handle(player, "TalentBloodbattlemagespell", "UpdateTalentItemCount", GetTalentItemCount(player))
        end
    end
end

for talentName, talentData in pairs(talents) do
    BloodbattlemageHandlers[talentName] = function(player, item)
        LearnTalent(player, talentData, talentName)
    end
end

local function LoadTalentProgression(player)
    local guid = player:GetGUIDLow()
    TalentBloodbattlemagePointsSpend[guid] = {}
    local spendList    = TalentBloodbattlemagePointsSpend[guid]
    local learnedSpells = {}

    local query = CharDBQuery(
        "SELECT spell FROM character_talentspell WHERE guid = " .. guid ..
        " AND account_id = " .. player:GetAccountId() .. " AND active = 1;"
    )
    if query then
        repeat
            local spellID = query:GetUInt32(0)
            table.insert(spendList, spellID)
            player:LearnSpell(spellID)

            -- Trouver le handler correspondant au spellID
            for handler, talentData in pairs(talents) do
                if talentData.spellID == spellID then
                    learnedSpells[handler] = true
                    break
                end
            end
        until not query:NextRow()
    end

    AIO.Handle(player, "TalentBloodbattlemagespell", "UpdateTalentCount", #spendList, MAX_TALENTS)

    -- Petit délai pour s'assurer que l'UI client est chargée avant d'envoyer l'état
    player:RegisterEvent(function(eventId, delay, repeats, pPlayer)
        AIO.Handle(pPlayer, "TalentBloodbattlemagespell", "UpdateLearnedTalents", learnedSpells)
        AIO.Handle(pPlayer, "TalentBloodbattlemagespell", "UpdateTalentItemCount", GetTalentItemCount(pPlayer))
    end, 10, 1)
end

BloodbattlemageHandlers.RequestLearnedTalents = function(player)
    local learnedSpells = {}
    local query = CharDBQuery("SELECT spell FROM character_talentspell WHERE guid = " .. player:GetGUIDLow() .. ";")
    if query then
        repeat
            local spellID = query:GetUInt32(0)
            for handler, talentData in pairs(talents) do
                if talentData.spellID == spellID then
                    learnedSpells[handler] = true
                    break
                end
            end
        until not query:NextRow()
    end
    AIO.Handle(player, "TalentBloodbattlemagespell", "UpdateLearnedTalents", learnedSpells)
end

local function OnPlayerLogin(event, player)
    LoadTalentProgression(player)
end
RegisterPlayerEvent(3, OnPlayerLogin)

-- Supprime les données de talent lorsqu'un personnage est supprimé.
-- PLAYER_EVENT_ON_CHARACTER_DELETE (2) passe (event, guid) — pas d'objet player disponible.
local function OnCharacterDelete(event, guid)
    CharDBQuery(
        "DELETE FROM character_talentspell WHERE guid = " .. guid .. ";"
    )
end
RegisterPlayerEvent(2, OnCharacterDelete)

BloodbattlemageHandlers.GetTalentItemCount = function(player)
    AIO.Handle(player, "TalentBloodbattlemagespell", "UpdateTalentItemCount", GetTalentItemCount(player))
end

local function ResetTalentProgression(player)
    CharDBQuery("DELETE FROM character_talentspell WHERE guid = " .. player:GetGUIDLow() .. " AND account_id = " .. player:GetAccountId() .. ";")
end

BloodbattlemageHandlers.ResetTalents = function(player)
    local spendList        = GetSpendList(player)
    local pointsBeforeReset = #spendList

    for talentName, talentData in pairs(talents) do
        player:RemoveSpell(talentData.spellID)
    end

    local guid = player:GetGUIDLow()
    TalentBloodbattlemagePointsSpend[guid] = {}
    ResetTalentProgression(player)

    AIO.Handle(player, "TalentBloodbattlemagespell", "ResetAllButtons")
    AIO.Handle(player, "TalentBloodbattlemagespell", "UpdateTalentCount", 0, MAX_TALENTS)
    AIO.Handle(player, "TalentBloodbattlemagespell", "UpdateTalentPointsUsed", 0, pointsBeforeReset)

    player:AddItem(338404, pointsBeforeReset)
    AIO.Handle(player, "TalentBloodbattlemagespell", "UpdateTalentItemCount", GetTalentItemCount(player))
end