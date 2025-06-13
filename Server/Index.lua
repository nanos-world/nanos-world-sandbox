Package.Require("Config.lua")
Package.Require("SpawnMenu.lua")
Package.Require("Sky.lua")

-- List of Spawn Locations
SPAWN_POINTS = Server.GetMapSpawnPoints()

-- Custom Settings
SANDBOX_CUSTOM_SETTINGS = Server.GetCustomSettings()

function GetRandomSpawnPoint()
	return #SPAWN_POINTS > 0 and SPAWN_POINTS[math.random(#SPAWN_POINTS)] or { location = Vector(), rotation = Rotator() }
end

function CustomizeCharacter(character, mesh)
	-- Customization
	if (mesh == "nanos-world::SK_Male") then
		local selected_hair = SK_MALE_HAIR_MESHES[math.random(#SK_MALE_HAIR_MESHES)]
		if (selected_hair ~= "") then
			character:AddStaticMeshAttached("hair", selected_hair, "hair_male")
		end

		local selected_beard = SK_MALE_BEARD_MESHES[math.random(#SK_MALE_BEARD_MESHES)]
		if (selected_beard ~= "") then
			character:AddStaticMeshAttached("beard", selected_beard, "beard")
		end
	end

	if (mesh == "nanos-world::SK_Male" or mesh == "nanos-world::SK_Mannequin") then
		local selected_death_Sound = MALE_DEATH_SOUNDS[math.random(#MALE_DEATH_SOUNDS)]
		character:SetDeathSound(selected_death_Sound)

		local selected_pain_Sound = MALE_PAIN_SOUNDS[math.random(#MALE_PAIN_SOUNDS)]
		character:SetPainSound(selected_pain_Sound)
	end

	if (mesh == "nanos-world::SK_Female" or mesh == "nanos-world::SK_Mannequin_Female") then
		local selected_death_Sound = FEMALE_DEATH_SOUNDS[math.random(#FEMALE_DEATH_SOUNDS)]
		character:SetDeathSound(selected_death_Sound)

		local selected_pain_Sound = FEMALE_PAIN_SOUNDS[math.random(#FEMALE_PAIN_SOUNDS)]
		character:SetPainSound(selected_pain_Sound)
	end

	if (mesh == "nanos-world::SK_Female") then
		local selected_hair = SK_FEMALE_HAIR_MESHES[math.random(#SK_FEMALE_HAIR_MESHES)]
		if (selected_hair ~= "") then
			character:AddStaticMeshAttached("hair", selected_hair, "hair_female")
		end

		-- Those parameters are specific to female mesh
		character:SetMaterialColorParameter("BlushTint", Color(0.52, 0.12, 0.15))
		character:SetMaterialColorParameter("EyeShadowTint", Color(0.24, 0.05, 0.07))
		character:SetMaterialColorParameter("LipstickTint", Color(0.31, 0.03, 0.1))
	end

	-- Adds eyes to humanoid meshes
	if (mesh == "nanos-world::SK_Male" or mesh == "nanos-world::SK_Female") then
		character:AddStaticMeshAttached("eye_left", "nanos-world::SM_Eye", "eye_left")
		character:AddStaticMeshAttached("eye_right", "nanos-world::SM_Eye", "eye_right")

		-- Those parameters are specific to humanoid meshes (were added in their materials)
		character:SetMaterialColorParameter("HairTint", HAIR_TINTS[math.random(#HAIR_TINTS)], -1, "hair")
		character:SetMaterialColorParameter("Tint", HUMAN_SKIN_TONES[math.random(#HUMAN_SKIN_TONES)])

		character:SetMaterialScalarParameter("Muscular", math.random(100) / 100)
		character:SetMaterialScalarParameter("BaseColorPower", math.random(2) + 0.5)

		for _, morph_target in ipairs(HUMAN_MORPH_TARGETS) do
			character:SetMorphTarget(morph_target, math.random(200) / 100 - 1)
		end
	end
end

function SpawnCharacterRandomized(location, rotation, asset)
	local selected_mesh = asset or CHARACTER_MESHES[math.random(#CHARACTER_MESHES)]
	local spawn_point = GetRandomSpawnPoint()
	local new_char = Character(location or spawn_point.location, rotation or spawn_point.rotation, selected_mesh)

	CustomizeCharacter(new_char, selected_mesh)

	return new_char
end

-- Handles Characters Death, to auto respawn after a time
function OnPlayerCharacterDeath(chara, last_damage_taken, last_bone_damaged, damage_reason, hit_from, instigator)
	local controller = chara:GetPlayer()

	-- Was it supposed to happen? Maybe I was unpossessed
	if (not controller) then return end

	-- Outputs a message when dying
	if (instigator) then
		if (instigator == controller) then
			Chat.BroadcastMessage("<cyan>" .. instigator:GetName() .. "</> committed suicide")
		else
			Chat.BroadcastMessage("<cyan>" .. instigator:GetName() .. "</> killed <cyan>" .. controller:GetName() .. "</>")
		end
	else
		Chat.BroadcastMessage("<cyan>" .. controller:GetName() .. "</> died")
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

function SpawnPlayer(player, location, rotation)
	local new_char = SpawnCharacterRandomized(location, rotation)

	if (not SANDBOX_CUSTOM_SETTINGS.enable_pvp) then
		new_char:SetTeam(1)
	end

	player:Possess(new_char)

	-- Subscribe to Death event
	new_char:Subscribe("Death", OnPlayerCharacterDeath)

	-- Unsubscribe to Death event if unpossessed (in case we got possessed into another Character)
	new_char:Subscribe("UnPossess", function(self)
		self:Unsubscribe("Death", OnPlayerCharacterDeath)
	end)
end

-- When Player Connects, spawns a new Character and gives it to him
Player.Subscribe("Spawn", function(player)
	Chat.BroadcastMessage("<cyan>" .. player:GetName() .. "</> has joined the server")

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

	Chat.BroadcastMessage("<cyan>" .. player:GetName() .. "</> has left the server")
end)

Events.SubscribeRemote("ToggleNoClip", function(player)
	if (not SANDBOX_CUSTOM_SETTINGS.enable_noclip) then return end

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

Events.SubscribeRemote("EnterRagdoll", function(player)
	local character = player:GetControlledCharacter()
	if (not character) then return end

	if (not character:IsInputEnabled()) then return end
	if (character:GetVehicle()) then return end

	character:SetRagdollMode(true)
end)

Events.SubscribeRemote("RespawnCharacter", function(player)
	local character = player:GetControlledCharacter()
	if (not character) then return end

	character:SetHealth(0)
end)

Events.SubscribeRemote("SelectCharacterMesh", function(player, mesh)
	local chararacter = player:GetControlledCharacter()

	if (chararacter) then
		chararacter:SetMesh(mesh)

		chararacter:RemoveAllSkeletalMeshesAttached()
		chararacter:RemoveAllStaticMeshesAttached()

		chararacter:ClearMorphTargets()

		CustomizeCharacter(chararacter, mesh)
	end
end)

function GetPlayerByNameOrID(key)
	for _, player in pairs(Player.GetPairs()) do
		if (player:GetName() == key or player:GetID() == tonumber(key)) then
			return player
		end
	end

	return nil
end

-- TP console command
Console.RegisterCommand("tp", function(player1, player2)
	if (not player1 or not player2) then
		Console.Error("Invalid parameters passed to 'tp' command!")
		return
	end

	local p1 = GetPlayerByNameOrID(player1)
	local p2 = GetPlayerByNameOrID(player2)

	if (not p1) then Console.Error("Invalid Player 1 name or ID provided!") return end
	if (not p2) then Console.Error("Invalid Player 2 name or ID provided!") return end

	local char1 = p1:GetControlledCharacter()
	local char2 = p2:GetControlledCharacter()

	if (not char1) then Console.Error("Player 1 does not have a controlled Character!") return end
	if (not char2) then Console.Error("Player 2 does not have a controlled Character!") return end

	char1:SetLocation(char2:GetLocation())

	Console.Log("Teleporting '%s (Player#%d)' to '%s (Player#%d)'.", p1:GetName(), p1:GetID(), p2:GetName(), p2:GetID())
end, "teleports a player to another", { "player1", "player2" })


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

	Chat.BroadcastMessage("The package <cyan>Sandbox</> has been reloaded!")
end)

-- Exposes this to other packages
Package.Export("SpawnPlayer", SpawnPlayer)