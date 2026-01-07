ColorGun = ToolGun.Inherit("ColorGun")

function ColorGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGun.Constructor(self, location, rotation, Color.GREEN)
end

function ColorGun:OnColorObject(player, entity, hit_location, direction, color)
	-- Make sure that entity is valid
	if (not NanosUtils.IsEntityValid(entity)) then return end

	-- Refuse changing color of a Character
	if (entity:IsA(Character) and entity:GetPlayer()) then
		return
	end

	entity:SetMaterialColorParameter("Tint", color)
	Particle(hit_location, direction:Rotation(), "nanos-world::P_DirectionalBurst"):SetParameterColor("Color", color)
end

ColorGun.SubscribeRemote("ColorObject", ColorGun.OnColorObject)