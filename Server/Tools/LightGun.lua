LightGun = ToolGun.Inherit("LightGun")

function LightGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGun.Constructor(self, location, rotation, Color.YELLOW)
end

function LightGun:OnSpawnLight(player, spawn_location, direction, entity, distance_trace_object)
	-- Refuse to attach a light to a player
	if (entity and entity:IsA(Character) and entity:GetPlayer()) then
		return
	end

	if (not ValidateSpawnLimits(player, "Light")) then
		return
	end

	local light = RopeLight(spawn_location, direction, entity, distance_trace_object)

	-- Calls the client to add it to his spawn history
	Events.CallRemote("SpawnedItem", player, light)

	Particle(spawn_location, direction:Rotation(), "nanos-world::P_DirectionalBurst"):SetParameterColor("Color", light.color)
end

LightGun.SubscribeRemote("SpawnLight", LightGun.OnSpawnLight)