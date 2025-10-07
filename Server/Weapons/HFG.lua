HFG = Weapon.Inherit("HFG")

function HFG:Constructor(location, rotation)
	self.Super:Constructor(location or Vector(), rotation or Rotator(), "nanos-world::SK_DC15S")

	self:SetAmmoSettings(1024, 0)
	self:SetDamage(0)
	self:SetSpread(30)
	self:SetSightTransform(Vector(-6, 0, -5), Rotator(0, 0, 0))
	self:SetLeftHandTransform(Vector(19, 0, 5), Rotator(0, 60, 90))
	self:SetRightHandOffset(Vector(-7, 0, -1))
	self:SetHandlingMode(HandlingMode.DoubleHandedWeapon)
	self:SetCadence(0.2)
	self:SetSoundDry("nanos-world::A_Pistol_Dry")
	self:SetSoundZooming("nanos-world::A_AimZoom")
	self:SetSoundAim("nanos-world::A_Rattle")
	self:SetSoundFire("nanos-world::A_ShotgunBlast_Shot")
	self:SetAnimationCharacterFire("nanos-world::AM_Mannequin_Sight_Fire")
	self:SetParticlesBarrel("nanos-world::P_Weapon_BarrelSmoke")
	self:SetCrosshairMaterial("nanos-world::MI_Crosshair_Square")
	self:SetUsageSettings(true, false)
end

function HFG:OnFire(character)
	local control_rotation = character:GetControlRotation()
	local forward_vector = control_rotation:GetForwardVector()
	local spawn_location = self:GetLocation() + Vector(0, 0, 25) + forward_vector * 50

	local grenade = Grenade(spawn_location, Rotator(), "nanos-world::SM_Grenade_G67", "nanos-world::P_Explosion_Dirt", "nanos-world::A_Explosion_Large")
	grenade:SetScale(Vector(3, 3, 3))

	local trail_particle = Particle(spawn_location, Rotator(), "nanos-world::P_Ribbon", false, true)
	trail_particle:SetParameterColor("Color", Color.RandomPalette())
	trail_particle:SetParameterFloat("LifeTime", 1)
	trail_particle:SetParameterFloat("SpawnRate", 30)
	trail_particle:SetParameterFloat("Width", 1)
	trail_particle:AttachTo(grenade)
	grenade:SetValue("Particle", trail_particle)

	grenade:Subscribe("Hit", function(self, intensity)
		self:Explode()
	end)

	grenade:Subscribe("Destroy", function(self, intensity)
		self:GetValue("Particle"):SetLifeSpan(1)
	end)

	grenade:AddImpulse(forward_vector * 3000, true)
end

HFG.SubscribeRemote("Fire", HFG.OnFire)