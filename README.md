# nanos-world-sandbox
Default Sandbox nanos world package

![image](https://user-images.githubusercontent.com/6226807/121760112-7d254d80-caff-11eb-968e-20f77aa3c7d3.png)

How to create a Package which integrates your own Tools and Weapons into the Sandbox Spawn Menu:

Note: All Assets from Asset Packs are loaded automatically in the Spawn Menu!

Client:

```lua
Package:Subscribe("Load", function()
	-- Package:Call("Sandbox", "AddSpawnMenuItem", {"YOUR_CUSTOM_'PACK'_NAME", "CATEGORY", "TOOL_ID", "TOOL_LABEL", "IMAGE_PATH"})
	-- The category must be: 'props', 'weapons', 'tools' or 'vehicles'
	-- Example:

	-- Calls the Sandbox method to add my weapon to the SpawnMenu
	Package:Call("Sandbox", "AddSpawnMenuItem", {"AwesomeWeapons", "weapons", "BFG", "Big Fucking Gun", "package///AwesomeWeapons/Client/SK_BFG.jpg"})
	return false
end)

-- If you are making a tool, you can subscribe when your character picks up or drops the Tool
Events:Subscribe("PickUpToolGun_AwesomeTool", function(tool, character)
	GrabbedAwesomeTool(tool)
end)

Events:Subscribe("DropToolGun_AwesomeTool", function(tool, character)
	StopUsingAwesomeTool(false)
end)
```

Server:

```lua
-- Create a function to spawn your weapon with location and rotation parameters
function SpawnBFG(location, rotation)
	local bfg = Weapon(location or Vector(), rotation or Rotator(), ...)

	return bfg
end

-- Exports the function to be called by the Sandbox 
Package:Export("SpawnBFG", SpawnBFG)

Package:Subscribe("Load", function()
	-- Package:Call("Sandbox", "AddSpawnMenuItem", {"YOUR_CUSTOM_'PACK'_NAME", "CATEGORY", "TOOL_ID", "PACKAGE_PATH", "PACKAGE_FUNCTION_NAME"})
	-- The category must be: 'props', 'weapons', 'tools' or 'vehicles'
	-- Example:

	-- Calls the Sandbox method to add my weapon to the SpawnMenu
	Package:Call("Sandbox", "AddSpawnMenuItem", {"AwesomeWeapons", "weapons", "BFG", "awesome-weapons", "SpawnBFG"})
	return false
end)
```

![image](https://user-images.githubusercontent.com/6226807/121760136-9a5a1c00-caff-11eb-8478-9694135d1378.png)
