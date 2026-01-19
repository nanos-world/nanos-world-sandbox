Thruster = Prop.Inherit("Thruster")

ConfigureSpawnLimits("Thruster", "Thrusters", Thruster.GetCount, "max_thrusters")

function Thruster:Constructor(location, rotation, particle_asset, sound_asset, force)
	self.Super:Constructor(location, rotation, "nanos-world::SM_Rocket_Thruster", CollisionType.StaticOnly, true, GrabMode.Disabled)

	self:SetScale(Vector(0.5, 0.5, 0.5))

	-- Adds a constant force to the Thruster
	self:SetForce(Vector(force or 100000, 0, 0), true)

	-- Sets the values as sync, so client can access it on Spawn event
	self:SetValue("Sound", sound_asset or "nanos-world::A_Thruster_02", true)
	self:SetValue("Particle", particle_asset or "nanos-world::P_RocketExhaust_Realistic", true)
end

function Thruster:SetCustomForce(player, force)
	self:SetForce(Vector(force, 0, 0), true)
end

function Thruster:SetSoundAsset(player, sound_asset)
	self:SetValue("Sound", sound_asset, true)
	self:BroadcastRemoteEvent("UpdateSoundAsset", sound_asset)
end

function Thruster:SetParticleAsset(player, particle_asset)
	self:SetValue("Particle", particle_asset, true)
	self:BroadcastRemoteEvent("UpdateParticleAsset", particle_asset)
end

Thruster.SubscribeRemote("SetSoundAsset", Thruster.SetSoundAsset)
Thruster.SubscribeRemote("SetParticleAsset", Thruster.SetParticleAsset)
Thruster.SubscribeRemote("SetCustomForce", Thruster.SetCustomForce)