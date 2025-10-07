-- Character Customization data
CharacterCustomization = {
	-- If it's currently possessed (i.e. meshes visible on ContextMenu)
	is_possessed = false
}

CharacterCustomization.AddMesh = function(id, name, image)
	CHARACTER_MESHES[id] = { name = name, image = image }

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

	local meshes = {}
	for k, v in pairs(CHARACTER_MESHES) do
		table.insert(meshes, {
			id = k,
			name = v.name,
			image = v.image
		})
	end

	-- Adds an entry to Context Menu
	ContextMenu.AddItems("character_customization", "character customization", {
		{ id = "character_mesh", type = "select_image", label = "mesh", callback_event = "SelectCharacterMesh", selected = current_mesh, options = meshes},
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