-- Global table to store Sandbox related functions and variables, exposed to other packages
Sandbox = {}

-- Exposes Sandbox to other packages, this will contain all subsystems as well
Package.Export("Sandbox", Sandbox)

-- List of Spawn Locations
SPAWN_POINTS = Server.GetMapSpawnPoints()

-- Custom Settings
SANDBOX_CUSTOM_SETTINGS = Server.GetCustomSettings()

-- Configured limits for spawned items per player
SANDBOX_LIMITS = {
	-- ["ID"] = { max_count = 0, label = "Label", func_check = function() }
}

-- TODO store limits per player?
--	 weak table k, store per [player][id] = { item, item } (weak v)
function ConfigureSpawnLimits(ID, label, func_check, setting_override)
	local max_count = SANDBOX_CUSTOM_SETTINGS[setting_override]

	if (not max_count) then
		Console.Warn("No setting found to configure '%s' (%s) limits as '%s'", ID, label, setting_override)
		return
	end

	Console.Debug("Configuring '%s' (%s) limits: %d", ID, label, max_count)

	SANDBOX_LIMITS[ID] = { max_count = max_count, label = label, func_check = func_check }
end

-- Validates if a player can spawn an item
function ValidateSpawnLimits(player, ID)
	local limit_data = SANDBOX_LIMITS[ID]

	-- No limits for this item
	if (not limit_data or limit_data.max_count == 0 or not limit_data.func_check) then
		return true
	end

	local current_count = limit_data.func_check()

	-- Under limits
	if (current_count < limit_data.max_count) then
		return true
	end

	-- Can't spawn
	Events.CallRemote("AddNotification", player, NotificationType.Warning, "SPAWN_LIMIT_" .. ID, "the server have reached the configured limit of " .. limit_data.max_count .. " " .. limit_data.label .. ".", 3, 0, true)

	return false
end

function GetRandomSpawnPoint()
	return #SPAWN_POINTS > 0 and SPAWN_POINTS[math.random(#SPAWN_POINTS)] or { location = Vector(), rotation = Rotator() }
end

-- Handles Characters Death, to auto respawn after a time
function OnPlayerCharacterDeath(character, last_damage_taken, last_bone_damaged, damage_reason, hit_from, instigator)
	local controller = character:GetPlayer()

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

	-- Respawn the Character after 5 seconds, we Bind the Timer to the Character, this way if the Character gets destroyed in the meanwhile, this Timer never gets destroyed
	Timer.Bind(
		Timer.SetTimeout(function()
			-- If he is not dead anymore after 5 seconds, ignores it
			if (not character:IsDead()) then return end

			RandomRespawnCharacter(character)
		end, 5000),
		character
	)
end

-- Respawn the Character at a random point
function RandomRespawnCharacter(character)
	local spawn_point = GetRandomSpawnPoint()
	character:Respawn(spawn_point.location, spawn_point.rotation)
end

-- Spawns a Character for the Player
function SpawnPlayerCharacter(player)
	-- TODO cache classes?
	local character_classes = {}
	for k, class in pairs(Character.GetInheritedClasses(true)) do
		if (class ~= BaseDefaultCharacter and class ~= BaseDefaultCharacterSimple) then
			table.insert(character_classes, class)
		end
	end

	local character_to_spawn = character_classes[math.random(#character_classes)]

	local location, rotation = nil, nil

	local last_position = player:GetValue("last_position")
	if (last_position) then
		location = last_position.location
		rotation = last_position.rotation
	else
		local spawn_point = GetRandomSpawnPoint()
		location = spawn_point.location
		rotation = spawn_point.rotation
	end

	-- Spawns the Character
	local new_character = character_to_spawn(location, rotation, false)

	-- This will possess, configure Player configs and subscribe to events
	SetupPlayerCharacter(player, new_character)
end

-- Possess, configure Player configs and subscribe to events
function SetupPlayerCharacter(player, character)
	-- Disables PVP if set
	if (not SANDBOX_CUSTOM_SETTINGS.enable_pvp) then
		character:SetTeam(1)
	end

	-- Possess the Character
	player:Possess(character)

	-- Subscribe to Death event
	character:Subscribe("Death", OnPlayerCharacterDeath)

	-- Unsubscribe to Death event if unpossessed (in case we got possessed into another Character)
	character:Subscribe("UnPossess", function(self)
		self:Unsubscribe("Death", OnPlayerCharacterDeath)
	end)
end

-- When Player Connects, spawns a new Character and gives it to him
Player.Subscribe("Spawn", function(player)
	Chat.BroadcastMessage("<cyan>" .. player:GetName() .. "</> has joined the server")

	SpawnPlayerCharacter(player)
end)

-- Called when Character respawns
Character.Subscribe("Respawn", function(character)
	-- Resets character's scale to default
	character:SetScale(Vector(1, 1, 1))
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
	if (not character or not character.SetRagdollMode) then return end

	if (not character:IsInputEnabled()) then return end
	if (character:GetVehicle()) then return end

	character:SetRagdollMode(true)
end)

Events.SubscribeRemote("RespawnCharacter", function(player)
	-- Respawn Character or spawn a new one
	local character = player:GetControlledCharacter()
	if (character) then
		RandomRespawnCharacter(character)
	else
		SpawnPlayerCharacter(player)
	end
end)

Events.SubscribeRemote("ChangeCharacter", function(player, class_name)
	local character = player:GetControlledCharacter()

	local location, rotation, picked_item = nil, nil, nil

	if (character) then
		if (character.GetPicked) then
			picked_item = character:GetPicked()
		end

		location = character:GetLocation()
		rotation = character:GetRotation()

		character:Destroy()
	else
		local spawn_point = GetRandomSpawnPoint()
		location = spawn_point.location
		rotation = spawn_point.rotation
	end

	-- TODO better way to get the class?
	local class = _G[class_name]
	local new_character = class(location, rotation, false)

	-- This will possess, configure Player configs and subscribe to events
	SetupPlayerCharacter(player, new_character)

	-- Restore picked up item
	if (picked_item) then
		new_character:PickUp(picked_item)
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

-- Client Commands
Events.SubscribeRemote("ClientCommand", function(player, command)
	if (command == "reset") then
		Console.Log("The Player '%s' has requested to reset the package.", player:GetName())

		if (Player.GetCount() > 1) then
			Events.CallRemote("AddNotification", player, NotificationType.Error, "CANT_RESET", "you cannot reset the package while other players are connected", 3, 0, true)
			return
		end

		Server.ReloadPackage("sandbox")
		return
	end
end)

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
		SpawnPlayerCharacter(player)
	end

	Chat.BroadcastMessage("The package <cyan>Sandbox</> has been reloaded!")
end)

Package.Require("SpawnMenu.lua")
Package.Require("SpawnHistory.lua")
Package.Require("Sky.lua")