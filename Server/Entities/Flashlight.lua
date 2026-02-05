Flashlight = Prop.Inherit("Flashlight")

ConfigureSpawnLimits("Flashlight", "Flashlights", Flashlight.GetCount, "max_flashlights")

function Flashlight:Constructor(location, rotation)
	self.Super:Constructor(location, rotation, "nanos-world::SM_Flashlight", CollisionType.StaticOnly)

	-- Spawns a Point Light, with the color
	self.light = Light(Vector(), Rotator(), Color(1, 0.6, 0.4), LightType.Spot, 1, 3000, 25, 0.975, 4000, false)
	self.light:SetTextureLightProfile(LightProfile.Shattered_02)

	-- Sets light to sync
	self:SetValue("Light", self.light, true)

	-- Turns on by default
	self:SetLightEnabled(true)

	-- Attaches the lamp to the prop, offsetting 35 forwards
	self.light:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)
	self.light:SetRelativeLocation(Vector(35, 0, 0))
end

function Flashlight:SetLightEnabled(is_on)
	self.is_on = is_on

	if (is_on) then
		-- Sets the prop mesh emissive color to this color
		self:SetMaterialColorParameter("Emissive", self.light:GetColor() * 100)
		self.light:SetVisibility(true)

		Events.BroadcastRemote("SpawnSound", self:GetLocation(), "nanos-world::A_Switch_Button_03", false, 0.5, 3)

	else
		self:SetMaterialColorParameter("Emissive", Color.BLACK)
		self.light:SetVisibility(false)

		Events.BroadcastRemote("SpawnSound", self:GetLocation(), "nanos-world::A_Switch_Button_03", false, 0.5, 2)
	end
end

function Flashlight:SetColor(player, color)
	if (self.is_on) then
		self:SetMaterialColorParameter("Emissive", color * 100)
	end

	self.light:SetColor(color)
end

function Flashlight:SetIntensity(player, intensity)
	self.light:SetIntensity(intensity)
end

function Flashlight:ToggleLight()
	self:SetLightEnabled(not self.is_on)
end

function Flashlight:Activate()
	self:SetLightEnabled(true)
end

function Flashlight:Deactivate()
	self:SetLightEnabled(false)
end

function Flashlight:SetActive(player, active)
	if (active) then
		self:Activate()
	else
		self:Deactivate()
	end
end


Flashlight.SubscribeRemote("SetActive", Flashlight.SetActive)
Flashlight.SubscribeRemote("ToggleLight", Flashlight.ToggleLight)
Flashlight.SubscribeRemote("SetColor", Flashlight.SetColor)
Flashlight.SubscribeRemote("SetIntensity", Flashlight.SetIntensity)