BouncyBall = Prop.Inherit("BouncyBall")

function BouncyBall:Constructor(location, rotation)
	-- CHAMAR SUPER COM . CRASHA KAKAKA
	self.Super:Constructor(location or Vector(), (rotation or Rotator()) + Rotator(0, 90, 0), "nanos-world::SM_Sphere")

	self:SetPhysicalMaterial("nanos-world::PM_RubberBouncy")

	local scale = math.random(5, 10)
	self:SetScale(Vector(scale, scale, scale) /10)

	local color = Color.RandomPalette()
	self:SetMaterialColorParameter("Tint", color * 1000)
	self:SetMaterialScalarParameter("Roughness", 0)
end