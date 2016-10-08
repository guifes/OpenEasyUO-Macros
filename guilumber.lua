dofile(getinstalldir().."scripts\\lib\\FluentUO.lua")
dofile(getinstalldir().."scripts\\lib\\vector.lua")
dofile(getinstalldir().."scripts\\lib\\uoutil.lua")

print("UOTileInit success: " .. tostring(UO.TileInit()))

-- Configuration
local radius = 15
local maxWeightRatio = 0.9

-- Internal
local chopped = {}

function markTree(tree)
	chopped[vectorToKey(tree)] = true
end

function checkMarkedTree(tree)
	return chopped[vectorToKey(tree)]
end

function checkTile(tile_pos)
	local nType, nZ, sName = UO.TileGet(tile_pos.x, tile_pos.y, 3)
	if string.match(sName, "tree") and not checkMarkedTree(tile_pos) then
	   --print("(" .. tile_pos.x .. ", " .. tile_pos.y .. ") " .. sName)
	   return true
	end
	return false
end

function checkForTrees()
	local tiles = {}
	for r = 1, radius do
		for s = 0, r do
			table.insert(tiles, { x = r, y = s })
			table.insert(tiles, { x = -r, y = s })

			if not (r == s) then
				table.insert(tiles, { x = s, y = r })
			end

			table.insert(tiles, { x = s, y = -r })

			if s > 0 then
				if not (r == s) then
					table.insert(tiles, { x = r, y = -s })
					table.insert(tiles, { x = -r, y = -s })
					table.insert(tiles, { x = -s, y = r })
				end
			 
				table.insert(tiles, { x = -s, y = -r })
			end
		end
	end
	
	for i = 1, #tiles do
		local tile = { x = UO.CharPosX + tiles[i].x, y = UO.CharPosY + tiles[i].y }
		if checkTile(tile) then
			return tile
		end
	end
end

function checkForHatchets()
	local hand_items = Equipment().WithName("Hatchet").Items
	if hand_items ~= nil and #hand_items > 0 then
		return hand_items[1]
	end
	local bag_items = Backpack().WithName("Hatchet").Items
	if bag_items ~= nil and #bag_items > 0 then
		UO.LHandID = bag_items[1].ID
		UO.Macro(24,1)
		return bag_items[1]
	end
end

function checkWeight()
	print(UO.Weight / UO.MaxWeight)
	return UO.Weight / UO.MaxWeight > maxWeightRatio
end

local hatchet = checkForHatchets()
local tree = checkForTrees()
local maxWeightReached = false

while(hatchet ~= nil and tree ~= nil and not maxWeightReached) do
	walkToSpot(tree)
	local treeHasLog = true
	while(hatchet ~= nil and treeHasLog and not maxWeightReached) do
		treeHasLog = chopTree(hatchet, tree)
		hatchet = checkForHatchets()
		maxWeightReached = checkWeight()
	end
	print("Tree has no more logs")
	markTree(tree)
	tree = checkForTrees()
end

print("Finished")