function parseFacZoneName(facZoneName)
    local splitString = {}
    for i in string.gmatch(facZoneName, "[%w]+") do
        table.insert(splitString, i)
    end
    if #splitString == 3 then
        return splitString[1], splitString[2], splitString[3]
    end
    return splitString[1], splitString[2], splitString[3], splitString[4]
end


function loadFacZones()
    local facZones = {}
    for _, v in pairs(env.mission.triggers.zones) do
        if startsWith(v.name, "FAC ") then
            local facAreaName, spawnType, _, spawnHeading = parseFacZoneName(v.name:sub(4))
            if not facZones[facAreaName] then
                facZones[facAreaName] = {}
            end
            if not facZones[facAreaName][spawnType] then
                facZones[facAreaName][spawnType] = {}
            end
            local zoneData = {}
            zoneData.x = v["x"]
            zoneData.y = v["y"]
            if spawnHeading then
                zoneData.heading = spawnHeading
            end
            table.insert(facZones[facAreaName][spawnType], zoneData)
        end
    end
    return facZones
end

function spawnRoadBlocks(areaName, min, max)
    local nrOfRoadBlocks = math.random(min, max)

    local selectIds = {}
    local unitSet = {}
    for _ = 1, nrOfRoadBlocks do
        local nrOfRoadBlockSlots = #facZones[areaName]["road"]
        local randomIndex = math.random(1, nrOfRoadBlockSlots)
        while selectIds[randomIndex] do
            randomIndex = math.random(1, nrOfRoadBlockSlots)
        end
        local roadblock = {}
        roadblock.x = facZones[areaName]["road"][randomIndex].x
        roadblock.y = facZones[areaName]["road"][randomIndex].y
        roadblock.heading = degreeToRadian(facZones[areaName]["road"][randomIndex].heading)
        roadblock.type = "outpost_road"
        selectIds[randomIndex] = randomIndex
        table.insert(unitSet, roadblock)
    end
    return coalition.addGroup(0, Group.Category.GROUND, { name = "FAC " .. areaName .. " roadblocks", units = unitSet })
end

function spawnTargets(areaName, min, max)
    local nrOfTargets = math.random(min, max)

    local selectIds = {}
    local unitSet = {}
    for _ = 1, nrOfTargets do
        local nrOfTargetSlots = #facZones[areaName]["target"]
        local randomIndex = math.random(1, nrOfTargetSlots)
        while selectIds[randomIndex] do
            randomIndex = math.random(1, nrOfTargetSlots)
        end
        local target = {}
        target.x = facZones[areaName]["target"][randomIndex].x
        target.y = facZones[areaName]["target"][randomIndex].y
        target.heading = degreeToRadian(math.random(0, 359))
        target.type = targetTable[math.random(1, #targetTable)]
        selectIds[randomIndex] = randomIndex
        table.insert(unitSet, target)
    end
    return coalition.addGroup(0, Group.Category.GROUND, { name = "FAC " .. areaName .. " targets", units = unitSet })
end

function randomOffset()
    local value = math.random(10,25)
    if math.random(1, 2) == 2 then
        return value * -1
    end
    return value
end

function spawnAds(areaName, difficulty)
    local adsConfig = difficultyTable[difficulty]
    local adsGroups = {}
    local selectIds = {}
    if adsConfig.EASY_AA.max ~= 0 then
        local nrOfEasyAa = math.random(adsConfig.EASY_AA.min, adsConfig.EASY_AA.max)
        local unitSet = {}
        for _ = 1, nrOfEasyAa do
            local nrOfAdsSlots = #facZones[areaName]["ads"]
            local randomIndex = math.random(1, nrOfAdsSlots)
            while selectIds[randomIndex] do
                randomIndex = math.random(1, nrOfAdsSlots)
            end
            local target = {}
            target.x = facZones[areaName]["ads"][randomIndex].x
            target.y = facZones[areaName]["ads"][randomIndex].y
            target.heading = degreeToRadian(math.random(0, 359))
            target.type = easyAaTable[math.random(1, #easyAaTable)]
            selectIds[randomIndex] = randomIndex
            table.insert(unitSet, target)
        end
        table.insert(adsGroups, coalition.addGroup(0, Group.Category.GROUND, { name = "FAC " .. areaName .. " Easy AA", units = unitSet }))
    end
    if adsConfig.MEDIUM_AA.max ~= 0 then
        local nrOfZu = math.random(adsConfig.MEDIUM_AA.min, adsConfig.MEDIUM_AA.max)
        local unitSet = {}
        for _ = 1, nrOfZu do
            local nrOfAdsSlots = #facZones[areaName]["ads"]
            local randomIndex = math.random(1, nrOfAdsSlots)
            while selectIds[randomIndex] do
                randomIndex = math.random(1, nrOfAdsSlots)
            end
            local target = {}
            target.x = facZones[areaName]["ads"][randomIndex].x
            target.y = facZones[areaName]["ads"][randomIndex].y
            target.heading = degreeToRadian(math.random(0, 359))
            local targetType = mediumAaTable[math.random(1, #mediumAaTable)]
            if type(targetType) == "table" then
                local sa18Secondary = {}
                sa18Secondary.x = facZones[areaName]["ads"][randomIndex].x + randomOffset()
                sa18Secondary.y = facZones[areaName]["ads"][randomIndex].y + randomOffset()
                sa18Secondary.heading = degreeToRadian(math.random(0, 359))
                sa18Secondary.type = targetType[1]
                table.insert(unitSet, sa18Secondary)
                targetType = targetType[2]
            end
            target.type = targetType
            selectIds[randomIndex] = randomIndex
            table.insert(unitSet, target)
        end
        table.insert(adsGroups, coalition.addGroup(0, Group.Category.GROUND, { name = "FAC " .. areaName .. " Medium AA", units = unitSet }))
    end
    if adsConfig.HARD_AA.max ~= 0 then
        local nrOfHardAa = math.random(adsConfig.HARD_AA.min, adsConfig.HARD_AA.max)
        local unitSet = {}
        for _ = 1, nrOfHardAa do
            local nrOfAdsSlots = #facZones[areaName]["ads"]
            local randomIndex = math.random(1, nrOfAdsSlots)
            while selectIds[randomIndex] do
                randomIndex = math.random(1, nrOfAdsSlots)
            end
            local targetType = hardAaTable[math.random(1, #hardAaTable)]
            if type(targetType) == "table" then
                local secondary = {}
                secondary.x = facZones[areaName]["ads"][randomIndex].x + randomOffset()
                secondary.y = facZones[areaName]["ads"][randomIndex].y + randomOffset()
                secondary.heading = degreeToRadian(math.random(0, 359))
                secondary.type = targetType[1]
                table.insert(unitSet, secondary)
                targetType = targetType[2]
            end
            local target = {}
            target.x = facZones[areaName]["ads"][randomIndex].x
            target.y = facZones[areaName]["ads"][randomIndex].y
            target.heading = degreeToRadian(math.random(0, 359))
            target.type = targetType
            selectIds[randomIndex] = randomIndex
            table.insert(unitSet, target)
        end
        table.insert(adsGroups, coalition.addGroup(0, Group.Category.GROUND, { name = "FAC " .. areaName .. " Hard AA", units = unitSet }))
    end
    return adsGroups
end

function spawnFacMission(callerId, areaName, difficulty)
    if activeFacAreas[areaName] and next(activeFacAreas[areaName]) ~= nil then
        trigger.action.outTextForGroup(callerId, "A FAC (" .. activeFacAreas[areaName].difficulty .. ") mission is already active at "..areaName, 30)
    else
        activeFacAreas[areaName] = {}
        activeFacAreas[areaName].difficulty = difficulty
        activeFacAreas[areaName].groups = {}
        table.insert(activeFacAreas[areaName].groups, spawnRoadBlocks(areaName, 1, 2))
        table.insert(activeFacAreas[areaName].groups, spawnTargets(areaName, 10, 20))
        for _, v in pairs(spawnAds(areaName, difficulty)) do
            table.insert(activeFacAreas[areaName].groups, v)
        end
        registerFacGroups(areaName, activeFacAreas[areaName].groups)
    end
end

difficultyTable = { Easy = { EASY_AA = { min = 2, max = 4 }, MEDIUM_AA = { min = 0, max = 0 }, HARD_AA = { min = 0, max = 0 } },
                    Medium = { EASY_AA = { min = 3, max = 5 }, MEDIUM_AA = { min = 2, max = 4 }, HARD_AA = { min = 0, max = 0 } },
                    Hard = { EASY_AA = { min = 1, max = 3 }, MEDIUM_AA = { min = 4, max = 6 }, HARD_AA = { min = 1, max = 3 } } }
targetTable = { "BTR-80", "BMP-1", "BMP-3", "T-55", "ATMZ-5", "Ural-4320T", "SAU Akatsia", "SAU 2-C9", "Grad-URAL" }
easyAaTable = { "ZU-23 Emplacement Closed", "Ural-375 ZU-23", "S-60_Type59_Artillery" }
mediumAaTable = { "ZSU-23-4 Shilka", "Strela-1 9P31", { "SA-18 Igla comm", "SA-18 Igla manpad" }, "ZSU_57_2" }
hardAaTable = { "Strela-10M3", "2S6 Tunguska", { "Dog Ear radar", "ZSU_57_2" }, { "Dog Ear radar", "Ural-375 ZU-23" } }
facZones = loadFacZones()
activeFacAreas = {}