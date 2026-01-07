ResizerGun = ToolGun.Inherit("ResizerGun")

function ResizerGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGun.Constructor(self, location, rotation, Color.VIOLET)
end

function ResizerGun:OnResizeObject(player, object, scale, up)
	-- Refuse to resize a character
	if (not object or object:IsA(Character)) then
		--Events.BroadcastRemote("SpawnSound", player:GetLocation(), "nanos-world::A_Invalid_Action", false, 1, 1)
		return
	end

	-- Cannot resize too big or too small
	if (scale:SizeSquared() > 1200) then
		scale = Vector(20)
	elseif (scale:SizeSquared() < 0.03) then
		scale = Vector(0.1)
	end

	-- Play invalid action sound if scale hasn't changed
	if (object:GetScale():Equals(scale, 0.001)) then
		Events.BroadcastRemote("SpawnSound", object:GetLocation(), "nanos-world::A_Invalid_Action", false, 1, 1)
		return
	end

	object:SetScale(scale)
	Events.BroadcastRemote("SpawnSound", object:GetLocation(), "nanos-world::A_Object_Snaps_To_Grid", false, 1, up and 0.9 or 0.8)
end

Events.SubscribeRemote("ToggleResizing", function(player, is_resizing)
	player:GetControlledCharacter():SetCanAim(not is_resizing)
end)

ResizerGun.SubscribeRemote("ResizeObject", ResizerGun.OnResizeObject)