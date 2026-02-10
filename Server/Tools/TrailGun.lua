TrailGun = ToolGunSingleTarget.Inherit("TrailGun")

function TrailGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGunSingleTarget.Constructor(self, location, rotation, Color.VIOLET)
end

function TrailGun:OnSpawnTrail(player, hit_location, relative_location, relative_rotation, direction, entity)
	-- Refuse to attach a trail to a player
	if (entity and entity:IsA(Character) and entity:GetPlayer()) then
		return
	end

	if (not ValidateSpawnLimits(player, "Trail")) then
		return
	end

	-- Calculates the Trail Rotation to spawn it
	local rotation = direction:Rotation()
	local trail = Trail(hit_location, rotation, relative_location, relative_rotation, direction, entity)

	-- Updates the client's spawn history
	SpawnHistory.AddItemToHistory(player, trail)

	Particle(hit_location, rotation, "nanos-world::P_DirectionalBurst"):SetParameterColor("Color", trail.color)
end

TrailGun.SubscribeRemote("SpawnTrail", TrailGun.OnSpawnTrail)