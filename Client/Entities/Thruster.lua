Thruster = Prop.Inherit("Thruster")

-- Input Bindings for this Entity
Thruster.input_bindings = {
	{
		label = "activate / deactivate",
		callback_pressed = function(entity)
			entity:CallRemoteEvent("SetActive", true)
		end,
		callback_released = function(entity)
			entity:CallRemoteEvent("SetActive", false)
		end,
	},
	{
		label = "toggle",
		callback_pressed = function(entity)
			entity:CallRemoteEvent("SetActive", not entity:GetValue("Active"))
		end,
	},
}

-- Context Menu Items when selecting this Entity
Thruster.selected_context_menu_items = {
	{
		label = "particle",
		type = "select",
		options = THRUSTER_ASSETS,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetParticleAsset", value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Particle")
		end,
	},
	{
		type = "select",
		label = "sound",
		options = THRUSTER_SOUNDS,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetSoundAsset", value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Sound")
		end,
	},
	{
		label = "force",
		type = "range",
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
		label = "active",
		type = "checkbox",
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
		self.sound:FadeIn(0.5)
	end
end

function Thruster:OnDeactivated()
	if (self.particle) then
		self.particle:Deactivate()
	end

	if (self.sound) then
		self.sound:FadeOut(0.5)
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