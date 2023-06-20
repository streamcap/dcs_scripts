-- WE USE MOOSE HERE

spawnedFarps = 0
spawnedFarpFreq = 265
farpCallsignOffset = 2

local FARPClearnames = {
    [1]="London",
    [2]="Dallas",
    [3]="Paris",
    [4]="Moscow",
    [5]="Berlin",
    [6]="Rome",
    [7]="Madrid",
    [8]="Warsaw",
    [9]="Dublin",
    [10]="Perth"
}


function spawnFarp(zoneName)    
    local zone = trigger.misc.getZone(zoneName)

    spawnedFarps = spawnedFarps + 1
    local shape = farpShapes[farpType]
    local type = farpTypes[farpType] 
    local freq = spawnedFarpFreq + spawnedFarps
    local name = 'statFarp2-' .. spawnedFarps
    local rotationAngle = math.random() * 2 * math.pi
    local clearName = FARPClearnames[spawnedFarps]

    trigger.action.outText("Spawning FARP of type " .. type .. ", shape " .. shape .. ", name " .. name .. ", freq " .. freq .. "...", 30)

    local SpawnStaticFarp=SPAWNSTATIC:NewFromStatic("Static Invisible FARP-1", country.id.USA)
    SpawnStaticFarp:InitFARP(name, freq, 0)
    SpawnStaticFarp:InitDead(false)
    -- Spawn FARP 
    local ZoneSpawn = ZONE_RADIUS:New("FARP "..clearName,zone:GetVec2(),160,false)
    local FarpBerlin=SpawnStaticFarp:SpawnFromZone(ZoneSpawn, rotationAngle, "FARP "..clearName)

    -- ATC and services - put them 125m from the center of the zone towards North
    local FarpVehicles = SPAWN:NewWithAlias("FARP Vehicles Template","FARP "..clearName.." Technicals")
    FarpVehicles:InitHeading(180)
    local FarpVCoord = coord:Translate(125,0)
    FarpVehicles:SpawnFromCoordinate(FarpVCoord)

























    local farpToSpawn = {
        ["category"] = "Heliports",
        ["shape_name"] = farpShapes.farpType,
        ["name"] = name,
        ["type"] = farpTypes.farpType,
        ["heliport_frequency"] = freq,
        ["heliport_callsign_id"] = spawnedFarps,
        ["heliport_modulation"] = 0,
        ["x"] = zone.point.x,
        ["y"] = zone.point.z,
        --["heading"] = rotationAngle
    }

    local group = {
        ["units"] = {
            [1] = farpToSpawn
        },
        ["visible"]=true,
        ["hidden"]=false,
        ["x"]=farpToSpawn.x,
        ["y"]=farpToSpawn.y,
        ["name"]=farpToSpawn.name
    }       
    
    local farpgroup = coalition.addGroup(country.id.USA, -1, group)

    -- Currently DCS 2.8 does not trigger birth events if FAPRS are spawned!
    -- We create such an event. The airbase is registered in Core.Event
    local _event = {
        id = world.event.S_EVENT_BIRTH,
        time = timer.getTime(),
        initiator = farpgroup
    }
    -- Create BIRTH event.
    world.onEvent(_event)
end