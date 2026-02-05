CableUtils = {}

-- Helper function to spawn a cable attached between two points/entities
function CableUtils.SpawnCableAttached(targeting_first_to, targeting_first_relative_location, targeting_second_to, targeting_second_location, keep_offset, custom_config_func)

	-- Calculate the world end location (from the first target)
	local attaching_end_world_location = targeting_first_to:GetLocation() + targeting_first_to:GetRotation():UnrotateVector(targeting_first_relative_location) * targeting_first_to:GetScale()
	local attaching_start_world_location = nil

	-- Calculate the world start location (if second target is passed, then targeting_second_location is a relative location, otherwise it's the world location)
	if (targeting_second_to) then
		attaching_start_world_location = targeting_second_to:GetLocation() + targeting_second_to:GetRotation():UnrotateVector(targeting_second_location) * targeting_second_to:GetScale()
	else
		attaching_start_world_location = targeting_second_location
	end

	-- Gets the distance from the end and start locations
	local distance = attaching_end_world_location:Distance(attaching_start_world_location)

	-- Spawns the cable
	local cable = Cable(attaching_start_world_location)

	-- Sets cable rendering settings (width = 5, sides = 4)
	cable:SetRenderingSettings(5, 4, 1)

	-- Calls the custom config, so it can apply Limits before attachments are made, for optimization
	if (custom_config_func) then
		custom_config_func(cable, distance)
	end

	-- If there is an start object, attaches to it otherwise the cable keeps attached to the ground (at the Cable's location)
	if (targeting_second_to) then
		cable:AttachStartTo(targeting_second_to, targeting_second_location)
	end

	local constraint_offset = Vector()
	if (keep_offset) then
		-- Gets the relative location from the end object to the start location, this will be the physics constraint offset, to keep objects "in place"
		constraint_offset = targeting_first_to:GetRotation():RotateVector(attaching_start_world_location - attaching_end_world_location)
	end

	-- Attaches the cable to the end object
	cable:AttachEndTo(targeting_first_to, targeting_first_relative_location, nil, constraint_offset)

	Particle(attaching_end_world_location, Rotator(), "nanos-world::P_OmnidirectionalBurst")
	Particle(attaching_start_world_location, Rotator(), "nanos-world::P_OmnidirectionalBurst")

	return cable
end