-- Context Menu data
ContextMenu = ContextMenu or {
	-- Whether the menu is opened
	is_opened = false
}

ContextMenu.AddItems = function(id, title, items)
	MainHUD:CallEvent("AddContextMenuItems", id, title, items)
end

ContextMenu.RemoveItems = function(id)
	MainHUD:CallEvent("RemoveContextMenuItems", id)
end

Input.Bind("ContextMenu", InputEvent.Pressed, function()
	if (SpawnMenu.is_opened) then return end

	if (ContextMenu.is_opened) then
		MainHUD:CallEvent("ToggleContextMenuVisibility", false)

		Client.SetMouseEnabled(false)
		Client.SetChatVisibility(true)

		ContextMenu.is_opened = false
		PlayClickSound(0.9)
	else
		-- Opens context menu
		MainHUD:CallEvent("ToggleContextMenuVisibility", true)

		-- Updates time of the day
		local hours, minutes, seconds = Sky.GetTimeOfDay()
		UpdateTimeOfDayValue(hours, minutes)

		Client.SetMouseEnabled(true)
		Client.SetChatVisibility(false)

		MainHUD:BringToFront()

		ContextMenu.is_opened = true
		PlayClickSound(1.1)
	end
end)

-- Called from Context Menu when pressing X
MainHUD:Subscribe("CloseContextMenu", function()
	Client.SetMouseEnabled(false)
	Client.SetChatVisibility(true)
	ContextMenu.is_opened = false

	PlayClickSound(0.9)
end)


-- Time
ContextMenu.AddItems("time", "time", {
	{ id = "time_of_day", type = "range", label = "time of day (00:00)", min = 0, max = 1440, value = 720, callback_event = "ContextMenu_SetTimeOfDay", auto_update_label = false },
	{ id = "lock_time_of_day", type = "checkbox", label = "lock time of the day", callback_event = "ContextMenu_LockTimeOfDay" },
})

MainHUD:Subscribe("ContextMenu_LockTimeOfDay", function(enabled)
	if (enabled) then
		Sky.SetAnimateTimeOfDay(false)
	else
		Sky.SetAnimateTimeOfDay(true, 30, 15)
	end
end)

MainHUD:Subscribe("ContextMenu_SetTimeOfDay", function(value)
	local hours = math.floor(value / 60)
	local minutes = math.fmod(value, 60)
	Sky.SetTimeOfDay(hours, minutes)

	UpdateTimeOfDayLabel(hours, minutes)
end)

function UpdateTimeOfDayLabel(hours, minutes)
	local label = string.format("time of day (%02d:%02d)", hours, minutes);
	MainHUD:CallEvent("SetContextMenuLabel", "time_of_day", label)
end

function UpdateTimeOfDayValue(hours, minutes)
	local value = hours * 60 + minutes
	MainHUD:CallEvent("SetContextMenuValue", "time_of_day", value)
	UpdateTimeOfDayLabel(hours, minutes)
end
-- Time

-- Common
ContextMenu.AddItems("common", "common", {
	{ id = "respawn_button", type = "button", label = "respawn", callback_event = "ContextMenu_Respawn" },
})

MainHUD:Subscribe("ContextMenu_Respawn", function()
	Events.CallRemote("RespawnCharacter")
end)
-- Common