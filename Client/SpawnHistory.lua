SpawnHistory = {
	-- Current delay between each item deletion when holding the undo button
	history_undo_delay = 0,

	is_pressing_undo = true,
}

-- Exposes SpawnHistory to other packages
Sandbox.SpawnHistory = SpawnHistory


function SpawnHistory.HistoryUndoTick(delta_time)
	SpawnHistory.history_undo_delay = SpawnHistory.history_undo_delay - delta_time

	if (SpawnHistory.history_undo_delay <= 0) then
		-- Calls server to destroy the last item
		Events.CallRemote("DeleteItemFromHistory")

		SpawnHistory.history_undo_delay = SpawnHistory.history_undo_delay + 0.1
	end
end

function SpawnHistory.OnDestroyedItem(location)
	Sound(location, "nanos-world::A_Player_Eject", false, true, SoundType.SFX, 0.3)
	Particle(location + Vector(0, 0, 30), Rotator(), "nanos-world::P_OmnidirectionalBurst")
end

function SpawnHistory.OnNoItemToDestroy()
	-- Prevents multiple notifications when holding the undo button
	if (SpawnHistory.history_undo_delay == 0) then return end

	Notifications.Add(NotificationType.Warning, "NO_ITEM_TO_DELETE", "there are no items in your history to destroy!", 3, 0, true)

	if (SpawnHistory.is_pressing_undo) then
		Client.Unsubscribe("Tick", SpawnHistory.HistoryUndoTick)
	end

	SpawnHistory.history_undo_delay = 0
	SpawnHistory.is_pressing_undo = false
end

Input.Bind("Undo", InputEvent.Pressed, function()
	-- Calls server to destroy the last item
	Events.CallRemote("DeleteItemFromHistory")

	SpawnHistory.is_pressing_undo = true

	-- Waits 1 seconds then keeps destroying
	SpawnHistory.history_undo_delay = 1

	Client.Subscribe("Tick", SpawnHistory.HistoryUndoTick)
end)

Input.Bind("Undo", InputEvent.Released, function()
	SpawnHistory.is_pressing_undo = false
	Client.Unsubscribe("Tick", SpawnHistory.HistoryUndoTick)
end)

Events.SubscribeRemote("DestroyedItem", SpawnHistory.OnDestroyedItem)
Events.SubscribeRemote("NoItemToDestroy", SpawnHistory.OnNoItemToDestroy)