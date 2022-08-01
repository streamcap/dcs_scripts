function booms(points)
	-- trigger.action.outText('Running booms...', 3)	
	for i, u in pairs(points) do		
		if(u == nil or u.p == nil or u.load == nil or type(u.p) ~= "table" or type(u.load) == "number") {
			env.info("The booms function takes a table of explosion params as input.")
			env.info("Each explosion param is 'p' - a 3d point of the location, and 'load' - an amount")
			env.info("Check the source file for examples on the Caucasus map.")
			trigger.action.outText("Error in function call booms, check log",10)
		}
		trigger.action.explosion(u.p, u.load)
	end
	-- trigger.action.outText('Booms run!', 3)
end

vaziani_runway={
	v1={p={x=-319474, y=464, z=903552},load=2500},
	v2={p={x=-318864, y=465, z=902952},load=2500},
	v3={p={x=-318408, y=464, z=902504},load=2500}
}

kutaisi_runway={
	v1={p={x=-285076,  y=45, z=683201},load=2500},
	v2={p={x=-284702,  y=45, z=684503},load=2500},
	v3={p={x=-284867,  y=45, z=683929},load=2500}
}

tunnels={
	t1={p={x=-00219543, y=2508, z=00818348},load=10000},
	t2={p={x=-00220954, y=2129, z=00812672},load=10000}
}

-- This line places explosions along the runway at Vaziani
--booms(vaziani_runway)