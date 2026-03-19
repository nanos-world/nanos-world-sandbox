ContextMenu.selected_color = Color.AZURE
ContextMenu.picked_color = Color.AQUAMARINE

-- Adds custom context menu items for selected entities through the Context Menu
function ContextMenu.AddSelectedCustomItems(entity)
	local class = entity:GetClass()
	local category_name = "selected\n" .. class:GetName() .. "#" .. entity:GetID()

	-- If the class has custom context menu items when selected through context menu, adds them
	local entity_context_menu_items = class.selected_context_menu_items
	if (entity_context_menu_items) then
		ContextMenu.AddItems("selected_item", category_name, entity_context_menu_items, ContextMenu.selected_color)
	end

	-- If the class has custom inputs, adds them
	if (class.input_bindings) then
		local parsed_context_menu_items = EntityInputSystem.ParseInputBindingsForContextMenu(class)
		ContextMenu.AddItems("selected_item", category_name, parsed_context_menu_items, ContextMenu.selected_color)
	end

	local items = {}

	-- Basic Actor entries with tint/gravity
	if (class == Prop or entity:IsA(Weapon) or entity:IsA(Melee) or entity:IsA(VehicleWheeled) or entity:IsA(VehicleWater)) then
		table.insert(items, {
			id = "tint",
			type = "color",
			label = "tint",
			value = function ()
				return (ContextMenu.selected_entity:GetMaterialColorParameter("Tint") or Color.WHITE):ToHex(false)
			end,
			callback = function(color)
				Events.CallRemote("ColorObject", ContextMenu.selected_entity, ContextMenu.selected_entity:GetLocation(), Vector(0, 0, 1), Color.FromHEX(color))
			end
		})

		table.insert(items, {
			id = "gravity_enabled",
			type = "checkbox",
			label = "gravity enabled",
			value = function()
				return ContextMenu.selected_entity:IsGravityEnabled()
			end,
			callback = function()
				Events.CallRemote("SetGravityEnabled", ContextMenu.selected_entity)
			end
		})
	end

	-- Prop specific entries
	if (class == Prop) then
		table.insert(items, {
			id = "selected_prop_grabbable",
			type = "checkbox",
			label = "grabbable",
			value = function()
				return entity:GetGrabMode() ~= GrabMode.Disabled
			end,
			callback = function(value)
				Events.CallRemote("SetPropGrabMode", entity, value)
			end
		})
	end

	-- Weapon specific entries
	if (entity:IsA(Weapon) and not entity:IsA(ToolGun)) then
		table.insert(items, {
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
		})
	end

	local is_player = (entity:IsA(Character) or entity:IsA(CharacterSimple)) and entity:GetPlayer() ~= nil

	if (not is_player) then
		-- All entities
		table.insert(items, {
			id = "destroy_button",
			type = "button",
			label = "destroy",
			callback = function()
				Events.CallRemote("DestroyItem", ContextMenu.selected_entity)
				ContextMenu.SelectEntity(nil)
			end
		})
	end

	-- Inserts all items
	ContextMenu.AddItems("selected_item", category_name, items, ContextMenu.selected_color)
end

-- Adds custom context menu items for picked entities through the Context Menu
function ContextMenu.AddPickedCustomItems(entity)
	local class = entity:GetClass()
	local category_name = "picked\n" .. class:GetName() .. "#" .. entity:GetID()

	-- If the class has custom context menu items when picking up through context menu, adds them
	local context_menu_items = class.picked_context_menu_items
	if (context_menu_items) then
		ContextMenu.AddItems("picked_item", category_name, context_menu_items, ContextMenu.picked_color)
	end

	-- Adds Weapon Pattern Customization to Context Menu
	if (entity:IsA(Weapon) and not entity:IsA(ToolGun) and not class.tab) then
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
		}, ContextMenu.picked_color)
	end
end

-- Adds custom context menu item for customizing the character through the Context Menu
function ContextMenu.AddPossessedCharacterItems(entity)
	local class = entity:GetClass()

	local character_classes = {}

	for k, character_class in pairs(Character.GetInheritedClasses(true)) do
		if (character_class.name ~= nil) then
			table.insert(character_classes, {
				id = character_class:GetName(),
				name = character_class.name,
				image = character_class.image
			})
		end
	end

	for k, character_class in pairs(CharacterSimple.GetInheritedClasses(true)) do
		if (character_class.name ~= nil) then
			table.insert(character_classes, {
				id = character_class:GetName(),
				name = character_class.name,
				image = character_class.image
			})
		end
	end

	ContextMenu.AddItems("possessed_character", "character", {
		{
			type = "select_image",
			label = "character",
			options = character_classes,
			callback = function(value)
				Events.CallRemote("ChangeCharacter", value)
			end,
			value = class:GetName(),
		},
	})
end