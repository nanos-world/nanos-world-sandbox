Text = Prop.Inherit("Text")

ConfigureSpawnLimits("Text", "Texts", Text.GetCount, "max_texts")

function Text:Constructor(location, rotation)
	self.Super:Constructor(location, rotation + Rotator(0, 180, 0), "nanos-world::SM_Cube", CollisionType.StaticOnly, false)
	self:SetMaterial("nanos-world::M_None")

	self.text_render = TextRender(location, Rotator(), "nanos world!", 40, Color.WHITE, TextRenderHorizontalAlignment.Center, TextRenderVerticalAlignment.Center, false, "nanos-world::Font_LondrinaSolid_DistanceField")
	self.text_render:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)

	self:UpdateScale()

	self:SetValue("TextRender", self.text_render, true)
end

function Text:UpdateScale()
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

function Text:SetText(player, text)
	self.text_render:SetText(text)

	self:UpdateScale()
end

function Text:SetColor(player, color)
	self.text_render:SetColor(color)
end

function Text:SetWordSize(player, size)
	self.text_render:SetWordSize(size)

	self:UpdateScale()
end

Text.SubscribeRemote("SetText", Text.SetText)
Text.SubscribeRemote("SetColor", Text.SetColor)
Text.SubscribeRemote("SetWordSize", Text.SetWordSize)