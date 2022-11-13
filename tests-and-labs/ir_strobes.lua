strobing = {}
strobes = {}

function startsWith(str, prefix)
	return str:sub(1, #prefix) == prefix
end

function irStrobeForGroup(groupName)
    local group = Group.getByName(groupName)
    for index,unit in pairs(group:getUnits()) do
        irStrobeForUnit(unit)
    end
end

function irStrobeForUnit(unit)
    strobing[unit:getID()] = unit
end

function destroyStrobes()
    for i,strobe in pairs(strobes) do
        strobe:destroy()
    end
    strobes = {}
end

function createStrobes()
    destroyStrobes()
    local nextTime = timer.getTime() + 1
    if #strobing < 1 then
        nextTime = nextTime + 10        
    end
    for i,j in pairs(strobing) do
        strobes[i] = Spot.createInfraRed(j, {x=0,y=-1,z=0}, j:getPoint())
    end
    timer.scheduleFunction(destroyStrobes, {}, timer.getTime() + 0.2)
    timer.scheduleFunction(createStrobes, {}, timer.getTime() + nextTime)    
end

function scanForGroundStrobers(side)
local blueStrobes = coalition.getGroups(side, Group.Category.GROUND)
for i,j in pairs(blueStrobes) do
    if startsWith(j:getName(), "STROBE ") then
        for k,l in pairs(j:getUnits()) do
            strobing[l:getID()] = l
        end
    end    
end

scanForGroundStrobers(coalition.side.BLUE)
timer.scheduleFunction(createStrobes, {}, timer.getTime() + 1)    
