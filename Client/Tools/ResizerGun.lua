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
ResizerGun.current_scale = 1
ResizerGun.min_object_scale = 0.1 -- (Note: also configured in Server/Tools/ResizerGun.lua)
ResizerGun.max_object_scale = 20 -- (Note: also configured in Server/Tools/ResizerGun.lua)


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
	local trace_result = TraceFor(10000, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle)

	-- If hit an object, then sets this object to be the "resized" one
	if (trace_result.Success and trace_result.Entity and not trace_result.Entity:HasAuthority()) then
		ResizerGun.resizing_object = trace_result.Entity
		ResizerGun.current_scale = ResizerGun.resizing_object:GetScale().X
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
	character:Subscribe("WeaponAimModeChange", ResizerGunWeaponAimModeChanged)
	Input.Subscribe("MouseScroll", ResizerGunMouseScroll)
	Input.Subscribe("KeyPress", ResizerGunKeyPress)

	-- Sets some notification when grabbing the Tool
	AddNotification("RESIZER_GUIDE", "hold down Left Mouse to select an object, then use mouse wheel to size it up or down", 10000, 5000)
end

-- Overrides Tool Gun's OnLocalPlayerDrop
function ResizerGun:OnLocalPlayerDrop(character)
	ResizerGun.weapon = nil

	self:Unsubscribe("ReleaseUse", ResizerGun.OnReleaseUse)
	character:Unsubscribe("WeaponAimModeChange", ResizerGunWeaponAimModeChanged)
	Input.Unsubscribe("MouseScroll", ResizerGunMouseScroll)
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

function ResizerGunMouseScroll(mouse_x, mouse_y, delta)
	if (not ResizerGun.weapon or not ResizerGun.resizing_object) then return end

	-- Scroll up/down to increase/decrease the scale; clamped on server-side
	ResizerGun.current_scale = ResizerGun.current_scale + ResizerGun.current_scale * 0.1 * delta

	-- Cannot resize too big or too small
	ResizerGun.current_scale = NanosMath.Clamp(ResizerGun.current_scale, ResizerGun.min_object_scale, ResizerGun.max_object_scale)

	ResizerGun.weapon:CallRemoteEvent("ResizeObject", ResizerGun.resizing_object, ResizerGun.current_scale, true)
end

function ResizerGunKeyPress(key_name)
	if (not ResizerGun.weapon or not ResizerGun.resizing_object) then return end

	if (key_name == "R") then
		ResizerGun.current_scale = 1
		ResizerGun.weapon:CallRemoteEvent("ResizeObject", ResizerGun.resizing_object, 1, true)
	end
end