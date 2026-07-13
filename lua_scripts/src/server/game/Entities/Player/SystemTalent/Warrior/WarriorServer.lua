local AIO = AIO or require("AIO")
local WarriorHandlers = AIO.AddHandlers("TalentWarriorspell", {})
local TalentWarriorPointsSpend = {}

local MAX_TALENTS = 60

local talents = {
	-- Template 1

	-- Armes
	
	["spellimprovedheroicstrike"] = {spellID = 12664, itemID = 338404},
	["spelldeflection"] = {spellID = 16466, itemID = 338404},
	["spellimprovedrend"] = {spellID = 12658, itemID = 338404},
	["spellimprovedcharge"] = {spellID = 12697, itemID = 338404},
	["spellironwill"] = {spellID = 12960, itemID = 338404},
	["spelltacticalmastery"] = {spellID = 12677, itemID = 338404},
	["spellimprovedoverpower"] = {spellID = 12963, itemID = 338404},
	["spellangermanagement"] = {spellID = 12296, itemID = 338404},
	["spellimpale"] = {spellID = 16494, itemID = 338404},
	["spelldeepwounds"] = {spellID = 12867, itemID = 338404},
	["spelltwohandedweaponspecialization"] = {spellID = 12712, itemID = 338404},
	["spelltasteforblood"] = {spellID = 56638, itemID = 338404},
	["spellpoleaxespecialization"] = {spellID = 12785, itemID = 338404},
	["spellsweepingstrikes"] = {spellID = 12328, itemID = 338404},
	["spellmacespecialization"] = {spellID = 12704, itemID = 338404},
	["spellswordspecialization"] = {spellID = 12815, itemID = 338404},
	["spellweaponmastery"] = {spellID = 20505, itemID = 338404},
	["spellimprovedhamstring"] = {spellID = 23695, itemID = 338404},
	["spelltrauma"] = {spellID = 46855, itemID = 338404},
	["spellsecondwind"] = {spellID = 29838, itemID = 338404},
	["spellmortalstrike"] = {spellID = 12294, itemID = 338404},
	["spellstrengthofarms"] = {spellID = 46866, itemID = 338404},
	["spellimprovedslam"] = {spellID = 12330, itemID = 338404},
	["spelljuggernaut"] = {spellID = 64976, itemID = 338404},
	["spellimprovedmortalstrike"] = {spellID = 35449, itemID = 338404},
	["spellunrelentingassault"] = {spellID = 46860, itemID = 338404},
	["spellsuddendeath"] = {spellID = 29724, itemID = 338404},
	["spellendlessrage"] = {spellID = 29623, itemID = 338404},
	
	-- Fureur
	
	["spellbloodfrenzy"] = {spellID = 29859, itemID = 338404},
	["spellwreckingcrew"] = {spellID = 56614, itemID = 338404},
	["spellbladestorm"] = {spellID = 46924, itemID = 338404},
	["spellarmoredtotheteeth"] = {spellID = 61222, itemID = 338404},
	["spellboomingvoice"] = {spellID = 12835, itemID = 338404},
	["spellcruelty"] = {spellID = 12856, itemID = 338404},
	["spellimproveddemoralizingshout"] = {spellID = 12879, itemID = 338404},
	["spellunbridledwrath"] = {spellID = 13002, itemID = 338404},
	["spellimprovedcleave"] = {spellID = 20496, itemID = 338404},
	["spellpiercinghowl"] = {spellID = 12323, itemID = 338404},
	["spellbloodcraze"] = {spellID = 16492, itemID = 338404},
	["spellcommandingpresence"] = {spellID = 12861, itemID = 338404},
	["spelldualwieldspecialization"] = {spellID = 23588, itemID = 338404},
	
	-- Template 2
	
	["spellimprovedexecute"] = {spellID = 20503, itemID = 338404},
	["spellenrage"] = {spellID = 13048, itemID = 338404},
	["spellprecision"] = {spellID = 29592, itemID = 338404},
	["spelldeathwish"] = {spellID = 12292, itemID = 338404},
	["spellimprovedintercept"] = {spellID = 29889, itemID = 338404},
	["spellimprovedberserkerrage"] = {spellID = 20501, itemID = 338404},
	["spellflurry"] = {spellID = 12974, itemID = 338404},
	["spellintensifyrage"] = {spellID = 56924, itemID = 338404},
	["spellbloodthirst"] = {spellID = 23881, itemID = 338404},
	["spellimprovedwhirlwind"] = {spellID = 29776, itemID = 338404},
	["spellfuriousattacks"] = {spellID = 46911, itemID = 338404},
	["spellimprovedberserkerstance"] = {spellID = 29763, itemID = 338404},
	["spellheroicfury"] = {spellID = 60970, itemID = 338404},
	["spellrampage"] = {spellID = 29801, itemID = 338404},
	
	-- Protection
	
	["spellbloodsurge"] = {spellID = 46915, itemID = 338404},
	["spellunendingfury"] = {spellID = 56932, itemID = 338404},
	["spelltitansgrip"] = {spellID = 46917, itemID = 338404},
	["spellimprovedbloodrage"] = {spellID = 12818, itemID = 338404},
	["spellshieldspecialization"] = {spellID = 12727, itemID = 338404},
	["spellimprovedthunderclap"] = {spellID = 12666, itemID = 338404},
	["spellincite"] = {spellID = 50687, itemID = 338404},
	["spellanticipation"] = {spellID = 12753, itemID = 338404},
	["spelllaststand"] = {spellID = 12975, itemID = 338404},
	["spellimprovedrevenge"] = {spellID = 12799, itemID = 338404},
	["spellshieldmastery"] = {spellID = 29599, itemID = 338404},
	["spelltoughness"] = {spellID = 12764, itemID = 338404},
	["spellimprovedspellreflection"] = {spellID = 59089, itemID = 338404},
	["spellimproveddisarm"] = {spellID = 12804, itemID = 338404},
	["spellpuncture"] = {spellID = 12811, itemID = 338404},
	["spellimproveddisciplines"] = {spellID = 12803, itemID = 338404},
	["spellconcussionblow"] = {spellID = 12809, itemID = 338404},
	["spellgagorder"] = {spellID = 12958, itemID = 338404},
	["spellfear"] = {spellID = 16542, itemID = 338404},
	["spellimproveddefensivestance"] = {spellID = 29594, itemID = 338404},
	["spellvigilance"] = {spellID = 50720, itemID = 338404},
	["spellfocusedrage"] = {spellID = 29792, itemID = 338404},
	["spellvitality"] = {spellID = 29144, itemID = 338404},
	["spellsafeguard"] = {spellID = 46949, itemID = 338404},
	["spellwarbringer"] = {spellID = 57499, itemID = 338404},
	["spelldevastate"] = {spellID = 20243, itemID = 338404},
	["spellcriticalblock"] = {spellID = 47296, itemID = 338404},
	["spellswordandboard"] = {spellID = 46953, itemID = 338404},
	["spelldamageshield"] = {spellID = 58874, itemID = 338404},
	["spellshockwave"] = {spellID = 46968, itemID = 338404},
}

-- Accesseur item talent (GetItemCount est l'API Eluna correcte)
local function GetTalentItemCount(player)
    return player:GetItemCount(338404)
end

-- Accesseur par GUID pour éviter la collision multi-joueurs
local function GetSpendList(player)
    local guid = player:GetGUIDLow()
    if not TalentWarriorPointsSpend[guid] then
        TalentWarriorPointsSpend[guid] = {}
    end
    return TalentWarriorPointsSpend[guid]
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

                AIO.Handle(player, "TalentWarriorspell", "UpdateTalentCount", #spendList, MAX_TALENTS)
                AIO.Handle(player, "TalentWarriorspell", "UpdateTalentItemCount", GetTalentItemCount(player))

                local learnedSpells = {}
                learnedSpells[talentHandler] = true
                AIO.Handle(player, "TalentWarriorspell", "UpdateLearnedTalents", learnedSpells)
            end
        else
            player:SendAreaTriggerMessage("|cffff0000Vous n'avez pas de point de talent !|r")
            AIO.Handle(player, "TalentWarriorspell", "UpdateTalentItemCount", GetTalentItemCount(player))
        end
    end
end

for talentName, talentData in pairs(talents) do
    WarriorHandlers[talentName] = function(player, item)
        LearnTalent(player, talentData, talentName)
    end
end

local function LoadTalentProgression(player)
    local guid = player:GetGUIDLow()
    TalentWarriorPointsSpend[guid] = {}
    local spendList    = TalentWarriorPointsSpend[guid]
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

    AIO.Handle(player, "TalentWarriorspell", "UpdateTalentCount", #spendList, MAX_TALENTS)

    -- Petit délai pour s'assurer que l'UI client est chargée avant d'envoyer l'état
    player:RegisterEvent(function(eventId, delay, repeats, pPlayer)
        AIO.Handle(pPlayer, "TalentWarriorspell", "UpdateLearnedTalents", learnedSpells)
        AIO.Handle(pPlayer, "TalentWarriorspell", "UpdateTalentItemCount", GetTalentItemCount(pPlayer))
    end, 10, 1)
end

WarriorHandlers.RequestLearnedTalents = function(player)
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
    AIO.Handle(player, "TalentWarriorspell", "UpdateLearnedTalents", learnedSpells)
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

WarriorHandlers.GetTalentItemCount = function(player)
    AIO.Handle(player, "TalentWarriorspell", "UpdateTalentItemCount", GetTalentItemCount(player))
end

local function ResetTalentProgression(player)
    CharDBQuery("DELETE FROM character_talentspell WHERE guid = " .. player:GetGUIDLow() .. " AND account_id = " .. player:GetAccountId() .. ";")
end

WarriorHandlers.ResetTalents = function(player)
    local spendList        = GetSpendList(player)
    local pointsBeforeReset = #spendList

    for talentName, talentData in pairs(talents) do
        player:RemoveSpell(talentData.spellID)
    end

    local guid = player:GetGUIDLow()
    TalentWarriorPointsSpend[guid] = {}
    ResetTalentProgression(player)

    AIO.Handle(player, "TalentWarriorspell", "ResetAllButtons")
    AIO.Handle(player, "TalentWarriorspell", "UpdateTalentCount", 0, MAX_TALENTS)
    AIO.Handle(player, "TalentWarriorspell", "UpdateTalentPointsUsed", 0, pointsBeforeReset)

    player:AddItem(338404, pointsBeforeReset)
    AIO.Handle(player, "TalentWarriorspell", "UpdateTalentItemCount", GetTalentItemCount(player))
end