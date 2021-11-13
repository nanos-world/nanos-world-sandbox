function SpawnBouncyBall(location, rotation, asset_pack, category, asset)
	-- Spawns a Ball Prop
	local bouncy_ball = Prop(location or Vector(), (rotation or Rotator()) + Rotator(0, 90, 0), "nanos-world::SM_Sphere")
	bouncy_ball:SetPhysicalMaterial("nanos-world::PM_RubberBouncy")

	local scale = math.random(5, 10)
	bouncy_ball:SetScale(Vector(scale, scale, scale) /10)

	local color = Color.RandomPalette()
	bouncy_ball:SetMaterialColorParameter("Tint", color * 1000)
	bouncy_ball:SetMaterialScalarParameter("Roughness", 0)

	return bouncy_ball
end

AddSpawnMenuItem("nanos-world", "entities", "BouncyBall", SpawnBouncyBall)