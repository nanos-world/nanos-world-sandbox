-- Event called from Client to Paint an object
-- Painting can only affect meshes which materials has the Color Parameter 'Tint'
Events:Subscribe("ColorObject", function(player, entity, hit_location, direction, color)
	entity:SetMaterialColorParameter("Tint", color)

	Particle(hit_location, direction:Rotation(), "NanosWorld::P_DirectionalBurst"):SetParameterColor("Color", color)
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("NanosWorld", "tools", "ColorTool", function() return SpawnGenericToolGun(Vector(), Rotator(), Color.GREEN) end)