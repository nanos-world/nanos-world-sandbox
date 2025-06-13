ToolGun = Weapon.Inherit("ToolGun")

-- Used on Tick to draw a Debug.Crosshair in the world to point where it's aiming
ToolGun.draw_debug_toolgun = nil

-- Called when the Local Player picks up this ToolGun
function ToolGun:__OnLocalPlayerPickUp(character)
	local class = self:GetClass()
	local tool_gun_tutorials = class.tutorials
	if (tool_gun_tutorials) then
		local tutorials_parsed = {}

		for _, tutorial_data in pairs(tool_gun_tutorials) do
			-- Get the mapped key or use it as Raw if didn't find (probably it's a raw key)
			local mapped_key = Input.GetMappedKeys(tutorial_data.key)[1] or tutorial_data.key

			-- Gets the image path
			local key_icon = Input.GetKeyIcon(mapped_key)

			table.insert(tutorials_parsed, { image = key_icon, text = tutorial_data.text })
		end

		MainHUD:CallEvent("ToggleTutorial", true, class.name, tutorials_parsed)
	end

	-- Subscribes for LocalPlayer events
	character:Subscribe("WeaponAimModeChange", OnToolGunLocalPlayerWeaponAimModeChanged)
	self:Subscribe("Fire", ToolGun.__OnLocalPlayerFire)

	-- Calls children method
	self:OnLocalPlayerPickUp(character)
end

-- Called when the Local Player drops this ToolGun
function ToolGun:__OnLocalPlayerDrop(character)
	MainHUD:CallEvent("ToggleTutorial", false)
	self:ToggleToolGunAiming(false)

	-- Unsubscribes for LocalPlayer events
	self:Unsubscribe("Fire", ToolGun.__OnLocalPlayerFire)
	character:Unsubscribe("WeaponAimModeChange", OnToolGunLocalPlayerWeaponAimModeChanged)

	-- Calls children method
	self:OnLocalPlayerDrop(character)
end

-- Internal callback
function ToolGun:__OnLocalPlayerFire(...)
	-- Call the method to be overridden on children
	self:OnLocalPlayerFire(...)
end

-- Method to be overridden on children, it has empty implementation
function ToolGun:OnLocalPlayerFire(...) end
function ToolGun:OnLocalPlayerPickUp(...) end
function ToolGun:OnLocalPlayerDrop(...) end

function ToolGun:ToggleToolGunAiming(enable)
	local crosshair_trace = self.crosshair_trace
	if (not crosshair_trace or not crosshair_trace.collision_channel) then return end
	if (not crosshair_trace.color_entity) then crosshair_trace.color_entity = Color.GREEN end
	if (not crosshair_trace.color_no_entity) then crosshair_trace.color_no_entity = Color.RED end

	if (enable) then
		ToolGun.draw_debug_toolgun = self
		Client.Subscribe("Tick", OnToolGunDebugTick)
	else
		ToolGun.draw_debug_toolgun = nil
		Client.Unsubscribe("Tick", OnToolGunDebugTick)
	end
end

-- Called when the LocalPlayer changes the Aim Mode
function OnToolGunLocalPlayerWeaponAimModeChanged(character, old_state, new_state)
	local tool = character:GetPicked()
	if (not tool) then return end

	-- Enables/Disables the tool gun debug crosshair
	if (new_state == AimMode.None) then
		tool:ToggleToolGunAiming(false)
	else
		tool:ToggleToolGunAiming(true)
	end
end

-- Aux for Tracing for world object
function TraceFor(trace_max_distance, collision_channel)
	local viewport_2D_center = Viewport.GetViewportSize() / 2
	local viewport_3D = Viewport.DeprojectScreenToWorld(viewport_2D_center)

	local start_location = viewport_3D.Position + viewport_3D.Direction * 100
	local end_location = viewport_3D.Position + viewport_3D.Direction * trace_max_distance

	return Trace.LineSingle(start_location, end_location, collision_channel, TraceMode.TraceComplex | TraceMode.ReturnEntity | TraceMode.TraceOnlyVisibility, { Client.GetLocalPlayer():GetControlledCharacter() })
end

-- Called on Tick when possessing a ToolGun to draw a Crosshair in the world
function OnToolGunDebugTick(delta_time)
	local crosshair_trace = ToolGun.draw_debug_toolgun.crosshair_trace
	local trace_result = TraceFor(2000, crosshair_trace.collision_channel)
	if (not trace_result.Success) then return end

	local color = trace_result.Entity and crosshair_trace.color_entity or crosshair_trace.color_no_entity

	-- Draws a Crosshair in the world where the player is aiming
	Debug.DrawCrosshairs(trace_result.Location, Rotator(), 25, color, 0, 2)
end

ToolGun.SubscribeRemote("LocalPlayerPickUp", ToolGun.__OnLocalPlayerPickUp)
ToolGun.SubscribeRemote("LocalPlayerDrop", ToolGun.__OnLocalPlayerDrop)



-- function ToggleToolGunAiming(weapon, tool, enable)
-- 	print("toggle", enable)
-- 	if (enable) then
-- 		if (
-- 			tool == "RopeTool" or
-- 			tool == "RemoverTool" or
-- 			tool == "ThrusterTool"
-- 		) then
-- 			DrawDebugToolGun.TraceCollisionChannel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle
-- 		else
-- 			DrawDebugToolGun.TraceCollisionChannel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn
-- 		end

-- 		if (
-- 			tool == "BalloonTool" or
-- 			tool == "LightTool" or
-- 			tool == "LampTool"
-- 		) then
-- 			DrawDebugToolGun.Weapon = weapon

-- 			DrawDebugToolGun.ColorEntity = Color.GREEN
-- 			DrawDebugToolGun.ColorNoEntity = Color.BLUE
-- 			return
-- 		elseif (
-- 			tool == "ColorTool" or
-- 			tool == "ThrusterTool" or
-- 			tool == "UselessTool" or
-- 			tool == "WeldTool" or
-- 			tool == "TrailTool" or
-- 			tool == "ResizerTool" or
-- 			tool == "RopeTool" or
-- 			tool == "RemoverTool"
-- 		) then
-- 			DrawDebugToolGun.Weapon = weapon

-- 			DrawDebugToolGun.ColorEntity = Color.GREEN
-- 			DrawDebugToolGun.ColorNoEntity = Color.RED
-- 			return
-- 		end
-- 	end

-- 	DrawDebugToolGun.Weapon = nil
-- end
