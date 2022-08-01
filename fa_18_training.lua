-- fa_18_training scripts
-- uses DCS standard Group class functions

do
	fa18 = {}

	function fa18.tryDestroy(groupName)
		local tgts = Group.getByName(groupName)
		if(tgts ~= nil) then
			Group.destroy(tgts)
		end
	end

end