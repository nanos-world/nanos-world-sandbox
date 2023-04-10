SandboxSky = {
	current_weather = 5, -- PartlyCloudy
	probability_change_weather = 0.5, -- 50% of chance
	weather_change_check_interval = 300000, -- 5 minutes
	weather_transition_time_min = 20,
	weather_transition_time_max = 40,
}

Package.Subscribe("Load", function()
	if (SANDBOX_CUSTOM_SETTINGS.enable_default_sky) then
		Events.BroadcastRemote("SpawnSky", SandboxSky.current_weather)

		if (SANDBOX_CUSTOM_SETTINGS.enable_auto_weather) then
			Timer.SetInterval(function()
				-- At each 'weather_change_check_interval' seconds, we have 'probability_change_weather' of chance of changing the weather
				math.randomseed(os.time())
				if (math.random(0, 100) / 100 >= SandboxSky.probability_change_weather) then return end

				SandboxSky.current_weather = math.random(1, 13)
				local transition_time = math.random(SandboxSky.weather_transition_time_min, SandboxSky.weather_transition_time_max)

				Console.Log("Automatically changing Weather to '%d'.", SandboxSky.current_weather)

				Events.BroadcastRemote("ChangeWeather", SandboxSky.current_weather, transition_time)
			end, SandboxSky.weather_change_check_interval)
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