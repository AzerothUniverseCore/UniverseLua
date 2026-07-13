local cordenadas = {807, 12451, 12770.2, 0.963407, 3.05291}
local players
local function Update(evento, unidad, diferencia)

	players = unidad:GetPlayersInRange( 6, 0, 1 )
	
	for i = 1, #players do
		local map, x, y, z, o = table.unpack(cordenadas)
		players[i]:Teleport(map, x, y, z, o)
	end
end

RegisterGameObjectEvent(300518, 1, Update)