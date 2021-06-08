local MODE_HL1 = 0
local MODE_CS16 = 1
local MODE_OP4 = 2

local cvarEnabled = CreateConVar("gsrc_footsteps_enabled", "1", FCVAR_REPLICATE, "Enable/Disable the GoldSrc Footstep addon")

-- List for the last played footstep sound for each player
local playersLastFootstep = {

}

-- Set up footsteps for each material type
local matFootstepSounds = {
	[MAT_CONCRETE] = {
		"player/gsrc/footsteps/concrete1.wav",
		"player/gsrc/footsteps/concrete2.wav",
		"player/gsrc/footsteps/concrete3.wav",
		"player/gsrc/footsteps/concrete4.wav"},
	[MAT_SNOW] = {
		"player/gsrc/footsteps/pl_snow1.wav",
		"player/gsrc/footsteps/pl_snow2.wav",
		"player/gsrc/footsteps/pl_snow3.wav",
		"player/gsrc/footsteps/pl_snow4.wav",
		"player/gsrc/footsteps/pl_snow5.wav",
		"player/gsrc/footsteps/pl_snow6.wav",
	},
	[MAT_DIRT] = {
		"player/gsrc/footsteps/dirt1.wav",
		"player/gsrc/footsteps/dirt2.wav",
		"player/gsrc/footsteps/dirt3.wav",
		"player/gsrc/footsteps/dirt4.wav",
    },
	[MAT_FOLIAGE] = {
		"player/gsrc/footsteps/dirt1.wav",
		"player/gsrc/footsteps/dirt2.wav",
		"player/gsrc/footsteps/dirt3.wav",
		"player/gsrc/footsteps/dirt4.wav",
    },
	[MAT_GRASS] = {
		"player/gsrc/footsteps/dirt1.wav",
		"player/gsrc/footsteps/dirt2.wav",
		"player/gsrc/footsteps/dirt3.wav",
		"player/gsrc/footsteps/dirt4.wav",
    },
	[MAT_SAND] = {
		"player/gsrc/footsteps/dirt1.wav",
		"player/gsrc/footsteps/dirt2.wav",
		"player/gsrc/footsteps/dirt3.wav",
		"player/gsrc/footsteps/dirt4.wav",
    },
    [MAT_METAL] = {
        "player/gsrc/footsteps/metal1.wav",
        "player/gsrc/footsteps/metal2.wav",
        "player/gsrc/footsteps/metal3.wav",
        "player/gsrc/footsteps/metal4.wav",
    },
    [MAT_TILE] = {
        "player/gsrc/footsteps/tile1.wav",
        "player/gsrc/footsteps/tile2.wav",
        "player/gsrc/footsteps/tile3.wav",
        "player/gsrc/footsteps/tile4.wav",
    },
    [MAT_VENT] = {
        "player/gsrc/footsteps/metal1.wav",
        "player/gsrc/footsteps/metal2.wav",
        "player/gsrc/footsteps/metal3.wav",
        "player/gsrc/footsteps/metal4.wav",
    },
    [MAT_GRATE] = {
        "player/gsrc/footsteps/metalgrate1.wav",
        "player/gsrc/footsteps/metalgrate2.wav",
        "player/gsrc/footsteps/metalgrate3.wav",
        "player/gsrc/footsteps/metalgrate4.wav",
    },
    [MAT_SLOSH] = {
        "player/gsrc/footsteps/slosh1.wav",
        "player/gsrc/footsteps/slosh2.wav",
        "player/gsrc/footsteps/slosh3.wav",
        "player/gsrc/footsteps/slosh4.wav",
    },
    ["ladder"] = {
        "player/gsrc/footsteps/ladder1.wav",
        "player/gsrc/footsteps/ladder2.wav",
        "player/gsrc/footsteps/ladder3.wav",
        "player/gsrc/footsteps/ladder4.wav",
    }
}

-- Certain textures have concrete properties BUT WE DONT WANT THAT >:(
-- Seriously having concrete footsteps on the SNOW on CS_OFFICE???
local texFootstepType = {
	["CS_OFFICE/SPHINX_SNOW_1"] = MAT_SNOW
}

local function PlayFootstep(ply, file)
    ply:EmitSound( file, 75, 100, volume ) -- Play the footstep

	playersLastFootstep[ply] = file
end

-- Play a random footstep sound at a player
local function GetRandomFootstep(ply, list)
	local random
	local last = playersLastFootstep[ply]

	repeat
		random = list[ math.random( #list ) ]

		-- exit if the list has only 1 element to avoid infinite loop
		if (#list == 1) then break end
	until (last != random)

    return random
end

function GoldSrcFootstepHook( ply, pos, foot, sound, volume, rf )
	if (!cvarEnabled:GetBool()) then return false end

	-- Player is on a ladder, skip the tracing stuff
    if ply:GetMoveType() == MOVETYPE_LADDER then
        local list = matFootstepSounds["ladder"]
        PlayRandomFootstep(ply, list, volume)

        return true
	elseif (ply:WaterLevel() > 0) then
		local list = matFootstepSounds[MAT_SLOSH]
        PlayRandomFootstep(ply, list, volume)

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
	local list = matFootstepSounds[matType] or matFootstepSounds[MAT_CONCRETE]

    if SERVER then
        -- Broadcast the footstep to all players
        net.Start("GoldSrcFootstepSound")
        net.WriteEntity(ply)
        net.WriteString(GetRandomFootstep(ply, list))
        net.Broadcast()
    end
    if CLIENT or game.SinglePlayer() then
        -- Play the footstep locally
        local file = GetRandomFootstep(ply, list)
        PlayFootstep(ply, file)
    end
	return true -- Don't allow default footsteps, or other addon footsteps
end

hook.Add( "PlayerFootstep", "GoldSrcCustomFootstep", GoldSrcFootstepHook)

if CLIENT then
    net.Receive("GoldSrcFootstepSound", function()
        local ply = net.ReadEntity()
        local file = net.ReadString()

        if (ply != LocalPlayer()) then
            PlayFootstep(ply, file)
        end
    end)
end

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
