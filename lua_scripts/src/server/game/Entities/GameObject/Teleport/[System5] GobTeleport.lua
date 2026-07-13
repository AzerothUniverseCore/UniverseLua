local cordenadas = {796, 3210.35, 2912.78, 641.60, 1.25}
local players
local function Update(evento, unidad, diferencia)

	players = unidad:GetPlayersInRange( 0.6, 0, 1 )
	
	for i = 1, #players do
		local map, x, y, z, o = table.unpack(cordenadas)
		players[i]:Teleport(map, x, y, z, o)
	end
end

RegisterGameObjectEvent(1782151, 1, Update)