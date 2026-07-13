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

-- Handler pour demander les données du panel
function PanelHandlers.RequestPanelData(player)
    local vp, dp = GetPlayerBreloques(player)
    
    local data = {
        accountId = player:GetAccountId(),
        accountName = player:GetAccountName(),
        charId = player:GetGUIDLow(),
        charName = player:GetName(),
        vp = vp,
        dp = dp
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