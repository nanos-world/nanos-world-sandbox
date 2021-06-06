-- Event when Client calls to spawn a Lamp
Events:Subscribe("SpawnLamp", function(player, spawn_location, direction, entity, distance_trace_object)
	local rotation = direction:Rotation() + Rotator(-90, 0, 0)

	-- Spawns a Lamp Bulb prop
	local prop_lamp = Prop(spawn_location, Rotator(), "NanosWorld::SM_TeaPot_Interior")

	-- Sets the player to be the network authority immediately of this Prop
	prop_lamp:SetNetworkAuthority(player)

	-- Sets the prop mesh emissive color to a random color
	local color = Color(1, 0.6, 0.4)

	local prop_lamp_bulb = Prop(spawn_location, Rotator(), "NanosWorld::SM_Sphere", CollisionType.NoCollision, true, false)
	prop_lamp_bulb:AttachTo(prop_lamp)
	prop_lamp_bulb:SetScale(Vector(0.175, 0.175, 0.175))
	prop_lamp_bulb:SetRelativeLocation(Vector(-1.5, 0, 17.5))
	prop_lamp_bulb:SetMaterialColorParameter("Emissive", color * 50)
	prop_lamp:SetValue("Bulb", prop_lamp_bulb)

	-- Spawns a Point Light, with the color
	local intensity = 100
	local light = Light(Vector(), Rotator(), color, LightType.Spot, intensity, 1000, 25, 0.975, 2000, false)

	-- Attaches the lamp to the prop, offseting 25 downwards
	light:AttachTo(prop_lamp)
	light:SetRelativeLocation(Vector(0, 0, 30))
	light:SetRelativeRotation(Rotator(90, 0, 0))

	-- If to attach to an entity, otherwise creates and attaches to a fixed invisible mesh
	if (entity) then
		prop_lamp:AttachTo(entity, AttachmentRule.KeepWorld)
		prop_lamp:SetGrabbable(false)
	end

	prop_lamp:SetValue("Light", light)
	prop_lamp:SetRotation(rotation)

	-- Calls the client to add it to his spawn history
	Events:CallRemote("SpawnedItem", player, {prop_lamp})

	Particle(spawn_location, direction:Rotation(), "NanosWorld::P_DirectionalBurst"):SetParameterColor("Color", color)
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("NanosWorld", "tools", "LampTool", function() return SpawnGenericToolGun(Vector(), Rotator(), Color.YELLOW) end)