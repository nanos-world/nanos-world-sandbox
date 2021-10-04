-- Function to spawn the ToolGun weapon
function SpawnGenericToolGun(location, rotation, color)
	local tool_gun = Weapon(location or Vector(), rotation or Rotator(), "nanos-world::SK_Blaster")

	tool_gun:SetAmmoSettings(10000000, 0)
	tool_gun:SetDamage(0)
	tool_gun:SetSpread(0)
	tool_gun:SetRecoil(0)
	tool_gun:SetSightTransform(Vector(0, 0, -3.2), Rotator(0, 0, 0))
	tool_gun:SetLeftHandTransform(Vector(-1, 1, -2), Rotator(0, 60, 100))
	tool_gun:SetRightHandOffset(Vector(-25, -5, 0))
	tool_gun:SetHandlingMode(HandlingMode.SingleHandedWeapon)
	tool_gun:SetCadence(0.1)
	tool_gun:SetSoundDry("nanos-world::A_Pistol_Dry")
	tool_gun:SetSoundZooming("nanos-world::A_AimZoom")
	tool_gun:SetSoundAim("nanos-world::A_Rattle")
	tool_gun:SetSoundFire("nanos-world::A_Simulate_Start")
	tool_gun:SetParticlesBarrel("nanos-world::P_Weapon_BarrelSmoke")
	tool_gun:SetAnimationCharacterFire("nanos-world::A_Mannequin_Sight_Fire_Pistol")
	tool_gun:SetCrosshairMaterial("nanos-world::MI_Crosshair_Dot")
	tool_gun:SetUsageSettings(false, false)

	tool_gun:SetValue("Color", color, true)
	tool_gun:SetMaterialColorParameter("Emissive", color * 500)

	return tool_gun
end

SpawnMenuItems = {}

-- Event for Spawning and Item from the SpawnMenu
Events.Subscribe("SpawnItem", function(player, asset_pack, category, asset, spawn_location, spawn_rotation, selected_option)
	local character = player:GetControlledCharacter()

	local item = nil

	if (category == "vehicles") then
		spawn_location = character:GetLocation() + Vector(0, 0, 100)
		spawn_rotation = character:GetRotation()
	end

	-- If spawning a Prop
	if (category == "props") then
		local asset_path = asset_pack .. "::" .. asset

		item = Prop(spawn_location + Vector(0, 0, 50), Rotator(0, spawn_rotation.Yaw + 180, 0), asset_path)

		-- If this Prop is a Breakable Prop, setup it (we only configure Props from Spawn Menu to break*)
		if (BreakableProps[asset_path]) then
			SetupBreakableProp(item)
		end
	else
		if (not SpawnMenuItems[asset_pack] or not SpawnMenuItems[asset_pack][category] or not SpawnMenuItems[asset_pack][category][asset]) then
			Package.Error("Failed to find item to spawn: Asset Pack '%s'. Category '%s'. Asset '%s'.", asset_pack, category, asset)
			return
		end

		local spawn_menu_item = SpawnMenuItems[asset_pack][category][asset]

		-- If this has a spawn function, uses it, otherwise uses the Package Call method because it may have been created by another package
		if (spawn_menu_item.spawn_function) then
			item = spawn_menu_item.spawn_function(spawn_location, spawn_rotation, asset_pack, category, asset)
		else
			item = Package.Call(spawn_menu_item.package_name, spawn_menu_item.package_function, spawn_location, spawn_rotation, asset_pack, category, asset)
		end

		if (category == "tools") then
			item:SetValue("ToolGun", asset, true)

			item:Subscribe("PickUp", function(weapon, char)
				Events.CallRemote("PickUpToolGun_" .. asset, char:GetPlayer(), weapon, char)
			end)

			item:Subscribe("Drop", function(weapon, char)
				Events.CallRemote("DropToolGun_" .. asset, char:GetPlayer(), weapon, char)
			end)
		end

		if (character) then
			if (category == "weapons" or category == "tools") then
				-- Stores the old Aim Mode
				local current_aiming_mode = character:GetWeaponAimMode()
				local current_picking_weapon = character:GetPicked()

				-- Destroys the current picked up item
				if (current_picking_weapon) then current_picking_weapon:Destroy() end

				character:PickUp(item)

				-- If has previous Aim Mode, sets it again after some small delay
				if (current_aiming_mode ~= AimMode.None) then
					Timer.SetTimeout(function(c, am)
						c:SetWeaponAimMode(am)
					end, 150, character, current_aiming_mode)
				end

				-- workaround
				if (selected_option ~= "") then
					ApplyWeaponPattern(item, selected_option)
				end
			elseif (category == "vehicles") then
				character:EnterVehicle(item, 0)
			end
		end
	end

	-- Calls the client to update his history
	Events.CallRemote("SpawnedItem", player, item)
end)

-- Called by Client to destroy an spawned item 
Events.Subscribe("DestroyItem", function(player, item)
	-- Spawns some sounds and particles
	Events.BroadcastRemote("SpawnSound", item:GetLocation(), "nanos-world::A_Player_Eject", false, 0.3, 1)
	Particle(item:GetLocation() + Vector(0, 0, 30), Rotator(), "nanos-world::P_OmnidirectionalBurst")

	-- Destroy the item
	item:Destroy()
end)

-- Function for Adding new Spawn Menu items
function AddSpawnMenuItem(asset_pack, category, id, spawn_function, package_name, package_function)
	if (not SpawnMenuItems[asset_pack]) then
		SpawnMenuItems[asset_pack] = {}
	end

	if (not SpawnMenuItems[asset_pack][category]) then
		SpawnMenuItems[asset_pack][category] = {}
	end

	SpawnMenuItems[asset_pack][category][id] = {
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

Events.Subscribe("ApplyWeaponPattern", function(player, weapon, pattern_texture)
	ApplyWeaponPattern(weapon, pattern_texture)
end)

-- Exported functions cannot have functions as arguments, so we get the package name and package_function name and call it the proper way
Package.Export("AddSpawnMenuItem", function(asset_pack, category, id, package_name, package_function)
	AddSpawnMenuItem(asset_pack, category, id, nil, package_name, package_function)
end)

-- Adds the default NanosWorld items
Package.RequirePackage("nanos-world-weapons")
Package.RequirePackage("nanos-world-vehicles")

-- Default Weapons
AddSpawnMenuItem("nanos-world", "weapons", "AK47", NanosWorldWeapons.AK47)
AddSpawnMenuItem("nanos-world", "weapons", "AK74U", NanosWorldWeapons.AK74U)
AddSpawnMenuItem("nanos-world", "weapons", "AP5", NanosWorldWeapons.AP5)
AddSpawnMenuItem("nanos-world", "weapons", "AR4", NanosWorldWeapons.AR4)
AddSpawnMenuItem("nanos-world", "weapons", "GE36", NanosWorldWeapons.GE36)
AddSpawnMenuItem("nanos-world", "weapons", "Glock", NanosWorldWeapons.Glock)
AddSpawnMenuItem("nanos-world", "weapons", "Makarov", NanosWorldWeapons.Makarov)
AddSpawnMenuItem("nanos-world", "weapons", "UMP45", NanosWorldWeapons.UMP45)
AddSpawnMenuItem("nanos-world", "weapons", "M1911", NanosWorldWeapons.M1911)
AddSpawnMenuItem("nanos-world", "weapons", "GE3", NanosWorldWeapons.GE3)
AddSpawnMenuItem("nanos-world", "weapons", "AK5C", NanosWorldWeapons.AK5C)
AddSpawnMenuItem("nanos-world", "weapons", "DesertEagle", NanosWorldWeapons.DesertEagle)
AddSpawnMenuItem("nanos-world", "weapons", "Moss500", NanosWorldWeapons.Moss500)
AddSpawnMenuItem("nanos-world", "weapons", "SMG11", NanosWorldWeapons.SMG11)
AddSpawnMenuItem("nanos-world", "weapons", "ASVal", NanosWorldWeapons.ASVal)
AddSpawnMenuItem("nanos-world", "weapons", "Ithaca37", NanosWorldWeapons.Ithaca37)
AddSpawnMenuItem("nanos-world", "weapons", "Rem870", NanosWorldWeapons.Rem870)
AddSpawnMenuItem("nanos-world", "weapons", "P90", NanosWorldWeapons.P90)
AddSpawnMenuItem("nanos-world", "weapons", "SPAS12", NanosWorldWeapons.SPAS12)
AddSpawnMenuItem("nanos-world", "weapons", "SA80", NanosWorldWeapons.SA80)
AddSpawnMenuItem("nanos-world", "weapons", "AWP", NanosWorldWeapons.AWP)
AddSpawnMenuItem("nanos-world", "weapons", "Grenade", function(location, rotation) return Grenade(location, rotation, "nanos-world::SM_Grenade_G67") end)

-- Default Vehicles
AddSpawnMenuItem("nanos-world", "vehicles", "SUV", NanosWorldVehicles.SUV)
AddSpawnMenuItem("nanos-world", "vehicles", "Hatchback", NanosWorldVehicles.Hatchback)
AddSpawnMenuItem("nanos-world", "vehicles", "SportsCar", NanosWorldVehicles.SportsCar)
AddSpawnMenuItem("nanos-world", "vehicles", "TruckBox", NanosWorldVehicles.TruckBox)
AddSpawnMenuItem("nanos-world", "vehicles", "TruckChassis", NanosWorldVehicles.TruckChassis)
AddSpawnMenuItem("nanos-world", "vehicles", "Pickup", NanosWorldVehicles.Pickup)

-- Default Tools
AddSpawnMenuItem("nanos-world", "tools", "RemoverTool", function() return SpawnGenericToolGun(Vector(), Rotator(), Color.RED) end)

-- Requires all the Tools
Package.Require("Tools/Balloon.lua")
Package.Require("Tools/Color.lua")
Package.Require("Tools/Lamp.lua")
Package.Require("Tools/Light.lua")
Package.Require("Tools/PhysicsGun.lua")
Package.Require("Tools/Resizer.lua")
Package.Require("Tools/Rope.lua")
Package.Require("Tools/Thruster.lua")
Package.Require("Tools/Torch.lua")
Package.Require("Tools/Trail.lua")
Package.Require("Tools/Weld.lua")

-- Extra
Package.Require("NPC.lua")
Package.Require("Weapons/HFG.lua")
Package.Require("Weapons/VeggieGun.lua")
Package.Require("Entities/Breakable.lua")