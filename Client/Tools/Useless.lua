-- Method to handle when Player picks up the Tool
function HandleUselessTool(tool)
	-- Subscribe when the player fires with this weapon
	tool:Subscribe("Fire", function(weapon, shooter)
		-- Makes a trace 10000 units ahead
		local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn)

		-- If hit an object, then get a random Useless and call server to update the Useless for everyone
		if (trace_result.Success and trace_result.Entity and not trace_result.Entity:HasAuthority()) then
			Events.CallRemote("UselessObject", trace_result.Entity, trace_result.Location, trace_result.Normal)
		else
			-- If didn't hit anything, plays a negative sound
			Sound(Vector(), "nanos-world::A_Button_Click_Down_Cue", true, true, SoundType.SFX, 4)
		end
	end)
end

Events.Subscribe("MakeObjectUseless", function(entity, website)
	-- Checks if the WebUI already exists
	local website_webui_value = entity:GetValue("MaterialWebUI")

	-- If so, just reloads the page
	if (website_webui_value and website_webui_value:IsValid()) then
		website_webui_value:LoadURL(website)
		return
	end

	-- Spawns the WebUI
	local website_webui = WebUI("", website, false, false, false, 500, 500)

	-- Sets the new WebUI as the Material
	entity:SetMaterialFromWebUI(website_webui)

	-- Stores the WebUI in the entity to be destroyed later
	entity:SetValue("MaterialWebUI", website_webui)

	-- When entity is destroyed, destroy the WebUI as well
	entity:Subscribe("Destroy", function(item)
		local _website_webui_value = item:GetValue("MaterialWebUI")

		if (_website_webui_value and _website_webui_value:IsValid()) then
			_website_webui_value:Destroy()
		end
	end)
end)

Events.Subscribe("PickUpToolGun_UselessTool", function(tool)
	HandleUselessTool(tool)
end)

Events.Subscribe("DropToolGun_UselessTool", function(tool)
	tool:Unsubscribe("Fire")
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "tools", "UselessTool", "Useless", "assets://NanosWorld/Thumbnails/SK_Blaster.webp", nil, {
	{ key = "LeftClick", text = "paint object" }
})