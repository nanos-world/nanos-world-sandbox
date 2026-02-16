BalloonGun = ToolGunSingleTarget.Inherit("BalloonGun")

-- Tool Info
BalloonGun.name = "Balloon Gun"
BalloonGun.category = "spawners"
BalloonGun.image = "package://sandbox/Client/Media/Tools/BalloonGun.webp"
BalloonGun.description = "Spawns a balloon you can attach to objects to lift them. Customize mesh, force, and string length"

-- Tool Tutorials
BalloonGun.tutorials = {
	{ key = "LeftClick",	text = "spawn balloon" },
	{ key = "Undo",			text = "undo last spawn" },
	{ key = "ContextMenu",	text = "balloon settings" },
}

-- Tool Tips
BalloonGun.tips = {
	"you can change the balloons mesh and color in the Context Menu",
	"balloons will start to pop if they reach a very high height",
}

-- Balloon Configuration
BalloonGun.asset = Balloon.assets[math.random(9)].id -- Only the 9 first balloons
BalloonGun.force = 100 -- (x1000)
BalloonGun.max_length = 100
BalloonGun.length_randomness = 0.15

-- Tool Trace Debug Settings
BalloonGun.debug_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	show_crosshair = true,
	show_preview_mesh = true,
	preview_mesh = BalloonGun.asset,
	preview_mesh_scale = Vector(1, 1, 1),
	preview_mesh_offset = Vector(0, 0, -50),
	preview_mesh_rotation = Rotator(),
	preview_mesh_rotation_fixed = true
}


-- Context Menu Items when picking up this Tool
BalloonGun.picked_context_menu_items = {
	{
		label = "mesh",
		type = "select_image",
		options = Balloon.assets,
		callback = function(value)
			BalloonGun.asset = value
			BalloonGun.debug_trace.preview_mesh = value
		end,
		value = function()
			return BalloonGun.asset
		end,
	},
	{
		label = "force",
		type = "range",
		min = -100,
		max = 200,
		callback = function(value)
			BalloonGun.force = value
		end,
		value = function()
			return BalloonGun.force
		end,
	},
	{
		label = "length",
		type = "range",
		min = 0,
		max = 1000,
		callback = function(value)
			BalloonGun.max_length = value
		end,
		value = function()
			return BalloonGun.max_length
		end,
	},
	{
		label = "length randomness",
		type = "range",
		min = 0,
		max = 100,
		callback = function(value)
			BalloonGun.length_randomness = value / 100
		end,
		value = function()
			return BalloonGun.length_randomness * 100
		end,
	},
}


-- Overrides ToolGunSingleTarget method
function BalloonGun:OnLocalPlayerTarget(location, relative_location, relative_rotation, normal, entity)
	-- Calculate randomness
	local force_randomness = BalloonGun.force * BalloonGun.length_randomness
	local max_length_randomness = BalloonGun.max_length * BalloonGun.length_randomness

	local force = (math.random() * force_randomness * 2 + (BalloonGun.force - force_randomness)) * 1000
	local max_length = math.random() * max_length_randomness * 2 + (BalloonGun.max_length - max_length_randomness)

	-- Calls remote to spawn the Balloon
	self:CallRemoteEvent("SpawnBalloon", location, relative_location, relative_rotation, normal, entity, force, max_length, BalloonGun.asset)
end