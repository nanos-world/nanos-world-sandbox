ContextMenuOpened = false

Input.Bind("ContextMenu", InputEvent.Pressed, function()
	if (ContextMenuOpened) then
		main_hud:CallEvent("ToggleContextMenuVisibility", false)

		Client.SetInputEnabled(true)
		Client.SetMouseEnabled(false)
		Client.SetChatVisibility(true)

		ContextMenuOpened = false
	else
		-- Opens context menu with updated data
		local time = World.GetTime()
		main_hud:CallEvent("ToggleContextMenuVisibility", true, time.hours, time.minutes)

		Client.SetInputEnabled(false)
		Client.SetMouseEnabled(true)
		Client.SetChatVisibility(false)

		main_hud:BringToFront()
		main_hud:SetFocus()

		ContextMenuOpened = true
	end
end)

-- Called from Context Menu when pressing X
main_hud:Subscribe("CloseContextMenu", function()
	Client.SetInputEnabled(true)
	Client.SetMouseEnabled(false)
	Client.SetChatVisibility(true)
	ContextMenuOpened = false
end)

-- Called from Context Menu
main_hud:Subscribe("ChangeTimeOfDay", function(hours, minutes)
	World.SetTime(hours, minutes)
end)
