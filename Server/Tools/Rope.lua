-- Subscribes for client event to spawn a Rope
Events.Subscribe("RopeAttach", function(player, attaching_start_to, attaching_start_location, attaching_end_to, attaching_end_location)
	-- Gets the distance from the start and end locations
	local distance = attaching_start_location:Distance(attaching_end_location)

	-- Spawns the Ballon cable
	local cable = Cable(attaching_end_location)

	-- Configures the Cable Linear Physics Limit
	cable:SetLinearLimits(ConstraintMotion.Limited, ConstraintMotion.Limited, ConstraintMotion.Limited, distance + distance * 0.1, 1)

	-- Sets cable rendering settings (width = 3, pieces = 4)
	cable:SetRenderingSettings(5, 4, 1)
	cable:SetCableSettings(distance / 2, 10, 1)

	-- Gets the relative location from the hit location and the start object
	local attaching_start_relative_to = attaching_start_to:GetLocation() - attaching_start_location

	-- Gets a correct relative rotation rotated by the object rotation
	local attach_start_location = attaching_start_to:GetRotation():RotateVector(-attaching_start_relative_to)

	-- Attaches the cable to the start object
	cable:AttachEndTo(attaching_start_to, attach_start_location)

	-- If there is an end object, attaches to it otherwise the cable keeps attached to the ground
	if (attaching_end_to) then
		local attaching_end_relative_to = attaching_end_to:GetLocation() - attaching_end_location

		-- Gets the relative location rotated to attach to the exact point the player aimed
		local attach_end_location = attaching_end_to:GetRotation():RotateVector(-attaching_end_relative_to)
		cable:AttachStartTo(attaching_end_to, attach_end_location)
	end

	-- Calls the client to update his history
	Events.CallRemote("SpawnedItem", player, cable)

	Particle(attaching_start_location, Rotator(), "nanos-world::P_OmnidirectionalBurst")
	Particle(attaching_end_location, Rotator(), "nanos-world::P_OmnidirectionalBurst")
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "tools", "RopeTool", function() return SpawnGenericToolGun(Vector(), Rotator(), Color.ORANGE) end)