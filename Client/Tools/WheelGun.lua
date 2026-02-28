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

-- Balloon Configuration
WheelGun.configs = {
	asset =				PersistentConfigSystem.GetConfig("WheelGun", "asset")				or "nanos-world::SM_Offroad_Tire",
	force =				PersistentConfigSystem.GetConfig("WheelGun", "force")				or 1000, -- (x1000)
	start_activated =	PersistentConfigSystem.GetConfig("WheelGun", "start_activated")		or true,
	scale =				1,
	forward =			true,
}

-- Tool Trace Debug Settings
WheelGun.debug_trace = {
	collision_channel = CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	show_crosshair = false,
	show_preview_mesh = true,
	preview_mesh = WheelGun.configs.asset,
	preview_mesh_scale = Vector(1, 1, 1),
	preview_mesh_offset = WHEELS_CONFIG[WheelGun.configs.asset].offset,
	preview_mesh_rotation = WHEELS_CONFIG[WheelGun.configs.asset].direction:ToOrientationRotator(),
}

-- Context Menu Items when Picking Up this Tool
WheelGun.picked_context_menu_items = {
	{
		label = "mesh",
		type = "select_image",
		options = WHEELS_ASSETS,
		callback = function(value)
			WheelGun.configs.asset = value
			WheelGun.debug_trace.preview_mesh = value
			WheelGun.debug_trace.preview_mesh_offset = WHEELS_CONFIG[value].offset
			WheelGun.debug_trace.preview_mesh_rotation = WHEELS_CONFIG[value].direction:ToOrientationRotator()
			PersistentConfigSystem.SaveConfig("WheelGun", "asset", value)
		end,
		value = function()
			return WheelGun.configs.asset
		end,
	},
	{
		label = "force",
		type = "range",
		min = 0, max = 10000,
		callback = function(value)
			WheelGun.configs.force = value
			PersistentConfigSystem.SaveConfig("WheelGun", "force", value)
		end,
		value = function()
			return WheelGun.configs.force
		end,
	},
	{
		label = "start activated",
		type = "checkbox",
		callback = function(value)
			WheelGun.configs.start_activated = value
			PersistentConfigSystem.SaveConfig("WheelGun", "start_activated", value)
		end,
		value = function()
			return WheelGun.configs.start_activated
		end,
	},
	{
		label = "forward",
		type = "checkbox",
		callback = function(value)
			WheelGun.configs.forward = value
		end,
		value = function()
			return WheelGun.configs.forward
		end
	},
	{
		label = "scale",
		type = "range",
		min = 0.1, max = 3, step = 0.1,
		callback = function(value)
			WheelGun.configs.scale = value
			WheelGun.debug_trace.preview_mesh_scale = Vector(value, value, value)
		end,
		value = function()
			return WheelGun.configs.scale
		end,
	},
}


-- Overrides ToolGunSingleTarget method
function WheelGun:OnLocalPlayerTarget(location, relative_location, relative_rotation, normal, entity)
	-- Call remote event to spawn the thruster
	self:CallRemoteEvent("SpawnWheel", location, relative_location, relative_rotation, normal, entity, WheelGun.configs)
end