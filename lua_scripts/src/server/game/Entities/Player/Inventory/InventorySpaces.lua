--Return empty inventory spaces number of player
function CountEmptyInventorySpaces(player)
	--Vars
	local emptySpaceCount = 0
	local selectedItem
	local currentBag
	local currentBagSize = 0
	--
	--Main backpack
	for i = 23,38,1
	do
		selectedItem = player:GetItemByPos(255, i)

		if (selectedItem == nil) then
			emptySpaceCount = emptySpaceCount + 1
		end
	end
	--Count all four bags (id from 19 to 22 included)
	for b = 19,22,1
	do
		--First get if the player has a bag equipped
		currentBag = player:GetItemByPos(255, b)
		if (currentBag ~= nil) then
			--Get the bag size
			currentBagSize = currentBag:GetBagSize() - 1
			for i = 0,currentBagSize,1
			do
				--Count the nil items !
				selectedItem = player:GetItemByPos(b, i)
				if (selectedItem == nil) then
					emptySpaceCount = emptySpaceCount + 1
				end
			end
		end
	end
	return emptySpaceCount
end
