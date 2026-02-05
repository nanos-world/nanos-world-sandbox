ElasticGun = ToolGunDoubleTarget.Inherit("ElasticGun")

-- Tool Name
ElasticGun.name = "Elastic Gun"

-- Tool Image
ElasticGun.image = "package://sandbox/Client/Tools/ElasticGun.webp"

-- Tool Tutorials
ElasticGun.tutorials = {
	{ key = "LeftClick",	text = "attach elastic" },
	{ key = "Undo",			text = "undo last elastic" },
}

-- Tool Trace Debug Settings
ElasticGun.debug_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	show_crosshair = true,
}

-- Elastic Gun Configuration
ElasticGun.restitution = 0.75
ElasticGun.stiffness = 30
ElasticGun.damping = 1

-- Context Menu Items when picking up this Tool
ElasticGun.picked_context_menu_items = {
	{
		id = "elastic_gun_restitution",
		type = "range",
		label = "restitution",
		min = 0,
		max = 100,
		auto_update_label = true,
		callback = function(value)
			ElasticGun.restitution = value / 100
		end,
		value = function()
			return ElasticGun.restitution * 100
		end
	},
	{
		id = "elastic_gun_stiffness",
		type = "range",
		label = "stiffness",
		min = 0,
		max = 1000,
		auto_update_label = true,
		callback = function(value)
			ElasticGun.stiffness = value
		end,
		value = function()
			return ElasticGun.stiffness
		end
	},
	{
		id = "elastic_gun_damping",
		type = "range",
		label = "damping",
		min = 0,
		max = 100,
		auto_update_label = true,
		callback = function(value)
			ElasticGun.damping = value
		end,
		value = function()
			return ElasticGun.damping
		end
	},
}

-- Overrides ToolGunSingleTarget method
function ElasticGun:OnLocalPlayerTarget(targeting_first_to, targeting_first_relative_location, targeting_second_to, targeting_second_location)
	-- Calls remote to attach rope
	self:CallRemoteEvent("ElasticAttach", targeting_first_to, targeting_first_relative_location, targeting_second_to, targeting_second_location, ElasticGun.restitution, ElasticGun.stiffness, ElasticGun.damping)
end