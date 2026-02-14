WheelGun = ToolGunSingleTarget.Inherit("WheelGun")

function WheelGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGunSingleTarget.Constructor(self, location, rotation, Color.WHITE)
end

function WheelGun:OnSpawnWheel(player, hit_location, relative_location, relative_rotation, direction, entity, force, active, forward, scale)
	-- Make sure that entity is valid
	if (not NanosUtils.IsEntityValid(entity)) then return end

	-- Refuse to attach a wheel to a character
	if (entity:IsA(Character)) then
		return
	end

	if (not ValidateSpawnLimits(player, "Wheel")) then
		return
	end

	local location = hit_location + direction * 20 * scale
	local rotation = direction:Rotation()
	local wheel = Wheel(location, rotation, Vector(0, 1, 0), force, active, forward, scale)

	local cable = Cable(location, false)

	-- Disables collisions between ends
	cable:SetPhysicsConstraintSettings(true)

	cable:SetLinearLimits(ConstraintMotion.Locked, ConstraintMotion.Limited, ConstraintMotion.Locked, 10 * scale)
	cable:SetAngularLimits(ConstraintMotion.Locked, ConstraintMotion.Locked, ConstraintMotion.Free)

	cable:SetLinearMotorPositionSettings(false, true, false, 1000)

	cable:AttachStartTo(wheel)

	-- Gets the relative location from the end object to the start location, this will be the physics constraint offset, to keep objects "in place"
	local constraint_offset = entity:GetRotation():RotateVector(location - hit_location) / entity:GetScale()

	cable:AttachEndTo(entity, relative_location, nil, constraint_offset)

	-- Updates the client's spawn history
	SpawnHistory.AddItemToHistory(player, wheel)

	Particle(hit_location, rotation, "nanos-world::P_DirectionalBurst")
end

WheelGun.SubscribeRemote("SpawnWheel", WheelGun.OnSpawnWheel)
