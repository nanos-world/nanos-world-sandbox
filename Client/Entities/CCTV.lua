CCTV = Prop.Inherit("CCTV")

CCTV.name = "CCTV"
CCTV.image = "assets://nanos-world/Thumbnails/SM_Camera.jpg"
CCTV.category = "uncategorized"

function CCTV:OnSpawn()
	local camera = self:GetValue("Camera")
	local sc = SceneCapture(camera:GetLocation(), Rotator(), 650, 400, 0.016)
	sc:AttachTo(camera, AttachmentRule.SnapToTarget, "", 0)

	self:SetMaterialFromSceneCapture(sc, 1)
	self:SetMaterialColorParameter("Emissive", Color(2, 2, 2))
	self:SetMaterialScalarParameter("Roughness", 0.25)
end

CCTV.Subscribe("Spawn", CCTV.OnSpawn)