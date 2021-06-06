-- Event when Client calls to spawn a Light
Events:Subscribe("SpawnLight", function(player, spawn_location, direction, entity, distance_trace_object)
	local rotation = direction:Rotation() + Rotator(90, 0, 0)

	-- Spawns a Light Bulb prop
	local prop_light = Prop(spawn_location, Rotator(), "NanosWorld::SM_Lamp", CollisionType.Normal, true, false)
	prop_light:SetCollision(CollisionType.StaticOnly)

	-- Sets the player to be the network authority immediately of this Prop
	prop_light:SetNetworkAuthority(player)

	-- Sets the prop mesh emissive color to a random color
	local color = Color.RandomPalette()
	prop_light:SetMaterialColorParameter("Emissive", color * 50)
	-- prop_light:SetPhysicsDamping(5, 10)

	-- Spawns a Point Light, with the color
	local intensity = 100
	local light = Light(Vector(), Rotator(), color, LightType.Point, intensity, 250, 44, 0, 2000)

	-- Attaches the light to the prop, offseting 25 downwards
	light:AttachTo(prop_light)
	light:SetRelativeLocation(Vector(0, 0, -25))

	-- Spawns the Cable
	local cable = Cable(spawn_location)

	-- Configures the cable
	local cable_length = 100
	cable:SetLinearLimits(ConstraintMotion.Limited, ConstraintMotion.Limited, ConstraintMotion.Limited, cable_length)
	cable:SetRenderingSettings(3, 4, 1)
	cable:SetCableSettings(cable_length / 4, 10, 1)

	-- If to attach to an entity, otherwise creates and attaches to a fixed invisible mesh
	if (entity) then
		-- Gets the relative location rotated to attach to the exact point the player aimed
		local attach_location = entity:GetRotation():RotateVector(-distance_trace_object)
		cable:AttachStartTo(entity, attach_location)
	end

	cable:AttachEndTo(prop_light)
	prop_light:SetValue("Light", light)
	prop_light:SetRotation(rotation)
	prop_light:SetLocation(spawn_location)

	-- Calls the client to add it to his spawn history
	Events:CallRemote("SpawnedItem", player, {prop_light})

	Particle(spawn_location, direction:Rotation(), "NanosWorld::P_DirectionalBurst"):SetParameterColor("Color", color)
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("NanosWorld", "tools", "LightTool", function() return SpawnGenericToolGun(Vector(), Rotator(), Color.YELLOW) end)