BalloonGun = ToolGunSingleTarget.Inherit("BalloonGun")

function BalloonGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGunSingleTarget.Constructor(self, location, rotation, Color.VIOLET)
end

function BalloonGun:OnSpawnBalloon(player, spawn_location, relative_location, relative_rotation, direction, entity, configs)
	-- Refuse to attach a balloon to a Character
	if (entity and entity:IsA(Character) and entity:GetPlayer()) then
		return
	end

	if (not ValidateSpawnLimits(player, "Balloon")) then
		return
	end

	-- Calculate randomness
	local force_randomness = configs.force * configs.length_randomness / 100
	local max_length_randomness = configs.max_length * configs.length_randomness / 100

	local force = (math.random() * force_randomness * 2 + (configs.force - force_randomness)) * 1000
	local max_length = math.random() * max_length_randomness * 2 + (configs.max_length - max_length_randomness)

	local balloon = Balloon(spawn_location, Rotator(0, math.random() * 360, 0), "", "", player, relative_location, relative_rotation, direction, entity, force, max_length, configs.asset)

	-- Updates the client's spawn history
	SpawnHistory.AddItemToHistory(player, balloon)

	Particle(spawn_location, direction:ToOrientationRotator(), "nanos-world::P_DirectionalBurst"):SetParameterColor("Color", balloon:GetMaterialColorParameter("Tint"))
end

BalloonGun.SubscribeRemote("SpawnBalloon", BalloonGun.OnSpawnBalloon)