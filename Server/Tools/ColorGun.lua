ColorGun = ToolGun.Inherit("ColorGun")

function ColorGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGun.Constructor(self, location, rotation, Color.GREEN)
end

function ColorGun:OnColorObject(player, entity, hit_location, direction, color)
	entity:SetMaterialColorParameter("Tint", color)
	Particle(hit_location, direction:Rotation(), "nanos-world::P_DirectionalBurst"):SetParameterColor("Color", color)
end

ColorGun.SubscribeRemote("ColorObject", ColorGun.OnColorObject)