Flashlight = Prop.Inherit("Flashlight")

Flashlight.name = "Flashlight"
Flashlight.image = "assets://nanos-world/Thumbnails/SM_Flashlight.jpg"
Flashlight.category = "uncategorized"

CURRENTLY_GRABBED_FLASHLIGHT = nil

function Flashlight:OnToggle()
	CURRENTLY_GRABBED_FLASHLIGHT:CallRemoteEvent("ToggleLight")
end

function Flashlight:OnGrab(character)
	CURRENTLY_GRABBED_FLASHLIGHT = self

	-- Binds the Input
	Input.Bind("Flashlight", InputEvent.Pressed, Flashlight.OnToggle)

	-- Adds tutorial on screen
	MainHUD:CallEvent("ToggleTutorial", true, "Flashlight", {
		{ image = Input.GetKeyIcon(Input.GetMappedKeys("Flashlight")[1]), text = "turns on/off the flashlight" }
	})
end

function Flashlight:OnUnGrab(character)
	CURRENTLY_GRABBED_FLASHLIGHT = nil

	-- Unbinds from Input
	Input.Unbind("Flashlight", InputEvent.Pressed, Flashlight.OnToggle)

	-- Removes tutorial from screen
	MainHUD:CallEvent("ToggleTutorial", false)
end

Flashlight.Subscribe("Grab", Flashlight.OnGrab)
Flashlight.Subscribe("UnGrab", Flashlight.OnUnGrab)

-- Registers the Input
Input.Register("Flashlight", "L", "Turns on/off the Flashlight")