function SpawnDestructable(location, rotation, asset)
	-- Spawns Destructable
	local static_mesh = StaticMesh((location or Vector()) + Vector(0, 0, 70), (rotation or Rotator()) + Rotator(0, 90, 0), asset)
	return static_mesh
end


-- Adds this to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "entities", "GC_Ball", function(location, rotation) return SpawnDestructable(location, rotation, "NanosWorld/Props/VRShapes/GC_Ball") end)
AddSpawnMenuItem("nanos-world", "entities", "GC_Cube_01", function(location, rotation) return SpawnDestructable(location, rotation, "NanosWorld/Props/VRShapes/GC_Cube_01") end)
AddSpawnMenuItem("nanos-world", "entities", "GC_Cube_02", function(location, rotation) return SpawnDestructable(location, rotation, "NanosWorld/Props/VRShapes/GC_Cube_02") end)
AddSpawnMenuItem("nanos-world", "entities", "GC_Cube_03", function(location, rotation) return SpawnDestructable(location, rotation, "NanosWorld/Props/VRShapes/GC_Cube_03") end)
AddSpawnMenuItem("nanos-world", "entities", "GC_Pyramid", function(location, rotation) return SpawnDestructable(location, rotation, "NanosWorld/Props/VRShapes/GC_Pyramid") end)