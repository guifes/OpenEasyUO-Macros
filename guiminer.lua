dofile(getinstalldir().."scripts\\lib\\FluentUO.lua")
dofile(getinstalldir().."scripts\\lib\\vector.lua")
dofile(getinstalldir().."scripts\\lib\\uoutil.lua")

print("UOTileInit success: " .. tostring(UO.TileInit()))

-- Configuration
local radius = 10
local maxWeightRatio = 0.9

-- Internal
local minedSpots = {}

function markSpot(spot)
	minedSpots[vectorToKey(spot)] = true
end

function checkMarkedSpot(spot)
	return minedSpots[vectorToKey(spot)]
end

function checkTile(tile_pos)
	local nType, nZ, sName = UO.TileGet(tile_pos.x, tile_pos.y, 1)
	if not checkMarkedSpot(tile_pos) then
	   return true
	end
	return false
end

function checkForSpots()
	local tiles = {}
	for r = 0, radius do
		for s = 0, r do
			if r == 0 then
				table.insert(tiles, { x = r, y = s })
			else
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
	end
	
	for i = 1, #tiles do
		local tile = { x = UO.CharPosX + tiles[i].x, y = UO.CharPosY + tiles[i].y }
		if checkTile(tile) then
			return tile
		end
	end
end

function checkWeight()
	return UO.Weight / UO.MaxWeight > maxWeightRatio
end

local tool = checkForMiningTools()
local spot = checkForSpots()
local maxWeightReached = checkWeight()
local forge = findForge()
local lastMinedSpot = nil
repeat
	while(tool ~= nil and spot ~= nil and not maxWeightReached) do
		walkToSpot(spot)
		local spotHasOre = true
		while(tool ~= nil and spotHasOre and not maxWeightReached) do
			spotHasOre = mineSpot(tool, spot)
			tool = checkForMiningTools()
			maxWeightReached = checkWeight()
		end
		markSpot(spot)
		spot = checkForSpots()
	end
	
	lastMinedSpot = spot
	
	if forge == nil then
		break
	end
	
	walkToSpot(forge)
	
	local oreID = findOre()
	while oreID ~= nil do
		FluentUO.Action.Item.Use(oreID)
		UO.LTargetID = forge.id
		UO.LTargetX = forge.x
		UO.LTargetY = forge.y
		UO.LTargetKind = 1
		UO.Macro(22, 0)
		wait(1000)
		oreID = findOre()
	end
	
	maxWeightReached = checkWeight()
	walkToSpot(lastMinedSpot)
until maxWeightReached or tool == nil

print("Finished")
UO.SysMessage("Missing either tools or max weight reached", 6)