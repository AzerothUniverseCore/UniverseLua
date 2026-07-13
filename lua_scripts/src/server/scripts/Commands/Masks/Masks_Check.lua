local commands = {
{"Masks", "masks"},
};

local function MasksCheck(event, player, command)
local Account_Rank_Check = player:GetGMRank()

for i = 1, #commands do
if(command ==  commands[i]) and Account_Rank_Check < 1 then
		player:SendBroadcastMessage("|cffffff33You cannot use that command.")
     	return;
 end
end
		

if(command == commands[1][1] or command == commands[1][2]) and Account_Rank_Check >= 1 then
player:SendBroadcastMessage("Your race and class masks:", 0)
player:SendBroadcastMessage("Race Mask: "..player:GetRaceMask().."", 0)
player:SendBroadcastMessage("Class Mask: "..player:GetClassMask().."", 0)
player:SendBroadcastMessage("Race id: "..player:GetRace().."", 0)
player:SendBroadcastMessage("Class id: "..player:GetClass().."", 0)
end
end


RegisterPlayerEvent(42, MasksCheck)
