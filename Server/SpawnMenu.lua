SpawnMenu = {
	items = {
		props = {},
		entities = {},
		weapons = {},
		vehicles = {},
		tools = {},
		npcs = {},
	}
}

-- Event for Spawning and Item from the SpawnMenu
Events.SubscribeRemote("SpawnItem", function(player, tab, id, spawn_location, spawn_rotation, selected_option)
	local character = player:GetControlledCharacter()

	if (tab == "vehicles") then
		spawn_location = character:GetLocation() + Vector(0, 0, 50)
		spawn_rotation = character:GetRotation()
	elseif (tab == "tools" or tab == "weapons") then
		spawn_location = character:GetLocation()
	end

	local item = nil

	-- If spawning a Prop
	if (tab == "props") then
		item = Prop(spawn_location + Vector(0, 0, 50), Rotator(0, spawn_rotation.Yaw + 180, 0), id)

		-- If this Prop is a Breakable Prop, setup it (we only configure Props from Spawn Menu to break*)
		if (BreakableProps[id]) then
			SetupBreakableProp(item)
		end
	else
		if (not SpawnMenu.items[tab] or not SpawnMenu.items[tab][id]) then
			Package.Error("Failed to find item to spawn: Tab '%s'. ID '%s'.", tab, id)
			return
		end

		local spawn_menu_item = SpawnMenu.items[tab][id]

		-- If this has a spawn function, uses it, otherwise uses the Package Call method because it may have been created by another package
		if (spawn_menu_item.spawn_function) then
			item = spawn_menu_item.spawn_function(spawn_location, spawn_rotation, tab, id)
		else
			item = Package.Call(spawn_menu_item.package_name, spawn_menu_item.package_function, spawn_location, spawn_rotation, tab, id)
		end

		if (character) then
			if (item:IsA(Weapon)) then
				-- Stores the old Aim Mode
				local current_aiming_mode = character:GetWeaponAimMode()

				-- Destroys the current picked up item
				local current_picking_weapon = character:GetPicked()
				if (current_picking_weapon) then current_picking_weapon:Destroy() end

				character:PickUp(item)

				-- If has previous Aim Mode, sets it again after some small delay
				if (current_aiming_mode == AimMode.ADS or current_aiming_mode == AimMode.Zoomed or current_aiming_mode == AimMode.ZoomedZoom) then
					character:SetWeaponAimMode(current_aiming_mode)
				end

				-- workaround
				if (selected_option ~= "") then
					ApplyWeaponPattern(item, selected_option)
				end
			elseif (tab == "vehicles") then
				-- Enters the Character
				character:EnterVehicle(item, 0)
			elseif (item:IsA(Melee) or item:IsA(Grenade)) then
				-- Destroys the current picked up item
				local current_picking_weapon = character:GetPicked()
				if (current_picking_weapon) then current_picking_weapon:Destroy() end

				character:PickUp(item)
			end
		end
	end

	-- Calls the client to update his history
	Events.CallRemote("SpawnedItem", player, item)
end)

-- Called by Client to destroy an spawned item 
Events.SubscribeRemote("DestroyItem", function(player, item)
	-- Spawns some sounds and particles
	Events.BroadcastRemote("SpawnSound", item:GetLocation(), "nanos-world::A_Player_Eject", false, 0.3, 1)
	Particle(item:GetLocation() + Vector(0, 0, 30), Rotator(), "nanos-world::P_OmnidirectionalBurst")

	-- Destroy the item
	item:Destroy()
end)

SpawnMenu.AddInheritedClasses = function(tab, parent_class, blacklist_class)
	for _, class in pairs(parent_class.GetInheritedClasses(true)) do
		if (not blacklist_class or not class.IsChildOf(blacklist_class)) then
			SpawnMenu.AddItem(tab, class.GetName(), class)
		end
	end
end

Package.Subscribe("Load", function()
	SpawnMenu.AddInheritedClasses("tools", ToolGun)
	SpawnMenu.AddInheritedClasses("npcs", NPC)
	SpawnMenu.AddInheritedClasses("weapons", Melee)
	SpawnMenu.AddInheritedClasses("entities", Prop) -- Inherited from Prop is Entity?
	SpawnMenu.AddInheritedClasses("weapons", Grenade)
	SpawnMenu.AddInheritedClasses("weapons", Weapon, ToolGun)
	SpawnMenu.AddInheritedClasses("vehicles", Vehicle)
end)

-- Adds a new item to the Spawn Menu
---@param tab_id string				Tab of this item - it must be 'props', 'weapons', 'tools' or 'vehicles'
---@param id string					Unique ID used to identify this item
---@param spawn_function string		Spawn function
---@param package_name? string		Your package name which will be used to call your spawn function (used by external packages if spawn_function is not passed)
---@param package_function? table	Spawn Function name which will be called from sandbox (used by external packages if spawn_function is not passed)
SpawnMenu.AddItem = function(tab_id, id, spawn_function, package_name, package_function)
	if (not SpawnMenu.items[tab_id]) then
		Package.Warn("Invalid tab when trying to add a new Spawn Menu item: '%s'.", tab_id)
	end

	SpawnMenu.items[tab_id][id] = {
		spawn_function = spawn_function,
		package_name = package_name,
		package_function = package_function,
	}
end

-- Function to apply a Texture Pattern in a Weapon (currently only work on default nanos world Weapons as their materials are prepared beforehand)
function ApplyWeaponPattern(weapon, pattern_texture)
	weapon:SetMaterialTextureParameter("PatternTexture", pattern_texture)
	weapon:SetMaterialScalarParameter("PatternBlend", pattern_texture ~= "" and 1 or 0)
	weapon:SetMaterialScalarParameter("PatternTiling", 2)
	weapon:SetMaterialScalarParameter("PatternRoughness", 0.3)
end

Events.SubscribeRemote("ApplyWeaponPattern", function(player, weapon, pattern_texture)
	ApplyWeaponPattern(weapon, pattern_texture)
end)

-- Exported functions cannot have functions as arguments, so we get the package name and package_function name and call it the proper way
Package.Export("AddSpawnMenuItem", function(tab, id, package_name, package_function)
	SpawnMenu.AddItem(tab, id, nil, package_name, package_function)
end)

function RequireAllLuaFilesInFolder(folder)
	local files = Package.GetFiles(folder, ".lua")
	for _, file in pairs(files) do
		Package.Require(file)
	end
end

-- Requires all the Tools
Package.Require("Tools/BaseToolGun.lua")
RequireAllLuaFilesInFolder("Server/Tools")

-- Weapons
RequireAllLuaFilesInFolder("Server/Weapons")

-- Entities
RequireAllLuaFilesInFolder("Server/Entities")

-- Extra
Package.Require("NPC.lua")

-- Adds the default NanosWorld packs
Package.RequirePackage("nanos-world-weapons")
Package.RequirePackage("nanos-world-vehicles")