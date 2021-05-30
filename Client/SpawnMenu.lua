-- Stores all spawned Items by this client
SpawnsHistory = setmetatable({}, { __mode = 'k' })

-- List of all Assets
SpawnMenuItems = {}

-- Configures the Highlight colors to be used
Client:SetHighlightColor(Color(0, 0, 20, 0.25), 1) -- Index 1
Client:SetHighlightColor(Color(0, 20, 0, 1.20), 0) -- Index 2

-- When Sandbox UI is ready
main_hud:Subscribe("Ready", function()
	local asset_packs = Assets:GetAssetPacks()

	-- Loads all AssetPacks
	for i, asset_pack in pairs(asset_packs) do
		if (not SpawnMenuItems[asset_pack.Path]) then
			SpawnMenuItems[asset_pack.Path] = {}
		end

		if (not SpawnMenuItems[asset_pack.Path].props) then
			SpawnMenuItems[asset_pack.Path].props = {}
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

		-- Loads all StaticMeshes as Props
		local props = Assets:GetStaticMeshes(asset_pack.Path)
		for i, prop in pairs(props) do
			SpawnMenuItems[asset_pack.Path].props[prop] = {
				name = prop,
				image = "assets/" .. asset_pack.Path .. "/" .. prop .. ".jpg"
			}
		end

		main_hud:CallEvent("AddAssetPack", {asset_pack.Path, JSON.stringify(SpawnMenuItems[asset_pack.Path])})
	end

	main_hud:CallEvent("ToggleSpawnMenuVisibility", {false})
end)

-- Toggle the Spawn Menu on
Client:Subscribe("KeyUp", function(key)
	if (key == "Q") then
		main_hud:CallEvent("ToggleSpawnMenuVisibility", {false})
		Client:SetMouseEnabled(false)
		Client:SetChatVisibility(true)
		return
	end
end)

-- Toggle the Spawn Menu off
Client:Subscribe("KeyPress", function(key)
	-- Opens SpawnMenu
	if (key == "Q") then
		main_hud:CallEvent("ToggleSpawnMenuVisibility", {true})
		Client:SetMouseEnabled(true)
		Client:SetChatVisibility(false)
		main_hud:BringToFront()
		main_hud:SetFocus()
		return
	end
end)

Client:Subscribe("KeyDown", function(key)
	-- Destroy the last spawned item from history
	if (key == "X") then
		DeleteItemFromHistory()
		return
	end
end)

-- Function to delete the last item spawned
function DeleteItemFromHistory()
	if (#SpawnsHistory == 0) then
		AddNotification("NO_ITEM_TO_DELETE", "There is no items in your History to delete!", 3000, true)
		return
	end

	local data = table.remove(SpawnsHistory)

	-- If there is a item to destroy, otherwise tries the next from the list, recursively
	if (data.item and data.item:IsValid()) then
		Events:CallRemote("DestroyItem", {data.item})
		Sound(Vector(), "NanosWorld::A_Player_Eject", true, true, SoundType.SFX, 0.1)
	else
		DeleteItemFromHistory()
	end
end

-- Sound when hovering an Item in the SpawnMenu
main_hud:Subscribe("HoverSound", function()
	Sound(Vector(), "NanosWorld::A_VR_Click_01", true, true, SoundType.SFX, 0.04)
end)

-- Handle for selecting an Item from the SpawnMenu
main_hud:Subscribe("SpawnItem", function(asset_pack, category, asset_id)
	-- Gets the world spawn location to spawn the Item
	local viewport_2D_center = Render:GetViewportSize() / 2
	local viewport_3D = Render:Deproject(viewport_2D_center)
	local trace_max_distance = 5000

	local start_location = viewport_3D.Position
	local end_location = viewport_3D.Position + viewport_3D.Direction * trace_max_distance

	-- Traces for world things
    local trace_result = Client:Trace(start_location, end_location, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic)

	local spawn_location = end_location

	-- Gets the rotation looking at the player, only rotated by Yaw
	local spawn_rotation = Rotator(0, viewport_3D.Direction:Rotation().Yaw, 0)

	if (trace_result.Success) then
		spawn_location = trace_result.Location - viewport_3D.Direction * 100
	end

	-- Calls server to spawn it
	Events:CallRemote("SpawnItem", { asset_pack, category, asset_id, spawn_location, spawn_rotation })

	-- Spawns a sound for 'spawning an item'
	Sound(Vector(), "NanosWorld::A_VR_Teleport", true, true, SoundType.SFX, 0.15)
end)

-- Subscribes for when I spawn an Item, do add it to my history
Events:Subscribe("SpawnedItem", function(item, weld)
	table.insert(SpawnsHistory, { ["item"] = item, ["weld"] = weld} )
end)

-- Auxiliar for Tracing for world object
function TraceFor(trace_max_distance, collision_channel)
	local viewport_2D_center = Render:GetViewportSize() / 2
	local viewport_3D = Render:Deproject(viewport_2D_center)

	local start_location = viewport_3D.Position + viewport_3D.Direction * 100
	local end_location = viewport_3D.Position + viewport_3D.Direction * trace_max_distance

	return Client:Trace(start_location, end_location, collision_channel, true, true)
end

-- Function for Adding new Spawn Menu items
function AddSpawnMenuItem(asset_pack, category, id, name, image)
	if (not SpawnMenuItems[asset_pack]) then
		SpawnMenuItems[asset_pack] = {}
	end

	if (not SpawnMenuItems[asset_pack][category]) then
		SpawnMenuItems[asset_pack][category] = {}
	end

	SpawnMenuItems[asset_pack][category][id] = {
		name = name,
		image = image
	}
end

-- Exposes this to other packages
Package:Export("AddSpawnMenuItem", AddSpawnMenuItem)

-- Requires all Tools
Package:Require("Tools/Balloon.lua")
Package:Require("Tools/Color.lua")
Package:Require("Tools/Light.lua")
Package:Require("Tools/PhysicsGun.lua")
Package:Require("Tools/Remover.lua")
Package:Require("Tools/Resizer.lua")
Package:Require("Tools/Rope.lua")
Package:Require("Tools/Thruster.lua")
Package:Require("Tools/Weld.lua")

-- Adds the default NanosWorld items
-- Default Weapons
AddSpawnMenuItem("NanosWorld", "weapons", "AK47", "AK47", "assets/NanosWorld/SK_AK47.jpg")
AddSpawnMenuItem("NanosWorld", "weapons", "AK74U", "AK74U", "assets/NanosWorld/SK_AK74U.jpg")
AddSpawnMenuItem("NanosWorld", "weapons", "AP5", "AP5", "assets/NanosWorld/SK_AP5.jpg")
AddSpawnMenuItem("NanosWorld", "weapons", "AR4", "AR4", "assets/NanosWorld/SK_AR4.jpg")
AddSpawnMenuItem("NanosWorld", "weapons", "GE36", "GE36", "assets/NanosWorld/SK_GE36.jpg")
AddSpawnMenuItem("NanosWorld", "weapons", "Glock", "Glock", "assets/NanosWorld/SK_Glock.jpg")
AddSpawnMenuItem("NanosWorld", "weapons", "DesertEagle", "DesertEagle", "assets/NanosWorld/SK_DesertEagle.jpg")
AddSpawnMenuItem("NanosWorld", "weapons", "Moss500", "Moss500", "assets/NanosWorld/SK_Moss500.jpg")
AddSpawnMenuItem("NanosWorld", "weapons", "SMG11", "SMG11", "assets/NanosWorld/SK_SMG11.jpg")
AddSpawnMenuItem("NanosWorld", "weapons", "ASVal", "ASVal", "assets/NanosWorld/SK_ASVal.jpg")

-- Default Vehicles
AddSpawnMenuItem("NanosWorld", "vehicles", "SUV", "SUV", "assets/NanosWorld/SK_SUV.jpg")
AddSpawnMenuItem("NanosWorld", "vehicles", "Hatchback", "Hatchback", "assets/NanosWorld/SK_Hatchback.jpg")
AddSpawnMenuItem("NanosWorld", "vehicles", "SportsCar", "SportsCar", "assets/NanosWorld/SK_SportsCar.jpg")
AddSpawnMenuItem("NanosWorld", "vehicles", "TruckBox", "TruckBox", "assets/NanosWorld/SK_Truck_Box.jpg")
AddSpawnMenuItem("NanosWorld", "vehicles", "TruckChassis", "TruckChassis", "assets/NanosWorld/SK_Truck_Chassis.jpg")
AddSpawnMenuItem("NanosWorld", "vehicles", "Pickup", "Pickup", "assets/NanosWorld/SK_Pickup.jpg")

-- Defines some Spawn Menu Hints
SetNotification("SPAWN_MENU", 30000, "you can press Q to open the Spawn Menu", 7000)
SetNotification("SPAWN_MENU_DESTROY_ITEM", 90000, "you can press X to delete your last spawned item", 5000)