Sign = Prop.Inherit("Sign")

Sign.name = "Sign"
Sign.image = "package://sandbox/Client/Media/Entities/Sign.webp"
Sign.category = "display"

-- Context Menu Items when selecting this Entity
Sign.selected_context_menu_items = {
	{
		id = "sign_text",
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
}