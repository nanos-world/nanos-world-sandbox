ToolGunSingleTarget = ToolGun.Inherit("ToolGunSingleTarget")

-- Overrides ToolGun method
function ToolGunSingleTarget:OnLocalPlayerFire(shooter)
	local trace_result = TraceFor(10000, self.debug_trace.collision_channel)
	if (trace_result.Success) then
		local relative_location = nil
		local relative_rotation = nil

		-- If hit an Entity
		if (trace_result.Entity) then
			-- Prevent sending local spawned entity
			if (trace_result.Entity:HasAuthority()) then
				SoundInvalidAction:Play()
				return
			end

			-- Calculates the relative location and rotation relative to the entity
			relative_location, relative_rotation = NanosMath.RelativeTo(trace_result.Location, trace_result.Normal:Rotation(), trace_result.Entity)
		end

		-- Calls the Single Target method
		self:OnLocalPlayerTarget(trace_result.Location, relative_location, relative_rotation, trace_result.Normal, trace_result.Entity)
	else
		-- If didn't hit anything, plays a negative sound
		SoundInvalidAction:Play()
	end
end