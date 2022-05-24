-- Subscribes for Client Event for spawning a Trail
Events.Subscribe("SpawnTrail", function(player, hit_location, relative_location, relative_rotation, direction, entity)
	-- Calculates the Trail Rotation to spawn it
	local rotation = (direction * -1):Rotation() + Rotator(90, 0, 0)

	-- Spawns a Trail Prop
	local trail = Prop(hit_location, Rotator(), "nanos-world::SM_CupC", CollisionType.NoCollision, true, false)

	-- Spawns a Particle and attaches it to the trail
	local particle = Particle(hit_location, Rotator(), "nanos-world::P_Ribbon", false, true)

	local color = Color.RandomPalette()
	trail:SetMaterialColorParameter("Tint", color)

	particle:SetParameterColor("Color", color)
	particle:SetParameterFloat("LifeTime", 2)
	particle:SetParameterFloat("SpawnRate", 60)

	particle:AttachTo(trail, AttachmentRule.SnapToTarget, "", 0)
	particle:SetRelativeLocation(rotation:RotateVector(direction * 10))

	-- Attaches with the relative locations provided by the client
	trail:AttachTo(entity, AttachmentRule.SnapToTarget, "", 0)
	trail:SetRelativeLocation(relative_location)
	trail:SetRelativeRotation(relative_rotation)

	-- Updates the client's spawn history
	Events.CallRemote("SpawnedItem", player,  trail)

	Particle(hit_location, rotation + Rotator(90, 0, 0), "nanos-world::P_DirectionalBurst"):SetParameterColor("Color", color)
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "tools", "TrailTool", function() return SpawnGenericToolGun(Vector(), Rotator(), Color.VIOLET) end)
