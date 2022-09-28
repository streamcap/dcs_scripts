function getTabs(number)
	local result = ""
	for _ = 1, number do
		result = result.."  "
	end
	return result
end

function printTable(theTable, logFunction, level)
	if logFunction == nil then
		logFunction = function(logLine)
			env.info(logLine)
		end
	end
	if level == nil then
		level = 0
	end
	if theTable == nil or type(theTable) ~= "table" then
		logFunction(tostring(theTable))
		return
	end
	for k,v in pairs(theTable) do
		if type(k) == "table" then
			logFunction(getTabs(level).."----- key -----")
			printTable(k, logFunction, level)
			logFunction(getTabs(level).."----- value -----")
			if (type(v) == "table") then
				logFunction(getTabs(level).."{")
				printTable(v, logFunction,level + 1)
				logFunction(getTabs(level).."}")
			else
				if (type(v) == "boolean") then
					logFunction(getTabs(level)..tostring(v))
				else
					if (type(v) == "function") then
						logFunction(getTabs(level).."a function")
					else
						logFunction(getTabs(level)..v)
					end
				end
			end
		else
			if (type(v) == "table") then
				logFunction(getTabs(level)..k.." = {")
				printTable(v, logFunction,level + 1)
				logFunction(getTabs(level).."}")
			else
				if (type(v) == "boolean") then
					logFunction(getTabs(level)..k.." = "..tostring(v))
				else
					if (type(v) == "function") then
						logFunction(getTabs(level)..k.." which is a function")
					else
						logFunction(getTabs(level)..k.." = "..v)
					end
				end
			end
		end
    end
end

function pow(value)
	return value * value
end

function unpackTable(tableToUnpack, startIndex, endIndex)
	if startIndex == nil then
		startIndex = 1
	end
	if endIndex == nil or endIndex > #tableToUnpack then
		endIndex = #tableToUnpack
	end
	local index = 1
	local resultSet = {}
	for k, v in pairs(tableToUnpack) do
		if index >= startIndex and index <= endIndex then
			resultSet[k] = v
		end
		index = index + 1
	end
	return resultSet
end

function getTheatre()
	return env.mission.theatre
end

function round(number)
	local integral, fractional = math.modf(number)
	if fractional > 0.5 then
		return integral + 1
	else
		return integral
	end
end

function degreeToRadian(degrees)
	return degrees / (360 / (2 * math.pi) )
end

function positionToHeading(position)
	local dotProduct = 1 * position["x"] + 0 * position["z"]
	local magnitudeProduct = math.sqrt(math.pow(1, 2) + math.pow(0, 2)) * math.sqrt(math.pow(position["x"], 2) + math.pow(position["z"], 2))
	local acos = math.acos(dotProduct / magnitudeProduct)
	if (position["z"] >= 0) then
		return acos
	else
		return math.pi * 2 - acos
	end
end

function unitInZone(unitId, zoneName)
	local zone = trigger.misc.getZone(zoneName)
	local unitPoint = Unit.getPoint(unitId)
	unitPoint["x"] = unitPoint["x"] - zone.point["x"]
	unitPoint["z"] = unitPoint["z"] - zone.point["z"]
	return vectorMagnitude(unitPoint) < zone.radius
end

function vectorMagnitude(vector)
	return math.sqrt(math.pow(vector["x"], 2) + math.pow(vector["z"], 2))
end

function meterToNm(distance)
	return distance * 0.000539956803
end

function nmToMeters(distance)
	return distance * 1852
end

function startsWith(str, prefix)
	return str:sub(1, #prefix) == prefix
end

function endsWith(str, postfix)
	return str:sub(#str - #postfix + 1,#str) == postfix
end

function split(str, delimiter)
	local result = {}
	local currentResult = ""
	local currentChar = ""
	for index = 1, #str do
		currentChar = str:sub(index, index)
		if currentChar == delimiter then
			if #currentResult > 0 then
				table.insert(result, currentResult)
				currentResult = ""
			end
		else
			currentResult = currentResult..currentChar
		end
	end
	if #currentResult > 0 then
		table.insert(result, currentResult)
		currentResult = ""
	end
	return result
end

function deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepCopy(orig_key)] = deepCopy(orig_value)
        end
        setmetatable(copy, deepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function sortPairs(t, order)
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function tableLength(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

function speedFromVector(vector)
	return math.sqrt(pow(vector["x"]) + pow(vector["z"]) + pow(vector["y"]))
end

function msToKnots(speed)
	return speed * 3.6 * 0.539
end