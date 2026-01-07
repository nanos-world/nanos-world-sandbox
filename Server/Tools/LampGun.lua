LampGun = ToolGun.Inherit("LampGun")

function LampGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGun.Constructor(self, location, rotation, Color.YELLOW)
end

function LampGun:OnSpawnLamp(player, spawn_location, relative_location, relative_rotation, direction, entity)
	if (not ValidateSpawnLimits(player, "Lamp")) then
		return
	end

	local rotation = direction:Rotation()
	local lamp = Flashlight(spawn_location, rotation)

	-- If to attach to a non-player entity
	if (entity and (not entity:IsA(Character) or not entity:GetPlayer())) then
		lamp:AttachTo(entity, AttachmentRule.KeepWorld, "", 0)
		lamp:SetRelativeLocation(relative_location)
		lamp:SetRelativeRotation(relative_rotation)
		lamp:SetGrabMode(GrabMode.Disabled)
	end

	-- Updates the client's spawn history
	Events.CallRemote("SpawnedItem", player, lamp)

	Particle(spawn_location, rotation, "nanos-world::P_DirectionalBurst"):SetParameterColor("Color", lamp.color)
end

LampGun.SubscribeRemote("SpawnLamp", LampGun.OnSpawnLamp)