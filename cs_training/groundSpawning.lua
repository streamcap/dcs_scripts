function transformUnitProps(unit, xTrans, yTrans, originX, originY, rotationAngle)
	local relativeX = unit.x + xTrans - originX
	local relativeY = unit.y + yTrans - originY
	unit.x = (relativeX * math.cos(rotationAngle) - relativeY * math.sin(rotationAngle)) + originX
	unit.y = (relativeX * math.sin(rotationAngle) + relativeY * math.cos(rotationAngle)) + originY
	unit.heading = unit.heading + rotationAngle
	return unit
end

function calculateTranslation(rawData, x, y)
	local yMin = 0
	local xMin = 0
	local yMax = 0
	local xMax = 0
	for unitIndex = 1, #rawData.units do
		local y1 = rawData.units[unitIndex].y
		local x1 = rawData.units[unitIndex].x
		if yMin == 0 or y1 < yMin then
			yMin = y1
		end
		if yMax == 0 or y1 > yMax then
			yMax = y1
		end
		if xMin == 0 or x1 < xMin then
			xMin = x1
		end
		if xMax == 0 or x1 > xMax then
			xMax = x1
		end
	end
	local resultY = yMin + ((yMax - yMin) / 2)
	local resultX = xMin + ((xMax - xMin) / 2)

	return x - resultX, y - resultY
end

function spawnGroundCorrected(rawData, y, x, triggerZoneName, triggerAreaIndex)
	local unitSet = {}
	local xTrans, yTrans = calculateTranslation(rawData, x, y)
	local rotationAngle = math.random() * 2 * math.pi
	for unitIndex = 1, #rawData.units do
		table.insert(unitSet, transformUnitProps(rawData.units[unitIndex], xTrans, yTrans, x, y, rotationAngle))
	end
	local spawnedGroup = coalition.addGroup(rawData["country"], Group.Category.GROUND, { name = generateGroundGroupName(triggerZoneName), units = unitSet })
	registerGroundGroup(spawnedGroup, triggerZoneName, triggerAreaIndex)
end

function parseSectionNameAndIndex(zoneName)
	local index = #zoneName
	while index > 0 do
		if zoneName:sub(index, index) == " " then
			return zoneName:sub(1, index - 1), zoneName:sub(index + 1, #zoneName + 1)
		end
		index = index - 1
	end
end

function loadTriggerZones()
	local triggerZones = {}
	for _, v in pairs(env.mission.triggers.zones) do
		if startsWith(v.name, "Spawn ") then
			local sectionName, sectionIndex = parseSectionNameAndIndex(v.name:sub(7))
			if triggerZones[sectionName] == nil then
				triggerZones[sectionName] = {}
			end
			local zoneData = {}
			zoneData["x"] = v["x"]
			zoneData["y"] = v["y"]
			triggerZones[sectionName][sectionIndex] = zoneData
		end
	end
	return triggerZones
end

function processGroundTemplate(groupName, groupId)
	local template = { groupName = groupName, units = {} }
	local groupPropsNeedSetting = true
	for _, unitId in pairs(Group.getUnits(groupId)) do
		if groupPropsNeedSetting then
			groupPropsNeedSetting = false
			template["country"] = Unit.getCountry(unitId)
			template["templateType"] = split(groupName, " ")[2]
		end
		local unit = {}
		unit["type"] = Unit.getTypeName(unitId)
		unit["x"] = Unit.getPoint(unitId)["x"]
		unit["y"] = Unit.getPoint(unitId)["z"]
		unit["heading"] = positionToHeading(Unit.getPosition(unitId)["x"])
		table.insert(template.units, unit)
	end
	return template
end

function loadGroundUnitTemplates()
	local unitTemplates = {}
	for _, groupId in pairs(coalition.getGroups(coalition.side.RED)) do
		local groupName = groupId:getName()
		if groupName:find("Template ") == 1 then
			table.insert(unitTemplates, processGroundTemplate(groupName, groupId))
		end
	end
	return unitTemplates
end

function getGroundTemplateNames()
	local result = {}
	for _, v in pairs(groundUnitTemplates) do
		table.insert(result, v["groupName"])
	end
	return result
end

function getNrZonesInArea(triggerAreaPrefix)
	for k, v in pairs(triggerZones) do
		if startsWith(k, triggerAreaPrefix) then
			return #v
		end
	end
	return 0
end

function getRandomTemplateByPrefix(templatePrefix)
	local availableTemplates = {}
	for _, v in pairs(groundUnitTemplates) do
		local templateName = v["groupName"]
		if startsWith(templateName, templatePrefix) then
			table.insert(availableTemplates, v)
		end
	end
	return availableTemplates[math.random(tableLength(availableTemplates))]
end

function getGroundTemplateByName(templateName)
	for _, v in pairs(groundUnitTemplates) do
		if templateName == v["groupName"] then
			return v
		end
	end
	env.error("No match for "..templateName)
end

function getGroundTemplateByPrefix(templatePrefix)
	if endsWith(templatePrefix, "Random") then
		local substr = templatePrefix:sub(1, #templatePrefix - 6)
		return getRandomTemplateByPrefix(substr)
	else
		return getGroundTemplateByName(templatePrefix)
	end
end

function selectRandomEmptyZone(triggerAreaName)
	if isZoneFull(triggerAreaName) then
		trigger.action.outTextForCoalition(coalition.side.BLUE, "Unable to spawn group in "..triggerAreaName.." because its full.", 15)
		return nil
	else
		local selectedIndex
		while selectedIndex == nil do
			selectedIndex = tostring(math.random(tableLength(triggerZones[triggerAreaName])))
			if isZoneIndexOccupied(triggerAreaName, selectedIndex) then
				selectedIndex = nil
			end
		end
		return triggerZones[triggerAreaName][selectedIndex], selectedIndex
	end
end

function spawnGroundTemplateGroup(templatePrefix, triggerAreaName, triggerAreaSpecificIndex)
	local selectedZone
	if triggerAreaSpecificIndex == nil then
		selectedZone, triggerAreaSpecificIndex = selectRandomEmptyZone(triggerAreaName)
		if selectedZone == nil then
			return
		end
	else
		local selectedIndexString = tostring(triggerAreaSpecificIndex)
		if isZoneIndexOccupied(triggerAreaName, selectedIndexString) then
			trigger.action.outTextForCoalition(coalition.side.BLUE, "Unable to spawn group in "..triggerAreaName.." slot "..selectedIndexString.." because its occupied.", 15)
			return
		end
		selectedZone = triggerZones[triggerAreaName][selectedIndexString]
	end
	local template = getGroundTemplateByPrefix(templatePrefix)
	spawnGroundCorrected(template, selectedZone["y"], selectedZone["x"], triggerAreaName, triggerAreaSpecificIndex)
end

triggerZones = loadTriggerZones()
groundUnitTemplates = loadGroundUnitTemplates()
