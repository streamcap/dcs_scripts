starttime = nil
startfuel = nil
report = nil
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
    if report == nil then return nil end
    local fuel = getFuelAmount(aUnit)
    local msg = "Unit " .. aUnit:getName() .. " refueled " .. fuel .. " lbs at " .. timer.getTime()
    trigger.action.outText(msg, 5)
    return time + 30
end

refuelingStart = {}
function refuelingStart:onEvent(event) 
	if event.id ~= world.event.S_EVENT_REFUELING then return end
    starttime = event.time
    startfuel = getFuelAmount(event.initiator)
    local msg = "Unit " .. event.initiator:getName() .. " started refuel with " .. startfuel .. " lbs at " .. starttime
    env.info(msg)
    trigger.action.outText(msg, 5)
    report = timer.scheduleFunction(reportFuel, event.initiator, timer.getTime() + 30)
end

refuelingStop = {}
function refuelingStop:onEvent(event)
    if event.id ~= world.event.S_EVENT_REFUELING_STOP or event.initiator == nil then return end
    if report ~= nil then 
        timer.removeFunction(report) 
        report = nil
    end
    local sumfuel = getFuelAmount(event.initiator, startfuel)
    local sumtime = event.time - starttime
    local fuelPerMinute = round((sumfuel / sumtime) * 60)
    local msg = "Refueling complete. Unit " .. event.initiator:getName() .. " took on " .. sumfuel .. " fuel in " .. sumtime .. " seconds, or " .. fuelPerMinute .. " lbs per minute."
    env.info(msg)
    trigger.action.outText(msg, 15)
end

world.addEventHandler(refuelingStart)
world.addEventHandler(refuelingStop)
trigger.action.outText("Registering handlers done...",2)