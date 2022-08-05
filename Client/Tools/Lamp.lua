-- Method to handle when Player picks up the Tool
function HandleLampTool(weapon)
	-- Subscribe when the player fires with this weapon
	weapon:Subscribe("Fire", function(weapon, shooter)
		-- Makes a trace 10000 units ahead
		local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn)

		if (trace_result.Success) then
			local relative_location = nil
			local relative_rotation = nil

			if (trace_result.Entity) then
				relative_location, relative_rotation = NanosMath.RelativeTo(trace_result.Location, trace_result.Normal:Rotation(), trace_result.Entity)
			end

			-- Calls remote to spawn the Lamp
			Events.CallRemote("SpawnLamp", trace_result.Location, relative_location, relative_rotation, trace_result.Normal, trace_result.Entity)
		else
			-- If didn't hit anything, plays a negative sound
			Sound(Vector(), "nanos-world::A_Invalid_Action", true, true, SoundType.SFX, 1)
		end
	end)
end

Events.Subscribe("PickUpToolGun_LampTool", function(tool)
	HandleLampTool(tool)
end)

Events.Subscribe("DropToolGun_LampTool", function(tool)
	tool:Unsubscribe("Fire")
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "tools", "LampTool", "Lamps", "package://sandbox/Client/Tools/Lamp.jpg", nil, {
	{ key = "LeftClick", text = "spawn lamp" },
	{ key = "Undo", text = "undo spawn" },
})