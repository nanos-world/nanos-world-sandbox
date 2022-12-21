-- Loads the Default Asset Pack list (categorized)
Package.Require("DefaultAssets.lua")

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
	for _, class in pairs(parent_class.GetInheritedClasses(true)) do
		if (not blacklist_class or (not class.IsChildOf(blacklist_class) and class ~= blacklist_class)) then
			SpawnMenu.AddItem(tab, class.GetName(), class.name, class.image, class.category)
		end
	end
end

Package.Subscribe("Load", function()
	-- Wait 1 second so all other packages can send their Tools during Package Load event
	Timer.SetTimeout(function()
		-- Loads all Asset Packs
		local asset_packs = Assets.GetAssetPacks()
		for _, asset_pack in pairs(asset_packs) do

			-- Loads all StaticMeshes as Props
			local props = Assets.GetStaticMeshes(asset_pack.Path)

			for _, prop in pairs(props) do
				-- TODO make global way to access categories for other Asset Packs
				-- Get the category from a default list
				local asset_category = DEFAULT_ASSET_PACK[prop]

				SpawnMenu.AddItem(
					"props",
					asset_pack.Path .. "::" .. prop,
					prop:gsub("SM_", " "):gsub("_", " "), -- Parses it to remove dirty names
					"assets://" .. asset_pack.Path .. "/Thumbnails/" .. prop .. ".jpg",-- Gets the Thumbnail path from conventional path "my_asset_pack/Thumbnails/"
					asset_category or "uncategorized"
				)
			end
		end

		SpawnMenu.AddInheritedClasses("tools", ToolGun)
		SpawnMenu.AddInheritedClasses("npcs", NPC)
		SpawnMenu.AddInheritedClasses("weapons", Melee)
		SpawnMenu.AddInheritedClasses("weapons", Grenade)
		SpawnMenu.AddInheritedClasses("weapons", Weapon, ToolGun)
		SpawnMenu.AddInheritedClasses("vehicles", Vehicle)

		-- Inherited from Prop is Entity?
		for _, class in ipairs(Prop.GetInheritedClasses(true)) do
			-- Props child without property .name we consider don't wish to display on Spawn Menu
			if (class.name) then
				SpawnMenu.AddItem("entities", class.GetName(), class.name, class.image, class.category)
			end
		end

		MainHUD:CallEvent("SetSpawnMenuItems", SpawnMenu.items)
	end, 1000)
end)

Input.Bind("SpawnMenu", InputEvent.Released, function()
	if (ContextMenu.is_opened) then return end

	MainHUD:CallEvent("ToggleSpawnMenuVisibility", false)
	SpawnMenu.is_opened = false
	Client.SetMouseEnabled(false)
	Client.SetChatVisibility(true)

	PlayClickSound(0.9)
end)

Input.Bind("SpawnMenu", InputEvent.Pressed, function()
	if (ContextMenu.is_opened) then return end

	MainHUD:CallEvent("ToggleSpawnMenuVisibility", true)
	SpawnMenu.is_opened = true
	Client.SetMouseEnabled(true)
	Client.SetChatVisibility(false)
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
	local viewport_2D_center = Client.GetViewportSize() / 2
	local viewport_3D = Client.DeprojectScreenToWorld(viewport_2D_center)
	local trace_max_distance = 5000

	local start_location = viewport_3D.Position
	local end_location = viewport_3D.Position + viewport_3D.Direction * trace_max_distance

	-- Traces for world things
    local trace_result = Client.TraceLineSingle(start_location, end_location, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.Water)

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
SpawnMenu.AddItem = function(tab_id, id, name, image, category_id)
	if (not SpawnMenu.items[tab_id]) then
		Package.Warn("Invalid tab when trying to add a new Spawn Menu item: '%s'.", tab_id)
	end

	table.insert(SpawnMenu.items[tab_id], {
		id = id,
		name = name,
		image = image,
		category = category_id
	})
end

-- Adds a new tab to the Spawn Menu
---@param id string				Unique ID used to identify this tab
---@param label string			Display text
---@param image_active string	Image path when tab is selected
---@param image_inactive string	Image path when tab is not selected
SpawnMenu.AddTab = function(id, label, image_active, image_inactive)
	SpawnMenu.items[id] = {}
	MainHUD:CallEvent("AddTab", id, label, image_active, image_inactive)
end

-- Adds a new category to a tab in the Spawn Menu
---@param tab_id string			Tab id
---@param id string				Unique ID used to identify this category
---@param label string			Display text
---@param image_active string	Image path when tab is selected
---@param image_inactive string	Image path when tab is not selected
SpawnMenu.AddCategory = function(tab_id, id, label, image_active, image_inactive)
	if (not SpawnMenu.items[tab_id]) then
		Package.Warn("Invalid tab when trying to add a new Spawn Menu category: '%s'.", tab_id)
	end

	MainHUD:CallEvent("AddCategory", tab_id, id, label, image_active, image_inactive)
end

-- Exposes this to other packages
Package.Export("AddSpawnMenuItem", SpawnMenu.AddItem)
Package.Export("AddSpawnMenuTab", SpawnMenu.AddTab)
Package.Export("AddSpawnMenuCategory", SpawnMenu.AddCategory)

-- Configures Tabs
SpawnMenu.AddTab("props", "props", "tabs/chair.webp", "tabs/chair-disabled.webp")
SpawnMenu.AddTab("entities", "entities", "tabs/rocket.webp", "tabs/rocket-disabled.webp")
SpawnMenu.AddTab("weapons", "weapons", "tabs/gun.webp", "tabs/gun-disabled.webp")
SpawnMenu.AddTab("vehicles", "vehicles", "tabs/car.webp", "tabs/car-disabled.webp")
SpawnMenu.AddTab("tools", "tools", "tabs/paint-spray.webp", "tabs/paint-spray-disabled.webp")
SpawnMenu.AddTab("npcs", "npcs", "tabs/robot.webp", "tabs/robot-disabled.webp")

-- Configures Categories
SpawnMenu.AddCategory("props", "basic", "Basic", "categories/shapes.webp", "categories/shapes-disabled.webp")
SpawnMenu.AddCategory("props", "appliances", "Appliances", "categories/appliances.webp", "categories/appliances-disabled.webp")
SpawnMenu.AddCategory("props", "construction", "Construction", "categories/construction.webp", "categories/construction-disabled.webp")
SpawnMenu.AddCategory("props", "furniture", "Furniture", "categories/lamp.webp", "categories/lamp-disabled.webp")
SpawnMenu.AddCategory("props", "funny", "Funny", "categories/joker-hat.webp", "categories/joker-hat-disabled.webp")
SpawnMenu.AddCategory("props", "tools", "Tools", "categories/tools.webp", "categories/tools-disabled.webp")
SpawnMenu.AddCategory("props", "food", "Food", "categories/hot-dog.webp", "categories/hot-dog-disabled.webp")
SpawnMenu.AddCategory("props", "street", "Street", "categories/street-lamp.webp", "categories/street-lamp-disabled.webp")
SpawnMenu.AddCategory("props", "nature", "Nature", "categories/tree.webp", "categories/tree-disabled.webp")
SpawnMenu.AddCategory("props", "uncategorized", "Uncategorized", "categories/menu.webp", "categories/menu-disabled.webp")

SpawnMenu.AddCategory("weapons", "rifles", "Rifles", "categories/rifle.webp", "categories/rifle-disabled.webp")
SpawnMenu.AddCategory("weapons", "smgs", "SMGs", "categories/smg.webp", "categories/smg-disabled.webp")
SpawnMenu.AddCategory("weapons", "pistols", "Pistols", "categories/revolver.webp", "categories/revolver-disabled.webp")
SpawnMenu.AddCategory("weapons", "shotguns", "Shotguns", "categories/shotgun.webp", "categories/shotgun-disabled.webp")
SpawnMenu.AddCategory("weapons", "sniper-rifles", "Sniper Rifles", "categories/sniper-rifle.webp", "categories/sniper-rifle-disabled.webp")
SpawnMenu.AddCategory("weapons", "special", "Special", "categories/laser-gun.webp", "categories/laser-gun-disabled.webp")
SpawnMenu.AddCategory("weapons", "grenades", "Grenade", "categories/grenade.webp", "categories/grenade-disabled.webp")
SpawnMenu.AddCategory("weapons", "melee", "Melee", "categories/knife.webp", "categories/knife-disabled.webp")

SpawnMenu.AddCategory("entities", "uncategorized", "Uncategorized", "categories/menu.webp", "categories/menu-disabled.webp")
SpawnMenu.AddCategory("entities", "destructables", "Destructables", "categories/destructable.webp", "categories/destructable-disabled.webp")

-- Defines some Spawn Menu Hints
AddNotification("SPAWN_MENU", "you can press Q to open the Spawn Menu", 10000, 30000)
AddNotification("SPAWN_MENU_DESTROY_ITEM", "you can press X to delete your last spawned item", 10000, 90000)


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

-- Adds the default NanosWorld packs
Package.RequirePackage("nanos-world-weapons")
Package.RequirePackage("nanos-world-vehicles")