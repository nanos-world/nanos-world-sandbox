LightGun = ToolGunSingleTarget.Inherit("LightGun")

-- Tool Name, Category and Image
LightGun.name = "Light"
LightGun.category = "spawners"
LightGun.image = "package://sandbox/Client/Media/Tools/LightGun.webp"

-- Tool Tutorials
LightGun.tutorials = {
	{ key = "LeftClick",	text = "spawn light" },
	{ key = "Undo",			text = "undo last spawn" },
}

-- Tool Tips
LightGun.tips = {
	"too many lights can cause severe lag"
}

-- Tool Trace Debug Settings
LightGun.debug_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	show_crosshair = false,
	show_preview_mesh = true,
	preview_mesh = "nanos-world::SM_Lamp",
	preview_mesh_scale = Vector(1, 1, 1),
	preview_mesh_offset = Vector(0, 0, 0),
	preview_mesh_rotation = Rotator(90, 0, 0),
}


-- Overrides ToolGunSingleTarget method
function LightGun:OnLocalPlayerTarget(location, relative_location, relative_rotation, normal, entity)
	-- Calls remote to spawn the Light
	self:CallRemoteEvent("SpawnLight", location, relative_location, relative_rotation, normal, entity)
end