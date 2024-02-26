-- remove static transports
local transportNames = {"Transport_S1", "Transport_S2"}

for i,t in pairs(transportNames) do
	local obj = StaticObject.getByName(t)
	obj:destroy()
end