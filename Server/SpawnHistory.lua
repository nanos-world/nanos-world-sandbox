SpawnHistory = {
	-- Per client list of spawned items
	player_history = setmetatable({}, { __mode = 'k' }),
}

-- Exposes SpawnHistory to other packages
Sandbox.SpawnHistory = SpawnHistory


-- Helper to add an item to the history of a player
function SpawnHistory.AddItemToHistory(player, item)
	if (not SpawnHistory.player_history[player]) then
		SpawnHistory.player_history[player] = {}
	end

	table.insert(SpawnHistory.player_history[player], item)

	if (type(item) ~= "function") then
		SpawnHistory.UpdateItemOwnership(player, item)
	end
end

-- Helper to update an item ownership data
function SpawnHistory.UpdateItemOwnership(player, item)
	item:SetValue("SpawnedBy", {
		player = player,
		player_name = player:GetName(),
		player_steam_id = player:GetSteamID(),
		time = Server.GetTime()
	}, true)
end

-- Destroys the last item in the history of a player, if any, and returns true, otherwise returns false
function SpawnHistory.DeleteItemFromHistory(player, index)
	local player_data = SpawnHistory.player_history[player]
	if (not player_data) then
		Events.CallRemote("NoItemToDestroy", player)
		return false
	end

	if (not index) then index = #player_data end

	local history_item = player_data[index]

	if (not history_item) then
		Events.CallRemote("NoItemToDestroy", player)
		return false
	end

	-- If it's a function, we call it, it must be a "destroy function"
	if (type(history_item) == "function") then
		-- Removes the function from history
		table.remove(player_data, index)

		local destroyed, location, what = history_item()

		if (destroyed) then
			if (location) then
				SpawnHistory.OnDestroyedItem(player, location, what)
			end
		else
			-- If it returns false, it means it didn't succeed, so we try the next one in the list, recursively
			return SpawnHistory.DeleteItemFromHistory(player, index - 1)
		end

		return true
	end

	local is_item_valid = history_item and history_item:IsValid()

	-- If the item is not valid, tries the next one in the list, recursively
	if (is_item_valid) then
		-- If it's currently being picked up by the player, skips it but keep it in the history and tries the next one
		local character = player:GetControlledCharacter()
		if (character and character:GetPicked() == history_item) then
			return SpawnHistory.DeleteItemFromHistory(player, index - 1)
		end
	end

	-- Removes from the table
	table.remove(player_data, index)

	-- If it's not valid or is another player's Character, tries the next one in the list, recursively
	if (not is_item_valid or (history_item:IsA(Character) and history_item:GetPlayer())) then
		return SpawnHistory.DeleteItemFromHistory(player, index - 1)
	end

	-- Tell clients to spawns some sounds and particles
	SpawnHistory.OnDestroyedItem(player, history_item:GetLocation(), history_item:GetClass():GetName() .. "#" .. history_item:GetID())

	-- Destroy the item
	history_item:Destroy()

	return true
end

function SpawnHistory.OnDestroyedItem(player, location, what)
	Events.CallRemote("AddNotification", player, NotificationType.Info, "UNDO", "undo spawned " .. (what or "item"), 2, 0, true)

	if (location) then
		Events.BroadcastRemote("DestroyedItem", location)
	end
end

Events.SubscribeRemote("DeleteItemFromHistory", SpawnHistory.DeleteItemFromHistory)