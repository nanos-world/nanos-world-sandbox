WeldGun = ToolGunDoubleTarget.Inherit("WeldGun")

function WeldGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGunDoubleTarget.Constructor(self, location, rotation, Color.CHARTREUSE)
end

function WeldGun:OnWeld(player, targeting_first_to, targeting_second_to, targeting_second_location)
	-- Refuse attaching weld from/to a character, also refuse attaching to itself
	if (
		(targeting_first_to and targeting_first_to:IsA(Character)) or
		(targeting_second_to and targeting_second_to:IsA(Character)) or
		(targeting_first_to == targeting_second_to)
	) then
		return
	end

	local welding_end_world_location = targeting_first_to:GetLocation()
	local welding_start_world_location = nil

	-- If we have an entity, then get the relative instead because it can change the location when data reaching the server
	if (targeting_second_to) then
		welding_start_world_location = targeting_second_to:GetLocation()
	else
		welding_start_world_location = targeting_second_location
	end

	-- Spawns the cable (invisible)
	local cable = Cable(welding_start_world_location, false)

	-- Configures the Cable Physics Limits to be rigid
	cable:SetLinearLimits(ConstraintMotion.Locked, ConstraintMotion.Locked, ConstraintMotion.Locked)
	cable:SetAngularLimits(ConstraintMotion.Locked, ConstraintMotion.Locked, ConstraintMotion.Locked)

	-- If there is an start object, attaches to it otherwise the cable keeps attached to the ground (at the Cable's location)
	if (targeting_second_to) then
		cable:AttachStartTo(targeting_second_to)
	end

	-- Gets the relative location from the end object to the start location, this will be the physics constraint offset, to keep objects "in place"
	local constraint_offset = targeting_first_to:GetRotation():RotateVector(welding_start_world_location - welding_end_world_location) / targeting_first_to:GetScale()

	-- Attaches the cable to the end object
	cable:AttachEndTo(targeting_first_to, nil, nil, constraint_offset)

	-- Updates the client's spawn history
	SpawnHistory.AddItemToHistory(player, cable)

	Particle(welding_end_world_location, Rotator(), "nanos-world::P_OmnidirectionalBurst")
	Particle(welding_start_world_location, Rotator(), "nanos-world::P_OmnidirectionalBurst")
end

WeldGun.SubscribeRemote("Weld", WeldGun.OnWeld)