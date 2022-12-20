ResizerGun = ToolGun.Inherit("ResizerGun")

function ResizerGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGun.Constructor(self, location, rotation, Color.VIOLET)
end

function ResizerGun:OnResizeObject(player, object, scale, up)
	object:SetScale(scale)
	Events.BroadcastRemote("SpawnSound", object:GetLocation(), "nanos-world::A_Object_Snaps_To_Grid", false, 1, up and 0.9 or 0.8)
end

Events.SubscribeRemote("ToggleResizing", function(player, is_resizing)
    player:GetControlledCharacter():SetCanAim(not is_resizing)
end)

ResizerGun.SubscribeRemote("ResizeObject", ResizerGun.OnResizeObject)