RopeLight = Prop.Inherit("RopeLight")

function RopeLight:Constructor(spawn_location, direction, attach_to_entity, distance_trace_object)
	local rotation = direction:Rotation() + Rotator(90, 0, 0)

	self.Super:Constructor(spawn_location, rotation, "nanos-world::SM_Lamp", CollisionType.Auto, true, GrabMode.Disabled)

	self:SetCollision(CollisionType.StaticOnly)

	-- Sets the prop mesh emissive color to a random color
	self.color = Color.RandomPalette(false)
	self:SetMaterialColorParameter("Emissive", self.color * 50)

	-- Spawns a Point Light, with the color
	local intensity = 10
	local light = Light(spawn_location, Rotator(), self.color, LightType.Point, intensity, 250, 44, 0, 2000)

	-- Attaches the light to the prop, offseting 25 downwards
	light:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)
	light:SetRelativeLocation(Vector(0, 0, -25))

	-- Spawns the Cable
	local cable = Cable(spawn_location)

	-- Configures the cable
	local cable_length = 100
	cable:SetLinearLimits(ConstraintMotion.Limited, ConstraintMotion.Limited, ConstraintMotion.Limited, cable_length, 0, true, 10000, 100)
	cable:SetRenderingSettings(3, 4, 1)
	cable:SetCableSettings(cable_length / 4, 10, 2)

	-- Destroy PropLight when cable is destroyed
	cable:SetValue("PropLight", self)
	cable:Subscribe("Destroy", function(c)
		local light_attached = c:GetValue("PropLight")
		if (light_attached and light_attached:IsValid()) then
			light_attached:Destroy()
		end
	end)

	-- If to attach to an entity
	if (attach_to_entity) then
		-- Gets the relative location rotated to attach to the exact point the player aimed
		local attach_location = attach_to_entity:GetRotation():RotateVector(-distance_trace_object)
		cable:AttachStartTo(attach_to_entity, attach_location)
	end

	cable:AttachEndTo(self)
end
