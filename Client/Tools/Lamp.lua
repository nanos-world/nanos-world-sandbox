-- Method to handle when Player picks up the Tool
function HandleLampTool(weapon)
	-- Subscribe when the player fires with this weapon
	weapon:Subscribe("Fire", function(weapon, shooter)
		-- Makes a trace 10000 units ahead
		local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn)

		if (trace_result.Success) then
			-- Calls remote to spawn the Lamp
			Events:CallRemote("SpawnLamp", {trace_result.Location, trace_result.Normal, trace_result.Entity})
		else
			-- If didn't hit anything, plays a negative sound
			Sound(Vector(), "NanosWorld::A_Invalid_Action", true, true, SoundType.SFX, 1)
		end
	end)
end

Events:Subscribe("PickUpToolGun_LampTool", function(tool)
	HandleLampTool(tool)
end)

Events:Subscribe("DropToolGun_LampTool", function(tool)
	tool:Unsubscribe("Fire")
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("NanosWorld", "tools", "LampTool", "Lamps", "assets///NanosWorld/Thumbnails/SK_Blaster.jpg")