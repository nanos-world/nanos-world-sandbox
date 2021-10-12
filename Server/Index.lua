Package.Require("SpawnMenu.lua")

-- List of Character Meshes
CHARACTER_MESHES = {
	"nanos-world::SK_Male",
	"nanos-world::SK_Female",
	"nanos-world::SK_Mannequin",
	"nanos-world::SK_Mannequin_Female",
	"nanos-world::SK_ClassicMale",
	"nanos-world::SK_PostApocalyptic",
}

-- List of SK_Male hair Static Meshes
SK_MALE_HAIR_MESHES = {
	"",
	"nanos-world::SM_Hair_Long",
	"nanos-world::SM_Hair_Short"
}

-- List of SK_Male beard Static Meshes
SK_MALE_BEARD_MESHES = {
	"",
	"nanos-world::SM_Beard_Extra",
	"nanos-world::SM_Beard_Middle",
	"nanos-world::SM_Beard_Mustache_01",
	"nanos-world::SM_Beard_Mustache_02",
	"nanos-world::SM_Beard_Side"
}

-- List of SK_Female hair Static Meshes
SK_FEMALE_HAIR_MESHES = {
	"",
	"nanos-world::SM_Hair_Kwang"
}

-- List of Death Male voices
MALE_DEATH_SOUNDS = {
	"nanos-world::A_Male_01_Death",
	"nanos-world::A_Male_02_Death",
	"nanos-world::A_Male_03_Death",
	"nanos-world::A_Male_04_Death",
	"nanos-world::A_Male_05_Death",
	"nanos-world::A_Male_06_Death"
}

-- List of Pain Male voices
MALE_PAIN_SOUNDS = {
	"nanos-world::A_Male_01_Pain",
	"nanos-world::A_Male_02_Pain",
	"nanos-world::A_Male_03_Pain",
	"nanos-world::A_Male_04_Pain",
	"nanos-world::A_Male_05_Pain",
	"nanos-world::A_Male_06_Pain",
	"nanos-world::A_Male_07_Pain",
	"nanos-world::A_Male_06_Pain"
}

-- List of Death Female voices
FEMALE_DEATH_SOUNDS = {
	"nanos-world::A_Female_01_Death",
	"nanos-world::A_Female_02_Death",
	"nanos-world::A_Female_03_Death",
	"nanos-world::A_Female_04_Death",
	"nanos-world::A_Female_05_Death"
}

-- List of Pain Female voices
FEMALE_PAIN_SOUNDS = {
	"nanos-world::A_Female_01_Pain",
	"nanos-world::A_Female_02_Pain",
	"nanos-world::A_Female_03_Pain",
	"nanos-world::A_Female_04_Pain",
	"nanos-world::A_Female_05_Pain",
	"nanos-world::A_Female_06_Pain",
	"nanos-world::A_Female_07_Pain",
	"nanos-world::A_Female_06_Pain"
}

-- List of Male/Female Meshes Morph Targets
HUMAN_MORPH_TARGETS = {
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

HUMAN_SKIN_TONES = {
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

HAIR_TINTS = {
	Color(0.067708, 0.030797, 0.001471),
	Color(0.983483, 1.000000, 0.166667),
	Color(0.010000, 0.010000, 0.010000),
	Color(1.000000, 0.129006, 0.000000),
}

-- List of Spawn Locations
SPAWN_LOCATIONS = {
	Vector(0, 0, 300),
	Vector(100, 0, 300),
	Vector(-100, 0, 300),
	Vector(0, 100, 300),
	Vector(0, -100, 300)
}

function SpawnCharacterAlpha(location, rotation)
	local new_char = Character(location or SPAWN_LOCATIONS[math.random(#SPAWN_LOCATIONS)], rotation or Rotator(), "nanos-world::SK_Male")

	-- Spawns two kind of Characters
	if (math.random() >= 0.5) then
		-- Eye Guy

		-- Valve
		new_char:AddStaticMeshAttached("eye_valve", "nanos-world::SM_Valve", "eye_left", Vector(0, 1, 0), Rotator(-79.1, -58.7, 63.8))

		-- Eye
		new_char:AddStaticMeshAttached("eye_right", "nanos-world::SM_Eye", "eye_right")

		-- Color
		new_char:SetMaterialColorParameter("Tint", Color(0.59, 0.73, 0.47))
		new_char:SetMaterialScalarParameter("BaseColorPower", 1)

		-- Hair
		new_char:AddStaticMeshAttached("hair", "nanos-world::SM_Hair_Short", "hair_male")

		-- Morph Targets
		new_char:SetMorphTarget("nose1", 1)
		new_char:SetMorphTarget("nose2", -1)
		new_char:SetMorphTarget("brows", -0.3)
		new_char:SetMorphTarget("mouth", 0.44)
		new_char:SetMorphTarget("fat", -0.28)
		new_char:SetMorphTarget("nose3", -0.63)
		new_char:SetMorphTarget("chin", -0.15)
		new_char:SetMorphTarget("face", -0.88)
		new_char:SetMorphTarget("nose4", -1)
		new_char:SetMorphTarget("skinny", 0.1)
		new_char:SetMorphTarget("brows2", -0.12)
		new_char:SetMorphTarget("smirk", 1)
		new_char:SetMorphTarget("smirk2", 1)
		new_char:SetMorphTarget("smirk3", 0)
		new_char:SetMorphTarget("nose6", 0.3)
		new_char:SetMorphTarget("jaw_forward", -0.6)
		new_char:SetMorphTarget("lips", -0.16)
		new_char:SetMorphTarget("lips2", -0.78)
		new_char:SetMorphTarget("mouth_wide", 0.18)
		new_char:SetMorphTarget("eyes1", -1)
		new_char:SetMorphTarget("eyes2", 1)
		new_char:SetMorphTarget("eyes3", 1)
		new_char:SetMorphTarget("eyes4", -1)
		new_char:SetMorphTarget("eyes_retraction", -1)
		new_char:SetMorphTarget("eyes5", 1)
		new_char:SetMorphTarget("bodyfat", -1)
	else
		-- Nut Guy

		-- Valve
		new_char:AddStaticMeshAttached("nut_valve", "nanos-world::SM_Valve", "head", Vector(17.82, -7.7, 1.25), Rotator(80, 88, -110))

		-- Eyes
		new_char:AddStaticMeshAttached("eye_left", "nanos-world::SM_Eye", "eye_left")
		new_char:AddStaticMeshAttached("eye_right", "nanos-world::SM_Eye", "eye_right")

		-- Color
		new_char:SetMaterialColorParameter("Tint", Color(0.16, 0.16, 0.05))
		new_char:SetMaterialScalarParameter("BaseColorPower", 1.25)

		-- Morph Targets
		new_char:SetMorphTarget("nose1", 1)
		new_char:SetMorphTarget("nose2", 1)
		new_char:SetMorphTarget("mouth", 1)
		new_char:SetMorphTarget("fat", 1)
		new_char:SetMorphTarget("nose3", -1)
		new_char:SetMorphTarget("nose4", 1)
		new_char:SetMorphTarget("jaw", -0.3)
		new_char:SetMorphTarget("brows2", -1)
		new_char:SetMorphTarget("angry", 0.15)
		new_char:SetMorphTarget("nose6", 1)
		new_char:SetMorphTarget("jaw_forward", 0.42)
		new_char:SetMorphTarget("lips", 0.5)
		new_char:SetMorphTarget("lips2", 0.25)
		new_char:SetMorphTarget("mouth_wide", 0.5)
		new_char:SetMorphTarget("forehead", -0.5)
		new_char:SetMorphTarget("bodyfat", 1)
	end

	return new_char
end

function SpawnCharacterRandomized(location, rotation, asset)
	local selected_mesh = asset or CHARACTER_MESHES[math.random(#CHARACTER_MESHES)]
	local new_char = Character(location or SPAWN_LOCATIONS[math.random(#SPAWN_LOCATIONS)], rotation or Rotator(), selected_mesh)

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

	return new_char
end

function SpawnPlayer(player, location, rotation)
	-- local new_char = SpawnCharacterRandomized(location, rotation)

	-- Temp during event
	local new_char = SpawnCharacterAlpha(location, rotation)

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

		-- Respawns the Character after 5 seconds, we Bind the Timer to the Character, this way if the Character gets destroyed in the meanwhile, this Timer never gets destroyed
		Timer.Bind(
			Timer.SetTimeout(function(character)
				-- If he is not dead anymore after 5 seconds, ignores it
				if (character:GetHealth() ~= 0) then return end

				-- Respawns the Character at a random location
				character:Respawn(SPAWN_LOCATIONS[math.random(#SPAWN_LOCATIONS)])
			end, 5000, chara),
			chara
		)
	end)
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

-- Catches a custom event "MapLoaded" to override this script spawn locations
Events.Subscribe("MapLoaded", function(map_custom_spawn_locations)
	SPAWN_LOCATIONS = map_custom_spawn_locations
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
			if (p.player and p.player:IsValid()) then
				SpawnPlayer(p.player, p.location, p.rotation)
			end
		end
	end

	Server.BroadcastChatMessage("The package <cyan>Sandbox</> has been reloaded!")
end)

-- Exposes this to other packages
Package.Export("SpawnPlayer", SpawnPlayer)
