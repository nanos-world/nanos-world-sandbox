-- Toggles the Scoreboard
Input.Bind("Scoreboard", InputEvent.Released, function()
	MainHUD:CallEvent("ToggleScoreboard", false)
end)

Input.Bind("Scoreboard", InputEvent.Pressed, function()
	MainHUD:CallEvent("ToggleScoreboard", true)
end)

-- Updates someone scoreboard data
function UpdatePlayerScoreboard(player)
	MainHUD:CallEvent("UpdatePlayer", player:GetID(), true, player:GetName(), player:GetPing())
end

--  Adds someone to the scoreboard
Player.Subscribe("Spawn", function(player)
	UpdatePlayerScoreboard(player)
end)


Package.Subscribe("Load", function()
	for k, player in pairs(Player.GetPairs()) do
		UpdatePlayerScoreboard(player)
	end

	-- Updates the ping every 5 seconds
	Timer.SetInterval(function()
		for k, player in pairs(Player.GetPairs()) do
			UpdatePlayerScoreboard(player)
		end
	end, 5000)
end)