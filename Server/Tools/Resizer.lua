-- Subscribes for client event to resize an object
Events:Subscribe("ResizeObject", function(player, object, scale)
	object:SetScale(scale)
end)

-- Subscribes for client event to start resizing an object
Events:Subscribe("ToggleResizing", function(player, is_resizing)
    player:GetControlledCharacter():SetCanAim(not is_resizing)
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("NanosWorld", "tools", "ResizerTool", function() return SpawnGenericToolGun(Vector(), Rotator(), Color.VIOLET) end)