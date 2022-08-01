-- This function runs a radio jamming/transmission.
-- In order for this to work, the following is needed:
-- * A list of jammer unit names in the jammers table
-- * A list of zones, one per jammer unit, in the same order a the jammer units, in the jammerZones table
-- * A sound file (wav or OGG) in the miz file, given as a relative path (included in the MIZ file)
-- USAGE: 
-- ** Load the script
-- ** Load the sound file by playing it for a non-included country
-- ** Check the MIZ file structure for the path to the sound file
-- ** Set the tables as shown below, for instance in a separate file

function restartWideBandJamming()
    if(type(jammers) ~= "table") {
        jammers = {}
    }
    if(type(jammerZones) ~= "table") {
        jammerZones = {}
    }
    jammings = {}
    startMHz = 250
    stopMHz = 310
    file = ""
    for i,j in pairs(jammings) do
        trigger.action.stopRadioTransmission(u)
    end
    for theMHz=startMHz,stopMHz, 1 do
        for i,j in pairs(jammers) do             
            local jammer = Unit.getByName(j)
            local jammerZone = jammerZones[i]
            if((jammer:getLife() * 10) > jammer:getLife0()) then
                local transmission = "tx_" .. theMHz .. "_" .. j .. "_"
                trigger.action.radioTransmission(file, jammer:getPoint(), 0, true, theMHz * 1000000, 400, transmission)
                table.insert(jammings, transmission)
            end
        end
    end
    timer.scheduleFunction(restartWideBandJamming, {}, timer.getTime() + 5)
end

jammers = {
    "jammer_1",
    "jammer_2"
}

jammerZones = {
    "jammerZone_1",
    "jammerZone_2"
}

file = "locale/default/jamming.ogg"