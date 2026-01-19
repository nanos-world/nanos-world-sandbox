ColorGun = ToolGun.Inherit("ColorGun")

-- Tool Name
ColorGun.name = "Color"

-- Tool Image
ColorGun.image = "package://sandbox/Client/Tools/ColorGun.webp"

-- Tool Tutorials
ColorGun.tutorials = {
	{ key = "LeftClick", text = "paint object" },
	{ key = "ContextMenu", text = "color gun settings" },
}

-- Color Gun Configuration
ColorGun.color = Color.RandomPalette()

-- Tool Crosshair Trace Debug Settings
ColorGun.crosshair_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	color_entity = Color.GREEN,
	color_no_entity = Color.RED,
}

-- Context Menu Items when picking up this Tool
ColorGun.picked_context_menu_items = {
	{
		id = "color_gun_color",
		type = "color",
		label = "color",
		callback = function(value)
			ColorGun.color = Color.FromHEX(value)
		end,
		value = function()
			return ColorGun.color:ToHex(false)
		end
	},
}


-- Overrides ToolGun method
function ColorGun:OnLocalPlayerFire(shooter)
	local trace_result = TraceFor(10000, ColorGun.crosshair_trace.collision_channel)

	-- If hit an object, then get a random Color and call server to update the color for everyone
	if (trace_result.Success and trace_result.Entity and not trace_result.Entity:HasAuthority()) then
		Events.CallRemote("ColorObject", trace_result.Entity, trace_result.Location, trace_result.Normal, ColorGun.color)
	else
		-- If didn't hit anything, plays a negative sound
		SoundInvalidAction:Play()
	end
end