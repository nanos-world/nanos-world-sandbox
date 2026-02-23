ThrusterGun = ToolGunSingleTarget.Inherit("ThrusterGun")

-- Tool Info
ThrusterGun.name = "Thruster Gun"
ThrusterGun.image = "package://sandbox/Client/Media/Tools/ThrusterGun.webp"
ThrusterGun.category = "spawners"
ThrusterGun.description = "Spawns a thruster attached to objects to push them"

-- Tool Tutorials
ThrusterGun.tutorials = {
	{ key = "LeftClick",	text = "spawn thruster" },
	{ key = "Undo",			text = "undo last spawn" },
	{ key = "ContextMenu",	text = "thruster settings" },
}

-- Tool Trace Debug Settings
ThrusterGun.debug_trace = {
	collision_channel = CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	show_crosshair = false,
	show_preview_mesh = true,
	preview_mesh = "nanos-world::SM_Rocket_Thruster",
	preview_mesh_scale = Vector(0.5, 0.5, 0.5),
	preview_mesh_offset = Vector(0, 0, 0),
	preview_mesh_rotation = Rotator(180, 0, 0),
}

-- Tool Tips
ThrusterGun.tips = {
	"you can change the thruster's particle and sound in the Context Menu"
}

-- ThrusterGun Configuration
ThrusterGun.configs = {
	particle_asset = THRUSTER_ASSETS[math.random(#THRUSTER_ASSETS - 1) + 1].id,
	sound_asset = THRUSTER_SOUNDS[math.random(#THRUSTER_SOUNDS - 1) + 1].id,
	force = 100,
	active = true,
}

-- Context Menu Items when Picking Up this Tool
ThrusterGun.picked_context_menu_items = {
	{
		label = "particle",
		type = "select",
		options = THRUSTER_ASSETS,
		callback = function(value)
			ThrusterGun.configs.particle_asset = value
		end,
		value = function()
			return ThrusterGun.configs.particle_asset
		end,
	},
	{
		label = "sound",
		type = "select",
		options = THRUSTER_SOUNDS,
		callback = function(value)
			ThrusterGun.configs.sound_asset = value
		end,
		value = function()
			return ThrusterGun.configs.sound_asset
		end,
	},
	{
		label = "force",
		type = "range",
		min = 0, max = 1000,
		callback = function(value)
			ThrusterGun.configs.force = value
		end,
		value = function()
			return ThrusterGun.configs.force
		end,
	},
	{
		label = "start activated",
		type = "checkbox",
		callback = function(value)
			ThrusterGun.configs.active = value
		end,
		value = function()
			return ThrusterGun.configs.active
		end,
	},
}

-- Overrides ToolGunSingleTarget method
function ThrusterGun:OnLocalPlayerTarget(location, relative_location, relative_rotation, normal, entity)
	-- Call remote event to spawn the thruster
	self:CallRemoteEvent("SpawnThruster", location, relative_location, relative_rotation, normal, entity, ThrusterGun.configs)
end