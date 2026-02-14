ToolGun = Weapon.Inherit("ToolGun")

ToolGun.category = "tool-guns"

-- Used on Tick to draw a Debug.Crosshair in the world to point where it's aiming
ToolGun.draw_debug_toolgun = nil
ToolGun.preview_mesh_prop = nil


-- Called when the Local Player picks up this ToolGun
function ToolGun:__OnLocalPlayerPickUp(character)
	local class = self:GetClass()

	-- Shows the tutorials on screen
	Tutorials.Show(class.name, class.description or "", class.tutorials or {})

	-- Subscribes for LocalPlayer events
	character:Subscribe("WeaponAimModeChange", ToolGun.OnLocalPlayerWeaponAimModeChanged)
	self:Subscribe("Fire", ToolGun.__OnLocalPlayerFire)

	-- Calls children method
	self:OnLocalPlayerPickUp(character)
end

-- Called when the Local Player drops this ToolGun
function ToolGun:__OnLocalPlayerDrop(character)
	Tutorials.Hide()
	self:ToggleToolGunAiming(false)

	-- Unsubscribes for LocalPlayer events
	self:Unsubscribe("Fire", ToolGun.__OnLocalPlayerFire)
	character:Unsubscribe("WeaponAimModeChange", ToolGun.OnLocalPlayerWeaponAimModeChanged)

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
	local debug_trace = self.debug_trace
	if (not debug_trace or not debug_trace.collision_channel) then return end

	-- Set defaults
	if (debug_trace.show_preview_mesh) then
		if (not debug_trace.preview_mesh) then debug_trace.preview_mesh = "nanos-world::SM_Toaster" end
		if (not debug_trace.preview_mesh_scale) then debug_trace.preview_mesh_scale = Vector(1, 1, 1) end
		if (not debug_trace.preview_mesh_offset) then debug_trace.preview_mesh_offset = Vector(0, 0, 0) end
		if (not debug_trace.preview_mesh_rotation) then debug_trace.preview_mesh_rotation = Rotator(0, 0, 0) end
	end

	if (enable) then
		ToolGun.draw_debug_toolgun = self
		Client.Subscribe("Tick", ToolGun.OnDebugTick)
	else
		ToolGun.ToggleDrawDebugPreviewMesh(false)
		ToolGun.draw_debug_toolgun = nil
		Client.Unsubscribe("Tick", ToolGun.OnDebugTick)
	end
end

-- Called when the LocalPlayer changes the Aim Mode
function ToolGun.OnLocalPlayerWeaponAimModeChanged(character, old_state, new_state)
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

	local start_location = viewport_3D.Position + viewport_3D.Direction * 50
	local end_location = viewport_3D.Position + viewport_3D.Direction * trace_max_distance

	local trace_mode = TraceMode.TraceComplex | TraceMode.ReturnEntity | TraceMode.TraceOnlyVisibility

	local ignored_actors = { Client.GetLocalPlayer():GetControlledCharacter() }

	return Trace.LineSingle(start_location, end_location, collision_channel, trace_mode, ignored_actors)
end

function ToolGun.ToggleDrawDebugPreviewMesh(enable, default_location, default_rotation)
	if (not ToolGun.draw_debug_toolgun or not ToolGun.draw_debug_toolgun.debug_trace.show_preview_mesh) then return end

	if (enable) then
		-- Spawns the mesh if didn't exist
		if (not ToolGun.preview_mesh_prop or not ToolGun.preview_mesh_prop:IsValid()) then
			ToolGun.preview_mesh_prop = Prop(default_location, default_rotation, ToolGun.draw_debug_toolgun.debug_trace.preview_mesh, CollisionType.NoCollision, false, GrabMode.Disabled, CCDMode.Disabled)

			ToolGun.preview_mesh_prop:SetScale(ToolGun.draw_debug_toolgun.debug_trace.preview_mesh_scale)
			ToolGun.preview_mesh_prop:SetMaterial("nanos-world::M_Default_Translucent_Lit")
			ToolGun.preview_mesh_prop:SetMaterialColorParameter("Tint", Color.GREEN)
			ToolGun.preview_mesh_prop:SetMaterialColorParameter("Emissive", Color.GREEN * 0.5)
			ToolGun.preview_mesh_prop:SetMaterialScalarParameter("Opacity", 0.8)
		else
			-- If it already exists and is not visible, then updates it
			if (not ToolGun.preview_mesh_prop:IsVisible()) then
				ToolGun.preview_mesh_prop:SetLocation(default_location)
				ToolGun.preview_mesh_prop:SetRotation(default_rotation)

				if (ToolGun.preview_mesh_prop:GetScale() ~= ToolGun.draw_debug_toolgun.debug_trace.preview_mesh_scale) then
					ToolGun.preview_mesh_prop:SetScale(ToolGun.draw_debug_toolgun.debug_trace.preview_mesh_scale)
				end

				if (ToolGun.preview_mesh_prop:GetMesh() ~= ToolGun.draw_debug_toolgun.debug_trace.preview_mesh) then
					ToolGun.preview_mesh_prop:SetMesh(ToolGun.draw_debug_toolgun.debug_trace.preview_mesh)
				end

				ToolGun.preview_mesh_prop:SetVisibility(true)
			end
		end
	else
		if (ToolGun.preview_mesh_prop and ToolGun.preview_mesh_prop:IsValid()) then
			ToolGun.preview_mesh_prop:SetVisibility(false)
		end
	end
end

-- Called on Tick when possessing a ToolGun to draw a Crosshair in the world
function ToolGun.OnDebugTick(delta_time)
	-- Does not trace if ContextMenu or SpawnMenu are open
	if (ContextMenu.is_opened or SpawnMenu.is_opened) then
		ToolGun.ToggleDrawDebugPreviewMesh(false)
		return
	end

	local debug_trace = ToolGun.draw_debug_toolgun.debug_trace
	local trace_result = TraceFor(2000, debug_trace.collision_channel)

	if (not trace_result.Success) then
		ToolGun.ToggleDrawDebugPreviewMesh(false)
		return
	end

	local trace_normal_rotation = trace_result.Normal:Rotation()
	local trace_location = trace_result.Location

	-- Draws a preview mesh
	if (ToolGun.draw_debug_toolgun.debug_trace.show_preview_mesh) then
		local preview_mesh_rotation = ToolGun.draw_debug_toolgun.debug_trace.preview_mesh_rotation

		if (not ToolGun.draw_debug_toolgun.debug_trace.preview_mesh_rotation_fixed) then
			preview_mesh_rotation = preview_mesh_rotation + trace_normal_rotation
		end

		local preview_mesh_location = trace_location - preview_mesh_rotation:UnrotateVector(ToolGun.draw_debug_toolgun.debug_trace.preview_mesh_offset * ToolGun.draw_debug_toolgun.debug_trace.preview_mesh_scale)

		ToolGun.ToggleDrawDebugPreviewMesh(true, preview_mesh_location, preview_mesh_rotation)

		ToolGun.preview_mesh_prop:TranslateTo(preview_mesh_location, 0.0167)
		ToolGun.preview_mesh_prop:RotateTo(preview_mesh_rotation, 0.0167)
	end

	-- Draws a crosshair
	if (ToolGun.draw_debug_toolgun.debug_trace.show_crosshair) then
		local color = nil
		local is_toolgun_double_target = ToolGun.draw_debug_toolgun:IsA(ToolGunDoubleTarget)

		-- If hit an entity, GREEN
		if (trace_result.Entity) then
			-- If is targeting double and the first target is the same as the hit entity, BLACK (to cancel)
			if (is_toolgun_double_target and ToolGunDoubleTarget.targeting_first_to == trace_result.Entity) then
				color = Color.BLACK
			else
				color = Color.GREEN
			end
		else
			-- Otherwise check if we are targeting double and we already found the first target
			if (is_toolgun_double_target and ToolGunDoubleTarget.targeting_first_to == nil) then
				color = Color.RED
			else
				color = Color.BLUE
			end
		end

		-- Draws a Crosshair in the world where the player is aiming
		Debug.DrawCrosshairs(trace_location, Rotator(), 25, color, 0, 2)
	end
end

ToolGun.SubscribeRemote("LocalPlayerPickUp", ToolGun.__OnLocalPlayerPickUp)
ToolGun.SubscribeRemote("LocalPlayerDrop", ToolGun.__OnLocalPlayerDrop)


Package.Require("Tools/BaseToolGunSingleTarget.lua")
Package.Require("Tools/BaseToolGunDoubleTarget.lua")