spots = {}

function setLasing(jtacName, targetName, isTgtStatic, code, addIr)
    local targetPoint;
    local jtac = Unit.getByName(jtacName)
    if isTgtStatic then
        targetPoint = StaticObject.getByName(targetName):getPoint()
    else
        targetPoint = Unit.getByName(targetName):getPoint()
    end
    spots[0] = Spot.createLaser(jtac, {x=0,y=0,z=0}, targetPoint, code)
    if addIr then
        spots[1] = Spot.createInfraRed(jtac, {x=0,y=0,z=0}, targetPoint)     
    end
end

function clearLasers()
    for i,j in pairs(spots) do
        j:destroy()
    end
    spots = {}
end