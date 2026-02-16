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

-- WheelGun Configuration
WheelGun.asset = "nanos-world::SM_Offroad_Tire"
WheelGun.force = 1000 -- (x1000)
WheelGun.active = true
WheelGun.scale = 1
WheelGun.forward = true

-- Tool Trace Debug Settings
WheelGun.debug_trace = {
	collision_channel = CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	show_crosshair = false,
	show_preview_mesh = true,
	preview_mesh = WheelGun.asset,
	preview_mesh_scale = Vector(1, 1, 1),
	preview_mesh_offset = Wheel.wheels_config[WheelGun.asset].offset,
	preview_mesh_rotation = Wheel.wheels_config[WheelGun.asset].direction:ToOrientationRotator(),
}

-- Context Menu Items when Picking Up this Tool
WheelGun.picked_context_menu_items = {
	{
		label = "mesh",
		type = "select_image",
		options = Wheel.wheels_assets,
		callback = function(value)
			WheelGun.asset = value
			WheelGun.debug_trace.preview_mesh = value
			WheelGun.debug_trace.preview_mesh_offset = Wheel.wheels_config[value].offset
			WheelGun.debug_trace.preview_mesh_rotation = Wheel.wheels_config[value].direction:ToOrientationRotator()
		end,
		value = function()
			return WheelGun.asset
		end,
	},
	{
		label = "force",
		type = "range",
		min = 0, max = 10000,
		callback = function(value)
			WheelGun.force = value
		end,
		value = function()
			return WheelGun.force
		end,
	},
	{
		label = "start activated",
		type = "checkbox",
		callback = function(value)
			WheelGun.active = value
		end,
		value = function()
			return WheelGun.active
		end,
	},
	{
		label = "forward",
		type = "checkbox",
		callback = function(value)
			WheelGun.forward = value
		end,
		value = function()
			return WheelGun.forward
		end
	},
	{
		label = "scale",
		type = "range",
		min = 0.1, max = 3, step = 0.1,
		callback = function(value)
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
	self:CallRemoteEvent("SpawnWheel", location, relative_location, relative_rotation, normal, entity, WheelGun.force * 1000, WheelGun.active, WheelGun.forward, WheelGun.scale, WheelGun.asset, Wheel.wheels_config[WheelGun.asset])
end