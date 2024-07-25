 -- ATIS Kandahar on ATIS: 	127.02 MHz AM.
atisAndersen=ATIS:New(AIRBASE.Afghanistan.Kandahar, 127.02)
atisAndersen:SetSoundfilesPath("ATIS Soundfiles/")
atisAndersen:SetRadioRelayUnitName("Radio Relay Camp Bastion")
atisAndersen:SetActiveRunway("L")
atisAndersen:SetTowerFrequencies({250.100, 123.300})
atisAndersen:SetTACAN(98)
atisAndersen:Start()

 -- Setting up bombing Range "Iron Bombing Range"
local bombtargets={"target1", "target2", "target3", "target4"}
myRange=RANGE:New("Iron Bombing Range")
myRange:AddBombingTargets(bombtargets, 20)
myRange:SetRangeZone(ZONE:New("Iron Bombing Range"))
myRange:SetSoundfilesPath("Range Soundfiles/")
myRange:SetInstructorRadio(305)
myRange:SetRangeControl(256)
myRange.SetMessageON()
myRange:Start()
