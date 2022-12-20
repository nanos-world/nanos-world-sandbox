RemoverGun = ToolGun.Inherit("RemoverGun")

-- Tool Name
RemoverGun.name = "Remover Gun"

-- Tool Image
RemoverGun.image = "package://sandbox/Client/Tools/RemoverGun.webp"

-- Tool Tutorials
RemoverGun.tutorials = {
	{ key = "LeftClick", text = "remove object" },
}

-- Tool Crosshair Trace Debug Settings
RemoverGun.crosshair_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	color_entity = Color.GREEN,
	color_no_entity = Color.RED,
}


-- Overrides ToolGun method
function RemoverGun:OnLocalPlayerFire(shooter)
	-- Makes a trace 10000 units ahead
	local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle)

	-- If hit an object, calls the server to destroy it
	if (trace_result.Success and trace_result.Entity and not trace_result.Entity:IsA(Character) and not trace_result.Entity:HasAuthority()) then
		Events.CallRemote("DestroyItem", trace_result.Entity)
	else
		-- If didn't hit anything, plays a negative sound
		SoundInvalidAction:Play()
	end
end