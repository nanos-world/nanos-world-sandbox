NPC = Character.Inherit("NPC")

function NPC:Constructor(location, rotation, mesh)
	self.Super:Constructor(location or Vector(), (rotation or Rotator()) + Rotator(0, math.random(0, 360), 0), mesh)

	CustomizeCharacter(self, mesh)

	Timer.Bind(
		-- After 5-10 seconds, move again
		Timer.SetInterval(function(chara)
			-- Make him walk
			chara:SetGaitMode(GaitMode.Walking)

			-- Walk 30 meters away max
			chara:MoveRandom(3000)
		end, math.random(5000) + 5000, self),
		self
	)

	-- Immediately walks after spawning
	self:MoveRandom(2000)
end

-- Randomly walk a NPC to somwehere around within distance
function NPC:MoveRandom(distance)
	local random_location = self:GetLocation() + Vector(math.random(distance) - distance / 2, math.random(distance) - distance / 2, 0)
	self:MoveTo(random_location, 250)
end

-- When take damage
function NPC:OnTakeDamage(damage, bone, type, from_direction, instigator, causer)
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
		Timer.SetTimeout(function(chara)
			chara:Jump()
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


StackOBot = CharacterSimple.Inherit("StackOBot")

function StackOBot:Constructor(location, rotation)
	self.Super:Constructor(location or Vector(), (rotation or Rotator()) + Rotator(0, math.random(0, 360), 0), "nanos-world::SK_StackOBot", "nanos-world::ABP_StackOBot")

	-- Temp if for update
	if (CharacterSimple.SetSpeedSettings) then
		self:SetSpeedSettings(275, 150)
	end

	Timer.Bind(
		Timer.SetInterval(function(stack_o_bot)
			self:SetMood(math.random(0, 15))
		end, 15000, self),
		self
	)

	self:SetMood(math.random(0, 15))

	-- TODO duplicated bad code
	Timer.Bind(
		-- After 5-10 seconds, move again
		Timer.SetInterval(function(chara)
			-- Walk 30 meters away max
			chara:MoveRandom(3000)
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
	local random_location = self:GetLocation() + Vector(math.random(distance) - distance / 2, math.random(distance) - distance / 2, 0)
	self:MoveTo(random_location, 250)
end
