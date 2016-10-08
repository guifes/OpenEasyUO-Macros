dofile(getinstalldir().."scripts\\lib\\FluentUO.lua")
dofile(getinstalldir().."scripts\\lib\\vector.lua")
dofile(getinstalldir().."scripts\\lib\\uoutil.lua")

print("UOTileInit success: " .. tostring(UO.TileInit()))

for i = 0, 101 do
       UO.SysMessage("TESTE", 79)
end
