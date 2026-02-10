RopeGun = ToolGunDoubleTarget.Inherit("RopeGun")

ConfigureSpawnLimits("Cable", "Cables", Cable.GetCount, "max_cables")

function RopeGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGunDoubleTarget.Constructor(self, location, rotation, Color.ORANGE)
end

function RopeGun:OnRopeAttach(player, targeting_first_to, targeting_first_relative_location, targeting_second_to, targeting_second_location)
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
			cable:SetLinearLimits(ConstraintMotion.Limited, ConstraintMotion.Limited, ConstraintMotion.Limited, distance, 0.25, true, 1000, 10)

			cable:SetCableSettings(distance * 0.75, 10, 1)
		end
	)

	-- Updates the client's spawn history
	SpawnHistory.AddItemToHistory(player, cable)
end

RopeGun.SubscribeRemote("RopeAttach", RopeGun.OnRopeAttach)