-- Toggles the Scoreboard
Client.Subscribe("KeyUp", function(key_name)
	if (key_name == "Tab") then
		main_hud:CallEvent("ToggleScoreboard", false)
	end
end)

-- Toggles the Scoreboard
Client.Subscribe("KeyDown", function(key_name)
	if (key_name == "Tab") then
		main_hud:CallEvent("ToggleScoreboard", true)
	end
end)

-- Updates someone scoreboard data
function UpdatePlayerScoreboard(player)
	main_hud:CallEvent("UpdatePlayer", player:GetID(), true, player:GetName(), player:GetPing())
end

--  Adds someone to the scoreboard
Player.Subscribe("Spawn", function(player)
	UpdatePlayerScoreboard(player)
end)

-- Updates the ping every 5 seconds
Timer.SetTimeout(function()
	for k, player in pairs(NanosWorld:GetPlayers()) do
		UpdatePlayerScoreboard(player)
	end
end, 5000)