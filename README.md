# nanos-world-sandbox
Default Sandbox nanos world package

How to integrate your own Tools and Weapons into the Sandbox Spawn Menu:

Client:

```lua
-- Waits 3 second so the Sandbox can be loaded first
Timer:SetTimeout(3000, function()
	-- Package:Call("Sandbox", "AddSpawnMenuItem", {"YOUR_CUSTOM_'PACK'_NAME", "CATEGORY", "TOOL_ID", "TOOL_LABEL", "IMAGE_PATH"})
	-- The category must be: 'props', 'weapons', 'tools' or 'vehicles'
	-- Example:

	-- Calls the Sandbox method to add my weapon to the SpawnMenu
	Package:Call("Sandbox", "AddSpawnMenuItem", {"AwesomeWeapons", "weapons", "BFG", "Big Fucking Gun", "../../../AwesomeWeapons/Client/SK_BFG.jpg"})
    return false
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

-- Waits 3 second so the Sandbox can be loaded first
Timer:SetTimeout(3000, function()
	-- Package:Call("Sandbox", "AddSpawnMenuItem", {"YOUR_CUSTOM_'PACK'_NAME", "CATEGORY", "TOOL_ID", "PACKAGE_PATH", "PACKAGE_FUNCTION_NAME"})
	-- The category must be: 'props', 'weapons', 'tools' or 'vehicles'
	-- Example:

	-- Calls the Sandbox method to add my weapon to the SpawnMenu
	Package:Call("Sandbox", "AddSpawnMenuItem", {"AwesomeWeapons", "weapons", "BFG", "awesome-weapons", "SpawnBFG"})
    return false
end)
```