-- Context Menu data
ContextMenu = {
	-- Whether the menu is opened
	is_opened = false,

	-- List of functions called when ContextMenu is opened, to update their current value/label
	update_functions = {}
}

-- Exposes ContextMenu to other packages
Package.Export("ContextMenu", ContextMenu)

ContextMenu.AddItems = function(id, title, items)
	MainHUD:CallEvent("AddContextMenuItems", id, title, items)
end

ContextMenu.RemoveItems = function(id)
	MainHUD:CallEvent("RemoveContextMenuItems", id)
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

Input.Bind("ContextMenu", InputEvent.Pressed, function()
	if (SpawnMenu.is_opened) then return end

	if (ContextMenu.is_opened) then
		MainHUD:CallEvent("ToggleContextMenuVisibility", false)

		Input.SetMouseEnabled(false)
		Chat.SetVisibility(true)

		ContextMenu.is_opened = false
		PlayClickSound(0.9)
	else
		-- Opens context menu
		MainHUD:CallEvent("ToggleContextMenuVisibility", true)

		-- Calls all update functions
		for _, func in pairs(ContextMenu.update_functions) do
			func()
		end

		Input.SetMouseEnabled(true)
		Chat.SetVisibility(false)

		MainHUD:BringToFront()

		ContextMenu.is_opened = true
		PlayClickSound(1.1)
	end
end)

-- Called from Context Menu when pressing X
MainHUD:Subscribe("CloseContextMenu", function()
	Input.SetMouseEnabled(false)
	Chat.SetVisibility(true)
	ContextMenu.is_opened = false

	PlayClickSound(0.9)
end)


-- Common
ContextMenu.AddItems("common", "common", {
	{ id = "respawn_button", type = "button", label = "respawn", callback_event = "ContextMenu_Respawn" },
})

MainHUD:Subscribe("ContextMenu_Respawn", function()
	Events.CallRemote("RespawnCharacter")
end)
-- Common