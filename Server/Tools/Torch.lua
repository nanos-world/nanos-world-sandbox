function SpawnTorch(location, rotation)
	local torch = Item(location or Vector(), rotation or Rotator(), "nanos-world::SM_Torch")

	local light = Light(Vector(), Rotator(), Color(1, 0.7, 0.4), LightType.Point, 100, 1000)
	light:AttachTo(torch, AttachmentRule.SnapToTarget, "", true)
	light:SetRelativeLocation(Vector(0, 0, 75))

	local particle = Particle(Vector(), Rotator(), "nanos-world::P_Fire", false)
	particle:AttachTo(torch, AttachmentRule.SnapToTarget, "", true)
	particle:SetRelativeLocation(Vector(0, 0, 50))

	return torch
end

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "tools", "Torch", SpawnTorch)