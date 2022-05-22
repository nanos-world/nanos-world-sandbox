-- Resizer Tool variables
ResizerTool = {
	resizing_object = nil,
	weapon = nil,
	current_scale = Vector(1)
}

function ResizerReleaseUse(weapon, shooter)
	if (ResizerTool.resizing_object) then
		ResizerTool.resizing_object:SetHighlightEnabled(false)
		ResizerTool.resizing_object = nil
		Events.CallRemote("ToggleResizing", false)
	end
end

function ResizerWeaponAimModeChanged(self, old_state, new_state)
	if (new_state == AimMode.None and ResizerTool.resizing_object) then
		ResizerTool.resizing_object:SetHighlightEnabled(false)
		ResizerTool.resizing_object = nil
		Events.CallRemote("ToggleResizing", false)
	end
end

function ResizerFire(weapon, shooter)
	-- Makes a trace 10000 units ahead
	local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn)

	-- If hit an object, then sets this object to be the "resized" one
	if (trace_result.Success and trace_result.Entity and not trace_result.Entity:HasAuthority()) then
		ResizerTool.resizing_object = trace_result.Entity
		ResizerTool.current_scale = ResizerTool.resizing_object:GetScale()
		ResizerTool.resizing_object:SetHighlightEnabled(true, 0)
		Events.CallRemote("ToggleResizing", true)
	else
		-- If didn't hit anything, plays a negative sound
		Sound(Vector(), "nanos-world::A_Invalid_Action", true, true, SoundType.SFX, 1)
	end
end

-- Method to handle when Player picks up the Tool
function HandleResizerTool(weapon, character)
	ResizerTool.weapon = weapon

	-- Subscribe when the player fires with this weapon
	weapon:Subscribe("Fire", ResizerFire)

	-- Subscribes when the player stops using this weapon (turn off the Physics Gun)
	weapon:Subscribe("ReleaseUse", ResizerReleaseUse)

	-- If changed the AimMode, stops resizing
	character:Subscribe("WeaponAimModeChanged", ResizerWeaponAimModeChanged)

	-- Sets some notification when grabbing the Tool
	AddNotification("RESIZER_GUIDE", "hold down Left Mouse to select an object, then use mouse wheel to size it up or down", 10000, 5000)
end

Client.Subscribe("MouseUp", function(key_name)
	if (not ResizerTool.weapon) then return end

	-- Scrolls up to increase the scale
	if (key_name == "MouseScrollUp") then
		if (ResizerTool.resizing_object) then
			ResizerTool.current_scale = ResizerTool.current_scale + 0.1
			Events.CallRemote("ResizeObject", ResizerTool.resizing_object, ResizerTool.current_scale, true)
		end
		return
	end

	-- Scrolls down to dencrease the scale
	if (key_name == "MouseScrollDown") then
		if (ResizerTool.resizing_object) then
			ResizerTool.current_scale = ResizerTool.current_scale - 0.1

			-- Cannot resize too small
			if (ResizerTool.current_scale.X < 0.1) then
				ResizerTool.current_scale = Vector(0.1)
			end

			Events.CallRemote("ResizeObject", ResizerTool.resizing_object, ResizerTool.current_scale, false)
		end
		return
	end
end)

Client.Subscribe("KeyPress", function(key_name)
	if (not ResizerTool.weapon or not ResizerTool.resizing_object) then return end

	if (key_name == "R") then
		ResizerTool.current_scale = Vector(1, 1, 1)
		Events.CallRemote("ResizeObject", ResizerTool.resizing_object, Vector(1, 1, 1), true)
	end
end)

Events.Subscribe("PickUpToolGun_ResizerTool", function(tool, character)
	HandleResizerTool(tool, character)
end)

Events.Subscribe("DropToolGun_ResizerTool", function(tool, character)
	tool:Unsubscribe("Fire", ResizerFire)
	tool:Unsubscribe("ReleaseUse", ResizerReleaseUse)
	character:Unsubscribe("WeaponAimModeChanged", ResizerWeaponAimModeChanged)

	if (ResizerTool.resizing_object) then
		ResizerTool.resizing_object:SetHighlightEnabled(false)
		ResizerTool.resizing_object = nil
		Events.CallRemote("ToggleResizing", false)
	end
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "tools", "ResizerTool", "Resizer", "assets///NanosWorld/Thumbnails/SK_Blaster.jpg", nil, {
	{ key = "LeftClick", text = "select object" },
	{ key = "R", text = "reset scale" },
	{ key = "MouseScrollUp", text = "scale" },
})