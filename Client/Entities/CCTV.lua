-- Event from server to set a SceneCapture in a CCTV
function SpawnAndSetCameraOnProp(prop, camera)
	local sc = SceneCapture(camera:GetLocation(), Rotator(), 650, 400)
	sc:AttachTo(camera, AttachmentRule.SnapToTarget, "", 0)

	prop:SetMaterialFromSceneCapture(sc, 1)
	prop:SetMaterialColorParameter("Emissive", Color(5, 5, 5))
end

Events.Subscribe("SpawnCCTV", SpawnAndSetCameraOnProp)

Prop.Subscribe("Spawn", function(prop)
	local camera = prop:GetValue("CCTV")

	if (camera) then
		SpawnAndSetCameraOnProp(prop, camera)
	end
end)

AddSpawnMenuItem("nanos-world", "entities", "CCTV", "CCTV", "assets///NanosWorld/Thumbnails/SM_Camera.jpg", "uncategorized")