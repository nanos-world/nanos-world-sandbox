-- List of Character Meshes
character_meshes = {
	"NanosWorld::SK_Male",
	"NanosWorld::SK_Female",
	"NanosWorld::SK_Mannequin"
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

-- List of Spawn Locations
spawn_locations = {
	Vector(0, 0, 100),
	Vector(100, 0, 100),
	Vector(-100, 0, 100),
	Vector(0, 100, 100),
	Vector(0, -100, 100)
}

-- When Player Connects, spawns a new Character and gives it to him
Player:on("Spawn", function(player)
	local selected_mesh = character_meshes[math.random(#character_meshes)]
	local new_char = Character(spawn_locations[math.random(#spawn_locations)], Rotator(), selected_mesh)

	-- Adds eyes to humanoid meshes
	if (selected_mesh == "NanosWorld::SK_Male" or selected_mesh == "NanosWorld::SK_Female") then
		new_char:AddStaticMeshAttached("eye_left", "NanosWorld::SM_Eye", "eye_left")
		new_char:AddStaticMeshAttached("eye_right", "NanosWorld::SM_Eye", "eye_right")
	end

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

	if (selected_mesh == "NanosWorld::SK_Female") then
		local selected_hair = sk_female_hair_meshes[math.random(#sk_female_hair_meshes)]
		if (selected_hair ~= "") then
			new_char:AddStaticMeshAttached("hair", selected_hair, "hair_female")
		end
	end

	player:Possess(new_char)

	-- Sets a callback to automatically respawn the character, 10 seconds after he dies
	new_char:on("Death", function(last_damage_taken, last_bone_damaged, damage_reason, hit_from, instigator)
		if (instigator) then
			Server:BroadcastChatMessage("<cyan>" .. instigator:GetName() .. "</> killed <cyan>" .. player:GetName() .. "</>")
		else
			Server:BroadcastChatMessage("<cyan>" .. player:GetName() .. "</> died")
		end

		Timer:SetTimeout(10000, function(character)
			if (character:IsValid()) then
				character:Respawn()
			end

			return false
		end, {new_char})
	end)

	Server:BroadcastChatMessage("<cyan>" .. player:GetName() .. "</> has joined the server")
end)

-- Called when Character respawns
Character:on("Respawn", function(character)
	-- Sets the Initial Character's Location (location where the Character will spawn). After the Respawn event, a
	-- call for SetLocation(InitialLocation) will be triggered. If you always want something to respawn at the same
	-- position you do not need to keep setting SetInitialLocation, this is just for respawning at random spots
	character:SetInitialLocation(spawn_locations[math.random(#spawn_locations)])
end)

-- When Player Unpossess a Character (when player is unpossessing because is disconnecting 'is_player_disconnecting' = true)
Player:on("UnPossess", function(player, character, is_player_disconnecting)
	if (is_player_disconnecting) then
		character:Destroy()
	end
end)

Player:on("Destroy", function(player)
	Server:BroadcastChatMessage("<cyan>" .. player:GetName() .. "</> has left the server")
end)

-- Catches a custom event "MapLoaded" to override this script spawn locations
Events:on("MapLoaded", function(map_custom_spawn_locations)
	spawn_locations = map_custom_spawn_locations
end)
