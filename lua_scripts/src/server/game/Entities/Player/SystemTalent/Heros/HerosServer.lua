local AIO = AIO or require("AIO")
local HerosHandlers = AIO.AddHandlers("TalentHerosspell", {})
local TalentHerosPointsSpend = {}

local MAX_TALENTS = 8

local talents = {

	-- Template 1
	
	["spellbeserker"] = {spellID = 381804, itemID = 338404},
    ["spellrallyingcry"] = {spellID = 382034, itemID = 338404},
    ["spellspeed"] = {spellID = 381712, itemID = 338404},
    ["spellruse"] = {spellID = 381972, itemID = 338404},
    ["spelldisengage"] = {spellID = 382000, itemID = 338404},
	-- Template 2
	["spelllightningstrike"] = {spellID = 381740, itemID = 338404},
    ["spellfireball"] = {spellID = 381689, itemID = 338404},
    ["spellfrostball"] = {spellID = 381790, itemID = 338404},
    ["spelldivinefury"] = {spellID = 381838, itemID = 338404},
    ["spellignition"] = {spellID = 381904, itemID = 338404}
}

-- Accesseur item talent (GetItemCount est l'API Eluna correcte)
local function GetTalentItemCount(player)
    return player:GetItemCount(338404)
end

-- Accesseur par GUID pour éviter la collision multi-joueurs
local function GetSpendList(player)
    local guid = player:GetGUIDLow()
    if not TalentHerosPointsSpend[guid] then
        TalentHerosPointsSpend[guid] = {}
    end
    return TalentHerosPointsSpend[guid]
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

                AIO.Handle(player, "TalentHerosspell", "UpdateTalentCount", #spendList, MAX_TALENTS)
                AIO.Handle(player, "TalentHerosspell", "UpdateTalentItemCount", GetTalentItemCount(player))

                local learnedSpells = {}
                learnedSpells[talentHandler] = true
                AIO.Handle(player, "TalentHerosspell", "UpdateLearnedTalents", learnedSpells)
            end
        else
            player:SendAreaTriggerMessage("|cffff0000Vous n'avez pas de point de talent !|r")
            AIO.Handle(player, "TalentHerosspell", "UpdateTalentItemCount", GetTalentItemCount(player))
        end
    end
end

for talentName, talentData in pairs(talents) do
    HerosHandlers[talentName] = function(player, item)
        LearnTalent(player, talentData, talentName)
    end
end

local function LoadTalentProgression(player)
    local guid = player:GetGUIDLow()
    TalentHerosPointsSpend[guid] = {}
    local spendList    = TalentHerosPointsSpend[guid]
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

    AIO.Handle(player, "TalentHerosspell", "UpdateTalentCount", #spendList, MAX_TALENTS)

    -- Petit délai pour s'assurer que l'UI client est chargée avant d'envoyer l'état
    player:RegisterEvent(function(eventId, delay, repeats, pPlayer)
        AIO.Handle(pPlayer, "TalentHerosspell", "UpdateLearnedTalents", learnedSpells)
        AIO.Handle(pPlayer, "TalentHerosspell", "UpdateTalentItemCount", GetTalentItemCount(pPlayer))
    end, 10, 1)
end

HerosHandlers.RequestLearnedTalents = function(player)
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
    AIO.Handle(player, "TalentHerosspell", "UpdateLearnedTalents", learnedSpells)
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

HerosHandlers.GetTalentItemCount = function(player)
    AIO.Handle(player, "TalentHerosspell", "UpdateTalentItemCount", GetTalentItemCount(player))
end

local function ResetTalentProgression(player)
    CharDBQuery("DELETE FROM character_talentspell WHERE guid = " .. player:GetGUIDLow() .. " AND account_id = " .. player:GetAccountId() .. ";")
end

HerosHandlers.ResetTalents = function(player)
    local spendList        = GetSpendList(player)
    local pointsBeforeReset = #spendList

    for talentName, talentData in pairs(talents) do
        player:RemoveSpell(talentData.spellID)
    end

    local guid = player:GetGUIDLow()
    TalentHerosPointsSpend[guid] = {}
    ResetTalentProgression(player)

    AIO.Handle(player, "TalentHerosspell", "ResetAllButtons")
    AIO.Handle(player, "TalentHerosspell", "UpdateTalentCount", 0, MAX_TALENTS)
    AIO.Handle(player, "TalentHerosspell", "UpdateTalentPointsUsed", 0, pointsBeforeReset)

    player:AddItem(338404, pointsBeforeReset)
    AIO.Handle(player, "TalentHerosspell", "UpdateTalentItemCount", GetTalentItemCount(player))
end