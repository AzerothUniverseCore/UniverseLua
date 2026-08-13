local AIO = AIO or require("AIO")

local DESTINATIONS = {
    { "Orgrimmar",                     1,   1517.55,     -4412.03,     21.7103,   0.243466, nameEn = "Orgrimmar",                          faction = "Horde" },
    { "Sanctuaire des Deux-Lunes",     754, 1678.38,     931.508,      471.425,   0.143189, nameEn = "Shrine of Two Moons",                faction = "Horde" },
    { "Hurlevent",                     0,   -8905,       560,          94,        0.62,     nameEn = "Stormwind",                          faction = "Alliance" },
    { "Sanctuaire des Sept-Etoiles",   754, 821.866,     253.792,      503.92,    3.73811,  nameEn = "Shrine of Seven Stars",              faction = "Alliance" },
    { "Dalaran",                       571, 5826,        470,          659,       1.4,      nameEn = "Dalaran" },
    { "Dalaran (Legion)",   		   781, -11908.80,   2961.10,      1857.40,   5.04,     nameEn = "Dalaran (Legion)" },
    { "Les Ports Oublies",  		   807, 11742.5,     11860.6,      -0.169944, 4.85993,  nameEn = "The Forgotten Ports" },
    { "Netheril",    		   		   725, -14749.907227,-13192.527344,34.431049,1.896851, nameEn = "Netheril" },
    { "Chemin du Reve d'emeraude", 	   792, 1658.18,     1573.7,       5.84094,   2.46316,  nameEn = "Path of the Emerald Dream" },
}

local function PDF_PlayerFaction(player)
    local team = player:GetTeam()
    if team == 0 then
        return "Alliance"
    elseif team == 1 then
        return "Horde"
    end
    return "Neutral"
end

local SERVER_LOCALES = {
    frFR = {
        teleported          = "Vous avez ete teleporte vers %s.",
        recalled            = "Vous etes revenu a votre position precedente.",
        noRecall            = "Aucune position de retour enregistree.",
        invalidDestination  = "Destination invalide.",
        cooldown            = "Veuillez patienter avant de reutiliser la Pierre de Foyer.",
    },
    enUS = {
        teleported          = "You have been teleported to %s.",
        recalled            = "You have been returned to your previous location.",
        noRecall            = "No recall position saved.",
        invalidDestination  = "Invalid destination.",
        cooldown            = "Please wait before using the Hearthstone again.",
    },
}

local PlayerLocale = {}

local function PDF_LocaleFor(guidLow)
    return SERVER_LOCALES[PlayerLocale[guidLow]] or SERVER_LOCALES.enUS
end

local function PDF_DestName(guidLow, dest)
    return (PlayerLocale[guidLow] == "frFR") and dest[1] or dest.nameEn
end

CharDBExecute([[
CREATE TABLE IF NOT EXISTS character_pierre_foyer_recall (
    guid INT UNSIGNED NOT NULL PRIMARY KEY,
    mapId SMALLINT UNSIGNED NOT NULL,
    x FLOAT NOT NULL,
    y FLOAT NOT NULL,
    z FLOAT NOT NULL,
    o FLOAT NOT NULL
) ENGINE=InnoDB
]])

local LastPosition = {}

local function PDF_SaveRecallPosition(player)
    local guid = player:GetGUIDLow()
    local pos = {
        mapId = player:GetMapId(),
        x = player:GetX(),
        y = player:GetY(),
        z = player:GetZ(),
        o = player:GetO(),
    }
    LastPosition[guid] = pos
    CharDBExecute(string.format(
        "REPLACE INTO character_pierre_foyer_recall (guid, mapId, x, y, z, o) VALUES (%d, %d, %f, %f, %f, %f)",
        guid, pos.mapId, pos.x, pos.y, pos.z, pos.o
    ))
end

local Cooldown = {}
local COOLDOWN_SECONDS = 2

local function PDF_OnCooldown(guid)
    local last = Cooldown[guid]
    if last and (os.time() - last) < COOLDOWN_SECONDS then
        return true
    end
    Cooldown[guid] = os.time()
    return false
end

local function PDF_OnLogin(event, player)
    local guid = player:GetGUIDLow()
    PlayerLocale[guid] = PlayerLocale[guid] or "enUS"

    local result = CharDBQuery("SELECT mapId, x, y, z, o FROM character_pierre_foyer_recall WHERE guid = " .. guid)
    if result then
        LastPosition[guid] = {
            mapId = result:GetUInt32(0),
            x = result:GetFloat(1),
            y = result:GetFloat(2),
            z = result:GetFloat(3),
            o = result:GetFloat(4),
        }
    end
end

local function PDF_OnLogout(event, player)
    local guid = player:GetGUIDLow()
    PlayerLocale[guid] = nil
    LastPosition[guid] = nil
    Cooldown[guid] = nil
end

RegisterPlayerEvent(3, PDF_OnLogin)
RegisterPlayerEvent(4, PDF_OnLogout)

AIO.AddHandlers("PierreFoyer", {
    SetLocale = function(player, locale)
        local guid = player:GetGUIDLow()
        PlayerLocale[guid] = (locale == "frFR") and "frFR" or "enUS"
    end,

    Teleport = function(player, index)
        local guid = player:GetGUIDLow()
        local msg = PDF_LocaleFor(guid)

        if PDF_OnCooldown(guid) then
            AIO.Handle(player, "PierreFoyer", "Result", msg.cooldown, 1, 0.2, 0.2)
            return
        end

        local dest = type(index) == "number" and DESTINATIONS[index]
        if not dest then
            AIO.Handle(player, "PierreFoyer", "Result", msg.invalidDestination, 1, 0.2, 0.2)
            return
        end

        if dest.faction and dest.faction ~= PDF_PlayerFaction(player) then
            AIO.Handle(player, "PierreFoyer", "Result", msg.invalidDestination, 1, 0.2, 0.2)
            return
        end

        PDF_SaveRecallPosition(player)

        player:Teleport(dest[2], dest[3], dest[4], dest[5], dest[6])

        local text = string.format(msg.teleported, PDF_DestName(guid, dest))
        AIO.Handle(player, "PierreFoyer", "Result", text, 1, 0.82, 0)
    end,

    Recall = function(player)
        local guid = player:GetGUIDLow()
        local msg = PDF_LocaleFor(guid)

        if PDF_OnCooldown(guid) then
            AIO.Handle(player, "PierreFoyer", "Result", msg.cooldown, 1, 0.2, 0.2)
            return
        end

        local pos = LastPosition[guid]
        if not pos then
            AIO.Handle(player, "PierreFoyer", "Result", msg.noRecall, 1, 0.2, 0.2)
            return
        end

        player:Teleport(pos.mapId, pos.x, pos.y, pos.z, pos.o)
        AIO.Handle(player, "PierreFoyer", "Result", msg.recalled, 1, 0.82, 0)
    end,
})
