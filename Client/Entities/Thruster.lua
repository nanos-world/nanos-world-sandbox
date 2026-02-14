Thruster = Prop.Inherit("Thruster")

-- Defines custom assets used in Context Menu
Thruster.assets_list = {
	{ id = "",												name = "None" },
	{ id = "nanos-world::P_RocketExhaust_Realistic",		name = "Realistic" },
	{ id = "nanos-world::P_RocketExhaust_Afterburn",		name = "Afterburn" },
	{ id = "nanos-world::P_RocketExhaust_Afterburn_Jet",	name = "Afterburn Jet" },
	{ id = "nanos-world::P_RocketExhaust_Blue",				name = "Blue" },
	{ id = "nanos-world::P_RocketExhaust_BlueRed",			name = "BlueRed" },
	{ id = "nanos-world::P_RocketExhaust_Crackling",		name = "Crackling" },
	{ id = "nanos-world::P_RocketExhaust_Energy",			name = "Energy" },
	{ id = "nanos-world::P_RocketExhaust_Green",			name = "Green" },
	{ id = "nanos-world::P_RocketExhaust_Maniac",			name = "Maniac" },
	{ id = "nanos-world::P_RocketExhaust_Pixie",			name = "Pixie" },
	{ id = "nanos-world::P_RocketExhaust_Plume_01",			name = "Plume 01" },
	{ id = "nanos-world::P_RocketExhaust_Plume_02",			name = "Plume 02" },
	{ id = "nanos-world::P_RocketExhaust_Plume_03",			name = "Plume 03" },
	{ id = "nanos-world::P_RocketExhaust_Red",				name = "Red" },
	{ id = "nanos-world::P_RocketExhaust_SciFi",			name = "SciFi" },
	{ id = "nanos-world::P_RocketExhaust_Violet",			name = "Violet" },
	{ id = "nanos-world::P_RocketExhaust_White",			name = "White" },
	{ id = "nanos-world::P_RocketExhaust_Yellow",			name = "Yellow" },
}

Thruster.sounds_list = {
	{ id = "",												name = "None" },
	{ id = "nanos-world::A_Thruster_01",					name = "Thruster 01" },
	{ id = "nanos-world::A_Thruster_02",					name = "Thruster 02" },
	{ id = "nanos-world::A_Thruster_03",					name = "Thruster 03" },
	{ id = "nanos-world::A_Thruster_04",					name = "Thruster 04" },
	{ id = "nanos-world::A_VR_WorldMove_Loop_01",			name = "World Move 01" },
	{ id = "nanos-world::A_VR_WorldMove_Loop_02",			name = "World Move 02" },
}

-- Context Menu Items when selecting this Entity
Thruster.selected_context_menu_items = {
	{
		id = "thruster_particle_asset",
		type = "select",
		label = "particle",
		options = Thruster.assets_list,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetParticleAsset", value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Particle")
		end,
	},
	{
		id = "thruster_sound_asset",
		type = "select",
		label = "sound",
		options = Thruster.sounds_list,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetSoundAsset", value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Sound")
		end,
	},
	{
		id = "thruster_force",
		type = "range",
		label = "force",
		min = 0,
		max = 1000,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetCustomForce", value * 1000)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Force") / 1000
		end,
	},
	{
		id = "thruster_active",
		type = "checkbox",
		label = "active",
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetActive", value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Active")
		end
	},
}


function Thruster:OnSpawn()
	self:UpdateSoundAsset()
	self:UpdateParticleAsset()
end

function Thruster:OnActivated()
	if (self.particle) then
		self.particle:Activate(true)
	end

	if (self.sound) then
		self.sound:Play()
	end
end

function Thruster:OnDeactivated()
	if (self.particle) then
		self.particle:Deactivate()
	end

	if (self.sound) then
		self.sound:Stop()
	end
end

function Thruster:UpdateSoundAsset()
	if (self.sound) then
		self.sound:Destroy()
		self.sound = nil
	end

	-- Spawns the Sound and attaches it to the thruster
	local sound_asset = self:GetValue("Sound")
	if (sound_asset == "") then return end

	local is_active = self:GetValue("Active")
	self.sound = Sound(self:GetLocation(), sound_asset, false, false, SoundType.SFX, 0.25, math.random(10) / 100 + 1, nil, nil, AttenuationFunction.NaturalSound, false, nil, is_active)
	self.sound:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)
end

function Thruster:UpdateParticleAsset()
	if (self.particle) then
		self.particle:Destroy()
		self.particle = nil
	end

	-- Spawns a Particle and attaches it to the thruster
	local particle_asset = self:GetValue("Particle")
	if (particle_asset == "") then return end

	local is_active = self:GetValue("Active")
	self.particle = Particle(self:GetLocation(), Rotator(), particle_asset, false, is_active)
	self.particle:SetScale(Vector(0.45, 0.45, 0.45))
	self.particle:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)
	self.particle:SetRelativeLocation(Vector(-30, 0, 0))
	self.particle:SetRelativeRotation(Rotator(180, 0, 0))
end

Thruster.Subscribe("Spawn", Thruster.OnSpawn)
Thruster.SubscribeRemote("UpdateSoundAsset", Thruster.UpdateSoundAsset)
Thruster.SubscribeRemote("UpdateParticleAsset", Thruster.UpdateParticleAsset)
Thruster.SubscribeRemote("OnActivated", Thruster.OnActivated)
Thruster.SubscribeRemote("OnDeactivated", Thruster.OnDeactivated)