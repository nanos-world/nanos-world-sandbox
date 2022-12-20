PhysicsGun = ToolGun.Inherit("PhysicsGun")

function PhysicsGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGun.Constructor(self, location, rotation, Color.BLUE)

	-- Spawns a Beam Particle and attaches it to the weapon
	self.beam_particle = Particle(Vector(), Rotator(), "nanos-world::P_Beam", false, false)
	self.beam_particle:AttachTo(self, AttachmentRule.SnapToTarget, "muzzle", 0)

	-- Sets the Color and some settings to make it pretty
	self.beam_particle:SetParameterColor("BeamColor", Color(0, 0, 0.05, 1))
	self.beam_particle:SetParameterFloat("BeamWidth", 1.5)
	self.beam_particle:SetParameterFloat("JitterAmount", 1)

	-- Syncs the Particle with Clients
	self:SetValue("BeamParticle", self.beam_particle, true)
end

function PhysicsGun:OnPickUpObject(player, object, is_grabbing, picking_object_relative_location, freeze)
	if (is_grabbing) then
		-- Forces it not being network authority distributed while someone is grabbing it
		object:SetNetworkAuthorityAutoDistributed(false)

		-- Only updates the Network Authority if this entity is network distributed
		if (object:IsNetworkDistributed()) then
			object:SetNetworkAuthority(player)
		end

		object:SetValue("IsBeingGrabbed", true, true)

		-- Sets the particle values so all Clients can set the correct position of them
		self.beam_particle:SetValue("RelativeLocationObject", picking_object_relative_location, true)
		self.beam_particle:SetValue("BeamEndObject", object, true)

		-- Spawns a sound for grabbing it
		Events.BroadcastRemote("SpawnSound", object:GetLocation(), "nanos-world::A_VR_Grab", false, 0.25, 0.9)

		self:BroadcastRemoteEvent("ToggleTargetParticles", false)
	else
		-- Restores auto network authority distribution of this object
		object:SetNetworkAuthorityAutoDistributed(true)

		object:SetValue("IsBeingGrabbed", false, true)

		-- Resets TranslateTo and RotateTo movement
		object:TranslateTo(object:GetLocation(), 0)
		object:RotateTo(object:GetRotation(), 0)

		-- Resets particle values
		self.beam_particle:SetValue("RelativeLocationObject", nil, true)
		self.beam_particle:SetValue("BeamEndObject", nil, true)

		-- Spawns a sound for ungrabbing it
		Events.BroadcastRemote("SpawnSound", object:GetLocation(), "nanos-world::A_VR_Ungrab", false, 0.25, 0.9)

		self:BroadcastRemoteEvent("ToggleTargetParticles", true)
	end

	-- Disables/Enables the gravity of the object so he can 'fly' freely
	object:SetGravityEnabled(not freeze and not is_grabbing)

	if (freeze) then
		Particle(object:GetLocation(), Rotator(), "nanos-world::P_OmnidirectionalBurst")
	end

	-- Disables/Enables the character to Aim, so he can use the Mouse Wheel properly
	player:GetControlledCharacter():SetCanAim(not is_grabbing)

	Events.BroadcastRemote("PickUpObject", object, is_grabbing)
end

function PhysicsGun:OnToggle(player, enable)
	-- If the Physics Gun is being enabled
	if (enable) then
		self.beam_particle:Activate(true)
		self:BroadcastRemoteEvent("ToggleTargetParticles", true)
	else
		Events.BroadcastRemote("SpawnSound", self:GetLocation(), "nanos-world::A_Simulate_End", false, 1, 1)
		self:StopParticles()
	end
end

function PhysicsGun:StopParticles()
	self.beam_particle:Deactivate()
	self:BroadcastRemoteEvent("ToggleTargetParticles", false)
end

-- TODO this broke if using 'PickUp' name
PhysicsGun.SubscribeRemote("PickUpObject", PhysicsGun.OnPickUpObject)
PhysicsGun.SubscribeRemote("Toggle", PhysicsGun.OnToggle)
PhysicsGun.SubscribeRemote("Drop", PhysicsGun.StopParticles)