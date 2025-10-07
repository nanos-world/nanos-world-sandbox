Flashlight = Prop.Inherit("Flashlight")

function Flashlight:Constructor(location, rotation)
	self.Super:Constructor(location, rotation, "nanos-world::SM_Flashlight", CollisionType.StaticOnly)

	-- Spawns a Point Light, with the color
	self.color = Color(1, 0.6, 0.4)
	self.light = Light(Vector(), Rotator(), self.color, LightType.Spot, 1, 3000, 25, 0.975, 4000, false)
	self.light:SetTextureLightProfile(LightProfile.Shattered_02)

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
		self:SetMaterialColorParameter("Emissive", self.color * 100)
		self.light:SetIntensity(1)

	else
		self:SetMaterialColorParameter("Emissive", Color.BLACK)
		self.light:SetIntensity(0) -- TODO actually disable the light
	end
end

function Flashlight:ToggleLight()
	self:SetLightEnabled(not self.is_on)
end

Flashlight.SubscribeRemote("ToggleLight", Flashlight.ToggleLight)