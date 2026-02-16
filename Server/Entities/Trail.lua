Trail = Prop.Inherit("Trail")

ConfigureSpawnLimits("Trail", "Trails", Trail.GetCount, "max_trails")

function Trail:Constructor(hit_location, rotation, relative_location, relative_rotation, direction, entity)
	-- Spawns a Trail Prop
	self.Super:Constructor(hit_location, rotation, "nanos-world::SM_Jet_Thruster", CollisionType.NoCollision, true, GrabMode.Disabled)

	self:SetScale(Vector(0.3, 0.6, 0.6))

	self.color = Color.RandomPalette()
	self:SetMaterialColorParameter("Tint", self.color)

	-- Spawns a Particle and attaches it to the trail
	local particle = Particle(hit_location, Rotator(), "nanos-world::P_Ribbon", false, true)
	particle:SetParameterColor("Color", self.color)
	particle:SetParameterFloat("LifeTime", 2)
	particle:SetParameterFloat("SpawnRate", 60)
	particle:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)
	particle:SetRelativeLocation(rotation:UnrotateVector(direction * -15))

	-- Attaches with the relative locations provided by the client
	self:AttachTo(entity, AttachmentRule.SnapToTarget, "", 0)
	self:SetRelativeLocation(relative_location)
	self:SetRelativeRotation(relative_rotation + Rotator(180, 0, 0))
end