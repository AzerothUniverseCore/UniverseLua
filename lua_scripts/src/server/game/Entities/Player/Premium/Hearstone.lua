local ItemId = 90180;
local MenuId = 900180;

local ChatMsg1 = "#Menu";
local ChatMsg2 = "#menu";

local HearthStone = {};
local KEY = "REPLACE INTO `hearthstone` (`guid`,`map`,`x`,`y`,`z`,`o`)VALUES (%s,%s,%s,%s,%s,%s);"; 

local function LoadPlayerLocation(pGuid)
    local Q = WorldDBQuery("SELECT * FROM `hearthstone` WHERE `guid`='"..pGuid.."';")
    if(Q) then
        HearthStone[Q:GetUInt32(0)] = {
            map = Q:GetUInt32(1),
            x = Q:GetFloat(2),
            y = Q:GetFloat(3),
            z = Q:GetFloat(4),
            o = Q:GetFloat(5),
        };
        return Q:GetUInt32(0),Q:GetUInt32(1),Q:GetFloat(2),Q:GetFloat(3),Q:GetFloat(4),Q:GetFloat(5);
    end
end

local function UpdateLoc(key, ...)
    if(key == 1) then
        local guid, a, b, c, d, e = ...;
        local qs = string.format(KEY, guid, a, b, c, d, e);
        WorldDBQuery(qs);
        HearthStone[guid] = {map = a, x = b, y = c, z = d, o = e,};
    end
end

local function Login(event, player)
    local guid = player:GetGUIDLow();
    local loc = LoadPlayerLocation(guid);
    local map, x, y, z, o = player:GetMapId(), player:GetLocation();

    if not loc or not HearthStone[guid] then
        UpdateLoc(1, guid, map, x, y, z, o);
    end
end

local function Logout(event, player)
    HearthStone[player:GetGUIDLow()] = {};
end

local function Hello(event, player)
    -- Vérification : Bloquer en Battleground et Arena
    if player:GetMap():IsBattleground() or player:GetMap():IsArena() then
        player:SendBroadcastMessage("Vous ne pouvez pas utiliser cette fonctionnalité en Champ de Bataille ou en Arène.")
        return
    end

    player:GossipClearMenu();
    player:GossipMenuAddItem(0, "Sauvegarder ma position", 0, 9)  
    player:GossipMenuAddItem(0, "Téléportez-moi", 0, 10)
    player:GossipSendMenu(1, player, 100);
end

local function OnSelect(event, player, unit, sender, intid, code)
    local guid = player:GetGUIDLow();
    local map, x, y, z, o = player:GetMapId(), player:GetLocation();

    if(intid == 9) then
        UpdateLoc(1, guid, map, x, y, z, o);
        player:GossipComplete();
        player:SendAreaTriggerMessage("Votre position a été enregistrée.")
        player:SendBroadcastMessage("Votre position a été mise à jour.")
    end

    if(intid == 10) then
        if HearthStone[guid] then
            player:Teleport(HearthStone[guid].map, HearthStone[guid].x, HearthStone[guid].y, HearthStone[guid].z, HearthStone[guid].o)
            player:GossipComplete();
        else
            player:SendBroadcastMessage("Erreur : aucune position sauvegardée !")
        end
    end
end

local function Chat(event, player, msg, lang, type)
    if(msg == ChatMsg1 or msg == ChatMsg2) then
        Hello(event, player)
    end
end

RegisterPlayerEvent(30, Login)
RegisterPlayerEvent(3, Login)
RegisterPlayerEvent(4, Logout)
RegisterPlayerEvent(18, Chat)
RegisterPlayerGossipEvent(100, 2, OnSelect)
RegisterItemGossipEvent(ItemId, 1, Hello);
RegisterItemGossipEvent(ItemId, 2, OnSelect);
