Wheel = Prop.Inherit("Wheel")


-- Context Menu Items when selecting this Entity
Wheel.selected_context_menu_items = {
	{
		type = "range",
		label = "force",
		min = 0,
		max = 10000,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetCustomAngularForce", value * 1000)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("AngularForce") / 1000
		end,
	},
	{
		type = "checkbox",
		label = "active",
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetActive", value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Active")
		end
	},
	{
		type = "checkbox",
		label = "forward",
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetDirection", value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Forward")
		end
	},
}