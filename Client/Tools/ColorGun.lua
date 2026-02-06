ColorGun = ToolGunSingleTarget.Inherit("ColorGun")

-- Tool Info
ColorGun.name = "Color"
ColorGun.image = "package://sandbox/Client/Media/Tools/ColorGun.webp"
ColorGun.description = "Paint props and objects with a selected color"

-- Tool Tutorials
ColorGun.tutorials = {
	{ key = "LeftClick", text = "paint object" },
	{ key = "ContextMenu", text = "color gun settings" },
}

-- Color Gun Configuration
ColorGun.color = Color.RandomPalette()

-- Tool Trace Debug Settings
ColorGun.debug_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	show_crosshair = true,
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


-- Overrides ToolGunSingleTarget method
function ColorGun:OnLocalPlayerTarget(location, relative_location, relative_rotation, normal, entity)
	-- Calls remote to spawn the Lamp
	Events.CallRemote("ColorObject", entity, location, normal, ColorGun.color)
end