local dueldata = {};

local classe = {
            [1] = "C79C6E",
            [2] = "F58CBA",
            [3] = "ABD473",
            [4] = "FFF569",
            [5] = "FFFFFF",
            [6] = "C41F3B",
            [7] = "0070DE",
            [8] = "69CCF0",
            [9] = "9482C9",
			[10] = "C41F3B",
            [11] = "FF7d0A",
			[12] = "FFF569",
			[13] = "9482C9",
			[14] = "ABD473",
			[15] = "FFFFFF",
			[16] = "F58CBA",
			[17] = "ABD473",
			[18] = "ABD473",
			[19] = "ABD473",
			[20] = "FF7d0A",
			[21] = "FFFFFF",
			[22] = "69CCF0",
			[23] = "C79C6E",
			[24] = "FFFFFF"
};

local function duelrequest(event, target, challenger)
if not (dueldata[challenger:GetGUIDLow()]) then
	dueldata[challenger:GetGUIDLow()] = {} ;
	dueldata[challenger:GetGUIDLow()].win = 0
	dueldata[challenger:GetGUIDLow()].loose = 0
	dueldata[challenger:GetGUIDLow()].cote = 0
end

if not (dueldata[target:GetGUIDLow()]) then
	dueldata[target:GetGUIDLow()] = {} ;
	dueldata[target:GetGUIDLow()].win = 0
	dueldata[target:GetGUIDLow()].loose = 0
	dueldata[target:GetGUIDLow()].cote = 0
end

local win1 = dueldata[challenger:GetGUIDLow()].win
local loose1 = dueldata[challenger:GetGUIDLow()].loose
local cote1 = dueldata[challenger:GetGUIDLow()].cote
local win2 = dueldata[target:GetGUIDLow()].win
local loose2 = dueldata[target:GetGUIDLow()].loose
local cote2 = dueldata[target:GetGUIDLow()].cote
local challengername = challenger:GetName();
local targetname = target:GetName();

	challenger:SendBroadcastMessage("Mes salutations |cff" .. classe[challenger:GetClass()] .. "" .. challengername .. "|cfff4ed0c, vous défier en duel |cff" .. classe[target:GetClass()] .. "" .. targetname .. "|cfff4ed0c.");
	challenger:SendBroadcastMessage("Ce joueur à un total de : |cff" .. classe[target:GetClass()] .. "" .. win2 .. " |cfff4ed0cvictoire(s) et |cff" .. classe[target:GetClass()] .. "" .. loose2 .. " |cfff4ed0cdéfaite(s)." );
	challenger:SendBroadcastMessage("Ce qui fait une côte de : |cff" .. classe[target:GetClass()] .. "" .. cote2 .. " |cfff4ed0cpoint(s).");
	target:SendBroadcastMessage("Mes salutations |cff" .. classe[target:GetClass()] .. "" .. targetname .. "|cfff4ed0c, vous êtes défier en duel par |cff" .. classe[challenger:GetClass()] .. "" .. challengername .. "|cfff4ed0c.");
	target:SendBroadcastMessage("Ce joueur à un total de : |cff" .. classe[challenger:GetClass()] .. "" .. win1 .. " |cfff4ed0cvictoire(s) et |cff" .. classe[challenger:GetClass()] .. "" .. loose1 .. " |cfff4ed0cdéfaite(s)." );
	target:SendBroadcastMessage("Ce qui fait une côte de : |cff" .. classe[challenger:GetClass()] .. "" .. cote1 .. " |cfff4ed0cpoint(s).");
end

RegisterPlayerEvent(9, duelrequest)

local function duelstart(event, player1, player2)
	player1:SetHealth(player1:GetMaxHealth())
	player1:SetPower(player1:GetMaxPower(0), 0)
	player1:ResetAllCooldowns()
	player2:SetHealth(player2:GetMaxHealth())
	player2:SetPower(player2:GetMaxPower(0), 0)
	player2:ResetAllCooldowns()
end

RegisterPlayerEvent(10, duelstart)

local function duelend(event, winner, loser, type)
local win1 = dueldata[winner:GetGUIDLow()].win
local loose1 = dueldata[winner:GetGUIDLow()].loose
local cote1 = dueldata[winner:GetGUIDLow()].cote
local win2 = dueldata[loser:GetGUIDLow()].win
local loose2 = dueldata[loser:GetGUIDLow()].loose
local cote2 = dueldata[loser:GetGUIDLow()].cote
local winnername = winner:GetName();
local losername = loser:GetName();

	winner:SetHealth(winner:GetMaxHealth())
	winner:SetPower(winner:GetMaxPower(0), 0)
	winner:ResetAllCooldowns()
	loser:SetHealth(loser:GetMaxHealth())
	loser:SetPower(loser:GetMaxPower(0), 0)
	loser:ResetAllCooldowns()
	
	dueldata[winner:GetGUIDLow()].win = dueldata[winner:GetGUIDLow()].win + 1
	dueldata[winner:GetGUIDLow()].cote = dueldata[winner:GetGUIDLow()].cote + 50
	dueldata[loser:GetGUIDLow()].loose = dueldata[loser:GetGUIDLow()].loose + 1
	
	if (dueldata[loser:GetGUIDLow()].cote >= 50) then
		dueldata[loser:GetGUIDLow()].cote = dueldata[loser:GetGUIDLow()].cote - 50
	elseif (dueldata[loser:GetGUIDLow()].cote == 0) then
		dueldata[loser:GetGUIDLow()].cote = dueldata[loser:GetGUIDLow()].cote - 0
	end
	
	winner:SendBroadcastMessage("Vous avez gagner un duel contre |cff" .. classe[loser:GetClass()] .. "" .. losername .. "|cfff4ed0c.");
	winner:SendBroadcastMessage("Vous avez un total de : |cff" .. classe[winner:GetClass()] .. "" .. win1 .. " |cfff4ed0cvictoire(s) et |cff" .. classe[winner:GetClass()] .. "" .. loose1 .. " |cfff4ed0cdéfaite(s).");
	winner:SendBroadcastMessage("Vous avez une côte de : |cff" .. classe[winner:GetClass()] .. "" .. cote1 .. " |cfff4ed0cpoint(s).");
	loser:SendBroadcastMessage("Vous avez perdu un duel contre |cff" .. classe[winner:GetClass()] .. "" .. winnername .. "|cfff4ed0c.");
	loser:SendBroadcastMessage("Vous avez un total de : |cff" .. classe[loser:GetClass()] .. "" .. win2 .. " |cfff4ed0cvictoire(s) et |cff" .. classe[loser:GetClass()] .. "" .. loose2 .. " |cfff4ed0cdéfaite(s).");
	loser:SendBroadcastMessage("Ce qui fait une côte de : |cff" .. classe[loser:GetClass()] .. "" .. cote2 .. " |cfff4ed0cpoint(s).");
end

RegisterPlayerEvent(11, duelend)