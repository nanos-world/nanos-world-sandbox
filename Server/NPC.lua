-- Aux function to Randomly walk a NPC to somwehere around within distance
function NPCRandomMove(character, distance)
	local random_location = character:GetLocation() + Vector(math.random(distance) - distance / 2, math.random(distance) - distance / 2, 0)
	character:MoveTo(random_location, 250)
end

function SpawnNPC(asset, location, rotation)
	-- Spawns a random Character
	local character = SpawnCharacterRandomized(location or Vector(), rotation + Rotator(0, math.random(0, 360), 0) or Rotator(), asset)

	-- After moving, move again after 5-10 seconds
	character:Subscribe("MoveCompleted", function(charac, success)
		-- Binds the timer with the Character, so if the Character is destroyed, the timer won't trigger
		Timer.Bind(
			-- After 5-10 seconds, move again
			Timer.SetTimeout(function(chara)
				-- Make him wwalk
				chara:SetGaitMode(GaitMode.Walking)

				-- Walk 30 meters away max
				NPCRandomMove(chara, 3000)
			end, math.random(5000) + 5000, charac),
			charac
		)
	end)

	-- When take damage
	character:Subscribe("TakeDamage", function(self, damage, bone, type, from_direction, instigator, causer)
		-- Make him run
		self:SetGaitMode(GaitMode.Sprinting)

		-- Run 30 meters away max
		NPCRandomMove(character, 3000)
	end)

	-- After dying, destroys the Character after 10 seconds
	character:Subscribe("Death", function(self)
		self:SetLifeSpan(10)
	end)

	-- Immediately walks after spawning
	NPCRandomMove(character, 1000)

	return character
end

-- Default NPCs
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_Mannequin", function(l, r) return SpawnNPC("nanos-world::SK_Mannequin", l, r) end)
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_Mannequin_Female", function(l, r) return SpawnNPC("nanos-world::SK_Mannequin_Female", l, r) end)
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_Male", function(l, r) return SpawnNPC("nanos-world::SK_Male", l, r) end)
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_Female", function(l, r) return SpawnNPC("nanos-world::SK_Female", l, r) end)
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_PostApocalyptic", function(l, r) return SpawnNPC("nanos-world::SK_PostApocalyptic", l, r) end)
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_ClassicMale", function(l, r) return SpawnNPC("nanos-world::SK_ClassicMale", l, r) end)