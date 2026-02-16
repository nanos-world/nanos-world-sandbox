ToolGunDoubleTarget = ToolGun.Inherit("ToolGunDoubleTarget")

-- Helper variables to handle the first target
ToolGunDoubleTarget.targeting_first_to = nil
ToolGunDoubleTarget.targeting_first_relative_location = Vector()
ToolGunDoubleTarget.targeting_first_relative_rotation = Rotator()

-- Overrides ToolGun method
function ToolGunDoubleTarget:OnLocalPlayerFire(shooter)
	-- Makes a trace 10000 units ahead to spawn the balloon
	local trace_result = TraceFor(10000, self.debug_trace.collision_channel)

	-- If hit something
	if (trace_result.Success) then
		-- If we are already targeting the first, then tries to target the second
		if (ToolGunDoubleTarget.targeting_first_to and ToolGunDoubleTarget.targeting_first_to:IsValid()) then
			-- If we target the same entity as the first, resets
			if (ToolGunDoubleTarget.targeting_first_to == trace_result.Entity) then

				-- Cleans up the first target
				ToolGunDoubleTarget.ResetFirstTarget()
				SoundDeleteItemFromHistory:Play()
				return
			end

			local targeting_second_to = trace_result.Entity
			local targeting_second_location = nil
			local targeting_second_rotation = nil

			-- If we have an entity, then get the relative instead because it can change the location when data reaching the server
			if (targeting_second_to) then
				targeting_second_location, targeting_second_rotation = NanosMath.RelativeTo(trace_result.Location, trace_result.Normal:ToOrientationRotator(), trace_result.Entity)
			else
				targeting_second_location = trace_result.Location
			end

			-- Calls the Double Target method
			self:OnLocalPlayerTarget(ToolGunDoubleTarget.targeting_first_to, ToolGunDoubleTarget.targeting_first_relative_location, ToolGunDoubleTarget.targeting_first_relative_rotation, targeting_second_to, targeting_second_location, targeting_second_rotation)

			-- Cleans up the first target
			ToolGunDoubleTarget.ResetFirstTarget()

			-- Spawns a "positive" sound for finishing
			Sound(trace_result.Location, "nanos-world::A_VR_Confirm", false, true, SoundType.SFX, 0.15, 0.85)
			return

		-- If is not yet targeting the first, it must be an entity (and not local spawned)
		elseif (trace_result.Entity and not trace_result.Entity:HasAuthority()) then
			ToolGunDoubleTarget.targeting_first_to = trace_result.Entity

			-- Stores the relative location and rotation relative to the entity
			ToolGunDoubleTarget.targeting_first_relative_location, ToolGunDoubleTarget.targeting_first_relative_rotation = NanosMath.RelativeTo(trace_result.Location, trace_result.Normal:ToOrientationRotator(), trace_result.Entity)

			-- Enable Highlighting on index 0
			ToolGunDoubleTarget.targeting_first_to:SetHighlightEnabled(true, 0)

			-- Spawns a "positive" sound for targeting first
			Sound(trace_result.Location, "nanos-world::A_VR_Click_03", false, true, SoundType.SFX, 0.15, 0.85)
			return
		end
	end

	-- If didn't hit anything, plays a negative sound
	SoundInvalidAction:Play()
end

-- Overrides ToolGun method
function ToolGunDoubleTarget:OnLocalPlayerDrop(character)
	ToolGunDoubleTarget.ResetFirstTarget()
end

-- Cleans up the variables and the object highlight
function ToolGunDoubleTarget.ResetFirstTarget()
	if (ToolGunDoubleTarget.targeting_first_to) then
		if (ToolGunDoubleTarget.targeting_first_to:IsValid()) then
			ToolGunDoubleTarget.targeting_first_to:SetHighlightEnabled(false)
		end

		ToolGunDoubleTarget.targeting_first_to = nil
		ToolGunDoubleTarget.targeting_first_relative_location = Vector()
		ToolGunDoubleTarget.targeting_first_relative_rotation = Rotator()
	end
end