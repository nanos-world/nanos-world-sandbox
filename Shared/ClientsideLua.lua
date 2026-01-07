local ID = "sv_allowcslua"
local Enabled = false -- disabled by default

if Server then
	Enabled = Server.GetCustomSettings().enable_cslua or Enabled

	-- Broadcast the convar's value initially
	Server.SetValue(ID, Enabled, true)
	--Events.BroadcastRemote(ID, Enabled)

	-- C2S: Query the convar's value; old approach
	--Events.SubscribeRemote(ID, function(player)
	--	Events.CallRemote(ID, player, Enabled)
	--end)

	Console.RegisterCommand(ID, function(enable)
		local changed
		if enable then
			if enable == "1" then
				changed = not Enabled
				if changed then
					Enabled = true
					Server.SetValue(ID, Enabled, true)
					Events.BroadcastRemote(ID, Enabled)
				end
			elseif enable == "0" then
				changed = Enabled
				if changed then
					Enabled = false
					Server.SetValue(ID, Enabled, true)
					Events.BroadcastRemote(ID, Enabled)
				end
			end
		end
		if changed then -- only broadcast a message if the state has changed
			Console.Log("Client-side Lua has been %s", Enabled and "enabled" or "disabled")
			Chat.BroadcastMessage("Client-side Lua has been " .. (Enabled and "<green>enabled</>" or "<red>disabled</>"))
		end
	end, "enable players to run Lua on client-side", { "0/1" })
else
	Enabled = Client.GetValue(ID, Enabled)

	-- S2C: synchronise convar state
	Events.SubscribeRemote(ID, function(enable)
		Enabled = not (not enable) -- old approach; make sure we have a boolean
		--Enabled = Client.GetValue(ID, false) -- new approach
		if Enabled then
			Client.SetDebugEnabled(true)
		end
	end)

	-- Query the convar's value initially
	--Events.CallRemote(ID)

	Console.RegisterCommand("lua", function(...)
		--Enabled = Client.GetValue(ID, false) -- new approach
		if not Enabled or select("#", ...) == 0 then return end
		local code = table.concat({ ... }, " ")
		local fn, err = load(code, nil, "t")
		if type(fn) == "function" then
			local ok, res = pcall(fn)
			if res ~= nil then
				Console.Log("[lua] %s", res)
			end
		else
			Console.Log("[lua] %s", err)
		end
	end, "run Lua (" .. ID .. " must be enabled on server-side)", { "code" })
end
