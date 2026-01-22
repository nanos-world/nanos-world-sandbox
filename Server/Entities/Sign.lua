Sign = Prop.Inherit("Sign")

ConfigureSpawnLimits("Sign", "Signs", Sign.GetCount, "max_signs")

function Sign:Constructor(location, rotation)
	self.Super:Constructor(location, rotation + Rotator(0, 90, 0), "nanos-world::SM_Sign")

	self.text_render = TextRender(location, Rotator(), "nanos world!", 8, Color.WHITE, TextRenderHorizontalAlignment.Center, TextRenderVerticalAlignment.Center, true, "nanos-world::Font_BoldPixels_DistanceField")
	self.text_render:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)
	self.text_render:SetRelativeRotation(Rotator(0, 90, 0))
	self.text_render:SetRelativeLocation(Vector(0, 7, 146))

	self:SetValue("TextRender", self.text_render, true)
end

function Sign:SetText(player, text)
	self.text_render:SetText(text)

	-- TODO add line breaks automatically?
end

Sign.SubscribeRemote("SetText", Sign.SetText)