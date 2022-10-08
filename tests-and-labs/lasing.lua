spots = {}

function setLasing(jtacName, targetName, code)
    local jtac = Unit.getByName(jtacName)
    local target = Unit.getByName(targetName)
    local lsr = Spot.createLaser(jtac, {x=0,y=0,z=0}, target:getPoint(), code)
    local ir = Spot.createInfraRed(jtac, {x=0,y=0,z=0}, target:getPoint())
    spots[0] = lsr
    spots[1] = ir
end

function clearLasers()
    for i,j in pairs(spots) do
        j:destroy()
    end
    spots = {}
end