local NPC_ID = 338045
local MAX_ALLOWED_CHARACTERS = 20

local AT_LOGIN_RENAME = 1

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

            local className
            if class == 1 then className = "Guerrier"
            elseif class == 2 then className = "Paladin"
            elseif class == 3 then className = "Chasseur"
            elseif class == 4 then className = "Voleur"
            elseif class == 5 then className = "Prêtre"
            elseif class == 6 then className = "Chevalier de la mort"
            elseif class == 7 then className = "Chamane"
            elseif class == 8 then className = "Mage"
            elseif class == 9 then className = "Démoniste"
			elseif class == 10 then className = "Mage de combat sanglant"
            elseif class == 11 then className = "Druide"
			elseif class == 12 then className = "Cavalier"
			elseif class == 13 then className = "Chasseur de démons"
			elseif class == 14 then className = "Moine"
			elseif class == 15 then className = "Dompteur"
			elseif class == 16 then className = "Héros"
			elseif class == 17 then className = "Évocateur"
            else className = "Unknown" end

            local menuText = "Nom: " .. name .. "\nNiveau: " .. level .. "\nClasse: " .. className
            player:GossipMenuAddItem(0, menuText, 0, guid, false, "Souhaitez-vous restaurer " .. name .. "?")
        until not query:NextRow()
    else
        player:SendBroadcastMessage("Aucun personnage supprimé n'a été trouvé.")
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
        player:SendBroadcastMessage("Votre liste de personnages est complète !")
        player:GossipComplete()
        return
    end

    if RecoverDeletedCharacterByGuid(player, intid) then
        local name = NameByGuid(intid)
        player:SendAreaTriggerMessage("Personnage " .. name .. " restauré avec succès !")
        player:SendBroadcastMessage("Votre personnage restauré a été signalé pour un changement de nom.")
    else
        player:SendBroadcastMessage("Échec de la restauration du personnage.")
    end

    player:GossipComplete()
end

RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect)
