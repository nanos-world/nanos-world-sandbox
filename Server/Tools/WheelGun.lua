WheelGun = ToolGunSingleTarget.Inherit("WheelGun")

function WheelGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGunSingleTarget.Constructor(self, location, rotation, Color.WHITE)
end

function WheelGun:OnSpawnWheel(player, hit_location, relative_location, relative_rotation, direction, entity, configs)
	-- Make sure that entity is valid
	if (not NanosUtils.IsEntityValid(entity)) then return end

	-- Refuse to attach a wheel to a character
	if (entity:IsA(Character)) then
		return
	end

	if (not ValidateSpawnLimits(player, "Wheel")) then
		return
	end

	local wheel_config = WHEELS_CONFIG[configs.asset]

	local entity_rotation_quaternion = entity:GetRotation():Quaternion()

	local current_hit_location = entity:GetLocation() + entity_rotation_quaternion:RotateVector(relative_location) * entity:GetScale()

	local base_rotation_quaternion = entity_rotation_quaternion * relative_rotation:Quaternion()

	local wheel_rotation_quaternion = base_rotation_quaternion * wheel_config.direction:ToOrientationQuat()

	local scale = configs.scale * (wheel_config.scale or 1)

	local wheel_location = current_hit_location - wheel_rotation_quaternion:RotateVector(wheel_config.offset) * scale

	local wheel = Wheel(wheel_location, wheel_rotation_quaternion:Rotator(), configs.asset, configs.force * 1000, configs.start_activated, configs.is_reversed, scale, wheel_config)

	local cable = Cable(wheel_location, false)

	-- Disables collisions between ends
	cable:SetPhysicsConstraintSettings(true)

	-- Note: linear limits only works in the rotation of the entity
	-- cable:SetLinearLimits(ConstraintMotion.Locked, ConstraintMotion.Limited, ConstraintMotion.Locked, 10 * scale)
	-- cable:SetLinearMotorPositionSettings(false, true, false, 1000)

	cable:SetAngularLimits(ConstraintMotion.Locked, ConstraintMotion.Locked, ConstraintMotion.Free)

	cable:AttachStartTo(wheel)

	-- Gets the relative location from the end object to the start location, this will be the physics constraint offset, to keep objects "in place"
	local constraint_offset = entity_rotation_quaternion:UnrotateVector(wheel_location - current_hit_location) / entity:GetScale()

	cable:AttachEndTo(entity, relative_location, nil, constraint_offset)

	-- Updates the client's spawn history
	SpawnHistory.AddItemToHistory(player, wheel)

	Particle(hit_location, base_rotation_quaternion:Rotator(), "nanos-world::P_DirectionalBurst")
end

WheelGun.SubscribeRemote("SpawnWheel", WheelGun.OnSpawnWheel)
