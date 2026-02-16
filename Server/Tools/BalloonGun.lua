BalloonGun = ToolGunSingleTarget.Inherit("BalloonGun")

function BalloonGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGunSingleTarget.Constructor(self, location, rotation, Color.VIOLET)
end

function BalloonGun:OnSpawnBalloon(player, spawn_location, relative_location, relative_rotation, direction, entity, force, max_length, asset)
	-- Refuse to attach a balloon to a Character
	if (entity and entity:IsA(Character) and entity:GetPlayer()) then
		return
	end

	if (not ValidateSpawnLimits(player, "Balloon")) then
		return
	end

	local balloon = Balloon(spawn_location, Rotator(0, math.random() * 360, 0), "", "", player, relative_location, relative_rotation, direction, entity, force, max_length, asset)

	-- Updates the client's spawn history
	SpawnHistory.AddItemToHistory(player, balloon)

	Particle(spawn_location, direction:ToOrientationRotator(), "nanos-world::P_DirectionalBurst"):SetParameterColor("Color", balloon:GetMaterialColorParameter("Tint"))
end

BalloonGun.SubscribeRemote("SpawnBalloon", BalloonGun.OnSpawnBalloon)