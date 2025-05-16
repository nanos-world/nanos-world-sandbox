RopeGun = ToolGun.Inherit("RopeGun")

function RopeGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGun.Constructor(self, location, rotation, Color.ORANGE)
end

function RopeGun:OnRopeAttach(player, attaching_end_to, attaching_end_relative_location, attaching_start_to, attaching_start_location)
	local attaching_end_world_location = attaching_end_to:GetLocation() + attaching_end_to:GetRotation():UnrotateVector(attaching_end_relative_location)
	local attaching_start_world_location = nil

	-- If we have an entity, then get the relative instead because it can change the location when data reaching the server
	if (attaching_start_to) then
		attaching_start_world_location = attaching_start_to:GetLocation() + attaching_start_to:GetRotation():UnrotateVector(attaching_start_location)
	else
		attaching_start_world_location = attaching_start_location
	end

	-- Gets the distance from the end and start locations
	local distance = attaching_end_world_location:Distance(attaching_start_world_location)

	-- Spawns the cable
	local cable = Cable(attaching_start_world_location)

	-- Sets cable rendering settings (width = 5, sides = 4)
	cable:SetRenderingSettings(5, 4, 1)
	cable:SetCableSettings(distance / 2, 10, 1)

	-- Configures the Cable Linear Physics Limit
	cable:SetLinearLimits(ConstraintMotion.Limited, ConstraintMotion.Limited, ConstraintMotion.Limited, distance, 0.25, true, 10000, 100)

	-- Attaches the cable to the end object
	cable:AttachEndTo(attaching_end_to, attaching_end_relative_location)

	-- If there is an start object, attaches to it otherwise the cable keeps attached to the ground (at the Cable's location)
	if (attaching_start_to) then
		cable:AttachStartTo(attaching_start_to, attaching_start_location)
	end

	-- Calls the client to update his history
	Events.CallRemote("SpawnedItem", player, cable)

	Particle(attaching_end_world_location, Rotator(), "nanos-world::P_OmnidirectionalBurst")
	Particle(attaching_start_world_location, Rotator(), "nanos-world::P_OmnidirectionalBurst")
end

RopeGun.SubscribeRemote("RopeAttach", RopeGun.OnRopeAttach)