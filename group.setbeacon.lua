local ActivateBeacon = { 
  id = 'ActivateBeacon', 
  params = { 
    type = 32776, 
    system = 7, 
    name = string, 
    callsign = 'TWA', 
    frequency = 357000, 
  } 
}

function setBeaconOnGroup(groupName, freq)
	local group = Group.getByName(groupName)
	local controller = group:getController()
	if freq then
		ActivateBeacon.params.frequency = freq * 1000
	end
	controller:setCommand(ActivateBeacon)
end