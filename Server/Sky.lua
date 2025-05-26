SandboxSky = {
	dusk_time = 1800,
	dawn_time = 600,
	day_length = 30,
	night_length = 15,
	time_speed = 1,
	last_time_set = nil,
	current_time_of_day = 960, -- 9:36 AM
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

Package.Subscribe("Load", function()
	if (SANDBOX_CUSTOM_SETTINGS.enable_default_sky) then
		-- Sends default values to all players
		Events.BroadcastRemote("SpawnSky", SandboxSky.current_weather, SandboxSky.current_time_of_day, SandboxSky.day_length, SandboxSky.night_length)

		if (SANDBOX_CUSTOM_SETTINGS.enable_auto_weather) then
			Timer.SetInterval(function()
				-- At each 'weather_change_interval' seconds, we have 'probability_change_weather' of chance of changing the weather
				if (math.random(0, 100) / 100 >= SandboxSky.probability_change_weather) then return end

				local new_weather = SandboxSky.ChooseRandomWeather()
				local transition_time = math.random(SandboxSky.weather_transition_time_min, SandboxSky.weather_transition_time_max)

				Console.Log("Automatically changing Weather to '%s'.", new_weather.name)

				SandboxSky.ChangeWeather(new_weather.id, transition_time)
			end, SandboxSky.weather_change_interval * 1000)
		end
	end
end)

function SandboxSky.ChooseRandomWeather()
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

-- Calculates the step of time of day based on the current time of day and the speed of time
function SandboxSky.GetTimeOfDayOffset(delta_seconds)
	local is_dawn = SandboxSky.current_time_of_day > SandboxSky.dawn_time and SandboxSky.current_time_of_day < SandboxSky.dusk_time

	local step = 0
	local current_length = 0

	if (is_dawn) then
		step = SandboxSky.dusk_time - SandboxSky.dawn_time
		current_length = SandboxSky.day_length
	else
		step = 2400 - SandboxSky.dusk_time  + SandboxSky.dawn_time
		current_length = SandboxSky.night_length
	end

	local time_per_second = ((SandboxSky.time_speed / 60 * delta_seconds) * step) / current_length
	return time_per_second
end

-- Simulate the time of day change, based on the same USD Blueprint algorithm, so we can sync with all players (there may be 5 seconds of difference)
Timer.SetInterval(function()
	-- Gets change in time
	local time_per_second = SandboxSky.GetTimeOfDayOffset(5)

	-- Increment time
	SandboxSky.current_time_of_day = SandboxSky.current_time_of_day + time_per_second
end, 5000)

function PlayerSpawn(player)
	if (SANDBOX_CUSTOM_SETTINGS.enable_default_sky) then
		Events.CallRemote("SpawnSky", player, SandboxSky.current_weather, SandboxSky.current_time_of_day)
	end
end

Player.Subscribe("Spawn", PlayerSpawn)

function SandboxSky.ChangeTime(time_of_day)
	-- Sets new current values
	SandboxSky.current_time_of_day = time_of_day

	Events.BroadcastRemote("ChangeTime", time_of_day)
end

function SandboxSky.ChangeWeather(weather, transition_time)
	-- Sets new current values
	SandboxSky.current_weather = weather

	Events.BroadcastRemote("ChangeWeather", weather, transition_time)
end

Events.SubscribeRemote("ChangeWeather", function(player, weather)
	Console.Log("Player '%s' is changing the weather to '%s'.", player:GetName(), SandboxSky.weathers[weather].name)

	SandboxSky.ChangeWeather(weather, 10)
end)

Events.SubscribeRemote("ChangeTime", function(player, time_of_day)
	local hours = math.floor(time_of_day / 100)
	local minutes = math.floor(math.fmod(time_of_day, 100) * 60 / 100)

	Console.Log("Player '%s' is changing the time to '%d:%d'.", player:GetName(), hours, minutes)

	SandboxSky.ChangeTime(time_of_day)
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

	Console.Log("Console is changing the Weather '%s'. Transition '%d' seconds.", SandboxSky.weathers[weather].name, transition_time)

	SandboxSky.ChangeWeather(weather, transition_time)
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

	Console.Log("Console is changing the Time to '%d:%d'.", hours, minutes)

	local time_of_day = hours * 100 + minutes * 100 / 60
	SandboxSky.ChangeTime(time_of_day)
end, "changes the sun time for everyone", { "hours", "minutes" })