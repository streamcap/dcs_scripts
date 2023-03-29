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
targetgroupSize = 0;

function scanUnitsForRecognitionTraining()
    local groundGroups = coalition.getGroups(coalition.side.RED, Group.Category.GROUND)
    for index, group in pairs(groundGroups) do 
        for jndex, unit in group:getUnits() do
            for index,unit in pairs(j:getUnits()) do                
                local id = #strobing+1
                units[id] = unit
            end            
        end
    end 
end



function setup(size)
    scanUnitsForRecognitionTraining()
    targetgroupSize = size
    setupMenu()
end

setup(5)