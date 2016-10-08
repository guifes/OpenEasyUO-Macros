function scanJournalFor(...)
	local _, count= UO.ScanJournal(0)
	for i = 0, count do
		local line = UO.GetJournal(i)
		for j = 1, #arg do
			if line == arg[j] then
				return line
			end
		end
	end
end

function customDistance(vector)
	return math.abs((vector.x + vector.y) * 0.5)
end

function reduceVectorDistance(vector, range)
	while customDistance(vector) > range do
		if math.abs(vector.x) > math.abs(vector.y) then
			vector.x = getSignal(vector.x) * (math.abs(vector.x) - 1)
		else
			vector.y = getSignal(vector.y) * (math.abs(vector.y) - 1)
		end
	end
	return vector
end

function waitReachingPoint(spot)
	while spot.x ~= UO.CharPosX or spot.y ~= UO.CharPosY do
		local lastX = UO.CharPosX
		local lastY = UO.CharPosY
		wait(1000)
		if UO.CharPosX == lastX and UO.CharPosY == lastY then
		   break
		end	
	end
	wait(100)
end

function walkToSpot(spot)
	UO.SysMessage("Walking to spot: (" .. spot.x .. ", " .. spot.y .. ")", 6)
	
	local distanceVec = {
		x = spot.x - UO.CharPosX,
		y = spot.y - UO.CharPosY
	}
	
	local reducedVector = reduceVectorDistance(distanceVec, 10)
	
	local midpoint = {
		x = UO.CharPosX + reducedVector.x,
		y = UO.CharPosY + reducedVector.y
	}
	
	UO.Pathfind(midpoint.x, midpoint.y)
	
	waitReachingPoint(midpoint)
	
	if not vectorInRange(spot, { x = UO.CharPosX, y = UO.CharPosY }, 1.5) then
		walkToSpot(spot)
	end
end

function checkForEquipableItem(item)
	local hand_items = Equipment().WithName(item).Items
	if hand_items ~= nil and #hand_items > 0 then
		return hand_items[1]
	end
	local bag_items = Backpack().WithName(item).Items
	if bag_items ~= nil and #bag_items > 0 then
		UO.LHandID = bag_items[1].ID
		UO.Macro(24,1)
		return bag_items[1]
	end
end

function checkForUsableItem(item)
	local hand_items = Equipment().WithName(item).Items
	if hand_items ~= nil and #hand_items > 0 then
		return hand_items[1]
	end
	local bag_items = Backpack().WithName(item).Items
	if bag_items ~= nil and #bag_items > 0 then
		return bag_items[1]
	end
end

function checkForMiningTools()
	return checkForUsableItem("Pickaxe") or checkForUsableItem("Shovel")
end

local mining_messages = {
	FAIL_TO_MINE = "You loosen some rocks but fail to find any useable ore.",
	MINE_SUCCESS = "You dig some iron ore and put it in your backpack.",
	NO_MORE_ORES = "There is no metal here to mine."
}

function mineSpot(pickaxe, spot)
	FluentUO.Action.Item.Use(pickaxe.ID)
	wait(500)
	local tileID, tileZ = UO.TileGet(spot.x, spot.y, 0)
	
	UO.LTargetTile = tileID
	UO.LTargetX = spot.x
	UO.LTargetY = spot.y
	UO.LTargetZ = tileZ 
	UO.LTargetKind = 2
	UO.Macro(22, 0)
	wait(2000)
	
	local messageFound = scanJournalFor(mining_messages.FAIL_TO_MINE, mining_messages.MINE_SUCCESS, mining_messages.NO_MORE_ORES)
	local found_ore = messageFound ~= mining_messages.NO_MORE_ORES
	if found_ore then
		UO.SysMessage("Mined spot and found ore.", 79)
	else
		UO.SysMessage("Mined spot and did not find ore.", 27)
	end
	
	return messageFound ~= mining_messages.NO_MORE_ORES
end

local lumberjacking_messages = {
	FAIL_TO_LOG = "You hack at the tree for a while, but fail to produce any useable wood.",
	LOG_SUCCESS = "You put some logs into your backpack.",
	NO_MORE_LOGS = "There's not enough wood here to harvest."
}

function chopTree(hatchet, tree)
	FluentUO.Action.Item.Use(hatchet.ID)
	wait(800)
	local tileID, tileZ = UO.TileGet(tree.x, tree.y, 3)
	UO.LTargetTile = tileID
	UO.LTargetX = tree.x
	UO.LTargetY = tree.y
	UO.LTargetZ = tileZ 
	UO.LTargetKind = 3
	UO.Macro(22, 0)
	wait(3000)
	local messageFound = scanJournalFor(lumberjacking_messages.FAIL_TO_LOG, lumberjacking_messages.LOG_SUCCESS, lumberjacking_messages.NO_MORE_LOGS)
	return messageFound ~= lumberjacking_messages.NO_MORE_LOGS
end

function findForge()
	local nCnt = UO.ScanItems()
	for i = 1, nCnt do
	   local nID,nType,nKind,nContID,nX,nY,nZ,nStack,nRep,nCol = UO.GetItem(i)
	   if nContID == 0 then
		   local name, info = UO.Property(nID)
		   if string.match(name, "Forge") then
			   --[[
			   print("Name: " .. name)
			   print("Info: " .. info)
			   print("ID: " .. nID)
			   print("Type: " .. nType)
			   print("Kind: " .. nKind)
			   print("Container ID: " .. nContID)
			   print("Position: " .. nX .. ", " .. nY .. ", " .. nZ)
			   print("Type: " .. nType)
			   print("--------------------------")
			   --]]
			   UO.SysMessage("Found forge at: (" .. nX .. ", " .. nY .. ")", 6)
			   return { id = nID, x = nX, y = nY }
			end
		end
	end
end

function findOre()
	local nCnt = UO.ScanItems()
	for i = 1, nCnt do
	   local nID,nType,nKind,nContID,nX,nY,nZ,nStack,nRep,nCol = UO.GetItem(i)
	   if nContID ~= 0 then
		   local name, info = UO.Property(nID)
		   if string.match(name, "Ore :") then
			   --[[
			   print("Name: " .. name)
			   print("Info: " .. info)
			   print("ID: " .. nID)
			   print("Type: " .. nType)
			   print("Kind: " .. nKind)
			   print("Container ID: " .. nContID)
			   print("Position: " .. nX .. ", " .. nY .. ", " .. nZ)
			   print("Type: " .. nType)
			   print("--------------------------")
			   --]]
			   return nID
			end
		end
	end
end