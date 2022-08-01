function messageGroupFuel(groupName)
	 local flightFuel = {}
	 for i, unitObject in pairs(Group.getByName(groupName):getUnits()) do		
	    local fuel = math.floor(Unit.getFuel(unitObject) * 100)
		local msg = 'Unit ' .. unitObject:getCallsign() .. " has fuel level " .. fuel
		trigger.action.outText(msg, 1)
	 end
end
