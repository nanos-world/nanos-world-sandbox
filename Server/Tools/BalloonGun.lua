BalloonGun = ToolGun.Inherit("BalloonGun")

function BalloonGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGun.Constructor(self, location, rotation, Color.VIOLET)
end

function BalloonGun:OnSpawnBalloon(player, spawn_location, rotation, force, max_length, entity, distance_trace_object, asset)
	if (entity and entity:IsA(Character)) then return end

	-- TODO use relative instead
	local balloon = Balloon(spawn_location, Rotator(0, math.random() * 360, 0), force, max_length, entity, distance_trace_object, asset)

	-- Updates the client's spawn history
	Events.CallRemote("SpawnedItem", player,  balloon)

	Particle(spawn_location, rotation, "nanos-world::P_DirectionalBurst"):SetParameterColor("Color", balloon.color)
end

BalloonGun.SubscribeRemote("SpawnBalloon", BalloonGun.OnSpawnBalloon)