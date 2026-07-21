local AIO = AIO or require("AIO")

local PanelHandlers = AIO.AddHandlers("ModMePanel", {})

-- Fonction pour récupérer les breloques du joueur
local function GetPlayerBreloques(player)
    local getPoints = CharDBQuery('SELECT vp, dp FROM `auc_website`.`users` WHERE username = "'..player:GetAccountName()..'";')
    
    if getPoints then
        local vp = getPoints:GetUInt32(0)
        local dp = getPoints:GetUInt32(1)
        return vp, dp
    end
    
    return 0, 0
end

-- Nom de race localisé : lu directement dans la table chrraces (base
-- auc_spell) plutot que d'etre traduit en dur cote client. La colonne SQL
-- depend a la fois du genre (Name* = homme, NameFemale* = femme) et de la
-- langue du client (Name3/NameFemale3 = frFR, Name1/NameFemale1 = enUS,
-- meme convention que chrclasses). Couvre donc les races standard et
-- toutes les races custom du serveur, sans liste a maintenir a la main.
-- gender: 0 = homme, 1 = femme (Eluna Player:GetGender()).
-- locale: "frFR" ou "enUS" (envoyee par le client via GetLocale()).
--
-- On lit TOUJOURS les deux colonnes (masculin + féminin) de la locale
-- demandée et on ne garde le nom féminin que s'il est réellement rempli :
-- la colonne NameFemale* n'a été traduite en base que pour le frFR (comme
-- montré dans tes captures) -- côté enUS elle est vide pour la plupart des
-- races, y compris les standards. Sans ce repli, un personnage féminin en
-- client enUS se retrouvait avec un nom de race vide au lieu d'utiliser le
-- nom de base ("Human", etc.).
local function GetRaceName(raceId, gender, locale)
    local isFemale = (gender == 1)
    local maleColumn, femaleColumn
    if locale == "enUS" then
        maleColumn, femaleColumn = "Name1", "NameFemale1"
    else
        maleColumn, femaleColumn = "Name3", "NameFemale3"
    end

    local result = CharDBQuery('SELECT '..maleColumn..', '..femaleColumn..' FROM `auc_spell`.`chrraces` WHERE ID = '..tonumber(raceId or 0)..' LIMIT 1')
    if not result then
        return nil
    end

    local maleName = result:GetString(0)
    local femaleName = result:GetString(1)

    if isFemale and femaleName and femaleName ~= "" then
        return femaleName
    end

    return maleName
end

-- Handler pour demander les données du panel
function PanelHandlers.RequestPanelData(player, locale)
    local vp, dp = GetPlayerBreloques(player)
    
    local data = {
        accountId = player:GetAccountId(),
        accountName = player:GetAccountName(),
        charId = player:GetGUIDLow(),
        charName = player:GetName(),
        vp = vp,
        dp = dp,
        raceName = GetRaceName(player:GetRace(), player:GetGender(), locale)
    }
    
    AIO.Handle(player, "ModMePanel", "UpdatePanelData", data)
end

-- Fonction pour vérifier si le joueur a assez de breloques
local function HasBreloques(player, count)
    local getPoints = CharDBQuery('SELECT dp FROM `auc_website`.`users` WHERE username = "'..player:GetAccountName()..'";')
    if getPoints then
        return count <= getPoints:GetUInt32(0)
    end
    return false
end

-- Fonction pour retirer des breloques
local function RemoveBreloques(player, count)
    CharDBQuery('UPDATE `auc_website`.`users` SET dp = dp - '..count..' WHERE username = "'..player:GetAccountName()..'";')
end

-- Commande pour ouvrir le panel UI
local function OnPlayerCommand(event, player, command)
    if command == "modmepanel" or command == "panel" then
        AIO.Handle(player, "ModMePanel", "ShowPanel")
        return false
    end
end

RegisterPlayerEvent(42, OnPlayerCommand)

-- Event pour envoyer le script au login
local function OnLogin(event, player)
    AIO.Handle(player, "ModMePanel", "Initialize")
end

RegisterPlayerEvent(3, OnLogin)

-- OPTIONNEL: Support gossip si vous avez la créature 2000040 dans votre base
local MenuId = 3445
local creatureEntry = 2000040

local function onGossipHello(event, player, object)
    player:GossipClearMenu()
    
    local getPoints = CharDBQuery('SELECT vp, dp FROM `auc_website`.`users` WHERE username = "'..player:GetAccountName()..'";')
    if getPoints then
        local vp = getPoints:GetUInt32(0)
        local dp = getPoints:GetUInt32(1)
        player:GossipSetText('Panneau d\'utilisateur \n\nIdentifiant du compte : '..player:GetAccountId()..'\nNom du compte : '..player:GetAccountName()..'\n\nIdentifiant du personnage : '..player:GetGUIDLow()..'\nNom du personnage : '..player:GetName()..'\n\n|TINTERFACE\\ICONS\\DP:30:30|t[Breloques supérieures] : '..dp..'\n|TINTERFACE\\ICONS\\VP:30:30|t[Breloques inférieures] : '..vp)
    end
    
    player:GossipSendMenu(0x7FFFFFFF, player, MenuId)
end

local function onGossipSelect(event, player, object, sender, intid, code, menuid)
    player:GossipClearMenu()
    
    if intid == 99 then
        onGossipHello(event, player, object)
    end
    
    player:GossipSendMenu(0x7FFFFFFF, player, MenuId)
end

-- Enregistrer les events gossip seulement si vous avez la créature
-- Commentez ces lignes si vous n'utilisez que le système UI
RegisterCreatureGossipEvent(creatureEntry, 1, onGossipHello)
RegisterCreatureGossipEvent(creatureEntry, 2, onGossipSelect)