SliderGun = ToolGunDoubleTarget.Inherit("SliderGun")

function SliderGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGunDoubleTarget.Constructor(self, location, rotation, Color.CHARTREUSE)
end

function SliderGun:OnAttach(player, targeting_first_to, targeting_first_relative_location, targeting_second_to, targeting_second_location)
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
			cable:SetLinearLimits(ConstraintMotion.Free, ConstraintMotion.Locked, ConstraintMotion.Locked)
			cable:SetAngularLimits(ConstraintMotion.Locked, ConstraintMotion.Locked, ConstraintMotion.Locked)

			-- Sets cable rendering settings (width = 5, sides = 4)
			cable:SetRenderingSettings(5, 4, 1)

			cable:SetCableSettings(1, 1)
		end
	)

	cable:SetMaterial("nanos-world::M_Default_Masked_Lit")
	cable:SetMaterialColorParameter("Tint", Color.BLACK)

	-- Updates the client's spawn history
	SpawnHistory.AddItemToHistory(player, cable)
end

SliderGun.SubscribeRemote("SliderAttach", SliderGun.OnAttach)