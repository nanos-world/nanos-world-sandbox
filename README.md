# nanos-world-sandbox

Default Sandbox nanos world package

![image](https://user-images.githubusercontent.com/6226807/121760112-7d254d80-caff-11eb-968e-20f77aa3c7d3.png)


Please refer to the [Official Sandbox Documentation Page](https://docs.nanos.world/docs/next/explore/sandbox-game-mode/spawn-menu) for more information on how to customize and make use of this package.


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
