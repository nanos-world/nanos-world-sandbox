RopeLight = Prop.Inherit("RopeLight")

ConfigureSpawnLimits("RopeLight", "Rope Lights", RopeLight.GetCount, "max_rope_lights")

function RopeLight:Constructor(spawn_location, relative_location, relative_rotation, direction, attach_to_entity)
	local rotation = direction:ToOrientationRotator() + Rotator(90, 0, 0)

	self.Super:Constructor(spawn_location, rotation, "nanos-world::SM_Lamp", CollisionType.StaticOnly, true, GrabMode.Disabled)

	-- Sets the prop mesh emissive color to a random color
	local color = Color.RandomPalette(false)

	-- Spawns a Point Light, with the color
	local intensity = 10
	self.light = Light(spawn_location, Rotator(), color, LightType.Point, intensity, 250, 44, 0, 2000)

	-- Attaches the light to the prop, offsetting 25 downwards
	self.light:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)
	self.light:SetRelativeLocation(Vector(0, 0, -25))

	-- Sets light to sync
	self:SetValue("Light", self.light, true)

	-- Turns on by default
	self:SetLightEnabled(true)

	-- Spawns the Cable
	local cable = Cable(spawn_location)

	-- Configures the cable
	local cable_length = 100
	cable:SetLinearLimits(ConstraintMotion.Limited, ConstraintMotion.Limited, ConstraintMotion.Limited, cable_length, 0, true, 10000, 100)
	cable:SetRenderingSettings(3, 4, 1)
	cable:SetCableSettings(cable_length / 4, 10, 2)

	-- If to attach to an entity
	if (attach_to_entity) then
		-- Gets the relative location rotated to attach to the exact point the player aimed
		cable:AttachStartTo(attach_to_entity, relative_location)
	end

	cable:AttachEndTo(self)
end

function RopeLight:SetLightEnabled(is_on)
	self.is_on = is_on

	if (is_on) then
		-- Sets the prop mesh emissive color to this color
		self:SetMaterialColorParameter("Emissive", self.light:GetColor() * 100)
		self.light:SetVisibility(true)

	else
		self:SetMaterialColorParameter("Emissive", Color.BLACK)
		self.light:SetVisibility(false)
	end
end

function RopeLight:SetColor(player, color)
	if (self.is_on) then
		self:SetMaterialColorParameter("Emissive", color * 100)
	end

	self.light:SetColor(color)
end

function RopeLight:SetIntensity(player, intensity)
	self.light:SetIntensity(intensity)
end

function RopeLight:ToggleLight()
	self:SetLightEnabled(not self.is_on)
end

function RopeLight:Activate()
	self:SetLightEnabled(true)
end

function RopeLight:Deactivate()
	self:SetLightEnabled(false)
end