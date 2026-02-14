SpringGun = ToolGunDoubleTarget.Inherit("SpringGun")

function SpringGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGunDoubleTarget.Constructor(self, location, rotation, Color.ORANGE)
end

function SpringGun:OnSpringAttach(player, targeting_first_to, targeting_first_relative_location, targeting_second_to, targeting_second_location, linear_strength, angular_strength)
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

	local cable = CableUtils.SpawnCableAttached(targeting_first_to, targeting_first_relative_location, targeting_second_to, targeting_second_location, true,
		function(cable, distance)
			-- Configures the Cable Physics Limits to be rigid
			cable:SetLinearLimits(ConstraintMotion.Limited, ConstraintMotion.Locked, ConstraintMotion.Locked, distance / 2)
			cable:SetAngularLimits(ConstraintMotion.Free, ConstraintMotion.Free, ConstraintMotion.Free)
			cable:SetLinearMotorPositionSettings(true, false, false, linear_strength)
			cable:SetAngularMotorSLERPOrientationSettings(true, angular_strength)

			cable:SetRenderingSettings(30, 6, 1)

			cable:SetCableSettings(distance * 0.75, 1, 1)
		end
	)

	cable:SetMaterialColorParameter("Tint", Color.BLACK)

	-- Updates the client's spawn history
	SpawnHistory.AddItemToHistory(player, cable)
end

SpringGun.SubscribeRemote("SpringAttach", SpringGun.OnSpringAttach)