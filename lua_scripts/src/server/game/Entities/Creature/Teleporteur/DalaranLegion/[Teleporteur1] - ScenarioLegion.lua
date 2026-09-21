--[==[
    = How to add new locations =

    Example:

    The first line will be the main menu ID (Here [1],
    increment this for each main menu option!),
    the main menu icon and faction (Here 1 (Horde)).
    0 = Alliance, 1 = Horde, 2 = Both

    The second line is the name of the main menu's sub menus,
    separated by name and teleport coordinates
    using Map, X, Y, Z, O (Here 1, 1503, -4415.5, 22, 0)

    Chaque titre/nom est localise (enUS = fallback par defaut, frFR si le
    client du joueur est en francais) via une table { [0] = "...", [2] = "..." }
    (LocaleConstant : LOCALE_enUS = 0, LOCALE_frFR = 2).

    [1] = { "|TIcon:35|t", 1, -- Icone du menu principal, puis faction (0 = Alliance, 1 = Horde, 2 = Both)
        title = { [0] = "Horde Cities", [2] = "Villes de la Horde" },
        {"|TIcon:35|t", { [0] = "Orgrimmar", [2] = "Orgrimmar" }, 1, 1503, -4415.5, 22, 0},
    },

    You can copy paste the above into the script and change the values as informed.
]==]

local UnitEntry = 9007109

-- LocaleConstant (Common.h) : LOCALE_enUS = 0, LOCALE_frFR = 2, etc.
-- On ne gere que enUS (langue par defaut / fallback) et frFR ici.
local LOCALE_FRFR = 2

local function L(player, localizedTable)
    local localeIndex = player:GetDbLocaleIndex()
    return localizedTable[localeIndex] or localizedTable[0]
end

-- Dialogue bulle du PNJ au clic (CHAT_MSG_MONSTER_SAY = 12 pour une vraie
-- bulle au-dessus de sa tete, pas juste dans le chat)
local TALK_HELLO = { [0] = "Ready for the Battle for the Broken Shore?", [LOCALE_FRFR] = "Pret pour La bataille du rivage brisé ?" }

local T = {
        [1] = {
            icon = "|TInterface\\icons\\ability_bossfellord_felfissure:35|t",
            title = { [0] = "Legion Scenario", [LOCALE_FRFR] = "Scenario Légion" },
            faction = 2,
            {
                icon = "|TInterface\\icons\\achievement_dungeon_tombofsargeras:35|t",
                name = { [0] = "The Battle for the Broken Shore", [LOCALE_FRFR] = "La bataille du rivage Brisé" },
                map = 833, x = -2025.83, y = 3123.82, z = 2.3149, o = 0.162094,
            },
        },
}

-- CODE STUFFS! DO NOT EDIT BELOW
-- UNLESS YOU KNOW WHAT YOU'RE DOING!

local function ShowMainMenu(player, unit)
    for i, v in ipairs(T) do
        if (v.faction == 2 or v.faction == player:GetTeam()) then
            player:GossipMenuAddItem(0, v.icon .. " " .. L(player, v.title), i, 0)
        end
    end
    player:GossipSendMenu(1, unit)
end

local function OnGossipHello(event, player, unit)
    -- Dialogue bulle uniquement au clic sur le PNJ (pas au "Retour")
    unit:SendChatMessageToPlayer(12, 0, L(player, TALK_HELLO), player)

    ShowMainMenu(player, unit)
end

local function OnGossipSelect(event, player, unit, sender, intid, code)
    if (sender == 0) then
        -- return to main menu (sans rejouer la bulle)
        ShowMainMenu(player, unit)
        return
    end

    if (intid == 0) then
        -- Show teleport menu
        for i, v in ipairs(T[sender]) do
            player:GossipMenuAddItem(0, v.icon .. " " .. L(player, v.name), sender, i)
        end
        player:GossipMenuAddItem(0, L(player, { [0] = "Back", [LOCALE_FRFR] = "Retour" }), 0, 0)
        player:GossipSendMenu(1, unit)
        return
    else
        -- teleport
        local dest = T[sender][intid]
        player:Teleport(dest.map, dest.x, dest.y, dest.z, dest.o)
    end

    player:GossipComplete()
end

RegisterCreatureGossipEvent(UnitEntry, 1, OnGossipHello)
RegisterCreatureGossipEvent(UnitEntry, 2, OnGossipSelect)
