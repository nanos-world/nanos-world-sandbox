-- Resizer Tool variables
WeldTool = {
	welding_start_to = nil,
}

-- Method to handle when Player picks up the Tool
function HandleWeldTool(tool)
	-- Subscribe when the player fires with this weapon
	tool:Subscribe("Fire", function(weapon, shooter)
		-- Makes a trace 10000 units ahead to spawn the balloon
		local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn)

		-- If hit something
		if (trace_result.Success) then
			-- If is already attaching the start, then tries to attach the end
			if (WeldTool.welding_start_to) then
				local welding_end_to = trace_result.Entity
				local welding_end_location = trace_result.Location

				if (welding_end_to) then
					welding_end_location = welding_end_to:GetLocation()
				end

				Events:CallRemote("Weld", {WeldTool.welding_start_to, welding_end_to, welding_end_location})

				-- Cleans up the highlights and variables
				WeldTool.welding_start_to:SetHighlightEnabled(false)
				WeldTool.welding_start_to = nil

				-- Spawns positive sounds and particles
				Particle(trace_result.Location, trace_result.Normal:Rotation(), "NanosWorld::P_DirectionalBurst", true, true)
				Sound(trace_result.Location, "NanosWorld::A_VR_Confirm", false, true, SoundType.SFX, 0.15, 0.85)

				return

			-- If is not yet attached to start
			elseif (trace_result.Entity) then
				WeldTool.welding_start_to = trace_result.Entity

				-- Enable Highlighting on index 0
				WeldTool.welding_start_to:SetHighlightEnabled(true, 0)

				-- Spawns a "positive" sound for attaching
				Sound(WeldTool.welding_start_to:GetLocation(), "NanosWorld::A_VR_Click_03", false, true, SoundType.SFX, 0.15, 0.85)
				return
			end
		end

		-- If didn't hit anything, plays a negative sound
		Sound(Vector(), "NanosWorld::A_Invalid_Action", true, true, SoundType.SFX, 1)
	end)
end

Events:Subscribe("PickUpToolGun_WeldTool", function(tool, character)
	HandleWeldTool(tool)
end)

Events:Subscribe("DropToolGun_WeldTool", function(tool, character)
	tool:Unsubscribe("Fire")

	if (WeldTool.welding_start_to) then
		WeldTool.welding_start_to:SetHighlightEnabled(false)
		WeldTool.welding_start_to = nil
	end
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("NanosWorld", "tools", "WeldTool", "Weld", "assets/NanosWorld/SK_Blaster.jpg")