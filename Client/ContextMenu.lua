ContextMenuOpened = ContextMenuOpened or false

Input.Bind("ContextMenu", InputEvent.Pressed, function()
	if (ContextMenuOpened) then
		MainHUD:CallEvent("ToggleContextMenuVisibility", false)

		Client.SetInputEnabled(true)
		Client.SetMouseEnabled(false)
		Client.SetChatVisibility(true)

		ContextMenuOpened = false
	else
		-- Opens context menu with updated data
		local time = World.GetTime()
		MainHUD:CallEvent("ToggleContextMenuVisibility", true, time.hours, time.minutes)

		Client.SetInputEnabled(false)
		Client.SetMouseEnabled(true)
		Client.SetChatVisibility(false)

		MainHUD:BringToFront()
		MainHUD:SetFocus()

		ContextMenuOpened = true
	end
end)

-- Called from Context Menu when pressing X
MainHUD:Subscribe("CloseContextMenu", function()
	Client.SetInputEnabled(true)
	Client.SetMouseEnabled(false)
	Client.SetChatVisibility(true)
	ContextMenuOpened = false
end)

-- Called from Context Menu
MainHUD:Subscribe("ChangeTimeOfDay", function(hours, minutes)
	World.SetTime(hours, minutes)
end)
