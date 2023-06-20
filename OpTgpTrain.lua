-- Op TGP training
-- Train target acquisition, ID and engagement using targeting pod

idMade = false
idCorrect = false
radioCommands = {}

selectedTarget = "MLRS_TGT"

function clearCommands()
    for _, v in pairs(radioCommands) do
		missionCommands.removeItem(v)
	end
end

function setupStageOne()
    idMade = false
    idCorrect = false
    trigger.action.outText("At WP A you have several vehicles. One of the vehicles is moving. ID the moving vehicle correctly by selecting the corresponding alternative in the F10 menu.", 30)

    table.insert(radioCommands, missionCommands.addCommand("SCUD launcher", nil, reportStageOne, {isCorrect = false}))
    table.insert(radioCommands, missionCommands.addCommand("MLRS launcher", nil, reportStageOne, {isCorrect = true}))
    table.insert(radioCommands, missionCommands.addCommand("Howitzer", nil, reportStageOne, {isCorrect = false}))
end

function setupStageTwo()
    idMade = false
    idCorrect = false
    --trigger.action.setUserFlag("StageTwo", 1)
    trigger.action.outText("Near WP B you have more vehicles, some stationary and some moving. Report the correct amount of moving vehicles.", 30)
    table.insert(radioCommands, missionCommands.addCommand("3 vehicles moving", nil, reportStageTwo, {isCorrect = true}))
    table.insert(radioCommands, missionCommands.addCommand("5 vehicles moving", nil, reportStageTwo, {isCorrect = false}))
    table.insert(radioCommands, missionCommands.addCommand("9 vehicles moving", nil, reportStageTwo, {isCorrect = false}))
end

function setupStageThree()
    trigger.action.outText("Return to WP A, re-locate the moving vehicle and destroy it - without damaging the other vehicles!", 30)
    --trigger.action.setUserFlag("StageThree", 1)
    world.addEventHandler(reportStageThree)
end

function reportStageOne(a)
    idMade = true
    idCorrect = a.isCorrect

    if idCorrect then
        trigger.action.outText("Correct! Please proceed to stage two.", 10)
        clearCommands()
        setupStageTwo()
    else
        trigger.action.outText("No, that is wrong. Try again.", 10)
    end
end

function reportStageTwo(a)
    idMade = true
    idCorrect = a.isCorrect

    if idCorrect then
        trigger.action.outText("Correct! Please proceed to stage three.", 10)
        clearCommands()
        setupStageThree()
    else
        trigger.action.outText("No, that is wrong. Try again.", 10)
    end
end

reportStageThree = {}
function reportStageThree:onEvent(event)
    if event.id == nil or event.id ~= world.event.S_EVENT_DEAD then return end
    if(event.initiator:getName() ~= selectedTarget) then
        trigger.action.outText("Oh no! Wrong target.", 10)
    else
        trigger.action.outText("Good! Correct target.", 10)
        world.removeEventHandler(trackDead)
        timer.scheduleFunction(allDone, nil, timer.getTime() + 15)
     end    
end

function allDone()
    trigger.action.outText("Training mission completed! You are clear to RTB.", 30)
end

liftoff = {}
function liftoff:onEvent(event)
    if event.id == nil or event.id ~= world.event.S_EVENT_TAKEOFF or event.initiator:getName() ~= "Trainee" then return end

    trigger.action.outText("Climb and maintain 14000 throughout the training - there are active SHORAD systems in the area!", 30)
    timer.scheduleFunction(setupStageOne, nil, timer.getTime() + 15)
    world.removeEventHandler(liftoff)
end

trigger.action.outText("Your mission is to identify and engage targets according to the instructions given here. You are NOT to engage any other targets. Your first instruction will be given after liftoff.", 60)
world.addEventHandler(liftoff)

