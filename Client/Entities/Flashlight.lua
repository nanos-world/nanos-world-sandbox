Flashlight = Prop.Inherit("Flashlight")

Flashlight.name = "Flashlight"
Flashlight.image = "assets://nanos-world/Thumbnails/SM_Flashlight.jpg"
Flashlight.category = "objects"

Flashlight.currently_grabbed = nil

-- Context Menu Items when selecting this Entity
Flashlight.selected_context_menu_items = {
	{
		id = "flashlight_color",
		type = "color",
		label = "color",
		callback = function(color)
			ContextMenu.selected_entity:CallRemoteEvent("SetColor", Color.FromHEX(color))
		end,
		value = function()
			return Color.ToHex(ContextMenu.selected_entity:GetValue("Light"):GetColor(), false)
		end
	},
	{
		id = "flashlight_intensity",
		type = "range",
		label = "intensity",
		min = 0,
		max = 1000,
		auto_update_label = true,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetIntensity", value / 100)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Light"):GetIntensity() * 100
		end
	},
	{
		id = "flashlight_active",
		type = "checkbox",
		label = "active",
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetActive", value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Light"):IsVisible()
		end
	},
}


function Flashlight.Toggle()
	Flashlight.currently_grabbed:CallRemoteEvent("ToggleLight")
end

function Flashlight:OnGrab(character)
	Flashlight.currently_grabbed = self

	-- Binds the Input
	Input.Bind("Flashlight", InputEvent.Pressed, Flashlight.Toggle)

	-- Adds tutorial on screen
	Tutorials.Show("Flashlight", "", {
		{ key = "Flashlight", text = "turns on/off the flashlight" }
	})
end

function Flashlight:OnUnGrab(character)
	Flashlight.currently_grabbed = nil

	-- Unbinds from Input
	Input.Unbind("Flashlight", InputEvent.Pressed, Flashlight.Toggle)

	-- Removes tutorial from screen
	Tutorials.Hide()
end

Flashlight.Subscribe("Grab", Flashlight.OnGrab)
Flashlight.Subscribe("UnGrab", Flashlight.OnUnGrab)

-- Registers the Input
Input.Register("Flashlight", "L", "Turns on/off the Flashlight")