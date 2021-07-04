-- Resizer Tool variables
RopeTool = {
	attaching_start_to = nil,
	attaching_start_location = Vector()
}

-- Method to handle when Player picks up the Tool
function HandleRopeTool(tool)
	-- Subscribe when the player fires with this weapon
	tool:Subscribe("Fire", function(weapon, shooter)
		-- Makes a trace 10000 units ahead to spawn the balloon
		local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn)

		-- If hit something
		if (trace_result.Success) then
			-- If is already attaching the start, then tries to attach the end
			if (RopeTool.attaching_start_to) then
				local attaching_end_to = trace_result.Entity
				local attaching_end_location = trace_result.Location

				Events.CallRemote("RopeAttach", RopeTool.attaching_start_to, RopeTool.attaching_start_location, attaching_end_to, attaching_end_location)

				-- Cleans up the variables and the object highlight
				RopeTool.attaching_start_to:SetHighlightEnabled(false)
				RopeTool.attaching_start_to = nil
				RopeTool.attaching_start_location = Vector()

				-- Spawns a "positive" sound for attaching
				Sound(attaching_end_location, "NanosWorld::A_VR_Confirm", false, true, SoundType.SFX, 0.15, 0.85)
				return

			-- If is not yet attached to start
			elseif (trace_result.Entity) then
				RopeTool.attaching_start_to = trace_result.Entity
				RopeTool.attaching_start_location = trace_result.Location

				-- Enable Highlighting on index 0
				RopeTool.attaching_start_to:SetHighlightEnabled(true, 0)

				-- Spawns a "positive" sound for attaching
				Sound(RopeTool.attaching_start_to:GetLocation(), "NanosWorld::A_VR_Click_03", false, true, SoundType.SFX, 0.15, 0.85)
				return
			end
		end

		-- If didn't hit anything, plays a negative sound
		Sound(Vector(), "NanosWorld::A_Invalid_Action", true, true, SoundType.SFX, 1)
	end)
end

Events.Subscribe("PickUpToolGun_RopeTool", function(tool, character)
	HandleRopeTool(tool)
end)

Events.Subscribe("DropToolGun_RopeTool", function(tool, character)
	tool:Unsubscribe("Fire")

	if (RopeTool.attaching_start_to) then
		RopeTool.attaching_start_to:SetHighlightEnabled(false)
		RopeTool.attaching_start_to = nil
		RopeTool.attaching_start_location = Vector()
	end
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("NanosWorld", "tools", "RopeTool", "Rope", "assets///NanosWorld/Thumbnails/SK_Blaster.jpg")