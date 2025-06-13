-- Spawn Menu Data
SpawnMenu = SpawnMenu or {
	-- Whether the menu is opened
	is_opened = false,

	-- Stores all spawned Items by this client
	history = setmetatable({}, { __mode = 'k' }),

	-- List of all items
	items = {},

	-- WORKAROUND used for weapons Patterns
	selected_option = "",
}

-- Configures the Highlight colors to be used
Client.SetHighlightColor(Color(0, 1, 0, 1.20), 0, HighlightMode.Always) -- Index 0
Client.SetOutlineColor(Color(0, 0, 10), 2) -- Index 2

-- Caches Sounds with Auto Play = false
SoundDeleteItemFromHistory = Sound(Vector(), "nanos-world::A_Player_Eject", true, false, SoundType.UI, 0.1, 1, 400, 3600, 0, false, 0, false)
SoundButtonHover = Sound(Vector(), "nanos-world::A_Button_Hover_Cue", true, false, SoundType.UI, 1, 1, 400, 3600, 0, false, 0, false)
SoundButtonClick = Sound(Vector(), "nanos-world::A_Button_Click_Cue", true, false, SoundType.UI, 1, 1, 400, 3600, 0, false, 0, false)
SoundSpawnItem = Sound(Vector(), "nanos-world::A_Button_Click_Up_Cue", true, false, SoundType.UI, 1, 1.1, 400, 3600, 0, false, 0, false)
SoundSelectOption = Sound(Vector(), "nanos-world::A_Button_Click_Up_Cue", true, false, SoundType.UI, 1, 1.1, 400, 3600, 0, false, 0, false)
SoundInvalidAction = Sound(Vector(), "nanos-world::A_Invalid_Action", true, false, SoundType.UI, 1, 1, 400, 3600, 0, false, 0, false)


SpawnMenu.AddInheritedClasses = function(tab, parent_class, blacklist_class)
	-- Iterates all existing classes
	for _, class in pairs(parent_class.GetInheritedClasses(true)) do
		SpawnMenu.AddInheritedClass(tab, class, blacklist_class, true)
	end

	-- Subscribes for further created classes
	parent_class.Subscribe("ClassRegister", function(class)
		SpawnMenu.AddInheritedClass(tab, class, blacklist_class)
	end)
end

SpawnMenu.AddInheritedClass = function(tab, class, blacklist_class, dont_add_to_spawn_menu)
	if (class.name and (not blacklist_class or (not class.IsChildOf(blacklist_class) and class ~= blacklist_class))) then
		SpawnMenu.AddItem(tab, class.GetName(), class.name, class.image, class.category, dont_add_to_spawn_menu)
	end
end

Package.Subscribe("Load", function()
	-- Loads all Asset Packs
	local asset_packs = Assets.GetAssetPacks()
	for _, asset_pack in pairs(asset_packs) do

		-- Loads all StaticMeshes as Props
		local props = Assets.GetStaticMeshes(asset_pack.Path)

		for _, prop in pairs(props) do
			SpawnMenu.AddItem(
				"props",
				asset_pack.Path .. "::" .. prop.key,
				prop.key:gsub("SM_", " "):gsub("_", " "), -- Parses it to remove dirty names
				"assets://" .. asset_pack.Path .. "/" .. (prop.thumbnail or ("Thumbnails/" .. prop.key .. ".jpg")), -- Gets the Thumbnail path from conventional path "my-asset-pack/Thumbnails/"
				prop.category or "uncategorized",
				true
			)
		end
	end

	SpawnMenu.AddInheritedClasses("tools", ToolGun)
	SpawnMenu.AddInheritedClasses("npcs", Character)
	SpawnMenu.AddInheritedClasses("npcs", CharacterSimple)
	SpawnMenu.AddInheritedClasses("weapons", Melee)
	SpawnMenu.AddInheritedClasses("entities", Prop) -- Inherited from Prop is Entity?
	SpawnMenu.AddInheritedClasses("weapons", Grenade)
	SpawnMenu.AddInheritedClasses("weapons", Weapon, ToolGun)
	SpawnMenu.AddInheritedClasses("vehicles", VehicleWheeled)
	SpawnMenu.AddInheritedClasses("vehicles", VehicleWater)
	MainHUD:CallEvent("SetSpawnMenuItems", SpawnMenu.items)
end)

Input.Bind("SpawnMenu", InputEvent.Released, function()
	if (ContextMenu.is_opened) then return end

	MainHUD:CallEvent("ToggleSpawnMenuVisibility", false)
	SpawnMenu.is_opened = false
	Input.SetMouseEnabled(false)
	Chat.SetVisibility(true)

	PlayClickSound(0.9)
end)

Input.Bind("SpawnMenu", InputEvent.Pressed, function()
	if (ContextMenu.is_opened) then return end

	MainHUD:CallEvent("ToggleSpawnMenuVisibility", true)
	SpawnMenu.is_opened = true
	Input.SetMouseEnabled(true)
	Chat.SetVisibility(false)
	MainHUD:BringToFront()

	PlayClickSound(1.1)
end)

-- Function to delete the last item spawned
function DeleteItemFromHistory()
	if (#SpawnMenu.history == 0) then
		AddNotification("NO_ITEM_TO_DELETE", "there are no items in your History to destroy!", 3000, 0, true)
		return
	end

	local data = table.remove(SpawnMenu.history)

	-- If there is a item to destroy, otherwise tries the next from the list, recursively
	if (data.item and data.item:IsValid()) then
		Events.CallRemote("DestroyItem", data.item)
		SoundDeleteItemFromHistory:Play()
	else
		DeleteItemFromHistory()
	end
end

UndoDelay = 0

function UndoTick(delta_time)
	-- Don't spam the user with empty history messages
	if (#SpawnMenu.history == 0) then
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
function PlayHoverSound(pitch)
	SoundButtonHover:SetPitch(pitch or 1)
	SoundButtonHover:Play()
end

function PlayClickSound(pitch)
	SoundButtonClick:SetPitch(pitch or 1)
	SoundButtonClick:Play()
end

MainHUD:Subscribe("HoverSound", PlayHoverSound)
MainHUD:Subscribe("ClickSound", PlayClickSound)


-- Handle for selecting an Item from the SpawnMenu
MainHUD:Subscribe("SpawnItem", function(category, asset_id)
	-- Gets the world spawn location to spawn the Item
	local viewport_2D_center = Viewport.GetViewportSize() / 2
	local viewport_3D = Viewport.DeprojectScreenToWorld(viewport_2D_center)
	local trace_max_distance = 5000

	local start_location = viewport_3D.Position
	local end_location = viewport_3D.Position + viewport_3D.Direction * trace_max_distance

	-- Traces for world things
    local trace_result = Trace.LineSingle(start_location, end_location, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.Water, TraceMode.TraceOnlyVisibility)

	local spawn_location = end_location

	-- Gets the rotation looking at the player, only rotated by Yaw
	local spawn_rotation = Rotator(0, viewport_3D.Direction:Rotation().Yaw, 0)

	if (trace_result.Success) then
		spawn_location = trace_result.Location - viewport_3D.Direction * 100
	end

	-- Triggers client side
	if (not Events.Call("SpawnItem_" .. asset_id, category, asset_id, spawn_location, spawn_rotation)) then
		return
	end

	-- Calls server to spawn it
	Events.CallRemote("SpawnItem", category, asset_id, spawn_location, spawn_rotation, SpawnMenu.selected_option)

	-- Spawns a sound for 'spawning an item'
	SoundSpawnItem:Play()
end)

-- Subscribes for when I select an Option
MainHUD:Subscribe("SelectOption", function(texture_path)
	SpawnMenu.selected_option = texture_path

	local local_character = Client.GetLocalPlayer():GetControlledCharacter()

	if (local_character) then
		local current_picked_item = local_character:GetPicked()
		if (current_picked_item) then
			SoundSelectOption:Play()
			Events.CallRemote("ApplyWeaponPattern", current_picked_item, texture_path)
		end
	end
end)

-- Subscribes for when I spawn an Item, do add it to my history
Events.SubscribeRemote("SpawnedItem", function(item, weld)
	table.insert(SpawnMenu.history, { ["item"] = item, ["weld"] = weld })
end)

-- Adds a new item to the Spawn Menu
---@param tab_id string			The tab to display this item - it must be 'props', 'weapons', 'tools', 'vehicles' or 'npcs'
---@param id string				Unique ID used to identify this item
---@param name string			Display name
---@param image string			Image path
---@param category_id? string		The category of this item, each tab has it's own set of categories (Prop: 'basic', 'appliances', 'construction', 'furniture', 'funny', 'tools', 'food', 'street', 'nature' or 'uncategorized'. Weapon: 'rifles', 'smgs', 'pistols', 'shotguns', 'sniper-rifles', 'special' or 'grenades')
SpawnMenu.AddItem = function(tab_id, id, name, image, category_id, dont_add_to_spawn_menu)
	if (not SpawnMenu.items[tab_id]) then
		Console.Warn("Invalid tab when trying to add a new Spawn Menu item: '%s'.", tab_id)
	end

	local item = {
		id = id,
		name = name,
		image = image,
		category = category_id
	}

	table.insert(SpawnMenu.items[tab_id], item)

	if (not dont_add_to_spawn_menu) then
		MainHUD:CallEvent("AddSpawnMenuItem", tab_id, item)
	end
end

-- Adds a new tab to the Spawn Menu
---@param id string				Unique ID used to identify this tab
---@param label string			Display text
---@param image string			Image path of the tab
SpawnMenu.AddTab = function(id, label, image)
	SpawnMenu.items[id] = {}
	MainHUD:CallEvent("AddTab", id, label, image)
end

-- Adds a new category to a tab in the Spawn Menu
---@param tab_id string			Tab id
---@param id string				Unique ID used to identify this category
---@param label string			Display text
---@param image string			Image path of the category
SpawnMenu.AddCategory = function(tab_id, id, label, image)
	if (not SpawnMenu.items[tab_id]) then
		Console.Warn("Invalid tab when trying to add a new Spawn Menu category: '%s'.", tab_id)
	end

	MainHUD:CallEvent("AddCategory", tab_id, id, label, image)
end

-- Exposes SpawnMenu to other packages
Package.Export("SpawnMenu", SpawnMenu)

-- Configures Tabs
SpawnMenu.AddTab("props", "props", "tabs/chair.webp")
SpawnMenu.AddTab("entities", "entities", "tabs/rocket.webp")
SpawnMenu.AddTab("weapons", "weapons", "tabs/gun.webp")
SpawnMenu.AddTab("vehicles", "vehicles", "tabs/car.webp")
SpawnMenu.AddTab("tools", "tools", "tabs/paint-spray.webp")
SpawnMenu.AddTab("npcs", "npcs", "tabs/robot.webp")

-- Configures Categories
SpawnMenu.AddCategory("props", "basic", "Basic", "categories/shapes.webp")
SpawnMenu.AddCategory("props", "appliances", "Appliances", "categories/appliances.webp")
SpawnMenu.AddCategory("props", "construction", "Construction", "categories/construction.webp")
SpawnMenu.AddCategory("props", "furniture", "Furniture", "categories/lamp.webp")
SpawnMenu.AddCategory("props", "funny", "Funny", "categories/joker-hat.webp")
SpawnMenu.AddCategory("props", "tools", "Tools", "categories/tools.webp")
SpawnMenu.AddCategory("props", "food", "Food", "categories/hot-dog.webp")
SpawnMenu.AddCategory("props", "street", "Street", "categories/street-lamp.webp")
SpawnMenu.AddCategory("props", "nature", "Nature", "categories/tree.webp")
SpawnMenu.AddCategory("props", "uncategorized", "Uncategorized", "categories/menu.webp")

SpawnMenu.AddCategory("weapons", "rifles", "Rifles", "categories/rifle.webp")
SpawnMenu.AddCategory("weapons", "smgs", "SMGs", "categories/smg.webp")
SpawnMenu.AddCategory("weapons", "pistols", "Pistols", "categories/revolver.webp")
SpawnMenu.AddCategory("weapons", "shotguns", "Shotguns", "categories/shotgun.webp")
SpawnMenu.AddCategory("weapons", "sniper-rifles", "Sniper Rifles", "categories/sniper-rifle.webp")
SpawnMenu.AddCategory("weapons", "special", "Special", "categories/laser-gun.webp")
SpawnMenu.AddCategory("weapons", "grenades", "Grenade", "categories/grenade.webp")
SpawnMenu.AddCategory("weapons", "melee", "Melee", "categories/knife.webp")

SpawnMenu.AddCategory("entities", "uncategorized", "Uncategorized", "categories/menu.webp")
SpawnMenu.AddCategory("entities", "destructables", "Destructables", "categories/destructable.webp")

-- Defines some Spawn Menu Hints
local spawn_menu_keybinding = Input.GetMappedKeys("SpawnMenu")[1] or "not set"
local undo_keybinding = Input.GetMappedKeys("Undo")[1] or "not set"

AddNotification("SPAWN_MENU", "you can press " .. spawn_menu_keybinding .. " to open the Spawn Menu", 10000, 30000)
AddNotification("SPAWN_MENU_DESTROY_ITEM", "you can press " .. undo_keybinding .. " to delete your last spawned item", 10000, 90000)


function RequireAllLuaFilesInFolder(folder)
	local files = Package.GetFiles(folder, ".lua")
	for _, file in pairs(files) do
		Package.Require(file)
	end
end

-- Requires all the Tools
Package.Require("Tools/BaseToolGun.lua")
RequireAllLuaFilesInFolder("Client/Tools")

-- Weapons
RequireAllLuaFilesInFolder("Client/Weapons")

-- Entities
RequireAllLuaFilesInFolder("Client/Entities")

-- Extra
Package.Require("NPC.lua")
