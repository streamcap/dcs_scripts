



function runTest()
	local point = {['x']=0, ['y']=0, ['z']=0}
	local levels = {100, 500, 1000, 5000, 10000}
	for i,j in pairs(levels) do
		point.y = j
		local wind = atmosphere.getWind(point)
		local msg = '-> x: ' .. wind.x .. ', y: ' .. wind.y .. ', z: ' .. wind.z .. ', alt: ' .. point.y*3.28084 .. ' <-'
		trigger.action.outText(msg, 10)
	end
end

runTest()