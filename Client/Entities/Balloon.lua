Balloon = Prop.Inherit("Balloon")

Balloon.name = "Balloon"
Balloon.image = "assets://nanos-world/Thumbnails/SM_Balloon_01.jpg"
Balloon.category = "uncategorized"

-- Balloons Assets
Balloon.assets = {
	{ id = "nanos-world::SM_Balloon_01",	name = "SM_Balloon_01",		image = "assets://nanos-world/Thumbnails/SM_Balloon_01.jpg"		},
	{ id = "nanos-world::SM_Balloon_02",	name = "SM_Balloon_02",		image = "assets://nanos-world/Thumbnails/SM_Balloon_02.jpg"		},
	{ id = "nanos-world::SM_Balloon_03",	name = "SM_Balloon_03",		image = "assets://nanos-world/Thumbnails/SM_Balloon_03.jpg"		},
	{ id = "nanos-world::SM_Balloon_04",	name = "SM_Balloon_04",		image = "assets://nanos-world/Thumbnails/SM_Balloon_04.jpg"		},
	{ id = "nanos-world::SM_Balloon_05",	name = "SM_Balloon_05",		image = "assets://nanos-world/Thumbnails/SM_Balloon_05.jpg"		},
	{ id = "nanos-world::SM_Balloon_06",	name = "SM_Balloon_06",		image = "assets://nanos-world/Thumbnails/SM_Balloon_06.jpg"		},
	{ id = "nanos-world::SM_Balloon_07",	name = "SM_Balloon_07",		image = "assets://nanos-world/Thumbnails/SM_Balloon_07.jpg"		},
	{ id = "nanos-world::SM_Balloon_Dog",	name = "SM_Balloon_Dog",	image = "assets://nanos-world/Thumbnails/SM_Balloon_Dog.jpg"	},
	{ id = "nanos-world::SM_Poop",			name = "SM_Poop",			image = "assets://nanos-world/Thumbnails/SM_Poop.jpg"			},
	{ id = "nanos-world::SM_Emoji_01",		name = "SM_Emoji_01",		image = "assets://nanos-world/Thumbnails/SM_Emoji_01.jpg"		},
	{ id = "nanos-world::SM_Emoji_02",		name = "SM_Emoji_02",		image = "assets://nanos-world/Thumbnails/SM_Emoji_02.jpg"		},
	{ id = "nanos-world::SM_Emoji_03",		name = "SM_Emoji_03",		image = "assets://nanos-world/Thumbnails/SM_Emoji_03.jpg"		},
	{ id = "nanos-world::SM_Emoji_04",		name = "SM_Emoji_04",		image = "assets://nanos-world/Thumbnails/SM_Emoji_04.jpg" 		},
}

-- Context Menu Items when selecting this Entity
Balloon.selected_context_menu_items = {
	{
		id = "balloon_asset",
		type = "select_image",
		label = "mesh",
		options = Balloon.assets,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetCustomMesh", value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetMesh()
		end,
	},
	{
		id = "balloon_force",
		type = "range",
		label = "force",
		min = -100000,
		max = 200000,
		auto_update_label = true,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetCustomForce", value)
		end,
		value = function()
			return math.ceil(ContextMenu.selected_entity:GetForce().Z)
		end,
	}
}

function Balloon:OnDestroy()
	-- Avoiding spawning particles and sound if it's too far
	if (self:GetDistanceFromCamera() > 5000) then return end

	local balloon_location = self:GetLocation()

	Sound(balloon_location, "nanos-world::A_Balloon_Pop", false, true, SoundType.SFX, 1, 1)
	Particle(balloon_location + Vector(0, 0, 30), Rotator(), "nanos-world::P_OmnidirectionalBurst", true, true):SetParameterColor("Color", self:GetMaterialColorParameter("Tint"))
end

Balloon.Subscribe("Destroy", Balloon.OnDestroy)