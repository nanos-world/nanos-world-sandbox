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

		if (not SpawnMenuItems[asset_pack.Path].tools) then
			SpawnMenuItems[asset_pack.Path].npcs = {}
		end

		-- Loads all StaticMeshes as Props
		local props = Assets:GetStaticMeshes(asset_pack.Path)
		for i, prop in pairs(props) do
			table.insert(SpawnMenuItems[asset_pack.Path].props, {
				id = prop,
				name = prop,
				image = "assets///" .. asset_pack.Path .. "/Thumbnails/" .. prop .. ".jpg"
			})
		end

		main_hud:CallEvent("AddAssetPack", {asset_pack.Path, JSON.stringify(SpawnMenuItems[asset_pack.Path])})
	end
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
		AddNotification("NO_ITEM_TO_DELETE", "there is no items in your History to delete!", 3000, true)
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

	table.insert(SpawnMenuItems[asset_pack][category], {
		id = id,
		name = name,
		image = image
	})
end

-- Exposes this to other packages
Package:Export("AddSpawnMenuItem", AddSpawnMenuItem)

-- Requires all Tools
Package:Require("Tools/Balloon.lua")
Package:Require("Tools/Color.lua")
Package:Require("Tools/Lamp.lua")
Package:Require("Tools/Light.lua")
Package:Require("Tools/PhysicsGun.lua")
Package:Require("Tools/Remover.lua")
Package:Require("Tools/Resizer.lua")
Package:Require("Tools/Rope.lua")
Package:Require("Tools/Thruster.lua")
Package:Require("Tools/Trail.lua")
Package:Require("Tools/Weld.lua")

-- Adds the default NanosWorld items
-- Default Weapons
AddSpawnMenuItem("NanosWorld", "weapons", "AK47", "AK47", "assets///NanosWorld/Thumbnails/SK_AK47.jpg")
AddSpawnMenuItem("NanosWorld", "weapons", "AK74U", "AK74U", "assets///NanosWorld/Thumbnails/SK_AK74U.jpg")
AddSpawnMenuItem("NanosWorld", "weapons", "AP5", "AP5", "assets///NanosWorld/Thumbnails/SK_AP5.jpg")
AddSpawnMenuItem("NanosWorld", "weapons", "AR4", "AR4", "assets///NanosWorld/Thumbnails/SK_AR4.jpg")
AddSpawnMenuItem("NanosWorld", "weapons", "ASVal", "ASVal", "assets///NanosWorld/Thumbnails/SK_ASVal.jpg")
AddSpawnMenuItem("NanosWorld", "weapons", "DesertEagle", "DesertEagle", "assets///NanosWorld/Thumbnails/SK_DesertEagle.jpg")
AddSpawnMenuItem("NanosWorld", "weapons", "GE36", "GE36", "assets///NanosWorld/Thumbnails/SK_GE36.jpg")
AddSpawnMenuItem("NanosWorld", "weapons", "Glock", "Glock", "assets///NanosWorld/Thumbnails/SK_Glock.jpg")
AddSpawnMenuItem("NanosWorld", "weapons", "Moss500", "Moss500", "assets///NanosWorld/Thumbnails/SK_Moss500.jpg")
AddSpawnMenuItem("NanosWorld", "weapons", "SMG11", "SMG11", "assets///NanosWorld/Thumbnails/SK_SMG11.jpg")
AddSpawnMenuItem("NanosWorld", "weapons", "Grenade", "Grenade", "assets///NanosWorld/Thumbnails/SK_G67.jpg")

AddSpawnMenuItem("NanosWorld", "weapons", "HFG", "HFG", "assets///NanosWorld/Thumbnails/SK_PortalGun.jpg")

-- Default Vehicles
AddSpawnMenuItem("NanosWorld", "vehicles", "SUV", "SUV", "assets///NanosWorld/Thumbnails/SK_SUV.jpg")
AddSpawnMenuItem("NanosWorld", "vehicles", "Hatchback", "Hatchback", "assets///NanosWorld/Thumbnails/SK_Hatchback.jpg")
AddSpawnMenuItem("NanosWorld", "vehicles", "SportsCar", "SportsCar", "assets///NanosWorld/Thumbnails/SK_SportsCar.jpg")
AddSpawnMenuItem("NanosWorld", "vehicles", "TruckBox", "TruckBox", "assets///NanosWorld/Thumbnails/SK_Truck_Box.jpg")
AddSpawnMenuItem("NanosWorld", "vehicles", "TruckChassis", "TruckChassis", "assets///NanosWorld/Thumbnails/SK_Truck_Chassis.jpg")
AddSpawnMenuItem("NanosWorld", "vehicles", "Pickup", "Pickup", "assets///NanosWorld/Thumbnails/SK_Pickup.jpg")

-- Default NPCs
AddSpawnMenuItem("NanosWorld", "npcs", "NanosWorld::SK_Mannequin", "Mannequin", "assets///NanosWorld/Thumbnails/SK_Mannequin.jpg")
AddSpawnMenuItem("NanosWorld", "npcs", "NanosWorld::SK_Mannequin_Female", "Mannequin Female", "assets///NanosWorld/Thumbnails/SK_Mannequin_Female.jpg")
AddSpawnMenuItem("NanosWorld", "npcs", "NanosWorld::SK_Male", "Man", "assets///NanosWorld/Thumbnails/SK_Male.jpg")
AddSpawnMenuItem("NanosWorld", "npcs", "NanosWorld::SK_Female", "Woman", "assets///NanosWorld/Thumbnails/SK_Female.jpg")
AddSpawnMenuItem("NanosWorld", "npcs", "NanosWorld::SK_PostApocalyptic", "Post Apocalyptic", "assets///NanosWorld/Thumbnails/SK_PostApocalyptic.jpg")
AddSpawnMenuItem("NanosWorld", "npcs", "NanosWorld::SK_ClassicMale", "Classic Male", "assets///NanosWorld/Thumbnails/SK_ClassicMale.jpg")

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("NanosWorld", "tools", "Torch", "Torch", "assets///NanosWorld/Thumbnails/SM_Torch.jpg")

-- Defines some Spawn Menu Hints
SetNotification("SPAWN_MENU", 30000, "you can press Q to open the Spawn Menu", 7000)
SetNotification("SPAWN_MENU_DESTROY_ITEM", 90000, "you can press X to delete your last spawned item", 5000)