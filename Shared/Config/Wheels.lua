-- List of wheels assets for Context Menu
WHEELS_ASSETS = {
	{ id = "nanos-world::SM_Offroad_Tire", name = "Offroad Tire", image = "assets://nanos-world/Thumbnails/SM_Offroad_Tire.jpg" },
	{ id = "nanos-world::SM_WheelBarrel_Wheel", name = "Wheel Barrel", image = "assets://nanos-world/Thumbnails/SM_WheelBarrel_Wheel.jpg" },
	{ id = "nanos-world::SM_RollerMachine_Wheel", name = "Roller Machine", image = "assets://nanos-world/Thumbnails/SM_RollerMachine_Wheel.jpg" },
	{ id = "nanos-world::SM_FidgetSpinner", name = "Fidget Spinner", image = "assets://nanos-world/Thumbnails/SM_FidgetSpinner.jpg" },
	{ id = "nanos-world::SM_PlasticBarrel_01", name = "Plastic Barrel", image = "assets://nanos-world/Thumbnails/SM_PlasticBarrel_01.jpg" },
	{ id = "nanos-world::SM_Steering_Wheel_01", name = "Steering Wheel", image = "assets://nanos-world/Thumbnails/SM_Steering_Wheel_01.jpg" },
	{ id = "nanos-world::SM_Valve", name = "Valve", image = "assets://nanos-world/Thumbnails/SM_Valve.jpg" },
}

-- List of wheels config
-- Note: we need at least 1 offset, so physics constraint can get the right direction
WHEELS_CONFIG = {
	["nanos-world::SM_Offroad_Tire"] = { offset = Vector(0, -20, 0), direction = Vector(0, -1, 0), },
	["nanos-world::SM_WheelBarrel_Wheel"] = { offset = Vector(0, -8, 0), direction = Vector(0, -1, 0), },
	["nanos-world::SM_RollerMachine_Wheel"] = { offset = Vector(0, 36, 0), direction = Vector(0, 1, 0), },
	["nanos-world::SM_FidgetSpinner"] = { offset = Vector(0, 8, 0), direction = Vector(0, 1, 0), },
	["nanos-world::SM_PlasticBarrel_01"] = { offset = Vector(0, 0, 1), direction = Vector(0, 0, -1), },
	["nanos-world::SM_Steering_Wheel_01"] = { offset = Vector(0, -11, 0), direction = Vector(0, -1, 0), },
	["nanos-world::SM_Valve"] = { offset = Vector(0, 1, 0), direction = Vector(0, -1, 0), scale = 10 },
}