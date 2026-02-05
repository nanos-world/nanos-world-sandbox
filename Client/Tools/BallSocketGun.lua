BallSocketGun = ToolGunDoubleTarget.Inherit("BallSocketGun")

-- Tool Name
BallSocketGun.name = "Ball Socket Gun"

-- Tool Image
BallSocketGun.image = "package://sandbox/Client/Tools/BallSocketGun.webp"

-- Tool Tutorials
BallSocketGun.tutorials = {
	{ key = "LeftClick",	text = "attach ball socket" },
	{ key = "Undo",			text = "undo last ball socket" },
}

-- Tool Trace Debug Settings
BallSocketGun.debug_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	show_crosshair = true,
}


-- Overrides ToolGunSingleTarget method
function BallSocketGun:OnLocalPlayerTarget(targeting_first_to, targeting_first_relative_location, targeting_first_relative_rotation, targeting_second_to, targeting_second_location, targeting_second_rotation)
	-- Calls remote to attach rope
	self:CallRemoteEvent("BallSocketAttach", targeting_first_to, targeting_first_relative_location, targeting_second_to, targeting_second_location)
end