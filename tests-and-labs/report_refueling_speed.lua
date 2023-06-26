starttime = {}
startfuel = {}
report = {}
precision = 1      -- The number of decimals in the reporting
maxfuel = 22588    -- The max amount according to the Mission Editor loadout screen

function getFuelAmount(unit, startAmount)
    local currentFraction = unit:getFuel()   -- returns fuel as fraction of max load
    local start = startAmount or 0           -- if nil in call, set to 0
    local sumfuelAmount = (currentFraction * maxfuel) - start  -- get exact
    return round(sumfuelAmount)
end

function round(amount)   -- rounding using math.floor, one half and multiplier as precision
    local mult = 10 ^ precision
    return math.floor(amount * mult + 0.5) / mult
end

function reportFuel(aUnit, time)
    if report[aUnit:getID()] == nil then return nil end
    local fuel = getFuelAmount(aUnit)
    local msg = "Unit " .. aUnit:getName() .. " refueled " .. fuel .. " lbs at " .. timer.getTime()
    trigger.action.outText(msg, 5)
    return time + 30
end

refuelingStart = {}
function refuelingStart:onEvent(event) 
	if event.id ~= world.event.S_EVENT_REFUELING then return end
    starttime[event.initiator:getID()] = event.time
    startfuel[event.initiator:getID()] = getFuelAmount(event.initiator)
    local msg = "Unit " .. event.initiator:getName() .. " started refuel with " .. startfuel[event.initiator:getID()] .. " lbs at " .. starttime[event.initiator:getID()]
    env.info(msg)
    trigger.action.outText(msg, 5)
    report[event.initiator:getID()] = timer.scheduleFunction(reportFuel, event.initiator, timer.getTime() + 30)
end

refuelingStop = {}
function refuelingStop:onEvent(event)
    if event.id ~= world.event.S_EVENT_REFUELING_STOP or event.initiator == nil then return end
    if report[event.initiator:getID()] ~= nil then 
        timer.removeFunction(report[event.initiator:getID()]) 
        report[event.initiator:getID()] = nil
    end
    local sumfuel = getFuelAmount(event.initiator, startfuel[event.initiator:getID()])
    local sumtime = event.time - starttime[event.initiator:getID()]
    local fuelPerMinute = round((sumfuel / sumtime) * 60)
    local msg = "Refueling complete. Unit " .. event.initiator:getName() .. " took on " .. sumfuel .. " fuel in " .. sumtime .. " seconds, or " .. fuelPerMinute .. " lbs per minute."
    env.info(msg)
    trigger.action.outText(msg, 15)
end

world.addEventHandler(refuelingStart)
world.addEventHandler(refuelingStop)
trigger.action.outText("Registering handlers done...", 2)