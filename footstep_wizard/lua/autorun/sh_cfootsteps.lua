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

local footstep_packs = {}

local function GFW_ChooseFootstepPack(pack_name)
	if SERVER then
		PrintMessage(HUD_PRINTTALK, "trying to choose "..pack_name)
	end
	matFootstepSounds = footstep_packs[pack_name]['sounds']
end

local function GFW_Concommand_PackSelect(ply, cmd, args, argStr)
	GFW_ChooseFootstepPack(args[1])
end

local function GFW_Concommand_PackMenu(ply, cmd, args, argStr)
	surface.CreateFont("Font", {
		font = "Arial",
		extended = true,
		size = 20
	})	

    local DFrame = vgui.Create("DFrame") -- The name of the panel we don't have to parent it.
    -- DFrame:SetPos(100, 100) -- Set the position to 100x by 100y. 
	DFrame:Center() -- Centers the panel.
    DFrame:SetSize(500, 500) -- Set the size to 300x by 200y.
    DFrame:SetTitle("GarrysMod Footstep Wizard") -- Set the title in the top left to "Derma Frame".
    DFrame:MakePopup() -- Makes your mouse be able to move around.

	local layout = vgui.Create("DTileLayout", DFrame)
	layout:SetBaseSize(32) -- Tile size
	layout:Dock(FILL)

	layout:SetDrawBackground(true)
	layout:SetBackgroundColor(Color(0, 100, 100))
	layout:MakeDroppable("unique_name") -- Allows us to rearrange children
	
	for k, v in pairs ( footstep_packs ) do
		local DPanel = vgui.Create( "DPanel", layout )
		DPanel:SetPos( 0, 0 ) -- Set the position of the panel
		DPanel:SetSize( 200, 225 ) -- Set the size of the panel

		local DLabel = vgui.Create( "DLabel", DPanel )
		DLabel:SetPos( 5, 5 ) -- Set the position of the label
		DLabel:SetText( k ) --  Set the text of the label
		DLabel:SizeToContents() -- Size the label to fit the text in it
		DLabel:SetDark( 1 ) -- Set the colour of the text inside the label to a darker one
		
		local DermaImageButton = vgui.Create( "DImageButton", DPanel )
		DermaImageButton:SetText( k )
		DermaImageButton:SetSize( 200, 200 )
		DermaImageButton:SetPos( 0, 25 )				-- Set position
		-- DermaButton:SetSize( 16, 16 )			-- OPTIONAL: Use instead of SizeToContents() if you know/want to fix the size
		DermaImageButton:SetImage( "vgui/entities/weapon_laserdance" )	-- Set the material - relative to /materials/ directory
		DermaImageButton:SetKeepAspect( true )
		DermaImageButton:SetText(v['name'])
		function DermaImageButton:DoClick()
			RunConsoleCommand( "gfw_pack_select", v['name'] )
		end
		
	end


	-- Paint function w, h = how wide and tall it is.
	DFrame.Paint = function(self, w, h)
		-- Draws a rounded box with the color faded_black stored above.
		draw.RoundedBox(2, 0, 0, w, h, Color(0, 0, 0, 200))
		-- Draws text in the color white.
		--draw.SimpleText("Choose a Footstep Pack", "Font", 250, 50, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

concommand.Add("gfw_pack_select", GFW_Concommand_PackSelect)

if CLIENT then
	concommand.Add("gfw_pack_menu", GFW_Concommand_PackMenu)
end

function GFW_RegisterFootstepPack(pack_name, pack_sounds, pack_icon, custom_callback)
	if SERVER then
		PrintMessage(HUD_PRINTTALK, "[GFW] "..pack_name.." is registered")
	end
	
	customCallback = custom_callback

	footstep_packs[pack_name] = {
		['name'] = pack_name,
		['sounds'] = pack_sounds,
		['icon'] = pack_icon,
		['callback'] = custom_callback
	}
end

-- Certain textures have concrete properties BUT WE DONT WANT THAT >:(
-- Seriously having concrete footsteps on the SNOW on CS_OFFICE???
local texFootstepType = {
	["CS_OFFICE/SPHINX_SNOW_1"] = MAT_SNOW
}

local function PlayFootstep(ply, file, volume)
	if file == nil then return end
	-- PrintMessage(HUD_PRINTTALK, "playing ".. file)
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

	foot = foot + 1 -- indexing in lua starts from 1... what...

	-- Player is on a ladder, skip the tracing stuff
    if ply:GetMoveType() == MOVETYPE_LADDER then
		local choice = ChooseFootstep("ladder", foot) or ({"Ladder.StepLeft", "Ladder.StepRight"})[foot]
        PlayFootstep(ply, choice, volume)

        return true
	elseif (ply:WaterLevel() > 0) then
		local choice = matFootstepSounds[MAT_SLOSH][foot]
        PlayFootstep(ply, choice, volume)

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
	local choice = ChooseFootstepOrDefault(matType, foot)

	PlayFootstep(ply, choice)

	if customCallback != nil then
		customCallback(ply, pos, foot, choice, volume, rf, texture, matType)
	end

	return true -- Don't allow default footsteps, or other addon footsteps
end

function ChooseFootstep(matType, foot)
	return (matFootstepSounds[matType] or {nil, nil})[foot]
end

function ChooseFootstepOrDefault(matType, foot)
	return ChooseFootstep(matType, foot) or matFootstepSounds["default"][foot]
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

		local choice = (matFootstepSounds["falldmg"] or {"Player.FallDamage"})[1]
		
		ply:EmitSound(choice)

		local dmginfo = DamageInfo()
		dmginfo:SetDamage(dmg)
		dmginfo:SetDamageType(DMG_FALL)
		dmginfo:SetAttacker(ply)
		
		ply:TakeDamageInfo(dmginfo)

		return 0
	end
end

local function SetupMoveHook(ply, mvd, cmd)
	if mvd:KeyPressed(IN_JUMP) and ply:Alive() and ply:OnGround() then
		local choice = ChooseFootstep("jump", 1)
		PlayFootstep(ply, choice, 1)
	end
end

-- Hooks
hook.Add( "PlayerFootstep", "GoldSrcCustomFootstep", GoldSrcFootstepHook)
hook.Add( "GetFallDamage", "GoldSrcFallDamage", FallDamageHook)
hook.Add( "SetupMove", "GFWSetupMove", SetupMoveHook)

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
		name = "Wade.StepLeft",
		channel = CHAN_BODY,
		volume = 0.25,
		level = SNDLVL_75dB,
		sound = wadeSounds
	} )

	sound.Add( {
		name = "Wade.StepRight",
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
