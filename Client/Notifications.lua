-- Sounds Cached
SoundNotification = Sound(Vector(), "nanos-world::A_VR_Click_01", true, false, SoundType.UI, 0.1, 1, 400, 3600, 0, false, 0, false)


-- Adds the Notification on the Screen
---@param id string			Unique ID used to store if the notification was already displayed to the player
---@param message string	The message to display
---@param time number		Duration of the notification
---@param delay number		Time to wait until display the notification
---@param force? boolean	To force it to be displayed regardless if it was already displayed before
function AddNotification(id, message, time, delay, force)
	Timer.SetTimeout(function(_id, _message, _time, _force)
		if (not _force) then
			if (PERSISTENT_DATA_NOTIFICATIONS[_id]) then
				return
			end

			-- Sets to the settings that the Notification has been shown
			PERSISTENT_DATA_NOTIFICATIONS[_id] = true
			Package.SetPersistentData("notifications", PERSISTENT_DATA_NOTIFICATIONS)
		end

		-- Plays a sound
		SoundNotification:Play()

		-- Trigger WebUI to display it
		MainHUD:CallEvent("AddNotification", _message, _time)
	end, delay, id, message, time, force)
end

-- Subscribes so other Packages can add and set notifications as well
Package.Export("AddNotification", AddNotification)

-- Setup some default notifications
local jump_keybind = Input.GetMappedKeys("Jump")[1] or "not set"
local camera_switch_keybind = Input.GetMappedKeys("CameraSwitch")[1] or "not set"
local camera_side_keybind = Input.GetMappedKeys("CameraSide")[1] or "not set"
local context_menu_keybind = Input.GetMappedKeys("ContextMenu")[1] or "not set"

AddNotification("PARACHUTE", "you can press " .. jump_keybind .. " while falling to open your parachute", 10000, 10000)
AddNotification("VIEW_MODE", "you can press " .. camera_switch_keybind .. " to change the View Mode", 10000, 50000)
AddNotification("CAMERA_SIDE", "you can press " .. camera_side_keybind .. " to change the Camera Side", 10000, 70000)
AddNotification("CONTEXT_MENU", "you can press " .. context_menu_keybind .. " to open the Context Menu", 10000, 100000)