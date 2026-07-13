local cordenadas = {819, 1788.73, -247.091, 260.766, 5.54082}
local players
local function Update(evento, unidad, diferencia)

	players = unidad:GetPlayersInRange( 0.6, 0, 1 )
	
	for i = 1, #players do
		local map, x, y, z, o = table.unpack(cordenadas)
		players[i]:Teleport(map, x, y, z, o)
	end
end

RegisterGameObjectEvent(814553, 1, Update)