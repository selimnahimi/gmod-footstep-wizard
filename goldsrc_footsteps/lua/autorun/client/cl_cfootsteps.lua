--[[-----------------------
    Custom Footsteps
-----------------------]]--

net.Receive("GoldSrcFootstepSound", function()
	local ply = net.ReadEntity()
	local file = net.ReadString()

	if (ply != LocalPlayer()) then
		PlayFootstep(ply, file)
	end
end)