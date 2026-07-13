local cordenadas = {792, 1695.17, 1641.01, 7.56, 4.41}
local players
local function Update(evento, unidad, diferencia)

	players = unidad:GetPlayersInRange( 0.6, 0, 1 )
	
	for i = 1, #players do
		local map, x, y, z, o = table.unpack(cordenadas)
		players[i]:Teleport(map, x, y, z, o)
	end
end

RegisterGameObjectEvent(1782150, 1, Update)