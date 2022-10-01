function SpawnTorch(location, rotation)
	local torch = Melee(location or Vector(), rotation or Rotator(), "nanos-world::SM_Torch")
	torch:AddAnimationCharacterUse("nanos-world::AM_Mannequin_Torch_Attack")
	torch:SetImpactSound(SurfaceType.Flesh, "nanos-world::A_Punch_Cue")
	torch:SetDamageSettings(0.5, 0.25)
	torch:SetCooldown(1.5)
	torch:SetBaseDamage(25)

	local light = Light(Vector(), Rotator(), Color(1, 0.7, 0.4), LightType.Point, 100, 1000)
	light:AttachTo(torch, AttachmentRule.SnapToTarget, "", 0)
	light:SetRelativeLocation(Vector(0, 0, 75))

	local particle = Particle(Vector(), Rotator(), "nanos-world::P_Fire", false)
	particle:AttachTo(torch, AttachmentRule.SnapToTarget, "", 0)
	particle:SetRelativeLocation(Vector(0, 0, 50))

	return torch
end

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "weapons", "Torch", SpawnTorch)