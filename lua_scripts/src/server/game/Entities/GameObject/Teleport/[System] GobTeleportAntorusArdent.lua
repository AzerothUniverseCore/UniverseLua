local cordenadas = {737, -12634.3, -2789.35, 2439.02, 4.72837}
local players
local function Update(evento, unidad, diferencia)

	players = unidad:GetPlayersInRange( 0.6, 0, 1 )
	
	for i = 1, #players do
		local map, x, y, z, o = table.unpack(cordenadas)
		players[i]:Teleport(map, x, y, z, o)
	end
end

RegisterGameObjectEvent(739552, 1, Update)