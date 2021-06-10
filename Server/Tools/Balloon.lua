-- List of all spawned balloons
Balloons = setmetatable({}, { __mode = 'k' })

-- Spawns a Balloon
Events:Subscribe("SpawnBalloon", function(player, spawn_location, rotation, force, max_length, entity, distance_trace_object)
	-- Spawns a Balloon Prop (not allowing characters to pickup it)
	local balloon = Prop(spawn_location + Vector(0, 0, 10), Rotator(0, 0, 0), "NanosWorld::SM_Balloon", CollisionType.Normal, true, false)

	-- Adds a constant force upwards
	balloon:SetForce(Vector(0, 0, force), false)

	-- Configures the Ballon Physics
	balloon:SetPhysicsDamping(5, 10)

	-- Sets a random color for the balloon
	local color = Color.RandomPalette()
	balloon:SetMaterialColorParameter("Tint", color)

	-- Sets the player to be the network authority immediately of this Prop (so he can immediately start applying the force on it - on the client side)
	balloon:SetNetworkAuthority(player)

	-- Subscribes for popping when balloon takes damage
	balloon:Subscribe("TakeDamage", function(self, Damage, BoneName, _NanosDamageType, HitFromDirection, Instigator)
		self:Destroy()
	end)

	-- Spawns the Ballon cable
	local cable = Cable(spawn_location)

	-- Configures the Cable Linear Physics Limit
	cable:SetLinearLimits(ConstraintMotion.Limited, ConstraintMotion.Limited, ConstraintMotion.Limited, max_length, 0, true, 10000, 100)

	-- Sets cable rendering settings (width = 3, pieces = 4)
	cable:SetRenderingSettings(3, 4, 1)
	cable:SetCableSettings(max_length / 4, 10, 1)

	-- If to attach to an entity, attaches the start to it
	if (entity) then
		-- Gets the relative location rotated to attach to the exact point the player aimed
		local attach_location = entity:GetRotation():RotateVector(-distance_trace_object)
		cable:AttachStartTo(entity, attach_location)
	end

	-- Sets some values to be used later on (such as Balloon color to be used on popping Particles and the Cable itself to be able to destroy it properly)
	balloon:SetValue("Color", color, true)
	balloon:SetValue("Balloon", true)

	-- Attaches the Cable to the Balloon
	cable:AttachEndTo(balloon)

	-- Insers the Ballon in the global list
	table.insert(Balloons, balloon)

	-- Calls the client to add it to his spawn history
	Events:CallRemote("SpawnedItem", player, {balloon})

	-- Calls the Client to spawn ballons spawning sounds
	Events:BroadcastRemote("SpawnSound", {spawn_location, "NanosWorld::A_Balloon_Inflate", false, 0.75, 1})
	Particle(spawn_location, rotation, "NanosWorld::P_DirectionalBurst"):SetParameterColor("Color", color)

	balloon:Subscribe("Destroy", function(item)
		Events:BroadcastRemote("SpawnSound", {item:GetLocation(), "NanosWorld::A_Balloon_Pop", false, 1, 1})
		Particle(item:GetLocation() + Vector(0, 0, 30), Rotator(), "NanosWorld::P_OmnidirectionalBurst"):SetParameterColor("Color", item:GetValue("Color"))
	end)
end)

-- Timer for destroying balloons when they gets too high
Timer:SetTimeout(500, function()
	for k, balloon in pairs(Balloons) do
		-- If this balloon is higher enough, pops it
		if (balloon:IsValid() and balloon:GetLocation().Z > 3000 + math.random(10000)) then
			balloon:Destroy()
		end
	end
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("NanosWorld", "tools", "BalloonTool", function() return SpawnGenericToolGun(Vector(), Rotator(), Color.MAGENTA) end)