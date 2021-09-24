-- Subscribes for Client Event for spawning a Trail
Events.Subscribe("SpawnTrail", function(player, spawn_location, direction, entity)
	-- Calculates the Trail Rotation to spawn it
	local rotation = (direction * -1):Rotation() + Rotator(90, 0, 0)

	-- Spawns a Trail Prop
	local trail = Prop(spawn_location, rotation, "nanos-world::SM_CupC", CollisionType.NoCollision, true, false)

	-- Spawns a Particle and attaches it to the trail
	local particle = Particle(spawn_location, Rotator(), "nanos-world::P_Ribbon", false, true)

	local color = Color.RandomPalette()
	trail:SetMaterialColorParameter("Tint", color)

	particle:SetParameterColor("Color", color)
	particle:SetParameterFloat("LifeTime", 2)
	particle:SetParameterFloat("SpawnRate", 60)

	particle:AttachTo(trail, AttachmentRule.SnapToTarget, "", 0)
	particle:SetRelativeLocation(rotation:RotateVector(direction * 10))

	-- Sets the player to be the network authority immediately of this Prop (so he can immediately start applying the force on it - on the client side)
	trail:SetNetworkAuthority(player)

	-- Gets the relative location rotated to attach to the exact point the player aimed
	trail:AttachTo(entity, AttachmentRule.KeepWorld, "", 0)

	-- Updates the client's spawn history
	Events.CallRemote("SpawnedItem", player,  trail)

	Particle(spawn_location, rotation, "nanos-world::P_DirectionalBurst")
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "tools", "TrailTool", function() return SpawnGenericToolGun(Vector(), Rotator(), Color.VIOLET) end)
