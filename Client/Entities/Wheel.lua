Wheel = Prop.Inherit("Wheel")

-- List of wheels assets for Context Menu
Wheel.wheels_assets = {
	{ id = "nanos-world::SM_Offroad_Tire", name = "Offroad Tire", image = "assets://nanos-world/Thumbnails/SM_Offroad_Tire.jpg" },
	{ id = "nanos-world::SM_WheelBarrel_Wheel", name = "Wheel Barrel", image = "assets://nanos-world/Thumbnails/SM_WheelBarrel_Wheel.jpg" },
	{ id = "nanos-world::SM_RollerMachine_Wheel", name = "Roller Machine", image = "assets://nanos-world/Thumbnails/SM_RollerMachine_Wheel.jpg" },
	{ id = "nanos-world::SM_FidgetSpinner", name = "Fidget Spinner", image = "assets://nanos-world/Thumbnails/SM_FidgetSpinner.jpg" },
	{ id = "nanos-world::SM_PlasticBarrel_01", name = "Plastic Barrel", image = "assets://nanos-world/Thumbnails/SM_PlasticBarrel_01.jpg" },
	{ id = "nanos-world::SM_Steering_Wheel_01", name = "Steering Wheel", image = "assets://nanos-world/Thumbnails/SM_Steering_Wheel_01.jpg" },
}

-- List of wheels config
-- Note: we need at least 1 offset, so physics constraint can get the right direction
Wheel.wheels_config = {
	["nanos-world::SM_Offroad_Tire"] = { offset = Vector(0, -20, 0), direction = Vector(0, -1, 0), },
	["nanos-world::SM_WheelBarrel_Wheel"] = { offset = Vector(0, -7, 0), direction = Vector(0, -1, 0), },
	["nanos-world::SM_RollerMachine_Wheel"] = { offset = Vector(0, 35, 0), direction = Vector(0, 1, 0), },
	["nanos-world::SM_FidgetSpinner"] = { offset = Vector(0, 8, 0), direction = Vector(0, 1, 0), },
	["nanos-world::SM_PlasticBarrel_01"] = { offset = Vector(0, 0, 1), direction = Vector(0, 0, -1), },
	["nanos-world::SM_Steering_Wheel_01"] = { offset = Vector(0, -10, 0), direction = Vector(0, -1, 0), },
}

-- Context Menu Items when selecting this Entity
Wheel.selected_context_menu_items = {
	{
		label = "force",
		type = "range",
		min = 0,
		max = 10000,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetCustomAngularForce", value * 1000)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("AngularForce") / 1000
		end,
	},
	{
		label = "is active",
		type = "checkbox",
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetActive", value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Active")
		end
	},
	{
		label = "is reversed",
		type = "checkbox",
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetDirection", not value)
		end,
		value = function()
			return not ContextMenu.selected_entity:GetValue("Forward")
		end
	},
}

-- Input Bindings for this Entity
Wheel.input_bindings = {
	{
		label = "accelerate",
		callback_pressed = function(entity)
			-- Note: if we press the accelerate then reverse, then release accelerate, it will stop moving
			entity:CallRemoteEvent("SetActive", true)
		end,
		callback_released = function(entity)
			entity:CallRemoteEvent("SetActive", false)
		end,
	},
	{
		label = "reverse",
		callback_pressed = function(entity)
			entity:CallRemoteEvent("SetActive", true, true)
		end,
		callback_released = function(entity)
			entity:CallRemoteEvent("SetActive", false)
		end,
	},
	{
		label = "toggle",
		callback_pressed = function(entity)
			entity:CallRemoteEvent("SetActive", not entity:GetValue("Active"))
		end,
	},
}