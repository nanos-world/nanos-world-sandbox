Thruster = Prop.Inherit("Thruster")

function Thruster:OnSpawn()
	local location = self:GetLocation()

	local sound = Sound(location, "nanos-world::A_VR_WorldMove_Loop_01", false, false, SoundType.SFX, 0.25, math.random(10) / 100 + 1)
	sound:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)

	-- Spawns a Particle and attaches it to the thruster
	local particle = Particle(location, Rotator(), "nanos-world::P_Fire", false, true)
	particle:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)
	particle:SetRelativeLocation(Vector(-40, 0, 0))
end

Thruster.Subscribe("Spawn", Thruster.OnSpawn)