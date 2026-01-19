
-- Adds custom context menu items for selected entities through the Context Menu
function ContextMenu.AddSelectedCustomItems(entity)
	local class = entity:GetClass()
	local category_name = "selected\n" .. class:GetName() .. "#" .. entity:GetID()

	-- If the class has custom context menu items when selected through context menu, adds them
	local entity_context_menu_items = class.selected_context_menu_items
	if (entity_context_menu_items) then
		ContextMenu.AddItems("selected_item", category_name, entity_context_menu_items)
	end

	-- Basic Actor entries
	ContextMenu.AddItems("selected_item", category_name, {
		{
			id = "tint",
			type = "color",
			label = "tint",
			value = function ()
				return (ContextMenu.selected_entity:GetMaterialColorParameter("Tint") or Color.WHITE):ToHex(false)
			end,
			callback = function(color)
				Events.CallRemote("ColorObject", ContextMenu.selected_entity, ContextMenu.selected_entity:GetLocation(), Vector(0, 0, 1), Color.FromHEX(color))
			end
		},
		{
			id = "gravity_enabled",
			type = "checkbox",
			label = "gravity enabled",
			value = function()
				return ContextMenu.selected_entity:IsGravityEnabled()
			end,
			callback = function()
				Events.CallRemote("SetGravityEnabled", ContextMenu.selected_entity)
			end
		},
		{
			id = "destroy_button",
			type = "button",
			label = "destroy",
			callback = function()
				Events.CallRemote("DestroyItem", ContextMenu.selected_entity)
				ContextMenu.SelectEntity(nil)
			end
		},
	})

	-- Weapon specific entries
	if (entity:IsA(Weapon) and not entity:IsA(ToolGun)) then
		ContextMenu.AddItems("selected_item", category_name, {
			{
				id = "selected_weapon_pattern",
				type = "select_image",
				label = "pattern",
				options = WEAPON_PATTERNS,
				value = function()
					return ContextMenu.selected_entity:GetValue("PatternTexture") or ""
				end,
				callback = function(value)
					Events.CallRemote("ApplyWeaponPattern", ContextMenu.selected_entity, value)
				end
			},
		})
	end
end

-- Adds custom context menu items for picked entities through the Context Menu
function ContextMenu.AddPickedCustomItems(entity)
	local class = entity:GetClass()
	local category_name = "picked\n" .. class:GetName() .. "#" .. entity:GetID()

	-- If the class has custom context menu items when picking up through context menu, adds them
	local context_menu_items = class.picked_context_menu_items
	if (context_menu_items) then
		ContextMenu.AddItems("picked_item", category_name, context_menu_items)
	end

	-- Adds Weapon Pattern Customization to Context Menu
	if (entity:IsA(Weapon) and not entity:IsA(ToolGun)) then
		ContextMenu.AddItems("picked_item", category_name, {
			{
				id = "picked_weapon_pattern",
				type = "select_image",
				label = "pattern",
				options = WEAPON_PATTERNS,
				value = function()
					return entity:GetValue("PatternTexture") or ""
				end,
				callback = function(value)
					Events.CallRemote("ApplyWeaponPattern", entity, value)
				end
			},
		})
	end
end