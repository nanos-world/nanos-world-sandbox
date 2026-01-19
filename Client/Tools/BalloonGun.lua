BalloonGun = ToolGun.Inherit("BalloonGun")

-- Tool Name
BalloonGun.name = "Balloon Gun"

-- Tool Image
BalloonGun.image = "package://sandbox/Client/Tools/BalloonGun.webp"

-- Tool Tutorials
BalloonGun.tutorials = {
	{ key = "LeftClick",	text = "spawn balloon" },
	{ key = "Undo",			text = "undo spawn" },
	{ key = "ContextMenu",	text = "balloon settings" },
}

-- Tool Crosshair Trace Debug Settings
BalloonGun.crosshair_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	color_entity = Color.GREEN,
	color_no_entity = Color.RED,
}

-- Tool Tips
BalloonGun.tips = {
	"you can change the balloons mesh and color in the Context Menu",
	"balloons will start to pop if they reach a very high height",
}

-- Balloon Configuration
BalloonGun.asset = Balloon.assets[math.random(#Balloon.assets)]
BalloonGun.force = 100000
BalloonGun.max_length = 100
BalloonGun.randomness = 0.15

-- Context Menu Items when picking up this Tool
BalloonGun.picked_context_menu_items = {
	{
		id = "balloon_gun_asset",
		type = "select_image",
		label = "mesh",
		options = Balloon.assets,
		callback = function(value)
			BalloonGun.asset = value
		end,
		value = function()
			return BalloonGun.asset
		end,
	},
	{
		id = "balloon_gun_force",
		type = "range",
		label = "force",
		min = -100000,
		max = 200000,
		auto_update_label = true,
		callback = function(value)
			BalloonGun.force = value
		end,
		value = function()
			return BalloonGun.force
		end,
	},
	{
		id = "balloon_gun_max_length",
		type = "range",
		label = "length",
		min = 0,
		max = 1000,
		auto_update_label = true,
		callback = function(value)
			BalloonGun.max_length = value
		end,
		value = function()
			return BalloonGun.max_length
		end,
	},
	{
		id = "balloon_gun_randomness",
		type = "range",
		label = "randomness",
		min = 0,
		max = 100,
		auto_update_label = true,
		callback = function(value)
			BalloonGun.randomness = value / 100
		end,
		value = function()
			return BalloonGun.randomness * 100
		end,
	},
}


-- Overrides ToolGun method
function BalloonGun:OnLocalPlayerFire(shooter)
	local trace_result = TraceFor(10000, BalloonGun.crosshair_trace.collision_channel)

	if (trace_result.Success) then
		local distance_trace_object = Vector()
		if (trace_result.Entity and not trace_result.Entity:HasAuthority()) then
			-- If hit an entity, then calculates the offset distance from the Hit and the Object
			distance_trace_object = (trace_result.Entity:GetLocation() - trace_result.Location) / trace_result.Entity:GetScale()
		end

		-- Calculate randomness
		local force_randomness = BalloonGun.force * BalloonGun.randomness
		local max_length_randomness = BalloonGun.max_length * BalloonGun.randomness

		local force = math.random() * force_randomness * 2 + (BalloonGun.force - force_randomness)
		local max_length = math.random() * max_length_randomness * 2 + (BalloonGun.max_length - max_length_randomness)

		-- Calls remote to spawn the Balloon
		self:CallRemoteEvent("SpawnBalloon", trace_result.Location, trace_result.Normal:Rotation(), force, max_length, trace_result.Entity, distance_trace_object, BalloonGun.asset)
	else
		-- If didn't hit anything, plays a negative sound
		SoundInvalidAction:Play()
	end
end