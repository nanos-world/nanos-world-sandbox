-- Function to spawn the ToolGun weapon
function SpawnGenericToolGun(location, rotation, color)
	local tool_gun = Weapon(
		location or Vector(),
		rotation or Rotator(),
		"NanosWorld::SK_Blaster",					-- Model
		0,											-- Collision (Normal)
		true,										-- Gravity Enabled
		10000000,									-- Ammo in the Clip
		0,											-- Ammo in the Bag
		10000000,									-- Clip Capacity
		0,											-- Base Damage
		0,											-- Spread
		1,											-- Bullet Count (1 for common weapons, > 1 for shotguns)
		10000000,									-- Ammo to Reload (Ammo Clip for common weapons, 1 for shotguns)
		20000,										-- Max Bullet Distance
		20000,										-- Bullet Speed (visual only)
		Color(),									-- Bullet Color
		0.6,										-- Sight's FOV multiplier
		Vector(0, 0, -13.75),						-- Sight Location
		Rotator(-0.5, 0, 0),						-- Sight Rotation
		Vector(2, -1.5, 0),							-- Left Hand Location
		Rotator(0, 50, 130),						-- Left Hand Rotation
		Vector(-35, -5, 5),							-- Right Hand Offset
		HandlingMode.SingleHandedWeapon,
		0.10,										-- Cadence
		false,										-- Can Hold Use (keep pressing to keep firing, common to automatic weapons)
		false,										-- Need to release to Fire (common to Bows)
		"",											-- Bullet Trail Particle
		"",											-- Barrel Particle
		"",											-- Shells Particle
		"NanosWorld::A_Pistol_Dry",					-- Weapon's Dry Sound
		"NanosWorld::A_Pistol_Load",				-- Weapon's Load Sound
		"NanosWorld::A_Pistol_Unload",				-- Weapon's Unload Sound
		"NanosWorld::A_AimZoom",					-- Weapon's Zooming Sound
		"NanosWorld::A_Rattle",						-- Weapon's Aiming Sound
		"NanosWorld::A_Simulate_Start",				-- Weapon's Shot Sound
		"NanosWorld::AM_Mannequin_Reload_Pistol",	-- Character's Reloading Animation
		"NanosWorld::AM_Mannequin_Sight_Fire",		-- Character's Aiming Animation
		"NanosWorld::SM_Glock_Mag_Empty",			-- Magazine Mesh
		CrosshairType.Dot
	)

	tool_gun:SetValue("Color", color, true)
	tool_gun:SetMaterialColorParameter("Emissive", color * 500)

	return tool_gun
end

-- Function to spawn the PortalGun
function SpawnPortalGun(location, rotation)
	local tool_gun = Weapon(
		location or Vector(),
		rotation or Rotator(),
		"NanosWorld::SK_PortalGun",	-- Model
		0,						-- Collision (Normal)
		true,					-- Gravity Enabled
		10000000,				-- Ammo in the Clip
		0,						-- Ammo in the Bag
		10000000,				-- Clip Capacity
		0,						-- Base Damage
		0,						-- Spread
		1,						-- Bullet Count (1 for common weapons, > 1 for shotguns)
		10000000,				-- Ammo to Reload (Ammo Clip for common weapons, 1 for shotguns)
		20000,					-- Max Bullet Distance
		20000,					-- Bullet Speed (visual only)
		Color(),				-- Bullet Color
		0.6,					-- Sight's FOV multiplier
		Vector(-10, 0, -20),	-- Sight Location
		Rotator(0, 0, 0),		-- Sight Rotation
		Vector(25, 0, 0),		-- Left Hand Location
		Rotator(0, 60, 90),		-- Left Hand Rotation
		Vector(-10, -5, -5),	-- Right Hand Offset
		HandlingMode.DoubleHandedWeapon,
		0.10,					-- Cadence
		false,					-- Can Hold Use (keep pressing to keep firing, common to automatic weapons)
		false,					-- Need to release to Fire (common to Bows)
		"",						-- Bullet Trail Particle
		"NanosWorld::P_DirectionalBurst",					-- Barrel Particle
		"",													-- Shells Particle
		"NanosWorld::A_Pistol_Dry",							-- Weapon's Dry Sound
		"NanosWorld::A_Pistol_Load",						-- Weapon's Load Sound
		"NanosWorld::A_Pistol_Unload",						-- Weapon's Unload Sound
		"NanosWorld::A_AimZoom",							-- Weapon's Zooming Sound
		"NanosWorld::A_Rattle",								-- Weapon's Aiming Sound
		"NanosWorld::A_Simulate_Start",						-- Weapon's Shot Sound
		"NanosWorld::AM_Mannequin_Reload_Pistol",			-- Character's Reloading Animation
		"NanosWorld::AM_Mannequin_Sight_Fire_Heavy",		-- Character's Aiming Animation
		"NanosWorld::SM_Glock_Mag_Empty",					-- Magazine Mesh
		CrosshairType.Dot
	)

	return tool_gun
end

-- todo fazer client igual, pra pegar ID
SpawnMenuItems = {}

-- Event for Spawning and Item from the SpawnMenu
Events:Subscribe("SpawnItem", function(player, asset_pack, category, asset, spawn_location, spawn_rotation)
	local character = player:GetControlledCharacter()

	local item = nil

	-- If spawning a Prop
	if (category == "props") then
		item = Prop(spawn_location + Vector(0, 0, 100), Rotator(0, spawn_rotation.Yaw + 180, 0), asset_pack .. "::" .. asset)
		item:SetNetworkAuthority(player)
	else
		if (not SpawnMenuItems[asset_pack] or not SpawnMenuItems[asset_pack][category] or not SpawnMenuItems[asset_pack][category][asset]) then
			Package:Error("Failed to find item to spawn: Asset Pack '%s'. Category '%s'. Asset '%s'.", asset_pack, category, asset)
			return
		end

		local spawn_menu_item = SpawnMenuItems[asset_pack][category][asset]

		-- If this has a spawn function, uses it, otherwise uses the Package Call method because it may have been created by another package
		if (spawn_menu_item.spawn_function) then
			item = spawn_menu_item.spawn_function(spawn_location, spawn_rotation)
		else
			item = Package:Call(spawn_menu_item.package_name, spawn_menu_item.package_function, {spawn_location, spawn_rotation})
		end

		if (category == "tools") then
			item:SetValue("ToolGun", asset, true)

			item:Subscribe("PickUp", function(weapon, char)
				Events:CallRemote("PickUpToolGun_" .. asset, char:GetPlayer(), {weapon, char})
			end)

			item:Subscribe("Drop", function(weapon, char)
				Events:CallRemote("DropToolGun_" .. asset, char:GetPlayer(), {weapon, char})
			end)
		end

		if (character) then
			if (category == "weapons" or category == "tools") then
				-- Destroys the current picked up item
				local current_picking_weapon = character:GetPicked()
				if (current_picking_weapon) then current_picking_weapon:Destroy() end

				character:PickUp(item)
			elseif (category == "vehicles") then
				character:EnterVehicle(item, 0)
			end
		end

	end

	-- Calls the client to update his history
	Events:CallRemote("SpawnedItem", player, {item})
end)

-- Helper to Destroy an Item
function DestroyItem(item)
	-- If this is a balloon, use the custom Balloon destroy function
	if (item:GetValue("Balloon")) then
		DestroyBalloon(item)
		return
	end

	-- If this item has a Particle, destroys it as well
	local particle = item:GetValue("Particle")
	if (particle) then particle:Destroy() end

	-- If this item has a Light, destroys it as well
	local light = item:GetValue("Light")
	if (light) then light:Destroy() end

	-- If this item has a Light, destroys it as well
	local bulb = item:GetValue("Bulb")
	if (bulb) then bulb:Destroy() end

	-- If this item has a Thruster attached, destroys it as well
	local thruster = item:GetValue("Thruster")
	if (thruster) then thruster:Destroy() end

	-- If this item has a Trail attached, destroys it as well
	local trail = item:GetValue("Trail")
	if (trail) then trail:Destroy() end

	-- Destroys the item itself
	item:Destroy()
end

-- Called by Client to destroy an spawned item 
Events:Subscribe("DestroyItem", function(player, item)
	-- Spawns some sounds and particles
	Events:BroadcastRemote("SpawnSound", {item:GetLocation(), "NanosWorld::A_Player_Eject", false, 0.3, 1})
	Particle(item:GetLocation() + Vector(0, 0, 30), Rotator(), "NanosWorld::P_OmnidirectionalBurst")

	DestroyItem(item)
end)

-- Function for Adding new Spawn Menu items
function AddSpawnMenuItem(asset_pack, category, id, spawn_function, package_name, package_function)
	if (not SpawnMenuItems[asset_pack]) then
		SpawnMenuItems[asset_pack] = {}
	end

	if (not SpawnMenuItems[asset_pack][category]) then
		SpawnMenuItems[asset_pack][category] = {}
	end

	Package:Log("Adding item '%s'. Category '%s'. Asset Pack '%s'. Package Function '%s'.", id, category, asset_pack, package_function)

	SpawnMenuItems[asset_pack][category][id] = {
		spawn_function = spawn_function,
		package_name = package_name,
		package_function = package_function,
	}
end

-- Exported functions cannot have functions as arguments, so we get the package name and package_function name and call it the proper way
Package:Export("AddSpawnMenuItem", function(asset_pack, category, id, package_name, package_function)
	AddSpawnMenuItem(asset_pack, category, id, nil, package_name, package_function)
end)

-- Adds the default NanosWorld items
Package:RequirePackage("NanosWorldWeapons")
Package:RequirePackage("NanosWorldVehicles")

-- Default Weapons
AddSpawnMenuItem("NanosWorld", "weapons", "AK47", NanosWorldWeapons.AK47)
AddSpawnMenuItem("NanosWorld", "weapons", "AK74U", NanosWorldWeapons.AK74U)
AddSpawnMenuItem("NanosWorld", "weapons", "AP5", NanosWorldWeapons.AP5)
AddSpawnMenuItem("NanosWorld", "weapons", "AR4", NanosWorldWeapons.AR4)
AddSpawnMenuItem("NanosWorld", "weapons", "GE36", NanosWorldWeapons.GE36)
AddSpawnMenuItem("NanosWorld", "weapons", "Glock", NanosWorldWeapons.Glock)
AddSpawnMenuItem("NanosWorld", "weapons", "DesertEagle", NanosWorldWeapons.DesertEagle)
AddSpawnMenuItem("NanosWorld", "weapons", "Moss500", NanosWorldWeapons.Moss500)
AddSpawnMenuItem("NanosWorld", "weapons", "SMG11", NanosWorldWeapons.SMG11)
AddSpawnMenuItem("NanosWorld", "weapons", "ASVal", NanosWorldWeapons.ASVal)
AddSpawnMenuItem("NanosWorld", "weapons", "Grenade", function(location, rotation) return Grenade(location, rotation, "NanosWorld::SM_Grenade_G67") end)

-- Default Vehicles
AddSpawnMenuItem("NanosWorld", "vehicles", "SUV", NanosWorldVehicles.SUV)
AddSpawnMenuItem("NanosWorld", "vehicles", "Hatchback", NanosWorldVehicles.Hatchback)
AddSpawnMenuItem("NanosWorld", "vehicles", "SportsCar", NanosWorldVehicles.SportsCar)
AddSpawnMenuItem("NanosWorld", "vehicles", "TruckBox", NanosWorldVehicles.TruckBox)
AddSpawnMenuItem("NanosWorld", "vehicles", "TruckChassis", NanosWorldVehicles.TruckChassis)
AddSpawnMenuItem("NanosWorld", "vehicles", "Pickup", NanosWorldVehicles.Pickup)

-- Default Tools
AddSpawnMenuItem("NanosWorld", "tools", "RemoverTool", function() return SpawnGenericToolGun(Vector(), Rotator(), Color.RED) end)

-- Requires all the Tools
Package:Require("Tools/Balloon.lua")
Package:Require("Tools/Color.lua")
Package:Require("Tools/Lamp.lua")
Package:Require("Tools/Light.lua")
Package:Require("Tools/PhysicsGun.lua")
Package:Require("Tools/Resizer.lua")
Package:Require("Tools/Rope.lua")
Package:Require("Tools/Thruster.lua")
Package:Require("Tools/Torch.lua")
Package:Require("Tools/Trail.lua")
Package:Require("Tools/Weld.lua")