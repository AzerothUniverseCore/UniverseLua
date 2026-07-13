local cordenadas = {830, 11767.2, 12300.4, 38.6805, 5.20694}
local players
local function Update(evento, unidad, diferencia)

	players = unidad:GetPlayersInRange( 5, 0, 1 )
	
	for i = 1, #players do
		local map, x, y, z, o = table.unpack(cordenadas)
		players[i]:Teleport(map, x, y, z, o)
	end
end

RegisterGameObjectEvent(300529, 1, Update)