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

-- Color Configuration
ColorGun.color = Color.RED

-- Tool Crosshair Trace Debug Settings
ColorGun.crosshair_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	color_entity = Color.GREEN,
	color_no_entity = Color.RED,
}

-- Overrides ToolGun method
function ColorGun:OnLocalPlayerFire(shooter)
	local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn)

	-- If hit an object, then get a random Color and call server to update the color for everyone
	if (trace_result.Success and trace_result.Entity and not trace_result.Entity:HasAuthority()) then
		local color = Color.RandomPalette()
		self:CallRemoteEvent("ColorObject", trace_result.Entity, trace_result.Location, trace_result.Normal, ColorGun.color)
	else
		-- If didn't hit anything, plays a negative sound
		SoundInvalidAction:Play()
	end
end

-- Overrides ToolGun method
function ColorGun:OnLocalPlayerPickUp(character)
	-- Adds an entry to Context Menu
	ContextMenu.AddItems("color_gun", "color gun", {
		{ id = "color_gun_color", type = "color", label = "color", callback_event = "SetColorGunColor", value = ColorGun.color:ToHex(false) },
	})
end

-- Overrides ToolGun method
function ColorGun:OnLocalPlayerDrop(character)
	ContextMenu.RemoveItems("color_gun")
end

-- Subscribes for ContextMenu changes
MainHUD:Subscribe("SetColorGunColor", function(color)
	ColorGun.color = Color.FromHEX(color)
end)