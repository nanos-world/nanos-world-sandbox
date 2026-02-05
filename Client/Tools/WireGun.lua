WireGun = ToolGunDoubleTarget.Inherit("WireGun")

-- Tool Name, Category and Image
WireGun.name = "Wire Gun"
WireGun.image = "package://sandbox/Client/Tools/WireGun.webp"

WireGun.description = "Connects two devices with a wire, to enable interactions between them"

-- Tool Tutorials
WireGun.tutorials = {
	{ key = "LeftClick",	text = "wire/unwire object" },
	-- { key = "Undo", text = "undo attach" },
}

-- Tool Trace Debug Settings
WireGun.debug_trace = {
	collision_channel = CollisionChannel.PhysicsBody,
	show_crosshair = true,
}

-- Context Menu Items when picking up this Tool
WireGun.picked_context_menu_items = {
	{
		id = "wire_gun_color",
		type = "color",
		label = "color",
		callback = function(value)
			WireGun.wire_color = Color.FromHEX(value)
		end,
		value = function()
			return WireGun.wire_color:ToHex(false)
		end
	},
	{
		id = "wire_gun_show_wire",
		type = "checkbox",
		label = "show wire",
		callback = function(value)
			WireGun.show_wire = value
		end,
		value = function()
			return WireGun.show_wire
		end
	},
}

-- WireGun Configurations
WireGun.wire_color = Color.BLACK
WireGun.show_wire = true


-- Overrides ToolGunDoubleTarget method
function WireGun:OnLocalPlayerTarget(targeting_first_to, targeting_first_relative_location, targeting_first_relative_rotation, targeting_second_to, targeting_second_location, targeting_second_rotation)
	-- TODO test if can wire these two entities on client side?

	-- Calls remote to attach wire
	self:CallRemoteEvent("Wire", targeting_first_to, targeting_second_to, WireGun.show_wire, WireGun.wire_color)
end