-- Context Menu data
ContextMenu = {
	-- Whether the menu is opened
	is_opened = false,

	-- List of functions called when ContextMenu is opened, to update their current value/label
	update_functions = {}
}

ContextMenu.AddItems = function(id, title, items)
	MainHUD:CallEvent("AddContextMenuItems", id, title, items)
end

ContextMenu.RemoveItems = function(id)
	MainHUD:CallEvent("RemoveContextMenuItems", id)
end

ContextMenu.AddUpdateFunction = function(id, func)
	if (type(func) ~= "function") then
		Console.Error("Invalid function parameter passed.")
		return
	end

	ContextMenu.update_functions[id] = func
end

ContextMenu.RemoveUpdateFunction = function(id)
	ContextMenu.update_functions[id] = nil
end

Input.Bind("ContextMenu", InputEvent.Pressed, function()
	if (SpawnMenu.is_opened) then return end

	if (ContextMenu.is_opened) then
		MainHUD:CallEvent("ToggleContextMenuVisibility", false)

		Input.SetMouseEnabled(false)
		Chat.SetVisibility(true)

		ContextMenu.is_opened = false
		PlayClickSound(0.9)
	else
		-- Opens context menu
		MainHUD:CallEvent("ToggleContextMenuVisibility", true)

		-- Calls all update functions
		for _, func in pairs(ContextMenu.update_functions) do
			func()
		end

		Input.SetMouseEnabled(true)
		Chat.SetVisibility(false)

		MainHUD:BringToFront()

		ContextMenu.is_opened = true
		PlayClickSound(1.1)
	end
end)

-- Called from Context Menu when pressing X
MainHUD:Subscribe("CloseContextMenu", function()
	Input.SetMouseEnabled(false)
	Chat.SetVisibility(true)
	ContextMenu.is_opened = false

	PlayClickSound(0.9)
end)


-- Common
ContextMenu.AddItems("common", "common", {
	{ id = "respawn_button", type = "button", label = "respawn", callback_event = "ContextMenu_Respawn" },
})

MainHUD:Subscribe("ContextMenu_Respawn", function()
	Events.CallRemote("RespawnCharacter")
end)
-- Common


CharacterMeshesMapContextMenu = {}

for i, v in ipairs(CHARACTER_MESHES) do
	table.insert(CharacterMeshesMapContextMenu, { id = i, name = v })
end

ContextMenu.AddItems("character_models", "character model", {
	{ id = "character_model", type = "select", label = "Character Model", selected = 5, callback_event = "ContextMenu_ChangeCharacterMesh", options = CharacterMeshesMapContextMenu},
})

function UpdatePMValue(id)
	MainHUD:CallEvent("SetContextMenuValue", "character_model", id)
end

Player.Subscribe("Possess", function(ply, char)
	if ply == Client.GetLocalPlayer() then
		local id
		for i, v in ipairs(CHARACTER_MESHES) do
			if v == char:GetMesh() then
				id = i
				break
			end
		end
		if id then
			UpdatePMValue(id)
		end
	end
end)

MainHUD:Subscribe("ContextMenu_ChangeCharacterMesh", function(value)
	if (not Client.GetLocalPlayer() or not Client.GetLocalPlayer():GetControlledCharacter()) then
		return
	end

	Events.CallRemote("SetCharacterModel", value)
end)
