WireGun = ToolGunDoubleTarget.Inherit("WireGun")

function WireGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGunDoubleTarget.Constructor(self, location, rotation, Color.CHARTREUSE)
end

function WireGun:OnWire(player, wire_start, wire_end, configs)
	-- Only allows attaching if any of the two has a LinkEntity function AND the other has an Activate function
	if (
		(not wire_start.LinkEntity and not wire_end.LinkEntity) or
		(wire_start.LinkEntity and not wire_end.Activate) or
		(wire_end.LinkEntity and not wire_start.Activate)
	) then
		Events.CallRemote("SpawnSound", player, wire_start:GetLocation(), "nanos-world::A_Invalid_Action", false, 1, 1)
		Events.CallRemote("AddNotification", player, NotificationType.Warning, "INVALID_WIRE_OBJECTS", "those objects are not connectable with a wire", 3, 0, true)
		return
	end

	local linked_start = false
	if (wire_start.LinkEntity) then
		linked_start = wire_start:LinkEntity(wire_end, configs.show_wire, configs.wire_color)
	end

	local linked_end = false
	if (wire_end.LinkEntity) then
		linked_end = wire_end:LinkEntity(wire_start, configs.show_wire, configs.wire_color)
	end

	-- If both returned false, it means they are already attached, then detaches
	if (not linked_start and not linked_end) then
		if (wire_start.UnlinkEntity) then
			wire_start:UnlinkEntity(wire_end)
		end

		if (wire_end.UnlinkEntity) then
			wire_end:UnlinkEntity(wire_start)
		end
	else
		-- Adds custom history functions to be able to undo the wire with the undo button
		if (linked_start) then
			SpawnHistory.AddItemToHistory(player, function()
				if (not wire_start or not wire_start:IsValid() or not wire_end or not wire_end:IsValid()) then return false end
				if (not wire_start:UnlinkEntity(wire_end)) then return false end

				return true, wire_end:GetLocation(), "Wire"
			end)
		end

		if (linked_end) then
			SpawnHistory.AddItemToHistory(player, function()
				if (not wire_end or not wire_end:IsValid() or not wire_start or not wire_start:IsValid()) then return false end
				if (not wire_end:UnlinkEntity(wire_start)) then return false end

				return true, wire_end:GetLocation(), "Wire"
			end)
		end
	end

	Particle(wire_start:GetLocation(), Rotator(), "nanos-world::P_OmnidirectionalBurst")
	Particle(wire_end:GetLocation(), Rotator(), "nanos-world::P_OmnidirectionalBurst")
end

function WireGun:UnWireAll(player, entity)
	if (not entity.UnlinkAllEntities) then
		Events.BroadcastRemote("SpawnSound", entity:GetLocation(), "nanos-world::A_Invalid_Action", false, 1, 1)
		return
	end

	entity:UnlinkAllEntities()
end


WireGun.SubscribeRemote("Wire", WireGun.OnWire)
WireGun.SubscribeRemote("UnWireAll", WireGun.UnWireAll)