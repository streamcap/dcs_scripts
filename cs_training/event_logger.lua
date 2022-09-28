-- helper functions...

function addLeadingZeroIfBelowTen(value)
    if value < 10 then
        return "0" .. value
    end
    return value
end

function getMissionGeneralData()
    --env.mission.date.Year .. env.mission.date.Month .. env.mission.date.Day .. ";" .. env.mission.start_time .. ";" .. env.mission.theatre .. "\r\n"

    local year = env.mission.date.Year
    local month = addLeadingZeroIfBelowTen(env.mission.date.Month)
    local day = addLeadingZeroIfBelowTen(env.mission.date.Day)

    if(env.mission.date.Month < 10) then
        month = "0" .. env.mission.date.Month
    end

    if(env.mission.date.Day < 10) then
        day = "0" .. env.mission.date.Day
    end

    return year .. month .. day .. ";" .. env.mission.start_time .. ";" .. env.mission.theatre .. "\r\n"
end

function getTypeNameFromObject(object)
    if Object.getCategory(object) == 1 then
        return Unit.getTypeName(object)
    elseif Object.getCategory(object) == 2 then
        return Weapon.getTypeName(object)
    elseif Object.getCategory(object) == 3 then
        if object["id_"] == Object.getName(object) and Object.getTypeName(object) ~= nil then
            return Object.getTypeName(object)
        end
        return StaticObject.getTypeName(object)
    elseif Object.getCategory(object) == 4 then
        return Airbase.getTypeName(object)
    elseif Object.getCategory(object) == 5 then
        return SceneryObject.getTypeName(object)
    else
        return ""
    end
end

--
-- Main script
--
-- Write header with mission info ->
-- env.mission.theatre  env.mission.start_time = (day 1, 00:00:00 + start_time (seconds))
-- local date = env.mission.date.Year .. env.mission.date.Month .. env.mission.date.Day
-- os.date() .. os.time()

if io and os and lfs then
    env.info("Event logger script starting")
    local logTestFile, errorMessage = io.open(lfs.writedir() .. "Logs\\" .. "DCSEventLogger-" .. os.date("%Y%m%d-%H-%M-%S") .. ".csv", "a")

    if errorMessage then
        env.error(errorMessage)
    end

    if logTestFile then
        logTestFile:write(getMissionGeneralData())
        local eventHandler = {}
        eventHandler.logger = logTestFile
        function eventHandler:onEvent(event)
            if event.id == 0 then
                return
            end

            local text = ""
            text = text .. event.id .. ";"
            text = text .. event.time .. ";"

            if event.initiator then
                text = text .. getTypeNameFromObject(event.initiator) .. ";"

                if Object.getCategory(event.initiator) == 1 then
                    local playerName = Unit.getPlayerName(event.initiator)
                    if playerName ~= nil then
                        text = text .. playerName
                    end
                end
                text = text .. ";"
            else
                text = text .. ";;"
            end

            if event.weapon then
                text = text .. getTypeNameFromObject(event.weapon) .. ";"
            elseif event.weapon_name then
                text = text .. event.weapon_name .. ";"
            else
                text = text .. ";"
            end

            if event.target then
                if Object.getCategory(event.target) == 1 then
                    text = text .. getTypeNameFromObject(event.target) .. ";"
                    local playerName = Unit.getPlayerName(event.target)
                    if playerName ~= nil then
                        text = text .. playerName
                    end
                    text = text .. ";"
                    --elseif Object.getCategory(event.target) == 3 and event.id ~= 6 then
                elseif event.id ~= 6 then --this should get typeName from any object, but eventId must not be 6 as it has non-script-acessable target object
                    text = text .. getTypeNameFromObject(event.target) .. ";;"
                else
                    text = text .. ";;"
                end
            else
                text = text .. ";;"
            end

            if event.place and Object.getCategory(event.place) == 4 then
                local landTakeoffPlace = Airbase.getDesc(event.place)

                text = text .. landTakeoffPlace.category .. ";"
                text = text .. Airbase.getID(event.place) .. ";"
                text = text .. landTakeoffPlace.displayName .. ";"
            elseif event.place and Object.getCategory(event.place) == 1 then
                local landTakeoffPlace = Airbase.getDesc(event.place)

                text = text .. landTakeoffPlace.category .. ";"
                text = text .. Airbase.getID(event.place) .. ";"
                text = text .. landTakeoffPlace.displayName .. ";"
            else
                text = text .. ";;;"
            end

            if event.comment then
                text = text .. event.comment
            end
            self.logger:write(text .. "\r\n");
        end

        world.addEventHandler(eventHandler)
    end
else
    env.error("One or more of io, os and lfs is not enabled, canceling event logger")
end
