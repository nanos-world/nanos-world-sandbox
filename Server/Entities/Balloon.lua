Balloon = Prop.Inherit("Balloon")

ConfigureSpawnLimits("Balloon", "Balloons", Balloon.GetCount, "max_balloons")


function Balloon:Constructor(location, rotation, tab, id, player, relative_location, relative_rotation, direction, entity, force, max_length, asset)
	-- Spawns a Balloon Prop (not allowing characters to pickup it and with CCD disabled)
	local spawn_location = location
	if (direction) then
		spawn_location = location + direction * 50
	end

	self.Super:Constructor(spawn_location, rotation, asset or "nanos-world::SM_Balloon_01", CollisionType.Normal, true, GrabMode.Disabled, CCDMode.Disabled)

	-- Sets Rubber Physical Material
	self:SetPhysicalMaterial("nanos-world::PM_Rubber")

	-- Normalize the Mass
	self:SetMassOverride(50)

	-- Adds a constant force upwards
	self:SetForce(Vector(0, 0, tonumber(force) or 100000), false)

	-- Configures the Ballon Physics
	self:SetPhysicsDamping(5, 10)

	-- Sets a random color for the balloon
	local color = Color.RandomPalette()
	self:SetMaterialColorParameter("Tint", color)

	max_length = tonumber(max_length)

	-- If didn't pass max_length, we consider we don't want cable
	if (max_length) then
		-- Spawns the Ballon cable
		local cable = Cable(location)

		-- Configures the Cable Linear Physics Limit
		cable:SetLinearLimits(ConstraintMotion.Limited, ConstraintMotion.Limited, ConstraintMotion.Limited, max_length, 0, true, 10000, 100)

		-- Sets cable rendering settings (width = 3, pieces = 4)
		cable:SetRenderingSettings(3, 5, 4)
		cable:SetCableSettings(max_length, 1, 1, false)

		-- If to attach to an entity, attaches the start to it
		if (entity) then
			cable:AttachStartTo(entity, relative_location)
		end

		-- Attaches the Cable to the Balloon
		local end_relative_location = Vector()

		-- Emojis have their pivot point at wrong, so hacky fix it
		if (asset:find("Emoji")) then
			end_relative_location = Vector(0, -5, -35)
		end

		cable:AttachEndTo(self, end_relative_location)
	end

	-- Stores the actual Z location so we can destroy it after it raised +6000
	self.spawn_z_location = location.Z

	-- Calls the Client to spawn balloons spawning sounds
	Events.BroadcastRemote("SpawnSound", location, "nanos-world::A_Balloon_Inflate", false, 0.75, 1)
end

function Balloon:SetCustomForce(player, force)
	self:SetForce(Vector(0, 0, tonumber(force)), false)
end

function Balloon:SetCustomMesh(player, mesh)
	local old_color = self:GetMaterialColorParameter("Tint")
	self:SetMesh(mesh)
	self:ResetMaterial()
	self:SetMaterialColorParameter("Tint", old_color)
end

-- Subscribes for popping when balloon takes damage
function Balloon:OnTakeDamage(damage, bone_name, damage_type, hit_from_direction, instigator, causer)
	self:Destroy()
end

Balloon.Subscribe("TakeDamage", Balloon.OnTakeDamage)
Balloon.SubscribeRemote("SetCustomForce", Balloon.SetCustomForce)
Balloon.SubscribeRemote("SetCustomMesh", Balloon.SetCustomMesh)


-- Timer for destroying balloons when they gets too high
Timer.SetInterval(function()
	for k, balloon in pairs(Balloon.GetPairs()) do
		-- If this balloon is higher enough, pops it
		if (balloon:IsValid() and balloon:GetLocation().Z - balloon.spawn_z_location > 6000 + math.random(1000)) then
			balloon:Destroy()
		end
	end
end, 1000)