BaseButton = Prop.Inherit("BaseButton")

BaseButton.name = "Button"
BaseButton.image = "assets://nanos-world/Thumbnails/SM_PushButton.jpg"
BaseButton.category = "logic"

-- Context Menu Items when selecting this Entity
BaseButton.selected_context_menu_items = {
	{
		id = "button_switchable",
		type = "checkbox",
		label = "switchable",
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetSwitchable", value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Switchable")
		end
	},
	{
		id = "button_activated_color",
		type = "color",
		label = "activated color",
		callback = function(color)
			ContextMenu.selected_entity:CallRemoteEvent("SetActivatedColor", Color.FromHEX(color))
		end,
		value = function()
			return Color.ToHex(ContextMenu.selected_entity:GetValue("ActivatedColor") or Color.GREEN, false)
		end
	},
	{
		id = "button_activate_tooltip",
		type = "text",
		label = "activate text",
		callback = function(text)
			ContextMenu.selected_entity:CallRemoteEvent("SetActivateLabel", text)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("ActivateLabel") or "activate"
		end
	},
	{
		id = "button_deactivated_color",
		type = "color",
		label = "deactivated color",
		callback = function(color)
			ContextMenu.selected_entity:CallRemoteEvent("SetDeactivatedColor", Color.FromHEX(color))
		end,
		value = function()
			return Color.ToHex(ContextMenu.selected_entity:GetValue("DeactivatedColor") or Color.RED, false)
		end
	},
	{
		id = "button_deactivate_tooltip",
		type = "text",
		label = "deactivate text",
		callback = function(text)
			ContextMenu.selected_entity:CallRemoteEvent("SetDeactivateLabel", text)

			if (ContextMenu.selected_entity.is_active) then
				ContextMenu.selected_entity:SetInteractionToolTipText(text)
			end
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("DeactivateLabel") or "deactivate"
		end
	},
	{
		id = "button_press",
		type = "button",
		label = "force press",
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("Press")
		end,
	}
}
-- TODO config sound


function BaseButton:OnSpawn()
	self:SetInteractionToolTipText(self:GetValue("ActivateLabel") or "activate")
end

function BaseButton:OnActivated()
	if (self:GetValue("Switchable")) then
		self:SetInteractionToolTipText(self:GetValue("DeactivateLabel") or "deactivate")
		self.is_active = true
	end

	local sound = Sound(self:GetLocation(), "nanos-world::A_Switch_Button_01", false, true, SoundType.SFX, 1, 1.1, nil, nil, AttenuationFunction.NaturalSound)
end

function BaseButton:OnDeactivated()
	self:SetInteractionToolTipText(self:GetValue("ActivateLabel") or "activate")

	self.is_active = false

	local sound = Sound(self:GetLocation(), "nanos-world::A_Switch_Button_01", false, true, SoundType.SFX, 1, 0.9, nil, nil, AttenuationFunction.NaturalSound)
end

function BaseButton:OnUpdateLabel()
	if (self.is_active) then
		self:SetInteractionToolTipText(self:GetValue("DeactivateLabel") or "activate")
	else
		self:SetInteractionToolTipText(self:GetValue("ActivateLabel") or "deactivate")
	end
end

BaseButton.Subscribe("Spawn", BaseButton.OnSpawn)
BaseButton.SubscribeRemote("OnActivated", BaseButton.OnActivated)
BaseButton.SubscribeRemote("OnDeactivated", BaseButton.OnDeactivated)
BaseButton.SubscribeRemote("UpdateLabel", BaseButton.OnUpdateLabel)
