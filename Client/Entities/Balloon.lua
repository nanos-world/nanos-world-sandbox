Balloon = Prop.Inherit("Balloon")

Balloon.name = "Balloon"
Balloon.image = "assets://nanos-world/Thumbnails/SM_Balloon_01.jpg"
Balloon.category = "uncategorized"


function Balloon:OnDestroy()
	-- Avoiding spawning particles and sound if it's too far
	if (self:GetDistanceFromCamera() > 5000) then return end

	local balloon_location = self:GetLocation()

	Sound(balloon_location, "nanos-world::A_Balloon_Pop", false, true, SoundType.SFX, 1, 1)
	Particle(balloon_location + Vector(0, 0, 30), Rotator(), "nanos-world::P_OmnidirectionalBurst", true, true):SetParameterColor("Color", self:GetValue("Color"))
end

Balloon.Subscribe("Destroy", Balloon.OnDestroy)