local AIO = AIO or require("AIO")
local ShamanHandlers = AIO.AddHandlers("TalentShamanspell", {})
local TalentShamanPointsSpend = {}

local MAX_TALENTS = 60

local talents = {
	-- Template 1

	-- Elémentaire
	
	["spellconvection"] = {spellID = 16112, itemID = 338404},
	["spellconcussion"] = {spellID = 16108, itemID = 338404},
	["spellcallofflame"] = {spellID = 16161, itemID = 338404},
	["spellelementalwarding"] = {spellID = 28998, itemID = 338404},
	["spellelementaldevastation"] = {spellID = 29180, itemID = 338404},
	["spellreverberation"] = {spellID = 16116, itemID = 338404},
	["spellelementalfocus"] = {spellID = 16164, itemID = 338404},
	["spellelementalfury"] = {spellID = 60188, itemID = 338404},
	["spellimprovedfirenova"] = {spellID = 16544, itemID = 338404},
	["spelleyeofthestorm"] = {spellID = 29065, itemID = 338404},
	["spellelementalreach"] = {spellID = 29000, itemID = 338404},
	["spellcallofthunder"] = {spellID = 16041, itemID = 338404},
	["spellunrelentingstorm"] = {spellID = 30666, itemID = 338404},
	["spellelementalprecision"] = {spellID = 30674, itemID = 338404},
	["spelllightningmastery"] = {spellID = 16582, itemID = 338404},
	["spellelementalmastery"] = {spellID = 16166, itemID = 338404},
	["spellstormearthandfire"] = {spellID = 51486, itemID = 338404},
	["spellboomingechoes"] = {spellID = 63372, itemID = 338404},
	["spellelementaloath"] = {spellID = 51470, itemID = 338404},
	["spelllightningoverload"] = {spellID = 30679, itemID = 338404},
	["spellastralshift"] = {spellID = 51479, itemID = 338404},
	["spelltotemofwrath"] = {spellID = 30706, itemID = 338404},
	["spelllavaflows"] = {spellID = 51482, itemID = 338404},
	["spellshamanism"] = {spellID = 62101, itemID = 338404},
	["spellthunderstorm"] = {spellID = 51490, itemID = 338404},
	["spellenhancingtotems"] = {spellID = 52456, itemID = 338404},
	["spellearthsgrasp"] = {spellID = 16130, itemID = 338404},
	["spellancestralknowledge"] = {spellID = 17489, itemID = 338404},
	
	-- Amélioration
	
	["spellguardiantotems"] = {spellID = 16293, itemID = 338404},
	["spellthunderingstrikes"] = {spellID = 16305, itemID = 338404},
	["spellimprovedghostwolf"] = {spellID = 16287, itemID = 338404},
	["spellimprovedshields"] = {spellID = 51881, itemID = 338404},
	["spellelementalweapons"] = {spellID = 29080, itemID = 338404},
	["spellshamanisticfocus"] = {spellID = 43338, itemID = 338404},
	["spellanticipation"] = {spellID = 16272, itemID = 338404},
	["spellflurry"] = {spellID = 16284, itemID = 338404},
	["spelltoughness"] = {spellID = 16309, itemID = 338404},
	["spellimprovedwindfurytotem"] = {spellID = 29193, itemID = 338404},
	["spellspiritweapons"] = {spellID = 16268, itemID = 338404},
	["spellmentaldexterity"] = {spellID = 51885, itemID = 338404},
	["spellunleashedrage"] = {spellID = 30809, itemID = 338404},
	
	-- Template 2
	
	["spellweaponmastery"] = {spellID = 29086, itemID = 338404},
	["spellfrozenpower"] = {spellID = 63374, itemID = 338404},
	["spelldualwieldspecialization"] = {spellID = 30819, itemID = 338404},
	["spelldualwield"] = {spellID = 30798, itemID = 338404},
	["spellstormstrike"] = {spellID = 17364, itemID = 338404},
	["spellstaticshock"] = {spellID = 51527, itemID = 338404},
	["spelllavalash"] = {spellID = 60103, itemID = 338404},
	["spellimprovedstormstrike"] = {spellID = 51522, itemID = 338404},
	["spellmentalquickness"] = {spellID = 30814, itemID = 338404},
	["spellshamanisticrage"] = {spellID = 30823, itemID = 338404},
	["spellearthenpower"] = {spellID = 51524, itemID = 338404},
	["spellmaelstromweapon"] = {spellID = 51532, itemID = 338404},
	["spellferalspirit"] = {spellID = 51533, itemID = 338404},
	["spellimprovedhealingwave"] = {spellID = 16229, itemID = 338404},
	
	-- Ombre
	
	["spelltotemicfocus"] = {spellID = 16225, itemID = 338404},
	["spellimprovedreincarnation"] = {spellID = 16209, itemID = 338404},
	["spellhealinggrace"] = {spellID = 29191, itemID = 338404},--
	["spelltidalfocus"] = {spellID = 16217, itemID = 338404},
	["spellimprovedwatershield"] = {spellID = 16198, itemID = 338404},
	["spellhealingfocus"] = {spellID = 16232, itemID = 338404},
	["spelltidalforce"] = {spellID = 55198, itemID = 338404},
	["spellancestralhealing"] = {spellID = 16240, itemID = 338404},
	["spellrestorativetotems"] = {spellID = 16206, itemID = 338404},
	["spelltidalmastery"] = {spellID = 16221, itemID = 338404},
	["spellhealingway"] = {spellID = 29202, itemID = 338404},
	["spellnaturesswiftness"] = {spellID = 16188, itemID = 338404},
	["spellfocusedmind"] = {spellID = 30866, itemID = 338404},
	["spellpurificatione"] = {spellID = 16213, itemID = 338404},
	["spellnaturesguardian"] = {spellID = 30886, itemID = 338404},
	["spellmanatidetotem"] = {spellID = 16190, itemID = 338404},
	["spellcleansespirit"] = {spellID = 51886, itemID = 338404},
	["spellblessingoftheeternals"] = {spellID = 51555, itemID = 338404},
	["spellimprovedchainheal"] = {spellID = 30873, itemID = 338404},
	["spellnaturesblessing"] = {spellID = 30869, itemID = 338404},
	["spellancestralawakening"] = {spellID = 51558, itemID = 338404},
	["spellearthshield"] = {spellID = 974, itemID = 338404},
	["spellimprovedearthshield"] = {spellID = 51561, itemID = 338404},
	["spelltidalwaves"] = {spellID = 51566, itemID = 338404},
	["spellriptide"] = {spellID = 61295, itemID = 338404},
	
}

-- Accesseur item talent (GetItemCount est l'API Eluna correcte)
local function GetTalentItemCount(player)
    return player:GetItemCount(338404)
end

-- Accesseur par GUID pour éviter la collision multi-joueurs
local function GetSpendList(player)
    local guid = player:GetGUIDLow()
    if not TalentShamanPointsSpend[guid] then
        TalentShamanPointsSpend[guid] = {}
    end
    return TalentShamanPointsSpend[guid]
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

                AIO.Handle(player, "TalentShamanspell", "UpdateTalentCount", #spendList, MAX_TALENTS)
                AIO.Handle(player, "TalentShamanspell", "UpdateTalentItemCount", GetTalentItemCount(player))

                local learnedSpells = {}
                learnedSpells[talentHandler] = true
                AIO.Handle(player, "TalentShamanspell", "UpdateLearnedTalents", learnedSpells)
            end
        else
            player:SendAreaTriggerMessage("|cffff0000Vous n'avez pas de point de talent !|r")
            AIO.Handle(player, "TalentShamanspell", "UpdateTalentItemCount", GetTalentItemCount(player))
        end
    end
end

for talentName, talentData in pairs(talents) do
    ShamanHandlers[talentName] = function(player, item)
        LearnTalent(player, talentData, talentName)
    end
end

local function LoadTalentProgression(player)
    local guid = player:GetGUIDLow()
    TalentShamanPointsSpend[guid] = {}
    local spendList    = TalentShamanPointsSpend[guid]
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

    AIO.Handle(player, "TalentShamanspell", "UpdateTalentCount", #spendList, MAX_TALENTS)

    -- Petit délai pour s'assurer que l'UI client est chargée avant d'envoyer l'état
    player:RegisterEvent(function(eventId, delay, repeats, pPlayer)
        AIO.Handle(pPlayer, "TalentShamanspell", "UpdateLearnedTalents", learnedSpells)
        AIO.Handle(pPlayer, "TalentShamanspell", "UpdateTalentItemCount", GetTalentItemCount(pPlayer))
    end, 10, 1)
end

ShamanHandlers.RequestLearnedTalents = function(player)
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
    AIO.Handle(player, "TalentShamanspell", "UpdateLearnedTalents", learnedSpells)
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

ShamanHandlers.GetTalentItemCount = function(player)
    AIO.Handle(player, "TalentShamanspell", "UpdateTalentItemCount", GetTalentItemCount(player))
end

local function ResetTalentProgression(player)
    CharDBQuery("DELETE FROM character_talentspell WHERE guid = " .. player:GetGUIDLow() .. " AND account_id = " .. player:GetAccountId() .. ";")
end

ShamanHandlers.ResetTalents = function(player)
    local spendList        = GetSpendList(player)
    local pointsBeforeReset = #spendList

    for talentName, talentData in pairs(talents) do
        player:RemoveSpell(talentData.spellID)
    end

    local guid = player:GetGUIDLow()
    TalentShamanPointsSpend[guid] = {}
    ResetTalentProgression(player)

    AIO.Handle(player, "TalentShamanspell", "ResetAllButtons")
    AIO.Handle(player, "TalentShamanspell", "UpdateTalentCount", 0, MAX_TALENTS)
    AIO.Handle(player, "TalentShamanspell", "UpdateTalentPointsUsed", 0, pointsBeforeReset)

    player:AddItem(338404, pointsBeforeReset)
    AIO.Handle(player, "TalentShamanspell", "UpdateTalentItemCount", GetTalentItemCount(player))
end