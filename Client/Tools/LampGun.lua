LampGun = ToolGun.Inherit("LampGun")

-- Tool Name
LampGun.name = "Lamp"

-- Tool Image
LampGun.image = "package://sandbox/Client/Tools/LampGun.webp"

-- Tool Tutorials
LampGun.tutorials = {
	{ key = "LeftClick", text = "spawn lamp" },
	{ key = "Undo", text = "undo spawn" },
}

-- Tool Crosshair Trace Debug Settings
LampGun.crosshair_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	color_entity = Color.GREEN,
	color_no_entity = Color.RED,
}


-- Overrides ToolGun method
function LampGun:OnLocalPlayerFire(shooter)
	local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn)

	if (trace_result.Success) then
		local relative_location = nil
		local relative_rotation = nil

		if (trace_result.Entity) then
			relative_location, relative_rotation = NanosMath.RelativeTo(trace_result.Location, trace_result.Normal:Rotation(), trace_result.Entity)
		end

		-- Calls remote to spawn the Lamp
		self:CallRemoteEvent("SpawnLamp", trace_result.Location, relative_location, relative_rotation, trace_result.Normal, trace_result.Entity)
	else
		-- If didn't hit anything, plays a negative sound
		SoundInvalidAction:Play()
	end
end