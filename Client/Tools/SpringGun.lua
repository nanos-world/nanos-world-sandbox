SpringGun = ToolGunDoubleTarget.Inherit("SpringGun")

-- Tool Info
SpringGun.name = "Spring Gun"
SpringGun.image = "package://sandbox/Client/Media/Tools/SpringGun.webp"
SpringGun.category = "constrainers"
SpringGun.description = "Creates a spring joint between two objects"

-- Tool Tutorials
SpringGun.tutorials = {
	{ key = "LeftClick",	text = "attach spring" },
	{ key = "Undo",			text = "undo last spring" },
	{ key = "ContextMenu",	text = "spring settings" },
}

-- Tool Trace Debug Settings
SpringGun.debug_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	show_crosshair = true,
}

-- Spring Gun Configuration
SpringGun.configs = {
	linear_strength = 800,
	angular_strength = 200,
}

-- Context Menu Items when Picking Up this Tool
SpringGun.picked_context_menu_items = {
	{
		id = "spring_gun_linear_strength",
		type = "range",
		label = "linear strength",
		min = 0, max = 10000,
		callback = function(value)
			SpringGun.configs.linear_strength = value
		end,
		value = function()
			return SpringGun.configs.linear_strength
		end,
	},
	{
		id = "spring_gun_angular_strength",
		type = "range",
		label = "angular strength",
		min = 0, max = 1000,
		callback = function(value)
			SpringGun.configs.angular_strength = value
		end,
		value = function()
			return SpringGun.configs.angular_strength
		end,
	},
}


-- Overrides ToolGunSingleTarget method
function SpringGun:OnLocalPlayerTarget(targeting_first_to, targeting_first_relative_location, targeting_first_relative_rotation, targeting_second_to, targeting_second_location, targeting_second_rotation)
	-- Calls remote to attach rope
	self:CallRemoteEvent("SpringAttach", targeting_first_to, targeting_first_relative_location, targeting_second_to, targeting_second_location, SpringGun.configs)
end