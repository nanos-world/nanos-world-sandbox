TrailGun = ToolGunSingleTarget.Inherit("TrailGun")

-- Tool Name, Category and Image
TrailGun.name = "Trail Gun"
TrailGun.category = "spawners"
TrailGun.image = "package://sandbox/Client/Media/Tools/TrailGun.webp"

-- Tool Tutorials
TrailGun.tutorials = {
	{ key = "LeftClick",	text = "spawn trail" },
	{ key = "Undo",			text = "undo last spawn" },
}

-- Tool Trace Debug Settings
TrailGun.debug_trace = {
	collision_channel = CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	show_crosshair = false,
	show_preview_mesh = true,
	preview_mesh = "nanos-world::SM_Jet_Thruster",
	preview_mesh_scale = Vector(0.3, 0.6, 0.6),
	preview_mesh_offset = Vector(0, 0, 0),
	preview_mesh_rotation = Rotator(180, 0, 0),
}


-- Overrides ToolGunSingleTarget method
function TrailGun:OnLocalPlayerTarget(location, relative_location, relative_rotation, normal, entity)
	-- Calls remote to spawn the Trail
	self:CallRemoteEvent("SpawnTrail", location, relative_location, relative_rotation, normal, entity)
end