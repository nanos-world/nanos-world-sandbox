-- Subscribes for Client Event for spawning a Thruster
Events.Subscribe("SpawnThruster", function(player, spawn_location, direction, entity)
	-- Calculates the Thruster Rotation to spawn it
	local rotation = (direction * -1):Rotation()

	-- Spawns a Thruster Prop
	local thruster = Prop(spawn_location, rotation, "nanos-world::SM_Jet_Thruster", CollisionType.NoCollision, true, false)

	-- Spawns a Particle and attaches it to the thruster
	local particle = Particle(spawn_location, Rotator(), "nanos-world::P_Fire", false, true)
	particle:AttachTo(thruster, AttachmentRule.SnapToTarget, "", 0)
	particle:SetRelativeLocation(rotation:RotateVector(direction * 40))

	-- Adds a constant force to the Thruster
	thruster:SetForce(Vector(100000, 0, 0), true)

	-- Sets the player to be the network authority immediately of this Prop (so he can immediately start applying the force on it - on the client side)
	thruster:SetNetworkAuthority(player)

	-- Gets the relative location rotated to attach to the exact point the player aimed
	thruster:AttachTo(entity, AttachmentRule.KeepWorld, "", 1)

	-- Updates the client's spawn history
	Events.CallRemote("SpawnedItem", player, thruster)

	Events.BroadcastRemote("SpawnSoundAttached", thruster, "nanos-world::A_VR_WorldMove_Loop_01", false, false, 0.25, math.random(10) / 100 + 1)

	Particle(spawn_location, rotation, "nanos-world::P_DirectionalBurst")
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "tools", "ThrusterTool", function() return SpawnGenericToolGun(Vector(), Rotator(), Color.WHITE) end)