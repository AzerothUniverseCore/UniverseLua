--[==[
    = How to add new locations =
    Example:
    The first line will be the main menu ID (Here [1], 
    increment this for each main menu option!),
    the main menu gossip title (Here "Horde Cities"),
    as well as which faction can use the said menu (Here 1 (Horde)). 
    0 = Alliance, 1 = Horde, 2 = Both
    The second line is the name of the main menu's sub menus, 
    separated by name (Here "Orgrimmar") and teleport coordinates
    using Map, X, Y, Z, O (Here 1, 1503, -4415.5, 22, 0)
    [1] = { "Horde Cities", 1,    --  This will be the main menu title, as well as which faction can use the said menu. 0 = Alliance, 1 = Horde, 2 = Both
        {"Orgrimmar", 1, 1503, -4415.5, 22, 0},
    },
    You can copy paste the above into the script and change the values as informed.
]==]

local ItemEntry = 90015

local T = {
    [1] = { "The Burning Crusade", 2,
        {"Porte des ténèbres", 0, -11802.721680, -3197.981445, -28.712740, 3.090865},
    },
}

-- CODE STUFFS! DO NOT EDIT BELOW
-- UNLESS YOU KNOW WHAT YOU'RE DOING!

local function OnGossipHello(event, player, item)
    -- Vérifie si le joueur est en BG ou en arène
    if player:GetMap():IsBattleground() or player:GetMap():IsArena() then
        player:SendBroadcastMessage("Vous ne pouvez pas accéder au menu de téléportation depuis un champ de bataille ou une arène.")
        player:GossipComplete()
        return
    end

    -- Show main menu
    for i, v in ipairs(T) do
        if (v[2] == 2 or v[2] == player:GetTeam()) then
            player:GossipMenuAddItem(0, v[1], i, 0)
        end
    end
    player:GossipSendMenu(1, item)
end 

local function OnGossipSelect(event, player, item, sender, intid, code)
    if (sender == 0) then
        -- retour au menu principal
        OnGossipHello(event, player, item)
        return
    end

    if (intid == 0) then
        -- afficher le menu de téléportation
        for i, v in ipairs(T[sender]) do
            if (i > 2) then
                player:GossipMenuAddItem(0, v[1], sender, i)
            end
        end
        player:GossipMenuAddItem(0, "Retour", 0, 0)
        player:GossipSendMenu(1, item)
        return
    else
        -- empêcher la téléportation si le joueur est en BG ou en arène
        if player:GetMap():IsBattleground() or player:GetMap():IsArena() then
            player:SendBroadcastMessage("Vous ne pouvez pas vous téléporter depuis un champ de bataille ou une arène.")
            player:GossipComplete()
            return
        end

        -- téléporter le joueur
        local name, map, x, y, z, o = table.unpack(T[sender][intid])
        player:Teleport(map, x, y, z, o)
    end
    
    player:GossipComplete()
end

RegisterItemGossipEvent(ItemEntry, 1, OnGossipHello)
RegisterItemGossipEvent(ItemEntry, 2, OnGossipSelect)