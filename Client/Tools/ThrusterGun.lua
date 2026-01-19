ThrusterGun = ToolGun.Inherit("ThrusterGun")

-- Tool Name
ThrusterGun.name = "Thruster Gun"

-- Tool Image
ThrusterGun.image = "package://sandbox/Client/Tools/ThrusterGun.webp"

-- Tool Tutorials
ThrusterGun.tutorials = {
	{ key = "LeftClick",	text = "spawn thruster" },
	{ key = "Undo",			text = "undo spawn" },
	{ key = "ContextMenu",	text = "thruster settings" },
}

-- Tool Crosshair Trace Debug Settings
ThrusterGun.crosshair_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	color_entity = Color.GREEN,
	color_no_entity = Color.RED,
}

-- Tool Tips
ThrusterGun.tips = {
	"you can change the thruster's particle and sound in the Context Menu"
}

-- ThrusterGun Configuration
ThrusterGun.particle_asset = Thruster.assets_list[math.random(#Thruster.assets_list)].id
ThrusterGun.sound_asset = Thruster.sounds_list[math.random(#Thruster.sounds_list)].id
ThrusterGun.force = 100000

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
}

-- Overrides ToolGun methods
function ThrusterGun:OnLocalPlayerFire(shooter)
	-- Makes a trace 10000 units ahead to spawn the balloon
	local trace_result = TraceFor(10000, ThrusterGun.crosshair_trace.collision_channel)

	-- If hit some object, then spawns a thruster on attached it
	if (trace_result.Success and trace_result.Entity and not trace_result.Entity:HasAuthority()) then
		local thruster_rotation = (trace_result.Normal * -1):Rotation()
		local relative_location, relative_rotation = NanosMath.RelativeTo(trace_result.Location, thruster_rotation, trace_result.Entity)

		self:CallRemoteEvent("SpawnThruster", trace_result.Location, relative_location, relative_rotation, trace_result.Normal, trace_result.Entity, ThrusterGun.particle_asset, ThrusterGun.sound_asset, ThrusterGun.force)
	else
		-- If didn't hit anything, plays a negative sound
		SoundInvalidAction:Play()
	end
end