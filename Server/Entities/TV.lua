function SpawnTV(location, rotation)
	-- Default Values
	location = location or Vector()
	rotation = (rotation or Rotator()) + Rotator(0, 90, 0)

	-- Spawns a TV prop
	local prop = Prop(location, rotation, "nanos-world::SM_TV", CollisionType.Auto, true, GrabMode.Enabled)
	prop:SetScale(Vector(2, 2, 2))
	prop:SetValue("TV", true, true)

	-- Spawns the Sound Box
	local soundbox_01 = Prop(location + rotation:UnrotateVector(Vector(200, 0, 0)), rotation, "nanos-world::SM_HalfStack_Marshall")
	local soundbox_02 = Prop(location - rotation:UnrotateVector(Vector(200, 0, 0)), rotation, "nanos-world::SM_HalfStack_Marshall")

	-- Spawns Cables to visually connect both
	local cable_01 = Cable(location)
	local cable_02 = Cable(location)

	cable_01:SetLinearLimits(ConstraintMotion.Limited, ConstraintMotion.Limited, ConstraintMotion.Limited, 10000, 0, true, 10000, 100)
	cable_01:SetRenderingSettings(2, 4, 1)
	cable_01:SetMaterial("nanos-world::M_NanosMasked")
	cable_01:SetMaterialColorParameter("Tint", Color.BLACK)

	cable_02:SetLinearLimits(ConstraintMotion.Limited, ConstraintMotion.Limited, ConstraintMotion.Limited, 10000, 0, true, 10000, 100)
	cable_02:SetRenderingSettings(2, 4, 1)
	cable_02:SetMaterial("nanos-world::M_NanosMasked")
	cable_02:SetMaterialColorParameter("Tint", Color.BLACK)

	cable_01:AttachStartTo(prop, Vector(0, 0, 15))
	cable_02:AttachStartTo(prop, Vector(0, 0, 15))

	cable_01:AttachEndTo(soundbox_01, Vector(0, 0, 20))
	cable_02:AttachEndTo(soundbox_02, Vector(0, 0, 20))

	-- Registers so the Sounds are destroyed when the TV is destroyed
	prop:SetValue("SoundBox_01", soundbox_01, true)
	prop:SetValue("SoundBox_02", soundbox_02, true)

	prop:Subscribe("Destroy", function(p)
		local _soundbox_01 = p:GetValue("SoundBox_01")
		if (_soundbox_01 and _soundbox_01:IsValid()) then _soundbox_01:Destroy() end

		local _soundbox_02 = p:GetValue("SoundBox_02")
		if (_soundbox_02 and _soundbox_02:IsValid()) then _soundbox_02:Destroy() end
	end)

	-- Overrides Interact (to avoid Players picking it up, and instead open a PopUp)
	prop:Subscribe("Interact", function(_tv_prop, character)
		Events.CallRemote("InteractTV", character:GetPlayer(), _tv_prop)

		-- Returns false to prevent picking it up
		return false
	end)

	return prop
end

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

-- Subscribes to sync TV website with other players
Events.Subscribe("OnTVSetWebsite", function(player, tv, url)
	-- Parse Link
	local parsed_url = GetYouTubeVideoIDFromURL(url)
	if (not parsed_url) then
		-- TODO send error notification
		Package.Warn("Trying to load an invalid YouTube URL: '%s'", url)
		return
	end

	local embed_url = BuildYouTubeEmbedURL(parsed_url)

	-- Send to everyone
	Events.BroadcastRemote("OnTVSetWebsite", tv, embed_url)
end)


-- Adds this weapon to the Sandbox Spawn Menu
AddSpawnMenuItem("nanos-world", "entities", "TV", SpawnTV)
