TV = Prop.Inherit("TV")

function TV:Constructor(location, rotation)
	-- Default Values
	location = location or Vector()
	rotation = (rotation or Rotator()) + Rotator(0, 90, 0)

	self.Super:Constructor(location, rotation, "nanos-world::SM_TV", CollisionType.Auto, true, GrabMode.Enabled)

	self:SetScale(Vector(2, 2, 2))

	-- Spawns the Sound Box
	local soundbox_01 = Prop(location + rotation:UnrotateVector(Vector(200, 0, 0)), rotation, "nanos-world::SM_HalfStack_Marshall")
	local soundbox_02 = Prop(location - rotation:UnrotateVector(Vector(200, 0, 0)), rotation, "nanos-world::SM_HalfStack_Marshall")

	-- Spawns Cables to visually connect both
	local cable_01 = Cable(location)
	local cable_02 = Cable(location)

	cable_01:SetLinearLimits(ConstraintMotion.Limited, ConstraintMotion.Limited, ConstraintMotion.Limited, 10000, 0, true, 10000, 100)
	cable_01:SetRenderingSettings(2, 4, 1)
	cable_01:SetMaterial("nanos-world::M_Default_Masked_Lit")
	cable_01:SetMaterialColorParameter("Tint", Color.BLACK)

	cable_02:SetLinearLimits(ConstraintMotion.Limited, ConstraintMotion.Limited, ConstraintMotion.Limited, 10000, 0, true, 10000, 100)
	cable_02:SetRenderingSettings(2, 4, 1)
	cable_02:SetMaterial("nanos-world::M_Default_Masked_Lit")
	cable_02:SetMaterialColorParameter("Tint", Color.BLACK)

	cable_01:AttachStartTo(self, Vector(0, 0, 15))
	cable_02:AttachStartTo(self, Vector(0, 0, 15))

	cable_01:AttachEndTo(soundbox_01, Vector(0, 0, 20))
	cable_02:AttachEndTo(soundbox_02, Vector(0, 0, 20))

	-- Registers so the Sounds are destroyed when the TV is destroyed
	self:SetValue("SoundBox_01", soundbox_01, true)
	self:SetValue("SoundBox_02", soundbox_02, true)
end

-- Subscribes to sync TV website with other players
function TV:SetWebsite(player, url)
	if (url == "") then
		self:SetValue("Website", "", true)
		return
	end

	-- Parse Link
	local parsed_url = GetYouTubeVideoIDFromURL(url)
	if (not parsed_url) then
		Console.Warn("TV: Trying to load an invalid YouTube URL: '%s'", url)
		self:SetValue("Website", false, true)
		return
	end

	local embed_url = BuildYouTubeEmbedURL(parsed_url)

	-- Send to everyone
	self:SetValue("Website", embed_url, true)
end

function TV:OnDestroy()
	local _soundbox_01 = self:GetValue("SoundBox_01")
	if (_soundbox_01 and _soundbox_01:IsValid()) then _soundbox_01:Destroy() end

	local _soundbox_02 = self:GetValue("SoundBox_02")
	if (_soundbox_02 and _soundbox_02:IsValid()) then _soundbox_02:Destroy() end
end

-- Overrides Interact (to avoid Players picking it up, and instead open a PopUp)
function TV:OnInteract(character)
	Events.CallRemote("InteractTV", character:GetPlayer(), self)

	-- Returns false to prevent picking it up
	return false
end

TV.Subscribe("Destroy", TV.OnDestroy)
TV.Subscribe("Interact", TV.OnInteract)
TV.SubscribeRemote("SetWebsite", TV.SetWebsite)


-- Extracts Video ID from YouTube URL
function GetYouTubeVideoIDFromURL(url)
	local video_id_and_parameters = url:match("youtube.com/watch%?v=(.*)")
	if (not video_id_and_parameters) then
		return false
	end

	local video_id = video_id_and_parameters:gsub("&.*", "")
	return video_id
end

-- Builds an auto play embed YouTube URL
function BuildYouTubeEmbedURL(video_id)
	return "https://www.youtube-nocookie.com/embed/" .. video_id .. "?autoplay=1&modestbranding=1&rel=0&iv_load_policy=3&fs=0&controls=0&disablekb=1"
end