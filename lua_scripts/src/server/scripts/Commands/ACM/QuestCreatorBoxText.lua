local function ShowQuestCreatorMenu(player)
    player:GossipClearMenu()
    player:GossipMenuAddItem(9, "Créer une nouvelle quête", 0, 1, true, "Entrez l'ID de la quête")
    player:GossipSendMenu(1, player, 540)
end

local function SaveQuestToDatabase(player)
    local questID = player:GetData("quest_id")
    local questTitle = player:GetData("quest_title")
    local questDescription = player:GetData("quest_description")
    local questObjective = player:GetData("quest_objective")
    local questReward = player:GetData("quest_reward") or 0  -- Valeur par défaut si nil
    local questLevel = player:GetData("quest_level") or 1     -- Valeur par défaut si nil
    local questMinLevel = player:GetData("quest_min_level") or 1 -- Valeur par défaut si nil

    -- Vérification des valeurs (optionnelle mais utile)
    if not questID or not questTitle or not questDescription or not questObjective then
        player:SendBroadcastMessage("Erreur : Certaines données essentielles sont manquantes.")
        return
    end

    -- Insérer dans quest_template avec l'ID de la quête
    local query = string.format("INSERT INTO quest_template (ID, LogTitle, LogDescription, QuestDescription, RewardItem1, QuestLevel, MinLevel) VALUES (%d, '%s', '%s', '%s', %d, %d, %d);", questID, questTitle, questDescription, questObjective, questReward, questLevel, questMinLevel)
    WorldDBQuery(query)
    
    -- Insérer dans quest_template_locale
    local queryLocale = string.format("INSERT INTO quest_template_locale (ID, locale, Title, Details, Objectives) VALUES (%d, 'frFR', '%s', '%s', '%s');", questID, questTitle, questDescription, questObjective)
    WorldDBQuery(queryLocale)
    
    -- Insérer dans quest_details
    local queryDetails = string.format("INSERT INTO quest_details (ID, VerifiedBuild) VALUES (%d, 0);", questID)
    WorldDBQuery(queryDetails)
    
    -- Insérer dans quest_template_addon
    local queryAddon = string.format("INSERT INTO quest_template_addon (ID, MaxLevel, AllowableClasses) VALUES (%d, 60, 0);", questID)
    WorldDBQuery(queryAddon)
    
    -- Insérer dans quest_offer_reward
    local queryReward = string.format("INSERT INTO quest_offer_reward (ID, RewardText, VerifiedBuild) VALUES (%d, 'Félicitations ! Voici votre récompense.', 0);", questID)
    WorldDBQuery(queryReward)
    
    player:SendBroadcastMessage("Quête créée et sauvegardée en base de données!\nID de la quête: " .. questID .. "\nTitre: " .. questTitle .. "\nDescription: " .. questDescription .. "\nObjectif: " .. questObjective .. "\nRécompense ID: " .. questReward)
end

local function OnGossipSelect(event, player, object, sender, intid, code, menu_id)
    if intid == 1 then
        local questID = tonumber(code)
        player:SetData("quest_id", questID)
        player:GossipClearMenu()
        player:GossipMenuAddItem(9, "Entrez le titre de la quête", 0, 2, true, "Entrez le titre de la quête")
        player:GossipSendMenu(1, player, 540)
    elseif intid == 2 then
        local questTitle = code
        player:SetData("quest_title", questTitle)
        player:GossipClearMenu()
        player:GossipMenuAddItem(9, "Décrire la quête", 0, 3, true, "Entrez la description de la quête")
        player:GossipSendMenu(1, player, 540)
    elseif intid == 3 then
        local questDescription = code
        player:SetData("quest_description", questDescription)
        player:GossipClearMenu()
        player:GossipMenuAddItem(9, "Définir l'objectif", 0, 4, true, "Entrez l'objectif de la quête")
        player:GossipSendMenu(1, player, 540)
    elseif intid == 4 then
        local questObjective = code
        player:SetData("quest_objective", questObjective)
        player:GossipClearMenu()
        player:GossipMenuAddItem(9, "Définir la récompense", 0, 5, true, "Entrez l'ID de l'objet de récompense")
        player:GossipSendMenu(1, player, 540)
    elseif intid == 5 then
        local questReward = tonumber(code)
        player:SetData("quest_reward", questReward)
        player:GossipClearMenu()
        player:GossipMenuAddItem(9, "Définir le niveau de la quête", 0, 6, true, "Entrez le niveau de la quête")
        player:GossipSendMenu(1, player, 540)
    elseif intid == 6 then
        local questMinLevel = tonumber(code)
        player:SetData("quest_min_level", questMinLevel)
        SaveQuestToDatabase(player)
        player:GossipComplete()
    end
end

local function OnCommand(event, player, command)
    if command == "questuibox" then
        ShowQuestCreatorMenu(player)
        return false
    end
end

RegisterPlayerGossipEvent(540, 2, OnGossipSelect)
RegisterPlayerEvent(42, OnCommand)
