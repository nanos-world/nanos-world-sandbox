-- All notifications already sent
PERSISTENT_DATA_NOTIFICATIONS = PERSISTENT_DATA_NOTIFICATIONS or {}

-- Spawns Sandbox HUD
MainHUD = MainHUD or WebUI("Sandbox HUD", "file:///UI/index.html")

-- Configures Keybindings Inputs
Input.Register("NoClip", "B", "Toggles the No Clip mode")
Input.Register("Scoreboard", "Tab", "Toggles the Scoreboard")
Input.Register("Ragdoll", "J", "Enters Ragdoll Mode")
Input.Register("SpawnMenu", "Q", "Toggles the Spawn Menu")
Input.Register("ContextMenu", "C", "Toggles the Context Menu")
Input.Register("Undo", "X", "Destroy last spawned Item")

-- Loads Package Files
Package.Require("Config.lua")
Package.Require("Notifications.lua")
Package.Require("ContextMenu.lua")
Package.Require("SpawnMenu.lua")
Package.Require("Scoreboard.lua")
Package.Require("Sky.lua")
Package.Require("CharacterCustomization.lua")
Package.Require("Nametags.lua")

-- Hit Taken Feedback Sound Cached
SoundHitTakenFeedback = Sound(Vector(), "nanos-world::A_HitTaken_Feedback", true, false, SoundType.SFX, 1, 1, 400, 3600, 0, false, 0, false)


-- When LocalPlayer spawns, sets an event on it to trigger when we possesses a new character, to store the local controlled character locally.
-- This event is only called once, see Package.Subscribe("Load") to load it when reloading a package
Client.Subscribe("SpawnLocalPlayer", function(local_player)
	SetupLocalPlayer(local_player)
end)

-- When package loads, verify if LocalPlayer already exists (eg. when reloading the package), then try to get and store it's controlled character
Package.Subscribe("Load", function()
	Input.SetMouseEnabled(false)
	Input.SetInputEnabled(true)

	local local_player = Client.GetLocalPlayer()

	if (local_player ~= nil) then
		UpdateLocalCharacter(local_player:GetControlledCharacter())
		SetupLocalPlayer(local_player)
	end

	-- Gets all notifications already sent
	PERSISTENT_DATA_NOTIFICATIONS = Package.GetPersistentData().notifications or {}
end)

-- Function to set all needed events on local character (to update the UI when it takes damage or dies)
---@param character Character
function UpdateLocalCharacter(character)
	-- Verifies if character is not nil (eg. when GetControllerCharacter() doesn't return a character)
	if (character == nil) then return end

	-- Sets on character an event to update the health's UI after it takes damage
	character:Subscribe("HealthChange", OnCharacterHealthChange)

	if (character:IsA(Character)) then
		-- Sets on character an event to update his grabbing weapon (to show ammo on UI)
		character:Subscribe("PickUp", OnCharacterPickup)

		-- Sets on character an event to remove the ammo ui when he drops it's weapon
		character:Subscribe("Drop", OnCharacterDrop)

		-- Try to get if the character is holding any weapon
		local current_picked_item = character:GetPicked()

		-- If so, update the UI
		if (current_picked_item and current_picked_item:IsA(Weapon) and not current_picked_item:IsA(ToolGun)) then
			UpdateAmmo(true, current_picked_item:GetAmmoClip(), current_picked_item:GetAmmoBag())
		end
	end

	-- Updates the UI with the current character's health
	UpdateHealth(character:GetHealth())
end

-- Setups the Local Player events
---@param local_player Player
function SetupLocalPlayer(local_player)
	local_player:Subscribe("Possess", function(player, character)
		UpdateLocalCharacter(character)
	end)

	local_player:Subscribe("UnPossess", function(player, character)
		-- Unsubscribe from all old Character events
		character:Unsubscribe("HealthChange", OnCharacterHealthChange)
		character:Unsubscribe("PickUp", OnCharacterPickup)
		character:Unsubscribe("Drop", OnCharacterDrop)
	end)
end

-- Handles Character picking up an object (weapon, melee)
function OnCharacterPickup(character, object)
	if (object:IsA(Weapon) and not object:IsA(ToolGun)) then
		-- Immediately Updates the Ammo UI
		UpdateAmmo(true, object:GetAmmoClip(), object:GetAmmoBag())

		-- Trigger Weapon Hints
		AddNotification("AIM_DOWN_SIGHT", "you can use mouse wheel to aim down sight with your Weapon when you are in First Person Mode", 10000, 3000)
		AddNotification("HEADSHOTS", "headshots can cause more damage", 10000, 15000)

		-- Subscribes on the weapon when the Ammo changes
		object:Subscribe("AmmoClipChange", OnAmmoClipChanged)
		object:Subscribe("AmmoBagChange", OnAmmoBagChanged)
	end
end

-- Handles Character taking damage (health change)
function OnCharacterHealthChange(character, old_health, new_health)
	-- Plays a Hit Taken sound effect if took damage
	if (new_health < old_health) then
		SoundHitTakenFeedback:Play()
	end

	-- Immediately Updates the Health UI
	UpdateHealth(new_health)
end

-- Handles Character Dropping an object (weapon, melee)
function OnCharacterDrop(character, object)
	-- Unsubscribes from events
	if (object:IsA(Weapon) and not object:IsA(ToolGun)) then
		UpdateAmmo(false)
		object:Unsubscribe("AmmoClipChange", OnAmmoClipChanged)
		object:Unsubscribe("AmmoBagChange", OnAmmoBagChanged)
	end
end

-- Function to update the Ammo's UI
function UpdateAmmo(enable_ui, ammo, ammo_bag)
	MainHUD:CallEvent("UpdateWeaponAmmo", enable_ui, ammo, ammo_bag)
end

-- Function to update the Health's UI
function UpdateHealth(health)
	MainHUD:CallEvent("UpdateHealth", health)
end

-- Callback when Weapon Ammo Clip changes
function OnAmmoClipChanged(weapon, old_ammo_clip, new_ammo_clip)
	UpdateAmmo(true, new_ammo_clip, weapon:GetAmmoBag())
end

-- Callback when Weapon Ammo Bag changes
function OnAmmoBagChanged(weapon, old_ammo_bag, new_ammo_bag)
	UpdateAmmo(true, weapon:GetAmmoClip(), new_ammo_bag)
end

Input.Bind("NoClip", InputEvent.Pressed, function()
	Events.CallRemote("ToggleNoClip")
end)

Input.Bind("Ragdoll", InputEvent.Pressed, function()
	Events.CallRemote("EnterRagdoll")
end)

-- VOIP UI
Player.Subscribe("VOIP", function(player, is_talking)
	MainHUD:CallEvent("ToggleVoice", player:GetID(), is_talking, player:GetName(), player:GetAccountIconURL())

	-- Apply speaking animation
	local character = player:GetControlledCharacter()
	if (character) then
		local character_mesh = character:GetMesh()
		local character_mesh_data = CHARACTER_MESHES[character_mesh]
		if (character_mesh_data and character_mesh_data.speak_animation) then
			if (is_talking and character:GetLocation():IsNear(Client.GetLocalPlayer():GetCameraLocation(), 1000)) then
				character:PlayAnimation(character_mesh_data.speak_animation, AnimationSlotType.Head, true)
			else
				character:StopAnimation(character_mesh_data.speak_animation)
			end
		end
	end
end)

Player.Subscribe("Destroy", function(player)
	MainHUD:CallEvent("ToggleVoice", player:GetID(), false)
	MainHUD:CallEvent("UpdatePlayer", player:GetID(), false)
end)

Events.SubscribeRemote("SpawnSound", function(location, sound_asset, is_2D, volume, pitch)
	Sound(location, sound_asset, is_2D, true, SoundType.SFX, volume or 1, pitch or 1)
end)

Events.SubscribeRemote("SpawnSoundAttached", function(object, sound_asset, is_2D, auto_destroy, volume, pitch)
	local sound = Sound(object:GetLocation(), sound_asset, is_2D, auto_destroy ~= false, SoundType.SFX, volume or 1, pitch or 1)
	sound:AttachTo(object, AttachmentRule.SnapToTarget, "", 0)
end)

Input.Subscribe("KeyPress", function(key_name, delta)
	if (key_name == "Escape") then
		if (ContextMenu.is_opened) then
			ContextMenu.Close()
			return false
		end
	end
end)

-- Exposes this to other packages
Package.Export("UpdateLocalCharacter", UpdateLocalCharacter)
