strobing = {}
strobes = {}

function destroyStrobes()
    for i,strobe in pairs(strobes) do
        strobe:destroy()
    end
    strobes = {}
end

function createStrobes()
    destroyStrobes()
    if #strobing < 1 then
        trigger.action.outText('STROBING IS EMPTY!!! ', 10)    
        return
    end
    for i,unit in pairs(strobing) do
        local id = #strobes + 1
        --trigger.action.outText('Creating strobe ' .. id .. ' on unit: ' .. unit:getName(), 10)
        strobes[id] = Spot.createInfraRed(unit, {x=0,y=1,z=0}, unit:getPoint())
    end
    timer.scheduleFunction(destroyStrobes, {}, timer.getTime() + 0.25)
    timer.scheduleFunction(createStrobes, {}, timer.getTime() + 1)    
end

function scanForGroundStrobers(side, prefix)
    strobing = {}
    local blueStrobes = coalition.getGroups(side, Group.Category.GROUND)
    for i,j in pairs(blueStrobes) do
        if j:getName():sub(1, #prefix) == prefix then
            for index,unit in pairs(j:getUnits()) do                
                local id = #strobing+1
                strobing[id] = unit
                local a = strobing[id]
            end
        end    
    end
end

function allStrobesOn()
    scanForGroundStrobers(coalition.side.BLUE, "STROBE ")
    timer.scheduleFunction(createStrobes, {}, timer.getTime() + 1)    
end

function allStrobesOff()
    strobing = {}
end