CCTV = Prop.Inherit("CCTV")

function CCTV:Constructor(location, rotation)
	-- Spawns a TV prop
	self.Super:Constructor(location, rotation + Rotator(0, 90, 0), "nanos-world::SM_TV")

	-- Spawns the Camera Prop
	self.camera = Prop(location + rotation:UnrotateVector(Vector(150, 0, 0)), rotation, "nanos-world::SM_Camera")

	-- Spawns a Cable
	self.cable = Cable(location)
	self.cable:SetLinearLimits(ConstraintMotion.Limited, ConstraintMotion.Limited, ConstraintMotion.Limited, 10000, 0, true, 10000, 100)
	self.cable:AttachStartTo(self.camera, Vector(-85, 0, 0))
	self.cable:AttachEndTo(self, Vector(0, 0, 10))
	self.cable:SetMaterial("nanos-world::M_Default_Masked_Lit")
	self.cable:SetMaterialColorParameter("Tint", Color.BLACK)
	self.cable:SetRenderingSettings(5, 4, 1)

	-- Sets this so we can access through Client
	self:SetValue("Camera", self.camera, true)
end

function CCTV:OnDestroy()
	-- Destroys the Camera when I get destroyed
	local camera_prop = self.camera
	if (camera_prop and camera_prop:IsValid()) then
		camera_prop:Destroy()
	end
end

CCTV.Subscribe("Destroy", CCTV.OnDestroy)