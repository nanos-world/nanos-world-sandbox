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
ThrusterGun.particle_asset = Thruster.assets_list[math.random(#Thruster.assets_list)].id
ThrusterGun.sound_asset = Thruster.sounds_list[math.random(#Thruster.sounds_list)].id
ThrusterGun.force = 100000
ThrusterGun.active = true

-- Context Menu Items when Picking Up this Tool
ThrusterGun.picked_context_menu_items = {
	{
		id = "thruster_gun_particle_asset",
		type = "select",
		label = "particle",
		options = Thruster.assets_list,
		callback = function(value)
			ThrusterGun.particle_asset = value
		end,
		value = function()
			return ThrusterGun.particle_asset
		end,
	},
	{
		id = "thruster_gun_sound_asset",
		type = "select",
		label = "sound",
		options = Thruster.sounds_list,
		callback = function(value)
			ThrusterGun.sound_asset = value
		end,
		value = function()
			return ThrusterGun.sound_asset
		end,
	},
	{
		id = "thruster_gun_force",
		type = "range",
		label = "force",
		min = 0, max = 1000000,
		auto_update_label = true,
		callback = function(value)
			ThrusterGun.force = value
		end,
		value = function()
			return ThrusterGun.force
		end,
	},
	{
		id = "thruster_gun_active",
		type = "checkbox",
		label = "start activated",
		callback = function(value)
			ThrusterGun.active = value
		end,
		value = function()
			return ThrusterGun.active
		end,
	},
}

-- Overrides ToolGunSingleTarget method
function ThrusterGun:OnLocalPlayerTarget(location, relative_location, relative_rotation, normal, entity)
	-- Call remote event to spawn the thruster
	self:CallRemoteEvent("SpawnThruster", location, relative_location, relative_rotation, normal, entity, ThrusterGun.particle_asset, ThrusterGun.sound_asset, ThrusterGun.force, ThrusterGun.active)
end