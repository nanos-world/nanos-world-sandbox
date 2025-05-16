WeldGun = ToolGun.Inherit("WeldGun")

-- Tool Name
WeldGun.name = "Weld Gun"

-- Tool Image
WeldGun.image = "package://sandbox/Client/Tools/WeldGun.webp"

-- Tool Tutorials
WeldGun.tutorials = {
	{ key = "LeftClick", text = "weld object" },
	{ key = "Undo", text = "undo weld" },
}

-- Tool Crosshair Trace Debug Settings
WeldGun.crosshair_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	color_entity = Color.GREEN,
	color_no_entity = Color.RED,
}

-- WeldGun Configurations
WeldGun.welding_end_to = nil


-- Overrides ToolGun method
function WeldGun:OnLocalPlayerFire(shooter)
	-- Makes a trace 10000 units ahead to spawn the balloon
	local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle)

	-- If hit something
	if (trace_result.Success) then
		-- If is already attaching the end, then tries to attach the start
		if (WeldGun.welding_end_to) then
			-- Do not allow attaching to itself
			if (WeldGun.welding_end_to == trace_result.Entity) then
				SoundInvalidAction:Play()
				return
			end

			local welding_start_to = trace_result.Entity
			local welding_start_location = nil

			-- If we have an entity, then get the relative instead because it can change the location when data reaching the server
			if (not welding_start_to) then
				welding_start_location = trace_result.Location
			end

			self:CallRemoteEvent("Weld", WeldGun.welding_end_to, welding_start_to, welding_start_location)

			-- Cleans up the variables and the object highlight
			WeldGun.welding_end_to:SetHighlightEnabled(false)
			WeldGun.welding_end_to = nil

			-- Spawns a "positive" sound for attaching
			Sound(trace_result.Location, "nanos-world::A_VR_Confirm", false, true, SoundType.SFX, 0.15, 0.85)
			return

		-- If is not yet attached to end
		elseif (trace_result.Entity and not trace_result.Entity:HasAuthority()) then
			WeldGun.welding_end_to = trace_result.Entity

			-- Enable Highlighting on index 0
			WeldGun.welding_end_to:SetHighlightEnabled(true, 0)

			-- Spawns a "positive" sound for attaching
			Sound(trace_result.Location, "nanos-world::A_VR_Click_03", false, true, SoundType.SFX, 0.15, 0.85)
			return
		end
	end

	-- If didn't hit anything, plays a negative sound
	SoundInvalidAction:Play()
end

-- Overrides ToolGun method
function WeldGun:OnLocalPlayerDrop(character)
	if (WeldGun.welding_end_to) then
		WeldGun.welding_end_to:SetHighlightEnabled(false)
		WeldGun.welding_end_to = nil
	end
end