-- unit_recognition
-- script to train recognition of different objects
--
-- Start: Place a trigger zone named "TARGETS" in a free spot on the map
--        and then place the units to train on well away from the player aircraft,
--        for instance in one of the corners of the map.
--        Then run this script in a "do script file" trigger action about 3-5 seconds 
--        into the mission in order to activate it.
--
-- Function: The script will place the units in the TARGETS zone and then
--           tell you which unit to identify and destroy using your weapons.
--           If you destroy the wrong target, you fail.


units = {}
spawnedUnits = {}
destroyedUnits = {}
targetgroupSize = 0;
selectedTarget = nil;

function scanUnitsForRecognitionTraining()
    local groundGroups = coalition.getGroups(coalition.side.RED, Group.Category.GROUND)
    for i, group in pairs(groundGroups) do 
        for k,unit in pairs(group:getUnits()) do                
            local id = #units + 1
            units[id] = unit
        end
    end 
end

function resetTargetArea()
    -- Find all units in target area
    -- remove all units in target area
end

function runTrainingMoment()
    resetTargetArea()
    missionCommands.removeItem()
    for i = 1, targetgroupSize do
        spawnRandomUnitInTargetZone()
    end
    selectedTargetIndex = #spawnedUnits * math.random()
    selectedTarget = spawnedUnits[selectedTargetIndex]
    trigger.action.outText("Identify and destroy the " .. selectedTarget:getName(), 10)
    world.addEventHandler(trackDead)
end

trackDead = {}
function trackDead:onEvent(event)
    if event.id ~= world.event.S_EVENT_DEAD then return end
    if(event.initiator.getID() ~= selectedTarget.getID()) then
        trigger.action.outText("Oh no! Wrong target.", 10)
    else
        trigger.action.outText("Good! Correct target.", 10)
        selectedTarget = nil;
        setupMenu();
        world.removeEventHandler(trackDead)
    end    
end


function setupMenu()
    trigger.action.outText("Use F10 menu to try again.", 10)
    missionCommands.addCommand("Ready!", nil, runTrainingMoment, nil)
end

function setup(size)
    scanUnitsForRecognitionTraining()
    targetgroupSize = size
    setupMenu()
end

setup(5)