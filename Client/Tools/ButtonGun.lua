ButtonGun = ToolGunSingleTarget.Inherit("ButtonGun")

-- Tool Info
ButtonGun.name = "Button Gun"
ButtonGun.image = "assets://nanos-world/Thumbnails/SM_PushButton.jpg"
ButtonGun.category = "spawners"
ButtonGun.description = "Spawns a Button attached to objects"

-- Tool Tutorials
ButtonGun.tutorials = {
	{ key = "LeftClick",	text = "spawn Button" },
	{ key = "Undo",			text = "undo last spawn" },
	-- { key = "ContextMenu",	text = "Button settings" },
}

-- Tool Trace Debug Settings
ButtonGun.debug_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	show_crosshair = false,
	show_preview_mesh = true,
	preview_mesh = "nanos-world::SM_PushButton",
	preview_mesh_offset = Vector(0, 0, 0),
	preview_mesh_rotation = Rotator(90, 0, 180),
}


-- Overrides ToolGunSingleTarget method
function ButtonGun:OnLocalPlayerTarget(location, relative_location, relative_rotation, normal, entity)
	-- Call remote event to spawn the Button
	self:CallRemoteEvent("SpawnButton", location, relative_location, relative_rotation, normal, entity)
end