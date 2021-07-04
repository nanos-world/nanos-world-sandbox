function SpawnHFG(location, rotation)
	local weapon = Weapon(location or Vector(), rotation or Rotator(), "NanosWorld::SK_Portal_PortalGun")

	weapon:SetAmmoSettings(1024, 0)
	weapon:SetDamage(0)
	weapon:SetSpread(30)
	weapon:SetSightTransform(Vector(-10, 0, -20), Rotator(0, 0, 0))
	weapon:SetLeftHandTransform(Vector(25, 0, 0), Rotator(0, 60, 90))
	weapon:SetRightHandOffset(Vector(-10, -5, -5))
	weapon:SetHandlingMode(HandlingMode.DoubleHandedWeapon)
	weapon:SetCadence(0.2)
	weapon:SetSoundDry("NanosWorld::A_Pistol_Dry")
	weapon:SetSoundZooming("NanosWorld::A_AimZoom")
	weapon:SetSoundAim("NanosWorld::A_Rattle")
	weapon:SetSoundFire("NanosWorld::A_ShotgunBlast_Shot")
	weapon:SetAnimationCharacterFire("NanosWorld::AM_Mannequin_Sight_Fire")
	weapon:SetParticlesBarrel("NanosWorld::P_Weapon_BarrelSmoke")
	weapon:SetCrosshairSetting(CrosshairType.Square)
	weapon:SetUsageSettings(true, false)

	weapon:Subscribe("Fire", function(self, character)
		local control_rotation = character:GetControlRotation()
		local forward_vector = control_rotation:GetForwardVector()
		local spawn_location = self:GetLocation() + forward_vector * 200

		local grenade = Grenade(spawn_location, Rotator(), "NanosWorld::SM_Grenade_G67", "NanosWorld::P_Explosion_Dirt", "NanosWorld::A_Explosion_Large")
		grenade:SetScale(Vector(3, 3, 3))
		grenade:SetNetworkAuthority(character:GetPlayer())

		local trail_particle = Particle(spawn_location, Rotator(), "NanosWorld::P_Ribbon", false, true)
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
AddSpawnMenuItem("NanosWorld", "weapons", "HFG", SpawnHFG)
