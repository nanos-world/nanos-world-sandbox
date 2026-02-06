RopeGun = ToolGunDoubleTarget.Inherit("RopeGun")

-- Tool Info
RopeGun.name = "Rope Gun"
RopeGun.image = "package://sandbox/Client/Media/Tools/RopeGun.webp"
RopeGun.description = "Tie two objects together with a rope constraint"

-- Tool Tutorials
RopeGun.tutorials = {
	{ key = "LeftClick",	text = "attach rope" },
	{ key = "Undo",			text = "undo last rope" },
}

-- Tool Trace Debug Settings
RopeGun.debug_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	show_crosshair = true,
}


-- Overrides ToolGunSingleTarget method
function RopeGun:OnLocalPlayerTarget(targeting_first_to, targeting_first_relative_location, targeting_first_relative_rotation, targeting_second_to, targeting_second_location, targeting_second_rotation)
	-- Calls remote to attach rope
	self:CallRemoteEvent("RopeAttach", targeting_first_to, targeting_first_relative_location, targeting_second_to, targeting_second_location)
end