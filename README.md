# nanos-world-sandbox

Default Sandbox nanos world package

![image](https://user-images.githubusercontent.com/6226807/121760112-7d254d80-caff-11eb-968e-20f77aa3c7d3.png)


## Exported Functions

The Sandbox game-mode exports the following functions, which can be called like:

```lua
Package.Call("sandbox", "FunctionName", param1, param2, param3...)
```

### AddNotification (client side)

```lua
-- Adds a Notification in the screen
---@param id string			Unique ID used to store if the notification was already displayed to the player
---@param message string	The message to display
---@param time number		Duration of the notification
---@param delay number		Time to wait until display the notification
---@param force? boolean	To force it to be displayed regardless if it was already displayed before
function AddNotification(id, message, time, delay, force)
```

Example:

```lua
-- Displays the message 'playing with friends is much more fun!' after 10 seconds, for 5 seconds
Package.Call("sandbox", "AddNotification", "FRIENDS", "playing with friends is much more fun!", 5000, 10000)
```


### UpdateLocalCharacter (client side)

```lua
-- Function to set all needed events on local character (to update the UI when it takes damage or dies)
---@param character Character
function UpdateLocalCharacter(character)
```


### AddSpawnMenuItem (client side)

On the Client side, we will define how the Item will be displayed in the Spawn Menu, including it's label, tab, category, image and tutorials.

*Note: you must call AddSpawnMenuItem from both client and server side. Each side has it's own parameters.*

```lua
-- Adds a new item to the Spawn Menu
---@param group string			Unique ID used to identify from which 'group' it belongs
---@param tab string			The tab to display this item - it must be 'props', 'weapons', 'tools' or 'vehicles'
---@param id string				Unique ID used to identify this item
---@param name string			Display name
---@param image string			Image path
---@param category string		The category of this item, each tab has it's own set of categories (Prop: 'basic', 'appliances', 'construction', 'furniture', 'funny', 'tools', 'food', 'street', 'nature' or 'uncategorized'. Weapon: 'rifles', 'smgs', 'pistols', 'shotguns', 'sniper-rifles', 'special' or 'grenades')
---@param tutorials table		List of tutorials to display in the top left screen, in the format: { { key = 'KeyName', text = 'description of the action' }, ... }
function AddSpawnMenuItem(group, tab, id, name, image, category, tutorials)
```

Example:

```lua
-- Adds an Incredible Tool to spawn Menu (client side)
Package.Call("sandbox", "AddSpawnMenuItem", "my-package", "tools", "IncredibleTool", "Incredible Tool", "assets///NanosWorld/Thumbnails/SK_Blaster.jpg", nil, {
	{ key = "LeftClick", text = "do amazing stuff" },
	{ key = "E", text = "activate power" },
})
```


### AddSpawnMenuItem (server side)

On the Server side, we will define how the item will be spawned, here we will create the "spawn function" for this item, and tell sandbox package which function it must call to be able to spawn it.

*Note: you must call AddSpawnMenuItem from both client and server side. Each side has it's own parameters.*

```lua
-- Adds a new item to the Spawn Menu
---@param group string				Unique ID used to identify from which 'group' it belongs
---@param tab string				Tab of this item
---@param id string					Unique ID used to identify this item
---@param package_name string		Your package name which will be used to call your spawn function
---@param package_function table	The exported Spawn Function name which will be called from sandbox
function AddSpawnMenuItem(group, tab, id, package_name, package_function)
```

Example:

```lua
-- Function which spawns the tool, the parameters location, rotation, group, tab and id will be passed automatically by the caller
function SpawnMyIncredibleTool(location, rotation, group, tab, id)
	local weapon = Weapon(location, rotation)

	-- ...
	-- configure stuff

	return weapon
end

-- Exports the function to be called by the Sandbox package
Package.Export("SpawnMyIncredibleTool", SpawnMyIncredibleTool)

Package.Subscribe("Load", function()
	-- Adds an Incredible Tool to spawn Menu (server side)
	Package.Call("sandbox", "AddSpawnMenuItem", "my-package", "tools", "IncredibleTool", SpawnMyIncredibleTool)
end)
```


### AddSpawnMenuTab (client side)

Adds a new tab to the Spawn Menu

```lua
---@param id string					Unique ID used to identify the tab
---@param name string				Label of the tab
---@param image_active string		Image path when the tab is selected
---@param image_inactive string		Image path when the tab is not selected
function AddSpawnMenuTab(id, name, image_active, image_inactive)
```

Example:

```lua
Package.Subscribe("Load", function()
	-- Adds a new tab
	Package.Call("sandbox", "AddSpawnMenuTab", "consumables", "consumables", "packages///my-package/food.png", "packages///my-package/food_inactive.png")
end)
```


### AddSpawnMenuCategory (client side)

Adds a new category to a Spawn Menu Tab

```lua
---@param tab_id string				Tab ID
---@param id string					Unique ID used to identify the category
---@param label string				Label of the tab
---@param image_active string		Image path when the category is selected
---@param image_inactive string		Image path when the category is not selected
function AddSpawnMenuCategory(tab_id, id, label, image_active, image_inactive)
```

Example:

```lua
Package.Subscribe("Load", function()
	-- Adds a new category to Props tab
	Package.Call("sandbox", "AddSpawnMenuCategory", "props", "low-poly", "low poly", "packages///my-package/low-poly.png", "packages///my-package/low-poly_inactive.png")

	-- Adds a new category to Weapons tab
	Package.Call("sandbox", "AddSpawnMenuCategory", "weapons", "world-war", "world war", "packages///my-package/ww.png", "packages///my-package/ww_inactive.png")
end)
```


## Events

Also the Sandbox game-mode have the following events:


### PickUpToolGun (client side)

This is called on client side when you pick up a tool gun (spawned from Spawn Menu)

Example:

```lua
Events.Subscribe("PickUpToolGun_", id, weapon, character)
	-- do something with the tool
end
```


### DropToolGun (client side)

This is called on client side when you drop a tool gun (spawned from Spawn Menu)

Example:

```lua
Events.Subscribe("DropToolGun", id, weapon, character)
	-- do something with the tool
end
```


### PickUpToolGun_[ID] (client side)

This is like PickUpToolGun, but specific for an tool, replace [ID] with the ID of your tool

Example:

```lua
Events.Subscribe("PickUpToolGun_IncredibleTool", id, weapon, character)
	-- do something with the Incredible Tool
end
```


### DropToolGun_[ID] (client side)

This is like DropToolGun, but specific for an tool, replace [ID] with the ID of your tool

Example:

```lua
Events.Subscribe("DropToolGun_IncredibleTool", id, weapon, character)
	-- do something with the Incredible Tool
end
```


### SpawnSound (client side)

You can call it from server side to spawn a sound

```lua
Events.BroadcastRemote("SpawnSound", location, sound_asset, is_2D, volume, pitch)
```

### SpawnSoundAttached (client side)

You can call it from server side to spawn a sound attached

```lua
Events.BroadcastRemote("SpawnSoundAttached", actor, sound_asset, is_2D, volume, pitch)
```


## Example of packages which exports Items to Spawn Menu

Those Packages can be loaded together Sandbox as well!

- https://github.com/nanos-world/nanos-world-quaternius
- https://github.com/gtnardy/nanos-world-ts-fireworks


![image](https://user-images.githubusercontent.com/6226807/121760136-9a5a1c00-caff-11eb-8478-9694135d1378.png)
