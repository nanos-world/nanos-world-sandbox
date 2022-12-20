Trail = Prop.Inherit("Trail")

function Trail:Constructor(hit_location, relative_location, relative_rotation, direction, entity)
	-- Calculates the Trail Rotation to spawn it
	local rotation = (direction * -1):Rotation() + Rotator(90, 0, 0)

	-- Spawns a Trail Prop
	self.Super:Constructor(hit_location, Rotator(), "nanos-world::SM_CupC", CollisionType.NoCollision, true, GrabMode.Disabled)

	self.color = Color.RandomPalette()
	self:SetMaterialColorParameter("Tint", self.color)

	-- Spawns a Particle and attaches it to the trail
	local particle = Particle(hit_location, Rotator(), "nanos-world::P_Ribbon", false, true)
	particle:SetParameterColor("Color", self.color)
	particle:SetParameterFloat("LifeTime", 2)
	particle:SetParameterFloat("SpawnRate", 60)
	particle:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)
	particle:SetRelativeLocation(rotation:RotateVector(direction * 10))

	-- Attaches with the relative locations provided by the client
	self:AttachTo(entity, AttachmentRule.SnapToTarget, "", 0)
	self:SetRelativeLocation(relative_location)
	self:SetRelativeRotation(relative_rotation)
end