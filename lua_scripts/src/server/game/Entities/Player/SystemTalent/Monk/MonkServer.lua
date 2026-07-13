local AIO = AIO or require("AIO")
local MonkHandlers = AIO.AddHandlers("TalentMonkspell", {})
local TalentMonkPointsSpend = {}

local MAX_TALENTS = 60

local talents = {
	-- Template 1
    ["spellpurifyingbrew"] = {spellID = 119582, itemID = 338404},
    ["spellkegsmash"] = {spellID = 121253, itemID = 338404},
    ["spellascension"] = {spellID = 115396, itemID = 338404},
	["spellgiftox"] = {spellID = 124502, itemID = 338404},
	["spellphysicssphere"] = {spellID = 1115460, itemID = 338404},
	["spellflyingmonk"] = {spellID = 11007428, itemID = 338404},
	["spelltigerhits"] = {spellID = 1100787, itemID = 338404},
	["spelldampenharm"] = {spellID = 1122278, itemID = 338404},
	["spelldizzyinghaze"] = {spellID = 115180, itemID = 338404},
	["spellfortifyingbrew"] = {spellID = 1126456, itemID = 338404},
	["spelllegsweep"] = {spellID = 1119381, itemID = 338404},
	["spellguard"] = {spellID = 115295, itemID = 338404},
	["spelllegacyemperor"] = {spellID = 1117666, itemID = 338404},
	["spelldetox"] = {spellID = 1215450, itemID = 338404},
	-- Template 2
	["spelladaptation"] = {spellID = 126046, itemID = 338404},
	["spellchibarrage"] = {spellID = 144644, itemID = 338404},
	["spellmonksleap"] = {spellID = 124008, itemID = 338404},
	["spellnimblebrew"] = {spellID = 137562, itemID = 338404},
	["spellpunch"] = {spellID = 109079, itemID = 338404},
	["spellblackoutkick"] = {spellID = 109080, itemID = 338404},
	["spellrisingsunkick"] = {spellID = 107428, itemID = 338404},
	["spellexpelharm"] = {spellID = 115072, itemID = 338404},
	["spellcracklingjadethunderstorm"] = {spellID = 144076, itemID = 338404},
	["spelldisable"] = {spellID = 116095, itemID = 338404},
	["spellringpeace"] = {spellID = 116844, itemID = 338404},
	["spelllifecocoon"] = {spellID = 1216849, itemID = 338404},
	["spellspinningcranekick"] = {spellID = 130767, itemID = 338404},
	["spellwhitetigerlegacy"] = {spellID = 116781, itemID = 338404},
	["spellspearhandstrike"] = {spellID = 116705, itemID = 338404},
	["spelldiffusemagic"] = {spellID = 122783, itemID = 338404},
	["spellflyingserpentkick"] = {spellID = 107427, itemID = 338404},
	["spellzenmeditation"] = {spellID = 115176, itemID = 338404},
	["spellsoothingmist"] = {spellID = 115175, itemID = 338404},
	["spellenvelopingmist"] = {spellID = 124682, itemID = 338404},
	["spellrenewingmist"] = {spellID = 115151, itemID = 338404},
	["spellsurgingmist"] = {spellID = 116694, itemID = 338404},
	["spellchiwave"] = {spellID = 1215098, itemID = 338404},
	["spellspinningfireblossom"] = {spellID = 115073, itemID = 338404},
	["spelluplift"] = {spellID = 116670, itemID = 338404},
	["spellsummonjadeserpentstatue"] = {spellID = 115313, itemID = 338404},
	["spelltouchkarma"] = {spellID = 122470, itemID = 338404},
	["spelltouchdeath"] = {spellID = 115080, itemID = 338404},
	["spelltranscendance"] = {spellID = 480190, itemID = 338404},
	["spelltranscendanceback"] = {spellID = 480030, itemID = 338404},
	["spellhealingsphere"] = {spellID = 115460, itemID = 338404},
	["spellresuscitate"] = {spellID = 1215178, itemID = 338404},
	["spellparalysis"] = {spellID = 115078, itemID = 338404},
	["spellzenpilgrimage"] = {spellID = 126897, itemID = 338404},
	["spellfistsfury"] = {spellID = 119014, itemID = 338404},
	["spellenergizingelixir"] = {spellID = 115288, itemID = 338404},
	["spelltigerslust"] = {spellID = 116841, itemID = 338404},
	["spellinvokexuenwhitetiger"] = {spellID = 68888, itemID = 338404},
	["spelltigereyebrew"] = {spellID = 116740, itemID = 338404},
	["spellcombatconditioning"] = {spellID = 128595, itemID = 338404},
	["spellrevival"] = {spellID = 115310, itemID = 338404},
	["spellprovoke"] = {spellID = 1116189, itemID = 338404},
	["spellsummonblackoxstatue"] = {spellID = 115315, itemID = 338404},
	["spellevilprevention"] = {spellID = 115213, itemID = 338404},
	["spellbreathfire"] = {spellID = 115181, itemID = 338404},
	["spellparry"] = {spellID = 116812, itemID = 338404},
	["spellthunderfocustea"] = {spellID = 116680, itemID = 338404},
	["spellstealweapon"] = {spellID = 117368, itemID = 338404},
	["spellfermentationelusiveinfusion"] = {spellID = 128938, itemID = 338404},
	["spellironskinbrew"] = {spellID = 115308, itemID = 338404},
	["spellclash"] = {spellID = 122057, itemID = 338404},
	["spellmasterbrewertraining"] = {spellID = 117967, itemID = 338404},
	["spellmasteryelusivebrawler"] = {spellID = 117906, itemID = 338404},
	["spellswiftreflexes"] = {spellID = 124334, itemID = 338404},
	["spelldesperatemeasures"] = {spellID = 126060, itemID = 338404},
	["spellstandoff"] = {spellID = 116023, itemID = 338404},
	["spellmasterycombostrikes"] = {spellID = 115636, itemID = 338404},
	["spellmusclememory"] = {spellID = 139598, itemID = 338404},
	["spellinternalmedicine"] = {spellID = 115451, itemID = 338404},
	["spellmanameditation"] = {spellID = 121278, itemID = 338404},
	["spellmanatea"] = {spellID = 115294, itemID = 338404},
	["spellteachingsmonastery"] = {spellID = 116645, itemID = 338404},
	["spellmasterygiftserpent"] = {spellID = 117907, itemID = 338404},
}

-- Accesseur item talent (GetItemCount est l'API Eluna correcte)
local function GetTalentItemCount(player)
    return player:GetItemCount(338404)
end

-- Accesseur par GUID pour éviter la collision multi-joueurs
local function GetSpendList(player)
    local guid = player:GetGUIDLow()
    if not TalentMonkPointsSpend[guid] then
        TalentMonkPointsSpend[guid] = {}
    end
    return TalentMonkPointsSpend[guid]
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

                AIO.Handle(player, "TalentMonkspell", "UpdateTalentCount", #spendList, MAX_TALENTS)
                AIO.Handle(player, "TalentMonkspell", "UpdateTalentItemCount", GetTalentItemCount(player))

                local learnedSpells = {}
                learnedSpells[talentHandler] = true
                AIO.Handle(player, "TalentMonkspell", "UpdateLearnedTalents", learnedSpells)
            end
        else
            player:SendAreaTriggerMessage("|cffff0000Vous n'avez pas de point de talent !|r")
            AIO.Handle(player, "TalentMonkspell", "UpdateTalentItemCount", GetTalentItemCount(player))
        end
    end
end

for talentName, talentData in pairs(talents) do
    MonkHandlers[talentName] = function(player, item)
        LearnTalent(player, talentData, talentName)
    end
end

local function LoadTalentProgression(player)
    local guid = player:GetGUIDLow()
    TalentMonkPointsSpend[guid] = {}
    local spendList    = TalentMonkPointsSpend[guid]
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

    AIO.Handle(player, "TalentMonkspell", "UpdateTalentCount", #spendList, MAX_TALENTS)

    -- Petit délai pour s'assurer que l'UI client est chargée avant d'envoyer l'état
    player:RegisterEvent(function(eventId, delay, repeats, pPlayer)
        AIO.Handle(pPlayer, "TalentMonkspell", "UpdateLearnedTalents", learnedSpells)
        AIO.Handle(pPlayer, "TalentMonkspell", "UpdateTalentItemCount", GetTalentItemCount(pPlayer))
    end, 10, 1)
end

MonkHandlers.RequestLearnedTalents = function(player)
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
    AIO.Handle(player, "TalentMonkspell", "UpdateLearnedTalents", learnedSpells)
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

MonkHandlers.GetTalentItemCount = function(player)
    AIO.Handle(player, "TalentMonkspell", "UpdateTalentItemCount", GetTalentItemCount(player))
end

local function ResetTalentProgression(player)
    CharDBQuery("DELETE FROM character_talentspell WHERE guid = " .. player:GetGUIDLow() .. " AND account_id = " .. player:GetAccountId() .. ";")
end

MonkHandlers.ResetTalents = function(player)
    local spendList        = GetSpendList(player)
    local pointsBeforeReset = #spendList

    for talentName, talentData in pairs(talents) do
        player:RemoveSpell(talentData.spellID)
    end

    local guid = player:GetGUIDLow()
    TalentMonkPointsSpend[guid] = {}
    ResetTalentProgression(player)

    AIO.Handle(player, "TalentMonkspell", "ResetAllButtons")
    AIO.Handle(player, "TalentMonkspell", "UpdateTalentCount", 0, MAX_TALENTS)
    AIO.Handle(player, "TalentMonkspell", "UpdateTalentPointsUsed", 0, pointsBeforeReset)

    player:AddItem(338404, pointsBeforeReset)
    AIO.Handle(player, "TalentMonkspell", "UpdateTalentItemCount", GetTalentItemCount(player))
end