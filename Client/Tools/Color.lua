-- Method to handle when Player picks up the Tool
function HandleColorTool(tool)
	-- Subscribe when the player fires with this weapon
	tool:Subscribe("Fire", function(weapon, shooter)
		-- Makes a trace 10000 units ahead
		local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn)

		-- If hit an object, then get a random Color and call server to update the color for everyone
		if (trace_result.Success and trace_result.Entity and trace_result.Entity:IsNetworkDistributed()) then
			local color = Color.RandomPalette()
			Events.CallRemote("ColorObject", trace_result.Entity, trace_result.Location, trace_result.Normal, color)
		else
			-- If didn't hit anything, plays a negative sound
			Sound(Vector(), "nanos-world::A_Invalid_Action", true, true, SoundType.SFX, 1)
		end
	end)
end

Events.Subscribe("PickUpToolGun_ColorTool", function(tool)
	HandleColorTool(tool)
end)

Events.Subscribe("DropToolGun_ColorTool", function(tool)
	tool:Unsubscribe("Fire")
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "tools", "ColorTool", "Colors", "assets///NanosWorld/Thumbnails/SK_Blaster.jpg", nil, {
	{ key = "LeftClick", text = "paint object" },
})