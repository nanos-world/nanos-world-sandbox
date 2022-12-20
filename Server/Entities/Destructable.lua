function SpawnDestructable(location, rotation, asset)
	-- Spawns Destructable
	local static_mesh = StaticMesh((location or Vector()) + Vector(0, 0, 70), (rotation or Rotator()) + Rotator(0, 90, 0), asset)
	return static_mesh
end


-- Adds this to the Sandbox Spawn Menu
SpawnMenu.AddItem("entities", "GC_Ball", function(location, rotation) return SpawnDestructable(location, rotation, "/Script/GeometryCollectionEngine.GeometryCollection'/Game/NanosWorld/Props/VRShapes/SM_Ball_VR_GeometryCollection.SM_Ball_VR_GeometryCollection'") end)
SpawnMenu.AddItem("entities", "GC_Cube_01", function(location, rotation) return SpawnDestructable(location, rotation, "/Script/GeometryCollectionEngine.GeometryCollection'/Game/NanosWorld/Props/VRShapes/SM_Cube_VR_01_GeometryCollection.SM_Cube_VR_01_GeometryCollection'") end)
SpawnMenu.AddItem("entities", "GC_Cube_02", function(location, rotation) return SpawnDestructable(location, rotation, "/Script/GeometryCollectionEngine.GeometryCollection'/Game/NanosWorld/Props/VRShapes/SM_Cube_VR_02_GeometryCollection.SM_Cube_VR_02_GeometryCollection'") end)
SpawnMenu.AddItem("entities", "GC_Cube_03", function(location, rotation) return SpawnDestructable(location, rotation, "/Script/GeometryCollectionEngine.GeometryCollection'/Game/NanosWorld/Props/VRShapes/SM_Cube_VR_03_GeometryCollection.SM_Cube_VR_03_GeometryCollection'3") end)
SpawnMenu.AddItem("entities", "GC_Pyramid", function(location, rotation) return SpawnDestructable(location, rotation, "/Script/GeometryCollectionEngine.GeometryCollection'/Game/NanosWorld/Props/VRShapes/SM_Pyramid_VR_GeometryCollection.SM_Pyramid_VR_GeometryCollection'") end)