local ID = "BroadcastLua"

if Server then
	function BroadcastLua(code)
		return Events.BroadcastRemote(ID, code)
	end

	function SendLua(player, code)
		return Events.CallRemote(ID, player, code)
	end

	Package.Export(ID, BroadcastLua)
	Package.Export("SendLua", SendLua)
else
	-- Client-side
	Events.SubscribeRemote(ID, function(code)
		local fn = load(code, ID, "t")
		if type(fn) == "function" then
			pcall(fn)
		end
	end)
end
