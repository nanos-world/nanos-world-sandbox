NPC = Character.Inherit("NPC")

function NPC:Constructor(location, rotation, mesh)
	self.Super:Constructor(location or Vector(), (rotation or Rotator()) + Rotator(0, math.random(0, 360), 0), mesh)

	CustomizeCharacter(self, mesh)

	Timer.Bind(
		-- After 5-10 seconds, move again
		Timer.SetInterval(function(bound_character)
			-- Does not move it already moving or dead or in ragdoll
			if (bound_character:GetMovingTo() ~= Vector() or bound_character:IsDead() or bound_character:IsInRagdollMode()) then return end

			-- Make him walk
			bound_character:SetGaitMode(GaitMode.Walking)

			-- Walk 30 meters away max
			bound_character:MoveRandom(3000)
		end, math.random(5000) + 5000, self),
		self
	)

	-- Immediately walks after spawning
	self:MoveRandom(2000)
end

-- Randomly walk a NPC to somewhere around within distance
function NPC:MoveRandom(distance)
	if (self:GetPlayer() ~= nil) then return end
	local random_location = self:GetLocation() + Vector(math.random(distance) - distance / 2, math.random(distance) - distance / 2, 0)
	self:MoveTo(random_location, 250)
end

-- When take damage
function NPC:OnTakeDamage(damage, bone, type, from_direction, instigator, causer)
	if (self:IsDead()) then return end

	-- Avoid those damage types
	if (type == DamageType.RunOverVehicle or type == DamageType.RunOverProp or type == DamageType.Fall) then return end

	-- Make him run
	self:SetGaitMode(GaitMode.Sprinting)

	local current_location = self:GetLocation()
	local run_to_location = current_location + from_direction * 3000

	-- Run 30 meters away max in the opposite direction
	self:MoveTo(Vector(run_to_location.X, run_to_location.Y, current_location.Z), 1000)
end

-- After dying, destroys the Character after 10 seconds
function NPC:OnDeath()
	self:SetLifeSpan(10)
end

-- After entering ragdoll, after some time, get up
function NPC:OnRagdollModeChange(was_in_ragdoll, is_in_ragdoll)
	if (not is_in_ragdoll) then return end

	Timer.Bind(
		Timer.SetTimeout(function(bound_character)
			-- If dead or not in ragdoll, do nothing
			if (bound_character:IsDead() or not bound_character:IsInRagdollMode()) then return end

			bound_character:SetRagdollMode(false)
			bound_character:SetGaitMode(GaitMode.Sprinting)
			bound_character:MoveRandom(2000)
		end, 3000, self),
		self
	)
end

NPC.Subscribe("TakeDamage", NPC.OnTakeDamage)
NPC.Subscribe("Death", NPC.OnDeath)
NPC.Subscribe("RagdollModeChange", NPC.OnRagdollModeChange)



NPC_MannequinMale = NPC.Inherit("NPC_MannequinMale")

function NPC_MannequinMale:Constructor(location, rotation)
	NPC.Constructor(self, location or Vector(), rotation or Rotator(), "nanos-world::SK_Mannequin")
end


NPC_MannequinFemale = NPC.Inherit("NPC_MannequinFemale")

function NPC_MannequinFemale:Constructor(location, rotation)
	NPC.Constructor(self, location or Vector(), rotation or Rotator(), "nanos-world::SK_Mannequin_Female")
end


NPC_PostApocalyptic = NPC.Inherit("NPC_PostApocalyptic")

function NPC_PostApocalyptic:Constructor(location, rotation)
	NPC.Constructor(self, location or Vector(), rotation or Rotator(), "nanos-world::SK_PostApocalyptic")
end


NPC_ClassicMale = NPC.Inherit("NPC_ClassicMale")

function NPC_ClassicMale:Constructor(location, rotation)
	NPC.Constructor(self, location or Vector(), rotation or Rotator(), "nanos-world::SK_ClassicMale")
end


NPC_Male = NPC.Inherit("NPC_Male")

function NPC_Male:Constructor(location, rotation)
	NPC.Constructor(self, location or Vector(), rotation or Rotator(), "nanos-world::SK_Male")
end


NPC_Female = NPC.Inherit("NPC_Female")

function NPC_Female:Constructor(location, rotation)
	NPC.Constructor(self, location or Vector(), rotation or Rotator(), "nanos-world::SK_Female")
end


NPC_Adventure_01 = NPC.Inherit("NPC_Adventure_01")

function NPC_Adventure_01:Constructor(location, rotation)
	NPC.Constructor(self, location or Vector(), rotation or Rotator(), "nanos-world::SK_Adventure_01_Full_02")
end


NPC_Adventure_02 = NPC.Inherit("NPC_Adventure_02")

function NPC_Adventure_02:Constructor(location, rotation)
	NPC.Constructor(self, location or Vector(), rotation or Rotator(), "nanos-world::SK_Adventure_02_Full_03")
end


NPC_Adventure_03 = NPC.Inherit("NPC_Adventure_03")

function NPC_Adventure_03:Constructor(location, rotation)
	NPC.Constructor(self, location or Vector(), rotation or Rotator(), "nanos-world::SK_Adventure_03_Full_02")
end


NPC_Adventure_04 = NPC.Inherit("NPC_Adventure_04")

function NPC_Adventure_04:Constructor(location, rotation)
	NPC.Constructor(self, location or Vector(), rotation or Rotator(), "nanos-world::SK_Adventure_04_Full_02")
end


NPC_Adventure_05 = NPC.Inherit("NPC_Adventure_05")

function NPC_Adventure_05:Constructor(location, rotation)
	NPC.Constructor(self, location or Vector(), rotation or Rotator(), "nanos-world::SK_Adventure_05_Full_02")
end


StackOBot = CharacterSimple.Inherit("StackOBot")

function StackOBot:Constructor(location, rotation)
	self.Super:Constructor(location or Vector(), (rotation or Rotator()) + Rotator(0, math.random(0, 360), 0), "nanos-world::SK_StackOBot", "nanos-world::ABP_StackOBot")

	self:SetSpeedSettings(275, 150)

	Timer.Bind(
		Timer.SetInterval(function(stack_o_bot)
			if (stack_o_bot:IsDead()) then return end

			stack_o_bot:SetMood(math.random(0, 14))
		end, 15000, self),
		self
	)

	-- Sets a Mood
	self:SetMood(math.random(0, 14))

	-- TODO duplicated bad code
	Timer.Bind(
		-- After 5-10 seconds, move again
		Timer.SetInterval(function(bound_character)
			-- Does not move it already moving or dead or in ragdoll
			if (bound_character:GetMovingTo() ~= Vector() or bound_character:IsDead()) then return end

			-- Walk 30 meters away max
			bound_character:MoveRandom(3000)
		end, math.random(5000) + 5000, self),
		self
	)

	-- Immediately walks after spawning
	self:MoveRandom(2000)
end

function StackOBot:SetMood(value)
	self:SetMaterialScalarParameter("Mood", value)
end

-- Randomly walk a NPC to somwehere around within distance
function StackOBot:MoveRandom(distance)
	if (self:GetPlayer() ~= nil) then return end
	local random_location = self:GetLocation() + Vector(math.random(distance) - distance / 2, math.random(distance) - distance / 2, 0)
	self:MoveTo(random_location, 250)
end

-- When take damage
function StackOBot:OnTakeDamage(damage, bone, type, from_direction, instigator, causer)
	if (self:IsDead()) then return end

	-- Avoid those damage types
	if (type == DamageType.RunOverVehicle or type == DamageType.RunOverProp or type == DamageType.Fall) then return end

	local current_location = self:GetLocation()
	local run_to_location = current_location + from_direction * 3000

	-- Run 30 meters away max in the opposite direction
	self:MoveTo(Vector(run_to_location.X, run_to_location.Y, current_location.Z), 1000)
end

-- After dying, destroys the Character after 10 seconds
function StackOBot:OnDeath()
	self:SetMood(15)
	self:SetLifeSpan(10)
end

StackOBot.Subscribe("TakeDamage", StackOBot.OnTakeDamage)
StackOBot.Subscribe("Death", StackOBot.OnDeath)