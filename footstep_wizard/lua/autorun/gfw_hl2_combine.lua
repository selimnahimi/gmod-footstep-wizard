-- Please make this unique to avoid conflicts. On conflict, the last loaded pack will be used.
local pack_name = "Half-Life 2 - Combine Soldier"

-- nil if you don't want a custom icon
local pack_icon = ""

-- For all material types, check: https://wiki.facepunch.com/gmod/Enums/MAT
-- There HAS to be 2 sounds listed, one for the left, and one for the right foot.
local pack_sounds = {
    ["default"] = { -- Default sound if the material is unknown
        "NPC_CombineS.FootstepLeft",
        "NPC_CombineS.FootstepRight"
    }
}

GFW_RegisterFootstepPack(pack_name, pack_sounds, pack_icon)
