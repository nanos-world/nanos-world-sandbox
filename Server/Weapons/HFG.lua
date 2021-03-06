function SpawnHFG(location, rotation)
	local weapon = Weapon(location or Vector(), rotation or Rotator(), "nanos-world::SK_Portal_PortalGun")

	weapon:SetAmmoSettings(1024, 0)
	weapon:SetDamage(0)
	weapon:SetSpread(30)
	weapon:SetSightTransform(Vector(-10, 0, -20), Rotator(0, 0, 0))
	weapon:SetLeftHandTransform(Vector(25, 0, 0), Rotator(0, 60, 90))
	weapon:SetRightHandOffset(Vector(-10, -5, -5))
	weapon:SetHandlingMode(HandlingMode.DoubleHandedWeapon)
	weapon:SetCadence(0.2)
	weapon:SetSoundDry("nanos-world::A_Pistol_Dry")
	weapon:SetSoundZooming("nanos-world::A_AimZoom")
	weapon:SetSoundAim("nanos-world::A_Rattle")
	weapon:SetSoundFire("nanos-world::A_ShotgunBlast_Shot")
	weapon:SetAnimationCharacterFire("nanos-world::AM_Mannequin_Sight_Fire")
	weapon:SetParticlesBarrel("nanos-world::P_Weapon_BarrelSmoke")
	weapon:SetCrosshairSetting(CrosshairType.Square)
	weapon:SetUsageSettings(true, false)

	weapon:Subscribe("Fire", function(self, character)
		local control_rotation = character:GetControlRotation()
		local forward_vector = control_rotation:GetForwardVector()
		local spawn_location = self:GetLocation() + forward_vector * 200

		local grenade = Grenade(spawn_location, Rotator(), "nanos-world::SM_Grenade_G67", "nanos-world::P_Explosion_Dirt", "nanos-world::A_Explosion_Large")
		grenade:SetScale(Vector(3, 3, 3))
		grenade:SetNetworkAuthority(character:GetPlayer())

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
			Timer.SetTimeout(function(particle)
				particle:Destroy()
			end, 1000, self:GetValue("Particle"))
		end)

		grenade:AddImpulse(forward_vector * 3000, true)
	end)

	return weapon
end

-- Adds this weapon to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "weapons", "HFG", SpawnHFG)
