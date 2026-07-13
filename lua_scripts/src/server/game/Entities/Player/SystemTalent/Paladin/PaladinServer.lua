local AIO = AIO or require("AIO")
local PaladinHandlers = AIO.AddHandlers("TalentPaladinspell", {})
local TalentPaladinPointsSpend = {}

local MAX_TALENTS = 60

local talents = {
	-- Template 1

	-- Sacré
	
	["spellspiritualfocus"] = {spellID = 20208, itemID = 338404},
	["spellsealsofthepure"] = {spellID = 20332, itemID = 338404},
	["spellhealinglight"] = {spellID = 20239, itemID = 338404},
	["spelldivineintellect"] = {spellID = 20261, itemID = 338404},
	["spellunyieldingfaith"] = {spellID = 25836, itemID = 338404},
	["spellauramastery"] = {spellID = 31821, itemID = 338404},
	["spellillumination"] = {spellID = 20215, itemID = 338404},
	["spellimprovedlayonhands"] = {spellID = 20235, itemID = 338404},
	["spellimprovedconcentrationaura"] = {spellID = 20256, itemID = 338404},
	["spellimprovedblessingofwisdom"] = {spellID = 20245, itemID = 338404},
	["spellblessedhands"] = {spellID = 53661, itemID = 338404},
	["spellpureofheart"] = {spellID = 31823, itemID = 338404},
	["spelldivinefavor"] = {spellID = 20216, itemID = 338404},
	["spellsanctifiedlight"] = {spellID = 20361, itemID = 338404},
	["spellpurifyingpower"] = {spellID = 31826, itemID = 338404},
	["spellholypower"] = {spellID = 25829, itemID = 338404},
	["spelllightsgrace"] = {spellID = 31826, itemID = 338404},
	["spellholyshock"] = {spellID = 20473, itemID = 338404},
	["spellblessedlife"] = {spellID = 31830, itemID = 338404},
	["spellsacredcleansing"] = {spellID = 53553, itemID = 338404},
	["spellholyguidance"] = {spellID = 31841, itemID = 338404},
	["spelldivineillumination"] = {spellID = 31842, itemID = 338404},
	["spelljudgementsofthepure"] = {spellID = 54155, itemID = 338404},
	["spellinfusionoflight"] = {spellID = 53576, itemID = 338404},
	["spellenlightenedjudgements"] = {spellID = 53557, itemID = 338404},
	["spellbeaconoflight"] = {spellID = 53563, itemID = 338404},
	["spelldivinity"] = {spellID = 63650, itemID = 338404},
	["spelldivinestrength"] = {spellID = 20266, itemID = 338404},
	
	-- Protection
	
	["spellstoicism"] = {spellID = 53519, itemID = 338404},
	["spellguardiansfavor"] = {spellID = 20175, itemID = 338404},
	["spellanticipation"] = {spellID = 20100, itemID = 338404},
	["spelldivinesacrifice"] = {spellID = 64205, itemID = 338404},
	["spellimprovedrighteousfury"] = {spellID = 20470, itemID = 338404},
	["spelltoughness"] = {spellID = 20147, itemID = 338404},
	["spelldivineguardian"] = {spellID = 53530, itemID = 338404},
	["spellimprovedhammerofjustice"] = {spellID = 20488, itemID = 338404},
	["spellimproveddevotionaura"] = {spellID = 20140, itemID = 338404},
	["spellblessingofsanctuary"] = {spellID = 20911, itemID = 338404},
	["spellreckoning"] = {spellID = 20182, itemID = 338404},
	["spellsacredduty"] = {spellID = 31849, itemID = 338404},
	["spellonehandedweaponspecialization"] = {spellID = 20198, itemID = 338404},
	
	-- Template 2
	
	["spellspiritualattunement"] = {spellID = 33776, itemID = 338404},
	["spellholyshield"] = {spellID = 20925, itemID = 338404},
	["spellardentdefender"] = {spellID = 31852, itemID = 338404},
	["spellredoubt"] = {spellID = 20135, itemID = 338404},
	["spellcombatexpertise"] = {spellID = 31860, itemID = 338404},
	["spelltouchedbythelight"] = {spellID = 53592, itemID = 338404},
	["spellavengersshield"] = {spellID = 31935, itemID = 338404},
	["spellguardedbythelight"] = {spellID = 53585, itemID = 338404},
	["spellthieldofthetemplar"] = {spellID = 53711, itemID = 338404},
	["spelljudgementsofthejust"] = {spellID = 53696, itemID = 338404},
	["spellhammeroftherighteous"] = {spellID = 53595, itemID = 338404},
	["spelldeflection"] = {spellID = 20064, itemID = 338404},
	["spellbenediction"] = {spellID = 20105, itemID = 338404},
	["spellimprovedjudgements"] = {spellID = 25957, itemID = 338404},
	
	-- Vindicte
	
	["spellheartofthecrusader"] = {spellID = 20337, itemID = 338404},
	["spellimprovedblessingofmight"] = {spellID = 20045, itemID = 338404},
	["spellindication"] = {spellID = 26016, itemID = 338404},--
	["spellconviction"] = {spellID = 20121, itemID = 338404},
	["spellsealofcommand"] = {spellID = 20375, itemID = 338404},
	["spellpursuitofjustice"] = {spellID = 26023, itemID = 338404},
	["spelleyeforaneye"] = {spellID = 25988, itemID = 338404},
	["spellsanctityofbattle"] = {spellID = 35397, itemID = 338404},
	["spellcrusade"] = {spellID = 31868, itemID = 338404},
	["spelltwohandedweaponspecialization"] = {spellID = 20113, itemID = 338404},
	["spellsanctifiedretribution"] = {spellID = 31869, itemID = 338404},
	["spellvengeance"] = {spellID = 20057, itemID = 338404},
	["spelldivinepurpose"] = {spellID = 31872, itemID = 338404},
	["spelltheartofwar"] = {spellID = 53488, itemID = 338404},
	["spellrepentance"] = {spellID = 20066, itemID = 338404},
	["spelljudgementsofthewise"] = {spellID = 31878, itemID = 338404},
	["spellfanaticism"] = {spellID = 31881, itemID = 338404},
	["spellsanctifiedwrath"] = {spellID = 53376, itemID = 338404},
	["spellswiftretribution"] = {spellID = 53648, itemID = 338404},
	["spellcrusaderstrike"] = {spellID = 35395, itemID = 338404},
	["spellsheathoflight"] = {spellID = 53503, itemID = 338404},
	["spellrighteousvengeance"] = {spellID = 53382, itemID = 338404},
	["spelldivinestorm"] = {spellID = 53385, itemID = 338404},
}

-- Accesseur item talent (GetItemCount est l'API Eluna correcte)
local function GetTalentItemCount(player)
    return player:GetItemCount(338404)
end

-- Accesseur par GUID pour éviter la collision multi-joueurs
local function GetSpendList(player)
    local guid = player:GetGUIDLow()
    if not TalentPaladinPointsSpend[guid] then
        TalentPaladinPointsSpend[guid] = {}
    end
    return TalentPaladinPointsSpend[guid]
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

                AIO.Handle(player, "TalentPaladinspell", "UpdateTalentCount", #spendList, MAX_TALENTS)
                AIO.Handle(player, "TalentPaladinspell", "UpdateTalentItemCount", GetTalentItemCount(player))

                local learnedSpells = {}
                learnedSpells[talentHandler] = true
                AIO.Handle(player, "TalentPaladinspell", "UpdateLearnedTalents", learnedSpells)
            end
        else
            player:SendAreaTriggerMessage("|cffff0000Vous n'avez pas de point de talent !|r")
            AIO.Handle(player, "TalentPaladinspell", "UpdateTalentItemCount", GetTalentItemCount(player))
        end
    end
end

for talentName, talentData in pairs(talents) do
    PaladinHandlers[talentName] = function(player, item)
        LearnTalent(player, talentData, talentName)
    end
end

local function LoadTalentProgression(player)
    local guid = player:GetGUIDLow()
    TalentPaladinPointsSpend[guid] = {}
    local spendList    = TalentPaladinPointsSpend[guid]
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

    AIO.Handle(player, "TalentPaladinspell", "UpdateTalentCount", #spendList, MAX_TALENTS)

    -- Petit délai pour s'assurer que l'UI client est chargée avant d'envoyer l'état
    player:RegisterEvent(function(eventId, delay, repeats, pPlayer)
        AIO.Handle(pPlayer, "TalentPaladinspell", "UpdateLearnedTalents", learnedSpells)
        AIO.Handle(pPlayer, "TalentPaladinspell", "UpdateTalentItemCount", GetTalentItemCount(pPlayer))
    end, 10, 1)
end

PaladinHandlers.RequestLearnedTalents = function(player)
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
    AIO.Handle(player, "TalentPaladinspell", "UpdateLearnedTalents", learnedSpells)
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

PaladinHandlers.GetTalentItemCount = function(player)
    AIO.Handle(player, "TalentPaladinspell", "UpdateTalentItemCount", GetTalentItemCount(player))
end

local function ResetTalentProgression(player)
    CharDBQuery("DELETE FROM character_talentspell WHERE guid = " .. player:GetGUIDLow() .. " AND account_id = " .. player:GetAccountId() .. ";")
end

PaladinHandlers.ResetTalents = function(player)
    local spendList        = GetSpendList(player)
    local pointsBeforeReset = #spendList

    for talentName, talentData in pairs(talents) do
        player:RemoveSpell(talentData.spellID)
    end

    local guid = player:GetGUIDLow()
    TalentPaladinPointsSpend[guid] = {}
    ResetTalentProgression(player)

    AIO.Handle(player, "TalentPaladinspell", "ResetAllButtons")
    AIO.Handle(player, "TalentPaladinspell", "UpdateTalentCount", 0, MAX_TALENTS)
    AIO.Handle(player, "TalentPaladinspell", "UpdateTalentPointsUsed", 0, pointsBeforeReset)

    player:AddItem(338404, pointsBeforeReset)
    AIO.Handle(player, "TalentPaladinspell", "UpdateTalentItemCount", GetTalentItemCount(player))
end