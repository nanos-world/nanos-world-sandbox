Knife = Melee.Inherit("Knife")

function Knife:Constructor(location, rotation)
	self.Super:Constructor(location or Vector(), rotation or Rotator(), "nanos-world::SM_M9", CollisionType.Normal, true, HandlingMode.SingleHandedMelee)
	self:AddAnimationCharacterUse("nanos-world::AM_Mannequin_Melee_Stab_Attack")
	self:SetDamageSettings(0.3, 0.3)
	self:SetCooldown(1.5)
	self:SetBaseDamage(50)
	self:SetImpactSound(SurfaceType.Default, "nanos-world::A_MetalHeavy_Impact_MS")
end