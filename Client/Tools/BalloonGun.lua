BalloonGun = ToolGun.Inherit("BalloonGun")

-- Tool Name
BalloonGun.name = "Balloon"

-- Tool Image
BalloonGun.image = "package://sandbox/Client/Tools/BalloonGun.webp"

-- Tool Tutorials
BalloonGun.tutorials = {
	{ key = "LeftClick", text = "spawn balloon" },
	{ key = "Undo", text = "undo spawn" },
	{ key = "ContextMenu", text = "balloon settings" },
}

-- Tool Crosshair Trace Debug Settings
BalloonGun.crosshair_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	color_entity = Color.GREEN,
	color_no_entity = Color.RED,
}

-- Balloon Configuration
BalloonGun.asset = "nanos-world::SM_Balloon_01"
BalloonGun.force = 100000
BalloonGun.max_length = 100
BalloonGun.randomness = 0.15


-- Overrides ToolGun method
function BalloonGun:OnLocalPlayerFire(shooter)
	local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle)

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

-- Overrides ToolGun method
function BalloonGun:OnLocalPlayerPickUp(character)
	-- Sets some notification when grabbing the Balloon Tool
	AddNotification("BALLOONS_POP", "balloons will start to pop if they reach a very high height", 5000, 5000)

	-- Adds an entry to Context Menu
	ContextMenu.AddItems("balloon_tool", "balloon gun", {
		{ id = "baloon_asset", type = "select_image", label = "Asset", callback_event = "SelectBalloonAsset", selected = BalloonGun.asset, options = {
			{ id = "nanos-world::SM_Balloon_01", name = "SM_Balloon_01", image = "assets://nanos-world/Thumbnails/SM_Balloon_01.jpg" },
			{ id = "nanos-world::SM_Balloon_02", name = "SM_Balloon_02", image = "assets://nanos-world/Thumbnails/SM_Balloon_02.jpg" },
			{ id = "nanos-world::SM_Balloon_03", name = "SM_Balloon_03", image = "assets://nanos-world/Thumbnails/SM_Balloon_03.jpg" },
			{ id = "nanos-world::SM_Balloon_04", name = "SM_Balloon_04", image = "assets://nanos-world/Thumbnails/SM_Balloon_04.jpg" },
			{ id = "nanos-world::SM_Balloon_05", name = "SM_Balloon_05", image = "assets://nanos-world/Thumbnails/SM_Balloon_05.jpg" },
			{ id = "nanos-world::SM_Balloon_06", name = "SM_Balloon_06", image = "assets://nanos-world/Thumbnails/SM_Balloon_06.jpg" },
			{ id = "nanos-world::SM_Balloon_07", name = "SM_Balloon_07", image = "assets://nanos-world/Thumbnails/SM_Balloon_07.jpg" },
			{ id = "nanos-world::SM_Balloon_Trump", name = "SM_Balloon_Trump", image = "assets://nanos-world/Thumbnails/SM_Balloon_Trump.jpg" },
			{ id = "nanos-world::SM_Balloon_Dog", name = "SM_Balloon_Dog", image = "assets://nanos-world/Thumbnails/SM_Balloon_Dog.jpg" },
			{ id = "nanos-world::SM_Poop", name = "SM_Poop", image = "assets://nanos-world/Thumbnails/SM_Poop.jpg" },
			{ id = "nanos-world::SM_Emoji_01", name = "SM_Emoji_01", image = "assets://nanos-world/Thumbnails/SM_Emoji_01.jpg" },
			{ id = "nanos-world::SM_Emoji_02", name = "SM_Emoji_02", image = "assets://nanos-world/Thumbnails/SM_Emoji_02.jpg" },
			{ id = "nanos-world::SM_Emoji_03", name = "SM_Emoji_03", image = "assets://nanos-world/Thumbnails/SM_Emoji_03.jpg" },
			{ id = "nanos-world::SM_Emoji_04", name = "SM_Emoji_04", image = "assets://nanos-world/Thumbnails/SM_Emoji_04.jpg" },
		}},
		{ id = "baloon_force", type = "range", label = "Force", callback_event = "SetBalloonForce", min = -100000, max = 200000, value = BalloonGun.force, auto_update_label = true },
		{ id = "baloon_max_length", type = "range", label = "Length", callback_event = "SetBalloonMaxLength", min = 0, max = 1000, value = BalloonGun.max_length, auto_update_label = true },
		{ id = "baloon_randomness", type = "range", label = "Randomness", callback_event = "SetBalloonRandomness", min = 0, max = 100, value = BalloonGun.randomness * 100, auto_update_label = true },
	})
end

-- Overrides ToolGun method
function BalloonGun:OnLocalPlayerDrop(character)
	ContextMenu.RemoveItems("balloon_tool")
end

-- Subscribes for ContextMenu changes
MainHUD:Subscribe("SelectBalloonAsset", function(asset)
	BalloonGun.asset = asset
end)

-- Subscribes for ContextMenu changes
MainHUD:Subscribe("SetBalloonForce", function(force)
	BalloonGun.force = force
end)

-- Subscribes for ContextMenu changes
MainHUD:Subscribe("SetBalloonMaxLength", function(max_length)
	BalloonGun.max_length = max_length
end)

-- Subscribes for ContextMenu changes
MainHUD:Subscribe("SetBalloonRandomness", function(randomness)
	BalloonGun.randomness = randomness / 100
end)