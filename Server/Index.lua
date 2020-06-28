local character_meshes = {
	"NanosWorld::SK_Male",
	"NanosWorld::SK_Female",
	"NanosWorld::SK_Mannequin"
}

Player:on("Spawn", function(player)
	new_char = Character(Vector(0, 0, 100), Rotator(), character_meshes[math.random(#character_meshes)])
	player:Possess(new_char)
end)

Player:on("UnPossess", function(player, character, is_player_disconnecting)
	if (is_player_disconnecting) then
		character:Destroy()
	end
end)
