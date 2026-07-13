local cordenadas = {825, 14697.4, 14634.1, 318.109, 0.742202}
local players
local function Update(evento, unidad, diferencia)

	players = unidad:GetPlayersInRange( 3, 0, 1 )
	
	for i = 1, #players do
		local map, x, y, z, o = table.unpack(cordenadas)
		players[i]:Teleport(map, x, y, z, o)
	end
end

RegisterGameObjectEvent(300516, 1, Update)