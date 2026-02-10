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
	-- Make sure that object is a valid entity
	if (not NanosUtils.IsEntityValid(object)) then return end

	local is_pawn = object:IsA(Character) or object:IsA(CharacterSimple)

	if (is_grabbing) then
		-- Cannot grab Player's Characters, cannot grab attached entities or entities which are being grabbed
		if (
			(is_pawn and object:GetPlayer() ~= nil) or
			object:GetAttachedTo() or
			object:GetValue("IsBeingGrabbed")
		) then
			return
		end

		-- Only updates the Network Authority if this entity is network distributed
		if (object:IsNetworkDistributed()) then
			object:SetNetworkAuthority(player)
		end

		-- Enables flying mode for pawn
		if (is_pawn) then
			object:StopMovement()
			object:SetFlyingMode(true)
		end

		-- Forces it not being network authority distributed while someone is grabbing it
		object:SetNetworkAuthorityAutoDistributed(false)

		object:SetValue("IsBeingGrabbed", true, true)
		object:SetValue("PhysicsGunUsing", self)
		player:SetValue("PhysicsGunUsing", self)
		self.player_grabbing = player
		self.object_grabbing = object

		-- Sets the particle values so all Clients can set the correct position of them
		self.beam_particle:SetValue("RelativeLocationObject", picking_object_relative_location, true)
		self.beam_particle:SetValue("BeamEndObject", object, true)

		-- Subscribe to Destroy event, so we can clean up
		object:Subscribe("Destroy", PhysicsGun.OnObjectDestroyed)
		player:Subscribe("Destroy", PhysicsGun.OnPlayerDestroyed)
	else
		-- Restores flying mode
		if (is_pawn) then
			object:SetFlyingMode(false)
		end

		-- Restores auto network authority distribution of this object
		object:SetNetworkAuthorityAutoDistributed(true)

		object:SetValue("IsBeingGrabbed", false, true)
		object:SetValue("PhysicsGunUsing", nil)
		player:SetValue("PhysicsGunUsing", nil)
		self.player_grabbing = nil
		self.object_grabbing = nil

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
	if (object:IsA(Prop) and not object:IsA(BaseButton)) then
		object:SetGrabMode(freeze and GrabMode.Disabled or GrabMode.Auto)
	end

	if (freeze) then
		Particle(object:GetLocation(), Rotator(), "nanos-world::P_OmnidirectionalBurst")
	end

	-- Disables/Enables the character to Aim, so he can use the Mouse Wheel properly
	local controlled_character = player:GetControlledCharacter()
	controlled_character:SetCanAim(not is_grabbing)
	controlled_character:SetCanGrabProps(not is_grabbing)

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

-- Restores Object values if Physics Gun is destroyed
function PhysicsGun:OnDestroyed()
	local object_grabbing = self.object_grabbing
	if (object_grabbing and object_grabbing:IsValid()) then
		object_grabbing:SetNetworkAuthorityAutoDistributed(true)
		object_grabbing:SetGravityEnabled(true)
		object_grabbing:Unsubscribe("Destroy", PhysicsGun.OnObjectDestroyed)

		object_grabbing:SetValue("PhysicsGunUsing", nil)
		object_grabbing:SetValue("IsBeingGrabbed", false, true)
	end

	local player_grabbing = self.player_grabbing
	if (player_grabbing and player_grabbing:IsValid()) then
		local controlled_character = player_grabbing:GetControlledCharacter()
		controlled_character:SetCanAim(true)
		controlled_character:SetCanGrabProps(true)

		player_grabbing:Unsubscribe("Destroy", PhysicsGun.OnPlayerDestroyed)

		player_grabbing:SetValue("PhysicsGunUsing", nil)
	end
end

-- Restores Player values if Object is destroyed
function PhysicsGun.OnObjectDestroyed(object)
	local physics_gun = object:GetValue("PhysicsGunUsing")
	if (not physics_gun or not physics_gun:IsValid()) then return end

	local player_grabbing = physics_gun.player_grabbing

	if (player_grabbing and player_grabbing:IsValid()) then
		local controlled_character = player_grabbing:GetControlledCharacter()
		controlled_character:SetCanAim(true)
		controlled_character:SetCanGrabProps(true)

		player_grabbing:Unsubscribe("Destroy", PhysicsGun.OnPlayerDestroyed)
	end

	physics_gun.beam_particle:SetValue("BeamEndObject", nil, true)

	physics_gun.object_grabbing = nil
	physics_gun.player_grabbing = nil
end

-- Restores Object values if Player is destroyed
function PhysicsGun.OnPlayerDestroyed(player)
	local physics_gun = player:GetValue("PhysicsGunUsing")
	if (not physics_gun or not physics_gun:IsValid()) then return end

	local object_grabbing = physics_gun.object_grabbing

	if (object_grabbing and object_grabbing:IsValid()) then
		object_grabbing:SetNetworkAuthorityAutoDistributed(true)
		object_grabbing:SetGravityEnabled(true)
		object_grabbing:Unsubscribe("Destroy", PhysicsGun.OnObjectDestroyed)

		object_grabbing:SetValue("PhysicsGunUsing", nil)
		object_grabbing:SetValue("IsBeingGrabbed", false, true)
	end

	physics_gun.beam_particle:SetValue("BeamEndObject", nil, true)

	physics_gun.object_grabbing = nil
	physics_gun.player_grabbing = nil
end

PhysicsGun.Subscribe("Destroy", PhysicsGun.OnDestroyed)

-- TODO this broke if using 'PickUp' name
PhysicsGun.SubscribeRemote("PickUpObject", PhysicsGun.OnPickUpObject)
PhysicsGun.SubscribeRemote("Toggle", PhysicsGun.OnToggle)
PhysicsGun.SubscribeRemote("Drop", PhysicsGun.StopParticles)