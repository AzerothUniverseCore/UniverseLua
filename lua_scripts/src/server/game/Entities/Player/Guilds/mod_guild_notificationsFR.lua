local function OnLogin(event, player)
	local guild = player:GetGuild()
	if guild ~= nil then
		local member;
		for _, member in ipairs(guild:GetMembers()) do
			if player:GetGuildId() == member:GetGuildId()then
				if player:GetName() ~= member:GetName() then
					member:SendBroadcastMessage(table.concat{"|cFF3CFE01[|r", "|Hplayer:", player:GetName(), "|h", player:GetName(), "|cFF3CFE01] vient de se connecter.|r"})
					member:PlayDirectSound(3081, member)
				end
			end
		end
	end
end
RegisterPlayerEvent(3, OnLogin)

local function OnLogout(event, player)
	local guild = player:GetGuild()
	if guild ~= nil then
		local member;
		for _, member in ipairs(guild:GetMembers()) do
			if player:GetGuildId() == member:GetGuildId()then
				if player:GetName() ~= member:GetName() then
					member:SendBroadcastMessage(table.concat{"|cFF3CFE01[|r", "|Hplayer:", player:GetName(), "|h", player:GetName(), "|cFF3CFE01] vient de se déconnecter.|r"})
				end
			end
		end
	end
end
RegisterPlayerEvent(4, OnLogout)
