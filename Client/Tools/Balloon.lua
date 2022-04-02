-- Method to handle when Player picks up the Tool
function HandleBalloonTool(weapon)
	-- Subscribe when the player fires with this weapon
	weapon:Subscribe("Fire", function(weapon, shooter)
		-- Makes a trace 10000 units ahead to spawn the balloon
		local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn)

		if (trace_result.Success) then
			local distance_trace_object = Vector()
			if (trace_result.Entity and trace_result.Entity:IsNetworkDistributed()) then
				-- If hit an entity, then calculates the offset distance from the Hit and the Object
				distance_trace_object = trace_result.Entity:GetLocation() - trace_result.Location
			end

			-- Balloon Upwards force
			-- TODO: make a menu to client define the force manually
			local force = math.random() * 10000 + 95000

			-- Balloon rope length
			-- TODO: make a menu to client define the rope manually
			local max_length = math.random() * 50 + 75

			-- Calls remote to spawn the Balloon
			Events.CallRemote("SpawnBalloon", trace_result.Location, trace_result.Normal:Rotation(), force, max_length, trace_result.Entity, distance_trace_object)
		else
			-- If didn't hit anything, plays a negative sound
			Sound(Vector(), "nanos-world::A_Invalid_Action", true, true, SoundType.SFX, 1)
		end
	end)

	-- Sets some notification when grabbing the Balloon Tool
	AddNotification("BALLOONS_POP", "balloons will start to pop if they reach a very high height", 5000, 5000)
end

Events.Subscribe("PickUpToolGun_BalloonTool", function(tool)
	HandleBalloonTool(tool)
end)

Events.Subscribe("DropToolGun_BalloonTool", function(tool)
	tool:Unsubscribe("Fire")
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "tools", "BalloonTool", "Balloons", "assets///NanosWorld/Thumbnails/SK_Blaster.jpg", nil, {
	{ key = "LeftClick", text = "spawn balloon" },
	{ key = "Undo", text = "undo spawn" },
})