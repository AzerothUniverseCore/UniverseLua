local AIO = AIO or require("AIO")
local RogueHandlers = AIO.AddHandlers("TalentRoguespell", {})
local TalentRoguePointsSpend = {}

local MAX_TALENTS = 70

local talents = {
	-- Template 1

	-- Assassinat
	
	["spellimprovedeviscerate"] = {spellID = 14164, itemID = 338404},
	["spellremorselessattacks"] = {spellID = 14148, itemID = 338404},
	["spellmalice"] = {spellID = 14142, itemID = 338404},
	["spellruthlessness"] = {spellID = 14161, itemID = 338404},
	["spellbloodspatter"] = {spellID = 51633, itemID = 338404},
	["spellpuncturingwounds"] = {spellID = 13866, itemID = 338404},
	["spellvigor"] = {spellID = 14983, itemID = 338404},
	["spellimprovedexposearmor"] = {spellID = 14169, itemID = 338404},
	["spelllethality"] = {spellID = 14137, itemID = 338404},
	["spellvilepoisons"] = {spellID = 16515, itemID = 338404},
	["spellimprovedpoisons"] = {spellID = 14117, itemID = 338404},
	["spellfleetfooted"] = {spellID = 31209, itemID = 338404},
	["spellcoldblood"] = {spellID = 14177, itemID = 338404},
	["spellimprovedkidneyshot"] = {spellID = 14176, itemID = 338404},
	["spellquickrecovery"] = {spellID = 31245, itemID = 338404},
	["spellsealfate"] = {spellID = 14195, itemID = 338404},
	["spellmurder"] = {spellID = 14159, itemID = 338404},
	["spelldeadlybrew"] = {spellID = 51626, itemID = 338404},
	["spelloverkill"] = {spellID = 58426, itemID = 338404},
	["spelldeadenednerves"] = {spellID = 31383, itemID = 338404},
	["spellfocusedattacks"] = {spellID = 51636, itemID = 338404},
	["spellfindweakness"] = {spellID = 31236, itemID = 338404},
	["spellmasterpoisoner"] = {spellID = 58410, itemID = 338404},
	["spellmutilate"] = {spellID = 1329, itemID = 338404},
	["spellturnthetables"] = {spellID = 51629, itemID = 338404},
	["spellcuttothechase"] = {spellID = 51669, itemID = 338404},
	["spellhungerforblood"] = {spellID = 51662, itemID = 338404},
	
	-- Combat
	
	["spellimprovedgouge"] = {spellID = 13792, itemID = 338404},
	["spellimprovedsinisterstrike"] = {spellID = 13863, itemID = 338404},
	["spelldualwieldspecialization"] = {spellID = 13852, itemID = 338404},
	["spelldualcrimsonvial"] = {spellID = 248777, itemID = 338404},
	["spellimprovedsliceanddice"] = {spellID = 14166, itemID = 338404},
	["spelldeflection"] = {spellID = 13854, itemID = 338404},
	["spellprecision"] = {spellID = 13845, itemID = 338404},
	["spellendurance"] = {spellID = 13872, itemID = 338404},
	["spellriposte"] = {spellID = 14251, itemID = 338404},
	["spellclosequarterscombat"] = {spellID = 13807, itemID = 338404},
	["spellimprovedkick"] = {spellID = 13867, itemID = 338404},
	["spellrecuperate"] = {spellID = 73651, itemID = 338404},
	["spellimprovedsprint"] = {spellID = 13875, itemID = 338404},
	["spelllightningreflexes"] = {spellID = 13789, itemID = 338404},
	["spellaggression"] = {spellID = 61331, itemID = 338404},
	["spellmacespecialization"] = {spellID = 13803, itemID = 338404},
	["spellbladeflurry"] = {spellID = 13877, itemID = 338404},
	["spellhackandslash"] = {spellID = 13964, itemID = 338404},
	
	-- Template 2
	
	["spellweaponexpertise"] = {spellID = 30920, itemID = 338404},
	["spellbladetwisting"] = {spellID = 31126, itemID = 338404},
	["spellvitality"] = {spellID = 61329, itemID = 338404},
	["spelladrenalinerush"] = {spellID = 13750, itemID = 338404},
	["spellnervesofsteel"] = {spellID = 31131, itemID = 338404},
	["spellthrowingspecialization"] = {spellID = 51679, itemID = 338404},
	["spellcombatpotency"] = {spellID = 35553, itemID = 338404},
	["spellunfairadvantage"] = {spellID = 51674, itemID = 338404},
	["spellsurpriseattacks"] = {spellID = 32601, itemID = 338404},
	["spellsavagecombat"] = {spellID = 58413, itemID = 338404},
	["spellpreyontheweak"] = {spellID = 51689, itemID = 338404},
	["spellkillingspree"] = {spellID = 51690, itemID = 338404},
	["spellshroudofconcealment"] = {spellID = 114018, itemID = 338404},
	
	-- Finesse
	
	["spellrelentlessstrikes"] = {spellID = 58425, itemID = 338404},
	["spellmasterofdeception"] = {spellID = 13971, itemID = 338404},
	["spellopportunity"] = {spellID = 14072, itemID = 338404},
	["spellsleightofhand"] = {spellID = 30893, itemID = 338404},
	["spelldirtytricks"] = {spellID = 14094, itemID = 338404},
	["spellcamouflage"] = {spellID = 14063, itemID = 338404},
	["spellelusiveness"] = {spellID = 14066, itemID = 338404},
	["spellghostlystrike"] = {spellID = 14278, itemID = 338404},
	["spellserratedblades"] = {spellID = 14173, itemID = 338404},
	["spellsetup"] = {spellID = 14071, itemID = 338404},
	["spellinitiative"] = {spellID = 13980, itemID = 338404},
	["spellimprovedambush"] = {spellID = 14080, itemID = 338404},
	["spellheightenedsenses"] = {spellID = 30895, itemID = 338404},
	["spellpreparation"] = {spellID = 14185, itemID = 338404},
	["spelldirtydeeds"] = {spellID = 14083, itemID = 338404},
	["spellhemorrhage"] = {spellID = 16511, itemID = 338404},
	["spellmasterofsubtlety"] = {spellID = 31223, itemID = 338404},
	["spelldeadliness"] = {spellID = 30906, itemID = 338404},
	["spellenvelopingshadows"] = {spellID = 31213, itemID = 338404},
	["spellpremeditation"] = {spellID = 14183, itemID = 338404},
	["spellcheatdeath"] = {spellID = 31230, itemID = 338404},
	["spellshadowblades"] = {spellID = 121471, itemID = 338404},
	["spellsinistercalling"] = {spellID = 31220, itemID = 338404},
	["spellwaylay"] = {spellID = 51696, itemID = 338404},
	["spellhonoramongthieves"] = {spellID = 51701, itemID = 338404},
	["spellshadowstep"] = {spellID = 36554, itemID = 338404},
	["spellfilthytricks"] = {spellID = 58415, itemID = 338404},
	["spellslaughterfromtheshadows"] = {spellID = 51712, itemID = 338404},
	["spellshadowdance"] = {spellID = 51713, itemID = 338404},
	
}

-- Accesseur item talent (GetItemCount est l'API Eluna correcte)
local function GetTalentItemCount(player)
    return player:GetItemCount(338404)
end

-- Accesseur par GUID pour éviter la collision multi-joueurs
local function GetSpendList(player)
    local guid = player:GetGUIDLow()
    if not TalentRoguePointsSpend[guid] then
        TalentRoguePointsSpend[guid] = {}
    end
    return TalentRoguePointsSpend[guid]
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

                AIO.Handle(player, "TalentRoguespell", "UpdateTalentCount", #spendList, MAX_TALENTS)
                AIO.Handle(player, "TalentRoguespell", "UpdateTalentItemCount", GetTalentItemCount(player))

                local learnedSpells = {}
                learnedSpells[talentHandler] = true
                AIO.Handle(player, "TalentRoguespell", "UpdateLearnedTalents", learnedSpells)
            end
        else
            player:SendAreaTriggerMessage("|cffff0000Vous n'avez pas de point de talent !|r")
            AIO.Handle(player, "TalentRoguespell", "UpdateTalentItemCount", GetTalentItemCount(player))
        end
    end
end

for talentName, talentData in pairs(talents) do
    RogueHandlers[talentName] = function(player, item)
        LearnTalent(player, talentData, talentName)
    end
end

local function LoadTalentProgression(player)
    local guid = player:GetGUIDLow()
    TalentRoguePointsSpend[guid] = {}
    local spendList    = TalentRoguePointsSpend[guid]
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

    AIO.Handle(player, "TalentRoguespell", "UpdateTalentCount", #spendList, MAX_TALENTS)

    -- Petit délai pour s'assurer que l'UI client est chargée avant d'envoyer l'état
    player:RegisterEvent(function(eventId, delay, repeats, pPlayer)
        AIO.Handle(pPlayer, "TalentRoguespell", "UpdateLearnedTalents", learnedSpells)
        AIO.Handle(pPlayer, "TalentRoguespell", "UpdateTalentItemCount", GetTalentItemCount(pPlayer))
    end, 10, 1)
end

RogueHandlers.RequestLearnedTalents = function(player)
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
    AIO.Handle(player, "TalentRoguespell", "UpdateLearnedTalents", learnedSpells)
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

RogueHandlers.GetTalentItemCount = function(player)
    AIO.Handle(player, "TalentRoguespell", "UpdateTalentItemCount", GetTalentItemCount(player))
end

local function ResetTalentProgression(player)
    CharDBQuery("DELETE FROM character_talentspell WHERE guid = " .. player:GetGUIDLow() .. " AND account_id = " .. player:GetAccountId() .. ";")
end

RogueHandlers.ResetTalents = function(player)
    local spendList        = GetSpendList(player)
    local pointsBeforeReset = #spendList

    for talentName, talentData in pairs(talents) do
        player:RemoveSpell(talentData.spellID)
    end

    local guid = player:GetGUIDLow()
    TalentRoguePointsSpend[guid] = {}
    ResetTalentProgression(player)

    AIO.Handle(player, "TalentRoguespell", "ResetAllButtons")
    AIO.Handle(player, "TalentRoguespell", "UpdateTalentCount", 0, MAX_TALENTS)
    AIO.Handle(player, "TalentRoguespell", "UpdateTalentPointsUsed", 0, pointsBeforeReset)

    player:AddItem(338404, pointsBeforeReset)
    AIO.Handle(player, "TalentRoguespell", "UpdateTalentItemCount", GetTalentItemCount(player))
end