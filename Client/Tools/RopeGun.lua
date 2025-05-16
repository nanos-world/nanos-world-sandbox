RopeGun = ToolGun.Inherit("RopeGun")

-- Tool Name
RopeGun.name = "Rope Gun"

-- Tool Image
RopeGun.image = "package://sandbox/Client/Tools/RopeGun.webp"

-- Tool Tutorials
RopeGun.tutorials = {
	{ key = "LeftClick", text = "attach rope" },
	{ key = "Undo", text = "undo rope" },
}

-- Tool Crosshair Trace Debug Settings
RopeGun.crosshair_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	color_entity = Color.GREEN,
	color_no_entity = Color.RED,
}

-- RopeGun Configurations
RopeGun.attaching_end_to = nil
RopeGun.attaching_end_relative_location = Vector()


-- Overrides ToolGun method
function RopeGun:OnLocalPlayerFire(shooter)
	-- Makes a trace 10000 units ahead to spawn the balloon
	local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle)

	-- If hit something
	if (trace_result.Success) then
		-- If is already attaching the end, then tries to attach the start
		if (RopeGun.attaching_end_to) then
			-- Do not allow attaching to itself
			if (RopeGun.attaching_end_to == trace_result.Entity) then
				SoundInvalidAction:Play()
				return
			end

			local attaching_start_to = trace_result.Entity
			local attaching_start_location = nil

			-- If we have an entity, then get the relative instead because it can change the location when data reaching the server
			if (attaching_start_to) then
				attaching_start_location = trace_result.Entity:GetRotation():RotateVector(trace_result.Location - trace_result.Entity:GetLocation()) / trace_result.Entity:GetScale()
			else
				attaching_start_location = trace_result.Location
			end

			self:CallRemoteEvent("RopeAttach", RopeGun.attaching_end_to, RopeGun.attaching_end_relative_location, attaching_start_to, attaching_start_location)

			-- Cleans up the variables and the object highlight
			RopeGun.attaching_end_to:SetHighlightEnabled(false)
			RopeGun.attaching_end_to = nil
			RopeGun.attaching_end_relative_location = Vector()

			-- Spawns a "positive" sound for attaching
			Sound(trace_result.Location, "nanos-world::A_VR_Confirm", false, true, SoundType.SFX, 0.15, 0.85)
			return

		-- If is not yet attached to end
		elseif (trace_result.Entity and not trace_result.Entity:HasAuthority()) then
			RopeGun.attaching_end_to = trace_result.Entity
			RopeGun.attaching_end_relative_location = trace_result.Entity:GetRotation():RotateVector(trace_result.Location - trace_result.Entity:GetLocation()) / trace_result.Entity:GetScale()

			-- Enable Highlighting on index 0
			RopeGun.attaching_end_to:SetHighlightEnabled(true, 0)

			-- Spawns a "positive" sound for attaching
			Sound(trace_result.Location, "nanos-world::A_VR_Click_03", false, true, SoundType.SFX, 0.15, 0.85)
			return
		end
	end

	-- If didn't hit anything, plays a negative sound
	SoundInvalidAction:Play()
end

-- Overrides ToolGun method
function RopeGun:OnLocalPlayerDrop(character)
	if (RopeGun.attaching_end_to) then
		RopeGun.attaching_end_to:SetHighlightEnabled(false)
		RopeGun.attaching_end_to = nil
		RopeGun.attaching_end_relative_location = Vector()
	end
end