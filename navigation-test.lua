-- To modify altitude, set minHeightFt and maxHeightFt as needed

minHeightFt = 24000
maxHeightFt = 26000

feedback = false

-- DO NOT CHANGE ANYTHING BELOW

scoring = {} -- track which planes we are scoring
total = {} -- track total ticks for each
onradial = {} -- track ticks on radial
onaltitude = {} -- track ticks on altitude

conv = 0.3048

oneNmZones = {
	"Zone-1NM-1",
	"Zone-1NM-2",
	"Zone-1NM-3"
}
fiveNmZones = {
	"Zone-5NM-1",
	"Zone-5NM-2",
	"Zone-5NM-3"
}

selectedZones = oneNmZones

function selectZoneSize(vars)
	selectedZones = vars.zones
	trigger.action.outText(vars.message, 10)
end

function isAtAltitude(unit)
	local alt = unit:getPoint().y
	return alt > minHeightFt*conv and alt < maxHeightFt*conv
end

function isInZones(planes, unitid, zones)
	local match = false
	for i = 1, #zones do
		local zone = mist.getGroupPoints(zones[i])
		local units = mist.getUnitsInPolygon(planes, zone)
		for i = 1,#units do
			if(units[i]:getID() == unitid) then return true end
		end
		return false
	end
	return match
end

function getGrade(gradescore)
	local grade = 'F'
	if(gradescore > 0.5)then grade = 'C' end
	if(gradescore > 0.75)then grade = 'B' end
	if(gradescore > 0.9)then grade = 'A' end
	return grade
end

function reportStatSums(unit, seconds)
	local id = unit:getID()
	local tot = total[id]
	local rad = onradial[id]
	local alt = onaltitude[id]
	local radG = getGrade(rad/tot)
	local altG = getGrade(alt/tot)

	trigger.action.outTextForUnit(id, "Here is your final tally:", seconds)
	trigger.action.outTextForUnit(id, "Total measured points: " .. tot, seconds)
	trigger.action.outTextForUnit(id, "Points on correct radial: " .. rad, seconds)
	trigger.action.outTextForUnit(id, "Points at correct altitude: " .. alt, seconds)
	trigger.action.outTextForUnit(id, "Final grade - radial: " .. radG, seconds)
	trigger.action.outTextForUnit(id, "Final grade - altitude: " .. altG, seconds)

	local name = unit:getPlayerName()
	if(name == nil) then name = "AI PILOT" end

	local header = 'Name|Total|OnRadial|OnAltitude|RadialScore|AltitudeScore'
	local points = {name, tot, rad, alt, radG, altG}
	env.info(header)
	env.info(table.concat(points, '|'))
end

function registerNewcomers()
	local planes = mist.makeUnitTable({'[all][plane]'})
	local unitsToRegister = mist.getUnitsInZones(planes, {'Station-1'})
	env.info("Checking newcomers, " .. #unitsToRegister .. " found at ".. timer.getTime() .."...")
	for i=1, #unitsToRegister do
		local unitid = unitsToRegister[i]:getID()
		env.info("Unit " .. unitid .." entered Station-1...")
		if(scoring[unitid] == nil) then
			registerUnit(unitsToRegister[i])
			trigger.action.outTextForUnit(unitid, "Registered! Start flying the track!", 30)
		end
	end
	timer.scheduleFunction(registerNewcomers, {}, timer.getTime() + 1)
end

function registerUnit(unit)
	local unitid = unit:getID()
	scoring[unitid] = unit
	total[unitid] = 0
	onradial[unitid] = 0
	onaltitude[unitid] = 0
	env.info("Unit " .. unitid .." registered...")
end

function registerCompletions()
	local planes = mist.makeUnitTable({'[all][plane]'})
	local unitsToRegister = mist.getUnitsInZones(planes, {'Station-4'})
	for i=1, #unitsToRegister do
		local unitid = unitsToRegister[i]:getID()
		if(scoring[unitid] ~= nil) then
			trigger.action.outTextForUnit(unitid, "Almost done! Now to land...", 30)
			scoring[unitid] = nil
		end
	end
	timer.scheduleFunction(registerCompletions, {}, timer.getTime() + 1)
end

function addToScore()
	local planes = mist.makeUnitTable({'[all][plane]'})
	local onStations = mist.getUnitsInZones(planes, {'Station-1','Station-2','Station-3','Station-4'})
	for i = 1, #scoring do
		local unit = scoring[i]
		local id = unit:getID()
		env.info("Looping addToScore for unit id " .. id .. "...")
		local msg = "unit: " .. id
		local skip = false
		for i = 1, #onStations do
			if(onStations[i]:getID() == unit:getID()) then
				skip = true
				msg = msg .. " skipping"
			end
		end
		if(skip ~= true) then
			total[id] = total[id] + 1
			msg = msg .. ", tracking"
			if(isInZones(planes, id, selectedZones)) then
				onradial[id] = onradial[id] + 1
				msg = msg .. ", on radial"
			end
			if(isAtAltitude(unit)) then
				onaltitude[id] = onaltitude[id] + 1
				msg = msg .. ", at altitude"
			end
		end
		env.info(msg)
		if(feedback == true) then
			trigger.action.outTextForUnit(id, msg, 1)
		end	
	end		
	timer.scheduleFunction(addToScore, {}, timer.getTime() + 1)
end

informStarted = {}
function informStarted:onEvent(event)
	if event.id ~= world.event.S_EVENT_TAKEOFF or event.initiator == nil then return end
	local id = event.initiator:getID()
	trigger.action.outTextForUnit(id, "Welcome! Fly to the first TACAN station to get started.", 10)
	env.info("Logged takeoff of unit id " .. id)
end

reportLanded = {}
function reportLanded:onEvent(event)
	if event.id ~= world.event.S_EVENT_LAND or event.initiator == nil then return end
	reportStatSums(event.initiator, 30)
end

world.addEventHandler(informStarted)
world.addEventHandler(reportLanded)

timer.scheduleFunction(addToScore, {}, timer.getTime() + 5)
timer.scheduleFunction(registerNewcomers, {}, timer.getTime() + 5)
timer.scheduleFunction(registerCompletions, {}, timer.getTime() + 5)

env.setErrorMessageBoxEnabled(true)

local zoneMenu = missionCommands.addSubMenu('Set zone width...')
missionCommands.addCommand('1 NM zone width', zoneMenu, selectZoneSize, {zones = oneNmZones, message = '1 NM zone size set'})
missionCommands.addCommand('5 NM zone width', zoneMenu, selectZoneSize, {zones = fiveNmZones, message = '5 NM zone size set'})

env.info("Nav training script loaded.")
trigger.action.outText("Welcome to the Adverse Weather Navigation training session.", 10)
trigger.action.outText("The NAVAIDs are in the mission briefing. Use the NAVAIDs suitable for your chosen aircraft.", 10)
trigger.action.outText("At the end of the training, you are to land using the provided NAVAIDs.", 10)
trigger.action.outText("Good luck! (You might need it...)", 10)

