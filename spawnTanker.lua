tankerTypes = 
{
	[1] = {["name"]="KC-135",["fuel"]="90500"},
	[2] = {["name"]="KC135MPRS",["fuel"]="90500"},
	[3] = {["name"]="S-3B Tanker",["fuel"]="7800"},
	[4] = {["name"]="KC130",["fuel"]="29500"}
}

function tacanFrequency( channel, mode )
    if ( mode == "Y" and channel < 64 ) then
        local basef = 1087000000
        local offset = 1000000 * channel
        return basef + offset
    elseif( mode == "X" and channel < 64 ) then
        local basef = 961000000
        local offset = 1000000 * channel
        return basef + offset
    elseif ( mode == "Y" and channel > 63 ) then
        local basef = 961000000
        local offset = 1000000 * channel
        return basef + offset
    elseif( mode == "X" and channel > 63 ) then
        local basef = 1087000000
        local offset = 1000000 * channel
        return basef + offset
    end        
end

function getTanker(start, final, speed, tankertype, tacan, mode, freq)
	local tacanFreq = tacanFrequency(tacan, mode)
	trigger.action.outText("Set tacan " .. tacan .. mode .. " and freq " .. freq, 10)
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
												["modeChannel"] = mode,
												["channel"] = tacan,
												["system"] = 4,
												["callsign"] = "TKR",
												["bearing"] = true,
												["frequency"] = tacanFreq,
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
				["type"] = tankertype.name,
				["psi"] = -2.0158125515504,
				["y"] = start.z,
				["x"] = start.x,
				["name"] = "Aerial-1-1",
				["payload"] = 
				{
					["pylons"] = 
					{
					}, -- end of ["pylons"]
					["fuel"] = tankertype.fuel,
					["flare"] = 30,
					["chaff"] = 30,
					--["gun"] = 100,
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
		["name"] = "tanker-1",
		["communication"] = true,
		["frequency"] = freq,
	} -- end of ["tankerGroup"]
end



function getOffset(point, heading, nauticals, altfeet)
	local metersDistance = nauticals * 1852
	local metersAltitude = altfeet / 3.28
	return {
		x=point.x + (metersDistance * math.cos(heading)), 
		y=metersAltitude, 
		z=point.z + (metersDistance * math.sin(heading))
	}
end

function getSpeed(altitude, isfast) 
	local baseSpeed = 126
	if isfast then 
		baseSpeed = baseSpeed + 40 
	end
	return (0.001 * altitude) + 166

end

function spawnTanker(params)
	local unitpos = params.unit:getPosition()
	local heading = math.atan2(unitpos.x.z, unitpos.x.x)
	env.info("heading set to " .. tostring(heading))
	local start = getOffset(unitpos.p, heading, params.distance, params.altitude)	
	local final = getOffset(start, heading, params.length, params.altitude)
	local speed = getSpeed(params.altitude, params.fast)
	env.info("speed set to " .. tostring(speed))
	local tankergroup = getTanker(start, final, speed, params.tankertype, params.tacan, params.mode, params.freq)
	env.info("tankergroup set")
	coalition.addGroup(params.unit:getCountry(), Group.Category.AIRPLANE, tankergroup)
	env.info("group added to " .. params.unit:getCountry())
	trigger.action.outText("Spawned tanker", 10)
end

function registerSpawnTanker(me, distance, length, altitude, tankertype, fast, tacan, mode, freq)    
	local command = "Spawn ".. tankerTypes[tankertype].name .. " " .. distance .. " NM ahead of " .. me:getName() .. " fast: " .. tostring(fast) .. " tacan " .. tacan .. mode .. " freq " .. freq	
	local params = {
		["unit"]=me,
		["distance"]=distance,
		["length"]=length,
		["altitude"]=altitude,
		["tankertype"] = tankerTypes[tankertype],
		["fast"]=fast,
		["tacan"]=tacan,
		["mode"]=mode,
		["freq"]=freq
	}
	missionCommands.addCommand(command, nil, spawnTanker, params)
	trigger.action.outText(command, 15)
	env.info(command)
end
