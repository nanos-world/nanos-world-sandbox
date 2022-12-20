ThrusterGun = ToolGun.Inherit("ThrusterGun")

function ThrusterGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGun.Constructor(self, location, rotation, Color.WHITE)
end

function ThrusterGun:OnSpawnThruster(player, hit_location, relative_location, relative_rotation, direction, entity)
	local rotation = (direction * -1):Rotation()
	local thruster = Thruster(hit_location, rotation)

	-- Gets the relative location rotated to attach to the exact point the player aimed
	thruster:AttachTo(entity, AttachmentRule.SnapToTarget, "", 1)
	thruster:SetRelativeLocation(relative_location)
	thruster:SetRelativeRotation(relative_rotation)

	-- Calls the client to add it to his spawn history
	Events.CallRemote("SpawnedItem", player, thruster)

	Particle(hit_location, rotation + Rotator(180, 0, 0), "nanos-world::P_DirectionalBurst")
end

ThrusterGun.SubscribeRemote("SpawnThruster", ThrusterGun.OnSpawnThruster)
