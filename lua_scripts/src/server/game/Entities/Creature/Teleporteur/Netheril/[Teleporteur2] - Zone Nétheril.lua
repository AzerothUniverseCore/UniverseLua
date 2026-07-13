--[[    How to add new locations!
               
                Example:
               
                The first line will be the main menu ID (Here [1],
                increment this for each main menu option!),
                the main menu gossip title (Here "Horde Cities"),
                as well as which faction can use the said menu (Here 1 (Horde)).
                0 = Alliance, 1 = Horde, 2 = Both
               
                The second line is the name of the main menu's sub menus,
                separated by name (Here "Orgrimmar") and teleport coordinates
                using Map, X, Y, Z, O (Here 1, 1503, -4415.5, 22, 0)
               
                [1] = { "Horde Cities", 1,      --  
                        {"Orgrimmar", 1, 1503, -4415.5, 22, 0},
                },
               
                You can copy paste the above into the script and change the values as informed.
]]
 
 
local UnitEntry = 2000012
 
local T = {
        [1] = { "|TInterface\\icons\\spell_shadow_metamorphosis:35|t |cff008000Assauts de la Légion (80)", 2,
                {"|TInterface\\icons\\achievement_zone_ashenvale_01:35|t |cff008000Nethéril Camp 1", 725, -14749.907227, -13192.527344, 34.431049, 1.896851},
				{"|TInterface\\icons\\achievement_zone_ashenvale_01:35|t |cff008000Nethéril Camp 2", 725, -14763.747070, -13609.506836, 27.086132, 4.800987},
                               
                },				
};               
 
 
--[[ CODE STUFFS! DO NOT EDIT BELOW ]]--
--[[ UNLESS YOU KNOW WHAT YOU'RE DOING! ]]--
 
function Teleporter_Gossip(event, player, unit)
        if (#T <= 10) then
                for i, v in ipairs(T) do
                        if(v[2] == 2 or v[2] == player:GetTeam()) then
                                player:GossipMenuAddItem(0, v[1], 0, i)
                        end
                end
                player:GossipSendMenu(1, unit)
        else
                print("This teleporter only supports 10 different menus.")
        end
end    
 
function Teleporter_Event(event, player, unit, sender, intid, code)
        if(intid == 0) then
                Teleporter_Gossip(event, player, unit)
        elseif(intid <= 10) then
                for i, v in ipairs(T[intid]) do
                        if (i > 2) then
                                player:GossipMenuAddItem(0, v[1], 0, intid..i)
                        end
                end
                player:GossipMenuAddItem(0, "Retour", 0, 0)
                player:GossipSendMenu(1, unit)
        elseif(intid > 10) then
                for i = 1, #T do
                        for j, v in ipairs(T[i]) do
                                if(intid == tonumber(i..j)) then
                                        player:GossipComplete()
                                        player:Teleport(v[2], v[3], v[4], v[5], v[6])
                                end
                        end
                end
        end
end
 
RegisterCreatureGossipEvent(UnitEntry, 1, Teleporter_Gossip)
RegisterCreatureGossipEvent(UnitEntry, 2, Teleporter_Event)