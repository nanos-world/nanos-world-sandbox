-- Resizer Tool variables
ResizerTool = {
	resizing_object = nil,
	weapon = nil,
	current_scale = Vector(1)
}

-- Method to handle when Player picks up the Tool
function HandleResizerTool(weapon, character)
	ResizerTool.weapon = weapon

	-- Subscribe when the player fires with this weapon
	weapon:Subscribe("Fire", function(weapon, shooter)
		-- Makes a trace 10000 units ahead
		local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn)

		-- If hit an object, then sets this object to be the "resized" one
		if (trace_result.Success and trace_result.Entity) then
			ResizerTool.resizing_object = trace_result.Entity
			ResizerTool.current_scale = ResizerTool.resizing_object:GetScale()
			ResizerTool.resizing_object:SetHighlightEnabled(true, 0)
			Events:CallRemote("ToggleResizing", {true})
		else
			-- If didn't hit anything, plays a negative sound
			Sound(Vector(), "NanosWorld::A_Invalid_Action", true, true, SoundType.SFX, 1)
		end
	end)

	-- If changed the AimMode, stops resizing
	character:Subscribe("WeaponAimModeChanged", function(self, old_state, new_state)
		if (new_state == AimMode.None and ResizerTool.resizing_object) then
			ResizerTool.resizing_object:SetHighlightEnabled(false)
			ResizerTool.resizing_object = nil
			Events:CallRemote("ToggleResizing", {false})
		end
	end)

	-- Sets some notification when grabbing the Tool
	SetNotification("RESIZER_GUIDE", 5000, "hold down Left Mouse to select an object, then use mouse wheel to size it up or down", 10000)
end

Client:Subscribe("MouseUp", function(key_name)
	if (not ResizerTool.weapon) then return end

	-- If released the leftMouse, stops resizing
    if (key_name == "LeftMouseButton") then
		if (ResizerTool.resizing_object) then
			ResizerTool.resizing_object:SetHighlightEnabled(false)
			ResizerTool.resizing_object = nil
			Events:CallRemote("ToggleResizing", {false})
		end
		return
	end

	-- Scrolls up to increase the scale
	if (key_name == "MouseScrollUp") then
		if (ResizerTool.resizing_object) then
			ResizerTool.current_scale = ResizerTool.current_scale + 0.1
			Events:CallRemote("ResizeObject", {ResizerTool.resizing_object, ResizerTool.current_scale})
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

			Events:CallRemote("ResizeObject", {ResizerTool.resizing_object, ResizerTool.current_scale})
		end
		return
	end
end)

Events:Subscribe("PickUpToolGun_ResizerTool", function(tool, character)
	HandleResizerTool(tool, character)
end)

Events:Subscribe("DropToolGun_ResizerTool", function(tool, character)
	tool:Unsubscribe("Fire")
	character:Unsubscribe("WeaponAimModeChanged")

	if (ResizerTool.resizing_object) then
		ResizerTool.resizing_object:SetHighlightEnabled(false)
		ResizerTool.resizing_object = nil
		Events:CallRemote("ToggleResizing", {false})
	end
end)

-- Adds this tool to the Sandbox Spawn Menu
AddSpawnMenuItem("NanosWorld", "tools", "ResizerTool", "Resizer", "assets///NanosWorld/Thumbnails/SK_Blaster.jpg")