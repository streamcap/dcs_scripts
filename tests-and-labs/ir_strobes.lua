strobing = {}
strobes = {}
strobelength = 0.18
strobeinterval = 2

function destroyStrobes()
    for i,strobe in pairs(strobes) do
        strobe:destroy()
    end
    strobes = {}
end

function createStrobes()
    destroyStrobes()
    for i,unit in pairs(strobing) do
        local id = #strobes + 1
        --env.info('Creating strobe ' .. id .. ' on unit: ' .. unit:getName())
        strobes[id] = Spot.createInfraRed(unit, {x=0,y=1,z=0}, unit:getPoint())
    end
    timer.scheduleFunction(destroyStrobes, {}, timer.getTime() + strobelength)
    timer.scheduleFunction(createStrobes, {}, timer.getTime() + strobeinterval)
end

function scanForGroundStrobers(side, prefix)
    strobing = {}
    local strobers = coalition.getGroups(side, Group.Category.GROUND)
    for i,j in pairs(strobers) do
        if j:getName():sub(1, #prefix) == prefix then
            for index,unit in pairs(j:getUnits()) do                
                local id = #strobing + 1
                strobing[id] = unit
                local a = strobing[id]
            end
        end    
    end
    env.info('Found ' .. #strobers .. ' strobing groups.')
end

function allStrobesOn()
    scanForGroundStrobers(coalition.side.BLUE, "STROBE ")
    if #strobing < 1 then
        env.warning('STROBING IS EMPTY! ', 10)    
        return
    end
    timer.scheduleFunction(createStrobes, {}, timer.getTime() + 1)    
end

function allStrobesOff()
    strobing = {}
end