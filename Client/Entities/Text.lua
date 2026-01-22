Text = Prop.Inherit("Text")

Text.name = "Floating Text"
Text.image = "package://sandbox/Client/Entities/Text.webp"
Text.category = "uncategorized"


-- Context Menu Items when selecting this Entity
Text.selected_context_menu_items = {
	{
		id = "text_text",
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
		id = "text_color",
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
		id = "text_word_size",
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