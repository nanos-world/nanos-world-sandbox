Wheel = Prop.Inherit("Wheel")

-- ConfigureSpawnLimits("Wheel", "Wheels", Wheel.GetCount, "max_wheels")

function Wheel:Constructor(location, rotation, asset, angular_force, is_active, is_forward, scale, wheel_config)
	self.Super:Constructor(location, rotation, asset or "nanos-world::SM_Offroad_Tire", CollisionType.IgnoreOnlyPawn, true, GrabMode.Disabled)

	-- TODO is it needed? it makes needed more force
	self:SetMassOverride(100)

	if (is_active == nil) then is_active = true end
	if (is_forward == nil) then is_forward = true end
	if (angular_force == nil) then angular_force = 2000000 end

	self.wheel_config = wheel_config
	self.is_active = is_active
	self.is_forward = is_forward
	self.angular_force = angular_force

	if (scale and scale ~= 1) then
		self:SetScale(Vector(scale, scale, scale))
	end

	-- Sets the values as sync, so client can access it on Spawn event
	self:SetValue("Active", is_active, true)
	self:SetValue("Forward", is_forward, true)
	self:SetValue("AngularForce", angular_force, true)

	if (is_active and angular_force ~= 0) then
		self:UpdateAngularForce()
	end
end

function Wheel:Activate()
	self.is_active = true
	self:SetValue("Active", true, true)
	self:UpdateAngularForce()
end

function Wheel:Deactivate()
	self.is_active = false
	self:SetValue("Active", false, true)
	self:SetAngularForce(Vector(0, 0, 0))
end

function Wheel:SetCustomAngularForce(player, angular_force)
	self.angular_force = angular_force
	self:SetValue("AngularForce", angular_force, true)

	if (self.is_active) then
		self:UpdateAngularForce()
	end
end

function Wheel:UpdateAngularForce()
	self:SetAngularForce(self.wheel_config.direction * self.angular_force * (self.is_forward and 1 or -1))
end

function Wheel:SetActive(player, active, is_reversed)
	if (active) then
		-- If wants to reverse, reverse the forward (server side only) then UpdateAngularForce() will apply inverted force
		local old_forward = nil
		if (is_reversed) then
			old_forward = self.is_forward
			self.is_forward = not old_forward
		end

		self:Activate()

		-- Revert the original forward value
		if (is_reversed) then
			self.is_forward = old_forward
		end
	else
		self:Deactivate()
	end
end

function Wheel:SetDirection(player, is_forward)
	self.is_forward = is_forward
	self:SetValue("Forward", is_forward, true)

	if (self.is_active) then
		self:UpdateAngularForce()
	end
end


Wheel.SubscribeRemote("SetActive", Wheel.SetActive)
Wheel.SubscribeRemote("SetCustomAngularForce", Wheel.SetCustomAngularForce)
Wheel.SubscribeRemote("SetDirection", Wheel.SetDirection)