-- Aux function to Randomly walk a NPC to somwehere around within distance
function Character:MoveRandom(distance)
	local random_location = self:GetLocation() + Vector(math.random(distance) - distance / 2, math.random(distance) - distance / 2, 0)
	self:MoveTo(random_location, 250)
end

function SpawnNPC(location, rotation, asset_pack, category, asset)
	-- Spawns a random Character
	local character = SpawnCharacterRandomized(location or Vector(), rotation + Rotator(0, math.random(0, 360), 0) or Rotator(), asset)

	Timer.Bind(
		-- After 5-10 seconds, move again
		Timer.SetInterval(function(chara)
			-- Make him walk
			chara:SetGaitMode(GaitMode.Walking)

			-- Walk 30 meters away max
			chara:MoveRandom(3000)
		end, math.random(5000) + 5000, character),
		character
	)

	-- When take damage
	character:Subscribe("TakeDamage", function(self, damage, bone, type, from_direction, instigator, causer)
		-- Make him run
		self:SetGaitMode(GaitMode.Sprinting)

		local current_location = self:GetLocation()
		local run_to_location = current_location + from_direction * 3000

		-- Run 30 meters away max in the opposite direction
		character:MoveTo(Vector(run_to_location.X, run_to_location.Y, current_location.Z), 1000)
	end)

	-- After dying, destroys the Character after 10 seconds
	character:Subscribe("Death", function(self)
		self:SetLifeSpan(10)
	end)

	-- After entering ragdoll, after some time, get up
	character:Subscribe("RagdollModeChanged", function(self, was_in_ragdoll, is_in_ragdoll)
		if (not is_in_ragdoll) then return end

		Timer.Bind(
			Timer.SetTimeout(function(chara)
				chara:Jump()
			end, 3000, self),
			self
		)
	end)

	-- Immediately walks after spawning
	character:MoveRandom(2000)

	return character
end

-- Default NPCs
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_Mannequin", SpawnNPC)
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_Mannequin_Female", SpawnNPC)
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_Male", SpawnNPC)
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_Female", SpawnNPC)
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_PostApocalyptic", SpawnNPC)
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_ClassicMale", SpawnNPC)