TrailGun = ToolGun.Inherit("TrailGun")

function TrailGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGun.Constructor(self, location, rotation, Color.VIOLET)
end

function TrailGun:OnSpawnTrail(player, hit_location, relative_location, relative_rotation, direction, entity)
	local trail = Trail(hit_location, relative_location, relative_rotation, direction, entity)

	-- Updates the client's spawn history
	Events.CallRemote("SpawnedItem", player, trail)

	Particle(hit_location, trail:GetRotation() + Rotator(90, 0, 0), "nanos-world::P_DirectionalBurst"):SetParameterColor("Color", trail.color)
end

TrailGun.SubscribeRemote("SpawnTrail", TrailGun.OnSpawnTrail)