-- List of Character Meshes
character_meshes = {
	"NanosWorld::SK_Male",
	"NanosWorld::SK_Female",
	"NanosWorld::SK_Mannequin"
}

-- List of Spawn Locations
spawn_locations = {
	Vector(0, 0, 100)
}

-- When Player Connects, spawns a new Character and gives it to him
Player:on("Spawn", function(player)
	new_char = Character(spawn_locations[math.random(#spawn_locations)], Rotator(), character_meshes[math.random(#character_meshes)])
	player:Possess(new_char)
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

-- Catchs a custom event "MapLoaded" to override this script spawn locations
Events:on("MapLoaded", function(map_custom_spawn_locations)
	spawn_locations = map_custom_spawn_locations
end)
