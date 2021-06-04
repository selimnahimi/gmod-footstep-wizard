--[[-----------------------
    Custom Footsteps
-----------------------]]--

-- On client simply disable footsteps altogether.
-- This is required, since otherwise the client keeps trying
-- to play the original sounds next to the custom ones.

hook.Add( "PlayerFootstep", "CustomFootstep", function( ply, pos, foot, sound, volume, rf )
	if (IsEnabled()) then return true end -- Return true disables anything default
end)

local function IsEnabled()
	return GetConVar("gsrc_footsteps_enabled"):GetBool()
end
