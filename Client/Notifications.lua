-- Base Notifications object
Notifications = {
	-- Caches some common keybindings (Note: this will stay the same even if the player changes the keybindings while in-game)
	common_keybindings = {
		jump = Input.GetMappedKeys("Jump")[1] or "(not set)",
		camera_switch = Input.GetMappedKeys("CameraSwitch")[1] or "(not set)",
		camera_side = Input.GetMappedKeys("CameraSide")[1] or "(not set)",
		context_menu = Input.GetMappedKeys("ContextMenu")[1] or "(not set)",
		spawn_menu = Input.GetMappedKeys("SpawnMenu")[1] or "(not set)",
		undo = Input.GetMappedKeys("Undo")[1] or "(not set)"
	},

	-- All notifications already sent
	persistent_data = {}
}

-- Exposes Notifications to other packages
Sandbox.Notifications = Notifications

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
			if (Notifications.persistent_data[_id]) then
				return
			end

			-- Sets to the settings that the Notification has been shown
			Notifications.persistent_data[_id] = true
			Package.SetPersistentData("notifications." .. _id, true)
		end

		Client.ShowNotification(_message, type, false, _duration)
	end, delay * 1000, id, message, duration, force)
end

Package.Subscribe("Load", function()
	-- Gets all notifications already sent
	Notifications.persistent_data = Package.GetPersistentData("notifications") or {}
end)


Events.SubscribeRemote("AddNotification", Notifications.Add)
Sandbox.HUD:Subscribe("AddNotification", Notifications.Add)


-- Setup some default notifications
Notifications.Add(NotificationType.Info, "SPAWN_MENU", "you can press " .. Notifications.common_keybindings.spawn_menu .. " to open the Spawn Menu", 10, 30)
Notifications.Add(NotificationType.Info, "SPAWN_MENU_DESTROY_ITEM", "you can press " .. Notifications.common_keybindings.undo .. " to delete your last spawned item", 10, 90)
Notifications.Add(NotificationType.Info, "CONTEXT_MENU", "you can press " .. Notifications.common_keybindings.context_menu .. " to open the Context Menu", 10, 150)
Notifications.Add(NotificationType.Info, "VIEW_MODE", "you can press " .. Notifications.common_keybindings.camera_switch .. " to change the View Mode", 10, 210)
Notifications.Add(NotificationType.Info, "CAMERA_SIDE", "you can press " .. Notifications.common_keybindings.camera_side .. " to change the Camera Side", 10, 270)
Notifications.Add(NotificationType.Info, "PARACHUTE", "you can press " .. Notifications.common_keybindings.jump .. " while falling to open your parachute", 10, 330)