local AIO = AIO or require("AIO")
local DemonhunterHandlers = AIO.AddHandlers("TalentDemonhunterspell", {})
local TalentDemonhunterPointsSpend = {}

local MAX_TALENTS = 28

local talents = {
	-- Template 1

	-- Dévastation
	
    ["spellwarglaiveschaos"] = {spellID = 98981, itemID = 338404},
	["spelldemonspeed"] = {spellID = 98980, itemID = 338404},
	["spellunboundchaos"] = {spellID = 98897, itemID = 338404},
	["spellchaosvision"] = {spellID = 98891, itemID = 338404},
	["spelldevastatingchaos"] = {spellID = 98890, itemID = 338404},
	["spelldesperateinstincts"] = {spellID = 98885, itemID = 338404},
	["spellimproveddemonsbite"] = {spellID = 98886, itemID = 338404},
	["spellnetherwalk"] = {spellID = 98884, itemID = 338404},
	["spellanguishdeceiver"] = {spellID = 98889, itemID = 338404},
	["spellchaoticonslaught"] = {spellID = 98878, itemID = 338404},
	["spellillidariknowledge"] = {spellID = 98879, itemID = 338404},
	["spellunleashedpower"] = {spellID = 98876, itemID = 338404},
	["spellchaosblade"] = {spellID = 98859, itemID = 338404},
	["spellimprovedmetamorphosis"] = {spellID = 98875, itemID = 338404},
	["spellunleasheddemons"] = {spellID = 98872, itemID = 338404},
	["spellbalancedblades"] = {spellID = 98862, itemID = 338404},
	["spelldemonic"] = {spellID = 98870, itemID = 338404},
	["spellfelwounds"] = {spellID = 98860, itemID = 338404},
	["spellfelbarrage"] = {spellID = 98868, itemID = 338404},
	
	-- Template 2

	-- Vengeance
	
	["spellthickskin"] = {spellID = 320384, itemID = 338404},
	["spelldemonicwards"] = {spellID = 203514, itemID = 338404},
	
	-- Maître du glaive
	
	["spellsharpenedglaives"] = {spellID = 98854, itemID = 338404},
	["spelldisorientglaives"] = {spellID = 98851, itemID = 338404},
	["spellfireglaives"] = {spellID = 98845, itemID = 338404},
	["spellmasterglaive"] = {spellID = 98832, itemID = 338404},
	["spellmasteryspeed"] = {spellID = 98831, itemID = 338404},
	["spellimprovedfireglaives"] = {spellID = 98842, itemID = 338404},
	["spellcauterize"] = {spellID = 98850, itemID = 338404},
	["spelldualbladedance"] = {spellID = 98829, itemID = 338404},
	["spellimproveddualblades"] = {spellID = 98827, itemID = 338404},
	["spellbloodlet"] = {spellID = 98839, itemID = 338404},
	["spellrapidglaives"] = {spellID = 98835, itemID = 338404},
	["spellvenomlet"] = {spellID = 98838, itemID = 338404},
}

-- Accesseur item talent (GetItemCount est l'API Eluna correcte)
local function GetTalentItemCount(player)
    return player:GetItemCount(338404)
end

-- Accesseur par GUID pour éviter la collision multi-joueurs
local function GetSpendList(player)
    local guid = player:GetGUIDLow()
    if not TalentDemonhunterPointsSpend[guid] then
        TalentDemonhunterPointsSpend[guid] = {}
    end
    return TalentDemonhunterPointsSpend[guid]
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

                AIO.Handle(player, "TalentDemonhunterspell", "UpdateTalentCount", #spendList, MAX_TALENTS)
                AIO.Handle(player, "TalentDemonhunterspell", "UpdateTalentItemCount", GetTalentItemCount(player))

                local learnedSpells = {}
                learnedSpells[talentHandler] = true
                AIO.Handle(player, "TalentDemonhunterspell", "UpdateLearnedTalents", learnedSpells)
            end
        else
            player:SendAreaTriggerMessage("|cffff0000Vous n'avez pas de point de talent !|r")
            AIO.Handle(player, "TalentDemonhunterspell", "UpdateTalentItemCount", GetTalentItemCount(player))
        end
    end
end

for talentName, talentData in pairs(talents) do
    DemonhunterHandlers[talentName] = function(player, item)
        LearnTalent(player, talentData, talentName)
    end
end

local function LoadTalentProgression(player)
    local guid = player:GetGUIDLow()
    TalentDemonhunterPointsSpend[guid] = {}
    local spendList    = TalentDemonhunterPointsSpend[guid]
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

    AIO.Handle(player, "TalentDemonhunterspell", "UpdateTalentCount", #spendList, MAX_TALENTS)

    -- Petit délai pour s'assurer que l'UI client est chargée avant d'envoyer l'état
    player:RegisterEvent(function(eventId, delay, repeats, pPlayer)
        AIO.Handle(pPlayer, "TalentDemonhunterspell", "UpdateLearnedTalents", learnedSpells)
        AIO.Handle(pPlayer, "TalentDemonhunterspell", "UpdateTalentItemCount", GetTalentItemCount(pPlayer))
    end, 10, 1)
end

DemonhunterHandlers.RequestLearnedTalents = function(player)
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
    AIO.Handle(player, "TalentDemonhunterspell", "UpdateLearnedTalents", learnedSpells)
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

DemonhunterHandlers.GetTalentItemCount = function(player)
    AIO.Handle(player, "TalentDemonhunterspell", "UpdateTalentItemCount", GetTalentItemCount(player))
end

local function ResetTalentProgression(player)
    CharDBQuery("DELETE FROM character_talentspell WHERE guid = " .. player:GetGUIDLow() .. " AND account_id = " .. player:GetAccountId() .. ";")
end

DemonhunterHandlers.ResetTalents = function(player)
    local spendList        = GetSpendList(player)
    local pointsBeforeReset = #spendList

    for talentName, talentData in pairs(talents) do
        player:RemoveSpell(talentData.spellID)
    end

    local guid = player:GetGUIDLow()
    TalentDemonhunterPointsSpend[guid] = {}
    ResetTalentProgression(player)

    AIO.Handle(player, "TalentDemonhunterspell", "ResetAllButtons")
    AIO.Handle(player, "TalentDemonhunterspell", "UpdateTalentCount", 0, MAX_TALENTS)
    AIO.Handle(player, "TalentDemonhunterspell", "UpdateTalentPointsUsed", 0, pointsBeforeReset)

    player:AddItem(338404, pointsBeforeReset)
    AIO.Handle(player, "TalentDemonhunterspell", "UpdateTalentItemCount", GetTalentItemCount(player))
end