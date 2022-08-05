-- Method to handle when Player picks up the Tool
function HandleThrusterTool(weapon)
	-- Subscribe when the player fires with this weapon
	weapon:Subscribe("Fire", function(weapon, shooter)
		-- Makes a trace 10000 units ahead to spawn the balloon
		local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle)

		-- If hit some object, then spawns a thruster on attached it
		if (trace_result.Success and trace_result.Entity and not NanosUtils.IsA(trace_result.Entity, Character) and not trace_result.Entity:HasAuthority()) then
			local thruster_rotation = (trace_result.Normal * -1):Rotation()
			local relative_location, relative_rotation = NanosMath.RelativeTo(trace_result.Location, thruster_rotation, trace_result.Entity)

			Events.CallRemote("SpawnThruster", trace_result.Location, relative_location, relative_rotation, trace_result.Normal, trace_result.Entity)
		else
			-- If didn't hit anything, plays a negative sound
			Sound(Vector(), "nanos-world::A_Invalid_Action", true, true, SoundType.SFX, 1)
		end
	end)
end

Events.Subscribe("PickUpToolGun_ThrusterTool", function(tool, character)
	HandleThrusterTool(tool)
end)

Events.Subscribe("DropToolGun_ThrusterTool", function(tool, character)
	tool:Unsubscribe("Fire")
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "tools", "ThrusterTool", "Thruster", "package://sandbox/Client/Tools/Thruster.jpg", nil, {
	{ key = "LeftClick", text = "spawn thruster" },
	{ key = "Undo", text = "undo spawn" },
})