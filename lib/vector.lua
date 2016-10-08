function getSignal(value)
	if value ~= 0 then
		return value / math.abs(value)
	else
		return 0
	end
end

function printVector(vector)
	print("(" .. vector.x .. ", " .. vector.y .. ") ")
end

function vectorToKey(vector)
	return tostring(vector.x) .. "_" .. tostring(vector.y)
end

function vectorInRange(a, b, range)
	local vector = { x = b.x - a.x, y = b.y - a.y }
	
	return math.sqrt((vector.x * vector.x) + (vector.y * vector.y)) <= range
end