function NPCRandomMove(character, distance)
	local random_location = character:GetLocation() + Vector(math.random(distance) - distance / 2, math.random(distance) - distance / 2, math.random(100) - 50)
	character:MoveTo(random_location, 250)
end

function SpawnNPC(asset, location, rotation)
	local character = Character(location or Vector(), rotation + Rotator(0, 180, 0) or Rotator(), asset)

	character:Subscribe("MoveCompleted", function(charac, success)
		Timer.SetTimeout(function(chara)
			if (chara and chara:IsValid()) then
				chara:SetGaitMode(GaitMode.Walking)
				NPCRandomMove(chara, 3000)
				charac:SetValue("Scream", false)
			end
		end, math.random(5000) + 5000, charac)
	end)

	character:Subscribe("TakeDamage", function(self, damage, bone, type, from_direction, instigator)
		self:SetGaitMode(GaitMode.Sprinting)
		NPCRandomMove(character, 3000)

		if (not self:GetValue("Scream")) then
			Events.BroadcastRemote("SpawnSoundAttached", self, "nanos-world::A_Female_02_Scream", false, 1, 1)
			self:SetValue("Scream", true)
		end
	end)

	character:Subscribe("Death", function(self)
		Timer.SetTimeout(function(chara)
			if (chara and chara:IsValid()) then
				chara:Destroy()
			end
		end, 10000, self)
	end)

	NPCRandomMove(character, 5000)

	return character
end

-- Default NPCs
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_Mannequin", function(l, r) return SpawnNPC("nanos-world::SK_Mannequin", l, r) end)
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_Mannequin_Female", function(l, r) return SpawnNPC("nanos-world::SK_Mannequin_Female", l, r) end)
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_Male", function(l, r) return SpawnNPC("nanos-world::SK_Male", l, r) end)
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_Female", function(l, r) return SpawnNPC("nanos-world::SK_Female", l, r) end)
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_PostApocalyptic", function(l, r) return SpawnNPC("nanos-world::SK_PostApocalyptic", l, r) end)
AddSpawnMenuItem("nanos-world", "npcs", "nanos-world::SK_ClassicMale", function(l, r) return SpawnNPC("nanos-world::SK_ClassicMale", l, r) end)