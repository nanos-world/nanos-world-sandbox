-- Adds the Notification on the Screen
---@param type NotificationType		Type of the notification to display
---@param id string					Unique ID used to store if the notification was already displayed to the player
---@param message string			The message to display
---@param duration number			Duration in seconds of the notification
---@param delay number				Time in seconds to wait until display the notification
---@param force? boolean			To force it to be displayed regardless if it was already displayed before
function AddNotification(type, id, message, duration, delay, force)
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

Events.SubscribeRemote("AddNotification", AddNotification)

-- Subscribes so other Packages can add and set notifications as well
Package.Export("AddNotification", AddNotification)

-- Setup some default notifications
local jump_keybind = Input.GetMappedKeys("Jump")[1] or "not set"
local camera_switch_keybind = Input.GetMappedKeys("CameraSwitch")[1] or "not set"
local camera_side_keybind = Input.GetMappedKeys("CameraSide")[1] or "not set"
local context_menu_keybind = Input.GetMappedKeys("ContextMenu")[1] or "not set"

AddNotification(NotificationType.Info, "PARACHUTE",		"you can press " .. jump_keybind .. " while falling to open your parachute", 10, 10)
AddNotification(NotificationType.Info, "VIEW_MODE",		"you can press " .. camera_switch_keybind .. " to change the View Mode", 10, 50)
AddNotification(NotificationType.Info, "CAMERA_SIDE",	"you can press " .. camera_side_keybind .. " to change the Camera Side", 10, 70)
AddNotification(NotificationType.Info, "CONTEXT_MENU",	"you can press " .. context_menu_keybind .. " to open the Context Menu", 10, 100)