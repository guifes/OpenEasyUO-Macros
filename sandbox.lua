dofile(getinstalldir().."scripts\\lib\\FluentUO.lua")
dofile(getinstalldir().."scripts\\lib\\vector.lua")
dofile(getinstalldir().."scripts\\lib\\uoutil.lua")

print("UOTileInit success: " .. tostring(UO.TileInit()))

function getCottonCollection()
	local cotton = {}
	local nCnt = UO.ScanItems()
	for i = 1, nCnt do
	   local nID,nType,nKind,nContID,nX,nY,nZ,nStack,nRep,nCol = UO.GetItem(i)
	   if nContID == 0 then
		   local name, info = UO.Property(nID)
		   if string.match(name, "Cotton") then
			   table.insert(cotton, { id = nID, x = nX, y = nY })
			end
		end
	end
	
	return cotton
end

local cotton = getCottonCollection()
for i = 1, #cotton do
	walkToSpot(cotton[i])
	FluentUO.Action.Item.Use(cotton[i].id)
	wait(2000)
end