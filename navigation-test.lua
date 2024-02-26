-- To modify altitude, set minHeightFt and maxHeightFt as needed

minHeightFt = 24000
maxHeightFt = 26000

feedback = false

-- DO NOT CHANGE ANYTHING BELOW

registered = {} -- track planes registered at start. item: name.
scores = {} -- track the scores on the track, item: [id] = {running = true, total = 0, onradial = 0, onaltitude = 0}

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

selectedTrackZones = oneNmZones

function selectZoneSize(vars)
	selectedTrackZones = vars.zones
	trigger.action.outText(vars.message, 10)
end

function isAtAltitude(unit)
	local alt = unit:getPoint().y
	return alt > minHeightFt*conv and alt < maxHeightFt*conv
end

function isInZones(planes, unitid, zones)
	for z, zoneName in pairs(zones) do
		local unitsInPolygon = mist.getUnitsInPolygon(planes, mist.getGroupPoints(zoneName))
		for u, unitInPolygon in pairs(unitsInPolygon) do
			if(unitInPolygon:getID() == unitid) then return true end
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

function reportScores(id, score, radG, altG, seconds)
	trigger.action.outTextForUnit(id, "Here is your final tally:", seconds)
	trigger.action.outTextForUnit(id, "Total measured points: " .. score.total, seconds)
	trigger.action.outTextForUnit(id, "Points on correct radial: " .. score.onradial, seconds)
	trigger.action.outTextForUnit(id, "Points at correct altitude: " .. score.onaltitude, seconds)
	trigger.action.outTextForUnit(id, "Final grade - radial: " .. radG, seconds)
	trigger.action.outTextForUnit(id, "Final grade - altitude: " .. altG, seconds)
end

function logScores(name, score, radG, altG)		
	env.info('Name|Total|OnRadial|OnAltitude|RadialScore|AltitudeScore')
	env.info(table.concat({name, score.total, score.onradial, score.onaltitude, radG, altG}, '|'))
end

function reportStatSums(unit, seconds)
	local id = unit:getID()
	local score = scores[id]
	local radG = getGrade(score.onradial/score.total)
	local altG = getGrade(score.onaltitude/score.total)
	reportScores(id, score, radG, altG, seconds)
	local name = unit:getPlayerName()
	if(name == nil) then name = "AI PILOT" end
	logScores(name, score, radG, altG)
end

function registerNewcomers()
	local planes = mist.makeUnitTable({'[all][plane]'})
	local startingUnits = mist.getUnitsInZones(planes, {'Station-1'})
	for u, startingUnit in pairs(startingUnits) do
		local unitid = startingUnit:getID()
		if(scores[unitid] == nil) then
			table.insert(registered, startingUnit:getName())
			scores[unitid] = {running = true, total = 0, onradial = 0, onaltitude = 0}
			env.info("Unit " .. unitid .." start registered...")
			trigger.action.outTextForUnit(unitid, "Registered! Start flying the track!", 10)
		end
	end
	timer.scheduleFunction(registerNewcomers, {}, timer.getTime() + 1)
end

function registerCompletions()
	local completingUnits = mist.getUnitsInZones(mist.makeUnitTable({'[all][plane]'}), {'Station-4'})
	for u, completingUnit in pairs(completingUnits) do
		local unitid = completingUnit:getID()
		if(scores[unitid].running == true) then
			scores[unitid].running = false
			env.info("Unit " .. unitid .." completion registered...")
			trigger.action.outTextForUnit(unitid, "Track complete! Land as stated in the briefing to get the scores.", 10)
		end
	end
	timer.scheduleFunction(registerCompletions, {}, timer.getTime() + 1)
end

function runTick()
	local planes = mist.makeUnitTable({'[all][plane]'})
	local inStations = mist.getUnitsInZones(planes, {'Station-1','Station-2','Station-3','Station-4'})
	env.info("Checking scorings, " .. #scores .. " tracked at " .. timer.getTime() .. "...")
	for r, name in pairs(registered) do
		local unit = Unit.getByName(name)
		local unitid = unit:getID()
		local logmsg = "unit: " .. unitid
		local run = scores[unitid].running
		for e, stationedUnit in pairs(inStations) do
			if(stationedUnit:getID() == unitid) then
				run = false
				logmsg = logmsg .. ", skipping"
			end
		end
		if(run == true) then				
			scores[unitid].total = scores[unitid].total + 1
			logmsg = logmsg .. ", tracking"
			if(isInZones(planes, unitid, selectedTrackZones)) then
				scores[unitid].onradial = scores[unitid].onradial + 1
				logmsg = logmsg .. ", on radial"
			end
			if(isAtAltitude(unit)) then
				scores[unitid].onaltitude = scores[unitid].onaltitude + 1
				logmsg = logmsg .. ", at altitude"
			end
		end
		env.info(unitid .. "Score:" .. table.concat(scores[unitid], '|'))
		if(feedback == true and scores[unitid].running == true) then
			trigger.action.outTextForUnit(unitid, logmsg, 1)
			logmsg = nil
		end	
	end		
	timer.scheduleFunction(runTick, {}, timer.getTime() + 1)
end

informStarted = {}
function informStarted:onEvent(event)
	if event.id ~= world.event.S_EVENT_TAKEOFF or event.initiator == nil then return end
	local id = event.initiator:getID()
	trigger.action.outTextForUnit(id, "Welcome! Fly to the first NAVAID station to get started.", 10)
	env.info("Logged takeoff of unit id " .. id)
end

reportLanded = {}
function reportLanded:onEvent(event)
	if event.id ~= world.event.S_EVENT_LAND or event.initiator == nil then return end
	env.info("Logged landing of unit id " .. event.initiator:getID())
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

