-- Subscribes for Client Event for welding an object into another
Events.Subscribe("Weld", function(player, welding_start, welding_end, welding_end_location)
	-- Spawns the cable (invisible)
	local cable = Cable(welding_end_location, false)

	-- Configures the Cable Physics Limits to be rigid
	cable:SetLinearLimits(ConstraintMotion.Locked, ConstraintMotion.Locked, ConstraintMotion.Locked)
	cable:SetAngularLimits(ConstraintMotion.Locked, ConstraintMotion.Locked, ConstraintMotion.Locked)

	-- Attaches the cable to the two objects
	cable:AttachEndTo(welding_start)

	-- If there is an end object, attaches to it otherwise the cable keeps attached to the ground
	if (welding_end) then
		cable:AttachStartTo(welding_end)
	end

	-- Calls the client to update it's action history
	Events.CallRemote("SpawnedItem", player, cable)

	Particle(welding_start:GetLocation(), Rotator(), "nanos-world::P_OmnidirectionalBurst")
	Particle(welding_end_location, Rotator(), "nanos-world::P_OmnidirectionalBurst")
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "tools", "WeldTool", function() return SpawnGenericToolGun(Vector(), Rotator(), Color.CHARTREUSE) end)