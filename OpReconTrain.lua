-- ***************** JTAC CONFIGURATION *****************
ctld.JTAC_LIMIT_RED = 10 -- max number of JTAC Crates for the RED Side
ctld.JTAC_LIMIT_BLUE = 10 -- max number of JTAC Crates for the BLUE Side
ctld.JTAC_dropEnabled = false -- allow JTAC Crate spawn from F10 menu
ctld.JTAC_maxDistance = 10000 -- How far a JTAC can "see" in meters (with Line of Sight)
ctld.JTAC_smokeOn_RED = false -- enables marking of target with smoke for RED forces
ctld.JTAC_smokeOn_BLUE = false -- enables marking of target with smoke for BLUE forces
ctld.JTAC_smokeColour_RED = 4 -- RED side smoke colour -- Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4
ctld.JTAC_smokeColour_BLUE = 1 -- BLUE side smoke colour -- Green = 0 , Red = 1, White = 2, Orange = 3, Blue = 4
ctld.JTAC_jtacStatusF10 = true -- enables F10 JTAC Status menu
ctld.JTAC_location = true -- shows location of target in JTAC message
ctld.JTAC_lock =  "vehicle" -- "vehicle" OR "troop" OR "all" forces JTAC to only lock vehicles or troops or all ground units

function activateJtac1()
    ctld.JTACAutoLase('JTAC1', 1631)
end
