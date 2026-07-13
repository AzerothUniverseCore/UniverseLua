local cordenadas = {807, 11792.8, 12242.9, 50.0822, 4.9733}
local players
local function Update(evento, unidad, diferencia)

	players = unidad:GetPlayersInRange( 2, 0, 1 )
	
	for i = 1, #players do
		local map, x, y, z, o = table.unpack(cordenadas)
		players[i]:Teleport(map, x, y, z, o)
	end
end

RegisterGameObjectEvent(300531, 1, Update)