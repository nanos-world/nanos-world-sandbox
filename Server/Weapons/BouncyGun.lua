
function SpawnBouncyGun(location, rotation)
	local weapon = Weapon(location or Vector(), rotation or Rotator(), "nanos-world::SK_FlareGun")

	weapon:SetAmmoSettings(9999, 0)
	weapon:SetDamage(0)
	weapon:SetRecoil(0)
	weapon:SetSightTransform(Vector(0, 0, -4), Rotator(0, 0, 0))
	weapon:SetLeftHandTransform(Vector(0, 1, -5), Rotator(0, 60, 100))
	weapon:SetRightHandOffset(Vector(-25, -5, 0))
	weapon:SetHandlingMode(HandlingMode.SingleHandedWeapon)
	weapon:SetCadence(0.05)
	weapon:SetSoundDry("nanos-world::A_Pistol_Dry")
	weapon:SetSoundZooming("nanos-world::A_AimZoom")
	weapon:SetSoundAim("nanos-world::A_Rattle")
	weapon:SetSoundFire("nanos-world::A_Whoosh")
	weapon:SetAnimationCharacterFire("nanos-world::A_Mannequin_Sight_Fire_Pistol")
	weapon:SetParticlesBarrel("nanos-world::P_Weapon_BarrelSmoke")
	weapon:SetCrosshairMaterial("nanos-world::MI_Crosshair_Square")
	weapon:SetUsageSettings(true, false)

	weapon:Subscribe("Fire", function(self, character)
		local control_rotation = character:GetControlRotation()
		local forward_vector = control_rotation:GetForwardVector()
		local spawn_location = self:GetLocation() + forward_vector * 100

		local prop = SpawnBouncyBall(spawn_location, Rotator())
		prop:SetLifeSpan(10)
		prop:AddImpulse(forward_vector * 3000, true)
	end)

	return weapon
end

-- Adds this weapon to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "weapons", "BouncyGun", SpawnBouncyGun)
