illum_delay = 5

function fireIllumRounds(args)
    if args.point == nil then
        timer.scheduleFunction(removeMark, {mark = args.point}, timer.getTime() + 1)
        return
    end
    local MGRS6 = getMgrs6(args.point.pos)
    trigger.action.outText('Illuminating ' .. MGRS6, 10)
    local tgt = args.point.pos
    tgt = {x = tgt.x, y = land.getHeight({x = tgt.x, y = tgt.z}) + 200, z= tgt.z}
    for n = 0, 4, 1 do
        tgt.y = tgt.y + 100
        trigger.action.illuminationBomb(tgt,1000000)
    end
    timer.scheduleFunction(removeMark, {mark = args.point}, timer.getTime() + 1)
end

function removeMark(args)
    if args.mark == nil then
        return
    end
    trigger.action.removeMark(args.mark.idx)
end

function getMgrs6(point)
    local lat, lon = coord.LOtoLL(point)	--target coordinates
    local MGRS = coord.LLtoMGRS(lat, lon)		--target MGRS grid
    return MGRS.MGRSDigraph .. " " .. math.floor(MGRS.Easting / 100) .. " " .. math.floor(MGRS.Northing / 100)	--simplified MGRS grid to 100m precision
end

MarkEventHandler = {}
function MarkEventHandler:onEvent(event)
    if event.id == world.event.S_EVENT_MARK_ADDED then
        trigger.action.outText('Marker added! Lights in '.. illum_delay ..' seconds...', 10)
        timer.scheduleFunction(fireIllumRounds, {point = event}, timer.getTime() + illum_delay)
    elseif event.id == world.event.S_EVENT_MARK_REMOVED then
        trigger.action.outText('Marker removed!', 10)
    end
end
world.addEventHandler(MarkEventHandler)