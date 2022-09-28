function resetAirGroupTask(controller)
	Controller.popTask(controller)
end

function createTurnoverPoint(point)
	return { alt = 10000, alt_type = "BARO", type = AI.Task.WaypointType.TURNING_POINT, action = AI.Task.TurnMethod.FLY_OVER_POINT,speed = 170.0, x = point.x, y = point.z }
end

function createAirInitialTasks()
	return {
		[1] =
		{
			["enabled"] = true,
			["auto"] = true,
			["id"] = "WrappedAction",
			["number"] = 1,
			["params"] =
			{
				["action"] =
				{
					["id"] = "Option",
					["params"] =
					{
						["value"] = true,
						["name"] = 17,
					}
				}
			}
		},
		[2] =
		{
			["enabled"] = true,
			["auto"] = true,
			["id"] = "WrappedAction",
			["number"] = 2,
			["params"] =
			{
				["action"] =
				{
					["id"] = "Option",
					["params"] =
					{
						["value"] = 4,
						["name"] = 18,
					},
				},
			},
		},
		[3] =
		{
			["enabled"] = true,
			["auto"] = true,
			["id"] = "WrappedAction",
			["number"] = 3,
			["params"] =
			{
				["action"] =
				{
					["id"] = "Option",
					["params"] =
					{
						["value"] = true,
						["name"] = 19,
					}
				}
			}
		},
		[4] =
		{
			["enabled"] = true,
			["auto"] = true,
			["id"] = "WrappedAction",
			["number"] = 4,
			["params"] =
			{
				["action"] = {
					["id"] = "Option",
					["params"] = {
						["targetTypes"] = {
						},
						["name"] = 21,
						["value"] = "none;",
						["noTargetTypes"] = {
							[1] = "Fighters",
							[2] = "Multirole fighters",
							[3] = "Bombers",
							[4] = "Helicopters",
							[5] = "Infantry",
							[6] = "Fortifications",
							[7] = "Tanks",
							[8] = "IFV",
							[9] = "APC",
							[10] = "Artillery",
							[11] = "Unarmed vehicles",
							[12] = "AAA",
							[13] = "SR SAM",
							[14] = "MR SAM",
							[15] = "LR SAM",
							[16] = "Aircraft Carriers",
							[17] = "Cruisers",
							[18] = "Destroyers",
							[19] = "Frigates",
							[20] = "Corvettes",
							[21] = "Light armed ships",
							[22] = "Unarmed ships",
							[23] = "Submarines",
							[24] = "Cruise missiles",
							[25] = "Antiship Missiles",
							[26] = "AA Missiles",
							[27] = "AG Missiles",
							[28] = "SA Missiles",
						}
					}
				}
			}
		},
		[5] =
		{
			["enabled"] = true,
			["auto"] = false,
			["id"] = "WrappedAction",
			["number"] = 5,
			["params"] =
			{
				["action"] =
				{
					["id"] = "Option",
					["params"] =
					{
						["value"] = 2,
						["name"] = 0,
					}
				}
			}
		}
	}
end

function createAttackGroupTask(groupId)
	return {
		[1] =
		{
			["enabled"] = true,
			["auto"] = false,
			["id"] = "AttackGroup",
			["number"] = 1,
			["params"] =
			{
				["altitudeEnabled"] = false,
				["groupId"] = groupId.id_,
				["attackQtyLimit"] = false,
				["attackQty"] = 1,
				["expend"] = "Auto",
				["altitude"] = 2000,
				["directionEnabled"] = false,
				["groupAttack"] = true,
				["weaponType"] = 1069547520,
				["direction"] = 0
			}
		}
	}
end

function createAirCorrectedRoute(targetGroup, targetPosition, heading)
	local point1 = createTurnoverPoint(targetPosition)
	point1.task = { id = "ComboTask", params = { tasks = createAirInitialTasks() } }
	local point2 = createTurnoverPoint(translatePointForDistanceAndHeading(targetPosition, nmToMeters(1), heading))
	point2.task = { id = "ComboTask", params = { tasks = createAttackGroupTask(targetGroup) } }
	local point3 = createTurnoverPoint(translatePointForDistanceAndHeading(targetPosition, nmToMeters(-100), heading))
	local route = { points = { point1, point2, point3 } }
	return route
end

function translatePointForDistanceAndHeading(point, distance, heading)
	local translation = {}
	if heading < math.pi / 2 then
		translation.z = math.cos(heading) * distance * -1
		translation.x = math.sin(heading) * distance
	elseif heading < math.pi then
		heading = heading - (math.pi / 2)
		translation.z = math.sin(heading) * distance
		translation.x = math.cos(heading) * distance
	elseif heading < math.pi * 1.5 then
		heading = heading - math.pi
		translation.z = math.cos(heading) * distance
		translation.x = math.sin(heading) * distance * -1
	else
		heading = heading - (math.pi * 1.5)
		translation.z = math.sin(heading) * distance * -1
		translation.x = math.cos(heading) * distance * -1
	end
	return { y = 10000, x = point.x + translation.x, z = point.z + translation.z }
end

function getDistanceByGroupName(groupName)
	local splitString = {}
	for i in string.gmatch(groupName, "%S+") do
		table.insert(splitString, i)
	end
	return splitString[4]:sub(1, #splitString[4] - 2)
end

function correctAltitude(altitude, altitudeOffset)
	return altitude + (altitudeOffset * 0.3048)
end

function isSpawnLocationUnsafe(point)
	local elevation = land.getHeight({x = point.x, y = point.z})
	env.info("Point at "..point.y.." where elevation is "..elevation)
	return point.y - elevation < 500
end

function spawnAirCorrected(rawData, callerGroupId, altitudeOffset)
	local targetPosition = Unit.getPosition(Group.getUnits(callerGroupId)[1])
	local targetHeading = positionToHeading(targetPosition.z)
	local spawnPoint = translatePointForDistanceAndHeading(targetPosition.p, nmToMeters(getDistanceByGroupName(rawData.groupName)), targetHeading)
	spawnPoint.y = correctAltitude(Unit.getPosition(Group.getUnits(callerGroupId)[1]).p.y, altitudeOffset)
	env.info("Checking safe spawn")
	if isSpawnLocationUnsafe(spawnPoint) then
		env.info("Spawn unsafe")
		trigger.action.outTextForGroup(callerGroupId["id_"], "Air spawn canceled. Group would be lower than 1500ft AGL.", 10)
		env.info("Returning")
		return
	end
	local heading = targetHeading + math.pi
	if heading > math.pi * 2 then
		heading = heading - (math.pi * 2)
	end
	local route = createAirCorrectedRoute(callerGroupId, spawnPoint, heading)
	local unitSet = {}
	local airGroupName = generateAirGroupName();
	for unitIndex = 1, rawData.number do
		local unit = {}
		unit.x = spawnPoint.x
		unit.y = spawnPoint.z
		unit.alt = spawnPoint.y - (25 * (unitIndex - 1))
		unit.type = rawData.units[1].type
		unit.payload = rawData.units[1].payload
		unit.speed = 250
		unit.name = airGroupName .. "-" .. unitIndex
		table.insert(unitSet, unit)
	end
	local spawnedGroup = coalition.addGroup(rawData["country"], Group.Category.AIRPLANE,
			{
				name = airGroupName,
				units = unitSet,
				route = route,
				task = "Intercept"
			})
	registerAirGroup(airGroupName, spawnedGroup, callerGroupId)
end

function processAirTemplate(groupName, groupData, countryId, number, skill)
	local template = { groupName = groupName, units = {}, country = countryId, number = number }
	template.route = groupData.route
	template.task = groupData.task
	for _, rawUnitData in pairs(groupData.units) do
		local unit = {}
		unit.alt = rawUnitData.alt
		unit.hardpoint_racks = rawUnitData.hardpoint_racks
		unit.y = rawUnitData.y
		unit.x = rawUnitData.x
		unit.payload = rawUnitData.payload
		unit.type = rawUnitData.type
		unit.speed = rawUnitData.speed
		unit.skill = skill
		table.insert(template.units, unit)
	end
	return template
end

function loadAirUnitTemplates()
	local airUnitTemplates = {}
	for _, country in pairs(env.mission.coalition.red.country) do
		if country.plane ~= nil and country.plane.group ~= nil then
			for _, airGroup in pairs(country.plane.group) do
				local groupName = airGroup["name"]
				if groupName:find("AirTemplate ") == 1 then
					for number = 1, 4 do
						for _, skill in pairs({"Rookie", "Trained", "Veteran", "Ace"}) do
							table.insert(airUnitTemplates, processAirTemplate(groupName.." "..number.." "..skill, airGroup, country.id, number, skill))
						end
					end
				end
			end
		end
	end
	return airUnitTemplates
end

function getAirTemplateNames()
	local result = {}
	for _, v in pairs(airUnitTemplates) do
		table.insert(result, v["groupName"])
	end
	return result
end

function getAirTemplateByName(templateName)
	for _, v in pairs(airUnitTemplates) do
		if templateName == v["groupName"] then
			return v
		end
	end
	env.error("No match for "..templateName)
end

function spawnAirTemplateGroup(groupId, templateName, altitudeOffset)
	spawnAirCorrected(getAirTemplateByName(templateName), groupId, altitudeOffset)
end

airUnitTemplates = loadAirUnitTemplates()
