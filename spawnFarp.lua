
function run()
    local point = trigger.misc.getZone('farp-1')
    local pointJson = net.lua2json(point.point)
    trigger.action.outText(pointJson, 10)
    env.info(pointJson)

    local statics = coalition.getStaticObjects(coalition.side.BLUE)
    for i,j in pairs(statics) do
        trigger.action.outText(j:getName(), 10)
    end

    local farpToSpawn = {
        ["category"] = "Heliports",
        ["shape_name"] = "FARP_T",
        ["name"] = 'statFarp2',
        ["type"] = "FARP_T",
        ["heliport_frequency"] = "262",
        ["heliport_callsign_id"] = 2,
        ["heliport_modulation"] = 0,
        ["x"] = point.point.x - 10,
        ["y"] = point.point.z
    }

    coalition.addStaticObject(country.id.USA, farpToSpawn)
end