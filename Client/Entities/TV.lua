TV = Prop.Inherit("TV")

TV.name = "TV"
TV.image = "assets://nanos-world/Thumbnails/SM_TV.jpg"
TV.category = "uncategorized"


-- When TV is spawned, check if it has a URL playing already
function TV:OnSpawn()
	local website = self:GetValue("Website")

	if (website) then
		self:SetWebsite(website)
	end
end

-- When TV is destroyed, destroy the WebUI as well
function TV:OnDestroy()
	local webui = self:GetValue("MaterialWebUI")

	if (webui and webui:IsValid()) then
		webui:Destroy()
	end
end

function TV:OnValueChange(key, value)
	if (key == "Website") then
		self:SetWebsite(value)
	end
end

-- Event from server to set a website in a TV
function TV:SetWebsite(url)
	-- Checks if the WebUI already exists
	local website_webui_value = self:GetValue("MaterialWebUI")

	-- If so, just reloads the page
	if (website_webui_value and website_webui_value:IsValid()) then
		if (url == "") then
			website_webui_value:Destroy()
			self:ResetMaterial()
			self:Reset()
		elseif (not url) then
			website_webui_value:Destroy()
			self:SetNoSignal()
		else
			website_webui_value:LoadURL(url)
			self:SetWebUIMaterial(website_webui_value)
		end
		return
	end

	if (url == "") then
		self:ResetMaterial()
		self:Reset()
		return
	elseif (not url) then
		self:SetNoSignal()
		return
	end

	-- Spawns the WebUI
	local webui = WebUI("TV", url, WidgetVisibility.Hidden, false, false, 1120, 630)

	-- Spawns the Sound from the WebUI and attaches to the TV prop
	local soundbox_01 = self:GetValue("SoundBox_01")
	local sound_01 = webui:SpawnSound(self:GetLocation(), false, 1, 100, 3600, AttenuationFunction.NaturalSound)
	sound_01:AttachTo(soundbox_01, AttachmentRule.SnapToTarget, "", 0)

	local soundbox_02 = self:GetValue("SoundBox_02")
	local sound_02 = webui:SpawnSound(self:GetLocation(), false, 1, 100, 3600, AttenuationFunction.NaturalSound)
	sound_02:AttachTo(soundbox_02, AttachmentRule.SnapToTarget, "", 0)

	-- Sets the new WebUI as the Material
	self:SetWebUIMaterial(webui)

	-- Stores the WebUI in the entity to be destroyed later
	self:SetValue("MaterialWebUI", webui)
end

function TV:Reset()
	local existing_white_noise_01 = self:GetValue("WhiteNoise_01")
	if (existing_white_noise_01 and existing_white_noise_01:IsValid()) then
		existing_white_noise_01:Destroy()
	end

	local existing_white_noise_02 = self:GetValue("WhiteNoise_02")
	if (existing_white_noise_02 and existing_white_noise_02:IsValid()) then
		existing_white_noise_02:Destroy()
	end
end

-- Sets the webui URL
function TV:SetWebUIMaterial(webui)
	self:SetMaterialFromWebUI(webui, 1)
	self:SetMaterialColorParameter("Emissive", Color(0.3))
	self:SetMaterialScalarParameter("Roughness", 0.1)

	self:Reset()
end

-- Sets a no-signal effect on the TV
function TV:SetNoSignal()
	self:SetMaterial("nanos-world::M_Noise", 1)
	self:SetMaterialColorParameter("Emissive", Color(0.3))
	self:SetMaterialScalarParameter("Roughness", 0.1)

	local existing_white_noise_01 = self:GetValue("WhiteNoise_01")
	if (not existing_white_noise_01 or not existing_white_noise_01:IsValid()) then
		local soundbox_01 = self:GetValue("SoundBox_01")
		if (soundbox_01 and soundbox_01:IsValid()) then
			local white_noise_01 = Sound(Vector(), "nanos-world::A_WhiteNoise", false, false, SoundType.SFX, 0.05, 1.5, 400, 3600, AttenuationFunction.NaturalSound)
			white_noise_01:AttachTo(soundbox_01, AttachmentRule.SnapToTarget, "", 0)
			self:SetValue("WhiteNoise_01", white_noise_01)
		end
	end

	local existing_white_noise_02 = self:GetValue("WhiteNoise_02")
	if (not existing_white_noise_02 or not existing_white_noise_02:IsValid()) then
		local soundbox_02 = self:GetValue("SoundBox_02")
		if (soundbox_02 and soundbox_02:IsValid()) then
			local white_noise_02 = Sound(Vector(), "nanos-world::A_WhiteNoise", false, false, SoundType.SFX, 0.05, 1.5, 400, 3600, AttenuationFunction.NaturalSound)
			white_noise_02:AttachTo(soundbox_02, AttachmentRule.SnapToTarget, "", 0)
			self:SetValue("WhiteNoise_02", white_noise_02)
		end
	end
end

TV.Subscribe("Destroy", TV.OnDestroy)
TV.Subscribe("ValueChange", TV.OnValueChange)


CURRENTLY_INTERACTING_TV = nil

-- Subscribes from WebUI, to know when the PopUp has been submitted
MainHUD:Subscribe("OnTVSetWebsite", function(submitted, text)
	Input.SetMouseEnabled(false)
	Input.SetInputEnabled(true)

	if (not submitted) then
		CURRENTLY_INTERACTING_TV = nil
		return
	end

	if (not CURRENTLY_INTERACTING_TV or not CURRENTLY_INTERACTING_TV:IsValid()) then
		Console.Error("Failed to find currently interacting TV!")
		return
	end

	-- Calls remote to sync the Website with everyone logged
	CURRENTLY_INTERACTING_TV:CallRemoteEvent("SetWebsite", text)
end)

-- Called by Server when Player interacts with a TV
Events.SubscribeRemote("InteractTV", function(tv_prop)
	CURRENTLY_INTERACTING_TV = tv_prop

	-- Disables Input
	Input.SetMouseEnabled(true)
	Input.SetInputEnabled(false)

	-- Opens PopUp to enter the TV URL
	MainHUD:CallEvent("ShowPopUpPrompt", "enter a YouTube URL", "OnTVSetWebsite")
end)