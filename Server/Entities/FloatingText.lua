FloatingText = Prop.Inherit("FloatingText")

ConfigureSpawnLimits("FloatingText", "Floating Texts", FloatingText.GetCount, "max_floating_texts")

function FloatingText:Constructor(location, rotation, tab, id, player)
	self.Super:Constructor(location, rotation + Rotator(0, 180, 0), "nanos-world::SM_Cube", CollisionType.StaticOnly, false)
	self:SetMaterial("nanos-world::M_None")

	self.text_render = TextRender(location, Rotator(), "nanos world!", 40, Color.WHITE, TextRenderRenderingType.Unlit, TextRenderHorizontalAlignment.Center, TextRenderVerticalAlignment.Center, "nanos-world::Font_LondrinaSolid_DistanceField", true)
	self.text_render:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)

	self:UpdateScale()

	self:SetValue("TextRender", self.text_render, true)

	if (player) then
		Events.CallRemote("AddNotification", player, NotificationType.Info, "FLOATING_TEXT_TUTORIAL", "you can change the Floating Text text by selecting it in the the Context Menu", 10, 5)
	end
end

function FloatingText:UpdateScale()
	local text = self.text_render:GetText()

	if (#text == 0) then
		self:SetScale(Vector(0.1, 0.2, 0.2))
		return
	end

	-- Finds number of lines and max characters in a line
	local lines = 0
	local max_line_chars = 0
	for line in text:gmatch("[^\n]+") do
		lines = lines + 1
		local line_length = #line
		if (line_length > max_line_chars) then
			max_line_chars = line_length
		end
	end

	local word_size = self.text_render:GetWordSize()

	-- Estimate scale based on SM_Cube (100x100x100) and line and max line length
	self:SetScale(Vector(0.1, max_line_chars * word_size * 0.004, lines * word_size * 0.011))
end

function FloatingText:SetText(player, text)
	-- Limits the text length
	text = text:sub(1, 512)

	self.text_render:SetText(text)

	self:UpdateScale()

	-- Overrides the last owner
	SpawnHistory.UpdateItemOwnership(player, self)
end

function FloatingText:SetColor(player, color)
	self.text_render:SetColor(color)
end

function FloatingText:SetWordSize(player, size)
	self.text_render:SetWordSize(size)

	self:UpdateScale()
end

FloatingText.SubscribeRemote("SetText", FloatingText.SetText)
FloatingText.SubscribeRemote("SetColor", FloatingText.SetColor)
FloatingText.SubscribeRemote("SetWordSize", FloatingText.SetWordSize)