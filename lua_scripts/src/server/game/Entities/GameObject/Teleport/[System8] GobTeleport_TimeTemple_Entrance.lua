local cordenadas = {823, 13503.9, 12964.1, 503.49, 3.89949}
local players
local function Update(evento, unidad, diferencia)

	players = unidad:GetPlayersInRange( 5, 0, 1 )
	
	for i = 1, #players do
		local map, x, y, z, o = table.unpack(cordenadas)
		players[i]:Teleport(map, x, y, z, o)
	end
end

RegisterGameObjectEvent(300512, 1, Update)