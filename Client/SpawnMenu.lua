-- Loads the Default Asset Pack list (categorized)
Package.Require("DefaultAssets.lua")

-- Stores all spawned Items by this client
SpawnsHistory = setmetatable({}, { __mode = 'k' })

-- List of all Assets
SpawnMenuItems = {}

-- WORKAROUND used for weapons Patterns
SelectedOption = ""

-- Configures the Highlight colors to be used
Client.SetHighlightColor(Color(0, 20, 0, 1.20), 0, HighlightMode.Always) -- Index 0

Package.Subscribe("Load", function()
	-- Wait 1 second so all other packages can send their Tools
	Timer.SetTimeout(function()
		local asset_packs = Assets.GetAssetPacks()

		-- Loads all AssetPacks
		for _, asset_pack in pairs(asset_packs) do
			if (not SpawnMenuItems[asset_pack.Path]) then
				SpawnMenuItems[asset_pack.Path] = {}
			end

			if (not SpawnMenuItems[asset_pack.Path].props) then
				SpawnMenuItems[asset_pack.Path].props = {}
			end

			if (not SpawnMenuItems[asset_pack.Path].entities) then
				SpawnMenuItems[asset_pack.Path].entities = {}
			end

			if (not SpawnMenuItems[asset_pack.Path].weapons) then
				SpawnMenuItems[asset_pack.Path].weapons = {}
			end

			if (not SpawnMenuItems[asset_pack.Path].vehicles) then
				SpawnMenuItems[asset_pack.Path].vehicles = {}
			end

			if (not SpawnMenuItems[asset_pack.Path].tools) then
				SpawnMenuItems[asset_pack.Path].tools = {}
			end

			if (not SpawnMenuItems[asset_pack.Path].npcs) then
				SpawnMenuItems[asset_pack.Path].npcs = {}
			end

			-- Loads all StaticMeshes as Props
			local props = Assets.GetStaticMeshes(asset_pack.Path)
			for _, prop in pairs(props) do
				-- TODO make global way to access categories for other Asset Packs
				local asset_category = DEFAULT_ASSET_PACK[prop]
				table.insert(SpawnMenuItems[asset_pack.Path].props, {
					id = prop,
					name = prop:gsub("SM_", " "):gsub("_", " "),
					image = "assets///" .. asset_pack.Path .. "/Thumbnails/" .. prop .. ".jpg",
					sub_category = asset_category or "uncategorized"
				})
			end
		end

		-- Iterate each Asset Pack to add to Spawn Menu
		for asset_pack, asset_pack_data in pairs(SpawnMenuItems) do
			main_hud:CallEvent("AddAssetPack", asset_pack, JSON.stringify(asset_pack_data))
		end
	end, 1000)
end)

Input.Bind("SpawnMenu", InputEvent.Released, function()
	main_hud:CallEvent("ToggleSpawnMenuVisibility", false)
	Client.SetMouseEnabled(false)
	Client.SetChatVisibility(true)
end)

Input.Bind("SpawnMenu", InputEvent.Pressed, function()
	main_hud:CallEvent("ToggleSpawnMenuVisibility", true)
	Client.SetMouseEnabled(true)
	Client.SetChatVisibility(false)
	main_hud:BringToFront()
end)

-- Function to delete the last item spawned
function DeleteItemFromHistory()
	if (#SpawnsHistory == 0) then
		AddNotification("NO_ITEM_TO_DELETE", "there are no items in your History to destroy!", 3000, true)
		return
	end

	local data = table.remove(SpawnsHistory)

	-- If there is a item to destroy, otherwise tries the next from the list, recursively
	if (data.item and data.item:IsValid()) then
		Events.CallRemote("DestroyItem", data.item)
		Sound(Vector(), "nanos-world::A_Player_Eject", true, true, SoundType.SFX, 0.1)
	else
		DeleteItemFromHistory()
	end
end

UndoDelay = 0

function UndoTick(delta_time)
	-- Don't spam the user with empty history messages
	if (#SpawnsHistory == 0) then
		Client.Unsubscribe("Tick", UndoTick)
	end

	UndoDelay = UndoDelay - delta_time

	if UndoDelay <= 0 then
		DeleteItemFromHistory()
		UndoDelay = 0.2
	end
end

Input.Bind("Undo", InputEvent.Pressed, function()
	-- Destroys the first Item
	DeleteItemFromHistory()

	-- Waits 1 seconds then keeps destroying
	UndoDelay = 1
	Client.Subscribe("Tick", UndoTick)
end)

Input.Bind("Undo", InputEvent.Released, function()
	Client.Unsubscribe("Tick", UndoTick)
end)

-- Sound when hovering an Item in the SpawnMenu
main_hud:Subscribe("HoverSound", function(pitch)
	Sound(Vector(), "nanos-world::A_VR_Click_01", true, true, SoundType.SFX, 0.02, pitch or 1)
end)

main_hud:Subscribe("ClickSound", function(pitch)
	Sound(Vector(), "nanos-world::A_VR_Click_02", true, true, SoundType.SFX, 0.01, pitch or 0.7)
end)

-- Handle for selecting an Item from the SpawnMenu
main_hud:Subscribe("SpawnItem", function(asset_pack, category, asset_id)
	-- Gets the world spawn location to spawn the Item
	local viewport_2D_center = Render.GetViewportSize() / 2
	local viewport_3D = Render.Deproject(viewport_2D_center)
	local trace_max_distance = 5000

	local start_location = viewport_3D.Position
	local end_location = viewport_3D.Position + viewport_3D.Direction * trace_max_distance

	-- Traces for world things
    local trace_result = Client.Trace(start_location, end_location, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic)

	local spawn_location = end_location

	-- Gets the rotation looking at the player, only rotated by Yaw
	local spawn_rotation = Rotator(0, viewport_3D.Direction:Rotation().Yaw, 0)

	if (trace_result.Success) then
		spawn_location = trace_result.Location - viewport_3D.Direction * 100
	end

	-- Triggers client side
	if (not Events.Call("SpawnItem_" .. asset_id, asset_pack, category, asset_id, spawn_location, spawn_rotation)) then
		return
	end

	-- Calls server to spawn it
	Events.CallRemote("SpawnItem", asset_pack, category, asset_id, spawn_location, spawn_rotation, SelectedOption)

	-- Spawns a sound for 'spawning an item'
	Sound(Vector(), "nanos-world::A_VR_Teleport", true, true, SoundType.SFX, 0.15)
end)

-- Subscribes for when I select an Option
main_hud:Subscribe("SelectOption", function(texture_path)
	SelectedOption = texture_path

	local local_character = Client.GetLocalPlayer():GetControlledCharacter()

	if (local_character) then
		local current_picked_item = local_character:GetPicked()
		if (current_picked_item) then
			Events.CallRemote("ApplyWeaponPattern", current_picked_item, texture_path)
		end
	end
end)

-- Subscribes for when I spawn an Item, do add it to my history
Events.Subscribe("SpawnedItem", function(item, weld)
	table.insert(SpawnsHistory, { ["item"] = item, ["weld"] = weld })
end)

-- Auxiliar for Tracing for world object
function TraceFor(trace_max_distance, collision_channel)
	local viewport_2D_center = Render.GetViewportSize() / 2
	local viewport_3D = Render.Deproject(viewport_2D_center)

	local start_location = viewport_3D.Position + viewport_3D.Direction * 100
	local end_location = viewport_3D.Position + viewport_3D.Direction * trace_max_distance

	return Client.Trace(start_location, end_location, collision_channel, true, true)
end

-- Function for Adding new Spawn Menu items
function AddSpawnMenuItem(asset_pack, tab, id, name, image, category)
	if (not SpawnMenuItems[asset_pack]) then
		SpawnMenuItems[asset_pack] = {}
	end

	if (not SpawnMenuItems[asset_pack][tab]) then
		SpawnMenuItems[asset_pack][tab] = {}
	end

	table.insert(SpawnMenuItems[asset_pack][tab], {
		id = id,
		name = name,
		image = image,
		sub_category = category
	})
end

-- Exposes this to other packages
Package.Export("AddSpawnMenuItem", AddSpawnMenuItem)

-- Requires all Tools
Package.Require("Tools/Balloon.lua")
Package.Require("Tools/Color.lua")
Package.Require("Tools/Lamp.lua")
Package.Require("Tools/Light.lua")
Package.Require("Tools/PhysicsGun.lua")
Package.Require("Tools/Remover.lua")
Package.Require("Tools/Resizer.lua")
Package.Require("Tools/Rope.lua")
Package.Require("Tools/Thruster.lua")
Package.Require("Tools/Trail.lua")
Package.Require("Tools/Weld.lua")

-- Adds the default NanosWorld items
-- Default Weapons
AddSpawnMenuItem("nanos-world", "weapons", "AK47", "AK-47", "assets///NanosWorld/Thumbnails/SK_AK47.jpg", "rifles")
AddSpawnMenuItem("nanos-world", "weapons", "AK74U", "AK-74U", "assets///NanosWorld/Thumbnails/SK_AK74U.jpg", "rifles")
AddSpawnMenuItem("nanos-world", "weapons", "AK5C", "Automatkarbin 5C", "assets///NanosWorld/Thumbnails/SK_AK5C.jpg", "rifles")
AddSpawnMenuItem("nanos-world", "weapons", "AR4", "AR-15", "assets///NanosWorld/Thumbnails/SK_AR4.jpg", "rifles")
AddSpawnMenuItem("nanos-world", "weapons", "ASVal", "AS-Val", "assets///NanosWorld/Thumbnails/SK_ASVal.jpg", "rifles")
AddSpawnMenuItem("nanos-world", "weapons", "GE3", "Gewehr 3", "assets///NanosWorld/Thumbnails/SK_GE3.jpg", "rifles")
AddSpawnMenuItem("nanos-world", "weapons", "GE36", "Gewehr 36", "assets///NanosWorld/Thumbnails/SK_GE36.jpg", "rifles")
AddSpawnMenuItem("nanos-world", "weapons", "SA80", "SA-80", "assets///NanosWorld/Thumbnails/SK_SA80.jpg", "rifles")

AddSpawnMenuItem("nanos-world", "weapons", "AP5", "MP5", "assets///NanosWorld/Thumbnails/SK_AP5.jpg", "smgs")
AddSpawnMenuItem("nanos-world", "weapons", "P90", "P90", "assets///NanosWorld/Thumbnails/SK_P90.jpg", "smgs")
AddSpawnMenuItem("nanos-world", "weapons", "SMG11", "MAC-10", "assets///NanosWorld/Thumbnails/SK_SMG11.jpg", "smgs")
AddSpawnMenuItem("nanos-world", "weapons", "UMP45", "UMP-45", "assets///NanosWorld/Thumbnails/SK_UMP45.jpg", "smgs")

AddSpawnMenuItem("nanos-world", "weapons", "DesertEagle", "Desert Eagle", "assets///NanosWorld/Thumbnails/SK_DesertEagle.jpg", "pistols")
AddSpawnMenuItem("nanos-world", "weapons", "Glock", "Glock", "assets///NanosWorld/Thumbnails/SK_Glock.jpg", "pistols")
AddSpawnMenuItem("nanos-world", "weapons", "Makarov", "Makarov", "assets///NanosWorld/Thumbnails/SK_Makarov.jpg", "pistols")
AddSpawnMenuItem("nanos-world", "weapons", "M1911", "M1911", "assets///NanosWorld/Thumbnails/SK_M1911.jpg", "pistols")

AddSpawnMenuItem("nanos-world", "weapons", "Ithaca37", "Ithaca 37", "assets///NanosWorld/Thumbnails/SK_Ithaca37.jpg", "shotguns")
AddSpawnMenuItem("nanos-world", "weapons", "Moss500", "Moss 500", "assets///NanosWorld/Thumbnails/SK_Moss500.jpg", "shotguns")
AddSpawnMenuItem("nanos-world", "weapons", "Rem870", "Rem 870", "assets///NanosWorld/Thumbnails/SK_Rem870.jpg", "shotguns")
AddSpawnMenuItem("nanos-world", "weapons", "SPAS12", "SPAS12", "assets///NanosWorld/Thumbnails/SK_SPAS12.jpg", "shotguns")

AddSpawnMenuItem("nanos-world", "weapons", "Grenade", "Grenade", "assets///NanosWorld/Thumbnails/SM_Grenade_G67.jpg", "grenades")

AddSpawnMenuItem("nanos-world", "weapons", "AWP", "AWP", "assets///NanosWorld/Thumbnails/SK_AWP.jpg", "sniper-rifles")

AddSpawnMenuItem("nanos-world", "weapons", "HFG", "HFG", "assets///NanosWorld/Thumbnails/SK_FlareGun.jpg", "special")
AddSpawnMenuItem("nanos-world", "weapons", "VeggieGun", "Veggie Gun", "assets///NanosWorld/Thumbnails/SK_FlareGun.jpg", "special")

-- Default Vehicles
AddSpawnMenuItem("nanos-world", "vehicles", "SUV", "SUV", "assets///NanosWorld/Thumbnails/SK_SUV.jpg")
AddSpawnMenuItem("nanos-world", "vehicles", "Hatchback", "Hatchback", "assets///NanosWorld/Thumbnails/SK_Hatchback.jpg")
AddSpawnMenuItem("nanos-world", "vehicles", "SportsCar", "SportsCar", "assets///NanosWorld/Thumbnails/SK_SportsCar.jpg")
AddSpawnMenuItem("nanos-world", "vehicles", "TruckBox", "TruckBox", "assets///NanosWorld/Thumbnails/SK_Truck_Box.jpg")
AddSpawnMenuItem("nanos-world", "vehicles", "TruckChassis", "TruckChassis", "assets///NanosWorld/Thumbnails/SK_Truck_Chassis.jpg")
AddSpawnMenuItem("nanos-world", "vehicles", "Pickup", "Pickup", "assets///NanosWorld/Thumbnails/SK_Pickup.jpg")

-- Default NPCs
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_Mannequin", "Mannequin", "assets///NanosWorld/Thumbnails/SK_Mannequin.jpg")
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_Mannequin_Female", "Mannequin Female", "assets///NanosWorld/Thumbnails/SK_Mannequin_Female.jpg")
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_Male", "Man", "assets///NanosWorld/Thumbnails/SK_Male.jpg")
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_Female", "Woman", "assets///NanosWorld/Thumbnails/SK_Female.jpg")
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_PostApocalyptic", "Post Apocalyptic", "assets///NanosWorld/Thumbnails/SK_PostApocalyptic.jpg")
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_ClassicMale", "Classic Male", "assets///NanosWorld/Thumbnails/SK_ClassicMale.jpg")

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "tools", "Torch", "Torch", "assets///NanosWorld/Thumbnails/SM_Torch.jpg")

-- Defines some Spawn Menu Hints
SetNotification("SPAWN_MENU", 30000, "you can press Q to open the Spawn Menu", 10000)
SetNotification("SPAWN_MENU_DESTROY_ITEM", 90000, "you can press X to delete your last spawned item", 10000)