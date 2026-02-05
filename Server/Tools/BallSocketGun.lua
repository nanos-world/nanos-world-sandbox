BallSocketGun = ToolGunDoubleTarget.Inherit("BallSocketGun")

function BallSocketGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGunDoubleTarget.Constructor(self, location, rotation, Color.ORANGE)
end

function BallSocketGun:OnBallSocketAttach(player, targeting_first_to, targeting_first_relative_location, targeting_second_to, targeting_second_location)
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
			cable:SetLinearLimits(ConstraintMotion.Locked, ConstraintMotion.Locked, ConstraintMotion.Locked)

			cable:SetCableSettings(distance * 0.75, 1, 1)
		end
	)

	cable:SetMaterialColorParameter("Tint", Color.BLACK)

	-- Calls the client to update his history
	Events.CallRemote("SpawnedItem", player, cable)
end

BallSocketGun.SubscribeRemote("BallSocketAttach", BallSocketGun.OnBallSocketAttach)