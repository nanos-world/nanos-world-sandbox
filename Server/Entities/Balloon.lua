Balloon = Prop.Inherit("Balloon")

-- todo move the cable stuff to balloon gun instead
function Balloon:Constructor(location, rotation, force, max_length, entity, distance_trace_object, asset)
	-- Spawns a Balloon Prop (not allowing characters to pickup it and with CCD disabled)
	self.Super:Constructor(location + Vector(0, 0, 10), rotation, asset or "nanos-world::SM_Balloon_01", CollisionType.Normal, true, GrabMode.Disabled, CCDMode.Disabled)

	self:SetPhysicalMaterial("nanos-world::PM_Rubber")

	-- Adds a constant force upwards
	self:SetForce(Vector(0, 0, tonumber(force) or 100000), false)

	-- Configures the Ballon Physics
	self:SetPhysicsDamping(5, 10)

	-- Sets a random color for the balloon
	self.color = Color.RandomPalette()
	self:SetMaterialColorParameter("Tint", self.color)

	max_length = tonumber(max_length)

	-- If didn't pass max_length, we consider we don't want cable
	if (max_length) then
		-- Spawns the Ballon cable
		local cable = Cable(location)

		-- Configures the Cable Linear Physics Limit
		cable:SetLinearLimits(ConstraintMotion.Limited, ConstraintMotion.Limited, ConstraintMotion.Limited, max_length, 0, true, 10000, 100)

		-- Sets cable rendering settings (width = 3, pieces = 4)
		cable:SetRenderingSettings(3, 4, 1)
		cable:SetCableSettings(max_length / 4, 10, 1)

		-- If to attach to an entity, attaches the start to it
		if (entity) then
			-- Gets the relative location rotated to attach to the exact point the player aimed
			local attach_location = entity:GetRotation():RotateVector(-distance_trace_object)
			cable:AttachStartTo(entity, attach_location)
		end

		-- Attaches the Cable to the Balloon
		cable:AttachEndTo(self)
	end

	-- Sets some values to be used later on (such as Balloon color to be used on popping Particles and the Cable itself to be able to destroy it properly)
	self:SetValue("Color", self.color, true)
	self:SetValue("Balloon", true)

	-- Stores the actual Z location so we can destroy it after it raised +6000
	self.spawn_z_location = location.Z

	-- Calls the Client to spawn ballons spawning sounds
	Events.BroadcastRemote("SpawnSound", location, "nanos-world::A_Balloon_Inflate", false, 0.75, 1)
end

-- Subscribes for popping when balloon takes damage
function Balloon:OnTakeDamage(damage, bone_name, damage_type, hit_from_direction, instigator, causer)
	self:Destroy()
end

Balloon.Subscribe("TakeDamage", Balloon.OnTakeDamage)


-- Timer for destroying balloons when they gets too high
Timer.SetInterval(function()
	for k, balloon in pairs(Balloon.GetPairs()) do
		-- If this balloon is higher enough, pops it
		if (balloon:IsValid() and balloon:GetLocation().Z - balloon.spawn_z_location > 6000 + math.random(1000)) then
			balloon:Destroy()
		end
	end
end, 1000)