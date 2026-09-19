local NPC_ID = 338045
local MAX_ALLOWED_CHARACTERS = 20

local AT_LOGIN_RENAME = 1

-- ------------------------------------------------------------
--  Locale du joueur (bilingue frFR / enUS, repli sur frFR)
-- ------------------------------------------------------------
local function GetPlayerLocale(player)
    local ok, result = pcall(function()
        local accountId = player:GetAccountId()
        local q = AuthDBQuery("SELECT locale FROM account WHERE id = "..accountId..";")
        if q then
            local loc = q:GetUInt8(0)
            if loc == 0 then return "enUS" end
        end
        return "frFR"
    end)
    if ok and result then return result end
    return "frFR"
end

local CRNotif = {
    frFR = {
        NO_DELETED_FOUND   = "Aucun personnage supprimé n'a été trouvé.",
        LIST_FULL          = "Votre liste de personnages est complète !",
        RESTORED_TRIGGER   = "Personnage %s restauré avec succès !",
        RESTORED_RENAME    = "Votre personnage restauré a été signalé pour un changement de nom.",
        RESTORE_FAILED     = "Échec de la restauration du personnage.",
        MENU_TEXT          = "Nom: %s\nNiveau: %s\nClasse: %s",
        CONFIRM_RESTORE    = "Souhaitez-vous restaurer %s?",
    },
    enUS = {
        NO_DELETED_FOUND   = "No deleted character was found.",
        LIST_FULL          = "Your character list is full!",
        RESTORED_TRIGGER   = "Character %s successfully restored!",
        RESTORED_RENAME    = "Your restored character has been flagged for a name change.",
        RESTORE_FAILED     = "Failed to restore the character.",
        MENU_TEXT          = "Name: %s\nLevel: %s\nClass: %s",
        CONFIRM_RESTORE    = "Would you like to restore %s?",
    },
}
local function L(player)
    return CRNotif[GetPlayerLocale(player)] or CRNotif.frFR
end

local CLASS_NAMES = {
    frFR = {
        [1] = "Guerrier", [2] = "Paladin", [3] = "Chasseur", [4] = "Voleur",
        [5] = "Prêtre", [6] = "Chevalier de la mort", [7] = "Chamane", [8] = "Mage",
        [9] = "Démoniste", [10] = "Mage de combat sanglant", [11] = "Druide",
        [12] = "Cavalier", [13] = "Chasseur de démons", [14] = "Moine",
        [15] = "Dompteur", [16] = "Héros", [17] = "Évocateur",
    },
    enUS = {
        [1] = "Warrior", [2] = "Paladin", [3] = "Hunter", [4] = "Rogue",
        [5] = "Priest", [6] = "Death Knight", [7] = "Shaman", [8] = "Mage",
        [9] = "Warlock", [10] = "Blood Combat Mage", [11] = "Druid",
        [12] = "Cavalier", [13] = "Demon Hunter", [14] = "Monk",
        [15] = "Tamer", [16] = "Hero", [17] = "Evoker",
    },
}
local function GetClassName(player, class)
    local names = CLASS_NAMES[GetPlayerLocale(player)] or CLASS_NAMES.frFR
    return names[class] or "Unknown"
end

local function NameByGuid(guid)
    local query = CharDBQuery("SELECT deleteInfos_Name FROM characters WHERE guid = " .. guid)
    if query then
        return query:GetString(0)
    end
    return nil
end

local function IsAtMaxCharacters(player)
    local accountId = player:GetAccountId()
    local query = CharDBQuery("SELECT COUNT(*) FROM characters WHERE account = " .. accountId)
    if query then
        local count = query:GetUInt32(0)
        return count >= MAX_ALLOWED_CHARACTERS
    end
    return false
end

local function RecoverDeletedCharacterByGuid(player, guid)
    if IsAtMaxCharacters(player) then
        return false
    end

    local name = NameByGuid(guid)
    local accountId = player:GetAccountId()
    CharDBExecute("UPDATE characters SET name = '" .. name .. "', account = " .. accountId .. ", at_login = " .. AT_LOGIN_RENAME .. ", deleteInfos_Account = NULL, deleteInfos_Name = NULL, deleteDate = NULL WHERE guid = " .. guid)
    return true
end

local function GenerateGossipMenuForPlayer(player, creature)
    local accountId = player:GetAccountId()
    local query = CharDBQuery("SELECT guid, deleteInfos_Name, level, class FROM characters WHERE deleteInfos_account = " .. accountId)
    if query then
        repeat
            local guid = query:GetUInt32(0)
            local name = query:GetString(1)
            local level = query:GetUInt32(2)
            local class = query:GetUInt32(3)

            local className = GetClassName(player, class)
            local menuText = string.format(L(player).MENU_TEXT, name, tostring(level), className)
            player:GossipMenuAddItem(0, menuText, 0, guid, false, string.format(L(player).CONFIRM_RESTORE, name))
        until not query:NextRow()
    else
        player:SendBroadcastMessage(L(player).NO_DELETED_FOUND)
    end
end

local function OnGossipHello(event, player, creature)
    GenerateGossipMenuForPlayer(player, creature)
    player:GossipSendMenu(1, creature)
end

local function OnGossipSelect(event, player, creature, sender, intid, code)
    if intid == 0 then
        player:GossipComplete()
        return
    end

    if IsAtMaxCharacters(player) then
        player:SendBroadcastMessage(L(player).LIST_FULL)
        player:GossipComplete()
        return
    end

    if RecoverDeletedCharacterByGuid(player, intid) then
        local name = NameByGuid(intid)
        player:SendAreaTriggerMessage(string.format(L(player).RESTORED_TRIGGER, name))
        player:SendBroadcastMessage(L(player).RESTORED_RENAME)
    else
        player:SendBroadcastMessage(L(player).RESTORE_FAILED)
    end

    player:GossipComplete()
end

RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect)
