-- Aux function to Randomly walk a NPC to somwehere around within distance
function NPCRandomMove(character, distance)
	local random_location = character:GetLocation() + Vector(math.random(distance) - distance / 2, math.random(distance) - distance / 2, 0)
	character:MoveTo(random_location, 250)
end

function SpawnNPC(location, rotation, asset_pack, category, asset)
	-- Spawns a random Character
	local character = SpawnCharacterRandomized(location or Vector(), rotation + Rotator(0, math.random(0, 360), 0) or Rotator(), asset)

	Timer.Bind(
		-- After 5-10 seconds, move again
		Timer.SetInterval(function(chara)
			-- Make him wwalk
			chara:SetGaitMode(GaitMode.Walking)

			-- Walk 30 meters away max
			NPCRandomMove(chara, 3000)
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

	-- Immediately walks after spawning
	NPCRandomMove(character, 2000)

	return character
end

-- Default NPCs
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_Mannequin", SpawnNPC)
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_Mannequin_Female", SpawnNPC)
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_Male", SpawnNPC)
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_Female", SpawnNPC)
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_PostApocalyptic", SpawnNPC)
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_ClassicMale", SpawnNPC)