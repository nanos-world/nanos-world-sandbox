Balloon = Prop.Inherit("Balloon")

Balloon.name = "Balloon"
Balloon.image = "assets://nanos-world/Thumbnails/SM_Balloon_01.jpg"
Balloon.category = "objects"

-- Balloons Assets
Balloon.assets = {
	{ id = "nanos-world::SM_Balloon_01",		name = "SM_Balloon_01",			image = "assets://nanos-world/Thumbnails/SM_Balloon_01.jpg"			},
	{ id = "nanos-world::SM_Balloon_02",		name = "SM_Balloon_02",			image = "assets://nanos-world/Thumbnails/SM_Balloon_02.jpg"			},
	{ id = "nanos-world::SM_Balloon_03",		name = "SM_Balloon_03",			image = "assets://nanos-world/Thumbnails/SM_Balloon_03.jpg"			},
	{ id = "nanos-world::SM_Balloon_04",		name = "SM_Balloon_04",			image = "assets://nanos-world/Thumbnails/SM_Balloon_04.jpg"			},
	{ id = "nanos-world::SM_Balloon_05",		name = "SM_Balloon_05",			image = "assets://nanos-world/Thumbnails/SM_Balloon_05.jpg"			},
	{ id = "nanos-world::SM_Balloon_06",		name = "SM_Balloon_06",			image = "assets://nanos-world/Thumbnails/SM_Balloon_06.jpg"			},
	{ id = "nanos-world::SM_Balloon_07",		name = "SM_Balloon_07",			image = "assets://nanos-world/Thumbnails/SM_Balloon_07.jpg"			},
	{ id = "nanos-world::SM_Balloon_Dog",		name = "SM_Balloon_Dog",		image = "assets://nanos-world/Thumbnails/SM_Balloon_Dog.jpg"		},
	{ id = "nanos-world::SM_Poop",				name = "SM_Poop",				image = "assets://nanos-world/Thumbnails/SM_Poop.jpg"				},
	{ id = "nanos-world::SM_Error",				name = "SM_Error",				image = "assets://nanos-world/Thumbnails/SM_Error.jpg"				},
	{ id = "nanos-world::SM_Mannequin_Head",	name = "SM_Mannequin_Head",		image = "assets://nanos-world/Thumbnails/SM_Mannequin_Head.jpg"		},
	{ id = "nanos-world::SM_TungTungTungSahur",	name = "SM_TungTungTungSahur",	image = "assets://nanos-world/Thumbnails/SM_TungTungTungSahur.jpg"	},
	{ id = "nanos-world::SM_Emoji_03",			name = "SM_Emoji_03",			image = "assets://nanos-world/Thumbnails/SM_Emoji_03.jpg"			},
	{ id = "nanos-world::SM_Emoji_04",			name = "SM_Emoji_04",			image = "assets://nanos-world/Thumbnails/SM_Emoji_04.jpg"			},
	{ id = "nanos-world::SM_Emoji_06",			name = "SM_Emoji_06",			image = "assets://nanos-world/Thumbnails/SM_Emoji_06.jpg"			},
	{ id = "nanos-world::SM_Emoji_09",			name = "SM_Emoji_09",			image = "assets://nanos-world/Thumbnails/SM_Emoji_09.jpg"			},
	{ id = "nanos-world::SM_Emoji_15",			name = "SM_Emoji_15",			image = "assets://nanos-world/Thumbnails/SM_Emoji_15.jpg"			},
	{ id = "nanos-world::SM_Emoji_20",			name = "SM_Emoji_20",			image = "assets://nanos-world/Thumbnails/SM_Emoji_20.jpg"			},
	{ id = "nanos-world::SM_Emoji_33",			name = "SM_Emoji_33",			image = "assets://nanos-world/Thumbnails/SM_Emoji_33.jpg"			},
	{ id = "nanos-world::SM_Emoji_36",			name = "SM_Emoji_36",			image = "assets://nanos-world/Thumbnails/SM_Emoji_36.jpg"			},
	{ id = "nanos-world::SM_Emoji_38",			name = "SM_Emoji_38",			image = "assets://nanos-world/Thumbnails/SM_Emoji_38.jpg"			},
	{ id = "nanos-world::SM_Emoji_39",			name = "SM_Emoji_39",			image = "assets://nanos-world/Thumbnails/SM_Emoji_39.jpg"			},
	{ id = "nanos-world::SM_Emoji_40",			name = "SM_Emoji_40",			image = "assets://nanos-world/Thumbnails/SM_Emoji_40.jpg"			},
	{ id = "nanos-world::SM_Emoji_45",			name = "SM_Emoji_45",			image = "assets://nanos-world/Thumbnails/SM_Emoji_45.jpg"			},
	{ id = "nanos-world::SM_Emoji_47",			name = "SM_Emoji_47",			image = "assets://nanos-world/Thumbnails/SM_Emoji_47.jpg"			},
	{ id = "nanos-world::SM_Emoji_57",			name = "SM_Emoji_57",			image = "assets://nanos-world/Thumbnails/SM_Emoji_57.jpg"			},
	{ id = "nanos-world::SM_Emoji_59",			name = "SM_Emoji_59",			image = "assets://nanos-world/Thumbnails/SM_Emoji_59.jpg"			},
	{ id = "nanos-world::SM_Emoji_61",			name = "SM_Emoji_61",			image = "assets://nanos-world/Thumbnails/SM_Emoji_61.jpg"			},
	{ id = "nanos-world::SM_Emoji_63",			name = "SM_Emoji_63",			image = "assets://nanos-world/Thumbnails/SM_Emoji_63.jpg"			},
	{ id = "nanos-world::SM_Emoji_68",			name = "SM_Emoji_68",			image = "assets://nanos-world/Thumbnails/SM_Emoji_68.jpg"			},
	{ id = "nanos-world::SM_Emoji_71",			name = "SM_Emoji_71",			image = "assets://nanos-world/Thumbnails/SM_Emoji_71.jpg"			},
	{ id = "nanos-world::SM_Emoji_77",			name = "SM_Emoji_77",			image = "assets://nanos-world/Thumbnails/SM_Emoji_77.jpg"			},
	{ id = "nanos-world::SM_Emoji_80",			name = "SM_Emoji_80",			image = "assets://nanos-world/Thumbnails/SM_Emoji_80.jpg"			},
}

-- Context Menu Items when selecting this Entity
Balloon.selected_context_menu_items = {
	{
		label = "mesh",
		type = "select_image",
		options = Balloon.assets,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetCustomMesh", value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetMesh()
		end,
	},
	{
		label = "force",
		type = "range",
		min = -100,
		max = 200,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetCustomForce", value * 1000)
		end,
		value = function()
			return math.ceil(ContextMenu.selected_entity:GetForce().Z / 1000)
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