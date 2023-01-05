# nanos-world-sandbox

Default Sandbox nanos world package

![image](https://user-images.githubusercontent.com/6226807/121760112-7d254d80-caff-11eb-968e-20f77aa3c7d3.png)


## Exported Functions

The Sandbox game-mode exports the following functions to the global scope:


### AddNotification (client side)

```lua
-- Adds a Notification in the screen
---@param id string         Unique ID used to store if the notification was already displayed to the player
---@param message string    The message to display
---@param time number       Duration of the notification
---@param delay number      Time to wait until display the notification
---@param force? boolean    To force it to be displayed regardless if it was already displayed before
function AddNotification(id, message, time, delay, force)
```

Example:

```lua
-- Displays the message 'playing with friends is much more fun!' after 10 seconds, for 5 seconds
AddNotification("FRIENDS", "playing with friends is much more fun!", 5000, 10000)
```


### UpdateLocalCharacter (client side)

```lua
-- Function to set all needed events on local character (to update the UI when it takes damage or dies)
---@param character Character
function UpdateLocalCharacter(character)
```


### SpawnMenu.AddItem (client side)

On the Client side, we will define how the Item will be displayed in the Spawn Menu, including it's label, tab, category, image and tutorials.

*Note: you must call SpawnMenu.AddItem from both client and server side. Each side has it's own parameters.*

```lua
-- Adds a new item to the Spawn Menu
---@param tab_id string         The tab to display this item
---@param id string             Unique ID used to identify this item
---@param name string           Display name
---@param image string          Image path
---@param category_id? string   The category of this item
function SpawnMenu.AddItem(tab_id, id, name, image, category_id?)
```

The built-in tabs are: 'props', 'weapons', 'tools', 'vehicles' or 'npcs'.

The built-in categories for each tab are:
- Tab **props**: 'basic', 'appliances', 'construction', 'furniture', 'funny', 'tools', 'food', 'street', 'nature' or 'uncategorized'
- Tab **weapons**: 'rifles', 'smgs', 'pistols', 'shotguns', 'sniper-rifles', 'special' or 'grenades'


Example:

```lua
-- Adds an Incredible Tool to spawn Menu (client side)
SpawnMenu.AddItem(
    "tools",
    "IncredibleTool",
    "Incredible Tool",
    "assets://NanosWorld/Thumbnails/SK_Blaster.jpg",
    nil
)
```


### SpawnMenu.AddItem (server side)

On the Server side, we will define how the item will be spawned, here we will create the "spawn function" for this item, and tell sandbox package which function it must call to be able to spawn it.

*Note: you must call SpawnMenu.AddItem from both client and server side. Each side has it's own parameters.*

```lua
-- Adds a new item to the Spawn Menu
---@param tab string                Tab of this item
---@param id string                 Unique ID used to identify this item
---@param spawn_function function	Spawn function
function SpawnMenu.AddItem(tab, id, spawn_function)
```

Example:

```lua
-- Function which spawns an entity
-- The parameters location, rotation, tab and id will be passed automatically by the caller
function SpawnMyIncredibleEntity(location, rotation, tab, id)
    local my_stuff = MyEntity(location, rotation)

    -- configure stuff...

    return my_stuff
end

Package.Subscribe("Load", function()
    -- Adds this to spawn Menu (server side)
   	SpawnMenu.AddItem("tools", "IncredibleEntity", SpawnMyIncredibleEntity)
end)
```


### SpawnMenu.AddTab (client side)

Adds a new tab to the Spawn Menu

```lua
---@param id string                Unique ID used to identify the tab
---@param name string              Label of the tab
---@param image_active string      Image path when the tab is selected
---@param image_inactive string    Image path when the tab is not selected
function SpawnMenu.AddTab(id, name, image_active, image_inactive)
```

Example:

```lua
Package.Subscribe("Load", function()
    -- Adds a new tab
    SpawnMenu.AddTab(
        "consumables",
        "consumables",
        "packages///my-package/food.png",
        "packages///my-package/food_inactive.png"
    )
end)
```


### SpawnMenu.AddCategory (client side)

Adds a new category to a Spawn Menu Tab

```lua
---@param tab_id string                Tab ID
---@param id string                    Unique ID used to identify the category
---@param label string                 Label of the tab
---@param image_active string          Image path when the category is selected
---@param image_inactive string        Image path when the category is not selected
function SpawnMenu.AddCategory(tab_id, id, label, image_active, image_inactive)
```

Example:

```lua
Package.Subscribe("Load", function()
    -- Adds a new category to Props tab
    SpawnMenu.AddCategory(
        "props",
        "low-poly",
        "low poly",
        "packages///my-package/low-poly.png",
        "packages///my-package/low-poly_inactive.png"
    )

    -- Adds a new category to Weapons tab
    SpawnMenu.AddCategory(
        "weapons",
        "world-war",
        "world war",
        "packages///my-package/ww.png",
        "packages///my-package/ww_inactive.png"
    )
end)
```


## Events

Also the Sandbox game-mode have the following events:


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

Those Packages can be loaded together Sandbox and the item will show up in the Spawn Menu!

- https://github.com/gtnardy/nanos-world-ts-fireworks


![image](https://user-images.githubusercontent.com/6226807/121760136-9a5a1c00-caff-11eb-8478-9694135d1378.png)
