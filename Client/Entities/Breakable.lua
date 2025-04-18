Events.SubscribeRemote("SpawnDebris", function(prop, debris_offset, debris_rotation, mesh, lifespan)
	local parent_location = prop:GetLocation()-- + velocity / 30

	-- Avoiding spawning debris if it's too far
	if (parent_location:Distance(Client.GetLocalPlayer():GetCameraLocation()) > 8000) then return end

	local velocity = prop:GetVelocity()
	local parent_rotation = prop:GetRotation()

	-- Spawn the Debris
	local debris = Prop(
		parent_location + ((debris_offset and parent_rotation:UnrotateVector(debris_offset)) or Vector()),
		parent_rotation + (debris_rotation or Rotator.Random()),
		mesh,
		CollisionType.StaticOnly,
		true,
		GrabMode.Disabled,
		CCDMode.Disabled
	)

	-- Copy parent scale
	debris:SetScale(prop:GetScale())

	-- Copy parent velocity, adds a small randomness to make it better
	debris:AddImpulse(velocity * 0.5 + Vector(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100)), true)

	-- Setup lifespan
	debris:SetLifeSpan(lifespan)
end)