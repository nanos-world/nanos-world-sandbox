-- Loads the Default Asset Pack list (categorized)
Package.Require("DefaultAssets.lua")

-- Stores all spawned Items by this client
SpawnsHistory = SpawnsHistory or setmetatable({}, { __mode = 'k' })

-- List of all Assets
SpawnMenuItems = SpawnMenuItems or {}

-- List of all Tool Guns Data
ToolGunsTutorials = ToolGunsTutorials or {}

-- WORKAROUND used for weapons Patterns
SelectedOption = SelectedOption or ""

SpawnMenuOpened = SpawnMenuOpened or false

-- Configures the Highlight colors to be used
Client.SetHighlightColor(Color(0, 20, 0, 1.20), 0, HighlightMode.Always) -- Index 0
Client.SetOutlineColor(Color(0, 0, 300), 2) -- Index 2

Package.Subscribe("Load", function()
	-- Wait 1 second so all other packages can send their Tools during Package Load event
	Timer.SetTimeout(function()
		local asset_packs = Assets.GetAssetPacks()

		-- Loads all Asset Packs
		for _, asset_pack in pairs(asset_packs) do
			if (not SpawnMenuItems[asset_pack.Path]) then SpawnMenuItems[asset_pack.Path] = {} end
			if (not SpawnMenuItems[asset_pack.Path].props) then SpawnMenuItems[asset_pack.Path].props = {} end
			if (not SpawnMenuItems[asset_pack.Path].entities) then SpawnMenuItems[asset_pack.Path].entities = {} end
			if (not SpawnMenuItems[asset_pack.Path].weapons) then SpawnMenuItems[asset_pack.Path].weapons = {} end
			if (not SpawnMenuItems[asset_pack.Path].vehicles) then SpawnMenuItems[asset_pack.Path].vehicles = {} end
			if (not SpawnMenuItems[asset_pack.Path].tools) then SpawnMenuItems[asset_pack.Path].tools = {} end
			if (not SpawnMenuItems[asset_pack.Path].npcs) then SpawnMenuItems[asset_pack.Path].npcs = {} end

			-- Loads all StaticMeshes as Props
			local props = Assets.GetStaticMeshes(asset_pack.Path)

			for _, prop in pairs(props) do
				-- TODO make global way to access categories for other Asset Packs
				-- Get the category from a default list
				local asset_category = DEFAULT_ASSET_PACK[prop]

				table.insert(SpawnMenuItems[asset_pack.Path].props, {
					id = prop,
					name = prop:gsub("SM_", " "):gsub("_", " "), -- Parses it to remove dirty names
					image = "assets///" .. asset_pack.Path .. "/Thumbnails/" .. prop .. ".jpg", -- Gets the Thumbnail path from conventional path "my_asset_pack/Thumbnails/"
					sub_category = asset_category or "uncategorized"
				})
			end
		end

		-- Iterate each group to add to Spawn Menu, this will add all items to it
		-- If an item is added after this it will not be added to spawn menu
		for group, spawn_menu_group_data in pairs(SpawnMenuItems) do
			MainHUD:CallEvent("AddSpawnMenuGroup", group, JSON.stringify(spawn_menu_group_data))
		end
	end, 1000)
end)

Input.Bind("SpawnMenu", InputEvent.Released, function()
	if (ContextMenuOpened) then return end

	MainHUD:CallEvent("ToggleSpawnMenuVisibility", false)
	SpawnMenuOpened = false
	Client.SetMouseEnabled(false)
	Client.SetChatVisibility(true)
end)

Input.Bind("SpawnMenu", InputEvent.Pressed, function()
	if (ContextMenuOpened) then return end

	MainHUD:CallEvent("ToggleSpawnMenuVisibility", true)
	SpawnMenuOpened = true
	Client.SetMouseEnabled(true)
	Client.SetChatVisibility(false)
	MainHUD:BringToFront()
end)

-- Function to delete the last item spawned
function DeleteItemFromHistory()
	if (#SpawnsHistory == 0) then
		AddNotification("NO_ITEM_TO_DELETE", "there are no items in your History to destroy!", 3000, 0, true)
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
		UndoDelay = 0.1
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
MainHUD:Subscribe("HoverSound", function(pitch)
	Sound(Vector(), "nanos-world::A_VR_Click_01", true, true, SoundType.SFX, 0.02, pitch or 1)
end)

MainHUD:Subscribe("ClickSound", function(pitch)
	Sound(Vector(), "nanos-world::A_VR_Click_02", true, true, SoundType.SFX, 0.01, pitch or 0.7)
end)

-- Handle for selecting an Item from the SpawnMenu
MainHUD:Subscribe("SpawnItem", function(group, category, asset_id)
	-- Gets the world spawn location to spawn the Item
	local viewport_2D_center = Client.GetViewportSize() / 2
	local viewport_3D = Client.DeprojectScreenToWorld(viewport_2D_center)
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
	if (not Events.Call("SpawnItem_" .. asset_id, group, category, asset_id, spawn_location, spawn_rotation)) then
		return
	end

	-- Calls server to spawn it
	Events.CallRemote("SpawnItem", group, category, asset_id, spawn_location, spawn_rotation, SelectedOption)

	-- Spawns a sound for 'spawning an item'
	Sound(Vector(), "nanos-world::A_VR_Teleport", true, true, SoundType.SFX, 0.15, 1.1)
end)

-- Subscribes for when I select an Option
MainHUD:Subscribe("SelectOption", function(texture_path)
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

Events.Subscribe("PickUpToolGun", function(asset, weapon, char)
	Events.Call("PickUpToolGun_" .. asset, weapon, char)

	local tool_gun_data = ToolGunsTutorials[asset]
	if (tool_gun_data) then
		MainHUD:CallEvent("ToggleTutorial", true, tool_gun_data.name, tool_gun_data.tutorials)
	end
end)

Events.Subscribe("DropToolGun", function(asset, weapon, char)
	Events.Call("DropToolGun_" .. asset, weapon, char)

	MainHUD:CallEvent("ToggleTutorial", false)
end)

function ToggleToolGunAiming(weapon, tool, enable)
	if (enable) then
		if (
			tool == "RopeTool" or
			tool == "RemoverTool" or
			tool == "ThrusterTool"
		) then
			DrawDebugToolGun.TraceCollisionChannel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle
		else
			DrawDebugToolGun.TraceCollisionChannel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn
		end

		if (
			tool == "BalloonTool" or
			tool == "LightTool" or
			tool == "LampTool"
		) then
			DrawDebugToolGun.Weapon = weapon

			DrawDebugToolGun.ColorEntity = Color.GREEN
			DrawDebugToolGun.ColorNoEntity = Color.BLUE
			return
		elseif (
			tool == "ColorTool" or
			tool == "ThrusterTool" or
			tool == "WeldTool" or
			tool == "TrailTool" or
			tool == "ResizerTool" or
			tool == "RopeTool" or
			tool == "RemoverTool"
		) then
			DrawDebugToolGun.Weapon = weapon

			DrawDebugToolGun.ColorEntity = Color.GREEN
			DrawDebugToolGun.ColorNoEntity = Color.RED
			return
		end
	end

	DrawDebugToolGun.Weapon = nil
end

DrawDebugToolGun = {
	Weapon = nil,
	ColorEntity = nil,
	ColorNoEntity = nil,
	TraceCollisionChannel = nil
}

Client.Subscribe("Tick", function(delta_time)
	if (DrawDebugToolGun.Weapon) then
		local trace_result = TraceFor(2000, DrawDebugToolGun.TraceCollisionChannel)

		if (not trace_result.Success) then return end

		local color = trace_result.Entity and DrawDebugToolGun.ColorEntity or DrawDebugToolGun.ColorNoEntity

		Client.DrawDebugCrosshairs(trace_result.Location, Rotator(), 25, color, 0, 2)
	end
end)

-- Auxiliar for Tracing for world object
function TraceFor(trace_max_distance, collision_channel)
	local viewport_2D_center = Client.GetViewportSize() / 2
	local viewport_3D = Client.DeprojectScreenToWorld(viewport_2D_center)

	local start_location = viewport_3D.Position + viewport_3D.Direction * 100
	local end_location = viewport_3D.Position + viewport_3D.Direction * trace_max_distance

	return Client.Trace(start_location, end_location, collision_channel, true, true)
end

-- Adds a new item to the Spawn Menu
---@param group string			Unique ID used to identify from which 'group' it belongs
---@param tab string			The tab to display this item - it must be 'props', 'weapons', 'tools' or 'vehicles'
---@param id string				Unique ID used to identify this item
---@param name string			Display name
---@param image string			Image path
---@param category string		The category of this item, each tab has it's own set of categories (Prop: 'basic', 'appliances', 'construction', 'furniture', 'funny', 'tools', 'food', 'street', 'nature' or 'uncategorized'. Weapon: 'rifles', 'smgs', 'pistols', 'shotguns', 'sniper-rifles', 'special' or 'grenades')
---@param tutorials table		List of tutorials to display in the top left screen, in the format: { { key = 'KeyName', text = 'description of the action' }, ... }
function AddSpawnMenuItem(group, tab, id, name, image, category, tutorials)
	if (not SpawnMenuItems[group]) then SpawnMenuItems[group] = {} end
	if (not SpawnMenuItems[group][tab]) then SpawnMenuItems[group][tab] = {} end

	table.insert(SpawnMenuItems[group][tab], {
		id = id,
		name = name,
		image = image,
		sub_category = category
	})

	if (tutorials) then
		local tutorials_parsed = {}

		for _, tutorial_data in pairs(tutorials) do
			local mapped_key = Input.GetMappedKey(tutorial_data.key)

			-- If didn't find mapped key, then use it as Raw
			if (mapped_key == "") then mapped_key = tutorial_data.key end

			-- Gets the image path
			local key_icon = Input.GetKeyIcon(mapped_key)

			table.insert(tutorials_parsed, { image = key_icon, text = tutorial_data.text })
		end

		ToolGunsTutorials[id] = { tutorials = JSON.stringify(tutorials_parsed), name = name }
	end
end

-- Exposes this to other packages
Package.Export("AddSpawnMenuItem", AddSpawnMenuItem)

Package.Export("AddSpawnMenuTab", function(id, name, image_active, image_inactive)
	MainHUD:CallEvent("AddTab", id, name, image_active, image_inactive)
end)

Package.Export("AddSpawnMenuCategory", function(tab_id, id, label, image_active, image_inactive)
	MainHUD:CallEvent("AddCategory", tab_id, id, label, image_active, image_inactive)
end)

-- Configures Tabs
MainHUD:CallEvent("AddTab", "props", "props", "images/tabs/chair.png", "images/tabs/chair-disabled.png")
MainHUD:CallEvent("AddTab", "entities", "entities", "images/tabs/rocket.png", "images/tabs/rocket-disabled.png")
MainHUD:CallEvent("AddTab", "weapons", "weapons", "images/tabs/gun.png", "images/tabs/gun-disabled.png")
MainHUD:CallEvent("AddTab", "vehicles", "vehicles", "images/tabs/car.png", "images/tabs/car-disabled.png")
MainHUD:CallEvent("AddTab", "tools", "tools", "images/tabs/paint-spray.png", "images/tabs/paint-spray-disabled.png")
MainHUD:CallEvent("AddTab", "npcs", "npcs", "images/tabs/robot.png", "images/tabs/robot-disabled.png")

-- Configures Categories
MainHUD:CallEvent("AddCategory", "props", "basic", "Basic", "images/categories/shapes.png", "images/categories/shapes-disabled.png")
MainHUD:CallEvent("AddCategory", "props", "appliances", "Appliances", "images/categories/appliances.png", "images/categories/appliances-disabled.png")
MainHUD:CallEvent("AddCategory", "props", "construction", "Construction", "images/categories/construction.png", "images/categories/construction-disabled.png")
MainHUD:CallEvent("AddCategory", "props", "furniture", "Furniture", "images/categories/lamp.png", "images/categories/lamp-disabled.png")
MainHUD:CallEvent("AddCategory", "props", "funny", "Funny", "images/categories/joker-hat.png", "images/categories/joker-hat-disabled.png")
MainHUD:CallEvent("AddCategory", "props", "tools", "Tools", "images/categories/tools.png", "images/categories/tools-disabled.png")
MainHUD:CallEvent("AddCategory", "props", "food", "Food", "images/categories/hot-dog.png", "images/categories/hot-dog-disabled.png")
MainHUD:CallEvent("AddCategory", "props", "street", "Street", "images/categories/street-lamp.png", "images/categories/street-lamp-disabled.png")
MainHUD:CallEvent("AddCategory", "props", "nature", "Nature", "images/categories/tree.png", "images/categories/tree-disabled.png")
MainHUD:CallEvent("AddCategory", "props", "uncategorized", "Uncategorized", "images/categories/menu.png", "images/categories/menu-disabled.png")

MainHUD:CallEvent("AddCategory", "weapons", "rifles", "Rifles", "images/categories/rifle.png", "images/categories/rifle-disabled.png")
MainHUD:CallEvent("AddCategory", "weapons", "smgs", "SMGs", "images/categories/smg.png", "images/categories/smg-disabled.png")
MainHUD:CallEvent("AddCategory", "weapons", "pistols", "Pistols", "images/categories/revolver.png", "images/categories/revolver-disabled.png")
MainHUD:CallEvent("AddCategory", "weapons", "shotguns", "Shotguns", "images/categories/shotgun.png", "images/categories/shotgun-disabled.png")
MainHUD:CallEvent("AddCategory", "weapons", "sniper-rifles", "Sniper Rifles", "images/categories/sniper-rifle.png", "images/categories/sniper-rifle-disabled.png")
MainHUD:CallEvent("AddCategory", "weapons", "special", "Special", "images/categories/laser-gun.png", "images/categories/laser-gun-disabled.png")
MainHUD:CallEvent("AddCategory", "weapons", "grenades", "Grenade", "images/categories/grenade.png", "images/categories/grenade-disabled.png")
MainHUD:CallEvent("AddCategory", "weapons", "melee", "Melee", "images/categories/knife.png", "images/categories/knife-disabled.png")

MainHUD:CallEvent("AddCategory", "entities", "uncategorized", "Uncategorized", "images/categories/menu.png", "images/categories/menu-disabled.png")
MainHUD:CallEvent("AddCategory", "entities", "destructables", "Destructables", "images/categories/destructable.png", "images/categories/destructable-disabled.png")

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

AddSpawnMenuItem("nanos-world", "weapons", "HFG", "HFG", "assets///NanosWorld/Thumbnails/SK_DC15S.jpg", "special")
AddSpawnMenuItem("nanos-world", "weapons", "VeggieGun", "Veggie Gun", "assets///NanosWorld/Thumbnails/SK_FlareGun.jpg", "special")
AddSpawnMenuItem("nanos-world", "weapons", "BouncyGun", "Bouncy Gun", "assets///NanosWorld/Thumbnails/SK_FlareGun.jpg", "special")

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
AddSpawnMenuItem("nanos-world", "weapons", "Torch", "Torch", "assets///NanosWorld/Thumbnails/SM_Torch.jpg", "melee")
AddSpawnMenuItem("nanos-world", "weapons", "Knife", "Knife", "assets///NanosWorld/Thumbnails/SM_M9.jpg", "melee")
AddSpawnMenuItem("nanos-world", "weapons", "Crowbar", "Crowbar", "assets///NanosWorld/Thumbnails/SM_Crowbar_01.jpg", "melee")

AddSpawnMenuItem("nanos-world", "entities", "BouncyBall", "BouncyBall", "assets///NanosWorld/Thumbnails/SM_Sphere.jpg", "uncategorized")

AddSpawnMenuItem("nanos-world", "entities", "GC_Ball", "GC Ball", "assets///NanosWorld/Thumbnails/SM_Ball_VR.jpg", "destructables")
AddSpawnMenuItem("nanos-world", "entities", "GC_Cube_01", "GC Cube 01", "assets///NanosWorld/Thumbnails/SM_Cube_01.jpg", "destructables")
AddSpawnMenuItem("nanos-world", "entities", "GC_Cube_02", "GC Cube 02", "assets///NanosWorld/Thumbnails/SM_Cube_02.jpg", "destructables")
AddSpawnMenuItem("nanos-world", "entities", "GC_Cube_03", "GC Cube 03", "assets///NanosWorld/Thumbnails/SM_Cube_03.jpg", "destructables")
AddSpawnMenuItem("nanos-world", "entities", "GC_Pyramid", "GC Pyramid", "assets///NanosWorld/Thumbnails/SM_Pyramid.jpg", "destructables")

-- Defines some Spawn Menu Hints
AddNotification("SPAWN_MENU", "you can press Q to open the Spawn Menu", 10000, 30000)
AddNotification("SPAWN_MENU_DESTROY_ITEM", "you can press X to delete your last spawned item", 10000, 90000)


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

Package.Require("Entities/CCTV.lua")
Package.Require("Entities/Breakable.lua")