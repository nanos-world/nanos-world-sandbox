Package.Require("Config.lua")
Package.Require("SpawnMenu.lua")

-- List of Spawn Locations
SPAWN_POINTS = Server.GetMapSpawnPoints()

CHARACTER_MESHES_FOR_RANDOM = {}
for k, v in pairs(CHARACTER_MESHES) do
	table.insert(CHARACTER_MESHES_FOR_RANDOM, v)
end

function GetRandomSpawnPoint()
	return #SPAWN_POINTS > 0 and SPAWN_POINTS[math.random(#SPAWN_POINTS)] or { location = Vector(), rotation = Rotator() }
end

function CharacterCustomization(new_char, selected_mesh)
	-- Customization
	if (selected_mesh == "nanos-world::SK_Male") then
		local selected_hair = SK_MALE_HAIR_MESHES[math.random(#SK_MALE_HAIR_MESHES)]
		if (selected_hair ~= "") then
			new_char:AddStaticMeshAttached("hair", selected_hair, "hair_male")
		end

		local selected_beard = SK_MALE_BEARD_MESHES[math.random(#SK_MALE_BEARD_MESHES)]
		if (selected_beard ~= "") then
			new_char:AddStaticMeshAttached("beard", selected_beard, "beard")
		end
	end

	if (selected_mesh == "nanos-world::SK_Male" or selected_mesh == "nanos-world::SK_Mannequin") then
		local selected_death_Sound = MALE_DEATH_SOUNDS[math.random(#MALE_DEATH_SOUNDS)]
		new_char:SetDeathSound(selected_death_Sound)

		local selected_pain_Sound = MALE_PAIN_SOUNDS[math.random(#MALE_PAIN_SOUNDS)]
		new_char:SetPainSound(selected_pain_Sound)
	end

	if (selected_mesh == "nanos-world::SK_Female" or selected_mesh == "nanos-world::SK_Mannequin_Female") then
		local selected_death_Sound = FEMALE_DEATH_SOUNDS[math.random(#FEMALE_DEATH_SOUNDS)]
		new_char:SetDeathSound(selected_death_Sound)

		local selected_pain_Sound = FEMALE_PAIN_SOUNDS[math.random(#FEMALE_PAIN_SOUNDS)]
		new_char:SetPainSound(selected_pain_Sound)
	end

	if (selected_mesh == "nanos-world::SK_Female") then
		local selected_hair = SK_FEMALE_HAIR_MESHES[math.random(#SK_FEMALE_HAIR_MESHES)]
		if (selected_hair ~= "") then
			new_char:AddStaticMeshAttached("hair", selected_hair, "hair_female")
		end

		-- Those parameters are specific to female mesh
		new_char:SetMaterialColorParameter("BlushTint", Color(0.52, 0.12, 0.15))
		new_char:SetMaterialColorParameter("EyeShadowTint", Color(0.24, 0.05, 0.07))
		new_char:SetMaterialColorParameter("LipstickTint", Color(0.31, 0.03, 0.1))
	end

	-- Adds eyes to humanoid meshes
	if (selected_mesh == "nanos-world::SK_Male" or selected_mesh == "nanos-world::SK_Female") then
		new_char:AddStaticMeshAttached("eye_left", "nanos-world::SM_Eye", "eye_left")
		new_char:AddStaticMeshAttached("eye_right", "nanos-world::SM_Eye", "eye_right")

		-- Those parameters are specific to humanoid meshes (were added in their materials)
		new_char:SetMaterialColorParameter("HairTint", HAIR_TINTS[math.random(#HAIR_TINTS)])
		new_char:SetMaterialColorParameter("Tint", HUMAN_SKIN_TONES[math.random(#HUMAN_SKIN_TONES)])

		new_char:SetMaterialScalarParameter("Muscular", math.random(100) / 100)
		new_char:SetMaterialScalarParameter("BaseColorPower", math.random(2) + 0.5)

		for i, morph_target in ipairs(HUMAN_MORPH_TARGETS) do
			new_char:SetMorphTarget(morph_target, math.random(200) / 100 - 1)
		end
	end
end

function SpawnCharacterRandomized(location, rotation, asset)
	local selected_mesh = asset or CHARACTER_MESHES_FOR_RANDOM[math.random(#CHARACTER_MESHES_FOR_RANDOM)]
	local spawn_point = GetRandomSpawnPoint()
	local new_char = Character(location or spawn_point.location, rotation or spawn_point.rotation, selected_mesh)

	CharacterCustomization(new_char, selected_mesh)

	return new_char
end

Events.Subscribe("CharacterSelect", function(player, character_name)
	local char = player:GetControlledCharacter()
	if char then
		local location = char:GetLocation()
		local rotation = char:GetRotation()

		char:Destroy()

		local new_char = SpawnCharacterRandomized(location, rotation, CHARACTER_MESHES[character_name])
		player:Possess(new_char)
	end
end)

Character.Subscribe("Death", function(chara, last_damage_taken, last_bone_damaged, damage_reason, hit_from, instigator)
	local player = chara:GetPlayer()
	if player then
		if (instigator) then
			if (instigator == player) then
				Server.BroadcastChatMessage("<cyan>" .. instigator:GetName() .. "</> committed suicide")
			else
				Server.BroadcastChatMessage("<cyan>" .. instigator:GetName() .. "</> killed <cyan>" .. player:GetName() .. "</>")
			end
		else
			Server.BroadcastChatMessage("<cyan>" .. player:GetName() .. "</> died")
		end

		-- Respawns the Character after 5 seconds, we Bind the Timer to the Character, this way if the Character gets destroyed in the meanwhile, this Timer never gets destroyed
		Timer.Bind(
			Timer.SetTimeout(function(character)
				-- If he is not dead anymore after 5 seconds, ignores it
				if (character:GetHealth() ~= 0) then return end

				-- Respawns the Character at a random point
				local spawn_point = GetRandomSpawnPoint()
				character:Respawn(spawn_point.location, spawn_point.rotation)
			end, 5000, chara),
			chara
		)
	end
end)

function SpawnPlayer(player, location, rotation)
	local new_char = SpawnCharacterRandomized(location, rotation)

	player:Possess(new_char)
end

-- When Player Connects, spawns a new Character and gives it to him
Player.Subscribe("Spawn", function(player)
	Server.BroadcastChatMessage("<cyan>" .. player:GetName() .. "</> has joined the server")

	SpawnPlayer(player)
end)

-- Called when Character respawns
Character.Subscribe("Respawn", function(character)
	-- Resets character's scale to default
	character:SetScale(Vector(1, 1, 1))

	-- Detaches all entities attached to the character
	for k, v in pairs(character:GetAttachedEntities()) do
		v:Detach()
	end
end)

-- When Player leaves the server
Player.Subscribe("Destroy", function(player)
	-- Destroy it's Character
	local character = player:GetControlledCharacter()
	if (character) then
		character:Destroy()
	end

	Server.BroadcastChatMessage("<cyan>" .. player:GetName() .. "</> has left the server")
end)

Events.Subscribe("ToggleNoClip", function(player)
	local character = player:GetControlledCharacter()
	if (not character) then return end

	local is_noclipping = character:GetValue("NoClip")

	if (is_noclipping) then
		character:SetFlyingMode(false)
		character:SetCollision(CollisionType.Normal)
	else
		character:SetFlyingMode(true)
		character:SetCollision(CollisionType.NoCollision)
	end

	character:SetValue("NoClip", not is_noclipping)
end)

Events.Subscribe("EnterRagdoll", function(player)
	local character = player:GetControlledCharacter()
	if (not character) then return end

	if (not character:IsMovementEnabled()) then return end
	if (character:GetVehicle()) then return end

	character:SetRagdollMode(true)
end)

Events.Subscribe("RespawnCharacter", function(player)
	local character = player:GetControlledCharacter()
	if (not character) then return end

	character:SetHealth(0)
end)

Package.Subscribe("Unload", function()
	local character_locations = {}

	-- When Package unloads, stores the characters locations to respawn them at the same position if the package is being reloaded
	for k, p in pairs(Player.GetAll()) do
		local cha = p:GetControlledCharacter()
		if (cha) then
			table.insert(character_locations, { player = p, location = cha:GetLocation(), rotation = Rotator(0, cha:GetRotation().Yaw, 0) })
		end
	end

	Server.SetValue("character_locations", character_locations)
end)

Package.Subscribe("Load", function()
	local character_locations = Server.GetValue("character_locations") or {}

	-- When Package loads, restores if existing, the latest player`s character positions
	if (#character_locations == 0) then
		-- If there is not stored locations, just spawn everyone randomly
		for k, player in pairs(Player.GetAll()) do
			SpawnPlayer(player)
		end
	else
		for k, p in pairs(character_locations) do
			if (p.player and p.player:IsValid()) then
				SpawnPlayer(p.player, p.location, p.rotation)
			end
		end
	end

	Server.BroadcastChatMessage("The package <cyan>Sandbox</> has been reloaded!")
end)

-- Exposes this to other packages
Package.Export("SpawnPlayer", SpawnPlayer)
