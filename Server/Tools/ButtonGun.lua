ButtonGun = ToolGunSingleTarget.Inherit("ButtonGun")

function ButtonGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGunSingleTarget.Constructor(self, location, rotation, Color.WHITE)
end

function ButtonGun:OnSpawnButton(player, hit_location, relative_location, relative_rotation, direction, entity)
	if (not ValidateSpawnLimits(player, "Button")) then
		return
	end

	local rotation = direction:ToOrientationRotator()

	-- TODO parameters
	local Button = BaseButton(hit_location, rotation + Rotator(90, 0, 180), "", "", player, true)

	-- Gets the relative location rotated to attach to the exact point the player aimed
	if (entity and entity:IsValid()) then
		Button:AttachTo(entity, AttachmentRule.SnapToTarget, "", 0)
		Button:SetRelativeLocation(relative_location)
		Button:SetRelativeRotation((relative_rotation:Quaternion() * Rotator(-90, 0, 0):Quaternion()):Rotator())
	end

	-- Updates the client's spawn history
	SpawnHistory.AddItemToHistory(player, Button)

	Particle(hit_location, rotation, "nanos-world::P_DirectionalBurst")
end

ButtonGun.SubscribeRemote("SpawnButton", ButtonGun.OnSpawnButton)