ResizerGun = ToolGun.Inherit("ResizerGun")

-- Tool Name
ResizerGun.name = "Resizer Gun"

-- Tool Image
ResizerGun.image = "package://sandbox/Client/Tools/ResizerGun.webp"

-- Tool Tutorials
ResizerGun.tutorials = {
	{ key = "LeftClick", text = "select object" },
	{ key = "R", text = "reset scale" },
	{ key = "MouseScrollUp", text = "scale" },
}

-- ResizerGun Configuration
ResizerGun.resizing_object = nil
ResizerGun.weapon = nil
ResizerGun.current_scale = Vector(1)


function ResizerGun:OnReleaseUse(character)
	if (ResizerGun.resizing_object) then
		ResizerGun.resizing_object:SetHighlightEnabled(false)
		ResizerGun.resizing_object = nil
		Events.CallRemote("ToggleResizing", false)
	end
end

-- Overrides Tool Gun's OnLocalPlayerFire
function ResizerGun:OnLocalPlayerFire(character)
	-- Makes a trace 10000 units ahead
	local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn)

	-- If hit an object, then sets this object to be the "resized" one
	if (trace_result.Success and trace_result.Entity and not trace_result.Entity:HasAuthority()) then
		ResizerGun.resizing_object = trace_result.Entity
		ResizerGun.current_scale = ResizerGun.resizing_object:GetScale()
		ResizerGun.resizing_object:SetHighlightEnabled(true, 0)
		Events.CallRemote("ToggleResizing", true)
	else
		-- If didn't hit anything, plays a negative sound
		SoundInvalidAction:Play()
	end
end

-- Overrides Tool Gun's OnLocalPlayerPickUp
function ResizerGun:OnLocalPlayerPickUp(character)
	ResizerGun.weapon = self

	self:Subscribe("ReleaseUse", ResizerGun.OnReleaseUse)
	character:Subscribe("WeaponAimModeChanged", ResizerGunWeaponAimModeChanged)
	Input.Subscribe("MouseUp", ResizerGunMouseUp)
	Input.Subscribe("KeyPress", ResizerGunKeyPress)

	-- Sets some notification when grabbing the Tool
	AddNotification("RESIZER_GUIDE", "hold down Left Mouse to select an object, then use mouse wheel to size it up or down", 10000, 5000)
end

-- Overrides Tool Gun's OnLocalPlayerDrop
function ResizerGun:OnLocalPlayerDrop(character)
	ResizerGun.weapon = nil

	self:Unsubscribe("ReleaseUse", ResizerGun.OnReleaseUse)
	character:Unsubscribe("WeaponAimModeChanged", ResizerGunWeaponAimModeChanged)
	Input.Unsubscribe("MouseUp", ResizerGunMouseUp)
	Input.Unsubscribe("KeyPress", ResizerGunKeyPress)

	if (ResizerGun.resizing_object) then
		ResizerGun.resizing_object:SetHighlightEnabled(false)
		ResizerGun.resizing_object = nil
		Events.CallRemote("ToggleResizing", false)
	end
end

function ResizerGunWeaponAimModeChanged(character, old_state, new_state)
	if (new_state == AimMode.None and ResizerGun.resizing_object) then
		ResizerGun.resizing_object:SetHighlightEnabled(false)
		ResizerGun.resizing_object = nil
		Events.CallRemote("ToggleResizing", false)
	end
end

function ResizerGunMouseUp(key_name)
	if (not ResizerGun.weapon) then return end

	-- Scrolls up to increase the scale
	if (key_name == "MouseScrollUp") then
		if (ResizerGun.resizing_object) then
			ResizerGun.current_scale = ResizerGun.current_scale + ResizerGun.current_scale * 0.1

			-- Cannot resize too big
			if (ResizerGun.current_scale.X > 20) then
				ResizerGun.current_scale = Vector(20)
			end

			ResizerGun.weapon:CallRemoteEvent("ResizeObject", ResizerGun.resizing_object, ResizerGun.current_scale, true)
		end
		return
	end

	-- Scrolls down to dencrease the scale
	if (key_name == "MouseScrollDown") then
		if (ResizerGun.resizing_object) then
			ResizerGun.current_scale = ResizerGun.current_scale - ResizerGun.current_scale * 0.1

			-- Cannot resize too small
			if (ResizerGun.current_scale.X < 0.1) then
				ResizerGun.current_scale = Vector(0.1)
			end

			ResizerGun.weapon:CallRemoteEvent("ResizeObject", ResizerGun.resizing_object, ResizerGun.current_scale, false)
		end
		return
	end
end

function ResizerGunKeyPress(key_name)
	if (not ResizerGun.weapon or not ResizerGun.resizing_object) then return end

	if (key_name == "R") then
		ResizerGun.current_scale = Vector(1, 1, 1)
		ResizerGun.weapon:CallRemoteEvent("ResizeObject", ResizerGun.resizing_object, Vector(1, 1, 1), true)
	end
end