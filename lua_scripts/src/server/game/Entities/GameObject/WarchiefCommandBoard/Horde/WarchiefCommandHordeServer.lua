-- ============================================================
--  WarchiefCommandHordeServer.lua
--  TrinityCore 3.3.5 — Eluna + AIO
--  Transmission par arguments AIO natifs (pas de JSON)
--  Format : OpenInterface(count, t1,d1,bl1,ci1,qi1,mi1,x1,y1,z1,o1,tm1, t2,...)
-- ============================================================

local AIO = AIO or require("AIO")

local WarchiefCommandHordeHandlers = AIO.AddHandlers("WarchiefCommandHordeHandler", {})

local GAMEOBJECT_ENTRY = 206109
local FACTION_HORDE    = 1

-- Longueur max de la description (caractères) — réduite car plus de JSON overhead
local DESC_MAX_LEN = 400

-- ------------------------------------------------------------
--  Vérifie si une quête a été récompensée
-- ------------------------------------------------------------
local function IsQuestRewarded(player, questId)
    local guid = player:GetGUIDLow()
    local res = CharDBQuery(
        "SELECT 1 FROM character_queststatus_rewarded " ..
        "WHERE guid = " .. guid ..
        " AND quest = " .. questId ..
        " LIMIT 1"
    )
    return res ~= nil
end

-- ------------------------------------------------------------
--  Lecture de la DB
-- ------------------------------------------------------------
local function GetAvailableFlyers(player)
    local guid = player:GetGUIDLow()

    --print("[WarchiefBoard] Ouverture pour " .. player:GetName() .. " (GUID=" .. guid .. ")")

    local result = WorldDBQuery(
        "SELECT title, description, button_label, card_image, " ..
        "quest_id, map_id, pos_x, pos_y, pos_z, orientation, teleport_msg " ..
        "FROM warchief_command_flyers " ..
        "WHERE faction = " .. FACTION_HORDE .. " AND enabled = 1 " ..
        "ORDER BY sort_order ASC"
    )

    if not result then
        --print("[WarchiefBoard] ERREUR : table warchief_command_flyers vide ou introuvable !")
        return {}
    end

    local flyers = {}
    local total  = 0

    repeat
        total = total + 1
        local questId  = result:GetUInt32(4)
        local rewarded = IsQuestRewarded(player, questId)

        --print("[WarchiefBoard] Dépliant #" .. total ..
        --      " questId=" .. questId ..
        --      " rewarded=" .. tostring(rewarded))

        if not rewarded then
            local desc = result:GetString(1)
            if #desc > DESC_MAX_LEN then
                desc = desc:sub(1, DESC_MAX_LEN - 3) .. "..."
            end

            table.insert(flyers, {
                title       = result:GetString(0),
                description = desc,
                buttonLabel = result:GetString(2),
                cardImage   = result:GetString(3),
                questId     = questId,
                mapId       = result:GetUInt32(5),
                posX        = result:GetFloat(6),
                posY        = result:GetFloat(7),
                posZ        = result:GetFloat(8),
                orientation = result:GetFloat(9),
                teleportMsg = result:GetString(10),
            })
        end
    until not result:NextRow()

    --print("[WarchiefBoard] Total DB=" .. total .. " | Affichés=" .. #flyers)
    return flyers
end

-- ------------------------------------------------------------
--  Ouverture du tableau
--  On envoie : count, puis pour chaque dépliant 11 args
--  => AIO.Handle(player, handler, func, count,
--                t1,d1,bl1,ci1,qi1,mi1,x1,y1,z1,o1,tm1,
--                t2,d2, ...)
-- ------------------------------------------------------------
local function OpenWarchiefBoard(player)
    local flyers = GetAvailableFlyers(player)

    if #flyers == 0 then
        player:SendBroadcastMessage("|cffFFD700[Chef de guerre]|r Toutes les missions sont accomplies. Revenez plus tard !")
        AIO.Handle(player, "WarchiefCommandHordeHandler", "OpenInterface", 0)
        return
    end

    local count = math.min(#flyers, 3)

    -- Construire la liste d'arguments : count puis 11 champs par dépliant
    local args = { count }
    for i = 1, count do
        local f = flyers[i]
        table.insert(args, f.title)
        table.insert(args, f.description)
        table.insert(args, f.buttonLabel)
        table.insert(args, f.cardImage)
        table.insert(args, f.questId)
        table.insert(args, f.mapId)
        table.insert(args, f.posX)
        table.insert(args, f.posY)
        table.insert(args, f.posZ)
        table.insert(args, f.orientation)
        table.insert(args, f.teleportMsg)
    end

    --print("[WarchiefBoard] Envoi " .. count .. " dépliants via " .. (1 + count * 11) .. " args AIO")
    AIO.Handle(player, "WarchiefCommandHordeHandler", "OpenInterface", unpack(args))
end

-- ------------------------------------------------------------
--  Acceptation d'une quête + téléportation
-- ------------------------------------------------------------
function WarchiefCommandHordeHandlers.AcceptQuest(player, questId)
    if not questId then
        player:SendBroadcastMessage("Erreur : ID de quête manquant.")
        return
    end

    local result = WorldDBQuery(
        "SELECT title, map_id, pos_x, pos_y, pos_z, orientation, teleport_msg " ..
        "FROM warchief_command_flyers " ..
        "WHERE quest_id = " .. questId ..
        " AND faction = " .. FACTION_HORDE ..
        " AND enabled = 1 LIMIT 1"
    )

    if not result then
        player:SendBroadcastMessage("Erreur : quête introuvable dans la liste.")
        return
    end

    if IsQuestRewarded(player, questId) then
        player:SendBroadcastMessage("|cffFFD700[Chef de guerre]|r Vous avez déjà accompli cette mission.")
        return
    end

    local title = result:GetString(0)
    local mapId = result:GetUInt32(1)
    local posX  = result:GetFloat(2)
    local posY  = result:GetFloat(3)
    local posZ  = result:GetFloat(4)
    local ori   = result:GetFloat(5)
    local tpMsg = result:GetString(6)

    if not player:HasQuest(questId) then
        player:AddQuest(questId)
        player:SendBroadcastMessage("|cffFFD700[Chef de guerre]|r Quête acceptée : " .. title)
    else
        player:SendBroadcastMessage("|cffFFD700[Chef de guerre]|r Quête déjà en cours.")
    end

    player:Teleport(mapId, posX, posY, posZ, ori)
    player:SendBroadcastMessage(tpMsg)
end

-- ------------------------------------------------------------
--  Événement Gossip
-- ------------------------------------------------------------
local function OnGossipHello(event, player, gameObject)
    OpenWarchiefBoard(player)
end

RegisterGameObjectGossipEvent(GAMEOBJECT_ENTRY, 1, OnGossipHello)
