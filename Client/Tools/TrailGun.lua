TrailGun = ToolGun.Inherit("TrailGun")

-- Tool Name
TrailGun.name = "Trail Gun"

-- Tool Image
TrailGun.image = "package://sandbox/Client/Tools/TrailGun.webp"

-- Tool Tutorials
TrailGun.tutorials = {
	{ key = "LeftClick", text = "spawn trail" },
	{ key = "Undo", text = "undo spawn" },
}

-- Tool Crosshair Trace Debug Settings
TrailGun.crosshair_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	color_entity = Color.GREEN,
	color_no_entity = Color.RED,
}


-- Overrides ToolGun method
function TrailGun:OnLocalPlayerFire(shooter)
	-- Makes a trace 10000 units ahead to spawn the balloon
	local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn)

	-- If hit some object, then spawns a trail on attached it
	if (trace_result.Success and trace_result.Entity and not trace_result.Entity:HasAuthority()) then
		local trail_rotation = (trace_result.Normal * -1):Rotation() + Rotator(90, 0, 0)
		local relative_location, relative_rotation = NanosMath.RelativeTo(trace_result.Location, trail_rotation, trace_result.Entity)

		self:CallRemoteEvent("SpawnTrail", trace_result.Location, relative_location, relative_rotation, trace_result.Normal, trace_result.Entity)
	else
		-- If didn't hit anything, plays a negative sound
		SoundInvalidAction:Play()
	end
end