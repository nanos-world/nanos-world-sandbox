Package.Require("SpawnMenu.lua")

-- List of Character Meshes
character_meshes = {
	"NanosWorld::SK_Male",
	"NanosWorld::SK_Female",
	"NanosWorld::SK_Mannequin",
	"NanosWorld::SK_Mannequin_Female",
}

-- List of SK_Male hair Static Meshes
sk_male_hair_meshes = {
	"",
	"NanosWorld::SM_Hair_Long",
	"NanosWorld::SM_Hair_Short"
}

-- List of SK_Male beard Static Meshes
sk_male_beard_meshes = {
	"",
	"NanosWorld::SM_Beard_Extra",
	"NanosWorld::SM_Beard_Middle",
	"NanosWorld::SM_Beard_Mustache_01",
	"NanosWorld::SM_Beard_Mustache_02",
	"NanosWorld::SM_Beard_Side"
}

-- List of SK_Female hair Static Meshes
sk_female_hair_meshes = {
	"",
	"NanosWorld::SM_Hair_Kwang"
}

male_death_sounds = {
	"NanosWorld::A_Male_01_Death",
	"NanosWorld::A_Male_02_Death",
	"NanosWorld::A_Male_03_Death",
	"NanosWorld::A_Male_04_Death",
	"NanosWorld::A_Male_05_Death",
	"NanosWorld::A_Male_06_Death"
}

male_pain_sounds = {
	"NanosWorld::A_Male_01_Pain",
	"NanosWorld::A_Male_02_Pain",
	"NanosWorld::A_Male_03_Pain",
	"NanosWorld::A_Male_04_Pain",
	"NanosWorld::A_Male_05_Pain",
	"NanosWorld::A_Male_06_Pain",
	"NanosWorld::A_Male_07_Pain",
	"NanosWorld::A_Male_06_Pain"
}

female_death_sounds = {
	"NanosWorld::A_Female_01_Death",
	"NanosWorld::A_Female_02_Death",
	"NanosWorld::A_Female_03_Death",
	"NanosWorld::A_Female_04_Death",
	"NanosWorld::A_Female_05_Death"
}

female_pain_sounds = {
	"NanosWorld::A_Female_01_Pain",
	"NanosWorld::A_Female_02_Pain",
	"NanosWorld::A_Female_03_Pain",
	"NanosWorld::A_Female_04_Pain",
	"NanosWorld::A_Female_05_Pain",
	"NanosWorld::A_Female_06_Pain",
	"NanosWorld::A_Female_07_Pain",
	"NanosWorld::A_Female_06_Pain"
}

human_morph_targets = {
	"nose1",
	"nose2",
	"brows",
	"mouth",
	"fat",
	"nose3",
	"chin",
	"face",
	"nose4",
	"skinny",
	"jaw",
	"brows2",
	"angry",
	"smirk",
	"smirk2",
	"smirk3",
	"smile",
	"nose6",
	"jaw_forward",
	"lips",
	"lips2",
	"mouth_wide",
	"eyes1",
	"eyes2",
	"eyes3",
	"eyes4",
	"eyes_retraction",
	"lips3",
	"eyes5",
	"nose7",
	"forehead",
	"bodyfat",
}

human_skin_tones = {
	Color(1.000000, 1.000000, 1.000000),
	Color(1.000000, 0.926933, 0.820785),
	Color(0.984375, 0.854302, 0.661377),
	Color(1.000000, 0.866979, 0.785255),
	Color(0.890625, 0.768996, 0.658135),
	Color(0.880208, 0.706081, 0.588818),
	Color(0.526042, 0.340051, 0.221689),
	Color(0.244792, 0.185846, 0.151720),
	Color(0.791667, 0.573959, 0.428820),
	Color(0.947917, 0.655642, 0.399902),
	Color(0.583333, 0.406594, 0.261284),
	Color(0.645833, 0.465268, 0.360730),
	Color(1.000000, 0.917535, 0.739583),
	Color(0.932292, 0.825388, 0.670085),
	Color(0.817708, 0.710384, 0.549398),
	Color(0.765625, 0.620475, 0.454590),
	Color(0.050000, 0.050000, 0.080000),	
}

hair_tints = {
	Color(0.067708, 0.030797, 0.001471),
	Color(0.983483, 1.000000, 0.166667),
	Color(0.010000, 0.010000, 0.010000),
	Color(1.000000, 0.129006, 0.000000),
}

-- List of Spawn Locations
spawn_locations = {
	Vector(0, 0, 300),
	Vector(100, 0, 300),
	Vector(-100, 0, 300),
	Vector(0, 100, 300),
	Vector(0, -100, 300)
}

function SpawnPlayer(player, location, rotation)
	local selected_mesh = character_meshes[math.random(#character_meshes)]
	local new_char = Character(location or spawn_locations[math.random(#spawn_locations)], rotation or Rotator(), selected_mesh)

	-- Customization
	if (selected_mesh == "NanosWorld::SK_Male") then
		local selected_hair = sk_male_hair_meshes[math.random(#sk_male_hair_meshes)]
		if (selected_hair ~= "") then
			new_char:AddStaticMeshAttached("hair", selected_hair, "hair_male")
		end

		local selected_beard = sk_male_beard_meshes[math.random(#sk_male_beard_meshes)]
		if (selected_beard ~= "") then
			new_char:AddStaticMeshAttached("beard", selected_beard, "beard")
		end
	end

	if (selected_mesh == "NanosWorld::SK_Male" or selected_mesh == "NanosWorld::SK_Mannequin") then
		local selected_death_Sound = male_death_sounds[math.random(#male_death_sounds)]
		new_char:SetDeathSound(selected_death_Sound)

		local selected_pain_Sound = male_pain_sounds[math.random(#male_pain_sounds)]
		new_char:SetPainSound(selected_pain_Sound)
	end

	if (selected_mesh == "NanosWorld::SK_Female" or selected_mesh == "NanosWorld::SK_Mannequin_Female") then
		local selected_death_Sound = female_death_sounds[math.random(#female_death_sounds)]
		new_char:SetDeathSound(selected_death_Sound)

		local selected_pain_Sound = female_pain_sounds[math.random(#female_pain_sounds)]
		new_char:SetPainSound(selected_pain_Sound)
	end

	if (selected_mesh == "NanosWorld::SK_Female") then
		local selected_hair = sk_female_hair_meshes[math.random(#sk_female_hair_meshes)]
		if (selected_hair ~= "") then
			new_char:AddStaticMeshAttached("hair", selected_hair, "hair_female")
		end

		-- Those parameters are specific to female mesh
		new_char:SetMaterialColorParameter("BlushTint", Color(0.52, 0.12, 0.15))
		new_char:SetMaterialColorParameter("EyeShadowTint", Color(0.24, 0.05, 0.07))
		new_char:SetMaterialColorParameter("LipstickTint", Color(0.31, 0.03, 0.1))
	end

	-- Adds eyes to humanoid meshes
	if (selected_mesh == "NanosWorld::SK_Male" or selected_mesh == "NanosWorld::SK_Female") then
		new_char:AddStaticMeshAttached("eye_left", "NanosWorld::SM_Eye", "eye_left")
		new_char:AddStaticMeshAttached("eye_right", "NanosWorld::SM_Eye", "eye_right")

		-- Those parameters are specific to humanoid meshes (were added in their materials)
		new_char:SetMaterialColorParameter("HairTint", hair_tints[math.random(#hair_tints)])
		new_char:SetMaterialColorParameter("Tint", human_skin_tones[math.random(#human_skin_tones)])

		new_char:SetMaterialScalarParameter("Muscular", math.random(100) / 100)
		new_char:SetMaterialScalarParameter("BaseColorPower", math.random(2) + 0.5)

		for i, morph_target in ipairs(human_morph_targets) do
			new_char:SetMorphTarget(morph_target, math.random(200) / 100 - 1)
		end
	end

	player:Possess(new_char)

	-- Sets a callback to automatically respawn the character, 10 seconds after he dies
	new_char:Subscribe("Death", function(chara, last_damage_taken, last_bone_damaged, damage_reason, hit_from, instigator)
		if (instigator) then
			if (instigator == player) then
				Server.BroadcastChatMessage("<cyan>" .. instigator:GetName() .. "</> committed suicide")
			else
				Server.BroadcastChatMessage("<cyan>" .. instigator:GetName() .. "</> killed <cyan>" .. player:GetName() .. "</>")
			end
		else
			Server.BroadcastChatMessage("<cyan>" .. player:GetName() .. "</> died")
		end

		Timer.SetTimeout(function(character)
			if (character:IsValid() and character:GetHealth() == 0) then
				character:Respawn()
			end
		end, 5000, new_char)
	end)

	Server.BroadcastChatMessage("<cyan>" .. player:GetName() .. "</> has joined the server")
end

-- When Player Connects, spawns a new Character and gives it to him
Player.Subscribe("Spawn", SpawnPlayer)

-- Called when Character respawns
Character.Subscribe("Respawn", function(character)
	-- Sets the Initial Character's Location (location where the Character will spawn). After the Respawn event, a
	-- call for SetLocation(InitialLocation) will be triggered. If you always want something to respawn at the same
	-- position you do not need to keep setting SetInitialLocation, this is just for respawning at random spots
	character:SetInitialLocation(spawn_locations[math.random(#spawn_locations)])

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

-- Catches a custom event "MapLoaded" to override this script spawn locations
Events.Subscribe("MapLoaded", function(map_custom_spawn_locations)
	spawn_locations = map_custom_spawn_locations
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

Package.Subscribe("Unload", function()
	local character_locations = {}

	-- When Package unloads, stores the characters locations to respawn them at the same position if the package is being reloaded
	for k, p in pairs(Player.GetAll()) do
		local cha = p:GetControlledCharacter()
		if (cha) then
			table.insert(character_locations, { player = p, location = cha:GetLocation(), rotation = cha:GetRotation() })
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
			SpawnPlayer(p.player, p.location, p.rotation)
		end
	end
end)

-- Exposes this to other packages
Package.Export("SpawnPlayer", SpawnPlayer)
