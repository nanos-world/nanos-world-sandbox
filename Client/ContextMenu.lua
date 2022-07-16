ContextMenuOpened = ContextMenuOpened or false

Input.Bind("ContextMenu", InputEvent.Pressed, function()
	if (ContextMenuOpened) then
		MainHUD:CallEvent("ToggleContextMenuVisibility", false)

		Client.SetMouseEnabled(false)
		Client.SetChatVisibility(true)

		ContextMenuOpened = false
	else
		-- Opens context menu with updated data
		local time = World.GetTime()
		MainHUD:CallEvent("ToggleContextMenuVisibility", true, time.hours, time.minutes)

		Client.SetMouseEnabled(true)
		Client.SetChatVisibility(false)

		MainHUD:BringToFront()

		ContextMenuOpened = true
	end
end)

-- Called from Context Menu when pressing X
MainHUD:Subscribe("CloseContextMenu", function()
	Client.SetMouseEnabled(false)
	Client.SetChatVisibility(true)
	ContextMenuOpened = false
end)

-- Called from Context Menu
MainHUD:Subscribe("ChangeTimeOfDay", function(hours, minutes)
	World.SetTime(hours, minutes)
end)

MainHUD:Subscribe("LockTimeOfDay", function(lock)
	if lock then
		World.SetSunSpeed(0)
	else
		World.SetSunSpeed(60)
	end
end)

MainHUD:Subscribe("RespawnButton", function()
	Events.CallRemote("RespawnCharacter")
end)
