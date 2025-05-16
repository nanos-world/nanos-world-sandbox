SpawnMenu = {
	-- List of items defined
	items = {
		props = {},
		entities = {},
		weapons = {},
		vehicles = {},
		tools = {},
		npcs = {},
	}
}

-- Handles a Spawn Item event called by client
---@param player Player				The player who triggered it
---@param tab string				The tab of the item
---@param id string					The id of the item
---@param spawn_location Vector		The spawn location passed by the client
---@param spawn_rotation Rotator	The spawn rotation passed by the client
---@param selected_option string	Temp custom hack parameter to set weapon patterns
SpawnMenu.SpawnItem = function(player, tab, id, spawn_location, spawn_rotation, selected_option)
	local character = player:GetControlledCharacter()

	if (tab == "vehicles") then
		spawn_rotation.Yaw = spawn_rotation.Yaw - 90
	elseif (character and (tab == "tools" or tab == "weapons")) then
		spawn_location = character:GetLocation()
	end

	local item = nil

	-- If spawning a Prop
	if (tab == "props") then
		-- Rotates the Prop 180 degrees to make it face the player and normalize it to be in range [0-360]
		spawn_rotation.Yaw = spawn_rotation.Yaw + 180
		spawn_rotation:Normalize()

		item = Prop(spawn_location + Vector(0, 0, 50), Rotator(0, spawn_rotation.Yaw, 0), id)

		-- If this Prop is a Breakable Prop, setup it (we only configure Props from Spawn Menu to break*)
		if (BreakableProps[id]) then
			SetupBreakableProp(item)
		end
	else
		if (not SpawnMenu.items[tab] or not SpawnMenu.items[tab][id]) then
			Console.Error("Failed to find item to spawn: Tab '%s'. ID '%s'.", tab, id)
			return
		end

		-- Calls the spawn function
		item = SpawnMenu.items[tab][id].spawn_function(spawn_location, spawn_rotation, tab, id)

		-- Forces the Network Authority to the player who spawned it
		item:SetNetworkAuthority(player)

		if (character) then
			local is_weapon = item:IsA(Weapon)
			local is_melee = item:IsA(Melee)
			local is_grenade = item:IsA(Grenade)

			if (is_weapon or is_melee or is_grenade) then
				-- Stores the old Aim Mode
				local current_aiming_mode = character:GetWeaponAimMode()

				-- Destroys the current picked up item
				local current_picking_weapon = character:GetPicked()
				if (current_picking_weapon) then current_picking_weapon:Destroy() end

				character:PickUp(item)

				if (is_weapon) then
					-- If has previous Aim Mode, sets it again so the Character keeps aiming
					if (current_aiming_mode == AimMode.ADS or current_aiming_mode == AimMode.Zoomed or current_aiming_mode == AimMode.ZoomedZoom) then
						character:SetWeaponAimMode(current_aiming_mode)
					end

					-- workaround
					if (selected_option ~= "") then
						ApplyWeaponPattern(item, selected_option)
					end
				end
			end
		end
	end

	-- Calls the client to update his history
	Events.CallRemote("SpawnedItem", player, item)
end

-- Handles a Spawn Item event called by client
---@param player Player				The player who triggered it
---@param item any					The item to be destroyed
SpawnMenu.DestroyItem = function(player, item)
	-- Spawns some sounds and particles
	Events.BroadcastRemote("SpawnSound", item:GetLocation(), "nanos-world::A_Player_Eject", false, 0.3, 1)
	Particle(item:GetLocation() + Vector(0, 0, 30), Rotator(), "nanos-world::P_OmnidirectionalBurst")

	-- Destroy the item
	item:Destroy()
end

SpawnMenu.AddInheritedClasses = function(tab, parent_class, blacklist_class)
	-- Iterates all existing classes
	for _, class in pairs(parent_class.GetInheritedClasses(true)) do
		SpawnMenu.AddInheritedClass(tab, class, blacklist_class)
	end

	-- Subscribes for further created classes
	parent_class.Subscribe("ClassRegister", function(class)
		SpawnMenu.AddInheritedClass(tab, class, blacklist_class)
	end)
end

SpawnMenu.AddInheritedClass = function(tab, class, blacklist_class)
	if (not blacklist_class or (not class.IsChildOf(blacklist_class) and class ~= blacklist_class)) then
		SpawnMenu.AddItem(tab, class.GetName(), class)
	end
end

-- Adds a new item to the Spawn Menu
---@param tab_id string				Tab of this item - it must be 'props', 'weapons', 'tools' or 'vehicles'
---@param id string					Unique ID used to identify this item
---@param spawn_function function	Spawn function
SpawnMenu.AddItem = function(tab_id, id, spawn_function)
	if (not SpawnMenu.items[tab_id]) then
		Console.Warn("Invalid tab when trying to add a new Spawn Menu item: '%s'.", tab_id)
	end

	SpawnMenu.items[tab_id][id] = {
		spawn_function = spawn_function
	}
end

-- Event for Spawning and Item from the SpawnMenu
Events.SubscribeRemote("SpawnItem", function(...)
	-- Note: we explicitly call it so other scripts can override this function
	SpawnMenu.SpawnItem(...)
end)

-- Called by Client to destroy an spawned item
Events.SubscribeRemote("DestroyItem", function(...)
	-- Note: we explicitly call it so other scripts can override this function
	SpawnMenu.DestroyItem(...)
end)

Package.Subscribe("Load", function()
	SpawnMenu.AddInheritedClasses("tools", ToolGun)
	SpawnMenu.AddInheritedClasses("npcs", Character)
	SpawnMenu.AddInheritedClasses("npcs", CharacterSimple)
	SpawnMenu.AddInheritedClasses("weapons", Melee)
	SpawnMenu.AddInheritedClasses("entities", Prop) -- Inherited from Prop is Entity?
	SpawnMenu.AddInheritedClasses("weapons", Grenade)
	SpawnMenu.AddInheritedClasses("weapons", Weapon, ToolGun)
	SpawnMenu.AddInheritedClasses("vehicles", VehicleWheeled)
	SpawnMenu.AddInheritedClasses("vehicles", VehicleWater)
end)

-- Function to apply a Texture Pattern in a Weapon (currently only work on default nanos world Weapons as their materials are prepared beforehand)
function ApplyWeaponPattern(weapon, pattern_texture)
	weapon:SetMaterialTextureParameter("PatternTexture", pattern_texture)
	weapon:SetMaterialScalarParameter("PatternBlend", pattern_texture ~= "" and 1 or 0)
	weapon:SetMaterialScalarParameter("PatternTiling", 2)
	weapon:SetMaterialScalarParameter("PatternRoughness", 0.3)
end

Events.SubscribeRemote("ApplyWeaponPattern", function(player, weapon, pattern_texture)
	local char = player:GetControlledCharacter()
	if not char then return end

	local picked = char:GetPicked()
	if not picked or (picked ~= weapon) then return end

	ApplyWeaponPattern(weapon, pattern_texture)
end)

-- Exposes SpawnMenu to other packages
Package.Export("SpawnMenu", SpawnMenu)

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
