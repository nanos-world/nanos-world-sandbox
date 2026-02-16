SliderGun = ToolGunDoubleTarget.Inherit("SliderGun")

-- Tool Info
SliderGun.name = "Slider Gun"
SliderGun.image = "package://sandbox/Client/Media/Tools/SliderGun.webp"
SliderGun.category = "constrainers"
SliderGun.description = "Attach two objects together so they are connected by a slider constraint"

-- Tool Tutorials
SliderGun.tutorials = {
	{ key = "LeftClick",	text = "slider object" },
	{ key = "Undo",			text = "undo last slider" },
}

-- Tool Trace Debug Settings
SliderGun.debug_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	show_crosshair = true,
}

-- TODO Setting make visible or not


-- Overrides ToolGunDoubleTarget method
function SliderGun:OnLocalPlayerTarget(targeting_first_to, targeting_first_relative_location, targeting_first_relative_rotation, targeting_second_to, targeting_second_location, targeting_second_rotation)
	-- Calls remote to attach Slider
	self:CallRemoteEvent("SliderAttach", targeting_first_to, targeting_first_relative_location, targeting_second_to, targeting_second_location)
end