Crowbar = Melee.Inherit("Crowbar")

function Crowbar:Constructor(location, rotation)
	self.Super:Constructor(location or Vector(), rotation or Rotator(), "nanos-world::SM_Crowbar_01", CollisionType.Normal, true, HandlingMode.SingleHandedMelee)
	self:SetScale(Vector(1.5, 1.5, 1.5))
	self:AddAnimationCharacterUse("nanos-world::AM_Mannequin_Melee_Slash_Attack")
	self:SetDamageSettings(0.3, 0.5)
	self:SetCooldown(1.0)
	self:SetBaseDamage(40)
	self:SetImpactSound(SurfaceType.Flesh, "nanos-world::A_Punch_Cue")
	self:SetImpactSound(SurfaceType.Default, "nanos-world::A_MetalHeavy_Impact_MS")
end