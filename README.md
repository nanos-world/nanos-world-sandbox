# nanos-world-sandbox
Default Sandbox nanos world package

How to create a Package which integrates your own Tools and Weapons into the Sandbox Spawn Menu:

Note: All Assets from Asset Packs are loaded automatically in the Spawn Menu!

Client:

```lua
-- Waits 100 ms so the Sandbox can be loaded first (this gonna be improved soon™)
Timer:SetTimeout(100, function()
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

-- Waits 100 ms so the Sandbox can be loaded first (this gonna be improved soon™)
Timer:SetTimeout(100, function()
	-- Package:Call("Sandbox", "AddSpawnMenuItem", {"YOUR_CUSTOM_'PACK'_NAME", "CATEGORY", "TOOL_ID", "PACKAGE_PATH", "PACKAGE_FUNCTION_NAME"})
	-- The category must be: 'props', 'weapons', 'tools' or 'vehicles'
	-- Example:

	-- Calls the Sandbox method to add my weapon to the SpawnMenu
	Package:Call("Sandbox", "AddSpawnMenuItem", {"AwesomeWeapons", "weapons", "BFG", "awesome-weapons", "SpawnBFG"})
	return false
end)
```
