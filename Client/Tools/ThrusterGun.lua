ThrusterGun = ToolGun.Inherit("ThrusterGun")

-- Tool Name
ThrusterGun.name = "Thruster Gun"

-- Tool Image
ThrusterGun.image = "package://sandbox/Client/Tools/ThrusterGun.webp"

-- Tool Tutorials
ThrusterGun.tutorials = {
	{ key = "LeftClick", text = "spawn thruster" },
	{ key = "Undo", text = "undo spawn" },
}

-- Tool Crosshair Trace Debug Settings
ThrusterGun.crosshair_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	color_entity = Color.GREEN,
	color_no_entity = Color.RED,
}


-- Overrides ToolGun method
function ThrusterGun:OnLocalPlayerFire(shooter)
	-- Makes a trace 10000 units ahead to spawn the balloon
	local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle)

	-- If hit some object, then spawns a thruster on attached it
	if (trace_result.Success and trace_result.Entity and not trace_result.Entity:IsA(Character) and not trace_result.Entity:HasAuthority()) then
		local thruster_rotation = (trace_result.Normal * -1):Rotation()
		local relative_location, relative_rotation = NanosMath.RelativeTo(trace_result.Location, thruster_rotation, trace_result.Entity)

		self:CallRemoteEvent("SpawnThruster", trace_result.Location, relative_location, relative_rotation, trace_result.Normal, trace_result.Entity)
	else
		-- If didn't hit anything, plays a negative sound
		SoundInvalidAction:Play()
	end
end