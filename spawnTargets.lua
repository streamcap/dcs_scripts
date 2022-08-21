function getX(origin, num, distance, total)
    local br = math.sqrt(total)
    while num > br do
        num = (num - br)
    end
    return origin - (num * distance) -- expanding south
end

function getY(origin, num, distance, total)
    local br = math.sqrt(total)
    local a = origin
    while num > br do
        num = (num - br)
        a = a + distance -- expanding east
    end
    return a
end

function spawnTargets(xx, yy, amount, distance)
    local type = "Ural-375"
    local data = {
        ["name"] = "tgt",
        ["task"] = "Ground Nothing",
        ["units"] = {}
    }

    for i=1,amount do
        data.units[i]= {
            ["name"] = "tgt"..i,
            ["type"] = type,
            ["x"] = getX(xx, i, distance, amount),
            ["y"] = getY(yy, i, distance, amount)
        }
    end

    coalition.addGroup(country.id.RUSSIA, Group.Category.GROUND, data)
    local za = land.getHeight({x=xx,y=yy}) + 10
    trigger.action.smoke({x=xx+distance, y=za, z=yy-distance}, trigger.smokeColor.Red)
    trigger.action.smoke({x=xx+distance, y=za, z=yy+(distance*(1+math.sqrt(amount)))}, trigger.smokeColor.Green)
end