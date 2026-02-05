LightGun = ToolGun.Inherit("LightGun")

function LightGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGun.Constructor(self, location, rotation, Color.YELLOW)
end

function LightGun:OnSpawnLight(player, spawn_location, relative_location, relative_rotation, direction, entity)
	-- Refuse to attach a light to a player
	if (entity and entity:IsA(Character) and entity:GetPlayer()) then
		return
	end

	if (not ValidateSpawnLimits(player, "Light")) then
		return
	end

	local rope_light = RopeLight(spawn_location, relative_location, relative_rotation, direction, entity)

	-- Calls the client to add it to his spawn history
	Events.CallRemote("SpawnedItem", player, rope_light)

	Particle(spawn_location, direction:Rotation(), "nanos-world::P_DirectionalBurst"):SetParameterColor("Color", rope_light.light:GetColor())
end

LightGun.SubscribeRemote("SpawnLight", LightGun.OnSpawnLight)