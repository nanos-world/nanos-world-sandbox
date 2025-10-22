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

function SelectRandomMesh(mesh)
	if (type(mesh) == "table") then
		return SelectRandomMesh(mesh[math.random(#mesh)])
	else
		return mesh
	end
end

function CustomizeCharacter(character, mesh)
	local custom_config = CHARACTER_MESHES[mesh]
	if (not custom_config) then return end

	-- Death/Pain Sounds
	local selected_death_sound = ""
	local selected_pain_sound = ""

	if (custom_config.is_male) then
		selected_death_sound = MALE_DEATH_SOUNDS[math.random(#MALE_DEATH_SOUNDS)]
		selected_pain_sound = MALE_PAIN_SOUNDS[math.random(#MALE_PAIN_SOUNDS)]
	else
		selected_death_sound = FEMALE_DEATH_SOUNDS[math.random(#FEMALE_DEATH_SOUNDS)]
		selected_pain_sound = FEMALE_PAIN_SOUNDS[math.random(#FEMALE_PAIN_SOUNDS)]
	end

	character:SetDeathSound(selected_death_sound)
	character:SetPainSound(selected_pain_sound)

	if (custom_config.skeletal_meshes ~= nil) then
		for id, skeletal_meshes in pairs(custom_config.skeletal_meshes) do
			local skeletal_mesh = SelectRandomMesh(skeletal_meshes)
			if (skeletal_mesh ~= "") then
				character:AddSkeletalMeshAttached(id, skeletal_mesh)
			end
		end
	end

	if (custom_config.static_meshes ~= nil) then
		for id, static_mesh_config in pairs(custom_config.static_meshes) do
			local static_mesh = SelectRandomMesh(static_mesh_config.meshes)
			if (static_mesh ~= "") then
				character:AddStaticMeshAttached(id, static_mesh, static_mesh_config.socket)
			end
		end
	end

	if (custom_config.morph_targets ~= nil) then
		for _, morph_target in pairs(custom_config.morph_targets) do
			local value = math.random(100) / 100 - 0.5 -- Only from -0.5 ~ 0.5
			character:SetMorphTarget(morph_target, value)
		end
	end

	if (custom_config.morph_targets_force ~= nil) then
		for morph_target, value in pairs(custom_config.morph_targets_force) do
			character:SetMorphTarget(morph_target, value)
		end
	end

	if (custom_config.materials ~= nil) then
		for _, material_config in pairs(custom_config.materials) do
			local selected_material = math.random(#material_config.values)
			character:SetMaterial(material_config.values[selected_material], material_config.index, material_config.slot)
		end
	end

	if (custom_config.materials_parameters_color ~= nil) then
		for _, materials_parameter_color in pairs(custom_config.materials_parameters_color) do
			local selected_material = math.random(#materials_parameter_color.values)
			character:SetMaterialColorParameter(materials_parameter_color.parameter, materials_parameter_color.values[selected_material], -1, materials_parameter_color.slot)
		end
	end
end

function SpawnCharacterRandomized(location, rotation, asset)
	-- Iterate over whole table to get all keys
	local character_meshes = {}
	for k in pairs(CHARACTER_MESHES) do
		table.insert(character_meshes, k)
	end

	local selected_mesh = asset or character_meshes[math.random(#character_meshes)]
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
			if (not character:IsDead()) then return end

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
	-- When Package unloads, stores the characters locations to respawn them at the same position if the package is being reloaded
	for k, p in pairs(Player.GetAll()) do
		local cha = p:GetControlledCharacter()
		if (cha) then
			p:SetValue("last_position", { location = cha:GetLocation(), rotation = Rotator(0, cha:GetRotation().Yaw, 0) })
		end
	end
end)

Package.Subscribe("Load", function()
	for k, player in pairs(Player.GetAll()) do
		local last_position = player:GetValue("last_position")
		if (last_position) then
			SpawnPlayer(player, last_position.location, last_position.rotation)
		else
			SpawnPlayer(player)
		end
	end

	Chat.BroadcastMessage("The package <cyan>Sandbox</> has been reloaded!")
end)

-- Exposes this to other packages
Package.Export("SpawnPlayer", SpawnPlayer)