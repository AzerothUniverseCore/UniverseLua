local AIO = AIO or require("AIO")
local WarlockHandlers = AIO.AddHandlers("TalentWarlockspell", {})
local TalentWarlockPointsSpend = {}

local MAX_TALENTS = 60

local talents = {
	-- Template 1

	-- Affliction
	
	["spellimprovedcurseofagony"] = {spellID = 18829, itemID = 338404},
	["spellsuppression"] = {spellID = 18176, itemID = 338404},
	["spellimprovedcorruption"] = {spellID = 17814, itemID = 338404},
	["spellimprovedcurseofweakness"] = {spellID = 18180, itemID = 338404},
	["spellimproveddrainsoul"] = {spellID = 18372, itemID = 338404},
	["spellimprovedlifetap"] = {spellID = 18183, itemID = 338404},
	["spellsoulsiphon"] = {spellID = 17805, itemID = 338404},
	["spellimprovedfear"] = {spellID = 53759, itemID = 338404},
	["spelllfelconcentration"] = {spellID = 17785, itemID = 338404},
	["spellamplifycurse"] = {spellID = 18288, itemID = 338404},
	["spellgrimreach"] = {spellID = 18219, itemID = 338404},
	["spellnightfall"] = {spellID = 18095, itemID = 338404},
	["spellempoweredcorruption"] = {spellID = 32383, itemID = 338404},
	["spellshadowembrace"] = {spellID = 32394, itemID = 338404},
	["spellsiphonlife"] = {spellID = 63108, itemID = 338404},
	["spellcurseofexhaustion"] = {spellID = 18223, itemID = 338404},
	["spellimprovedfelhunter"] = {spellID = 54038, itemID = 338404},
	["spellshadowmastery"] = {spellID = 18275, itemID = 338404},
	["spelleradication"] = {spellID = 47197, itemID = 338404},
	["spellcontagion"] = {spellID = 30064, itemID = 338404},
	["spelldarkpact"] = {spellID = 18220, itemID = 338404},
	["spellimprovedhowlofterror"] = {spellID = 30057, itemID = 338404},
	["spellmalediction"] = {spellID = 32484, itemID = 338404},
	["spelldeathsembrace"] = {spellID = 47200, itemID = 338404},
	["spellunstableaffliction"] = {spellID = 30108, itemID = 338404},
	["spellpandemic"] = {spellID = 58435, itemID = 338404},
	["spelleverlastingaffliction"] = {spellID = 47205, itemID = 338404},
	["spellhaunt"] = {spellID = 48181, itemID = 338404},
	
	-- Démonologie
	
	["spellimprovedhealthstone"] = {spellID = 18693, itemID = 338404},
	["spellimprovedimp"] = {spellID = 18696, itemID = 338404},
	["spelldemonicembrace"] = {spellID = 18699, itemID = 338404},
	["spellfelsynergy"] = {spellID = 47231, itemID = 338404},
	["spellimprovedhealthfunnel"] = {spellID = 18704, itemID = 338404},
	["spelldemonicbrutality"] = {spellID = 18707, itemID = 338404},
	["spellfelvitality"] = {spellID = 18744, itemID = 338404},
	["spellimprovedsayaad"] = {spellID = 18756, itemID = 338404},
	["spellsoullink"] = {spellID = 19028, itemID = 338404},
	["spellfeldomination"] = {spellID = 18708, itemID = 338404},
	["spelldemonicaegis"] = {spellID = 30145, itemID = 338404},
	["spellunholypower"] = {spellID = 18773, itemID = 338404},
	["spellmastersummoner"] = {spellID = 18710, itemID = 338404},
	
	-- Template 2
	
	["spellmanafeed"] = {spellID = 30326, itemID = 338404},
	["spellmasterconjuror"] = {spellID = 18768, itemID = 338404},
	["spellmasterdemonologist"] = {spellID = 23825, itemID = 338404},
	["spellmoltencore"] = {spellID = 47247, itemID = 338404},
	["spelldemonicresilience"] = {spellID = 30321, itemID = 338404},
	["spelldemonicempowerment"] = {spellID = 47193, itemID = 338404},
	["spelldemonicknowledge"] = {spellID = 35693, itemID = 338404},
	["spelldemonictactics"] = {spellID = 30248, itemID = 338404},
	["spelldecimation"] = {spellID = 63158, itemID = 338404},
	["spellimproveddemonictactics"] = {spellID = 54349, itemID = 338404},
	["spellsummonfelguard"] = {spellID = 30146, itemID = 338404},
	["spellnemesis"] = {spellID = 63123, itemID = 338404},
	["spelldemonicpact"] = {spellID = 47240, itemID = 338404},
	["spellmetamorphosis"] = {spellID = 59672, itemID = 338404},
	
	-- Destruction
	
	["spellimprovedshadowbolt"] = {spellID = 17803, itemID = 338404},
	["spellbane"] = {spellID = 17792, itemID = 338404},
	["spellaftermath"] = {spellID = 18120, itemID = 338404},--
	["spellmoltenskin"] = {spellID = 63351, itemID = 338404},
	["spellcataclysm"] = {spellID = 17780, itemID = 338404},
	["spelldemonicpower"] = {spellID = 18127, itemID = 338404},
	["spellshadowburn"] = {spellID = 17877, itemID = 338404},
	["spellruin"] = {spellID = 59741, itemID = 338404},
	["spellintensity"] = {spellID = 18136, itemID = 338404},
	["spelldestructivereach"] = {spellID = 17918, itemID = 338404},
	["spellimprovedsearingpain"] = {spellID = 17930, itemID = 338404},
	["spellbacklash"] = {spellID = 34939, itemID = 338404},
	["spellimprovedimmolate"] = {spellID = 17834, itemID = 338404},
	["spelldevastation"] = {spellID = 18130, itemID = 338404},
	["spellnetherprotection"] = {spellID = 30302, itemID = 338404},
	["spellemberstorm"] = {spellID = 17958, itemID = 338404},
	["spellconflagrate"] = {spellID = 17962, itemID = 338404},
	["spellsoulleech"] = {spellID = 30296, itemID = 338404},
	["spellpyroclasm"] = {spellID = 63245, itemID = 338404},
	["spellshadowandflame"] = {spellID = 30292, itemID = 338404},
	["spellimprovedsoulleech"] = {spellID = 54118, itemID = 338404},
	["spellbackdraft"] = {spellID = 47260, itemID = 338404},
	["spellshadowfury"] = {spellID = 30283, itemID = 338404},
	["spellempoweredimp"] = {spellID = 47223, itemID = 338404},
	["spellfireandbrimstone"] = {spellID = 47270, itemID = 338404},
	["spellchaosbolt"] = {spellID = 50796, itemID = 338404},
	
}

-- Accesseur item talent (GetItemCount est l'API Eluna correcte)
local function GetTalentItemCount(player)
    return player:GetItemCount(338404)
end

-- Accesseur par GUID pour éviter la collision multi-joueurs
local function GetSpendList(player)
    local guid = player:GetGUIDLow()
    if not TalentWarlockPointsSpend[guid] then
        TalentWarlockPointsSpend[guid] = {}
    end
    return TalentWarlockPointsSpend[guid]
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

                AIO.Handle(player, "TalentWarlockspell", "UpdateTalentCount", #spendList, MAX_TALENTS)
                AIO.Handle(player, "TalentWarlockspell", "UpdateTalentItemCount", GetTalentItemCount(player))

                local learnedSpells = {}
                learnedSpells[talentHandler] = true
                AIO.Handle(player, "TalentWarlockspell", "UpdateLearnedTalents", learnedSpells)
            end
        else
            player:SendAreaTriggerMessage("|cffff0000Vous n'avez pas de point de talent !|r")
            AIO.Handle(player, "TalentWarlockspell", "UpdateTalentItemCount", GetTalentItemCount(player))
        end
    end
end

for talentName, talentData in pairs(talents) do
    WarlockHandlers[talentName] = function(player, item)
        LearnTalent(player, talentData, talentName)
    end
end

local function LoadTalentProgression(player)
    local guid = player:GetGUIDLow()
    TalentWarlockPointsSpend[guid] = {}
    local spendList    = TalentWarlockPointsSpend[guid]
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

    AIO.Handle(player, "TalentWarlockspell", "UpdateTalentCount", #spendList, MAX_TALENTS)

    -- Petit délai pour s'assurer que l'UI client est chargée avant d'envoyer l'état
    player:RegisterEvent(function(eventId, delay, repeats, pPlayer)
        AIO.Handle(pPlayer, "TalentWarlockspell", "UpdateLearnedTalents", learnedSpells)
        AIO.Handle(pPlayer, "TalentWarlockspell", "UpdateTalentItemCount", GetTalentItemCount(pPlayer))
    end, 10, 1)
end

WarlockHandlers.RequestLearnedTalents = function(player)
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
    AIO.Handle(player, "TalentWarlockspell", "UpdateLearnedTalents", learnedSpells)
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

WarlockHandlers.GetTalentItemCount = function(player)
    AIO.Handle(player, "TalentWarlockspell", "UpdateTalentItemCount", GetTalentItemCount(player))
end

local function ResetTalentProgression(player)
    CharDBQuery("DELETE FROM character_talentspell WHERE guid = " .. player:GetGUIDLow() .. " AND account_id = " .. player:GetAccountId() .. ";")
end

WarlockHandlers.ResetTalents = function(player)
    local spendList        = GetSpendList(player)
    local pointsBeforeReset = #spendList

    for talentName, talentData in pairs(talents) do
        player:RemoveSpell(talentData.spellID)
    end

    local guid = player:GetGUIDLow()
    TalentWarlockPointsSpend[guid] = {}
    ResetTalentProgression(player)

    AIO.Handle(player, "TalentWarlockspell", "ResetAllButtons")
    AIO.Handle(player, "TalentWarlockspell", "UpdateTalentCount", 0, MAX_TALENTS)
    AIO.Handle(player, "TalentWarlockspell", "UpdateTalentPointsUsed", 0, pointsBeforeReset)

    player:AddItem(338404, pointsBeforeReset)
    AIO.Handle(player, "TalentWarlockspell", "UpdateTalentItemCount", GetTalentItemCount(player))
end