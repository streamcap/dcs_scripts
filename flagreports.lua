function reportFlag(flag, seconds)
	local value = trigger.misc.getUserFlag(flag)
	local msg = flag .. ":" .. value
	trigger.action.outText(msg,seconds)
end

function reportStatSums(flagOver, flagUnder, flagIn, seconds)
	local low = trigger.misc.getUserFlag(flagUnder)
	local mid = trigger.misc.getUserFlag(flagIn)
	local high = trigger.misc.getUserFlag(flagOver)
	local sum = low + mid + high
	
	local grade = 'F'
	local gradescore = mid / sum
	if(gradescore > 0.5)then grade = 'C' end
	if(gradescore > 0.75)then grade = 'B' end
	if(gradescore > 0.9)then grade = 'A' end
	
	trigger.action.outText("Here is your final tally:", seconds)
	trigger.action.outText("Total measured points: " .. sum, seconds)
	trigger.action.outText("Points at correct altitude: " .. mid, seconds)
	trigger.action.outText("Final grade: " .. grade, seconds)
end