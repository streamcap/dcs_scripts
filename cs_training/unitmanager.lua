activeGroups = {}
spawnedGroundGroupIndexes = {}
spawnedAirGroupIndexes = {}
spawnedFacGroups = {}
spawnedAirUnitIndex = 0
groupRandomPoint = {}

function registerFacGroups(areaName, groups)
	spawnedFacGroups[areaName] = groups
	rebuildRadioMenusForAllGroups()
end

function clearFacArea(areaName)
	local groupsInArea = spawnedFacGroups[areaName]
	if groupsInArea then
		for _, v in pairs(groupsInArea) do
			Group.destroy(v)
			activeFacAreas[areaName] = nil
			spawnedFacGroups[areaName] = nil
		end
	end
end

function registerGroundGroup(group, triggerZoneName, triggerAreaIndex)
	local groupData = {}
	groupData["name"] = Group.getName(group)
	groupData["group"] = group
	groupData["zoneName"] = triggerZoneName
	groupData["zoneIndex"] = triggerAreaIndex
	table.insert(activeGroups, groupData)
	rebuildRadioMenusForAllGroups()
end

function registerAirGroup(airGroupName, airGroupId, airGroupTargetId)
	spawnedAirGroupIndexes[airGroupName] = { id = airGroupId, target = airGroupTargetId}
	rebuildRadioMenusForAllGroups()
end

function cleanupGroups()
	for k, v in pairs(spawnedAirGroupIndexes) do
		local groupIsDead = true
		if Group.isExist(v.id) then
			for _, unit in pairs(Group.getUnits(v.id)) do
				if Unit.getLife(unit) >= 1 then
					groupIsDead = false
					break
				end
			end
		end
		local targetIsDead = true;
		if Group.isExist(v.target) then
			for _, unit in pairs(Group.getUnits(v.target)) do
				if Unit.getLife(unit) >= 1 then
					targetIsDead = false
					break
				end
			end
		end
		if targetIsDead or groupIsDead then
			Group.destroy(v.id)
			spawnedAirGroupIndexes[k] = nil
		end
	end
end

function isZoneIndexOccupied(zoneName, zoneIndex)
	for _, v in pairs(activeGroups) do
		if v["zoneName"] == zoneName and v["zoneIndex"] == zoneIndex then
			return true
		end
	end
	return false
end

function isZoneFull(zoneName)
	local index = 0
	for _, v in pairs(activeGroups) do
		if v["zoneName"] == zoneName then
			index = index + 1
		end
	end
	return index == 10
end

function generateGroundGroupName(zoneName)
	local index = 1
	if spawnedGroundGroupIndexes[zoneName] then
		index = spawnedGroundGroupIndexes[zoneName] + 1
	end
	spawnedGroundGroupIndexes[zoneName] = index
	return "Ground group " .. zoneName .. " " .. spawnedGroundGroupIndexes[zoneName]
end

function generateAirGroupName()
	spawnedAirUnitIndex = spawnedAirUnitIndex + 1
	return "Air group " .. spawnedAirUnitIndex
end

function getRandomPointNearGroup(groupId)
	if groupRandomPoint[groupId] then
		return groupRandomPoint[groupId]
	end
	local unitSet = Group.getUnits(groupId)
	local randomUnit = unitSet[math.random(tableLength(unitSet))]
	local randomUnitPoint = Unit.getPoint(randomUnit)
	randomUnitPoint["x"] = randomUnitPoint["x"] + math.random() * 200 - 50
	randomUnitPoint["z"] = randomUnitPoint["z"] + math.random() * 200 - 50
	groupRandomPoint[groupId] = randomUnitPoint
	return randomUnitPoint
end

function spawnSmokeOnGroupId(groupId, requesterGroupId)
	trigger.action.smoke(getRandomPointNearGroup(groupId), 1)
	trigger.action.outTextForGroup(requesterGroupId["id_"], "Red smoke near target!", 10)
end

function deleteGroundGroup(groupId)
	for k, v in pairs(activeGroups) do
		if v["group"] == groupId then
			Group.destroy(groupId)
			spawnedGroundGroupIndexes[k] = nil
			activeGroups[k] = nil
			rebuildRadioMenusForAllGroups()
		end
	end
end

function deleteAirGroup(groupId)
	for k, v in pairs(spawnedAirGroupIndexes) do
		if v.id == groupId then
			Group.destroy(groupId)
			spawnedAirGroupIndexes[k] = nil
			rebuildRadioMenusForAllGroups()
		end
	end
end

function listVectorToTarget(groupId, requesterGroupId)
	local message = "Vectors for each group member are:"
	local index = 1
	for _, v in pairs(Group.getUnits(requesterGroupId)) do
		local unitPoint = Unit.getPoint(Group.getUnits(groupId)[1])
		local requesterPoint = Unit.getPoint(v)
		unitPoint["x"] = unitPoint["x"] - requesterPoint["x"]
		unitPoint["z"] = unitPoint["z"] - requesterPoint["z"]
		local headingDegrees, _ = math.modf(math.deg(positionToHeading(unitPoint)))
		if headingDegrees == 0 then
			headingDegrees = 360
		end
		local headingDegString = tostring(headingDegrees)
		for _ = #headingDegString, 2 do
			headingDegString = "0"..headingDegString
		end
		message = message.."\nVector for unit "..index.." is "..headingDegString.." for "..round(meterToNm(vectorMagnitude(unitPoint)))
		index = index + 1
	end
	trigger.action.outTextForGroup(requesterGroupId["id_"], message, 30)
end

function roundDecimal(nr, places)
	local text = tostring(nr)
	local wholeNumberLength = #(split(text, ".")[1])
	return tonumber(text:sub(1, wholeNumberLength + 1 + places))
end

function getSixtiesFraction(value)
	local fraction = (value / 100) * 60
	return math.floor(fraction)
end

function getMinutes(value)
	local minutes, _ = math.modf(value * 100)
	if minutes > 9 then
		return getSixtiesFraction(minutes)
	else
		return "0"..minutes
	end
end

function getSeconds(value)
	local _, rest = math.modf(value * 100)
	rest = roundDecimal(rest, 1)
	if rest > 9 then
		return getSixtiesFraction(math.floor(rest * 100))
	else
		return "0"..rest
	end
end

function longitudeToDegMinSec(longitude)
	local resultString
	if longitude > 0 then
		resultString = "E"
	else
		resultString = "W"
	end
	local degrees, decimals = math.modf(math.abs(longitude))
	resultString = resultString..degrees.."° "
	resultString = resultString..getMinutes(decimals).."' "
	resultString = resultString..getSeconds(decimals).."\" "
	return resultString
end

function latitudeToDegMinSec(latitude)
	local resultString
	if latitude > 0 then
		resultString = "N"
	else
		resultString = "S"
	end
	local degrees, decimals = math.modf(math.abs(latitude))
	resultString = resultString..degrees.."° "
	resultString = resultString..getMinutes(decimals).."' "
	resultString = resultString..getSeconds(decimals).."\" "
	return resultString
end

function listTargetDegMinSecLonLat(groupId, requesterGroupId)
	local latitude, longitude, _ = coord.LOtoLL(getRandomPointNearGroup(groupId))
	trigger.action.outTextForGroup(requesterGroupId["id_"], "Target is near "..latitudeToDegMinSec(latitude).." "..longitudeToDegMinSec(longitude), 30)
end

function listTargetDegDecimalLonLat(groupId, requesterGroupId)
	local latitude, longitude, _ = coord.LOtoLL(getRandomPointNearGroup(groupId))
	trigger.action.outTextForGroup(requesterGroupId["id_"], "Target is near lon: "..roundDecimal(longitude, 3).." lat: "..roundDecimal(latitude,3), 30)
end

function listTargetGrid(groupId, requesterGroupId)
	local unitSet = Group.getUnits(groupId)
	local randomUnit = unitSet[math.random(tableLength(unitSet))]
	local randomUnitPoint = Unit.getPoint(randomUnit)
	local mgrs = coord.LLtoMGRS(coord.LOtoLL(randomUnitPoint))
	trigger.action.outTextForGroup(requesterGroupId["id_"], "Target is in ".. mgrs["MGRSDigraph"]..tostring(mgrs["Easting"]):sub(1,1)..tostring(mgrs["Northing"]):sub(1,1), 10)
end

local eventHandler = {}
function eventHandler:onEvent(event)
	if (not event) or event.id == 0 then
		return
	end
	if event.id == 5 or event.id == 8 or event.id == 21 then
		cleanupGroups()
	end
end
world.addEventHandler(eventHandler)