BaseButton = Prop.Inherit("BaseButton")

ConfigureSpawnLimits("Button", "Buttons", BaseButton.GetCount, "max_buttons")

function BaseButton:Constructor(location, rotation, tab, id, player, switchable)
	self.Super:Constructor(location, rotation, "nanos-world::SM_PushButton", CollisionType.Auto, true, GrabMode.Enabled)

	-- Cooldown in milliseconds
	self.cooldown = 500
	self.cooldown_timeout = nil
	self.last_pressed_time = 0

	-- Makes it switchable by default
	self:SetSwitchable(player, switchable or true)

	-- Starts off by default
	self.is_active = false

	-- Linked entities (note that destroyed entities may still exist if they are not gced yet)
	self.linked_entities = setmetatable({}, { __mode = "k" })

	if (player) then
		Events.CallRemote("AddNotification", player, NotificationType.Info, "BUTTON_WIRE_TUTORIAL", "use a Wire Gun to link buttons to other entities", 10, 5)
	end
end

function BaseButton:SetActivatedColor(player, color)
	self.activated_color = color
	self:SetValue("ActivatedColor", color, true)

	if (self.is_active) then
		self:SetMaterialColorParameter("Tint", color)
	end
end

function BaseButton:SetDeactivatedColor(player, color)
	self.deactivated_color = color
	self:SetValue("DeactivatedColor", color, true)

	if (not self.is_active) then
		self:SetMaterialColorParameter("Tint", color)
	end
end

function BaseButton:SetSwitchable(player, switchable)
	self.switchable = switchable
	self:SetValue("Switchable", switchable, true)
end

function BaseButton:Press(player_instigator, causer)
	-- Test cooldown
	if (self.cooldown > 0) then
		local now = Server.GetTime()
		if (now - self.last_pressed_time < self.cooldown) then
			return false
		end

		self.last_pressed_time = now
	end

	-- If switchable and is active, then deactivate, else always activate
	if (self.switchable and self.is_active) then
		self:Deactivate(player_instigator, causer)
	else
		self:Activate(player_instigator, causer)
	end

	return false
end

function BaseButton:OnInteract(character)
	self:Press(character:GetPlayer(), character)
	return false
end

function BaseButton:LinkEntity(entity, show_wire, wire_color)
	-- Already linked
	if (self.linked_entities[entity]) then
		return false
	end

	local link_data = {}

	if (show_wire) then
		local cable = Cable(self:GetLocation(), true)
		cable:SetMaterial("nanos-world::M_Default_Masked_Lit")
		cable:SetMaterialColorParameter("Tint", wire_color or Color.BLACK)
		cable:SetCableSettings(1, 1)
		cable:SetRenderingSettings(2, 4, 1)
		cable:AttachStartTo(self)
		cable:AttachEndTo(entity)

		link_data = {
			cable = cable
		}
	end

	self.linked_entities[entity] = link_data

	return true
end

function BaseButton:UnlinkAllEntities()
	for entity, linked_entity_data in pairs(self.linked_entities) do
		if (linked_entity_data.cable and linked_entity_data.cable:IsValid()) then
			linked_entity_data.cable:Destroy()
		end
	end

	self.linked_entities = setmetatable({}, { __mode = "k" })
end

function BaseButton:UnlinkEntity(entity)
	local linked_entity = self.linked_entities[entity]
	if (not linked_entity) then
		return false
	end

	if (linked_entity.cable and linked_entity.cable:IsValid()) then
		linked_entity.cable:Destroy()
	end

	self.linked_entities[entity] = nil

	return true
end

function BaseButton:Activate(player_instigator, causer, activated_entities)
	-- Prevents recursion
	if (activated_entities) then
		if (activated_entities[self]) then return end
	else
		activated_entities = {}
	end

	activated_entities[self] = true

	self.is_active = true

	-- Disables pressing and changes color if have cooldown
	if (self.cooldown > 0) then
		self:SetGrabMode(GrabMode.Disabled)
		self:SetMaterialColorParameter("Tint", self.activated_color or Color.GREEN)

		self.cooldown_timeout = Timer.SetTimeout(function()
			self.cooldown_timeout = nil
			self:ResetCooldown()

			-- Resets active as well if not switchable, so we always come back to is_active = false
			if (not self.switchable) then
				self.is_active = false
			end
		end, self.cooldown)

		Timer.Bind(self.cooldown_timeout, self)
	end

	-- Calls the remote event on clients
	self:BroadcastRemoteEvent("OnActivated")

	-- Activates all linked entities
	for entity, _ in pairs(self.linked_entities) do
		if (entity and entity:IsValid()) then
			if (entity.Activate) then
				entity:Activate(player_instigator, self, activated_entities)
			end
		else
			self.linked_entities[entity] = nil
		end
	end
end

function BaseButton:Deactivate(player_instigator, causer, deactivated_entities)
	-- Prevents recursion
	if (deactivated_entities) then
		if (deactivated_entities[self]) then return end
	else
		deactivated_entities = {}
	end

	deactivated_entities[self] = true

	self.is_active = false

	-- Disables pressing and changes color if have cooldown
	if (self.cooldown > 0) then
		self:SetGrabMode(GrabMode.Disabled)
		self:SetMaterialColorParameter("Tint", self.deactivated_color or Color.RED)

		-- Resets cooldown after the time
		self.cooldown_timeout = Timer.SetTimeout(function()
			self.cooldown_timeout = nil
			self:ResetCooldown()
		end, self.cooldown)

		Timer.Bind(self.cooldown_timeout, self)
	end

	-- Calls the remote event on clients
	self:BroadcastRemoteEvent("OnDeactivated")

	-- Deactivates all linked entities
	for entity, _ in pairs(self.linked_entities) do
		if (entity and entity:IsValid()) then
			if (entity.Deactivate) then
				entity:Deactivate(player_instigator, self, deactivated_entities)
			end
		else
			self.linked_entities[entity] = nil
		end
	end
end

function BaseButton:ResetCooldown()
	if (self.cooldown_timeout) then
		Timer.ClearTimeout(self.cooldown_timeout)
		self.cooldown_timeout = nil
	end

	-- Re-enables interacting
	self:SetGrabMode(GrabMode.Enabled)

	-- If not switchable, then we turn the color back, otherwise don't do nothing and keep the existing color
	if (not self.switchable) then
		local color = self.is_active and (self.deactivated_color or Color.RED) or (self.activated_color or Color.GREEN)
		self:SetMaterialColorParameter("Tint", color)
	end
end

function BaseButton:SetActivateLabel(player, label)
	self:SetValue("ActivateLabel", label, true)
	self:BroadcastRemoteEvent("UpdateLabel")
end

function BaseButton:SetDeactivateLabel(player, label)
	self:SetValue("DeactivateLabel", label, true)
	self:BroadcastRemoteEvent("UpdateLabel")
end

BaseButton.Subscribe("Interact", BaseButton.OnInteract)
BaseButton.SubscribeRemote("Press", BaseButton.Press)
BaseButton.SubscribeRemote("SetSwitchable", BaseButton.SetSwitchable)
BaseButton.SubscribeRemote("SetActivatedColor", BaseButton.SetActivatedColor)
BaseButton.SubscribeRemote("SetDeactivatedColor", BaseButton.SetDeactivatedColor)
BaseButton.SubscribeRemote("SetActivateLabel", BaseButton.SetActivateLabel)
BaseButton.SubscribeRemote("SetDeactivateLabel", BaseButton.SetDeactivateLabel)


-- TODO Children Buttons with custom tint, custom model?