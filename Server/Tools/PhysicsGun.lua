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

		-- Only updates the Network Authority if this entity is network distributed
		if (object:IsNetworkDistributed()) then
			object:SetNetworkAuthority(player)
		end

		-- Forces it not being network authority distributed while someone is grabbing it
		object:SetNetworkAuthorityAutoDistributed(false)

		object:SetValue("IsBeingGrabbed", true, true)
		object:SetValue("PlayerGrabbing", player)
		player:SetValue("ObjectGrabbing", object)

		-- Sets the particle values so all Clients can set the correct position of them
		self.beam_particle:SetValue("RelativeLocationObject", picking_object_relative_location, true)
		self.beam_particle:SetValue("BeamEndObject", object, true)

		-- Subscribe to Destroy event, so we can clean up
		object:Subscribe("Destroy", PhysicsGun.OnObjectDestroyed)
		player:Subscribe("Destroy", PhysicsGun.OnPlayerDestroyed)
	else
		-- Restores auto network authority distribution of this object
		object:SetNetworkAuthorityAutoDistributed(true)

		object:SetValue("IsBeingGrabbed", false, true)
		object:SetValue("PlayerGrabbing", nil)
		player:SetValue("ObjectGrabbing", nil)

		-- Resets particle values
		self.beam_particle:SetValue("RelativeLocationObject", nil, true)
		self.beam_particle:SetValue("BeamEndObject", nil, true)

		-- Unsubscribe to Destroy events
		object:Unsubscribe("Destroy", PhysicsGun.OnObjectDestroyed)
		player:Unsubscribe("Destroy", PhysicsGun.OnPlayerDestroyed)
	end

	-- Disables/Enables the gravity of the object so he can 'fly' freely
	object:SetGravityEnabled(not freeze and not is_grabbing)

	-- Disables/Enables the ability to players to grab it
	if (object:IsA(Prop)) then
		object:SetGrabMode(freeze and GrabMode.Disabled or GrabMode.Auto)
	end

	if (freeze) then
		Particle(object:GetLocation(), Rotator(), "nanos-world::P_OmnidirectionalBurst")
	end

	-- Disables/Enables the character to Aim, so he can use the Mouse Wheel properly
	player:GetControlledCharacter():SetCanAim(not is_grabbing)

	self:BroadcastRemoteEvent("PickUpObject", object, is_grabbing)
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

-- Restores Player values if Object is destroyed
function PhysicsGun.OnObjectDestroyed(object)
	local player_grabbing = object:GetValue("PlayerGrabbing")
	if (player_grabbing and player_grabbing:IsValid()) then
		player_grabbing:GetControlledCharacter():SetCanAim(true)
		player_grabbing:Unsubscribe("Destroy", PhysicsGun.OnPlayerDestroyed)
	end
end

-- Restores Object values if Player is destroyed
function PhysicsGun.OnPlayerDestroyed(player)
	local object_grabbing = player:GetValue("ObjectGrabbing")
	if (object_grabbing and object_grabbing:IsValid()) then
		object_grabbing:SetNetworkAuthorityAutoDistributed(true)
		object_grabbing:SetGravityEnabled(true)
		object_grabbing:Unsubscribe("Destroy", PhysicsGun.OnObjectDestroyed)
	end
end

-- TODO this broke if using 'PickUp' name
PhysicsGun.SubscribeRemote("PickUpObject", PhysicsGun.OnPickUpObject)
PhysicsGun.SubscribeRemote("Toggle", PhysicsGun.OnToggle)
PhysicsGun.SubscribeRemote("Drop", PhysicsGun.StopParticles)