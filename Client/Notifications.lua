-- Base Notifications object
Notifications = {
	-- Caches some common keybindings (Note: this will stay the same even if the player changes the keybindings while in-game)
	common_keybindings = {
		jump = Input.GetMappedKeys("Jump")[1] or "(not set)",
		camera_switch = Input.GetMappedKeys("CameraSwitch")[1] or "(not set)",
		camera_side = Input.GetMappedKeys("CameraSide")[1] or "(not set)",
		context_menu = Input.GetMappedKeys("ContextMenu")[1] or "(not set)",
	}
}

-- Adds the Notification on the Screen
---@param type NotificationType		Type of the notification to display
---@param id string					Unique ID used to store if the notification was already displayed to the player
---@param message string			The message to display
---@param duration number			Duration in seconds of the notification
---@param delay number				Time in seconds to wait until display the notification
---@param force? boolean			To force it to be displayed regardless if it was already displayed before
function Notifications.Add(type, id, message, duration, delay, force)
	Timer.SetTimeout(function(_id, _message, _duration, _force)
		if (not _force) then
			if (PERSISTENT_DATA_NOTIFICATIONS[_id]) then
				return
			end

			-- Sets to the settings that the Notification has been shown
			PERSISTENT_DATA_NOTIFICATIONS[_id] = true
			Package.SetPersistentData("notifications", PERSISTENT_DATA_NOTIFICATIONS)
		end

		Client.ShowNotification(_message, type, false, _duration)
	end, delay * 1000, id, message, duration, force)
end

Events.SubscribeRemote("AddNotification", Notifications.Add)
MainHUD:Subscribe("AddNotification", Notifications.Add)

-- Exports so other packages can use it
Package.Export("Notifications", Notifications)

-- Setup some default notifications
Notifications.Add(NotificationType.Info, "PARACHUTE", "you can press " .. Notifications.common_keybindings.jump .. " while falling to open your parachute", 10, 10)
Notifications.Add(NotificationType.Info, "VIEW_MODE", "you can press " .. Notifications.common_keybindings.camera_switch .. " to change the View Mode", 10, 50)
Notifications.Add(NotificationType.Info, "CAMERA_SIDE", "you can press " .. Notifications.common_keybindings.camera_side .. " to change the Camera Side", 10, 70)
Notifications.Add(NotificationType.Info, "CONTEXT_MENU", "you can press " .. Notifications.common_keybindings.context_menu .. " to open the Context Menu", 10, 100)