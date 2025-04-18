UselessGun = ToolGun.Inherit("UselessGun")

-- Tool Name
UselessGun.name = "Useless Gun"

-- Tool Image
UselessGun.image = "package://sandbox/Client/Tools/UselessGun.webp"

-- Tool Tutorials
UselessGun.tutorials = {
	{ key = "LeftClick", text = "make object useless" }
}

-- Tool Crosshair Trace Debug Settings
UselessGun.crosshair_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	color_entity = Color.GREEN,
	color_no_entity = Color.RED,
}


-- Overrides ToolGun method
function UselessGun:OnLocalPlayerFire(shooter)
	-- Makes a trace 10000 units ahead
	local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn)

	-- If hit an object, then get a random Useless and call server to update the Useless for everyone
	if (trace_result.Success and trace_result.Entity and not trace_result.Entity:HasAuthority()) then
		self:CallRemoteEvent("UselessObject", trace_result.Entity, trace_result.Location, trace_result.Normal)
	else
		-- If didn't hit anything, plays a negative sound
		SoundInvalidAction:Play()
	end
end


Events.SubscribeRemote("MakeObjectUseless", function(entity, website)
	-- Checks if the WebUI already exists
	local website_webui_value = entity:GetValue("MaterialWebUI")

	-- If so, just reloads the page
	if (website_webui_value and website_webui_value:IsValid()) then
		website_webui_value:LoadURL(website)
		return
	end

	-- Spawns the WebUI
	local website_webui = WebUI("useless-object", website, WidgetVisibility.Hidden, false, false, 500, 500)

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
