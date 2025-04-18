LightGun = ToolGun.Inherit("LightGun")

-- Tool Name
LightGun.name = "Light"

-- Tool Image
LightGun.image = "package://sandbox/Client/Tools/LightGun.webp"

-- Tool Tutorials
LightGun.tutorials = {
	{ key = "LeftClick", text = "spawn light" },
	{ key = "Undo", text = "undo spawn" },
}

-- Tool Crosshair Trace Debug Settings
LightGun.crosshair_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	color_entity = Color.GREEN,
	color_no_entity = Color.RED,
}


-- Overrides ToolGun method
function LightGun:OnLocalPlayerFire(shooter)
	local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn)

	if (trace_result.Success) then
		local distance_trace_object = Vector()
		if (trace_result.Entity) then
			-- If hit an entity, then calculates the offset distance from the Hit and the Object
			distance_trace_object = (trace_result.Entity:GetLocation() - trace_result.Location) / trace_result.Entity:GetScale()
		end

		-- Calls remote to spawn the Light
		self:CallRemoteEvent("SpawnLight", trace_result.Location, trace_result.Normal, trace_result.Entity, distance_trace_object)
	else
		-- If didn't hit anything, plays a negative sound
		SoundInvalidAction:Play()
	end
end

-- Overrides ToolGun method
function LightGun:OnLocalPlayerPickUp(character)
	-- Sets some notification when grabbing the Light Tool
	AddNotification("LIGHTS_PERFORMANCE", "too many lights can cause severe lag", 5000, 5000)
end