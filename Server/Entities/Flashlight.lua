Flashlight = Prop.Inherit("Flashlight")

function Flashlight:Constructor(location, rotation)
	self.Super:Constructor(location, rotation, "nanos-world::SM_Flashlight", CollisionType.StaticOnly)

	-- Spawns a Point Light, with the color
	local intensity = 25

	-- Sets the prop mesh emissive color to a random color
	self.color = Color(1, 0.6, 0.4)
	self:SetMaterialColorParameter("Emissive", self.color * intensity)

	local light = Light(Vector(), Rotator(), self.color, LightType.Spot, intensity, 1000, 25, 0.975, 2000, false)
	light:SetTextureLightProfile(LightProfile.Shattered_02)

	-- Attaches the lamp to the prop, offseting 35 forwards
	light:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)
	light:SetRelativeLocation(Vector(35, 0, 0))
end