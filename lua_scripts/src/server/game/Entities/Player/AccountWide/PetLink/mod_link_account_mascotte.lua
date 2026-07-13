-- Alliance mounts listing

local CommonMountList =	{	53082,
							30152,
							30156,
							69536,
							69535,
							25849,
							67527,
							61855,
							55068,
							40549,
							45127,
							68767,
							24988,
							45175,
							45125,
							54847,
							56806,
							10714,
							10716,
							};
				
local AllianceMountList = {
							};

-- Horde mounts listing
local HordeMountList 	= {
							};	
							
local EMPTY_VALUE = 0

local function GetSpell(event, player)
	for c, mountSpell in ipairs(CommonMountList) do
		if (player:HasSpell(mountSpell) == true) then
			local getAccountSpell = AuthDBQuery('SELECT commonMountID FROM auc_eluna.mod_link_account_mascotte WHERE accountID = '..player:GetAccountId()..' AND commonMountID = '..mountSpell..';');
			if getAccountSpell == nil then
				local SetAccountSpell = AuthDBQuery('INSERT IGNORE INTO auc_eluna.mod_link_account_mascotte VALUES ('..player:GetAccountId()..', '..mountSpell..', '..EMPTY_VALUE..', '..EMPTY_VALUE..');');
			end
		end	
	end	
	if (player:IsAlliance() == true) then
		for c, mountSpell in ipairs(AllianceMountList) do
			if (player:HasSpell(mountSpell) == true) then
				local getAccountSpell = AuthDBQuery('SELECT allianceMountID FROM auc_eluna.mod_link_account_mascotte WHERE accountID = '..player:GetAccountId()..' AND allianceMountID = '..mountSpell..';');
				if getAccountSpell == nil then
					local SetAccountSpell = AuthDBQuery('INSERT IGNORE INTO auc_eluna.mod_link_account_mascotte VALUES ('..player:GetAccountId()..', '..EMPTY_VALUE..', '..mountSpell..', '..EMPTY_VALUE..');');
				end
			end	
		end	
	elseif (player:IsHorde() == true) then
		for c, mountSpell in ipairs(HordeMountList) do
			if (player:HasSpell(mountSpell) == true) then
				local getAccountSpell = AuthDBQuery('SELECT hordeMountID FROM auc_eluna.mod_link_account_mascotte WHERE accountID = '..player:GetAccountId()..' AND hordeMountID = '..mountSpell..';');
				if getAccountSpell == nil then
					local SetAccountSpell = AuthDBQuery('INSERT IGNORE INTO auc_eluna.mod_link_account_mascotte VALUES ('..player:GetAccountId()..', '..EMPTY_VALUE..', '..EMPTY_VALUE..', '..mountSpell..');');
				end
			end
		end 
	end
 end
-- Player event on logout 
RegisterPlayerEvent(4, GetSpell)

local function SetSpell (event, player)
	if (player:GetLevel() >= 20) then
		local GetSpell = AuthDBQuery('SELECT commonMountID FROM auc_eluna.mod_link_account_mascotte WHERE accountid = '..player:GetAccountId()..';');
		if GetSpell ~= nil then
			repeat
			local mountID = GetSpell:GetUInt32(0);
			if (mountID ~= EMPTY_VALUE and player:HasSpell(mountID) == false) then
				player:LearnSpell(mountID);
			end
			until not GetSpell:NextRow();
		end
		if (player:IsAlliance() == true) then
			local GetSpell = AuthDBQuery('SELECT allianceMountID FROM auc_eluna.mod_link_account_mascotte WHERE accountid = '..player:GetAccountId()..';');
			if GetSpell ~= nil then
				repeat
				local mountID = GetSpell:GetUInt32(0);
				if (mountID ~= EMPTY_VALUE and player:HasSpell(mountID) == false) then
					player:LearnSpell(mountID);
				end
				until not GetSpell:NextRow();
			end
		elseif (player:IsHorde() == true) then
			local GetSpell = AuthDBQuery('SELECT hordeMountID FROM auc_eluna.mod_link_account_mascotte WHERE accountid = '..player:GetAccountId()..';');
			if GetSpell ~= nil then
				repeat
				local mountID = GetSpell:GetUInt32(0);
				if (mountID ~= EMPTY_VALUE and player:HasSpell(mountID) == false) then
					player:LearnSpell(mountID);
				end
				until not GetSpell:NextRow();
			end
		end
	end	
end
-- Player event on login
RegisterPlayerEvent(3, SetSpell);
-- Player event on level change
RegisterPlayerEvent(13, SetSpell);







