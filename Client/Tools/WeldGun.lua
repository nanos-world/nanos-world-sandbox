WeldGun = ToolGunDoubleTarget.Inherit("WeldGun")

-- Tool Name
WeldGun.name = "Weld Gun"

-- Tool Image
WeldGun.image = "package://sandbox/Client/Media/Tools/WeldGun.webp"

-- Tool Tutorials
WeldGun.tutorials = {
	{ key = "LeftClick",	text = "weld object" },
	{ key = "Undo",			text = "undo last weld" },
}

-- Tool Trace Debug Settings
WeldGun.debug_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	show_crosshair = true,
}


-- Overrides ToolGunSingleTarget method
function WeldGun:OnLocalPlayerTarget(targeting_first_to, targeting_first_relative_location, targeting_first_relative_rotation, targeting_second_to, targeting_second_location, targeting_second_rotation)
	-- Calls remote to weld
	self:CallRemoteEvent("Weld", targeting_first_to, targeting_second_to, targeting_second_location)
end