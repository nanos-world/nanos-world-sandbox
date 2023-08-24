ToolGun = Weapon.Inherit("ToolGun")

function ToolGun:Constructor(location, rotation, color)
	self.Super:Constructor(location, rotation, "nanos-world::SK_Blaster")

	self:SetAmmoSettings(10000000, 0)
	self:SetDamage(0)
	self:SetSpread(0)
	self:SetRecoil(0)
	self:SetSightTransform(Vector(0, 0, -3.2), Rotator(0, 0, 0))
	self:SetLeftHandTransform(Vector(-1, 1, -2), Rotator(0, 60, 100))
	self:SetRightHandOffset(Vector(-25, -5, 0))
	self:SetHandlingMode(HandlingMode.SingleHandedWeapon)
	self:SetCadence(0.1)
	self:SetSoundDry("nanos-world::A_Pistol_Dry")
	self:SetSoundZooming("nanos-world::A_AimZoom")
	self:SetSoundAim("nanos-world::A_Rattle")
	self:SetSoundFire("nanos-world::A_Simulate_Start")
	self:SetCrosshairMaterial("nanos-world::MI_Crosshair_Dot")
	self:SetUsageSettings(false, false)

	self:SetMaterialColorParameter("Emissive", color * 100)
end

function ToolGun:OnPickUp(character)
	local player = character:GetPlayer()
	if (not player) then return end

	-- Triggers the PickUp on the client which picked up it
	self:CallRemoteEvent("LocalPlayerPickUp", player, character)
end

function ToolGun:OnDrop(character)
	local player = character:GetPlayer()
	if (not player) then return end

	-- Triggers the Drop on the client which dropped up it
	self:CallRemoteEvent("LocalPlayerDrop", player, character)
end

ToolGun.Subscribe("PickUp", ToolGun.OnPickUp)
ToolGun.Subscribe("Drop", ToolGun.OnDrop)