WheelGun = ToolGunSingleTarget.Inherit("WheelGun")

-- Tool Info
WheelGun.name = "Wheel Gun"
WheelGun.image = "package://sandbox/Client/Media/Tools/WheelGun.webp"
WheelGun.category = "spawners"
WheelGun.description = "Spawns a wheel attached to objects"

-- Tool Tutorials
WheelGun.tutorials = {
	{ key = "LeftClick",	text = "spawn wheel" },
	{ key = "Undo",			text = "undo last spawn" },
	{ key = "ContextMenu",	text = "wheel settings" },
}

-- Tool Trace Debug Settings
WheelGun.debug_trace = {
	collision_channel = CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	show_crosshair = false,
	show_preview_mesh = true,
	preview_mesh = "nanos-world::SM_Offroad_Tire",
	preview_mesh_scale = Vector(1, 1, 1),
	preview_mesh_offset = Vector(0, -20, 0),
	preview_mesh_rotation = Rotator(90, 0, 90),
}


-- WheelGun Configuration
WheelGun.force = 200 -- (x1000)
WheelGun.active = true
WheelGun.scale = 1
WheelGun.forward = true

-- Context Menu Items when Picking Up this Tool
WheelGun.picked_context_menu_items = {
	{
		id = "wheel_gun_force",
		type = "range",
		label = "force",
		min = 0, max = 10000,
		callback = function(value)
			WheelGun.force = value
		end,
		value = function()
			return WheelGun.force
		end,
	},
	{
		id = "wheel_gun_active",
		type = "checkbox",
		label = "start activated",
		callback = function(value)
			WheelGun.active = value
		end,
		value = function()
			return WheelGun.active
		end,
	},
	{
		id = "wheel_gun_forward",
		type = "checkbox",
		label = "forward",
		callback = function(value)
			WheelGun.forward = value
		end,
		value = function()
			return WheelGun.forward
		end
	},
	{
		id = "wheel_gun_scale",
		type = "range",
		label = "scale",
		min = 0.1, max = 3, step = 0.1,
		callback = function(value)
			value = value
			WheelGun.scale = value
			WheelGun.debug_trace.preview_mesh_scale = Vector(value, value, value)
		end,
		value = function()
			return WheelGun.scale
		end,
	},
}

-- Overrides ToolGunSingleTarget method
function WheelGun:OnLocalPlayerTarget(location, relative_location, relative_rotation, normal, entity)
	-- Call remote event to spawn the thruster
	self:CallRemoteEvent("SpawnWheel", location, relative_location, relative_rotation, normal, entity, WheelGun.force * 1000, WheelGun.active, WheelGun.forward, WheelGun.scale)
end