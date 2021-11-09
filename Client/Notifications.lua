-- Adds the Notification on the Screen
function AddNotification(id, message, time, force)
	if (not force) then
		if (PERSISTENT_DATA_NOTIFICATIONS[id]) then
			return
		end

		-- Sets to the settings that the Notification has been shown
		PERSISTENT_DATA_NOTIFICATIONS[id] = true
		Package.SetPersistentData("notifications", PERSISTENT_DATA_NOTIFICATIONS)
	end

	-- Plays a sound
	Sound(Vector(), "nanos-world::A_VR_Click_01", true, true, SoundType.SFX, 0.1, 1)

	-- Trigger WebUI to display it
	MainHUD:CallEvent("AddNotification", message, time)
end

-- Subscribes so other Packages can add notification as well
Events.Subscribe("AddNotification", AddNotification)

-- Configure the notification to trigger after delay
function SetNotification(id, delay, message, time)
	Timer.SetTimeout(function(_id, _message, _time)
		AddNotification(_id, _message, _time)
	end, delay, id, message, time)
end

-- Subscribes so other Packages can set notification as well
Events.Subscribe("SetNotification", SetNotification)

-- Setup some default notifications
SetNotification("PARACHUTE", 10000, "you can press space while falling to open your parachute", 10000)
SetNotification("VIEW_MODE", 50000, "you can press V to change the View Mode", 10000)
SetNotification("CAMERA_SIDE", 70000, "you can press Middle Mouse Button to change the Camera Side", 10000)
SetNotification("PARACHUTE", 100000, "you can press C to open the Context Menu", 10000)