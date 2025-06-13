PhysicsGun = ToolGun.Inherit("PhysicsGun")

-- Tool Name
PhysicsGun.name = "Physics Gun"

-- Tool Image
PhysicsGun.image = "package://sandbox/Client/Tools/PhysicsGun.webp"

-- Tool Tutorials
PhysicsGun.tutorials = {
	{ key = "LeftClick", text = "grab object" },
	{ key = "RightMouseButton", text = "freeze object" },
	{ key = "MouseScrollUp", text = "increase/decrease beam size" },
	{ key = "E", text = "rotate object" },
	{ key = "LeftShift", text = "snap to grid" },
}

-- PhysicsGun variables
PhysicsGun.weapon = nil
PhysicsGun.picking_object = nil
PhysicsGun.picking_object_relative_location = Vector()
PhysicsGun.picking_object_distance = 0
PhysicsGun.picking_object_initial_rotation = Rotator()
PhysicsGun.is_rotating_object = false
PhysicsGun.is_snapping_to_grid = false
PhysicsGun.is_using = false
PhysicsGun.is_picking_object_server = false
PhysicsGun.grabbed_sound = nil
PhysicsGun.accumulated_rotation_x = 0
PhysicsGun.accumulated_rotation_y = 0
PhysicsGun.quaternion_rotate_front = Rotator(-45, 0, 0):Quaternion() -- Cache it for performance
PhysicsGun.quaternion_rotate_back = Rotator(45, 0, 0):Quaternion() -- Cache it for performance
PhysicsGun.quaternion_rotate_right = Rotator(0, -45, 0):Quaternion() -- Cache it for performance
PhysicsGun.quaternion_rotate_left = Rotator(0, 45, 0):Quaternion() -- Cache it for performance
PhysicsGun.quaternion_mouse_move_x = Quat(0, 0, 0, -1) -- Cache it for performance
PhysicsGun.quaternion_mouse_move_y = Quat(0, 0, 0, 1) -- Cache it for performance


function PhysicsGun:OnSpawn()
	self.beam_particle = self:GetValue("BeamParticle")

	self.target_particle = Particle(Vector(), Rotator(), "nanos-world::P_Fountain", false, false)
	self.target_particle:SetParameterColor("Color", Color(0, 0, 50, 0.5))
	self.target_particle:SetParameterFloat("VelocityConeAngle", 60)
	self.target_particle:SetParameterFloat("MaxSize", 4)
	self.target_particle:SetParameterFloat("MinSize", 2)
	self.target_particle:SetParameterFloat("VelocityStrengthMax", 400)
	self.target_particle:SetParameterFloat("VelocityStrengthMin", 200)
	self.target_particle:SetParameterFloat("SphereRadius", 1)
	self.target_particle:SetParameterFloat("SpawnRate", 50)
end

function PhysicsGun:OnDestroy()
	self.target_particle:Destroy()
end

PhysicsGun.Subscribe("Destroy", PhysicsGun.OnDestroy)
PhysicsGun.Subscribe("Spawn", PhysicsGun.OnSpawn)

function PhysicsGun:OnLocalPlayerPickUp(character)
	PhysicsGun.weapon = self

	self:Subscribe("ReleaseUse", PhysicsGun.OnReleaseUse)
	character:Subscribe("WeaponAimModeChange", PhysicsGunWeaponAimModeChanged)
	Input.Subscribe("KeyUp", PhysicsGunKeyUp)
	Input.Subscribe("KeyPress", PhysicsGunKeyPress)
	Input.Subscribe("KeyDown", PhysicsGunKeyDown)
	Input.Subscribe("MouseDown", PhysicsGunMouseDown)
	Input.Subscribe("MouseScroll", PhysicsGunMouseScroll)
	Input.Subscribe("MouseMove", PhysicsGunMouseMove)

	-- Sets some notification when grabbing the Light Tool
	AddNotification("PHYSICS_GUN_FREEZE", "while using a Physics Gun, press with the Right Click to freeze the object", 8000, 10000)
	AddNotification("PHYSICS_GUN_ROTATE", "you can rotate the object you are moving while holding E key and Mouse Wheel", 8000, 25000)
	AddNotification("PHYSICS_GUN_ROTATE_ANOTHER", "you can rotate the object you are moving in another direction while holding Alt+E key and Mouse Wheel", 8000, 35000)
	AddNotification("PHYSICS_GUN_ROTATE_DISTANCE", "you can approximate the object you are moving with Mouse Wheel", 8000, 50000)
end

function PhysicsGun:OnLocalPlayerDrop(character)
	PhysicsGun.weapon = nil

	self:Unsubscribe("ReleaseUse", PhysicsGun.OnReleaseUse)
	character:Unsubscribe("WeaponAimModeChange", PhysicsGunWeaponAimModeChanged)
	Input.Unsubscribe("KeyUp", PhysicsGunKeyUp)
	Input.Unsubscribe("KeyPress", PhysicsGunKeyPress)
	Input.Unsubscribe("KeyDown", PhysicsGunKeyDown)
	Input.Unsubscribe("MouseDown", PhysicsGunMouseDown)
	Input.Unsubscribe("MouseScroll", PhysicsGunMouseScroll)
	Input.Unsubscribe("MouseMove", PhysicsGunMouseMove)

	TogglePhysicsGunLocal(false)
end

function PhysicsGun:OnToggleTargetParticles(enable)
	self.target_particle_enabled = enable

	if (enable) then
		self.target_particle:Activate(true)
	else
		self.target_particle:Deactivate()
	end
end

PhysicsGun.SubscribeRemote("ToggleTargetParticles", PhysicsGun.OnToggleTargetParticles)

-- Handle for pulling Physics Gun trigger
function PhysicsGun:OnLocalPlayerFire(shooter)
	TogglePhysicsGunLocal(true)
end

-- Handle for releasing Physics Gun trigger
function PhysicsGun:OnReleaseUse(shooter)
	TogglePhysicsGunLocal(false)
end

-- Handle for switching aim mode on Physics Gun
function PhysicsGunWeaponAimModeChanged(character, old_state, new_state)
	if (new_state == AimMode.None) then
		TogglePhysicsGunLocal(false)
	end
end

function PhysicsGun:OnPickUpObject(object, is_grabbing)
	object:SetOutlineEnabled(is_grabbing, 2)
	self:OnToggleTargetParticles(not is_grabbing)

	-- Spawns a sound for grabbing/ungrabbing it
	if (is_grabbing) then
		Sound(object:GetLocation(), "nanos-world::A_VR_Grab", false, true, SoundType.SFX, 0.25, 0.9)
	else
		Sound(object:GetLocation(), "nanos-world::A_VR_Ungrab", false, true, SoundType.SFX, 0.25, 0.9)
	end

	if (self == PhysicsGun.weapon) then
		PhysicsGun.is_picking_object_server = is_grabbing
	end
end

PhysicsGun.SubscribeRemote("PickUpObject", PhysicsGun.OnPickUpObject)

-- Function to handle when I'm using a Physics Gun
function TogglePhysicsGunLocal(is_using, freeze)
	if (is_using == PhysicsGun.is_using) then return end

	-- If stops using
	if (not is_using) then
		if (PhysicsGun.picking_object) then
			-- Calls remote to "drop" the object
			PhysicsGun.weapon:CallRemoteEvent("PickUpObject", PhysicsGun.picking_object, false, nil, freeze)

			-- Disables the highlight on this object
			PhysicsGun.picking_object:SetOutlineEnabled(false)
			PhysicsGun.picking_object = nil

			-- Stops the "graviting" sound
			if (PhysicsGun.grabbed_sound) then
				PhysicsGun.grabbed_sound:Destroy()
				PhysicsGun.grabbed_sound = nil
			end
		end

		PhysicsGun.is_rotating_object = false
		PhysicsGun.is_snapping_to_grid = false
		PhysicsGun.is_picking_object_server = false
	end

	PhysicsGun.is_using = is_using

	-- Calls remote to toggle the Physics Gun off/on
	PhysicsGun.weapon:CallRemoteEvent("Toggle", is_using)
end

-- Function to try to pickup an object
function TryPickUpObject()
	-- Get the camera location in 3D World Space
	local viewport_2D_center = Viewport.GetViewportSize() / 2
	local viewport_3D = Viewport.DeprojectScreenToWorld(viewport_2D_center)
	local start_location = viewport_3D.Position + viewport_3D.Direction * 100

	-- Gets the end location of the trace (5000 units ahead)
	local trace_max_distance = 20000
	local end_location = viewport_3D.Position + viewport_3D.Direction * trace_max_distance

	-- Determine at which object we will be tracing for (WorldStatic - StaticMeshes - PhysicsBody - Props)
	local collision_trace = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle

	-- Do the Trace
	local trace_result = Trace.LineSingle(start_location, end_location, collision_trace, TraceMode.ReturnEntity | TraceMode.TraceOnlyVisibility)

	-- If hit something and hit an Entity
	if (trace_result.Success and trace_result.Entity and not trace_result.Entity:HasAuthority()) then
		-- Cannot grab Characters (yet?), cannot grab attached entities or entities which are being grabbed
		if (trace_result.Entity:IsA(Character) or trace_result.Entity:GetAttachedTo() or trace_result.Entity:GetValue("IsBeingGrabbed")) then
			return end_location
		end

		-- Sets the new picked up object
		PhysicsGun.picking_object = trace_result.Entity

		-- Spawns a 'gravitating' sound attached to the gravitated object
		PhysicsGun.grabbed_sound = Sound(Vector(), "nanos-world::A_VR_Object_Grabbed_Loop", false, false, SoundType.SFX, 0.25)
		PhysicsGun.grabbed_sound:AttachTo(PhysicsGun.picking_object, AttachmentRule.SnapToTarget, "", 0)

		-- Calculates the offset of the hit and the center of the object
		PhysicsGun.picking_object_relative_location = PhysicsGun.picking_object:GetRotation():RotateVector(PhysicsGun.picking_object:GetLocation() - trace_result.Location)

		-- Calculates the distance of the object and the camera, adds ArmLength to normalize Camera Views
		PhysicsGun.picking_object_distance = trace_result.Location:Distance(viewport_3D.Position) - Client.GetLocalPlayer():GetCameraArmLength()

		PhysicsGun.picking_object_initial_rotation = PhysicsGun.picking_object:GetRotation() - Client.GetLocalPlayer():GetControlledCharacter():GetRotation()

		-- Calls remote to disable gravity of this object (if has)
		PhysicsGun.weapon:CallRemoteEvent("PickUpObject", PhysicsGun.picking_object, true, PhysicsGun.picking_object_relative_location)
	else
		PhysicsGun.picking_object = nil
	end
end

-- Handles KeyBindings
function PhysicsGunKeyUp(key_name)
	if (key_name == "LeftShift") then
		PhysicsGun.is_snapping_to_grid = false

		-- Updates rotation to match
		if (PhysicsGun.is_rotating_object and PhysicsGun.picking_object) then
			PhysicsGun.picking_object_initial_rotation = PhysicsGun.picking_object:GetRotation() - Client.GetLocalPlayer():GetControlledCharacter():GetRotation()
		end

		return
	end

	if (key_name == "E") then
		PhysicsGun.is_rotating_object = false

		-- Updates rotation to match
		if (PhysicsGun.is_snapping_to_grid and PhysicsGun.picking_object) then
			PhysicsGun.picking_object_initial_rotation = PhysicsGun.picking_object:GetRotation() - Client.GetLocalPlayer():GetControlledCharacter():GetRotation()
		end

		return
	end
end

function PhysicsGunKeyPress(key_name)
	if (key_name == "E") then
		PhysicsGun.is_rotating_object = true
		if (PhysicsGun.picking_object) then return false else return end
	end

	if (key_name == "LeftShift") then
		PhysicsGun.is_snapping_to_grid = true
		PhysicsGun.accumulated_rotation_x = 0
		PhysicsGun.accumulated_rotation_y = 0

		if (PhysicsGun.is_rotating_object and PhysicsGun.picking_object) then
			Sound(PhysicsGun.picking_object:GetLocation(), "nanos-world::A_Object_Snaps_To_Grid", false, true, SoundType.SFX, 0.05, 0.5)
		end

		return
	end

	-- Ignore input while rotating object
	if (PhysicsGun.picking_object and PhysicsGun.is_rotating_object) then
		return false
	end
end

function PhysicsGunKeyDown(key_name)
	-- Ignore input while rotating object
	if (key_name == "E" and PhysicsGun.picking_object) then
		return false
	end
end

function PhysicsGunMouseDown(key_name)
	-- Right Click will turn off the Gravity Gun and freeze the object
	if (key_name == "RightMouseButton") then
		if (PhysicsGun.picking_object) then
			TogglePhysicsGunLocal(false, true)
			return false
		end
	end
end

function PhysicsGunMouseScroll(mouse_x, mouse_y, delta)
	-- If mouse scroll, updates the Distance of the object from the camera
	PhysicsGun.picking_object_distance = PhysicsGun.picking_object_distance + PhysicsGun.picking_object_distance * 0.1 * delta

	-- Cannot scroll too close
	if (delta < 0 and PhysicsGun.picking_object_distance < 100) then
		PhysicsGun.picking_object_distance = 100
	end
end

function PhysicsGunMouseMove(delta_x, delta_y, mouse_x, mouse_y)
	if (not PhysicsGun.picking_object) then return end

	if (PhysicsGun.is_rotating_object) then
		if (PhysicsGun.is_snapping_to_grid) then
			-- Accumulates rotation
			PhysicsGun.accumulated_rotation_x = PhysicsGun.accumulated_rotation_x + delta_x * 0.005
			PhysicsGun.accumulated_rotation_y = PhysicsGun.accumulated_rotation_y - delta_y * 0.005

			local has_accumulated_enough_x = math.abs(PhysicsGun.accumulated_rotation_x) > 1
			local has_accumulated_enough_y = math.abs(PhysicsGun.accumulated_rotation_y) > 1

			if (has_accumulated_enough_x or has_accumulated_enough_y) then
				Sound(PhysicsGun.picking_object:GetLocation(), "nanos-world::A_Object_Snaps_To_Grid", false, true, SoundType.SFX, 0.05, 0.5)

				if (has_accumulated_enough_x) then
					local diff = PhysicsGun.accumulated_rotation_x > 0 and PhysicsGun.quaternion_rotate_right or PhysicsGun.quaternion_rotate_left
					PhysicsGun.accumulated_rotation_x = 0
					PhysicsGun.picking_object_initial_rotation = (diff * PhysicsGun.picking_object_initial_rotation:Quaternion()):Rotator()
				end

				if (has_accumulated_enough_y) then
					local diff = PhysicsGun.accumulated_rotation_y > 0 and PhysicsGun.quaternion_rotate_front or PhysicsGun.quaternion_rotate_back
					PhysicsGun.accumulated_rotation_y = 0
					PhysicsGun.picking_object_initial_rotation = (diff * PhysicsGun.picking_object_initial_rotation:Quaternion()):Rotator()
				end
			end
		else
			PhysicsGun.quaternion_mouse_move_x.Z = 0.001 * delta_x
			PhysicsGun.quaternion_mouse_move_y.Y = 0.001 * -delta_y

			PhysicsGun.picking_object_initial_rotation = (PhysicsGun.quaternion_mouse_move_y * PhysicsGun.quaternion_mouse_move_x * PhysicsGun.picking_object_initial_rotation:Quaternion()):Rotator()
		end

		return false
	end
end

Client.Subscribe("Tick", function(delta_time)
	-- Updates the Physics Gun every frame
	PhysicsGunTick()

	-- Every Frame, updates all PhysicsGun's Beam Particles
	-- This particle has a special Vector parameter 'BeamEnd' which defines where the Beam will end
	for k, physics_gun in pairs(PhysicsGun.GetAll()) do
		local beam_particle = physics_gun.beam_particle
		if (beam_particle and beam_particle:IsValid()) then
			-- Gets the gravitating object
			local beam_end_object = beam_particle:GetValue("BeamEndObject")

			-- If there is an object being gravitating
			if (beam_end_object and beam_end_object:IsValid()) then
				-- Gets the relative location which the player grabbed it
				local picking_object_relative_location = beam_particle:GetValue("RelativeLocationObject")

				-- Sets the BeamEnd location, with some math to rotate the relative location relative to the object rotation
				local end_location = beam_end_object:GetLocation() + beam_end_object:GetRotation():UnrotateVector(-picking_object_relative_location)
				beam_particle:SetParameterVector("BeamEnd", end_location)
			else
				-- If there is no object being gravitated, then points the BeamEnd to very far
				-- Gets where the particle is pointing (as it is attached to the weapon, it will point where the weapon is pointing as well)
				-- And traces in the front of it, to hit and stop at any wall if existed
				local direction = nil
				local start_location = nil

				-- If I'm the local handler, make more precise calculations
				if (PhysicsGun.weapon == physics_gun) then
					local local_player = Client.GetLocalPlayer()
					local camera_rotation = local_player:GetCameraRotation()
					direction =  camera_rotation:GetForwardVector()
					start_location = local_player:GetCameraLocation()
				else
					direction = beam_particle:GetRotation():GetForwardVector()
					start_location = beam_particle:GetLocation()
				end

				-- Traces 20000 units in front
				local end_location = start_location + direction * 20000
				local collision_trace = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle
				local trace_result = Trace.LineSingle(start_location, end_location, collision_trace, TraceMode.TraceOnlyVisibility)

				-- If hit something
				if (trace_result.Success) then
					end_location = trace_result.Location
				end

				beam_particle:SetParameterVector("BeamEnd", end_location)

				-- TODO move target particle to a new Physics Gun beam particle asset
				local target_particle = physics_gun.target_particle
				if (physics_gun.target_particle_enabled and target_particle and target_particle:IsValid()) then
					target_particle:SetLocation(end_location)
					target_particle:SetRotation(trace_result.Normal:Rotation() - Rotator(90, 0, 0))
				end
			end
		end
	end
end)

function RoundRotator(rotator, degrees)
	return Rotator(
		NanosMath.Round(rotator.Pitch / degrees) * degrees,
		NanosMath.Round(rotator.Yaw / degrees) * degrees,
		NanosMath.Round(rotator.Roll / degrees) * degrees
	)
end

function PhysicsGunTick()
	-- If I'm using the Gravity Gun
	if (PhysicsGun.is_using) then
		-- If I'm not grabbing anything, then try to grab something
		if (PhysicsGun.picking_object == nil or not PhysicsGun.picking_object:IsValid()) then
			TryPickUpObject()

			-- If still not grabbed grabbed, then I'm done
			if (PhysicsGun.picking_object == nil) then return end
		end

		-- If server didn't confirm yet, skips
		if (not PhysicsGun.is_picking_object_server) then
			return
		end

		-- If lost network authority somehow, stops gravitating it
		if (not PhysicsGun.picking_object:HasNetworkAuthority()) then
			TogglePhysicsGunLocal(false)
			return
		end

		-- Otherwise, if I'm grabbing something, update it's location
		-- Get the camera location in 3D World Space
		local local_player = Client.GetLocalPlayer()
		local camera_location = local_player:GetCameraLocation()
		local camera_rotation = local_player:GetCameraRotation()
		local camera_direction = camera_rotation:GetForwardVector()

		-- Gets the new object location using some Math, first gets the overall location: start_location + camera_direction * the distance
		-- Then adds the offset of the object when it was grabbed, rotating it with the object rotation
		local end_location = (camera_location + camera_direction * (PhysicsGun.picking_object_distance + local_player:GetCameraArmLength())) + PhysicsGun.picking_object:GetRotation():UnrotateVector(PhysicsGun.picking_object_relative_location)

		-- The new object rotation will be the initial rotation + the camera rotation
		camera_rotation.Pitch = 0
		local rotation = camera_rotation + PhysicsGun.picking_object_initial_rotation

		-- Rounds if snapping to grid
		if (PhysicsGun.is_rotating_object and PhysicsGun.is_snapping_to_grid) then
			rotation = RoundRotator(rotation, 45)
		end

		-- Updates it's location (it is only possible to call those methods as this Player is the network authority)
		PhysicsGun.picking_object:TranslateTo(end_location, 0.05)
		PhysicsGun.picking_object:RotateTo(rotation, 0.1)
	end
end
