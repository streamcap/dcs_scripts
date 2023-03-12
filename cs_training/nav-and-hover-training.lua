------------------------------------------------
-- Basic flow:
-- 1. Get and input coords
-- 2. Fly to coords, locate mark
-- 3. Identify mark, answer in radio
-- 4. Depending on answer, get hover interval
-- 5. Hover over or near mark for interval
-- 6. Get next set of coords
-- 7. Rinse, repeat
--
-- Basic rules:
-- * min altitude 6 ft unless in base area
-- * max hover altitude 20 ft
------------------------------------------------

function presentCoords(number)
    trigger.action.outTextForGroup
end

function registerPlayer(playerName)
    local unit = Unit.getByName(playerName)
    local group = unit:getGroup()
    coordsArg = { groupId=group:getID, }
    missionCommands.addCommandForGroup(group:getID, 'Get coordinates', nil, presentCoords, 1)
end