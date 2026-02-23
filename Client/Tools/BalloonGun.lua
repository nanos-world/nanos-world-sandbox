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
BalloonGun.configs = {
	asset =					PersistentConfigSystem.GetConfig("BalloonGun",	"asset")				or "nanos-world::SM_Balloon_01",
	force =					PersistentConfigSystem.GetConfig("BalloonGun",	"force")				or 100, -- (x1000)
	max_length =			PersistentConfigSystem.GetConfig("BalloonGun",	"max_length")			or 100,
	length_randomness =		PersistentConfigSystem.GetConfig("BalloonGun",	"length_randomness")	or 15, -- %
}

-- Tool Trace Debug Settings
BalloonGun.debug_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	show_crosshair = true,
	show_preview_mesh = true,
	preview_mesh = BalloonGun.configs.asset,
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
		options = BALLOON_ASSETS,
		callback = function(value)
			BalloonGun.configs.asset = value
			BalloonGun.debug_trace.preview_mesh = value
			PersistentConfigSystem.SaveConfig("BalloonGun", "asset", value)
		end,
		value = function()
			return BalloonGun.configs.asset
		end,
	},
	{
		label = "force",
		type = "range",
		min = -100,
		max = 200,
		callback = function(value)
			BalloonGun.configs.force = value
			PersistentConfigSystem.SaveConfig("BalloonGun", "force", value)
		end,
		value = function()
			return BalloonGun.configs.force
		end,
	},
	{
		label = "length",
		type = "range",
		min = 0,
		max = 1000,
		callback = function(value)
			BalloonGun.configs.max_length = value
			PersistentConfigSystem.SaveConfig("BalloonGun", "max_length", value)
		end,
		value = function()
			return BalloonGun.configs.max_length
		end,
	},
	{
		label = "length randomness",
		type = "range",
		min = 0,
		max = 100,
		callback = function(value)
			BalloonGun.configs.length_randomness = value
			PersistentConfigSystem.SaveConfig("BalloonGun", "length_randomness", value)
		end,
		value = function()
			return BalloonGun.configs.length_randomness
		end,
	},
}


-- Overrides ToolGunSingleTarget method
function BalloonGun:OnLocalPlayerTarget(location, relative_location, relative_rotation, normal, entity)
	-- Calls remote to spawn the Balloon
	self:CallRemoteEvent("SpawnBalloon", location, relative_location, relative_rotation, normal, entity, BalloonGun.configs)
end