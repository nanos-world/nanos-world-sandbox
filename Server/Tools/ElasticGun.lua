ElasticGun = ToolGunDoubleTarget.Inherit("ElasticGun")

function ElasticGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGunDoubleTarget.Constructor(self, location, rotation, Color.ORANGE)
end

function ElasticGun:OnElasticAttach(player, targeting_first_to, targeting_first_relative_location, targeting_second_to, targeting_second_location, restitution, stiffness, damping)
	-- Refuse attaching rope from/to a character, also refuse attaching to itself
	if (
		(targeting_first_to and targeting_first_to:IsA(Character)) or
		(targeting_second_to and targeting_second_to:IsA(Character)) or
		(targeting_first_to == targeting_second_to)
	) then
		return
	end

	if (not ValidateSpawnLimits(player, "Cable")) then
		return
	end

	local cable = CableUtils.SpawnCableAttached(targeting_first_to, targeting_first_relative_location, targeting_second_to, targeting_second_location, false,
		function(cable, distance)
			-- Configures the Cable Linear Physics Limit
			cable:SetLinearLimits(ConstraintMotion.Limited, ConstraintMotion.Limited, ConstraintMotion.Limited, distance, restitution, true, stiffness, damping)

			-- Sets cable rendering settings (width = 5, sides = 4)
			cable:SetRenderingSettings(5, 4, 1)

			cable:SetCableSettings(distance * 0.75, 10, 1)
		end
	)

	cable:SetMaterial("nanos-world::M_Default_Masked_Lit")
	cable:SetMaterialColorParameter("Tint", Color.RandomPalette(false))

	-- Updates the client's spawn history
	SpawnHistory.AddItemToHistory(player, cable)
end

ElasticGun.SubscribeRemote("ElasticAttach", ElasticGun.OnElasticAttach)