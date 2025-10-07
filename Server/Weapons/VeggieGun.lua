VeggieGun = Weapon.Inherit("VeggieGun")

VeggieGun.veggies = {
	"nanos-world::SM_Fruit_Apple_01",
	"nanos-world::SM_Fruit_Apple_01_Half_01",
	"nanos-world::SM_Fruit_Apple_01_Quarter_01",
	"nanos-world::SM_Fruit_Apple_01_Wedge_01",
	"nanos-world::SM_Fruit_Apple_Green_01",
	"nanos-world::SM_Fruit_Apple_Green_01_Half_01",
	"nanos-world::SM_Fruit_Apple_Green_01_Quarter_01",
	"nanos-world::SM_Fruit_Apple_Green_01_Wedge_01",
	"nanos-world::SM_Fruit_Apple_Red_01",
	"nanos-world::SM_Fruit_Apple_Red_01_Half_01",
	"nanos-world::SM_Fruit_Apple_Red_01_Quarter_01",
	"nanos-world::SM_Fruit_Apple_Red_01_Wedge_01",
	"nanos-world::SM_Fruit_Avocado_01",
	"nanos-world::SM_Fruit_Avocado_01_Half_01",
	"nanos-world::SM_Fruit_Avocado_01_Half_02",
	"nanos-world::SM_Fruit_Banana_01",
	"nanos-world::SM_Fruit_Cantaloupe_01",
	"nanos-world::SM_Fruit_Cantaloupe_01_Half_01",
	"nanos-world::SM_Fruit_Cantaloupe_01_Slice_01",
	"nanos-world::SM_Fruit_Coconut_01",
	"nanos-world::SM_Fruit_Lemon_01",
	"nanos-world::SM_Fruit_Lemon_01_Half_01",
	"nanos-world::SM_Fruit_Lemon_01_Slice_01",
	"nanos-world::SM_Fruit_Lime_01",
	"nanos-world::SM_Fruit_Lime_01_Half_01",
	"nanos-world::SM_Fruit_Lime_01_Slice_01",
	"nanos-world::SM_Fruit_Mandarin_01",
	"nanos-world::SM_Fruit_Mandarin_01_Half_01",
	"nanos-world::SM_Fruit_Mandarin_01_Wedge_01",
	"nanos-world::SM_Fruit_Mango_01",
	"nanos-world::SM_Fruit_Mango_01_Half_01",
	"nanos-world::SM_Fruit_Mango_02",
	"nanos-world::SM_Fruit_Orange_01",
	"nanos-world::SM_Fruit_Orange_01_Half_01",
	"nanos-world::SM_Fruit_Orange_01_Wedge_01",
	"nanos-world::SM_Fruit_Peach_01",
	"nanos-world::SM_Fruit_Peach_01_Half_01",
	"nanos-world::SM_Fruit_Peach_01_Half_02",
	"nanos-world::SM_Fruit_Pear_01",
	"nanos-world::SM_Fruit_Pear_01_Half_01",
	"nanos-world::SM_Fruit_Pineapple_01",
	"nanos-world::SM_Fruit_Plum_01",
	"nanos-world::SM_Fruit_Plum_01_Half_01",
	"nanos-world::SM_Fruit_Plum_01_Half_02",
	"nanos-world::SM_Fruit_Pumpkin_01",
	"nanos-world::SM_Fruit_Squash_01",
	"nanos-world::SM_Fruit_Squash_01_Half_01",
	"nanos-world::SM_Fruit_Squash_02",
	"nanos-world::SM_Fruit_Squash_03",
	"nanos-world::SM_Fruit_Tomato_01",
	"nanos-world::SM_Fruit_Tomato_01_SliceBottom",
	"nanos-world::SM_Fruit_Tomato_01_SliceTop",
	"nanos-world::SM_Fruit_Tomato_01_Slice_01",
	"nanos-world::SM_Fruit_Tomato_Heirloom_01",
	"nanos-world::SM_Fruit_Tomato_Heirloom_01_Half_01",
	"nanos-world::SM_Fruit_Tomato_Heirloom_01_Slice_01",
	"nanos-world::SM_Fruit_Watermelon_01",
	"nanos-world::SM_Fruit_Watermelon_01_Crust_01",
	"nanos-world::SM_Fruit_Watermelon_01_Half_01",
	"nanos-world::SM_Fruit_Watermelon_01_Slice_01",
	"nanos-world::SM_Root_Garlic_01",
	"nanos-world::SM_Root_Ginger_01",
	"nanos-world::SM_Root_Potato_01",
	"nanos-world::SM_Root_Potato_02",
	"nanos-world::SM_Root_Potato_03",
	"nanos-world::SM_Root_Potato_Sweet_01",
	"nanos-world::SM_Veg_Artichoke_01",
	"nanos-world::SM_Veg_Artichoke_01_Half_01",
	"nanos-world::SM_Veg_Broccoli_01",
	"nanos-world::SM_Veg_Cabbage_01",
	"nanos-world::SM_Veg_Cabbage_02",
	"nanos-world::SM_Veg_Carrot_01",
	"nanos-world::SM_Veg_Carrot_01_Slice_01",
	"nanos-world::SM_Veg_Carrot_02",
	"nanos-world::SM_Veg_Cauliflower_01",
	"nanos-world::SM_Veg_Corn_01",
	"nanos-world::SM_Veg_Cucumber_01",
	"nanos-world::SM_Veg_Cucumber_01_Slice_01",
	"nanos-world::SM_Veg_Onion_Red_01",
	"nanos-world::SM_Veg_Onion_Red_01_Cut",
	"nanos-world::SM_Veg_Onion_White_01",
	"nanos-world::SM_Veg_Onion_Yellow_01",
}


function VeggieGun:Constructor(location, rotation)
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

function VeggieGun:OnFire(character)
	local control_rotation = character:GetControlRotation()
	local forward_vector = control_rotation:GetForwardVector()
	local spawn_location = self:GetLocation() + Vector(0, 0, 25) + forward_vector * 50

	-- local veggie_mesh = VeggieGun.veggies[math.random(#VeggieGun.veggies)]
	-- local veggie_mesh = "nanos-world::SM_Fruit_Banana_01"
	local veggie_mesh = "nanos-world::SM_Fruit_Watermelon_01"
	-- local veggie_mesh = "nanos-world::SM_Bread_Pizza_01"
	-- local veggie_mesh = "nanos-world::SM_Boxes_01"
	-- local veggie_mesh = "nanos-world::SM_CookerStove"

	local prop = Prop(spawn_location, Rotator.Random(), veggie_mesh, CollisionType.Auto, true, GrabMode.Disabled, CCDMode.Disabled)
	prop:SetLifeSpan(5)
	prop:SetScale(Vector(2, 2, 2))
	-- prop:SetScale(Vector(3, 3, 3))
	prop:SetValue("DebrisLifeSpan", 2)

	SetupBreakableProp(prop)

	prop:AddImpulse(forward_vector * 3000, true)
end

VeggieGun.SubscribeRemote("Fire", VeggieGun.OnFire)