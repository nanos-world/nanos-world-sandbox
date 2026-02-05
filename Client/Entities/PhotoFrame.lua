PhotoFrame = Prop.Inherit("PhotoFrame")

PhotoFrame.name = "Photo Frame"
PhotoFrame.image = "package://sandbox/Client/Entities/PhotoFrame.webp"
PhotoFrame.category = "display"


-- Context Menu Items when selecting this Entity
PhotoFrame.selected_context_menu_items = {
	{
		id = "photoframe_image",
		type = "text",
		multiline = true,
		label = "image",
		placeholder = "enter image url or base64...",
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetPhoto", value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetMaterialTextureParameter("Texture", 1) or ""
		end,
	},
}