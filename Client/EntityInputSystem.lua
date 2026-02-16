EntityInputSystem = {
	-- List of all binding names
	binding_names = {},

	-- List of all entities with bound inputs
	bound_entities = {},

	-- For generating unique IDs for bound inputs
	__last_bound_input_id = 0,
}

-- Exposes EntityInputSystem to other packages
Sandbox.EntityInputSystem = EntityInputSystem


Package.Subscribe("Load", function()
	-- Loads all Binding Names
	EntityInputSystem.binding_names = {
		{ id = "", name = "No Binding" }
	}

	-- Adds Scripting Key Bindings
	local scripting_key_bindings = Input.GetScriptingKeyBindings()

	for binding, keys in pairs(scripting_key_bindings) do
		table.insert(EntityInputSystem.binding_names, {
			id = binding,
			name = binding .. " (" .. (keys[1] and keys[1] or "no key associated") .. ")"
		})
	end

	-- Adds Game Key Bindings
	local game_key_bindings = Input.GetGameKeyBindings()

	for binding, keys in pairs(game_key_bindings) do
		table.insert(EntityInputSystem.binding_names, {
			id = binding,
			name = binding .. " (" .. (keys[1] and keys[1] or "no key associated") .. ")"
		})
	end

	-- Sorts the binding names by ID
	table.sort(EntityInputSystem.binding_names, function(a, b)
		return a.id < b.id
	end)
end)

Input.Subscribe("KeyBindingChange", function(binding, key)
	-- Updates the name of the changed binding in the list of binding names
	for _, binding_data in pairs(EntityInputSystem.binding_names) do
		if (binding_data.id == binding) then
			binding_data.name = binding .. " (" .. (key or "no key associated") .. ")"
		end
	end
end)

-- Adds an input binding to an entity
function EntityInputSystem.AddEntityBinding(entity, name, binding, callback_pressed, callback_released)

	local bound_entity = EntityInputSystem.bound_entities[entity]
	if (not bound_entity) then
		bound_entity = {}
		EntityInputSystem.bound_entities[entity] = bound_entity
	end

	local bound_binding = bound_entity[name]
	if (bound_binding) then
		-- Removes existing bindings
		EntityInputSystem.RemoveEntityBinding(entity, name)
	end

	local callback_pressed_wrapper = nil
	local callback_released_wrapper = nil

	-- Creates wrapper so it can capture entity variable
	if (callback_pressed) then
		callback_pressed_wrapper = function()
			-- Calls the callback passing entity as parameter
			callback_pressed(entity)
		end

		Input.Bind(binding, InputEvent.Pressed, callback_pressed_wrapper)
	end

	if (callback_released) then
		callback_released_wrapper = function()
			-- Calls the callback passing entity as parameter
			callback_released(entity)
		end

		Input.Bind(binding, InputEvent.Released, callback_released_wrapper)
	end

	local callback_destroyed = function(_entity)
		EntityInputSystem.RemoveEntityBinding(_entity, name)
	end

	bound_entity[name] = {
		binding = binding,
		callback_pressed = callback_pressed_wrapper,
		callback_released = callback_released_wrapper,
		callback_destroyed = callback_destroyed
	}

	entity:SetValue("Binding_" .. name, binding)

	entity:Subscribe("Destroy", callback_destroyed)

end

-- Removes an input binding from an entity
function EntityInputSystem.RemoveEntityBinding(entity, name)

	local bound_entity = EntityInputSystem.bound_entities[entity]
	if (not bound_entity) then return end

	local bound_binding = bound_entity[name]
	if (not bound_binding) then return end

	if (bound_binding.callback_pressed) then
		Input.Unbind(bound_binding.binding, InputEvent.Pressed, bound_binding.callback_pressed)
	end

	if (bound_binding.callback_released) then
		Input.Unbind(bound_binding.binding, InputEvent.Released, bound_binding.callback_released)
	end

	if (entity:IsValid() and not entity:IsBeingDestroyed()) then
		entity:SetValue("Binding_" .. name, "")

		if (bound_binding.callback_destroyed) then
			entity:Unsubscribe("Destroy", bound_binding.callback_destroyed)
		end
	end

	bound_entity[name] = nil
end

-- Removes an input binding from an entity
function EntityInputSystem.ParseInputBindingsForContextMenu(class)

	if (not class.input_bindings) then return {} end

	local parsed_bindings = {}
	for _, binding_data in pairs(class.input_bindings) do

		-- Generates random ID if not passing one
		if (not binding_data.id) then
			-- Increases ID global count
			EntityInputSystem.__last_bound_input_id = EntityInputSystem.__last_bound_input_id + 1

			binding_data.id = "bound_input_" .. tostring(EntityInputSystem.__last_bound_input_id)
		end

		table.insert(parsed_bindings, {
			label = binding_data.label,
			type = "select",
			options = EntityInputSystem.binding_names,
			callback = function(value)
				local entity = ContextMenu.selected_entity

				-- Empty means No Binding
				if (value ~= "") then
					EntityInputSystem.AddEntityBinding(entity, binding_data.id, value, binding_data.callback_pressed, binding_data.callback_released)
				else
					EntityInputSystem.RemoveEntityBinding(entity, binding_data.id)
				end
			end,
			value = function()
				return ContextMenu.selected_entity:GetValue("Binding_" .. binding_data.id) or ""
			end
		})
	end

	return parsed_bindings
end