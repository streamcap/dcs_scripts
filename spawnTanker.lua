-- USAGE:
-- In a mission script, call registerSpawnTanker with the following parameters:
-- unit: the unit object that will have the command added to its menu
-- distance: distance in nautical miles ahead of the unit to spawn the tanker
-- length: length in nautical miles of the tanker's refueling track
-- altitude: altitude in feet for the tanker
-- tankertype: integer index of the tanker type (1=KC-135, 2=KC135MPRS, 3=S-3B Tanker, 4=KC130, 5=A6E)
-- fast: boolean, if true the tanker will fly at a higher speed (about +40 knots IAS)
-- tacan: integer channel for the tanker's TACAN channel (1-126)
-- mode: string "X" or "Y" for the TACAN mode  (NOTE: This is broken in DCS 2.7.x and earlier)
-- freq: radio frequency in MHz for the tanker's radio in MHz (e.g., 251.0)


a6ePylons =
{
	[1] = { ["CLSID"] = "{HB_A6E_AERO1D}" },
	[2] = { ["CLSID"] = "{HB_A6E_AERO1D}" },
	[3] = { ["CLSID"] = "{HB_A6E_D704}" },
	[4] = { ["CLSID"] = "{HB_A6E_AERO1D}" },
	[5] = { ["CLSID"] = "{HB_A6E_AERO1D}" },
}

tankerTypes =
{
	[1] = { ["name"] = "KC-135", ["fuel"] = "90500", ["pylons"] = {}, ["minAlt"] = 10000 },
	[2] = { ["name"] = "KC135MPRS", ["fuel"] = "90500", ["pylons"] = {}, ["minAlt"] = 10000 },
	[3] = { ["name"] = "S-3B Tanker", ["fuel"] = "6880", ["pylons"] = {}, ["minAlt"] = 10000 },
	[4] = { ["name"] = "KC130", ["fuel"] = "29900", ["pylons"] = {}, ["minAlt"] = 5000 },
	[5] = { ["name"] = "A6E", ["fuel"] = "7220", ["pylons"] = a6ePylons, ["minAlt"] = 10000 },
}

function tacanFrequency(channel, mode)
	if (mode == "Y" and channel < 64) then
		local basef = 1087000000
		local offset = 1000000 * channel
		return basef + offset
	elseif (mode == "X" and channel < 64) then
		local basef = 961000000
		local offset = 1000000 * channel
		return basef + offset
	elseif (mode == "Y" and channel > 63) then
		local basef = 961000000
		local offset = 1000000 * channel
		return basef + offset
	elseif (mode == "X" and channel > 63) then
		local basef = 1087000000
		local offset = 1000000 * channel
		return basef + offset
	end
end

function getTanker(start, final, speed, tankertype, tacan, mode, freq, heading)
	local tacanFreq = tacanFrequency(tacan, mode)
	local pylons = tankertype.pylons
	if (pylons == nil) then
		pylons = {}
	end
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
				["psi"] = -1 * heading,
				["y"] = start.z,
				["x"] = start.x,
				["name"] = "Tanker-1-1",
				["payload"] =
				{
					["pylons"] = pylons,
					["fuel"] = tankertype.fuel,
					["flare"] = 30,
					["chaff"] = 30,
					--["gun"] = 100,
				}, -- end of ["payload"]
				["heading"] = heading,
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
		x = point.x + (metersDistance * math.cos(heading)),
		y = metersAltitude,
		z = point.z + (metersDistance * math.sin(heading))
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
	local tankergroup = getTanker(start, final, speed, params.tankertype, params.tacan, params.mode, params.freq, heading)
	env.info("tankergroup set")
	coalition.addGroup(params.unit:getCountry(), Group.Category.AIRPLANE, tankergroup)
	env.info("group added to " .. params.unit:getCountry())
	trigger.action.outText("Spawned tanker with heading " .. tostring(heading) .. " and speed " .. tostring(speed), 10)
end

function registerSpawnTanker(me, distance, length, altitude, tankertype, fast, tacan, mode, freq)
	local type = tankerTypes[tankertype]
	if altitude < type.minAlt then
		altitude = type.minAlt
	end
	local command = "Spawn " ..
	tankerTypes[tankertype].name ..
	" " ..
	distance ..
	" NM ahead of " .. me:getName() .. " fast: " .. tostring(fast) .. " tacan " .. tacan .. mode .. " freq " .. freq
	local params = {
		["unit"] = me,
		["distance"] = distance,
		["length"] = length,
		["altitude"] = altitude,
		["tankertype"] = tankerTypes[tankertype],
		["fast"] = fast,
		["tacan"] = tacan,
		["mode"] = mode,
		["freq"] = freq
	}
	missionCommands.addCommand(command, nil, spawnTanker, params)
	trigger.action.outText("Added command: " .. command, 15)
	env.info(command)
end

function getActivePlayer(coal)
	local units = coalition.getPlayers(coal)
	for i = 1, #units do
		local a = units[i]
		if (a ~= nil) then
			return a
		end
	end
	return {}
end
