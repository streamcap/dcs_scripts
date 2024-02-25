-- To modify altitude, set minHeightFt and maxHeightFt as needed

minHeightFt = 24000
maxHeightFt = 26000

feedback = false

-- DO NOT CHANGE ANYTHING BELOW

registered = {} -- track planes registered at start. Takes name.
scoring = {} -- track which planes we are scoring, takes: id = {running = true, total = 0, onradial = 0, onaltitude = 0}

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
	for z = 1, #zones do
		local zname = zones[z]
		local zone = mist.getGroupPoints(zname)
		local units = mist.getUnitsInPolygon(planes, zone)
		for u = 1,#units do
			local unit = units[u]
			if(unit:getID() == unitid) then return true end
		end
	end
	return false
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
	local score = scoring[id]
	local radG = getGrade(score.onradial/score.total)
	local altG = getGrade(score.onaltitude/score.total)

	trigger.action.outTextForUnit(id, "Here is your final tally:", seconds)
	trigger.action.outTextForUnit(id, "Total measured points: " .. score.total, seconds)
	trigger.action.outTextForUnit(id, "Points on correct radial: " .. score.onradial, seconds)
	trigger.action.outTextForUnit(id, "Points at correct altitude: " .. score.onaltitude, seconds)
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
			registerUnit(unitsToRegister[i], unitid)
			trigger.action.outTextForUnit(unitid, "Registered! Start flying the track!", 10)
		end
	end
	timer.scheduleFunction(registerNewcomers, {}, timer.getTime() + 1)
end

function registerUnit(unit, id)
	table.insert(registered, unit:getName())
	scoring[id] = {running = true, total = 0, onradial = 0, onaltitude = 0}
	env.info("Unit " .. id .." registered...")
end

function registerCompletions()
	local planes = mist.makeUnitTable({'[all][plane]'})
	local unitsToRegister = mist.getUnitsInZones(planes, {'Station-4'})
	env.info("Checking completions, " .. #unitsToRegister .. " found at ".. timer.getTime() .."...")
	for u=1, #unitsToRegister do
		local unitid = unitsToRegister[u]:getID()
		if(scoring[unitid].running == true) then
			scoring[unitid].running = false
			trigger.action.outTextForUnit(unitid, "Track complete! Land as stated in the briefing to get the scores.", 10)
		end
	end
	timer.scheduleFunction(registerCompletions, {}, timer.getTime() + 1)
end

function runTick()
	local planes = mist.makeUnitTable({'[all][plane]'})
	local onStations = mist.getUnitsInZones(planes, {'Station-1','Station-2','Station-3','Station-4'})
	env.info("Checking scorings, " .. #scoring .. " tracked at " .. timer.getTime() .. "...")
	for r = 1, #registered do
		local name = registered[r]
		local unit = Unit.getByName(name)
		local id = unit:getID()
		env.info("Looping runTick for unit " .. name .. "...")
		local msg = "unit: " .. id
		local score = scoring[id]
		local run = score.running
		for s = 1, #onStations do
			if(onStations[s]:getID() == id) then
				run = false
				msg = msg .. ", skipping"
			end
		end
		if(run == true) then				
			score.total = score.total + 1
			msg = msg .. ", tracking"
			if(isInZones(planes, id, selectedZones)) then
				score.onradial = score.onradial + 1
				msg = msg .. ", on radial"
			end
			if(isAtAltitude(unit)) then
				score.onaltitude = score.onaltitude + 1
				msg = msg .. ", at altitude"
			end
		end
		env.info(msg)
		if(feedback == true) then
			trigger.action.outTextForUnit(id, msg, 1)
			msg = nil
		end	
	end		
	timer.scheduleFunction(runTick, {}, timer.getTime() + 1)
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

timer.scheduleFunction(runTick, {}, timer.getTime() + 5)
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

