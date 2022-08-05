CURRENTLY_INTERACTING_TV = nil

-- Subscribes from WebUI, to know when the PopUp has been submitted
MainHUD:Subscribe("OnTVSetWebsite", function(submitted, text)
	Client.SetMouseEnabled(false)
	Client.SetInputEnabled(true)

	if (not submitted) then
		CURRENTLY_INTERACTING_TV = nil
		return
	end

	if (not CURRENTLY_INTERACTING_TV or not CURRENTLY_INTERACTING_TV:IsValid()) then
		Package.Error("Failed to find currently interacting TV!")
		return
	end

	-- Calls remote to sync the Website with everyone logged
	Events.CallRemote("OnTVSetWebsite", CURRENTLY_INTERACTING_TV, text)
end)

-- Event from server to set a website in a TV
Events.Subscribe("OnTVSetWebsite", function(tv, url)
	-- Checks if the WebUI already exists
	local website_webui_value = tv:GetValue("MaterialWebUI")

	-- If so, just reloads the page
	if (website_webui_value and website_webui_value:IsValid()) then
		website_webui_value:LoadURL(url)
		return
	end

	-- Spawns the WebUI
	local webui = WebUI("TV", url, false, false, false, 1120, 630)

	-- Spawns the Sound from the WebUI and attaches to the TV prop
	local soundbox_01 = tv:GetValue("SoundBox_01")
	local sound_01 = webui:SpawnSound(tv:GetLocation(), false, 10, 100, 3600, AttenuationFunction.NaturalSound)
	sound_01:AttachTo(soundbox_01, AttachmentRule.SnapToTarget, "", 0)

	local soundbox_02 = tv:GetValue("SoundBox_02")
	local sound_02 = webui:SpawnSound(tv:GetLocation(), false, 10, 100, 3600, AttenuationFunction.NaturalSound)
	sound_02:AttachTo(soundbox_02, AttachmentRule.SnapToTarget, "", 0)

	-- Sets the new WebUI as the Material
	tv:SetMaterialFromWebUI(webui, 1)
	tv:SetMaterialColorParameter("Emissive", Color(10, 10, 10))

	-- Stores the WebUI in the entity to be destroyed later
	tv:SetValue("MaterialWebUI", webui)

	-- When entity is destroyed, destroy the WebUI as well
	tv:Subscribe("Destroy", function(item)
		local _website_webui_value = item:GetValue("MaterialWebUI")

		if (_website_webui_value and _website_webui_value:IsValid()) then
			_website_webui_value:Destroy()
		end
	end)
end)

-- Called by Server when Player interacts with a TV
Events.Subscribe("InteractTV", function(tv_prop)
	CURRENTLY_INTERACTING_TV = tv_prop

	-- Disables Input
	Client.SetMouseEnabled(true)
	Client.SetInputEnabled(false)

	-- Opens PopUp to enter the TV URL
	MainHUD:CallEvent("ShowPopUpPrompt", "enter a YouTube URL", "OnTVSetWebsite")
end)



AddSpawnMenuItem("nanos-world", "entities", "TV", "TV", "assets://NanosWorld/Thumbnails/SM_TV.jpg", "uncategorized")
