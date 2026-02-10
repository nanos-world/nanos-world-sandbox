-- Context Menu data
ContextMenu = {
	-- Whether the menu is opened
	is_opened = false,

	-- Whether the context menu is behind hovered
	is_hovering_context_menu = false,

	-- List of functions called when ContextMenu is opened, to update their current value/label
	update_functions = {},

	-- List of all callbacks registered
	items_callbacks = {},

	-- Current selected item
	-- TODO more than one selection?
	selected_entity = nil,

	-- Current hovering item
	hovering_entity = nil,

	-- Current hovering item text render
	hovering_text_render = nil,
}

-- Exposes ContextMenu to other packages
Sandbox.ContextMenu = ContextMenu


-- TODO new section? Separate "selected" in another category?
ContextMenu.AddItems = function(id, title, items)
	-- We generate another list so we can validate and strip out callback functions
	local items_to_add = {}

	for _, item in pairs(items) do
		if (item.callback) then
			-- Stores the callbacks
			ContextMenu.items_callbacks[item.id] = item.callback

			-- Iterate over all key-value pairs in the original table
			local item_to_add = {}
			for key, value in pairs(item) do
				if (key ~= "callback") then
					if (key == "value" and type(value) == "function") then
						-- Calls the function to get the current value
						item_to_add[key] = value()
					else
						item_to_add[key] = value
					end
				end
			end

			table.insert(items_to_add, item_to_add)
		else
			Console.Error("ContextMenu AddItems: Item " .. item.id .. " has no callback assigned.")
		end
	end

	Sandbox.HUD:CallEvent("AddContextMenuItems", id, title, items_to_add)
end

ContextMenu.RemoveItems = function(id)
	Sandbox.HUD:CallEvent("RemoveContextMenuItems", id)
end

ContextMenu.AddUpdateFunction = function(id, func)
	if (type(func) ~= "function") then
		Console.Error("Invalid function parameter passed.")
		return
	end

	ContextMenu.update_functions[id] = func
end

ContextMenu.RemoveUpdateFunction = function(id)
	ContextMenu.update_functions[id] = nil
end

-- Closes context menu
ContextMenu.Close = function(called_from_context_menu)
	if (not called_from_context_menu) then
		Sandbox.HUD:CallEvent("ToggleContextMenuVisibility", false)
	end

	Input.SetMouseEnabled(false)
	Chat.SetVisibility(true)

	ContextMenu.is_opened = false
	PlayClickSound(0.9)

	Client.Unsubscribe("Tick", ContextMenu.OnTick)
	Input.Unsubscribe("MouseUp", ContextMenu.OnMouseUp)
	ContextMenu.HoverEntity(nil)
	ContextMenu.SelectEntity(nil)
end

-- Opens context menu
ContextMenu.Open = function()
	Sandbox.HUD:CallEvent("ToggleContextMenuVisibility", true)

	-- Calls all update functions
	for _, func in pairs(ContextMenu.update_functions) do
		func()
	end

	Input.SetMouseEnabled(true)
	Chat.SetVisibility(false)

	Sandbox.HUD:BringToFront()

	ContextMenu.is_opened = true
	ContextMenu.is_hovering_context_menu = false
	PlayClickSound(1.1)

	Client.Subscribe("Tick", ContextMenu.OnTick)
	Input.Subscribe("MouseUp", ContextMenu.OnMouseUp)
end

function ContextMenu.OnTick(delta_time)
	if (ContextMenu.is_hovering_context_menu) then
		return
	end

	-- Get the mouse location in 3D World Space
	local mouse_location = Viewport.GetMousePosition()
	local mouse_3D = Viewport.DeprojectScreenToWorld(mouse_location)
	local start_location = mouse_3D.Position

	-- Gets the end location of the trace (5000 units ahead)
	local trace_max_distance = 5000
	local end_location = start_location + mouse_3D.Direction * trace_max_distance

	-- Determine at which object we will be tracing for (WorldStatic = StaticMeshes; PhysicsBody = Props; Mesh = Characters; Vehicle = Vehicles)
	local collision_trace = CollisionChannel.WorldStatic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Mesh

	-- Sets the trace modes (we want it to return Entity)
	local trace_mode = TraceMode.ReturnEntity | TraceMode.TraceOnlyVisibility

	-- Sets the ignored actors (the local player's character)
	local ignored_actors = {}

	local local_player = Client.GetLocalPlayer()
	if (local_player) then
		local character = local_player:GetControlledCharacter()
		if (character) then
			table.insert(ignored_actors, character)
		end
	end

	-- Do the Trace
	local trace_result = Trace.LineSingle(start_location, end_location, collision_trace, trace_mode, ignored_actors)

	if (trace_result.Success and trace_result.Entity) then
		if (ContextMenu.hovering_entity ~= trace_result.Entity) then
			ContextMenu.HoverEntity(trace_result.Entity)
		end
	else
		ContextMenu.HoverEntity(nil)
	end

	if (
		ContextMenu.hovering_entity and ContextMenu.hovering_entity:IsValid() and
		ContextMenu.hovering_text_render and ContextMenu.hovering_text_render:IsValid()
	) then
		local bounds = ContextMenu.hovering_entity:GetBounds()
		ContextMenu.hovering_text_render:SetLocation(bounds.Origin + Vector(0, 0, bounds.BoxExtent.Z + 40))
	end
end

function ContextMenu.HoverEntity(entity)
	if (ContextMenu.hovering_entity and ContextMenu.hovering_entity:IsValid()) then
		-- Skips if the same
		if (ContextMenu.hovering_entity == entity) then
			return
		end

		-- Only changes outline if not the selected one
		if (ContextMenu.selected_entity ~= ContextMenu.hovering_entity) then
			ContextMenu.hovering_entity:SetOutlineEnabled(false)
		end
	end

	ContextMenu.hovering_entity = entity

	if (entity) then
		-- Only changes outline if not the selected one
		if (ContextMenu.selected_entity ~= entity) then
			entity:SetOutlineEnabled(true, 0)
		end

		Input.SetMouseCursor(CursorType.Hand)
		PlayHoverSound()

		-- Updates or Creates Text Render
		local text_render_text = entity:GetClass():GetName() .. "#" .. tostring(entity:GetID())
		if (ContextMenu.hovering_text_render and ContextMenu.hovering_text_render:IsValid()) then
			ContextMenu.hovering_text_render:SetText(text_render_text)
			ContextMenu.hovering_text_render:SetVisibility(true)
		else
			ContextMenu.hovering_text_render = TextRender(entity:GetLocation(), Rotator(), text_render_text, 30, Color.GREEN, TextRenderRenderingType.UnlitCameraAlignedDepth, TextRenderHorizontalAlignment.Center, TextRenderVerticalAlignment.Center, "nanos-world::Font_LondrinaSolid_DistanceField")
		end

		local spawned_by = entity:GetValue("SpawnedBy")
		local spawned_by_player = nil
		local spawned_by_time = nil

		if (spawned_by) then
			spawned_by_player = spawned_by.player_name .. " (" .. spawned_by.player_steam_id .. ")"
			spawned_by_time = spawned_by.time;
		end

		Sandbox.HUD:CallEvent("SetHoverEntity", true, text_render_text, spawned_by_player, spawned_by_time)
	else
		Input.SetMouseCursor(CursorType.Default)

		-- Hides Text Render
		if (ContextMenu.hovering_text_render and ContextMenu.hovering_text_render:IsValid()) then
			ContextMenu.hovering_text_render:SetVisibility(false)
		end

		Sandbox.HUD:CallEvent("SetHoverEntity", false)
	end
end

function ContextMenu.SelectEntity(entity)
	if (ContextMenu.selected_entity and ContextMenu.selected_entity:IsValid()) then
		-- Skips if the same
		if (ContextMenu.selected_entity == entity) then
			return
		end

		ContextMenu.selected_entity:Unsubscribe("Destroy", ContextMenu.OnSelectedEntityDestroy)
		ContextMenu.selected_entity:SetOutlineEnabled(false)
		ContextMenu.RemoveItems("selected_item")
	end

	ContextMenu.selected_entity = entity

	if (entity) then
		entity:Subscribe("Destroy", ContextMenu.OnSelectedEntityDestroy)

		entity:SetOutlineEnabled(true, 2)
		PlayClickSound(1.2)

		-- Adds custom items for the class, defined in ContextMenuDefaults.lua
		ContextMenu.AddSelectedCustomItems(entity)
	else
		PlayClickSound(0.8)
	end
end

function ContextMenu.OnSelectedEntityDestroy(entity)
	ContextMenu.SelectEntity(nil)
end

function ContextMenu.OnMouseUp(key_name)
	if (ContextMenu.is_hovering_context_menu) then
		return
	end

	-- Left Lick selects
	if (key_name == "LeftMouseButton") then
		if (ContextMenu.hovering_entity and ContextMenu.hovering_entity:IsValid()) then
			ContextMenu.SelectEntity(ContextMenu.hovering_entity)
		end
		return
	end

	-- Right Click deselects
	if (key_name == "RightMouseButton") then
		if (ContextMenu.selected_entity and ContextMenu.selected_entity:IsValid()) then
			ContextMenu.SelectEntity(nil)
		end
		return
	end
end

Input.Bind("ContextMenu", InputEvent.Pressed, function()
	if (SpawnMenu.is_opened) then return end

	if (ContextMenu.is_opened) then
		ContextMenu.Close()
	else
		ContextMenu.Open()
	end
end)

Sandbox.HUD:Subscribe("ContextMenu_SetHovering", function(is_hovering_context_menu)
	ContextMenu.is_hovering_context_menu = is_hovering_context_menu

	-- If was hovering an entity, stops
	if (is_hovering_context_menu and ContextMenu.hovering_entity and ContextMenu.hovering_entity:IsValid()) then
		ContextMenu.HoverEntity(nil)
	end
end)

Sandbox.HUD:Subscribe("ContextMenu_Callback", function(id, value)
	-- Skips if Context Menu was already closed
	if (not ContextMenu.is_opened) then return end

	local callback = ContextMenu.items_callbacks[id]

	if (not callback) then
		Console.Error("Context Menu Callback: '" .. id .. "' has no registered callback.")
		return
	end

	callback(value)
end)

-- Called from Context Menu when pressing X
Sandbox.HUD:Subscribe("CloseContextMenu", function()
	ContextMenu.Close(true)
end)

Sandbox.HUD:Subscribe("Ready", function()
	-- Common
	ContextMenu.AddItems("common", "common", {
		{ id = "respawn_button", type = "button", label = "respawn",
			callback = function()
				Events.CallRemote("RespawnCharacter")
			end
		},
	})
end)


Package.Require("ContextMenuDefaults.lua")