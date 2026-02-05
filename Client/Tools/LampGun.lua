LampGun = ToolGunSingleTarget.Inherit("LampGun")

-- Tool Name, Category and Image
LampGun.name = "Lamp"
LampGun.category = "spawners"
LampGun.image = "package://sandbox/Client/Tools/LampGun.webp"

-- Tool Tutorials
LampGun.tutorials = {
	{ key = "LeftClick", text = "spawn lamp" },
	{ key = "Undo", text = "undo spawn" },
}

-- Tool Trace Debug Settings
LampGun.debug_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	show_crosshair = false,
	show_preview_mesh = true,
	preview_mesh = "nanos-world::SM_Flashlight",
	preview_mesh_scale = Vector(1, 1, 1),
	preview_mesh_offset = Vector(0, 0, 0),
	preview_mesh_rotation = Rotator(0, 0, 0),
}


-- Overrides ToolGunSingleTarget method
function LampGun:OnLocalPlayerTarget(location, relative_location, relative_rotation, normal, entity)
	-- Calls remote to spawn the Lamp
	self:CallRemoteEvent("SpawnLamp", location, relative_location, relative_rotation, normal, entity)
end