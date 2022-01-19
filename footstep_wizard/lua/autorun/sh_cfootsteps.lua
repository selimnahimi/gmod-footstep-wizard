local MODE_HL1 = 0
local MODE_CS16 = 1
local MODE_OP4 = 2

local cvarEnabled = CreateConVar("gsrc_footsteps_enabled", "1", FCVAR_REPLICATE, "Enable/Disable the GoldSrc Footstep addon")
local cvarFallEnabled = CreateConVar("gsrc_footsteps_fall", "1", FCVAR_REPLICATE, "Enable/Disable GoldSrc custom falldamage event")

-- Set up footsteps for each material type
local matFootstepSounds = {
	[MAT_CONCRETE] = "GoldSrc.Footsteps.Concrete",
	[MAT_SNOW] = "GoldSrc.Footsteps.Snow",
	[MAT_DIRT] = "GoldSrc.Footsteps.Dirt",
	[MAT_FOLIAGE] = "GoldSrc.Footsteps.Dirt",
	[MAT_GRASS] = "GoldSrc.Footsteps.Dirt",
	[MAT_SAND] = "GoldSrc.Footsteps.Dirt",
    [MAT_METAL] = "GoldSrc.Footsteps.Metal",
    [MAT_TILE] = "GoldSrc.Footsteps.Tile",
    [MAT_VENT] = "GoldSrc.Footsteps.Metal",
    [MAT_GRATE] = "GoldSrc.Footsteps.MetalGrate",
    [MAT_SLOSH] = "GoldSrc.Footsteps.Slosh",
    ["ladder"] = "GoldSrc.Footsteps.Ladder"
}

-- Certain textures have concrete properties BUT WE DONT WANT THAT >:(
-- Seriously having concrete footsteps on the SNOW on CS_OFFICE???
local texFootstepType = {
	["CS_OFFICE/SPHINX_SNOW_1"] = MAT_SNOW
}

local function PlayFootstep(ply, file)
	if CLIENT or game.SinglePlayer() then
		-- Play the footstep locally
    	ply:EmitSound( file )
	elseif SERVER then
        -- Broadcast the footstep event to all players
        net.Start("GoldSrcFootstepSound")
        net.WriteEntity(ply)
        net.WriteString(file)
        net.Broadcast()
	end
end

local function GoldSrcFootstepHook( ply, pos, foot, sound, volume, rf )
	if (!cvarEnabled:GetBool()) then return false end

	-- Player is on a ladder, skip the tracing stuff
    if ply:GetMoveType() == MOVETYPE_LADDER then
		local choice = matFootstepSounds["ladder"]
        PlayFootstep(ply, list, volume)

        return true
	elseif (ply:WaterLevel() > 0) then
		local choice = matFootstepSounds[MAT_SLOSH]
        PlayFootstep(ply, list, volume)

        return true
	end

    -- Make a trace hull to check for the surface below the player
    local traceData = { 
        start = pos, 
        endpos = Vector(pos.x, pos.y, pos.z-500),
		mins = Vector(-16, -16, 0),
		maxs = Vector( 16, 16, 71),
		filter = function(ent)
			return ent != ply -- ignore self
		end
	}

	local tRes = util.TraceHull(traceData)
	local texture = tRes.HitTexture -- Hit texture
	local matType = tRes.MatType -- Hit material type

	-- Check if there's a sound assigned to a specific texture
	-- otherwise ignore
	matType = texFootstepType[texture] or matType

    -- Get the list of sounds and choose a random one out of it.
    -- If there's no list with the given mat type, return the list for MAT_CONCRETE
	local choice = matFootstepSounds[matType] or matFootstepSounds[MAT_CONCRETE]

	PlayFootstep(ply, choice)

	return true -- Don't allow default footsteps, or other addon footsteps
end

if CLIENT then
    net.Receive("GoldSrcFootstepSound", function()
        local ply = net.ReadEntity()
        local choice = net.ReadString()

        if (ply != LocalPlayer()) then
            PlayFootstep(ply, choice)
        end
    end)
end

local function FallDamageHook(ply, speed)
	if cvarFallEnabled:GetBool() then
		local mp_falldamage = GetConVar("mp_falldamage"):GetBool()
		local dmg = 10

		if mp_falldamage then
			dmg = math.max( 0, math.ceil( 0.2418 * speed - 125 ) )
		end

		ply:EmitSound("GoldSrc.Footsteps.FallDmg" )

		local dmginfo = DamageInfo()
		dmginfo:SetDamage(dmg)
		dmginfo:SetDamageType(DMG_FALL)
		dmginfo:SetAttacker(ply)
		
		ply:TakeDamageInfo(dmginfo)

		return 0
	end
end

-- Hooks
hook.Add( "PlayerFootstep", "GoldSrcCustomFootstep", GoldSrcFootstepHook)
hook.Add( "GetFallDamage", "GoldSrcFallDamage", FallDamageHook)

-- Overriding other sounds that do not have hooks...


local wadeSounds = {
	"player/gsrc/footsteps/wade1.wav",
	"player/gsrc/footsteps/wade2.wav",
	"player/gsrc/footsteps/wade3.wav",
	"player/gsrc/footsteps/wade4.wav"
}

if (cvarEnabled:GetBool()) then

	sound.Add( {
		name = "Player.Swim",
		channel = CHAN_STATIC,
		volume = 0.5,
		level = SNDLVL_NORM,
		sound = wadeSounds
	} )

	sound.Add( {
		name = "Player.Wade",
		channel = CHAN_BODY,
		volume = 0.25,
		level = SNDLVL_75dB,
		sound = wadeSounds
	} )

	sound.Add( {
		name = "BaseEntity.EnterWater",
		channel = CHAN_AUTO,
		volume = 0.35,
		level = SNDLVL_70dB,
		sound = wadeSounds
	} )

	sound.Add( {
		name = "BaseEntity.ExitWater",
		channel = CHAN_AUTO,
		volume = 0.3,
		level = SNDLVL_70dB,
		sound = wadeSounds
	} )

	sound.Add( {
		name = "Physics.WaterSplash",
		channel = CHAN_AUTO,
		volume = 0.3,
		level = SNDLVL_70dB,
		sound = wadeSounds
	} )
end
