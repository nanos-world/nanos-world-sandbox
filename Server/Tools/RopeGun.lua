RopeGun = ToolGun.Inherit("RopeGun")

function RopeGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGun.Constructor(self, location, rotation, Color.ORANGE)
end

function RopeGun:OnRopeAttach(player, attaching_start_to, attaching_start_relative_location, attaching_end_to, attaching_end_location)
	local attaching_start_world_location = attaching_start_to:GetLocation() + attaching_start_to:GetRotation():UnrotateVector(attaching_start_relative_location)
	local attaching_end_world_location = nil

	-- If we have an entity, then get the relative instead because it can change the location when data reaching the server
	if (attaching_end_to) then
		attaching_end_world_location = attaching_end_to:GetLocation() + attaching_end_to:GetRotation():UnrotateVector(attaching_end_location)
	else
		attaching_end_world_location = attaching_end_location
	end

	-- Gets the distance from the start and end locations
	local distance = attaching_start_world_location:Distance(attaching_end_world_location)

	-- Spawns the Ballon cable
	local cable = Cable(attaching_end_world_location)

	-- Configures the Cable Linear Physics Limit
	cable:SetLinearLimits(ConstraintMotion.Limited, ConstraintMotion.Limited, ConstraintMotion.Limited, distance, 1)

	-- Sets cable rendering settings (width = 3, pieces = 4)
	cable:SetRenderingSettings(5, 4, 1)
	cable:SetCableSettings(distance / 2, 10, 1)

	-- Attaches the cable to the start object
	cable:AttachEndTo(attaching_start_to, attaching_start_relative_location)

	-- If there is an end object, attaches to it otherwise the cable keeps attached to the ground
	if (attaching_end_to) then
		cable:AttachStartTo(attaching_end_to, attaching_end_location)
	end

	-- Calls the client to update his history
	Events.CallRemote("SpawnedItem", player, cable)

	Particle(attaching_start_world_location, Rotator(), "nanos-world::P_OmnidirectionalBurst")
	Particle(attaching_end_world_location, Rotator(), "nanos-world::P_OmnidirectionalBurst")
end

RopeGun.SubscribeRemote("RopeAttach", RopeGun.OnRopeAttach)