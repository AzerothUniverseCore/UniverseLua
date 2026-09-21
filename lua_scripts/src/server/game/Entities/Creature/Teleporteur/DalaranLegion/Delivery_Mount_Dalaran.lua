local NpcId = 9756653
local MenuId = 9756653

local LOCALE_FRFR = 2

local pathTable = {}

table.insert(pathTable, {781, -11929.8, 2973.13, 1857.65, 0.94023})
table.insert(pathTable, {781, -11922.1, 2978.39, 1861.2,  1.21512})
table.insert(pathTable, {781, -11917.7, 3005.21, 1869.83, 1.27402})
table.insert(pathTable, {781, -11908.7, 3027.61, 1873.01, 1.168})
table.insert(pathTable, {781, -11891,   3069.01, 1850.37, 1.168})
table.insert(pathTable, {781, -11877.5, 3109.65, 1813.38, 1.20727})
table.insert(pathTable, {781, -11861.3, 3147.32, 1779.31, 1.14443})
table.insert(pathTable, {781, -11855.1, 3159.51, 1769.83, 0.948084})
table.insert(pathTable, {781, -11843.5, 3177.1,  1759.37, 0.967719})

local RivageBriseIslePath = AddTaxiPath(pathTable, 150025, 150025)

local Locales = {
    [0] = { -- enUS
        GOSSIP_TEXT     = "Hello %s!\n\nI'm offering a trip to the Legion Portal for the Battle for the Broken Shore.\n\nDo you want to go?",
        OPTION_ACCEPT   = "Yes! Take me to the Battle for the Broken Shore!",
        OPTION_DECLINE  = "Not right now... Goodbye!",
        NOTIFICATION    = "|cffff0000Come back and see me if you want to travel.|r",
        TALK_TAKEOFF    = "Safe travels, and good luck in the battle!",
    },
    [LOCALE_FRFR] = { -- frFR
        GOSSIP_TEXT     = "Bonjour %s!\n\nJe propose un voyage direction au portail de la légion pour La bataille du rivage Brisé.\n\nVoulez-vous y aller ?",
        OPTION_ACCEPT   = "Oui ! Allez à La bataille du rivage Brisé !",
        OPTION_DECLINE  = "Pas maintenant... Au revoir !",
        NOTIFICATION    = "|cffff0000Reviens me voir si tu veux voyager.|r",
        TALK_TAKEOFF    = "Bon voyage ! Et bonne bataille !",
    },
}

local function GetLocalizedText(player)
    local localeIndex = player:GetDbLocaleIndex()
    return Locales[localeIndex] or Locales[0]
end

local function OnGossipHello(event, player, object)
    local L = GetLocalizedText(player)

    player:GossipClearMenu()
    player:GossipSetText(string.format(L.GOSSIP_TEXT, player:GetName()))
    player:GossipMenuAddItem(2, L.OPTION_ACCEPT, 1, 1)
    player:GossipMenuAddItem(7, L.OPTION_DECLINE, 1, 2)
    player:GossipSendMenu(0x7FFFFFFF, object)
end

local function OnGossipSelect(event, player, object, sender, intid, code, menuid)
    local L = GetLocalizedText(player)

    if (intid == 1) then
        object:SendChatMessageToPlayer(12, 0, L.TALK_TAKEOFF, player)

        player:StartTaxi(RivageBriseIslePath)
        player:GossipComplete()
    end

    if (intid == 2) then
        player:SendNotification(L.NOTIFICATION)
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NpcId, 1, OnGossipHello)
RegisterCreatureGossipEvent(NpcId, 2, OnGossipSelect)
RegisterPlayerGossipEvent(MenuId, 2, OnGossipSelect)
