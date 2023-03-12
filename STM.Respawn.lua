env.info('Loading Support Respawn script...')


--[[
STM Script for respawning support aircraft such as AWACS, tankers etc in event of RTB or shootdown.

HOW TO USE:
1. Create the support flight and give it a route, maybe even an orbit.
1. In a script trigger, call STM.Respawn.addEventHandlers().
2. In the same script trigger, call STM.Respawn.registerGroup() giving the name of the support flight group as a parameter.
2a. If you have several groups, for instance one of each type of tankers and an AWACS, put all the names in a LUA table and call the function STM.Respawn.registerGroups() passing that table as a parameter.
3. Enjoy!

LIMITATIONS:
The groups in question are presumed to be single-unit groups only. If a multi-unit group is registered, the group will respawn as soon as the first registered unit in that group lands.
]]--
do
	RespawnGroups = {}
	AirborneRespawnGroups = {}
	isRespawnActive = false
	recheckSchedule = -1

	_registerAirGroupForRespawnOnLanding = function(name, isSpawnedAirborne)
		table.insert(RespawnGroups, name);
		if isSpawnedAirborne == true then
			table.insert(AirborneRespawnGroups, name)
		end
		env.info('Group ' .. name .. ' added to respawn monitoring.')
	end

	_registerAirGroupsForRespawnOnLanding = function(namesTable, isSpawnedAirborne)		
		for i, u in namesTable do
			_registerAirGroupForRespawnOnLanding(u, isSpawnedAirborne)
		end
	end

	_removeAirborneRespawnGroup = function(groupName)
		local index = -1
		if #AirborneRespawnGroups == 0 then return end
		for i,u in pairs(AirborneRespawnGroups) do
			if u == groupName then index = i end
		end
		if index > -1 then table.remove(AirborneRespawnGroups, index) end 
	end

	_isRespawnAirborne = function(groupName)
		for i, g in pairs(AirborneRespawnGroups) do
			env.info('Checking airbornes for group ' .. groupName)
			if g == groupName then return true end
		end
		return false
	end

	_isRespawnRegistered = function(groupName)
		for i, g in pairs(RespawnGroups) do
			if g == groupName then return true end
		end
		return false
	end

	_respawnGroupAndPurgeQueue = function(groupName)
		timer.scheduleFunction(mist.respawnGroup,{groupName, true}, timer.getTime() + 2)
		_removeAirborneRespawnGroup(groupName)
		if recheckSchedule > -1 then
			timer.removeFunction(recheckSchedule)
		end
	end
	
	_respawnAircraft = function(groupName)
		if _isRespawnAirborne(groupName) == false then return end
		local group = Group.getByName(groupName)
		if group then
			for i, unit in pairs(group:getUnits()) do
				if not unit or Unit.inAir(unit) == false then
					env.info('Respawning group ' .. groupName .. ' in 2 seconds...')
					_respawnGroupAndPurgeQueue(groupName)
				else
					env.info('Group ' .. groupName .. ' still active. Checking again in 15 seconds...')
					recheckSchedule = timer.scheduleFunction(STM.Respawn.respawnAircraft,{groupName}, timer.getTime() + 15)
				end
			end
		else
			env.info('Group ' .. groupName .. ' Not found. Respawning...')
			_respawnGroupAndPurgeQueue(groupName)
		end
	end
	
	_handleLanded = function(event)	
		if event.id ~= world.event.S_EVENT_ENGINE_SHUTDOWN and event.id ~= world.event.S_EVENT_CRASH then
			return
		end
		env.info('Respawn script discovered shutdown or crash...')
		local groupName = Unit.getGroup(event.initiator):getName()
		env.info('Group ' .. groupName .. ' initiated respawn check...')
		if _isRespawnAirborne(groupName) == false then
			env.info('Nope, that was not correct.')
			return
		end	
		env.info('Respawn monitored Group ' .. groupName .. ' shut down engines.')
		STM.Respawn.respawnAircraft(groupName)
	end

	_handleTakeoff = function(event)
		if event.id ~= world.event.S_EVENT_TAKEOFF then
			return
		end
		local groupName = Unit.getGroup(event.initiator):getName()
		if _isRespawnRegistered(groupName) == false then
			return
		end
		env.info('Monitored respawn group ' .. groupName .. ' took off.')
		table.insert(AirborneRespawnGroups, groupName)
	end
	
	_addEventHandlers = function()
		world.addEventHandler(_handleLanded)
		world.addEventHandler(_handleTakeoff)
		env.info('Event handlers added.')
	end

	

	if STM == nil then 
		env.info('STM.Respawn finds STM is null, creating...')
		STM = {} 
	end 

	STM.Respawn = {
		respawnAircraft = _respawnAircraft,
		addEventHandlers = _addEventHandlers,
		registerGroup = _registerAirGroupForRespawnOnLanding,
		registerGroups = _registerAirGroupsForRespawnOnLanding
	}
end

env.info('Respawn script loaded')

