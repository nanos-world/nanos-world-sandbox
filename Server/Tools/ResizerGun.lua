ResizerGun = ToolGun.Inherit("ResizerGun")

-- ResizeGun Configurations
ResizerGun.min_object_scale = Vector(0.1)
ResizerGun.max_object_scale = Vector(20)


function ResizerGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGun.Constructor(self, location, rotation, Color.VIOLET)
end

function ResizerGun:OnResizeObject(player, object, scale, up)
	-- Make sure that object is a valid entity
	if (not NanosUtils.IsEntityValid(object)) then return end

	-- Refuse to resize a character
	if (object:IsA(Character)) then
		return
	end

	-- Cannot resize too big or too small
	local size = scale:SizeSquared() -- This is cheaper operation than Size()
	if (size > ResizerGun.max_object_scale:SizeSquared()) then
		scale = ResizerGun.max_object_scale
	elseif (size < ResizerGun.min_object_scale:SizeSquared()) then
		scale = ResizerGun.min_object_scale
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