strobing = {}
strobes = {}

function startsWith(str, prefix)
	return str:sub(1, #prefix) == prefix
end

function destroyStrobes()
    for i,strobe in pairs(strobes) do
        strobe:destroy()
    end
    strobes = {}
end

function createStrobes()
    destroyStrobes()
    if #strobing < 1 then
        return        
    end
    for i,j in pairs(strobing) do
        strobes[i] = Spot.createInfraRed(j, {x=0,y=-1,z=0}, j:getPoint())
    end
    timer.scheduleFunction(destroyStrobes, {}, timer.getTime() + 0.2)
    timer.scheduleFunction(createStrobes, {}, timer.getTime() + 1)    
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
end

function allStrobesOn()
    scanForGroundStrobers(coalition.side.BLUE)
    timer.scheduleFunction(createStrobes, {}, timer.getTime() + 1)    
end

function allStrobesOff()
    strobing = {}
end