SandboxSky = {
	current_weather = 5, -- PartlyCloudy
	probability_change_weather = 0.5, -- 50% of chance of changing the weather
	weather_change_interval = 600, -- 10 minutes
	weather_transition_time_min = 20,
	weather_transition_time_max = 40,
	weathers = {
		{ id = 1,	name = "ClearSkies",		probability = 0.7 },
		{ id = 2,	name = "Cloudy",			probability = 1.3 },
		{ id = 3,	name = "Foggy",				probability = 0.35 },
		{ id = 4,	name = "Overcast",			probability = 0.8 },
		{ id = 5,	name = "PartlyCloudy",		probability = 1.4 },
		{ id = 6,	name = "Rain",				probability = 1.0 },
		{ id = 7,	name = "RainLight",			probability = 1.0 },
		{ id = 8,	name = "RainThunderstorm",	probability = 0.8 },
		{ id = 9,	name = "SandDustCalm",		probability = 0.3 },
		{ id = 10,	name = "SandDustStorm",		probability = 0.2 },
		{ id = 11,	name = "Snow",				probability = 0.3 },
		{ id = 12,	name = "SnowBlizzard",		probability = 0.2 },
		{ id = 13,	name = "SnowLight",			probability = 0.3 }
	}
}

function ChooseRandomWeather()
	local total_probability = 0
	for _, weather in ipairs(SandboxSky.weathers) do
		total_probability = total_probability + weather.probability
	end

	local random_number = math.random() * total_probability

	for _, weather in ipairs(SandboxSky.weathers) do
		random_number = random_number - weather.probability
		if random_number <= 0 then
			return weather
		end
	end

	-- Fallback in case of rounding errors
	return SandboxSky.weathers[#SandboxSky.weathers]
end

Package.Subscribe("Load", function()
	if (SANDBOX_CUSTOM_SETTINGS.enable_default_sky) then
		Events.BroadcastRemote("SpawnSky", SandboxSky.current_weather)

		if (SANDBOX_CUSTOM_SETTINGS.enable_auto_weather) then
			Timer.SetInterval(function()
				-- At each 'weather_change_interval' seconds, we have 'probability_change_weather' of chance of changing the weather
				math.randomseed(os.time())
				if (math.random(0, 100) / 100 >= SandboxSky.probability_change_weather) then return end

				local new_weather = ChooseRandomWeather()
				local transition_time = math.random(SandboxSky.weather_transition_time_min, SandboxSky.weather_transition_time_max)

				SandboxSky.current_weather = new_weather.id

				Console.Log("Automatically changing Weather to '%s'.", new_weather.name)

				Events.BroadcastRemote("ChangeWeather", SandboxSky.current_weather, transition_time)
			end, SandboxSky.weather_change_interval * 1000)
		end
	end
end)

Player.Subscribe("Spawn", function(player)
	if (SANDBOX_CUSTOM_SETTINGS.enable_default_sky) then
		Events.CallRemote("SpawnSky", player, SandboxSky.current_weather)
	end
end)

Console.RegisterCommand("weather", function(weather, transition_time)
	if (not SANDBOX_CUSTOM_SETTINGS.enable_default_sky) then
		Console.Error("The Default Sky is disabled.")
		return
	end

	weather = tonumber(weather)
	transition_time = tonumber(transition_time) or 5

	if (not weather or not transition_time) then
		Console.Error("Invalid parameters passed to 'weather' command!")
		return
	end

	if (weather < 1 or weather > 13) then
		Console.Error("Invalid value passed to 'weather' command! Valid values are from 1 to 13.")
		return
	end

	SandboxSky.current_weather = weather

	Events.BroadcastRemote("ChangeWeather", weather, transition_time)

	Console.Log("Changing to Weather '%d'. Transition '%d' seconds.", weather, transition_time)
end, "changes the weather for everyone", { "weather", "transition_seconds" })

Console.RegisterCommand("time", function(hours, minutes)
	if (not SANDBOX_CUSTOM_SETTINGS.enable_default_sky) then
		Console.Error("The Default Sky is disabled.")
		return
	end

	hours = tonumber(hours)
	minutes = tonumber(minutes)

	if (not hours or not minutes) then
		Console.Error("Invalid parameters passed to 'time' command!")
		return
	end

	Events.BroadcastRemote("ChangeTime", hours, minutes)

	Console.Log("Changing Time to '%d:%d'.", hours, minutes)
end, "changes the sun time for everyone", { "hours", "minutes" })