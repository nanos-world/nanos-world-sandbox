-- Subscribes for client event to resize an object
Events:Subscribe("ResizeObject", function(player, object, scale, up)
	object:SetScale(scale)
	Events:BroadcastRemote("SpawnSound", {object:GetLocation(), "NanosWorld::A_Object_Snaps_To_Grid", false, 1, up and 0.9 or 0.8})
end)

-- Subscribes for client event to start resizing an object
Events:Subscribe("ToggleResizing", function(player, is_resizing)
    player:GetControlledCharacter():SetCanAim(not is_resizing)
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("NanosWorld", "tools", "ResizerTool", function() return SpawnGenericToolGun(Vector(), Rotator(), Color.VIOLET) end)