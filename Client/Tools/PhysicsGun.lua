-- PhysicsGun variables
PhysicsGun = {
	weapon = nil,
	beam_particle = nil,
	picking_object = nil,
	picking_object_relative_location = Vector(),
	picking_object_distance = 0,
	picking_object_initial_rotation = Rotator(),
	picking_object_snapped_moved = 0,
	is_holding_alt = false,
	is_using = false,
	is_rotating_object = false,
	quaternion_rotate_front = Rotator(-11.25, 0, 0):Quaternion(),
	quaternion_rotate_back = Rotator(11.25, 0, 0):Quaternion(),
	quaternion_rotate_right = Rotator(0, -11.25, 0):Quaternion(),
	quaternion_rotate_left = Rotator(0, 11.25, 0):Quaternion(),
	grabbed_sound = nil,
}

-- All BeamParticles being used
-- We set metamethod with __mode 'k' to make it's values be weak and auto destroyed from the table automatically
BeamParticles = setmetatable({}, { __mode = 'k' })

-- Method to handle when Player picks up the Tool
function HandlePhysicsGun(weapon, character)
	PhysicsGun.weapon = weapon

	-- Subscribes when the player fires with this weapon (turn on the Physics Gun)
	weapon:Subscribe("PullUse", function(weapon, shooter)
		TogglePhysicsGunLocal(true)
	end)

	-- Subscribes when the player stops using this weapon (turn off the Physics Gun)
	weapon:Subscribe("ReleaseUse", function(weapon, shooter)
		TogglePhysicsGunLocal(false)
	end)

	-- Subscribes when I change my AimMode (turn off the Physics Gun)
	character:Subscribe("WeaponAimModeChanged", function(self, old_state, new_state)
		if (new_state == AimMode.None) then
			TogglePhysicsGunLocal(false)
		end
	end)

	-- Sets some notification when grabbing the Light Tool
	SetNotification("PHYSICS_GUN_FREEZE", 10000, "while using a Physics Gun, press with the Right Click to freeze the object", 8000)
	SetNotification("PHYSICS_GUN_ROTATE", 25000, "you can rotate the object you are moving while holding E key and Mouse Wheel", 8000)
	SetNotification("PHYSICS_GUN_ROTATE_ANOTHER", 35000, "you can rotate the object you are moving in another direction while holding Alt+E key and Mouse Wheel", 8000)
	SetNotification("PHYSICS_GUN_ROTATE_DISTANCE", 50000, "you can approximate the object you are moving with Mouse Wheel", 8000)
end

-- Highlight objects being grabbed with index 1
Events.Subscribe("PickUpObject", function(object, is_grabbing)
	object:SetHighlightEnabled(is_grabbing, 1)
end)

-- Function to handle when I'm using a Physics Gun
function TogglePhysicsGunLocal(is_using, freeze)
	if (is_using == PhysicsGun.is_using) then return end

	-- If stops using
	if (not is_using) then
		if (PhysicsGun.picking_object) then
			-- Calls remote to "drop" the object
			Events.CallRemote("PickUp", PhysicsGun.weapon, PhysicsGun.picking_object, false, nil, freeze)

			-- Disables the highlight on this object
			PhysicsGun.picking_object:SetHighlightEnabled(false)
			PhysicsGun.picking_object = nil

			-- Stops the "graviting" sound
			if (PhysicsGun.grabbed_sound) then
				PhysicsGun.grabbed_sound:Destroy()
			end
		end
	end

	PhysicsGun.is_using = is_using

	-- Calls remote to toggle the Physics Gun off/on
	Events.CallRemote("TogglePhysicsGun", PhysicsGun.weapon, is_using)
end

-- Function to try to pickup an object
function TryPickUpObject()
	-- Get the camera location in 3D World Space
	local viewport_2D_center = Render.GetViewportSize() / 2
	local viewport_3D = Render.Deproject(viewport_2D_center)
	local start_location = viewport_3D.Position + viewport_3D.Direction * 100

	-- Gets the end location of the trace (5000 units ahead)
	local trace_max_distance = 20000
	local end_location = viewport_3D.Position + viewport_3D.Direction * trace_max_distance

	-- Determine at which object we will be tracing for (WorldStatic - StaticMeshes - PhysicsBody - Props)
	local collision_trace = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle

	-- Do the Trace
	local trace_result = Client.Trace(start_location, end_location, collision_trace, false, true)

	-- If hit something and hit an Entity
	if (trace_result.Success and trace_result.Entity) then
		-- Cannot grab Characters (yet?), cannot grab attached entities or entities which are being grabbed
		if (NanosUtils.IsA(trace_result.Entity, Character) or trace_result.Entity:GetAttachedTo() or trace_result.Entity:GetValue("IsBeingGrabbed")) then
			return end_location
		end

		-- Sets the new picked up object
		PhysicsGun.picking_object = trace_result.Entity

		-- Spawns a 'graviting' sound attached to the gravited object
		PhysicsGun.grabbed_sound = Sound(Vector(), "nanos-world::A_VR_Object_Grabbed_Loop", false, false, SoundType.SFX, 0.25)
		PhysicsGun.grabbed_sound:AttachTo(PhysicsGun.picking_object)

		-- Calculates the offset of the hit and the center of the object
		PhysicsGun.picking_object_relative_location = PhysicsGun.picking_object:GetRotation():RotateVector(PhysicsGun.picking_object:GetLocation() - trace_result.Location)

		-- Calculates the distance of the object and the camera
		PhysicsGun.picking_object_distance = trace_result.Location:Distance(viewport_3D.Position)

		PhysicsGun.picking_object_initial_rotation = PhysicsGun.picking_object:GetRotation() - Client.GetLocalPlayer():GetControlledCharacter():GetRotation()

		-- Resets settings
		PhysicsGun.is_rotating_object = false
		PhysicsGun.is_holding_alt = false

		-- Calls remote to disable gravity of this object (if has)
		Events.CallRemote("PickUp", PhysicsGun.weapon, PhysicsGun.picking_object, true, PhysicsGun.picking_object_relative_location)

		-- Enable Highlighting on index 1 on this object
		PhysicsGun.picking_object:SetHighlightEnabled(true, 1)
	else
		PhysicsGun.picking_object = nil
	end
end

-- Handles KeyBindings
Client.Subscribe("KeyUp", function(key_name)
	if (not PhysicsGun.weapon or not PhysicsGun.picking_object) then return end

	if (key_name == "LeftAlt") then
		PhysicsGun.is_holding_alt = false
		return
	end

	if (key_name == "E") then
		PhysicsGun.is_rotating_object = false
		return
	end
end)

Client.Subscribe("KeyPress", function(key_name)
	if (not PhysicsGun.weapon or not PhysicsGun.picking_object) then return end

	if (key_name == "E") then
		PhysicsGun.is_rotating_object = true
		return
	end

	if (key_name == "LeftAlt") then
		PhysicsGun.is_holding_alt = true
	end
end)

Client.Subscribe("MouseDown", function(key_name)
	if (not PhysicsGun.weapon) then return end

	-- Right Click will turn off the Gravity Gun and freeze the object
	if (key_name == "RightMouseButton") then
		if (PhysicsGun.picking_object) then
			TogglePhysicsGunLocal(false, true)
			return false
		end
	end
end)

Client.Subscribe("MouseUp", function(key_name)
	if (not PhysicsGun.weapon) then return end

	-- Scrolling will or move the object to far, or rotate it depending on the auxiliar keys pressed
	if (key_name == "MouseScrollUp") then
		if (PhysicsGun.is_rotating_object) then
			local new_rot = nil

			if (PhysicsGun.is_holding_alt) then
				new_rot = PhysicsGun.quaternion_rotate_front * PhysicsGun.picking_object_initial_rotation:Quaternion()
			else
				new_rot = PhysicsGun.quaternion_rotate_right * PhysicsGun.picking_object_initial_rotation:Quaternion()
			end

			PhysicsGun.picking_object_initial_rotation = new_rot:Rotator()
		else
			-- If mouse scroll, updates the Distance of the object from the camera
			PhysicsGun.picking_object_distance = PhysicsGun.picking_object_distance + 25
		end
		return

	-- Scrolling will or move the object to far, or rotate it depending on the auxiliar keys pressed
	elseif (key_name == "MouseScrollDown") then
		if (PhysicsGun.is_rotating_object) then
			local new_rot = nil

			if (PhysicsGun.is_holding_alt) then
				new_rot = PhysicsGun.quaternion_rotate_back * PhysicsGun.picking_object_initial_rotation:Quaternion()
			else
				new_rot = PhysicsGun.quaternion_rotate_left * PhysicsGun.picking_object_initial_rotation:Quaternion()
			end

			PhysicsGun.picking_object_initial_rotation = new_rot:Rotator()
		else
			-- If mouse scroll, updates the PhysicsGun.picking_object_distance of the object from the camera
			PhysicsGun.picking_object_distance = PhysicsGun.picking_object_distance - 25

			-- Cannot scroll too close
			if (PhysicsGun.picking_object_distance < 100) then PhysicsGun.picking_object_distance = 100 end
		end
		return
	end
end)

Client.Subscribe("Tick", function(delta_time)
	-- Every Frame, updates all Beam Particels spawned
	-- This particle has a special Vector parameter 'BeamEnd' which defines where the Beam will end
	for k, beam_particle in pairs(BeamParticles) do
		if (beam_particle:IsValid()) then
			-- Gets the graviting object
			local beam_end_object = beam_particle:GetValue("BeamEndObject")

			-- If there is an object being gravitating
			if (beam_end_object and beam_end_object:IsValid()) then
				-- Gets the relative location which the player grabbed it
				local picking_object_relative_location = beam_particle:GetValue("RelativeLocationObject")

				-- Sets the BeamEnd location, with some math to rotate the relative location relative to the object rotation
				beam_particle:SetParameterVector("BeamEnd", beam_end_object:GetLocation() + beam_end_object:GetRotation():UnrotateVector(-picking_object_relative_location))
			else
				-- If there is no object being gravitated, then points the BeamEnd to very far
				-- Gets where the particle is pointing (as it is attached to the weapon, it will point where the weapon is pointing as well)
				-- And traces in the front of it, to hit and stopa t any wall if existed
				local direction = beam_particle:GetRotation():GetForwardVector()
				local start_location = beam_particle:GetLocation()

				-- Traces 20000 units in front
				local end_location = start_location + direction * 20000
				local collision_trace = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle
				local trace_result = Client.Trace(start_location, end_location, collision_trace, false, true)

				-- If hit something
				if (trace_result.Success) then
					end_location = trace_result.Location
				end

				beam_particle:SetParameterVector("BeamEnd", end_location)
			end
		end
	end

	-- If I'm using the Gravity Gun
	if (PhysicsGun.weapon and PhysicsGun.weapon:IsValid() and PhysicsGun.is_using) then
		-- If I'm not grabbing anything, then try to grab something
		if (PhysicsGun.picking_object == nil or not PhysicsGun.picking_object:IsValid()) then
			TryPickUpObject()

			-- If still not grabbed grabbed, then I'm done
			if (PhysicsGun.picking_object == nil) then return end
		end

		-- Otherwise, if I'm grabbing something, tells the server to update it's location

		-- Get the camera location in 3D World Space
		local viewport_2D_center = Render.GetViewportSize() / 2
		local viewport_3D = Render.Deproject(viewport_2D_center)
		local start_location = viewport_3D.Position
		local camera_direction = viewport_3D.Direction

		-- Gets the new object location using some Math, first gets the overall location: start_location + camera_direction * the distance
		-- Then adds the offset of the object when it was grabbed, rotating it with the object rotation
		local end_location = (start_location + camera_direction * PhysicsGun.picking_object_distance) + PhysicsGun.picking_object:GetRotation():UnrotateVector(PhysicsGun.picking_object_relative_location)

		-- The new object rotation will be the initial rotation + the camera rotation
		local camera_rotation = Client.GetLocalPlayer():GetCameraRotation()
		camera_rotation.Pitch = 0
		local rotation = camera_rotation + PhysicsGun.picking_object_initial_rotation

		-- Calls remote to update it's location
		Events.CallRemote("UpdateObjectPosition", PhysicsGun.picking_object, end_location, rotation, PhysicsGun.is_holding_alt)
	end
end)

-- If a weapon has been added the BeamParticle value, adds it to our BeamParticles table
Weapon.Subscribe("ValueChange", function(weapon, key, value)
	if (key == "BeamParticle") then
		if (value ~= nil) then
			table.insert(BeamParticles, value)
		end
	end
end)

Events.Subscribe("PickUpToolGun_PhysicsGun", function(tool, character)
	HandlePhysicsGun(tool, character)
end)

Events.Subscribe("DropToolGun_PhysicsGun", function(tool, character)
	tool:Unsubscribe("PullUse")
	tool:Unsubscribe("ReleaseUse")
	character:Unsubscribe("WeaponAimModeChanged")

	TogglePhysicsGunLocal(false)
	PhysicsGun.weapon = nil
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "tools", "PhysicsGun", "Physics Gun", "assets///NanosWorld/Thumbnails/SK_Blaster.jpg")