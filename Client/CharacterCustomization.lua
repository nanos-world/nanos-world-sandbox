Client.Subscribe("SpawnLocalPlayer", function(local_player)
	local_player:Subscribe("Possess", LocalPlayerPossess)
	local_player:Subscribe("UnPossess", LocalPlayerUnPossess)
end)

Package.Subscribe("Load", function()
	local local_player = Client.GetLocalPlayer()

	if (local_player ~= nil) then
		local_player:Subscribe("Possess", LocalPlayerPossess)
		local_player:Subscribe("UnPossess", LocalPlayerUnPossess)

		local possessed_character = local_player:GetControlledCharacter()
		if (possessed_character) then
			LocalPlayerPossess(local_player, possessed_character)
		end
	end
end)

function LocalPlayerPossess(player, character)
	local current_mesh = character:GetMesh()

	-- Adds an entry to Context Menu
	ContextMenu.AddItems("character_customization", "character customization", {
		{ id = "character_mesh", type = "select_image", label = "mesh", callback_event = "SelectCharacterMesh", selected = current_mesh, options = {
			{ id = "nanos-world::SK_Male", name = "Male", image = "assets://nanos-world/Thumbnails/SK_Male.jpg" },
			{ id = "nanos-world::SK_Female", name = "Female", image = "assets://nanos-world/Thumbnails/SK_Female.jpg" },
			{ id = "nanos-world::SK_Mannequin", name = "Mannequin", image = "assets://nanos-world/Thumbnails/SK_Mannequin.jpg" },
			{ id = "nanos-world::SK_Mannequin_Female", name = "Mannequin Female", image = "assets://nanos-world/Thumbnails/SK_Mannequin_Female.jpg" },
			{ id = "nanos-world::SK_ClassicMale", name = "Classic Male", image = "assets://nanos-world/Thumbnails/SK_ClassicMale.jpg" },
			{ id = "nanos-world::SK_PostApocalyptic", name = "Post Apocalyptic", image = "assets://nanos-world/Thumbnails/SK_PostApocalyptic.jpg" },
		}},
	})
end

function LocalPlayerUnPossess(player, character)
	ContextMenu.RemoveItems("character_customization")
end

MainHUD:Subscribe("SelectCharacterMesh", function(value)
	Events.CallRemote("SelectCharacterMesh", value)
end)