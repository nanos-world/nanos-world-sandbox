function SpawnTorch(location, rotation)
	local torch = Item(location or Vector(), rotation or Rotator(), "NanosWorld::SM_Torch")

	local light = Light(Vector(), Rotator(), Color(1, 0.7, 0.4), LightType.Point, 100, 1000)
	light:AttachTo(torch)
	light:SetRelativeLocation(Vector(0, 0, 75))

	local particle = Particle(Vector(), Rotator(), "NanosWorld::P_Fire", false)
	particle:AttachTo(torch)
	particle:SetRelativeLocation(Vector(0, 0, 50))

	torch:SetValue("Light", light)
	torch:SetValue("Particle", particle)

	torch:Subscribe("Destroy", function(item)
		local _particle = item:GetValue("Particle")
		if (_particle and _particle:IsValid()) then _particle:Destroy() end

		local _light = item:GetValue("Light")
		if (_light and _light:IsValid()) then _light:Destroy() end
	end)

	return torch
end

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("NanosWorld", "tools", "Torch", SpawnTorch)