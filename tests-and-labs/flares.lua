local triggerZones = {}
for _, v in pairs(env.mission.triggers.zones) do
    if startsWith(v.name, "tgt") then
        -- do stuff with the zones
    end
end

