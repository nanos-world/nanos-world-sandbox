-- Character Customization data
CharacterCustomization = {
	-- All meshes available
	meshes = {
		{ id = "nanos-world::SK_Male", name = "Male", image = "assets://nanos-world/Thumbnails/SK_Male.jpg" },
		{ id = "nanos-world::SK_Female", name = "Female", image = "assets://nanos-world/Thumbnails/SK_Female.jpg" },
		{ id = "nanos-world::SK_Mannequin", name = "Mannequin", image = "assets://nanos-world/Thumbnails/SK_Mannequin.jpg" },
		{ id = "nanos-world::SK_Mannequin_Female", name = "Mannequin Female", image = "assets://nanos-world/Thumbnails/SK_Mannequin_Female.jpg" },
		{ id = "nanos-world::SK_ClassicMale", name = "Classic Male", image = "assets://nanos-world/Thumbnails/SK_ClassicMale.jpg" },
		{ id = "nanos-world::SK_PostApocalyptic", name = "Post Apocalyptic", image = "assets://nanos-world/Thumbnails/SK_PostApocalyptic.jpg" },
	},

	-- If it's currently possessed (i.e. meshes visible on ContextMenu)
	is_possessed = false
}

CharacterCustomization.AddMesh = function(id, name, image)
	table.insert(CharacterCustomization.meshes, { id = id, name = name, image = image })

	-- Updates screen dynamically
	if (CharacterCustomization.is_possessed) then
		CharacterCustomization.LocalPlayerUnPossess()
		CharacterCustomization.LocalPlayerPossess(Client.GetLocalPlayer(), Client.GetLocalPlayer():GetControlledCharacter())
	end
end

-- Exposes CharacterCustomization to other packages
Package.Export("CharacterCustomization", CharacterCustomization)

Client.Subscribe("SpawnLocalPlayer", function(local_player)
	local_player:Subscribe("Possess", CharacterCustomization.LocalPlayerPossess)
	local_player:Subscribe("UnPossess", CharacterCustomization.LocalPlayerUnPossess)
end)

Package.Subscribe("Load", function()
	local local_player = Client.GetLocalPlayer()

	if (local_player ~= nil) then
		local_player:Subscribe("Possess", CharacterCustomization.LocalPlayerPossess)
		local_player:Subscribe("UnPossess", CharacterCustomization.LocalPlayerUnPossess)

		local possessed_character = local_player:GetControlledCharacter()
		if (possessed_character) then
			CharacterCustomization.LocalPlayerPossess(local_player, possessed_character)
		end
	end
end)

function CharacterCustomization.LocalPlayerPossess(player, character)
	if (not character:IsA(Character)) then return end
	local current_mesh = character:GetMesh()

	-- Adds an entry to Context Menu
	ContextMenu.AddItems("character_customization", "character customization", {
		{ id = "character_mesh", type = "select_image", label = "mesh", callback_event = "SelectCharacterMesh", selected = current_mesh, options = CharacterCustomization.meshes},
	})

	CharacterCustomization.is_possessed = true
end

function CharacterCustomization.LocalPlayerUnPossess(player, character)
	ContextMenu.RemoveItems("character_customization")

	CharacterCustomization.is_possessed = false
end

MainHUD:Subscribe("SelectCharacterMesh", function(value)
	Events.CallRemote("SelectCharacterMesh", value)
end)