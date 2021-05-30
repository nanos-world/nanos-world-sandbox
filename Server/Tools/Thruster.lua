-- Subscribes for Client Event for spawning a Thruster
Events:Subscribe("SpawnThruster", function(player, spawn_location, direction, entity, distance_trace_object)
	-- Calculates the Thruster Rotation to spawn it
	local rotation = (direction * -1):Rotation()

	-- Spawns a Thruster Prop
	local thruster = Prop(spawn_location, rotation, "NanosWorld::SM_Jet_Thruster", CollisionType.NoCollision, true, false)

	-- Spawns a Particle and attaches it to the thruster
	local particle = Particle(spawn_location, Rotator(), "NanosWorld::P_Fire", false, true)
	particle:AttachTo(thruster)
	particle:SetRelativeLocation(rotation:RotateVector(direction * 40))
	thruster:SetValue("Particle", particle)

	-- Adds a constant force to the Thruster
	thruster:SetForce(Vector(100000, 0, 0), true)

	-- Sets the player to be the network authority immediately of this Prop (so he can immediately start applying the force on it - on the client side)
	thruster:SetNetworkAuthority(player)

	-- Gets the relative location rotated to attach to the exact point the player aimed
	thruster:AttachTo(entity, AttachmentRule.KeepWorld)

	-- Updates the client's spawn history
	Events:CallRemote("SpawnedItem", player, {thruster})

	-- Calls the client to spawns a thruster sound and attach to the thruster (currently sounds are client-only)
	Events:BroadcastRemote("SpawnThruster", {thruster})

	-- Calls the Client to spawn ballons spawning sounds
	Events:BroadcastRemote("SpawnParticle", {spawn_location, rotation, "NanosWorld::P_DirectionalBurst"})
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("NanosWorld", "tools", "ThrusterTool", function() return SpawnGenericToolGun(Vector(), Rotator(), Color.WHITE) end)