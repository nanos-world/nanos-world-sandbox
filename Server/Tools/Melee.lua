function SpawnKnife(location, rotation)
	local melee = Melee(location or Vector(), rotation or Rotator(), "nanos-world::SM_M9", CollisionType.Normal, true, HandlingMode.SingleHandedMelee)
	melee:AddAnimationCharacterUse("nanos-world::AM_Mannequin_Melee_Stab_Attack")
	melee:SetDamageSettings(0.3, 0.3)
	melee:SetCooldown(1.5)
	melee:SetBaseDamage(50)
	melee:SetImpactSound(SurfaceType.Default, "nanos-world::A_MetalHeavy_Impact_MS")

	return melee
end

function SpawnCrowbar(location, rotation)
	local melee = Melee(location or Vector(), rotation or Rotator(), "nanos-world::SM_Crowbar_01", CollisionType.Normal, true, HandlingMode.SingleHandedMelee)
	melee:SetScale(Vector(1.5, 1.5, 1.5))
	melee:AddAnimationCharacterUse("nanos-world::AM_Mannequin_Melee_Slash_Attack")
	melee:SetDamageSettings(0.3, 0.5)
	melee:SetCooldown(1.0)
	melee:SetBaseDamage(40)
	melee:SetImpactSound(SurfaceType.Flesh, "nanos-world::A_Punch_Cue")
	melee:SetImpactSound(SurfaceType.Default, "nanos-world::A_MetalHeavy_Impact_MS")

	return melee
end

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "weapons", "Knife", SpawnKnife)
AddSpawnMenuItem("nanos-world", "weapons", "Crowbar", SpawnCrowbar)