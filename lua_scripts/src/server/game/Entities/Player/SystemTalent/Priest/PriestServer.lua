local AIO = AIO or require("AIO")
local PriestHandlers = AIO.AddHandlers("TalentPriestspell", {})
local TalentPriestPointsSpend = {}

local MAX_TALENTS = 60

local talents = {
	-- Template 1

	-- Maitrise des Bêtes
	
	["spellunbreakablewill"] = {spellID = 14791, itemID = 338404},
	["spelltwindisciplines"] = {spellID = 52803, itemID = 338404},
	["spellsilentresolve"] = {spellID = 14785, itemID = 338404},
	["spellimprovedinnerfire"] = {spellID = 14771, itemID = 338404},
	["spellimprovedpowerwordfortitude"] = {spellID = 14767, itemID = 338404},
	["spellmartyrdom"] = {spellID = 14774, itemID = 338404},
	["spellmeditation"] = {spellID = 14777, itemID = 338404},
	["spellinnerfocus"] = {spellID = 14751, itemID = 338404},
	["spellimprovedpowerwordshield"] = {spellID = 14769, itemID = 338404},
	["spellabsolution"] = {spellID = 33172, itemID = 338404},
	["spellmentalagility"] = {spellID = 14781, itemID = 338404},
	["spellimprovedmanaburn"] = {spellID = 14772, itemID = 338404},
	["spellreflectiveshield"] = {spellID = 33202, itemID = 338404},
	["spellmentalstrength"] = {spellID = 18555, itemID = 338404},
	["spellsoulwarding"] = {spellID = 63574, itemID = 338404},
	["spellfocusedpower"] = {spellID = 33190, itemID = 338404},
	["spellenlightenment"] = {spellID = 34910, itemID = 338404},
	["spellfocusedwill"] = {spellID = 45244, itemID = 338404},
	["spellpowerinfusion"] = {spellID = 10060, itemID = 338404},
	["spellimprovedflashheal"] = {spellID = 63506, itemID = 338404},
	["spellrenewedhope"] = {spellID = 57472, itemID = 338404},
	["spellrapture"] = {spellID = 47537, itemID = 338404},
	["spellaspiration"] = {spellID = 47508, itemID = 338404},
	["spelldivineaegis"] = {spellID = 47515, itemID = 338404},
	["spellpainsuppression"] = {spellID = 33206, itemID = 338404},
	["spellgrace"] = {spellID = 47517, itemID = 338404},
	["spellborrowedtime"] = {spellID = 52800, itemID = 338404},
	["spellpenance"] = {spellID = 47540, itemID = 338404},
	
	-- Sacré
	
	["spellhealingfocus"] = {spellID = 15012, itemID = 338404},
	["spellimprovedrenew"] = {spellID = 17191, itemID = 338404},
	["spellholyspecialization"] = {spellID = 15011, itemID = 338404},
	["spellspellwarding"] = {spellID = 27904, itemID = 338404},
	["spelldivinefury"] = {spellID = 18535, itemID = 338404},
	["spelldesperateprayer"] = {spellID = 19236, itemID = 338404},
	["spellblessedrecovery"] = {spellID = 27816, itemID = 338404},
	["spellinspiration"] = {spellID = 15363, itemID = 338404},
	["spellholyreach"] = {spellID = 27790, itemID = 338404},
	["spellimprovedhealing"] = {spellID = 15014, itemID = 338404},
	["spellsearinglight"] = {spellID = 15017, itemID = 338404},
	["spellhealingprayers"] = {spellID = 15018, itemID = 338404},
	["spellspiritofredemption"] = {spellID = 20711, itemID = 338404},
	
	-- Template 2
	
	["spellspiritualguidance"] = {spellID = 15031, itemID = 338404},
	["spellsurgeoflight"] = {spellID = 33154, itemID = 338404},
	["spellspiritualsealing"] = {spellID = 15356, itemID = 338404},
	["spellholyconcentration"] = {spellID = 34860, itemID = 338404},
	["spelllightwell"] = {spellID = 724, itemID = 338404},
	["spellblessedresilience"] = {spellID = 33146, itemID = 338404},
	["spellbodyandsoul"] = {spellID = 64129, itemID = 338404},
	["spellempoweredhealing"] = {spellID = 33162, itemID = 338404},
	["spellserendipity"] = {spellID = 63737, itemID = 338404},
	["spellempoweredrenew"] = {spellID = 63543, itemID = 338404},
	["spellcircleofhealing"] = {spellID = 34861, itemID = 338404},
	["spelltestoffaith"] = {spellID = 47560, itemID = 338404},
	["spelldivineprovidence"] = {spellID = 47567, itemID = 338404},
	["spellguardianspirit"] = {spellID = 47788, itemID = 338404},
	
	-- Ombre
	
	["spellspirittap"] = {spellID = 15336, itemID = 338404},
	["spellimprovedspirittap"] = {spellID = 15338, itemID = 338404},
	["spelldarkness"] = {spellID = 15310, itemID = 338404},--
	["spellshadowaffinity"] = {spellID = 15320, itemID = 338404},
	["spellimprovedshadowwordpain"] = {spellID = 15317, itemID = 338404},
	["spellshadowfocus"] = {spellID = 15328, itemID = 338404},
	["spellimprovedpsychicscream"] = {spellID = 15448, itemID = 338404},
	["spellimprovedmindblast"] = {spellID = 15316, itemID = 338404},
	["spellmindflay"] = {spellID = 15407, itemID = 338404},
	["spellveiledshadows"] = {spellID = 15311, itemID = 338404},
	["spellshadowreacht"] = {spellID = 17323, itemID = 338404},
	["spellshadowweaving"] = {spellID = 15332, itemID = 338404},
	["spellsilence"] = {spellID = 15487, itemID = 338404},
	["spellvampiricembrace"] = {spellID = 15286, itemID = 338404},
	["spellimprovedvampiricembrace"] = {spellID = 27840, itemID = 338404},
	["spellfocusedmind"] = {spellID = 33215, itemID = 338404},
	["spellmindmelt"] = {spellID = 33371, itemID = 338404},
	["spellimproveddevouringplague"] = {spellID = 63627, itemID = 338404},
	["spellshadowform"] = {spellID = 15473, itemID = 338404},
	["spellshadowpower"] = {spellID = 33225, itemID = 338404},
	["spellimprovedshadowform"] = {spellID = 47570, itemID = 338404},
	["spellmisery"] = {spellID = 33193, itemID = 338404},
	["spellpsychichorror"] = {spellID = 64044, itemID = 338404},
	["spellvampirictouch"] = {spellID = 34914, itemID = 338404},
	["spellpainandsufferings"] = {spellID = 47582, itemID = 338404},
	["spelltwistedfaith"] = {spellID = 51167, itemID = 338404},
	["spelldispersion"] = {spellID = 47585, itemID = 338404},
	
}

-- Accesseur item talent (GetItemCount est l'API Eluna correcte)
local function GetTalentItemCount(player)
    return player:GetItemCount(338404)
end

-- Accesseur par GUID pour éviter la collision multi-joueurs
local function GetSpendList(player)
    local guid = player:GetGUIDLow()
    if not TalentPriestPointsSpend[guid] then
        TalentPriestPointsSpend[guid] = {}
    end
    return TalentPriestPointsSpend[guid]
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

                AIO.Handle(player, "TalentPriestspell", "UpdateTalentCount", #spendList, MAX_TALENTS)
                AIO.Handle(player, "TalentPriestspell", "UpdateTalentItemCount", GetTalentItemCount(player))

                local learnedSpells = {}
                learnedSpells[talentHandler] = true
                AIO.Handle(player, "TalentPriestspell", "UpdateLearnedTalents", learnedSpells)
            end
        else
            player:SendAreaTriggerMessage("|cffff0000Vous n'avez pas de point de talent !|r")
            AIO.Handle(player, "TalentPriestspell", "UpdateTalentItemCount", GetTalentItemCount(player))
        end
    end
end

for talentName, talentData in pairs(talents) do
    PriestHandlers[talentName] = function(player, item)
        LearnTalent(player, talentData, talentName)
    end
end

local function LoadTalentProgression(player)
    local guid = player:GetGUIDLow()
    TalentPriestPointsSpend[guid] = {}
    local spendList    = TalentPriestPointsSpend[guid]
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

    AIO.Handle(player, "TalentPriestspell", "UpdateTalentCount", #spendList, MAX_TALENTS)

    -- Petit délai pour s'assurer que l'UI client est chargée avant d'envoyer l'état
    player:RegisterEvent(function(eventId, delay, repeats, pPlayer)
        AIO.Handle(pPlayer, "TalentPriestspell", "UpdateLearnedTalents", learnedSpells)
        AIO.Handle(pPlayer, "TalentPriestspell", "UpdateTalentItemCount", GetTalentItemCount(pPlayer))
    end, 10, 1)
end

PriestHandlers.RequestLearnedTalents = function(player)
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
    AIO.Handle(player, "TalentPriestspell", "UpdateLearnedTalents", learnedSpells)
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

PriestHandlers.GetTalentItemCount = function(player)
    AIO.Handle(player, "TalentPriestspell", "UpdateTalentItemCount", GetTalentItemCount(player))
end

local function ResetTalentProgression(player)
    CharDBQuery("DELETE FROM character_talentspell WHERE guid = " .. player:GetGUIDLow() .. " AND account_id = " .. player:GetAccountId() .. ";")
end

PriestHandlers.ResetTalents = function(player)
    local spendList        = GetSpendList(player)
    local pointsBeforeReset = #spendList

    for talentName, talentData in pairs(talents) do
        player:RemoveSpell(talentData.spellID)
    end

    local guid = player:GetGUIDLow()
    TalentPriestPointsSpend[guid] = {}
    ResetTalentProgression(player)

    AIO.Handle(player, "TalentPriestspell", "ResetAllButtons")
    AIO.Handle(player, "TalentPriestspell", "UpdateTalentCount", 0, MAX_TALENTS)
    AIO.Handle(player, "TalentPriestspell", "UpdateTalentPointsUsed", 0, pointsBeforeReset)

    player:AddItem(338404, pointsBeforeReset)
    AIO.Handle(player, "TalentPriestspell", "UpdateTalentItemCount", GetTalentItemCount(player))
end