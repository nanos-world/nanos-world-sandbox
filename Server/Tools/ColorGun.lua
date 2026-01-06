ColorGun = ToolGun.Inherit("ColorGun")

function ColorGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGun.Constructor(self, location, rotation, Color.GREEN)
end

function ColorGun:OnColorObject(player, entity, hit_location, direction, color)
	if (not entity) then return end

	-- Refuse applying color to a player
	if (entity:IsA(Character) and entity:GetPlayer()) then
		--Events.BroadcastRemote("SpawnSound", player:GetLocation(), "nanos-world::A_Invalid_Action", false, 1, 1)
		return
	end

	entity:SetMaterialColorParameter("Tint", color)
	Particle(hit_location, direction:Rotation(), "nanos-world::P_DirectionalBurst"):SetParameterColor("Color", color)
end

ColorGun.SubscribeRemote("ColorObject", ColorGun.OnColorObject)