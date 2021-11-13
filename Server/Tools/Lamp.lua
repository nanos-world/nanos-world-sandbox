-- Event when Client calls to spawn a Lamp
Events.Subscribe("SpawnLamp", function(player, spawn_location, direction, entity)
	local rotation = direction:Rotation()

	-- Spawns a Lamp Bulb prop
	local prop_lamp = Prop(spawn_location, Rotator(), "nanos-world::SM_Flashlight", CollisionType.StaticOnly)

	-- Sets the player to be the network authority immediately of this Prop
	prop_lamp:SetNetworkAuthority(player)

	-- Spawns a Point Light, with the color
	local intensity = 75

	-- Sets the prop mesh emissive color to a random color
	local color = Color(1, 0.6, 0.4)
	prop_lamp:SetMaterialColorParameter("Emissive", color * intensity)

	local light = Light(Vector(), Rotator(), color, LightType.Spot, intensity, 1000, 25, 0.975, 2000, false)
	light:SetTextureLightProfile(LightProfile.Shattered_02)

	-- Attaches the lamp to the prop, offseting 25 downwards
	light:AttachTo(prop_lamp, AttachmentRule.SnapToTarget, "", 0)
	light:SetRelativeLocation(Vector(35, 0, 0))

	-- If to attach to an entity, otherwise creates and attaches to a fixed invisible mesh
	if (entity) then
		prop_lamp:AttachTo(entity, AttachmentRule.KeepWorld)
		prop_lamp:SetGrabbable(false)
	end

	prop_lamp:SetRotation(rotation)

	-- Calls the client to add it to his spawn history
	Events.CallRemote("SpawnedItem", player, prop_lamp)

	Particle(spawn_location, direction:Rotation(), "nanos-world::P_DirectionalBurst"):SetParameterColor("Color", color)
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "tools", "LampTool", function() return SpawnGenericToolGun(Vector(), Rotator(), Color.YELLOW) end)