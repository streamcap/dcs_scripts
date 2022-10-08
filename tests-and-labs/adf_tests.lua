env.info('Getting points...')
local p1 = Unit.getByName('adf-1-1'):getPoint()
local p2 = Unit.getByName('adf-2-1'):getPoint()
local p3 = Unit.getByName('adf-3-1'):getPoint()

env.info('Starting radios...')
trigger.action.radioTransmission('l10n/DEFAULT/air-raid-soundscape.ogg', p1, 0, true, 555000, 50, 'radio1')
trigger.action.radioTransmission('l10n/DEFAULT/air-raid-soundscape.ogg', p2, 0, true, 1800000, 50, 'radio2')


function fullPath()
    local p3 = Unit.getByName('adf-3-1'):getPoint()
    trigger.action.stopRadioTransmission('radio3')
    trigger.action.radioTransmission('l10n/DEFAULT/jamming-tone.ogg', p3, 1, false, 34000000, 50, 'radio3')
    trigger.action.outText('Full',2)
    env.info('Full to x ' .. p3.x .. ' y ' .. p3.y .. ' z ' .. p3.z)
end

function halfPath()
    local p3 = Unit.getByName('adf-3-1'):getPoint()
    trigger.action.stopRadioTransmission('radio3')
    trigger.action.radioTransmission('DEFAULT/jamming-tone.ogg', p3, 1, false, 34000000, 50, 'radio3')
    trigger.action.outText('Half',2)
    env.info('Half to x ' .. p3.x .. ' y ' .. p3.y .. ' z ' .. p3.z)
end

function noPath()
    local p3 = Unit.getByName('adf-3-1'):getPoint()
    trigger.action.stopRadioTransmission('radio3')
    trigger.action.radioTransmission('jamming-tone.ogg', p3, 1, false, 34000000, 50, 'radio3')
    trigger.action.outText('No',2)
    env.info('No to x ' .. p3.x .. ' y ' .. p3.y .. ' z ' .. p3.z)
end

env.info('Done.')
