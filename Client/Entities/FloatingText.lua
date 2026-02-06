FloatingText = Prop.Inherit("FloatingText")

FloatingText.name = "Floating Text"
FloatingText.image = "package://sandbox/Client/Media/Entities/FloatingText.webp"
FloatingText.category = "display"


-- Context Menu Items when selecting this Entity
FloatingText.selected_context_menu_items = {
	{
		id = "floating_text_text",
		type = "text",
		multiline = true,
		label = "text",
		placeholder = "enter text...",
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetText", value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("TextRender"):GetText()
		end,
	},
	{
		id = "floating_text_color",
		type = "color",
		label = "color",
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetColor", Color.FromHEX(value))
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("TextRender"):GetColor():ToHex(false)
		end,
	},
	{
		id = "floating_text_word_size",
		type = "range",
		label = "word size",
		min = 1,
		max = 1000,
		auto_update_label = true,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetWordSize", value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("TextRender"):GetWordSize()
		end,
	},
}