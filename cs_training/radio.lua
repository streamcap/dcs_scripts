local altitudeOffsetList = { { text = "5000ft lower", value = -5000 },
							 { text = "co-alt", value = 0 },
							 { text = "5000ft higher", value = 5000 },
							 { text = "10000ft higher", value = 10000 } }

function getGroundCategoryAndType(templateName)
	local splitString = {}
	for i in string.gmatch(templateName, "%S+") do
		table.insert(splitString, i)
	end
	return splitString[2], splitString[3], splitString[4]
end

function getAirCategoryAndType(templateName)
	local splitString = {}
	for i in string.gmatch(templateName, "%S+") do
		table.insert(splitString, i)
	end
	return splitString[2], splitString[3], splitString[4], splitString[5], splitString[6]
end

function addRadioEntrySectionSubgroup(groupId, name, parentMenu, templateName)
	local spawnInAreaSubgroup = missionCommands.addSubMenuForGroup(groupId["id_"], "Spawn in "..name, parentMenu)
	missionCommands.addCommandForGroup(groupId["id_"], "Spawn randomly in "..name, spawnInAreaSubgroup, spawnGroundTemplateGroup, templateName, name)
	local spawnSpecificInAreaSubgroup = missionCommands.addSubMenuForGroup(groupId["id_"], "Spawn specifically at ", spawnInAreaSubgroup)
	for index = 1, 10 do
		missionCommands.addCommandForGroup(groupId["id_"], "Spawn at "..index.." in "..name, spawnSpecificInAreaSubgroup, spawnGroundTemplateGroup, templateName, name, index)
	end
end

function addRadioEntryWithSort(groupId, parentMenu, orderedZoneSet, templateName, order)
	for k, v in sortPairs(orderedZoneSet, order) do
		if type(v) == "table" then
			local subMenu = missionCommands.addSubMenuForGroup(groupId["id_"], k, parentMenu)
			recursiveAddRadioEntry(groupId, subMenu, v, templateName)
		else
			addRadioEntrySectionSubgroup(groupId, v, parentMenu, templateName)
		end
	end
end

function recursiveAddRadioEntry(groupId, parentMenu, orderedZoneSet, templateName)
	if orderedZoneSet[1] ~= nil then
		addRadioEntryWithSort(groupId, parentMenu, orderedZoneSet, templateName, function(t,a,b) return t[b] > t[a] end)
	else
		addRadioEntryWithSort(groupId, parentMenu, orderedZoneSet, templateName)
	end
end

function splitLargeSet(zonePrefix, zonesTable)
	local resultTable = {}
	for _, topLayerV in pairs(zonesTable) do
		local zoneGroupName = zonePrefix..topLayerV:sub(1, 1).."'s"
		if resultTable[zoneGroupName] == nil then
			resultTable[zoneGroupName] = {}
		end
		table.insert(resultTable[zoneGroupName], zonePrefix..topLayerV)
	end
	return resultTable
end

-- Creates a new set with 2 entries, one numeric, and one alphabetical. Then fills those with the correct content
function splitRadioSetToNumericAndAlphabetic()
	local resultSet = {}
	resultSet["A-Z"] = {}
	resultSet["0-9"] = {}
	for k, _ in pairs(triggerZones) do
		if k:sub(1,1):match("%d") then
			table.insert(resultSet["0-9"], k)
		else
			table.insert(resultSet["A-Z"], k)
		end
	end
	return resultSet
end

-- Creates subsets for each multi word zone to divide further
function divideMultiWordRadioEntries(radioSet)
	local azSubset = {}
	for _, v in pairs(radioSet) do
		local splitResult = split(v, " ")
		if #splitResult > 1 then
			if azSubset[splitResult[1]] == nil then
				azSubset[splitResult[1]] = {}
			end
			table.insert(azSubset[splitResult[1]], splitResult[2])
		else
			table.insert(azSubset, v)
		end
	end
	return azSubset
end

-- Corrects the singular radio entries that are split by the divideMultiWordRadioEntries function
function fixAzSubset(radioSet)
	local fixedAzSubset = {}
	local uniqueNameSet = {}
	for k, v in pairs(radioSet) do
		if type(k) == "number" then
			table.insert(uniqueNameSet, v)
		else
			if #v == 1 then
				table.insert(uniqueNameSet, k.." "..v[1])
			else
				local newCorrectSubset = {}
				for _, innerV in pairs(v) do
					table.insert(newCorrectSubset, k.." "..innerV)
				end
				fixedAzSubset[k.." Area"] = newCorrectSubset
			end
		end
	end
	fixedAzSubset["Unique name Area"] = uniqueNameSet
	return fixedAzSubset
end

function createNumberedSubsets(radioSet)
	local numberSubset = {}
	for _, v in pairs(radioSet) do
		local firstNumber = v:sub(1, 1)
		if numberSubset[firstNumber] == nil then
			numberSubset[firstNumber] = {}
		end
		table.insert(numberSubset[firstNumber], v:sub(2, #v))
	end
	return numberSubset
end

function fixNumberedSubsets(radioSet)
	local fixedNumberSubset = {}
	for masterSetK, masterSetV in pairs(radioSet) do
		if #masterSetV <= 11 then
			local matcherPrefix = ""
			local perfectMatch = true
			local hasMatch = true
			while perfectMatch do
				hasMatch = true
				local firstRound = true
				for _, subSetV in pairs(masterSetV) do
					if firstRound then
						matcherPrefix = matcherPrefix..subSetV:sub(#matcherPrefix + 1, #matcherPrefix + 1)
						firstRound = false
					else
						local subSubSetV = subSetV:sub(1, #matcherPrefix)
						if matcherPrefix ~= subSubSetV then
							perfectMatch = false
							if #matcherPrefix > 1 then
								matcherPrefix = matcherPrefix:sub(1, #matcherPrefix - 1)
							else
								hasMatch = false
							end
							break
						end
					end
				end
			end
			if hasMatch then
				local newSubSet = {}
				for _, subSetV in pairs(masterSetV) do
					table.insert(newSubSet, masterSetK..matcherPrefix..subSetV:sub(#matcherPrefix + 1, #subSetV))
				end
				fixedNumberSubset[masterSetK..matcherPrefix.."0's"] = newSubSet
			else
				local newSubSet = {}
				for _, subSetV in pairs(masterSetV) do
					table.insert(newSubSet, masterSetK..subSetV:sub(1, #subSetV))
				end
				fixedNumberSubset[masterSetK.."0's"] = newSubSet
			end
		else
			fixedNumberSubset[masterSetK.."0's"] = splitLargeSet(masterSetK, masterSetV)
		end
	end
	return fixedNumberSubset
end

function createNttrRadioReadyZoneSet()
	local resultSet = splitRadioSetToNumericAndAlphabetic(triggerZones)
	local azSubset = divideMultiWordRadioEntries(resultSet["A-Z"])
	resultSet["A-Z"] = fixAzSubset(azSubset)
	local numberSubset = createNumberedSubsets(resultSet["0-9"])
	resultSet["0-9"] = fixNumberedSubsets(numberSubset)
	return resultSet
end

function sortZoneNames(content)
	local contentkeys = {}
	for k in pairs(content) do 
		table.insert(contentkeys, k) 
	end
	table.sort(contentkeys)
	return contentkeys
end

function createCaucasusRadioReadyZoneSet()
	local sortedTriggerNames = sortZoneNames(triggerZones)
	local resultSet = {}
	for _, v in pairs(sortedTriggerNames) do
		local splitString = {}
		for i in string.gmatch(v, "%S+") do
			table.insert(splitString, i)
		end
		local rangeName = "Range " .. splitString[1]
		if not resultSet[rangeName] then
			resultSet[rangeName] = {}
		end
		table.insert(resultSet[rangeName], v)
	end
	for _, v in pairs(resultSet) do
		table.sort(v)
	end
	return resultSet
end

function createMarianasRadioReadyZoneSet()
	local sortedTriggerNames = sortZoneNames(triggerZones)
	local resultSet = {}
	local aToJList = unpackTable(sortedTriggerNames, 1, 10)
	local kToTList = unpackTable(sortedTriggerNames, 11, 20)
	local uToZList = unpackTable(sortedTriggerNames, 21)
	table.sort(aToJList)
	table.sort(kToTList)
	table.sort(uToZList)
	resultSet["A-J"] = aToJList
	resultSet["K-T"] = kToTList
	resultSet["U-Z"] = uToZList
	return resultSet
end

function createRadioReadyZoneSet()
	local theatre = getTheatre()
	if theatre == "Nevada" then
		return createNttrRadioReadyZoneSet()
	end
	if theatre == "MarianaIslands" then
		return createMarianasRadioReadyZoneSet()
	end
	--if theatre == "Caucasus" then
	return createCaucasusRadioReadyZoneSet()
	--end
	--return {}
end

function addGroupRadioEntryForGroundGroup(groupId, groupData, listSpawnedSubMenu)
	local groupSubMenu = missionCommands.addSubMenuForGroup(groupId["id_"], groupData["name"], listSpawnedSubMenu)
	
	local navAssistSubMenu = missionCommands.addSubMenuForGroup(groupId["id_"], "Navigation assistance", groupSubMenu)
	missionCommands.addCommandForGroup(groupId["id_"], "Request vector to target", navAssistSubMenu, listVectorToTarget, groupData["group"], groupId)
	missionCommands.addCommandForGroup(groupId["id_"], "Request target Deg/Decimal Lon Lat", navAssistSubMenu, listTargetDegDecimalLonLat, groupData["group"], groupId)
	missionCommands.addCommandForGroup(groupId["id_"], "Request target Deg/Min/Sec Lon Lat", navAssistSubMenu, listTargetDegMinSecLonLat, groupData["group"], groupId)
	missionCommands.addCommandForGroup(groupId["id_"], "Request target grid", navAssistSubMenu, listTargetGrid, groupData["group"], groupId)
	
	missionCommands.addCommandForGroup(groupId["id_"], "Mark with smoke", groupSubMenu, spawnSmokeOnGroupId, groupData["group"], groupId)
	missionCommands.addCommandForGroup(groupId["id_"], "Delete group", groupSubMenu, deleteGroundGroup, groupData["group"])
end

function addGroupRadioEntryForAirGroup(groupId, enemyGroupName, enemyGroupId, listSpawnedSubMenu)
	local groupSubMenu = missionCommands.addSubMenuForGroup(groupId["id_"], enemyGroupName, listSpawnedSubMenu)

	missionCommands.addCommandForGroup(groupId["id_"], "Delete group", groupSubMenu, deleteAirGroup, enemyGroupId)
end

function createSpawnedGroundSubMenu(groupId, parentMenu)
	local listSpawnedGroundGroupsSubMenuPath = missionCommands.addSubMenuForGroup(groupId["id_"], "List spawned ground groups", parentMenu)
	if activeGroups then
		for _, groupData in pairs(activeGroups) do
			addGroupRadioEntryForGroundGroup(groupId, groupData, listSpawnedGroundGroupsSubMenuPath)
		end
	end
	return listSpawnedGroundGroupsSubMenuPath
end

function createSpawnedAirSubMenu(groupId, parentMenu)
	local listSpawnedAirGroupsSubMenuPath = missionCommands.addSubMenuForGroup(groupId["id_"], "List spawned air groups", parentMenu)
	if spawnedAirGroupIndexes then
		for key, v in pairs(spawnedAirGroupIndexes) do
			addGroupRadioEntryForAirGroup(groupId, key, v.id, listSpawnedAirGroupsSubMenuPath)
		end
	end
	return listSpawnedAirGroupsSubMenuPath
end

function createSpawnFacSubMenu(groupId)
	local spawnFacSubMenuPath = missionCommands.addSubMenuForGroup(groupId["id_"], "Spawn FAC mission")
	for k, _ in pairs(facZones) do
		local spawnAreaMenu = missionCommands.addSubMenuForGroup(groupId["id_"], "FAC in "..k, spawnFacSubMenuPath)
		missionCommands.addCommandForGroup(groupId["id_"], "Easy FAC in " .. k, spawnAreaMenu, spawnFacMission, groupId["id_"], k, "Easy")
		missionCommands.addCommandForGroup(groupId["id_"], "Medium FAC in " .. k, spawnAreaMenu, spawnFacMission, groupId["id_"], k, "Medium")
		missionCommands.addCommandForGroup(groupId["id_"], "Hard FAC in " .. k, spawnAreaMenu, spawnFacMission, groupId["id_"], k, "Hard")
	end
	return spawnFacSubMenuPath
end

function createSpawnGroundEnemySubMenu(groupId)
	local spawnEnemySubMenuPath = missionCommands.addSubMenuForGroup(groupId["id_"], "Spawn ground enemy")
	for catKey, catValue in pairs(groundRadioMenus) do
		local spawnCatSubMenu = missionCommands.addSubMenuForGroup(groupId["id_"], "Spawn "..catKey, spawnEnemySubMenuPath)
		for typeKey, typeValue in pairs(catValue) do
			local spawnTypeSubMenu = missionCommands.addSubMenuForGroup(groupId["id_"], "Spawn "..typeKey, spawnCatSubMenu)
			local spawnRandomVariationSubMenu = missionCommands.addSubMenuForGroup(groupId["id_"], "Spawn "..typeKey.." random variation", spawnTypeSubMenu)
			for _, varValue in pairs(typeValue) do
				local spawnVariationSubMenu = missionCommands.addSubMenuForGroup(groupId["id_"], "Spawn "..typeKey.." variation "..varValue, spawnTypeSubMenu)
				recursiveAddRadioEntry(groupId, spawnVariationSubMenu, orderedZoneSet, "Template "..catKey.." "..typeKey.." "..varValue)
			end
			recursiveAddRadioEntry(groupId, spawnRandomVariationSubMenu, orderedZoneSet, "Template "..catKey.." "..typeKey.." Random")
		end
	end
	return spawnEnemySubMenuPath
end

function createSpawnAirEnemySubMenu(groupId)
	local spawnEnemySubMenuPath = missionCommands.addSubMenuForGroup(groupId["id_"], "Spawn air enemy")
	for typeKey, typeValue in pairs(airRadioMenus) do
		local spawnTypeSubMenu = missionCommands.addSubMenuForGroup(groupId["id_"], "Spawn ".. typeKey, spawnEnemySubMenuPath)
		for armamentKey, armamentValue in pairs(typeValue) do
			local spawnArmamentSubMenu = missionCommands.addSubMenuForGroup(groupId["id_"], "Spawn with loadout name "..armamentKey, spawnTypeSubMenu)
			for rangeKey, rangeValue in pairs(armamentValue) do
				local spawnRangeSubMenu = missionCommands.addSubMenuForGroup(groupId["id_"], "Spawn at range "..rangeKey, spawnArmamentSubMenu)
				for _, altitudeInfo in ipairs(altitudeOffsetList) do
					local spawnAltitudeSubMenu = missionCommands.addSubMenuForGroup(groupId["id_"], "Spawn "..altitudeInfo.text, spawnRangeSubMenu)
					for countKey, countValue in sortPairs(rangeValue) do
						local spawnSkillSubMenu = missionCommands.addSubMenuForGroup(groupId["id_"], "Spawn flight of "..countKey, spawnAltitudeSubMenu)
						for _, skillValue in pairs(countValue) do
							missionCommands.addCommandForGroup(groupId["id_"], "Spawn with skill "..skillValue, spawnSkillSubMenu, spawnAirTemplateGroup, groupId, "AirTemplate ".. typeKey.." "..armamentKey .." "..rangeKey.." "..countKey.." "..skillValue, altitudeInfo.value)
						end
					end
				end
			end
		end
	end
	return spawnEnemySubMenuPath
end

function createSpawnedFacSubMenu(groupId, parentMenu)
	local spawnedFacMenu
	for k, _ in pairs(spawnedFacGroups) do
		if not spawnedFacMenu then
			spawnedFacMenu = missionCommands.addSubMenuForGroup(groupId["id_"], "Active FAC area's", parentMenu)
		end
		local spawnedFacAreaMenu = missionCommands.addSubMenuForGroup(groupId["id_"], k, spawnedFacMenu)
		missionCommands.addCommandForGroup(groupId["id_"], "Clear FAC area "..k, spawnedFacAreaMenu, clearFacArea, k)
	end
	return spawnedFacMenu
end

function createSpawnedUnitsMenu(groupId, spawnedUnitsMenu)
	local radioMenusForGroup = {}
	table.insert(radioMenusForGroup, createSpawnedGroundSubMenu(groupId, spawnedUnitsMenu))
	table.insert(radioMenusForGroup, createSpawnedAirSubMenu(groupId, spawnedUnitsMenu))
	table.insert(radioMenusForGroup, createSpawnedFacSubMenu(groupId, spawnedUnitsMenu))
	createdRadioMenusForGroup[groupId["id_"]] = {}
	createdRadioMenusForGroup[groupId["id_"]].deletable = radioMenusForGroup
	createdRadioMenusForGroup[groupId["id_"]].spawnedUnitsMenu = spawnedUnitsMenu
end

function rebuildRadioMenusForGroup(groupId)
	for _, v in pairs(createdRadioMenusForGroup[groupId["id_"]].deletable) do
		missionCommands.removeItemForGroup(groupId["id_"], v)
	end
	createSpawnedUnitsMenu(groupId, createdRadioMenusForGroup[groupId["id_"]].spawnedUnitsMenu)
end

function rebuildRadioMenusForAllGroups()
	for _, groupId in pairs(coalition.getGroups(coalition.side.BLUE)) do
		for _, unitId in ipairs(Group.getUnits(groupId)) do
			if unitId:getPlayerName() and unitId:getPlayerName() ~= "" then
				rebuildRadioMenusForGroup(groupId)
				break
			end
		end
	end
end

function birthEventHandleFunction(occurredEvent)
	if (occurredEvent.id == world.event.S_EVENT_BIRTH and occurredEvent.initiator and occurredEvent.initiator.getGroup) then
		local groupId = occurredEvent.initiator:getGroup()
		if groupId then
			for _, u in ipairs(groupId:getUnits()) do
				if u:getPlayerName() and u:getPlayerName() ~= "" then
					if createdRadioMenusForGroup[groupId["id_"]] then
						missionCommands.removeItemForGroup(groupId["id_"], nil)
					end
					createSpawnGroundEnemySubMenu(groupId)
					createSpawnAirEnemySubMenu(groupId)
					createSpawnedUnitsMenu(groupId, missionCommands.addSubMenuForGroup(groupId["id_"], "Spawned units menu"))
					if facZones and next(facZones) ~= nil then
						createSpawnFacSubMenu(groupId)
					end
					break
				end
			end
		end
	end
end

--------------------------
--						--
--	End of functions	--
--						--
--------------------------

orderedZoneSet = createRadioReadyZoneSet()
availableGroundTemplates = getGroundTemplateNames()
availableAirTemplates = getAirTemplateNames()
createdRadioMenusForGroup = {}

groundRadioMenus = {}
airRadioMenus = {}
for _, templateName in pairs(availableGroundTemplates) do
	local category, type, variation = getGroundCategoryAndType(templateName)
	if groundRadioMenus[category] == nil then
		groundRadioMenus[category] = {}
	end
	if groundRadioMenus[category][type] == nil then
		groundRadioMenus[category][type] = {}
	end
	table.insert(groundRadioMenus[category][type], variation)
end

for _, templateName in pairs(availableAirTemplates) do
	local type, armament, range, count, skill = getAirCategoryAndType(templateName)
	if airRadioMenus[type] == nil then
		airRadioMenus[type] = {}
	end
	if airRadioMenus[type][armament] == nil then
		airRadioMenus[type][armament] = {}
	end
	if airRadioMenus[type][armament][range] == nil then
		airRadioMenus[type][armament][range] = {}
	end
	if airRadioMenus[type][armament][range][count] == nil then
		airRadioMenus[type][armament][range][count] = {}
	end
	table.insert(airRadioMenus[type][armament][range][count], skill)
end

local groupBirthEventHandler = {}
groupBirthEventHandler.f = birthEventHandleFunction
function groupBirthEventHandler:onEvent(event)
	self.f(event)
end
world.addEventHandler(groupBirthEventHandler)
