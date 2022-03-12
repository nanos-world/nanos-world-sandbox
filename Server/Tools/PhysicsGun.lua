-- Subscribe for Client's custom event, for when the object is grabbed/dropped
Events.Subscribe("PickUp", function(player, weapon, object, is_grabbing, picking_object_relative_location, freeze)
    -- Gets the Laser particle of this weapon, if existing
    local particle = weapon and weapon:GetValue("BeamParticle") or nil

    if (is_grabbing) then
        -- Only updates the Network Authority if this entity is network distributed
        if (object:IsNetworkDistributed()) then
            object:SetNetworkAuthority(player)
        end

        object:SetValue("IsBeingGrabbed", true, true)

        -- Sets the particle values so all Clients can set the correct position of them
        if (particle) then
            particle:SetValue("RelativeLocationObject", picking_object_relative_location, true)
            particle:SetValue("BeamEndObject", object, true)
        end

        -- Spawns a sound for grabbing it
        if (weapon) then
	        Events.BroadcastRemote("SpawnSound", weapon:GetLocation(), "nanos-world::A_VR_Grab", false, 0.25, 0.9)
        end
    else
        object:SetValue("IsBeingGrabbed", false, true)

        -- Resets TranslateTo and RotateTo movement
        object:TranslateTo(object:GetLocation(), 0)
        object:RotateTo(object:GetRotation(), 0)

        -- Resets particle values
        if (particle) then
            particle:SetValue("RelativeLocationObject", nil, true)
            particle:SetValue("BeamEndObject", nil, true)
        end

        -- Spawns a sound for ungrabbing it
        if (weapon) then
            Events.BroadcastRemote("SpawnSound", weapon:GetLocation(), "nanos-world::A_VR_Ungrab", false, 0.25, 0.9)
        end
    end

    -- Disables/Enables the gravity of the object so he can 'fly' freely
    object:SetGravityEnabled(not freeze and not is_grabbing)

    if (freeze) then
        Particle(object:GetLocation(), Rotator(), "nanos-world::P_OmnidirectionalBurst")
    end

    -- Disables/Enables the character to Aim, so he can use the Mouse Wheel properly
    player:GetControlledCharacter():SetCanAim(not is_grabbing)

    Events.BroadcastRemote("PickUpObject", object, is_grabbing)
end)

-- Subscribe for Client's custom event, to update the position of the object he is grabbing
Events.Subscribe("UpdateObjectPosition", function(player, object, location, rotation, snap_to_grid)
    -- Maybe the server is closing?
    if (not object) then return end

    object:TranslateTo(location, 0.05)
    object:RotateTo(rotation, 0.05)

    -- Only updates the Network Authority if this entity is network distributed
    if (object:IsNetworkDistributed()) then
        object:SetNetworkAuthority(player)
    end
end)

-- Subscribes for Clients event for turning on/off the physics gun
Events.Subscribe("TogglePhysicsGun", function(player, weapon, enable)
    -- Maybe the server is closing?
    if (not weapon) then return end

    -- Attempt to Stop if existing the beam particle
    StopBeamParticle(weapon)

    -- If the Physics Gun is being enabled
    if (enable) then
        -- Spawns a Beam Particle and attaches it to the weapon
        local beam_particle = Particle(Vector(), Rotator(), "nanos-world::P_Beam", false, true)
        beam_particle:AttachTo(weapon, AttachmentRule.SnapToTarget, "muzzle")

        -- Sets the Color and some settings to make it pretty
        beam_particle:SetParameterColor("BeamColor", Color(0, 0, 2, 1))
        beam_particle:SetParameterFloat("BeamWidth", 2)
        beam_particle:SetParameterFloat("JitterAmount", 1)

        -- Sets in the weapon the particle value, so it can be get after all
        weapon:SetValue("BeamParticle", beam_particle, true)

        -- If the weapon is dropped, destroy the particle
        weapon:Subscribe("Drop", StopBeamParticle)
    else
        weapon:Unsubscribe("Drop", StopBeamParticle)
	    Events.BroadcastRemote("SpawnSound", weapon:GetLocation(), "nanos-world::A_Simulate_End", false, 1, 1)
    end
end)

function StopBeamParticle(weapon)
    local particle = weapon:GetValue("BeamParticle")
    if (not particle) then return end

    weapon:SetValue("BeamParticle", nil, true)
    particle:Destroy()
end

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "tools", "PhysicsGun", function() return SpawnGenericToolGun(Vector(), Rotator(), Color.BLUE) end)