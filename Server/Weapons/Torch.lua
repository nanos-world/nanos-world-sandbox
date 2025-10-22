Torch = Melee.Inherit("Torch")

function Torch:Constructor(location, rotation)
	self.Super:Constructor(location or Vector(), rotation or Rotator(), "nanos-world::SM_Torch")
	self:AddAnimationCharacterUse("nanos-world::AM_Mannequin_Torch_Attack")
	self:SetImpactSound(SurfaceType.Flesh, "nanos-world::A_Punch_Cue")
	self:SetDamageSettings(0.5, 0.25)
	self:SetCooldown(1.5)
	self:SetBaseDamage(25)

	local light = Light(Vector(), Rotator(), Color(1, 0.7, 0.4), LightType.Point, 1, 1000)
	light:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)
	light:SetRelativeLocation(Vector(0, 0, 75))

	local particle = Particle(Vector(), Rotator(), "nanos-world::P_Fire", false)
	particle:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)
	particle:SetRelativeLocation(Vector(0, 0, 50))
end