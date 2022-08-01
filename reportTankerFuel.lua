refuelingStart = {}
function refuelingStart:onEvent(event) 
	if event.id ~= world.event.S_EVENT_REFUELING then return end
	env.info("Tanking started")
	local tanker = Unit.getByName("t1")
	if tanker then
		env.info("Tanker fueling started at " .. tanker:getFuel() ..", time: " .. event.time)
		trigger.action.outText("Tanker fuel: " .. tanker:getFuel() .. " at " .. event.time, 5)
	end	
end

refuelingStop = {}
function refuelingStop:onEvent(event) 
	if event.id ~= world.event.S_EVENT_REFUELING_STOP then return end
	env.info("Tanking ended")
	local tanker = Unit.getByName("t1")
	if tanker then
		env.info("Tanker fueling ended at " .. tanker:getFuel() ..", time: " .. event.time)
		trigger.action.outText("Tanker fuel: " .. tanker:getFuel() .. " at " .. event.time, 5)
	end
end

world.addEventHandler(refuelingStart)
world.addEventHandler(refuelingStop)
trigger.action.outText("Registering handlers done...",2)
