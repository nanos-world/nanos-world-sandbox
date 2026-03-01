PukeGun = Weapon.Inherit("PukeGun", {
	tab = "tools", -- Overrides the tab (so it won't get at 'weapons' tab)
})

-- To define custom options to puke
PukeGun.options = {}

function PukeGun:Constructor(location, rotation)
	self.Super:Constructor(location or Vector(), rotation or Rotator(), "nanos-world::SK_FlareGun")

	self:SetAmmoSettings(9999, 0)
	self:SetDamage(0)
	self:SetRecoil(0)
	self:SetSightTransform(Vector(0, 0, -4), Rotator(0, 0, 0))
	self:SetLeftHandTransform(Vector(0, 1, -5), Rotator(0, 60, 100))
	self:SetRightHandOffset(Vector(-25, -5, 0))
	self:SetHandlingMode(HandlingMode.SingleHandedWeapon)
	self:SetCadence(0.1)
	self:SetSoundDry("nanos-world::A_Pistol_Dry")
	self:SetSoundZooming("nanos-world::A_AimZoom")
	self:SetSoundAim("nanos-world::A_Rattle")
	self:SetSoundFire("nanos-world::A_Whoosh")
	self:SetAnimationCharacterFire("nanos-world::A_Mannequin_Sight_Fire_Pistol")
	self:SetCrosshairMaterial("nanos-world::MI_Crosshair_Square")
	self:SetUsageSettings(true, false)
end

function PukeGun:OnFire(character)
	local control_rotation = character:GetControlRotation()
	local forward_vector = control_rotation:GetForwardVector()
	local spawn_location = self:GetLocation() + Vector(0, 0, 15) + forward_vector * 50

	local option = self:GetValue("Option") or "veggies"
	local force = self:GetValue("Force") or 3000

	local spawner = PukeGun.options[option]
	if (not spawner) then
		Console.Error("Invalid puke option: " .. option)
		return
	end

	local prop = spawner(spawn_location, self:GetRotation())

	prop:AddImpulse(forward_vector * force, true)
end

function PukeGun:OnSetOption(player, option)
	self:SetValue("Option", option, true)
end

function PukeGun:OnSetForce(player, force)
	self:SetValue("Force", force, true)
end

function PukeGun:OnSetCadence(player, cadence)
	self:SetCadence(cadence)
end

PukeGun.Subscribe("Fire", PukeGun.OnFire)
PukeGun.SubscribeRemote("SetOption", PukeGun.OnSetOption)
PukeGun.SubscribeRemote("SetCustomForce", PukeGun.OnSetForce)
PukeGun.SubscribeRemote("SetCadence", PukeGun.OnSetCadence)


-- Custom Options
PukeGun.options.veggies = function(spawn_location)
	local mesh = PukeGun.veggies[math.random(#PukeGun.veggies)]

	local prop = Prop(spawn_location, Rotator.Random(), mesh, CollisionType.Auto, true, GrabMode.Disabled, CCDMode.Auto)
	prop:SetScale(Vector(2, 2, 2))
	prop:SetValue("DebrisLifeSpan", 2)
	prop:SetLifeSpan(5)

	SetupBreakableProp(prop)

	return prop
end

PukeGun.options.bouncy_balls = function(spawn_location)
	local bouncy_ball = BouncyBall(spawn_location, Rotator())
	bouncy_ball:SetLifeSpan(10)
	return bouncy_ball
end

PukeGun.options.watermelons = function(spawn_location)
	local mesh = "nanos-world::SM_Fruit_Watermelon_01"

	local prop = Prop(spawn_location, Rotator.Random(), mesh, CollisionType.Auto, true, GrabMode.Disabled, CCDMode.Disabled)
	prop:SetScale(Vector(2, 2, 2))
	prop:SetValue("DebrisLifeSpan", 2)
	prop:SetLifeSpan(5)

	SetupBreakableProp(prop)

	return prop
end

PukeGun.options.trash_bags = function(spawn_location)
	local mesh = "nanos-world::SM_Trash_01"

	local prop = Prop(spawn_location, Rotator.Random(true), mesh, CollisionType.Auto, true, GrabMode.Disabled, CCDMode.Disabled)
	prop:SetScale(Vector(1.5, 1.5, 1.5))
	prop:SetValue("DebrisLifeSpan", 2)
	prop:SetLifeSpan(5)

	SetupBreakableProp(prop)

	return prop
end

PukeGun.options.balloons = function(spawn_location)
	local balloon = Balloon(spawn_location, Rotator.Random(true))
	balloon:SetLifeSpan(30)
	return balloon
end

PukeGun.options.propane_tanks = function(spawn_location, spawn_rotation)
	local mesh = PukeGun.propane_tanks[math.random(#PukeGun.propane_tanks)]

	local rotation = (spawn_rotation:Quaternion() * Rotator(-90, 0, 0):Quaternion()):Rotator()
	local prop = Prop(spawn_location, rotation, mesh, CollisionType.Auto, true, GrabMode.Disabled, CCDMode.Disabled)

	SetupBreakableProp(prop)
	InflameProp(prop)

	return prop
end

PukeGun.options.tycoon = function(spawn_location)
	local mesh = PukeGun.tycoon[math.random(#PukeGun.tycoon)]

	local prop = Prop(spawn_location, Rotator.Random(), mesh, CollisionType.Auto, true, GrabMode.Disabled, CCDMode.Auto)
	prop:SetLifeSpan(5)

	return prop
end

PukeGun.options.ragdolls = function(spawn_location)
	local character = Character(spawn_location, Rotator.Random(), "nanos-world::SK_Male", CollisionType.StaticOnly)
	character:SetLifeSpan(5)

	-- Delay a little due an issue when setting ragdoll just after spawned, not making it to apply the impulse
	Timer.SetTimeout(function ()
		character:SetRagdollMode(true)
	end, 100)

	return character
end


PukeGun.tycoon = {
	"nanos-world::SM_MoneyStack",
	"nanos-world::SM_MoneyRoll",
}

PukeGun.propane_tanks = {
	"nanos-world::SM_PropaneTank_01",
	"nanos-world::SM_PropaneTank_02",
}

PukeGun.veggies = {
	"nanos-world::SM_Fruit_Watermelon_01",
	"nanos-world::SM_Fruit_Cantaloupe_01",
	"nanos-world::SM_Fruit_Plum_01",
	"nanos-world::SM_Fruit_Mango_01",
	"nanos-world::SM_Fruit_Lemon_01",
	"nanos-world::SM_Fruit_Squash_01",
	"nanos-world::SM_Veg_Onion_Red_01",
	"nanos-world::SM_Veg_Artichoke_01",
	"nanos-world::SM_Fruit_Lime_01",
	"nanos-world::SM_Fruit_Orange_01",
	"nanos-world::SM_Fruit_Apple_01",
	"nanos-world::SM_Fruit_Tomato_01",
	"nanos-world::SM_Fruit_Mandarin_01",
	"nanos-world::SM_Fruit_Apple_Red_01",
	"nanos-world::SM_Fruit_Apple_Green_01",
	"nanos-world::SM_Fruit_Avocado_01",
	"nanos-world::SM_Fruit_Peach_01",
	"nanos-world::SM_Bread_Pizza_01",
	"nanos-world::SM_Fruit_Pear_01",
	"nanos-world::SM_Fruit_Tomato_01",
	"nanos-world::SM_Bread_Loaf_Multi_01",
	"nanos-world::SM_Veg_Onion_Red_01",
}