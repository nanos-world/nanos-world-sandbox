# nanos-world-sandbox
Default Sandbox nanos world package

![image](https://user-images.githubusercontent.com/6226807/121760112-7d254d80-caff-11eb-968e-20f77aa3c7d3.png)

## How to create a Package which integrates your own Tools and Weapons into the Sandbox Spawn Menu

Note: All Assets from loaded Asset Packs are displayed automatically in the Spawn Menu!

To be able to display your own Item/Weapon/Entity in the Spawn Menu, you will need to declare it on both Client and Server:

### Client:

On the Client side, we will define how the Item will be displayed in the Spawn Menu, including it's label, tab, category and image.

```lua
Package.Subscribe("Load", function()
	-- Package.Call("sandbox", "AddSpawnMenuItem", "YOUR_CUSTOM_PACK_NAME", "TAB", "TOOL_ID", "TOOL_LABEL", "IMAGE_PATH", "CATEGORY")

	-- YOUR_CUSTOM_PACK_NAME: Name of your "Pack", just to identify to which "Pack" it belongs - not currently displayed
	-- TAB: The tab which the item will be displayed, it must be: 'props', 'weapons', 'tools' or 'vehicles'
	-- TOOL_ID: An unique identifier for your Item
	-- TOOL_LABEL: The Text which will be displayed in the Spawn Menu
	-- IMAGE_PATH: The Icon which will be displayed in the Spawn Menu
	-- CATEGORY: The category to display your item in the sidebar, currently valid categories are:
	--	Prop: 'basic', 'appliances', 'construction', 'furniture', 'funny', 'tools', 'food', 'street', 'nature' or 'uncategorized'
	--	Weapon: 'rifles', 'smgs', 'pistols', 'shotguns', 'sniper-rifles', 'special' or 'grenades'

	-- Example:
	-- Calls the sandbox method to add my weapon to the SpawnMenu
	Package.Call("sandbox", "AddSpawnMenuItem", "AwesomeWeapons", "weapons", "BFG", "Big Fucking Gun", "package///AwesomeWeapons/Client/SK_BFG.jpg")
	return false
end)

-- If you are making a tool, you can subscribe when your character picks up or drops the Tool
Events.Subscribe("PickUpToolGun_AwesomeTool", function(tool, character)
	GrabbedAwesomeTool(tool)
end)

Events.Subscribe("DropToolGun_AwesomeTool", function(tool, character)
	StopUsingAwesomeTool(false)
end)
```

### Server:

On the Server side, we will define how the item will be spawned, here we will create the "spawn function" for this item, and tell sandbox package which function it must call to be able to spawn it.

```lua
-- Create a function to spawn your weapon with location and rotation parameters
function SpawnBFG(location, rotation)
	local bfg = Weapon(location or Vector(), rotation or Rotator(), ...)

	return bfg
end

-- Exports the function to be called by the Sandbox 
Package.Export("SpawnBFG", SpawnBFG)

Package.Subscribe("Load", function()
	-- Package.Call("sandbox", "AddSpawnMenuItem", "YOUR_CUSTOM_PACK_NAME", "TAB", "TOOL_ID", "PACKAGE_PATH", "PACKAGE_FUNCTION_NAME")

	-- YOUR_CUSTOM_PACK_NAME: Name of your "Pack", just to identify to which "Pack" it belongs - not currently displayed
	-- TAB: The tab which the item will be displayed, it must be: 'props', 'weapons', 'tools' or 'vehicles'
	-- TOOL_ID: An unique identifier for your Item
	-- PACKAGE_PATH: The Package Path which this Item belongs
	-- PACKAGE_FUNCTION_NAME: The Exported Function to spawn the Item

	-- Example:
	-- Calls the sandbox method to add my weapon to the SpawnMenu
	Package.Call("sandbox", "AddSpawnMenuItem", "AwesomeWeapons", "weapons", "BFG", "awesome-weapons", "SpawnBFG")
	return false
end)
```


## Example of packages which exports Items to Spawn Menu

Those Packages can be loaded together Sandbox as well!

- https://github.com/nanos-world/nanos-world-quaternius
- https://github.com/gtnardy/nanos-world-ts-fireworks


![image](https://user-images.githubusercontent.com/6226807/121760136-9a5a1c00-caff-11eb-8478-9694135d1378.png)
