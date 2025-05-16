WeldGun = ToolGun.Inherit("WeldGun")

function WeldGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGun.Constructor(self, location, rotation, Color.CHARTREUSE)
end

function WeldGun:OnWeld(player, welding_end_to, welding_start_to, welding_start_location)
	local welding_end_world_location = welding_end_to:GetLocation()
	local welding_start_world_location = nil

	-- If we have an entity, then get the relative instead because it can change the location when data reaching the server
	if (welding_start_to) then
		welding_start_world_location = welding_start_to:GetLocation()
	else
		welding_start_world_location = welding_start_location
	end

	-- Spawns the cable (invisible)
	local cable = Cable(welding_start_world_location, false)

	-- Configures the Cable Physics Limits to be rigid
	cable:SetLinearLimits(ConstraintMotion.Locked, ConstraintMotion.Locked, ConstraintMotion.Locked)
	cable:SetAngularLimits(ConstraintMotion.Locked, ConstraintMotion.Locked, ConstraintMotion.Locked)

	-- Attaches the cable to the end object
	cable:AttachEndTo(welding_end_to)

	-- If there is an start object, attaches to it otherwise the cable keeps attached to the ground (at the Cable's location)
	if (welding_start_to) then
		cable:AttachStartTo(welding_start_to)
	end

	-- Calls the client to update his history
	Events.CallRemote("SpawnedItem", player, cable)

	Particle(welding_end_world_location, Rotator(), "nanos-world::P_OmnidirectionalBurst")
	Particle(welding_start_world_location, Rotator(), "nanos-world::P_OmnidirectionalBurst")
end

WeldGun.SubscribeRemote("Weld", WeldGun.OnWeld)