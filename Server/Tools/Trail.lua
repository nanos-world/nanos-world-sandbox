-- Subscribes for Client Event for spawning a Trail
Events:Subscribe("SpawnTrail", function(player, spawn_location, direction, entity)
	-- Calculates the Trail Rotation to spawn it
	local rotation = (direction * -1):Rotation() + Rotator(90, 0, 0)

	-- Spawns a Trail Prop
	local trail = Prop(spawn_location, rotation, "NanosWorld::SM_CupC", CollisionType.NoCollision, true, false)

	-- Spawns a Particle and attaches it to the trail
	local particle = Particle(spawn_location, Rotator(), "NanosWorld::P_Ribbon", false, true)

	local color = Color.RandomPalette()
	trail:SetMaterialColorParameter("Tint", color)

	particle:SetParameterColor("Color", color)
	particle:SetParameterFloat("LifeTime", 2)
	particle:SetParameterFloat("SpawnRate", 60)

	particle:AttachTo(trail)
	particle:SetRelativeLocation(rotation:RotateVector(direction * 10))

	trail:SetValue("Particle", particle)

	-- Sets the player to be the network authority immediately of this Prop (so he can immediately start applying the force on it - on the client side)
	trail:SetNetworkAuthority(player)

	-- Gets the relative location rotated to attach to the exact point the player aimed
	trail:AttachTo(entity, AttachmentRule.KeepWorld)
	entity:SetValue("Trail", trail)

	-- Updates the client's spawn history
	Events:CallRemote("SpawnedItem", player, { trail })

	Particle(spawn_location, rotation, "NanosWorld::P_DirectionalBurst")

	-- TODO change when we have event "On Detached"
	entity:Subscribe("Destroy", function(item)
		local _trail = item:GetValue("Trail")
		if (_trail and _trail:IsValid()) then
			_trail:Destroy()
		end
	end)

	trail:Subscribe("Destroy", function(item)
		local _particle = item:GetValue("Particle")
		if (_particle and _particle:IsValid()) then _particle:Destroy() end
	end)
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("NanosWorld", "tools", "TrailTool", function() return SpawnGenericToolGun(Vector(), Rotator(), Color.VIOLET) end)