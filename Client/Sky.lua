SandboxSky = {
	day_length = 30,
	night_length = 15,
}

Events.SubscribeRemote("ChangeWeather", function(weather, time)
	Sky.ChangeWeather(weather, time)

	-- Updates the Context Menu as it may be opened
	UpdateWeatherValue()
end)

Events.SubscribeRemote("ChangeTime", function(time_of_day)
	local hours = math.floor(time_of_day / 100)
	local minutes = math.floor(math.fmod(time_of_day, 100) * 60 / 100)

	Sky.SetTimeOfDay(hours, minutes)

	-- Updates the Context Menu as it may be opened
	UpdateTimeOfDayValue(hours, minutes)
end)

Events.SubscribeRemote("SpawnSky", function(current_weather, time_of_day, day_length, night_length)
	-- Spawns/Overrides with default Ultra Dynamic Sky
	Sky.Spawn(true)

	SandboxSky.day_length = day_length
	SandboxSky.night_length = night_length

	local hours = math.floor(time_of_day / 100)
	local minutes = math.floor(math.fmod(time_of_day, 100) * 60 / 100)

	-- Sets the same time for everyone
	Sky.SetTimeOfDay(hours, minutes)
	Sky.SetAnimateTimeOfDay(true, day_length, night_length)

	-- Updates the Weather
	Sky.ChangeWeather(current_weather, 0)
end)

-- Context Menu callbacks
function SandboxSky.SetTimeOfDay(time_of_day)
	Events.CallRemote("ChangeTime", time_of_day * 100)
end

function SandboxSky.FreezeTime(enabled)
	if (enabled) then
		Sky.SetAnimateTimeOfDay(false)
	else
		Sky.SetAnimateTimeOfDay(true, SandboxSky.day_length, SandboxSky.night_length)
	end
end

function SandboxSky.ChangeWeather(value)
	Events.CallRemote("ChangeWeather", tonumber(value))
end

-- Context Menu Configuration for Sky & Time
ContextMenu.AddItems("sky", "sky", {
	{
		id = "time_of_day",
		type = "range",
		label = "time of day",
		min = 0,
		max = 24,
		step = 0.1,
		value = 9,
		callback = SandboxSky.SetTimeOfDay,
	},
	{
		id = "freeze_time",
		type = "checkbox",
		label = "freeze time",
		callback = SandboxSky.FreezeTime,
	},
	{
		id = "weather",
		type = "select",
		label = "weather",
		value = 5,
		options = {
			{ id = 1, name = "ClearSkies" },
			{ id = 2, name = "Cloudy" },
			{ id = 3, name = "Foggy" },
			{ id = 4, name = "Overcast" },
			{ id = 5, name = "PartlyCloudy" },
			{ id = 6, name = "Rain" },
			{ id = 7, name = "RainLight" },
			{ id = 8, name = "RainThunderstorm" },
			{ id = 9, name = "SandDustCalm" },
			{ id = 10, name = "SandDustStorm" },
			{ id = 11, name = "Snow" },
			{ id = 12, name = "SnowBlizzard" },
			{ id = 13, name = "SnowLight" }
		},
		callback = SandboxSky.ChangeWeather,
	},
})

function UpdateContextMenuValues()
	if (not Sky.IsSpawned(true)) then return end

	-- Updates time of the day
	local hours, minutes, seconds = Sky.GetTimeOfDay()
	UpdateTimeOfDayValue(hours, minutes)

	-- Updates Weather
	UpdateWeatherValue()
end

ContextMenu.AddUpdateFunction("sky", UpdateContextMenuValues)

function UpdateTimeOfDayValue(hours, minutes)
	-- 1 decimal place
	local value = math.floor((hours + minutes / 60) * 10) / 10
	ContextMenu.SetItemValue("time_of_day", value)
end

function UpdateWeatherValue()
	ContextMenu.SetItemValue("weather", Sky.GetWeather())
end