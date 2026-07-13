local cordenadas = {807, 12257.1, 12427.2, -73.1602, 1.76102}
local players
local function Update(evento, unidad, diferencia)

	players = unidad:GetPlayersInRange( 2, 0, 1 )
	
	for i = 1, #players do
		local map, x, y, z, o = table.unpack(cordenadas)
		players[i]:Teleport(map, x, y, z, o)
	end
end

RegisterGameObjectEvent(300514, 1, Update)