
-- GravityGun variables
GravityGun = {
	weapon = nil,
	beam_particle = nil,
	picking_object = nil,
	picking_object_offset = Vector(),
	picking_object_distance = Vector(),
}

-- Sets the color of Highlighing at index 1
Client:SetHighlightColor(Color(0, 0, 20, 1.5), 1)

-- Handles grabbing or dropping the GravityGun
function HandleGravityGun(weapon)
	if (weapon) then
		GravityGun.weapon = object
	else
		GravityGun.weapon = nil
	end
end

function TryPickUpObject()
	-- Get the camera location in 3D World Space
	local viewport_2D_center = Render:GetViewportSize() / 2
	local viewport_3D = Render:Deproject(viewport_2D_center)
	local start_location = viewport_3D.Position + viewport_3D.Direction * 100

	-- Gets the end location of the trace (5000 units ahead)
	local trace_max_distance = 5000
	local end_location = viewport_3D.Position + viewport_3D.Direction * trace_max_distance

	-- Determine at which object we will be tracing for (WorldStatic - StaticMeshes - and PhysicsBody - Props)
	local collision_trace = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn

	-- Do the Trace
	local trace_result = Client:Trace(start_location, end_location, collision_trace, false, true, false, true)

	-- If hit something and hit an Entity
	if (trace_result.Success and trace_result.Entity) then

		-- Sets the new picked up object
		GravityGun.picking_object = trace_result.Entity

		-- Calculates the offset of the hit and the center of the object
		GravityGun.picking_object_offset = GravityGun.picking_object:GetLocation() - trace_result.Location

		-- Calculates the distance of the object and the camera
		GravityGun.picking_object_distance = trace_result.Location:Distance(viewport_3D.Position)

		-- Calls remote to disable gravity of this object (if has)
		Events:CallRemote("PickUp", {GravityGun.picking_object, true})

		-- Enable Highlighting on index 1
		GravityGun.picking_object:SetHighlightEnabled(true, 1)
		GravityGun.beam_particle:SetParameterVector("BeamEnd", GravityGun.picking_object:GetLocation())
	end
end

-- When Player releases the mouse
Client:Subscribe("MouseUp", function(key_name)
	if (not GravityGun.weapon) then return end

    if (key_name == "LeftMouseButton") then
		if (GravityGun.picking_object) then
			-- Calls server to re-enable gravity (if possible) and update it's last position
			Events:CallRemote("PickUp", {GravityGun.picking_object, false})

			-- Disables the highlight
			GravityGun.picking_object:SetHighlightEnabled(false)

			GravityGun.picking_object = nil
		end

		if (GravityGun.beam_particle and GravityGun.beam_particle:IsValid()) then
			GravityGun.beam_particle:Destroy()
			GravityGun.beam_particle = nil
		end

	elseif (key_name == "MouseScrollUp") then
		-- If mouse scroll, updates the Distance of the object from the camera
		GravityGun.picking_object_distance = GravityGun.picking_object_distance + 25

	elseif (key_name == "MouseScrollDown") then
		-- If mouse scroll, updates the GravityGun.picking_object_distance of the object from the camera
		GravityGun.picking_object_distance = GravityGun.picking_object_distance - 25
		if (GravityGun.picking_object_distance < 100) then GravityGun.picking_object_distance = 100 end
	end
end)

-- When Player pressed the mouse
Client:Subscribe("MouseDown", function(key_name)
	if (not GravityGun.weapon) then return end

	-- If mouse was left button
    if (key_name == "LeftMouseButton") then
		if (not GravityGun.picking_object) then
			-- Spawns and configure the Beam particle
			GravityGun.beam_particle = Particle(Vector(), Rotator(), "NanosWorld::P_Beam", false, true)
			GravityGun.beam_particle:AttachTo(GravityGun.weapon, AttachmentRule.SnapToTarget, "muzzle")
			GravityGun.beam_particle:SetParameterColor("BeamColor", Color(0, 0, 5, 1))
			GravityGun.beam_particle:SetParameterFloat("BeamWidth", 2)
			GravityGun.beam_particle:SetParameterFloat("JitterAmount", 1)
			GravityGun.beam_particle:SetParameterVector("BeamEnd", GravityGun.weapon:GetLocation())

			TryPickUpObject()
        end
	end
end)

Client:Subscribe("Tick", function(delta_time)
	-- On Tick, updates the GravityGun beam particle
	if (GravityGun.weapon and GravityGun.weapon:IsValid()) then
		if (GravityGun.beam_particle and GravityGun.beam_particle:IsValid()) then
			-- If is grabbing an object with the GravityGun, sets the BeamEnd to it's location, otherwise make it "infinite"
			if (GravityGun.picking_object) then
				GravityGun.beam_particle:SetParameterVector("BeamEnd", GravityGun.picking_object:GetLocation() - GravityGun.picking_object_offset)
			else
				local viewport_2D_center = Render:GetViewportSize() / 2
				local viewport_3D = Render:Deproject(viewport_2D_center)
				local max_distance = 5000

				local end_location = viewport_3D.Position + viewport_3D.Direction * max_distance

				GravityGun.beam_particle:SetParameterVector("BeamEnd", end_location)

				TryPickUpObject()
			end
		end

		-- On Tick, updates the Position of the grabbing object, based on it's distance and camera rotation
		if (GravityGun.picking_object == nil) then return end

		local player = NanosWorld:GetLocalPlayer()
		if (player == nil) then return end

		-- Get the camera location in 3D World Space
		local viewport_2D_center = Render:GetViewportSize() / 2
		local viewport_3D = Render:Deproject(viewport_2D_center)
		local start_location = viewport_3D.Position

		-- Gets the new object location
		-- (camera direction * 'distance' units ahead + object offset from first Hit to keep it relative)
		local end_location = (viewport_3D.Position + viewport_3D.Direction * GravityGun.picking_object_distance) + GravityGun.picking_object_offset

		-- Calls remote to update it's location
		Events:CallRemote("UpdateObjectPosition", {GravityGun.picking_object, end_location})
	end
end)
