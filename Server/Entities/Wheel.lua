Wheel = Prop.Inherit("Wheel")

-- ConfigureSpawnLimits("Wheel", "Wheels", Wheel.GetCount, "max_wheels")

function Wheel:Constructor(location, rotation, axis, angular_force, active, is_forward, scale)
	-- TODO custom rotations?
	-- TODO custom meshes?
	rotation = rotation + Rotator(90, 0, 90)
	self.Super:Constructor(location, rotation, "nanos-world::SM_Offroad_Tire", CollisionType.IgnoreOnlyPawn, true, GrabMode.Disabled)

	-- Adds a constant angular force to the Wheel
	angular_force = angular_force or 2000000
	self.axis = axis

	-- TODO is it needed? it makes needed more force
	self:SetMassOverride(100)

	if (active == nil) then active = true end
	if (is_forward == nil) then is_forward = true end

	if (scale and scale ~= 1) then
		self:SetScale(Vector(scale, scale, scale))
	end

	-- Sets the values as sync, so client can access it on Spawn event
	self:SetValue("Active", active, true)
	self:SetValue("Forward", is_forward, true)
	self:SetValue("AngularForce", angular_force, true)

	if (active and angular_force ~= 0) then
		self:UpdateAngularForce()
	end
end

function Wheel:Activate()
	self:SetValue("Active", true, true)
	self:UpdateAngularForce()
end

function Wheel:Deactivate()
	self:SetValue("Active", false, true)
	self:SetAngularForce(Vector(0, 0, 0))
end

function Wheel:SetCustomAngularForce(player, angular_force)
	self:SetValue("AngularForce", angular_force, true)

	if (self:GetValue("Active")) then
		self:UpdateAngularForce()
	end
end

function Wheel:UpdateAngularForce()
	self:SetAngularForce(self.axis * self:GetValue("AngularForce") * (self:GetValue("Forward") and 1 or -1))
end

function Wheel:SetActive(player, active)
	if (active) then
		self:Activate()
	else
		self:Deactivate()
	end
end

function Wheel:SetDirection(player, is_forward)
	self:SetValue("Forward", is_forward, true)

	if (self:GetValue("Active")) then
		self:UpdateAngularForce()
	end
end


Wheel.SubscribeRemote("SetActive", Wheel.SetActive)
Wheel.SubscribeRemote("SetCustomAngularForce", Wheel.SetCustomAngularForce)
Wheel.SubscribeRemote("SetDirection", Wheel.SetDirection)


-- fazer metodo no Single Target que chama quando da hover,