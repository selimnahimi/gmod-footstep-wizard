-- Please make this unique to avoid conflicts. On conflict, the last loaded pack will be used.
local pack_name = "Half-Life 2"

-- nil if you don't want a custom icon
local pack_icon = ""

-- For all material types, check: https://wiki.facepunch.com/gmod/Enums/MAT
-- There HAS to be 2 sounds listed, one for the left, and one for the right foot.
local pack_sounds = {
    ["default"] = { -- Default sound if the material is unknown
        "Concrete.StepLeft",
        "Concrete.StepRight"
    },
	[MAT_CONCRETE] = {
        "Concrete.StepLeft",
        "Concrete.StepRight"
    },
	[MAT_SNOW] = {
        "Snow.StepLeft",
        "Snow.StepRight"
    },
	[MAT_DIRT] = {
        "Dirt.StepLeft",
        "Dirt.StepRight"
    },
	[MAT_FOLIAGE] = {
        "Grass.StepLeft",
        "Grass.StepRight"
    },
	[MAT_GRASS] = {
        "Grass.StepLeft",
        "Grass.StepRight"
    },
	[MAT_SAND] = {
        "Sand.StepLeft",
        "Sand.StepRight"
    },
    [MAT_METAL] = {
        "SolidMetal.StepLeft",
        "SolidMetal.StepRight"
    },
    [MAT_TILE] = {
        "Tile.StepLeft",
        "Tile.StepRight"
    },
    [MAT_VENT] = {
        "MetalVent.StepLeft",
        "MetalVent.StepRight"
    },
    [MAT_GRATE] = {
        "MetalGrate.StepLeft",
        "MetalGrate.StepRight"
    },
    [MAT_SLOSH] = {
        "Mud.StepLeft",
        "Mud.StepRight"
    },
    [MAT_WOOD] = {
        "Wood.StepLeft",
        "Wood.StepRight"
    },
    ["ladder"] = {
        "Ladder.StepLeft",
        "Ladder.StepRight"
    },
--  [MAT_WOOD] = nil -- if you don't want a sound to play on a given surface
}

GFW_RegisterFootstepPack(pack_name, pack_sounds, pack_icon)
