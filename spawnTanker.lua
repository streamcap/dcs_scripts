tankerTypes = 
{
	[1] = "KC-135",
	[2] = "KC-135 MPRS",
	[3] = "S-3B Tanker"
}

function getTanker(start, final, speed, tankertype)
	return {
		["radioSet"] = true,
		["task"] = "Refueling",
		["route"] = 
		{
			["points"] = 
			{
				[1] = 
				{
					["alt"] = start.y,
					["action"] = "Turning Point",
					["alt_type"] = "BARO",
					["speed"] = speed,
					["task"] = 
					{
						["id"] = "ComboTask",
						["params"] = 
						{
							["tasks"] = 
							{
								[1] = 
								{
									["enabled"] = true,
									["auto"] = true,
									["id"] = "Tanker",
									["number"] = 1,
									["params"] = 
									{
									}, -- end of ["params"]
								}, -- end of [1]
								[2] = 
								{
									["enabled"] = true,
									["auto"] = false,
									["id"] = "WrappedAction",
									["number"] = 2,
									["params"] = 
									{
										["action"] = 
										{
											["id"] = "Option",
											["params"] = 
											{
												["value"] = true,
												["name"] = 6,
											}, -- end of ["params"]
										}, -- end of ["action"]
									}, -- end of ["params"]
								}, -- end of [2]
								[3] = 
								{
									["enabled"] = true,
									["auto"] = true,
									["id"] = "WrappedAction",
									["number"] = 2,
									["params"] = 
									{
										["action"] = 
										{
											["id"] = "ActivateBeacon",
											["params"] = 
											{
												["type"] = 4,
												["AA"] = false,
												["unitId"] = 256,
												["modeChannel"] = "X",
												["channel"] = 11,
												["system"] = 4,
												["callsign"] = "TKR",
												["bearing"] = true,
												["frequency"] = 972000000,
											}, -- end of ["params"]
										}, -- end of ["action"]
									}, -- end of ["params"]
								}, -- end of [2]
								[4] = 
								{
									["enabled"] = true,
									["auto"] = false,
									["id"] = "Orbit",
									["number"] = 3,
									["params"] = 
									{
										["altitudeEdited"] = true,
										["pattern"] = "Race-Track",
										["speed"] = speed,
										["altitude"] = start.y,
										["speedEdited"] = true,
									}, -- end of ["params"]
								}, -- end of [3]
							}, -- end of ["tasks"]
						}, -- end of ["params"]
					}, -- end of ["task"]
					["type"] = "Turning Point",
					["ETA"] = 0,
					["ETA_locked"] = true,
					["y"] = start.z,
					["x"] = start.x,
					["formation_template"] = "",
					["speed_locked"] = true,
				}, -- end of [1]
				[2] = 
				{
					["alt"] = start.y,
					["action"] = "Turning Point",
					["alt_type"] = "BARO",
					["speed"] = speed,
					["task"] = 
					{
						["id"] = "ComboTask",
						["params"] = 
						{
							["tasks"] = 
							{
							}, -- end of ["tasks"]
						}, -- end of ["params"]
					}, -- end of ["task"]
					["type"] = "Turning Point",
					["ETA"] = 265.61337261173,
					["ETA_locked"] = false,
					["y"] = final.z,
					["x"] = final.x,
					["formation_template"] = "",
					["speed_locked"] = true,
				}, -- end of [2]
			}, -- end of ["points"]
		}, -- end of ["route"]
		["units"] = 
		{
			[1] = 
			{
				["alt"] = start.y,
				["alt_type"] = "BARO",
				["livery_id"] = "usaf standard",
				["skill"] = "High",
				["speed"] = speed,
				["type"] = tankertype,
				["psi"] = -2.0158125515504,
				["y"] = start.z,
				["x"] = start.x,
				["name"] = "Aerial-1-1",
				["payload"] = 
				{
					["pylons"] = 
					{
					}, -- end of ["pylons"]
					["fuel"] = "7813",
					["flare"] = 30,
					["chaff"] = 30,
					["gun"] = 100,
				}, -- end of ["payload"]
				["heading"] = 1.57,
				["callsign"] = 
				{
					[1] = 1,
					[2] = 1,
					[3] = 1,
					["name"] = "Texaco11",
				}, -- end of ["callsign"]
				["onboard_num"] = "010",
			}, -- end of [1]
		}, -- end of ["units"]
		["y"] = start.z,
		["x"] = start.x,
		["name"] = "Aerial-1",
		["communication"] = true,
		["frequency"] = 259,
	} -- end of ["tankerGroup"]
end

function getOffset(point, heading, nauticals, altitude)
	local metersDistance = nauticals * 1852
	local metersAltitude = altitude / 3.28
	return {
		x=point.x + (metersDistance * math.cos(heading)), 
		y=metersAltitude, 
		z=point.z + (metersDistance * math.sin(heading))
	}
end

function getSpeed(altitude, fast) 
	local baseSpeed = 126
	if fast then 
		baseSpeed = baseSpeed + 40 
	end
	return (0.001 * altitude) + 166

end

function spawnTanker(params)
	local unit = params.unit
	if unit == nil then
		trigger.action.outText("Spawning failed", 10)
		return
	end
	local unitpos = unit:getPosition()
	local heading = math.atan2(unitpos.x.z, unitpos.x.x)
	local start = getOffset(unitpos.p, heading, params.distance, params.altitude)	
	local final = getOffset(start, heading, params.length, params.altitude)
	local speed = getSpeed(params.altitude, params.fast)
	local tankergroup = getTanker(start, final, speed, params.tankertype)
	coalition.addGroup(unit:getCountry(),Group.Category.AIRPLANE, tankergroup)
	trigger.action.outText("Spawned tanker", 10)
end

function registerSpawnTanker(me, distance, length, altitude, tankertype, fast)
	local params = { 
		["unit"]=me, 
		["distance"]=distance, 
		["length"]=length, 
		["altitude"]=altitude, 
		["type"] = tankerTypes[tankertype], 
		["fast"]=fast 
	}
	var command = "Spawn ".. tankerTypes[tankertype] .. " " .. distance .. " NM ahead of " .. me:getName() .. " fast: " .. tostring(fast)
	missionCommands.addCommand(command, nil, spawnTanker, params)
	trigger.action.outText(command, 5)
	env.info(command)
end
