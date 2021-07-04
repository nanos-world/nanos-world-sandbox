-- Method to handle when Player picks up the Tool
function HandleTrailTool(weapon)
	-- Subscribe when the player fires with this weapon
	weapon:Subscribe("Fire", function(weapon, shooter)
		-- Makes a trace 10000 units ahead to spawn the balloon
		local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn)

		-- If hit some object, then spawns a trail on attached it
		if (trace_result.Success and trace_result.Entity) then
			Events.CallRemote("SpawnTrail", trace_result.Location, trace_result.Normal, trace_result.Entity)
		else
			-- If didn't hit anything, plays a negative sound
			Sound(Vector(), "NanosWorld::A_Invalid_Action", true, true, SoundType.SFX, 1)
		end
	end)
end

Events.Subscribe("PickUpToolGun_TrailTool", function(tool, character)
	HandleTrailTool(tool)
end)

Events.Subscribe("DropToolGun_TrailTool", function(tool, character)
	tool:Unsubscribe("Fire")
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("NanosWorld", "tools", "TrailTool", "Trail", "assets///NanosWorld/Thumbnails/SK_Blaster.jpg")