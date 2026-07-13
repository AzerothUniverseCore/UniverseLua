local cordenadas = {735, 4500.3, -1466.4, 385.6, 4.71}
local players
local function Update(evento, unidad, diferencia)

	players = unidad:GetPlayersInRange( 0.6, 0, 1 )
	
	for i = 1, #players do
		local map, x, y, z, o = table.unpack(cordenadas)
		players[i]:Teleport(map, x, y, z, o)
	end
end

RegisterGameObjectEvent(1882150, 1, Update)